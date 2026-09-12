-- Existing-database patch for secure Mushavo Homes inspection and public-listing workflows.
-- Run this once in the Supabase SQL editor for the existing project.
-- Safe to rerun: functions are replaced and policies are dropped idempotently.

begin;

create or replace function public.can_create_inspection_for_unit(p_unit_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.units u
    join public.properties p on p.id = u.property_id
    where u.id = p_unit_id
      and u.archived_at is null
      and p.archived_at is null
      and (
        public.is_super_admin()
        or public.admin_staff_can_access_unit(u.id)
        or p.landlord_id = auth.uid()
        or (
          public.current_profile_role() = 'staff'
          and public.staff_can_access_unit(u.id)
          and (
            public.staff_permission_flag('can_manage_maintenance')
            or public.staff_permission_flag('can_create_maintenance')
            or public.staff_permission_flag('can_add_resolution_notes')
            or public.staff_permission_flag('can_edit_units')
          )
        )
        or (
          public.current_profile_role() in ('management_leader', 'management_staff')
          and public.management_can_access_unit(u.id)
          and (
            public.current_profile_role() = 'management_leader'
            or public.management_permission_flag('can_manage_maintenance')
            or public.management_permission_flag('can_create_maintenance')
            or public.management_permission_flag('can_add_resolution_notes')
            or public.management_permission_flag('can_edit_units')
          )
        )
      )
  )
$$;

create or replace function public.can_access_inspection(p_inspection_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  inspection_row public.property_inspections%rowtype;
begin
  select *
  into inspection_row
  from public.property_inspections
  where id = p_inspection_id;

  if not found then
    return false;
  end if;

  if public.is_super_admin()
     or public.admin_staff_can_access_unit(inspection_row.unit_id)
     or inspection_row.landlord_id = auth.uid()
     or public.staff_can_access_unit(inspection_row.unit_id)
     or public.management_can_access_unit(inspection_row.unit_id) then
    return true;
  end if;

  return exists (
    select 1
    from public.tenants t
    join public.leases l
      on l.id = inspection_row.lease_id
     and l.tenant_id = t.id
     and l.unit_id = inspection_row.unit_id
     and l.landlord_id = inspection_row.landlord_id
    where t.id = inspection_row.tenant_id
      and t.profile_id = auth.uid()
      and t.archived_at is null
      and inspection_row.status in ('completed', 'locked')
  );
end;
$$;

create or replace function public.can_manage_inspection(p_inspection_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  inspection_row public.property_inspections%rowtype;
begin
  select *
  into inspection_row
  from public.property_inspections
  where id = p_inspection_id;

  if not found then
    return false;
  end if;

  return public.can_create_inspection_for_unit(inspection_row.unit_id);
end;
$$;

create or replace function public.can_read_inspection_file(p_object_name text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.property_inspections pi
    where pi.id = public.inspection_file_inspection_id(p_object_name)
      and split_part(p_object_name, '/', 1) = pi.landlord_id::text
      and public.can_access_inspection(pi.id)
  )
$$;

create or replace function public.can_manage_inspection_file(p_object_name text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.property_inspections pi
    where pi.id = public.inspection_file_inspection_id(p_object_name)
      and split_part(p_object_name, '/', 1) = pi.landlord_id::text
      and pi.status <> 'locked'
      and public.can_manage_inspection(pi.id)
  )
$$;

create or replace function public.tenant_sign_inspection(
  p_inspection_id uuid,
  p_signature_name text
)
returns public.property_inspections
language plpgsql
security definer
set search_path = public
as $$
declare
  signed_row public.property_inspections%rowtype;
begin
  if nullif(trim(p_signature_name), '') is null then
    raise exception 'Please enter the tenant signature name.';
  end if;

  update public.property_inspections pi
  set tenant_signature_name = trim(p_signature_name),
      tenant_signed_at = now(),
      updated_at = now(),
      updated_by = auth.uid()
  where pi.id = p_inspection_id
    and pi.status = 'completed'
    and pi.tenant_signed_at is null
    and exists (
      select 1
      from public.tenants t
      join public.leases l
        on l.id = pi.lease_id
       and l.tenant_id = t.id
       and l.unit_id = pi.unit_id
       and l.landlord_id = pi.landlord_id
      where t.id = pi.tenant_id
        and t.profile_id = auth.uid()
        and t.archived_at is null
    )
  returning * into signed_row;

  if not found then
    raise exception 'Inspection could not be signed.';
  end if;

  return signed_row;
end;
$$;

create or replace function public.save_property_inspection(
  p_inspection_id uuid,
  p_unit_id uuid,
  p_inspection_type text,
  p_status text,
  p_scheduled_for date,
  p_inspected_at timestamptz,
  p_compared_to_inspection_id uuid,
  p_meter_readings jsonb,
  p_room_conditions jsonb,
  p_summary_notes text,
  p_deposit_deduction_amount numeric,
  p_deposit_deduction_notes text
)
returns public.property_inspections
language plpgsql
security definer
set search_path = public
as $$
declare
  property_uuid uuid;
  landlord_uuid uuid;
  lease_uuid uuid;
  tenant_uuid uuid;
  saved_row public.property_inspections%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required.';
  end if;

  if p_inspection_type is null or p_inspection_type not in ('move_in', 'routine', 'move_out') then
    raise exception 'Invalid inspection type.';
  end if;

  if p_status is null or p_status not in ('draft', 'completed') then
    raise exception 'Save the inspection as draft or completed, then use Lock Record.';
  end if;

  if jsonb_typeof(coalesce(p_room_conditions, '[]'::jsonb)) <> 'array' then
    raise exception 'Add at least one room condition before saving the inspection.';
  end if;

  if jsonb_array_length(coalesce(p_room_conditions, '[]'::jsonb)) = 0 then
    raise exception 'Add at least one room condition before saving the inspection.';
  end if;

  if p_inspection_id is null then
    select u.property_id, p.landlord_id, l.id, l.tenant_id
    into property_uuid, landlord_uuid, lease_uuid, tenant_uuid
    from public.units u
    join public.properties p on p.id = u.property_id
    join public.leases l
      on l.unit_id = u.id
     and l.landlord_id = p.landlord_id
     and l.status = 'active'
    join public.tenants t
      on t.id = l.tenant_id
     and t.archived_at is null
    where u.id = p_unit_id
      and u.archived_at is null
      and p.archived_at is null
    order by l.created_at desc
    limit 1;

    if not found then
      raise exception 'An active lease and linked tenant are required for this inspection.';
    end if;

    if not public.can_create_inspection_for_unit(p_unit_id) then
      raise exception 'You do not have permission to manage inspections for this unit.';
    end if;
  else
    select pi.property_id, pi.landlord_id, pi.lease_id, pi.tenant_id
    into property_uuid, landlord_uuid, lease_uuid, tenant_uuid
    from public.property_inspections pi
    where pi.id = p_inspection_id
      and pi.unit_id = p_unit_id
      and pi.status <> 'locked';

    if not found then
      raise exception 'Inspection not found or already locked.';
    end if;

    if not public.can_manage_inspection(p_inspection_id) then
      raise exception 'You do not have permission to manage this inspection.';
    end if;
  end if;

  if p_compared_to_inspection_id is not null and not exists (
    select 1
    from public.property_inspections compared
    where compared.id = p_compared_to_inspection_id
      and compared.unit_id = p_unit_id
      and compared.id is distinct from p_inspection_id
  ) then
    raise exception 'The comparison inspection must belong to the same unit.';
  end if;

  if p_inspection_id is null then
    insert into public.property_inspections (
      landlord_id,
      property_id,
      unit_id,
      lease_id,
      tenant_id,
      inspection_type,
      status,
      scheduled_for,
      inspected_at,
      inspector_profile_id,
      meter_readings,
      room_conditions,
      summary_notes,
      deposit_deduction_amount,
      deposit_deduction_notes,
      compared_to_inspection_id,
      created_by
    ) values (
      landlord_uuid,
      property_uuid,
      p_unit_id,
      lease_uuid,
      tenant_uuid,
      p_inspection_type,
      p_status,
      p_scheduled_for,
      coalesce(p_inspected_at, now()),
      auth.uid(),
      coalesce(p_meter_readings, '{}'::jsonb),
      p_room_conditions,
      nullif(trim(coalesce(p_summary_notes, '')), ''),
      case when p_inspection_type = 'move_out' then greatest(coalesce(p_deposit_deduction_amount, 0), 0) else 0 end,
      case when p_inspection_type = 'move_out' then nullif(trim(coalesce(p_deposit_deduction_notes, '')), '') else null end,
      p_compared_to_inspection_id,
      auth.uid()
    )
    returning * into saved_row;
  else
    update public.property_inspections pi
    set inspection_type = p_inspection_type,
        status = p_status,
        scheduled_for = p_scheduled_for,
        inspected_at = coalesce(p_inspected_at, pi.inspected_at, now()),
        inspector_profile_id = auth.uid(),
        meter_readings = coalesce(p_meter_readings, '{}'::jsonb),
        room_conditions = p_room_conditions,
        summary_notes = nullif(trim(coalesce(p_summary_notes, '')), ''),
        deposit_deduction_amount = case when p_inspection_type = 'move_out' then greatest(coalesce(p_deposit_deduction_amount, 0), 0) else 0 end,
        deposit_deduction_notes = case when p_inspection_type = 'move_out' then nullif(trim(coalesce(p_deposit_deduction_notes, '')), '') else null end,
        compared_to_inspection_id = p_compared_to_inspection_id,
        updated_by = auth.uid()
    where pi.id = p_inspection_id
    returning * into saved_row;
  end if;

  return saved_row;
end;
$$;

create or replace function public.lock_property_inspection(p_inspection_id uuid)
returns public.property_inspections
language plpgsql
security definer
set search_path = public
as $$
declare
  locked_row public.property_inspections%rowtype;
begin
  if auth.uid() is null or not public.can_manage_inspection(p_inspection_id) then
    raise exception 'You do not have permission to lock this inspection.';
  end if;

  update public.property_inspections pi
  set status = 'locked',
      locked_at = now(),
      locked_by = auth.uid(),
      updated_by = auth.uid()
  where pi.id = p_inspection_id
    and pi.status <> 'locked'
  returning * into locked_row;

  if not found then
    raise exception 'Inspection not found or already locked.';
  end if;

  return locked_row;
end;
$$;

create or replace function public.register_inspection_file(
  p_inspection_id uuid,
  p_file_kind text,
  p_room_name text,
  p_caption text,
  p_object_path text,
  p_mime_type text,
  p_file_size bigint
)
returns public.inspection_files
language plpgsql
security definer
set search_path = public
as $$
declare
  inspection_row public.property_inspections%rowtype;
  saved_file public.inspection_files%rowtype;
  expected_prefix text;
begin
  select *
  into inspection_row
  from public.property_inspections pi
  where pi.id = p_inspection_id
    and pi.status <> 'locked';

  if not found or not public.can_manage_inspection(p_inspection_id) then
    raise exception 'You do not have permission to add evidence to this inspection.';
  end if;

  if p_file_kind is null or p_file_kind not in ('photo', 'video', 'document', 'signature', 'deduction_evidence') then
    raise exception 'Invalid inspection evidence type.';
  end if;

  if coalesce(p_file_size, 0) <= 0 then
    raise exception 'Inspection evidence file size is invalid.';
  end if;

  expected_prefix := inspection_row.landlord_id::text || '/' || inspection_row.id::text || '/';
  if p_object_path is null or left(p_object_path, length(expected_prefix)) <> expected_prefix then
    raise exception 'Inspection evidence path does not match the inspection.';
  end if;

  if not exists (
    select 1
    from storage.objects object_row
    where object_row.bucket_id = 'inspection-files'
      and object_row.name = p_object_path
  ) then
    raise exception 'Inspection evidence upload was not found.';
  end if;

  insert into public.inspection_files (
    inspection_id,
    landlord_id,
    property_id,
    unit_id,
    lease_id,
    tenant_id,
    file_kind,
    room_name,
    caption,
    object_path,
    mime_type,
    file_size,
    uploaded_by
  ) values (
    inspection_row.id,
    inspection_row.landlord_id,
    inspection_row.property_id,
    inspection_row.unit_id,
    inspection_row.lease_id,
    inspection_row.tenant_id,
    p_file_kind,
    nullif(trim(coalesce(p_room_name, '')), ''),
    nullif(trim(coalesce(p_caption, '')), ''),
    p_object_path,
    nullif(trim(coalesce(p_mime_type, '')), ''),
    p_file_size,
    auth.uid()
  )
  returning * into saved_file;

  return saved_file;
end;
$$;

create or replace function public.get_my_property_inspections()
returns setof public.property_inspections
language sql
stable
security definer
set search_path = public
as $$
  select pi.*
  from public.property_inspections pi
  join public.tenants t
    on t.id = pi.tenant_id
   and t.profile_id = auth.uid()
   and t.archived_at is null
  join public.leases l
    on l.id = pi.lease_id
   and l.tenant_id = t.id
   and l.unit_id = pi.unit_id
   and l.landlord_id = pi.landlord_id
  where pi.status in ('completed', 'locked')
  order by pi.created_at desc
$$;

drop policy if exists "property inspections insert scoped" on public.property_inspections;
drop policy if exists "property inspections update scoped" on public.property_inspections;
drop policy if exists "inspection files insert scoped" on public.inspection_files;
drop policy if exists "inspection files update scoped" on public.inspection_files;

revoke all on public.property_inspections from authenticated;
revoke all on public.inspection_files from authenticated;
grant select, delete on public.property_inspections to authenticated;
grant select, delete on public.inspection_files to authenticated;

revoke execute on function public.save_property_inspection(uuid, uuid, text, text, date, timestamptz, uuid, jsonb, jsonb, text, numeric, text) from public, anon;
revoke execute on function public.lock_property_inspection(uuid) from public, anon;
revoke execute on function public.register_inspection_file(uuid, text, text, text, text, text, bigint) from public, anon;
revoke execute on function public.get_my_property_inspections() from public, anon;

grant execute on function public.can_create_inspection_for_unit(uuid) to authenticated;
grant execute on function public.can_access_inspection(uuid) to authenticated;
grant execute on function public.can_manage_inspection(uuid) to authenticated;
grant execute on function public.can_read_inspection_file(text) to authenticated;
grant execute on function public.can_manage_inspection_file(text) to authenticated;
grant execute on function public.tenant_sign_inspection(uuid, text) to authenticated;
grant execute on function public.save_property_inspection(uuid, uuid, text, text, date, timestamptz, uuid, jsonb, jsonb, text, numeric, text) to authenticated;
grant execute on function public.lock_property_inspection(uuid) to authenticated;
grant execute on function public.register_inspection_file(uuid, text, text, text, text, text, bigint) to authenticated;
grant execute on function public.get_my_property_inspections() to authenticated;

-- Secure landlord listing photos and keep public listing data aligned with live unit details.
alter table public.unit_listings
  add column if not exists photo_paths text[] not null default '{}'::text[];

-- Listing changes must pass through the validated RPC, not direct browser writes.
drop policy if exists "unit listings crm insert" on public.unit_listings;
drop policy if exists "unit listings crm update" on public.unit_listings;
revoke insert, update on public.unit_listings from authenticated;
grant select on public.unit_listings to authenticated;

drop function if exists public.get_public_unit_listings(uuid, text, numeric, numeric, numeric, text);
create or replace function public.get_public_unit_listings(
  p_country_id uuid default null,
  p_area text default null,
  p_min_rent numeric default null,
  p_max_rent numeric default null,
  p_bedrooms numeric default null,
  p_availability text default null
)
returns table (
  id uuid,
  country_id uuid,
  country_name text,
  country_code text,
  city text,
  public_area text,
  property_name text,
  title text,
  summary text,
  unit_summary text,
  monthly_rent numeric,
  availability_status text,
  available_from date,
  bedrooms numeric,
  bathrooms numeric,
  show_rent boolean,
  photo_urls text[],
  photo_paths text[]
)
language sql
stable
security definer
set search_path = public
as $$
  select
    ul.id,
    ul.country_id,
    c.name,
    c.code,
    p.city,
    coalesce(nullif(ul.public_area, ''), p.city),
    p.name,
    ul.title,
    ul.summary,
    trim(concat('Unit ', u.unit_number, ' - ', u.bedrooms, ' bed, ', u.bathrooms, ' bath')),
    case when ul.show_rent then u.monthly_rent else null end,
    ul.availability_status,
    ul.available_from,
    u.bedrooms,
    u.bathrooms,
    ul.show_rent,
    case when ul.show_photos then ul.photo_urls else '{}'::text[] end,
    case when ul.show_photos then ul.photo_paths else '{}'::text[] end
  from public.unit_listings ul
  join public.units u on u.id = ul.unit_id
  join public.properties p on p.id = ul.property_id
  left join public.countries c on c.id = ul.country_id
  where ul.status = 'published'
    and ul.archived_at is null
    and p.archived_at is null
    and u.archived_at is null
    and (u.status = 'vacant' or ul.availability_status = 'available_soon')
    and (p_country_id is null or ul.country_id = p_country_id)
    and (p_area is null or p_area = '' or p.city ilike '%' || p_area || '%' or ul.public_area ilike '%' || p_area || '%' or p.name ilike '%' || p_area || '%')
    and (p_min_rent is null or u.monthly_rent >= p_min_rent)
    and (p_max_rent is null or u.monthly_rent <= p_max_rent)
    and (p_bedrooms is null or u.bedrooms >= p_bedrooms)
    and (p_availability is null or p_availability = '' or ul.availability_status = p_availability)
  order by ul.published_at desc nulls last, ul.created_at desc
$$;

drop function if exists public.get_manageable_listing_units();
create or replace function public.get_manageable_listing_units()
returns table (
  unit_id uuid,
  property_id uuid,
  landlord_id uuid,
  country_id uuid,
  property_name text,
  city text,
  unit_number text,
  bedrooms numeric,
  bathrooms numeric,
  monthly_rent numeric,
  unit_status public.unit_status,
  listing_id uuid,
  listing_status text,
  listing_title text,
  listing_summary text,
  public_area text,
  availability_status text,
  available_from date,
  show_rent boolean,
  show_photos boolean,
  photo_urls text[],
  photo_paths text[]
)
language sql
stable
security definer
set search_path = public
as $$
  select
    u.id,
    p.id,
    p.landlord_id,
    pr.country_id,
    p.name,
    p.city,
    u.unit_number,
    u.bedrooms,
    u.bathrooms,
    u.monthly_rent,
    u.status,
    ul.id,
    ul.status,
    ul.title,
    ul.summary,
    ul.public_area,
    ul.availability_status,
    ul.available_from,
    ul.show_rent,
    ul.show_photos,
    coalesce(ul.photo_urls, '{}'::text[]),
    coalesce(ul.photo_paths, '{}'::text[])
  from public.units u
  join public.properties p on p.id = u.property_id
  join public.profiles pr on pr.id = p.landlord_id
  left join public.unit_listings ul on ul.unit_id = u.id and ul.archived_at is null
  where p.archived_at is null
    and u.archived_at is null
    and public.crm_can_access_property(p.id)
  order by p.name, u.unit_number
$$;

drop function if exists public.upsert_unit_listing(uuid, text, text, text, text, text, date, boolean, boolean, text[]);
drop function if exists public.upsert_unit_listing(uuid, text, text, text, text, text, date, boolean, boolean, text[], text[]);
create or replace function public.upsert_unit_listing(
  p_unit_id uuid,
  p_status text,
  p_title text,
  p_summary text default null,
  p_public_area text default null,
  p_availability_status text default 'available',
  p_available_from date default null,
  p_show_rent boolean default true,
  p_show_photos boolean default true,
  p_photo_paths text[] default '{}'::text[],
  p_legacy_photo_urls text[] default '{}'::text[]
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  unit_record record;
  existing_id uuid;
  existing_photo_paths text[] := '{}'::text[];
  existing_photo_urls text[] := '{}'::text[];
  requested_photo_paths text[] := coalesce(p_photo_paths, '{}'::text[]);
  requested_photo_urls text[] := coalesce(p_legacy_photo_urls, '{}'::text[]);
  saved_id uuid;
  role_value public.user_role;
  object_path text;
  legacy_url text;
  expected_prefix text;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required.';
  end if;

  if p_status is null or p_status not in ('draft', 'published', 'paused') then
    raise exception 'Select a valid listing status.';
  end if;

  if p_availability_status is null or p_availability_status not in ('available', 'available_soon') then
    raise exception 'Select a valid availability status.';
  end if;

  select u.id as unit_id, u.property_id, p.landlord_id, pr.country_id,
         u.monthly_rent, u.bedrooms, u.bathrooms, u.status as unit_status
    into unit_record
  from public.units u
  join public.properties p on p.id = u.property_id
  join public.profiles pr on pr.id = p.landlord_id
  where u.id = p_unit_id
    and u.archived_at is null
    and p.archived_at is null;

  if unit_record.unit_id is null then
    raise exception 'Unit not found.';
  end if;

  if not public.crm_can_access_property(unit_record.property_id, 'can_publish_listings') then
    raise exception 'You do not have permission to publish listings.';
  end if;

  role_value := public.current_profile_role();

  select id, coalesce(photo_paths, '{}'::text[]), coalesce(photo_urls, '{}'::text[])
    into existing_id, existing_photo_paths, existing_photo_urls
  from public.unit_listings
  where unit_id = p_unit_id
    and archived_at is null
  limit 1;

  existing_photo_paths := coalesce(existing_photo_paths, '{}'::text[]);
  existing_photo_urls := coalesce(existing_photo_urls, '{}'::text[]);

  if cardinality(requested_photo_paths) + cardinality(requested_photo_urls) > 10 then
    raise exception 'A listing can have a maximum of 10 photos.';
  end if;

  foreach legacy_url in array requested_photo_urls loop
    if nullif(trim(legacy_url), '') is null or not (legacy_url = any(existing_photo_urls)) then
      raise exception 'New URL-based listing photos are not allowed. Upload an image file instead.';
    end if;
  end loop;

  expected_prefix := auth.uid()::text || '/' || p_unit_id::text || '/';
  foreach object_path in array requested_photo_paths loop
    if nullif(trim(object_path), '') is null then
      raise exception 'A listing photo path is invalid.';
    end if;

    if not (object_path = any(existing_photo_paths)) then
      if left(object_path, length(expected_prefix)) <> expected_prefix then
        raise exception 'A listing photo does not belong to the current user and unit.';
      end if;

      if not exists (
        select 1
        from storage.objects object_row
        where object_row.bucket_id = 'listing-photos'
          and object_row.name = object_path
      ) then
        raise exception 'A listing photo upload could not be verified.';
      end if;
    end if;
  end loop;

  foreach object_path in array existing_photo_paths loop
    if not (object_path = any(requested_photo_paths))
       and split_part(object_path, '/', 1) <> auth.uid()::text then
      raise exception 'Only the person who uploaded a listing photo can remove it.';
    end if;
  end loop;

  if p_status = 'published' then
    if nullif(trim(coalesce(p_title, '')), '') is null
       or nullif(trim(coalesce(p_summary, '')), '') is null
       or nullif(trim(coalesce(p_public_area, '')), '') is null
       or p_available_from is null then
      raise exception 'Title, summary, public area, and available-from date are required before publishing.';
    end if;

    if coalesce(unit_record.monthly_rent, 0) <= 0 then
      raise exception 'Add the unit rent before publishing this listing.';
    end if;

    if coalesce(unit_record.bathrooms, 0) <= 0 then
      raise exception 'Add the unit bathroom details before publishing this listing.';
    end if;

    if cardinality(requested_photo_paths) + cardinality(requested_photo_urls) = 0 then
      raise exception 'Upload at least one property photo before publishing.';
    end if;

    if not coalesce(p_show_rent, false) or not coalesce(p_show_photos, false) then
      raise exception 'Published listings must show the saved rent and property photos.';
    end if;

    if p_availability_status = 'available' and unit_record.unit_status <> 'vacant' then
      raise exception 'Only a vacant unit can be listed as available now. Use available soon instead.';
    end if;
  end if;

  if existing_id is null then
    insert into public.unit_listings (
      unit_id, property_id, landlord_id, country_id, published_by,
      manager_profile_id, management_company_id, manager_role,
      status, title, summary, public_area, availability_status,
      available_from, show_rent, show_photos, photo_urls, photo_paths, published_at
    )
    values (
      p_unit_id, unit_record.property_id, unit_record.landlord_id, unit_record.country_id, auth.uid(),
      auth.uid(), public.current_management_company_id(),
      case
        when role_value = 'staff' then 'landlord_staff'
        when role_value = 'management_leader' and public.current_management_company_id() is not null then 'pmc'
        when role_value = 'management_staff' then 'pmc_staff'
        when role_value = 'super_admin' then 'admin'
        when role_value = 'admin_staff' then 'admin_staff'
        else 'landlord'
      end,
      p_status, coalesce(nullif(trim(p_title), ''), 'Draft listing'), nullif(trim(coalesce(p_summary, '')), ''), nullif(trim(coalesce(p_public_area, '')), ''), p_availability_status,
      p_available_from, coalesce(p_show_rent, true), coalesce(p_show_photos, true), requested_photo_urls, requested_photo_paths,
      case when p_status = 'published' then now() else null end
    )
    returning id into saved_id;
  else
    update public.unit_listings
    set status = p_status,
        title = coalesce(nullif(trim(p_title), ''), title),
        summary = nullif(trim(coalesce(p_summary, '')), ''),
        public_area = nullif(trim(coalesce(p_public_area, '')), ''),
        availability_status = p_availability_status,
        available_from = p_available_from,
        show_rent = coalesce(p_show_rent, true),
        show_photos = coalesce(p_show_photos, true),
        photo_urls = requested_photo_urls,
        photo_paths = requested_photo_paths,
        published_by = auth.uid(),
        published_at = case when p_status = 'published' and published_at is null then now() else published_at end
    where id = existing_id
    returning id into saved_id;
  end if;

  return saved_id;
end;
$$;

create or replace function public.can_manage_listing_photo(p_object_name text)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  object_unit_id uuid;
  object_property_id uuid;
begin
  if auth.uid() is null
     or split_part(coalesce(p_object_name, ''), '/', 1) <> auth.uid()::text then
    return false;
  end if;

  object_unit_id := split_part(p_object_name, '/', 2)::uuid;

  select u.property_id
    into object_property_id
  from public.units u
  join public.properties p on p.id = u.property_id
  where u.id = object_unit_id
    and u.archived_at is null
    and p.archived_at is null;

  return object_property_id is not null
    and public.crm_can_access_property(object_property_id, 'can_publish_listings');
exception
  when invalid_text_representation then
    return false;
end;
$$;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'listing-photos',
  'listing-photos',
  true,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']::text[]
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "listing photos public read" on storage.objects;
create policy "listing photos public read"
on storage.objects for select to anon, authenticated
using (bucket_id = 'listing-photos');

drop policy if exists "listing photos insert own" on storage.objects;
create policy "listing photos insert own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'listing-photos'
  and public.can_manage_listing_photo(name)
);

drop policy if exists "listing photos update own" on storage.objects;
create policy "listing photos update own"
on storage.objects for update to authenticated
using (
  bucket_id = 'listing-photos'
  and public.can_manage_listing_photo(name)
)
with check (
  bucket_id = 'listing-photos'
  and public.can_manage_listing_photo(name)
);

drop policy if exists "listing photos delete own" on storage.objects;
create policy "listing photos delete own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'listing-photos'
  and public.can_manage_listing_photo(name)
);

grant execute on function public.get_public_unit_listings(uuid, text, numeric, numeric, numeric, text) to anon, authenticated;
grant execute on function public.get_manageable_listing_units() to authenticated;
revoke execute on function public.upsert_unit_listing(uuid, text, text, text, text, text, date, boolean, boolean, text[], text[]) from public, anon;
grant execute on function public.upsert_unit_listing(uuid, text, text, text, text, text, date, boolean, boolean, text[], text[]) to authenticated;
revoke execute on function public.can_manage_listing_photo(text) from public, anon;
grant execute on function public.can_manage_listing_photo(text) to authenticated;

-- Apply the official Mushavo Homes brand name to existing hosted database text.
-- Function signatures and technical identifiers are intentionally unchanged.
do $brand_rename$
declare
  function_row record;
  function_definition text;
begin
  for function_row in
    select p.oid
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prokind in ('f', 'p')
      and pg_get_functiondef(p.oid) like '%Mushavo%'
      and pg_get_functiondef(p.oid) not like '%Mushavo Homes%'
  loop
    function_definition := pg_get_functiondef(function_row.oid);
    function_definition := replace(function_definition, $old_brand$Mushavo's$old_brand$, $new_brand$Mushavo Homes'$new_brand$);
    function_definition := replace(function_definition, 'Mushavo', 'Mushavo Homes');
    execute function_definition;
  end loop;
end;
$brand_rename$;

update public.profiles
set full_name = 'Mushavo Homes Super Admin'
where role = 'super_admin'
  and full_name = 'Mushavo Super Admin';

update public.pricing_plans
set description = replace(description, 'Mushavo', 'Mushavo Homes'),
    updated_at = now()
where description like '%Mushavo%'
  and description not like '%Mushavo Homes%';

update public.automation_templates
set message = replace(message, 'Mushavo', 'Mushavo Homes'),
    updated_at = now()
where message like '%Mushavo%'
  and message not like '%Mushavo Homes%';

update public.notifications
set message = replace(message, 'Mushavo', 'Mushavo Homes')
where message like '%Mushavo%'
  and message not like '%Mushavo Homes%';

-- Make newly created RPC signatures available to PostgREST immediately.
notify pgrst, 'reload schema';

commit;

-- The result should list all five inspection RPCs and the three listing RPCs.
select routine_name
from information_schema.routines
where routine_schema = 'public'
  and routine_name in (
    'get_manageable_listing_units',
    'get_my_property_inspections',
    'get_public_unit_listings',
    'lock_property_inspection',
    'register_inspection_file',
    'save_property_inspection',
    'tenant_sign_inspection',
    'upsert_unit_listing'
  )
order by routine_name;

-- The result should show listing-photos as public with a 10 MB limit.
select id, public, file_size_limit, allowed_mime_types
from storage.buckets
where id = 'listing-photos';
