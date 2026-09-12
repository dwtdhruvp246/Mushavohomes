# Mushavo Homes Continuation Prompt For Next Chat

## Current Override - August 9, 2026

Use this section as the current source of truth if older notes below conflict with it.

Canonical local project folder:

`C:\Users\HP\Desktop\Mushavo Homes`

Work from this folder using a focused Git branch created from the latest GitHub `main`. Do not edit `main` directly. Do not use old `ne\outputs` files as the source of truth unless the owner explicitly asks. Do not update `rules.md` or this prompt unless the owner explicitly asks.

Important files:

- `client.html` - client area app for admin, admin staff, landlords, tenants, IPMs, PMCs, landlord staff, and PMC staff.
- `index.html`, `about.html`, `pricing.html`, `contact.html`, `available-units.html` - public website pages.
- `landlord-signup.html` - free landlord signup page.
- `tenant-signup.html` - tenant signup page.
- `i18n.js` - shared translation dictionary/helpers.
- `rentradar_loop1_schema.sql` - full Supabase schema/RLS/RPC/storage setup.
- `rules.md` - product and engineering rules that must be followed.

The app is now a static multi-page HTML app, not a single-file app. It still uses Tailwind CDN, Alpine.js CDN, Supabase JS SDK CDN, jsPDF CDN, Inter font, Supabase PostgreSQL/Auth/Storage/RLS/Realtime, and static hosting.

Primary rule: before changing code, read `rules.md`. If the owner reports a bug, search all role paths affected by that bug, not only the visible page.

## Current Product Terminology

- IPM means `Individual Portfolio Manager`.
- PMC means `Property Management Company`.
- Do not use old labels like freelancer manager or company management in visible UI.
- IPM/PMC menu labels should distinguish landlord-related payments from their own finance:
  - `Landlords Payments`
  - `Personal Finance`
- Landlord finance is private to the landlord and must not be exposed to IPM/PMC as if it is their finance page.

## Current Account Roles

- Admin: full platform owner access.
- Admin staff: platform staff restricted by assigned countries; cannot edit or delete finance/payment history entries.
- Landlord: owns properties, units, leases, tenants, staff, payments, maintenance, listings, and finance.
- Tenant: self-created account; accepts/rejects landlord link requests; submits payments and maintenance; can drop landlord only after no active lease remains.
- IPM: individual manager who connects to landlords and manages only assigned scope.
- PMC: property management company with leader and internal staff.
- Landlord staff: staff invited by a landlord and serving only that landlord.
- PMC staff: staff invited by a PMC and serving only that PMC.

## Current Subscription Rules

- Use combined `Plan / Status` labels, for example `Free - Active`, `Starter - Trial`, `Growth - Active`, `Pro - Active`.
- Trial is valid and must not be treated as suspended.
- Suspended and expired are separate lockout states.
- Suspended users get the suspension page.
- Expired users get the subscription expired page.
- Unsuspend must preserve the user's existing plan/status.
- Expiry status must be derived from expiry dates in admin/admin staff landlord, IPM, and PMC lists.
- New landlord direct signup or landlord invite by IPM/PMC defaults to `Free - Active`, 1 property, 1 unit, Finance page, 0 personal staff, 1 IPM/PMC connection, and no practical expiry.

## Current Country Rules

- All countries may appear in public signup/contact dropdowns.
- Admin Landlord Management should not show every world country by default. It should show `All countries` plus countries with landlords or intentionally added active markets.
- Add Country should use a dropdown from the world-country list, not free text.
- Admin staff may be assigned multiple countries and must be restricted to those countries for country-related work.
- Edit dialogs must reopen showing the saved country, not `Unassigned` or the first option.

## Current Tenant Lifecycle Rules

- Tenant signup is separate from login and lives on `tenant-signup.html`.
- Free landlord signup lives on `landlord-signup.html`.
- If a tenant does not exist, landlord/IPM/PMC invite flow should provide the tenant signup page link and friendly message: `Free tenant signup link ready. Copy and send it to the tenant.`
- If a landlord does not exist, IPM/PMC invite flow should provide the free landlord signup page link.
- If an existing tenant is found, send only a tenant-link request/notification.
- A tenant must accept before appearing in accepted tenant lists or assignable tenant dropdowns.
- Rejected tenant requests disappear and do not create accepted relationships.
- Landlord pages need a pending tenant requests list or page.
- Tenant Settings must show accepted landlords and allow dropping only after no active lease remains.
- Dropping a tenant-landlord relationship must not delete payment, lease, receipt, maintenance, or audit history.

## Current Payment And Finance Rules

- Tenant current balance is rent balance only and should include outstanding rent from previous months.
- Rent payments reduce rent balance.
- Non-rent, maintenance, and `Other` payments do not reduce rent balance.
- If payment purpose is `Other`, show `Amount` instead of `Rent amount`, and require a description.
- Deposit should appear as a payment purpose when unpaid, but deposits are not revenue.
- Wherever payments are shown, provide receipt/PDF download where applicable.
- Admin payment recording should use pricing-plan dropdowns with monthly/yearly options, auto-fill the amount, and keep the amount editable.
- Admin staff cannot edit or delete payment history or payment entries.

## Current UI And State Rules

- All account types must use the phone-friendly admin/admin-staff mobile header pattern.
- Mobile navigation uses a hamburger/menu drawer.
- Notification bell must remain visible on mobile.
- Logout moves into the mobile menu/drawer.
- Plan/status badges that do not fit move into the mobile menu/drawer.
- No page-wide horizontal scrolling on phones.
- Dialogs must be scrollable on small screens and always show close/cancel/save actions.
- Forms that take space should be collapsed behind Add buttons until needed.
- Property `Open Units` toggles to `Close Units`, and the expanded unit section opens directly under that property card.
- Avoid full-page reloads after add/edit/delete/payment/notification updates. Use granular section refreshes and preserve page, filters, selected tabs, selected landlord, open panels, and scroll position.
- Use stable containers/skeletons so data refreshes do not make the page jump.
- Sort buttons must sort by the clicked column only; no hidden primary sort should override the user's selected sort.

## Current Permission Rules

- Permissions must hide both actions and sensitive information when not granted.
- Domino dependencies apply. Example: edit-property controls cannot appear if view-property is not available.
- Maintenance create, assign, resolution, delete, and staff dropdown controls must only appear when the matching permission exists.
- Assignment dropdowns must only show staff actually inside the allowed landlord/IPM/PMC/property/unit scope.
- IPM per-landlord property limits must be enforced when assigning properties.

## Current Phase Rules

Completed or in-progress product phases:

1. Phase 1: Trust And Finance Core
2. Phase 2: Owner / Landlord Statements
3. Phase 3: Maintenance Workflow
4. Phase 4: Leasing And Tenant Lifecycle
5. Phase 5: Inspections
6. Phase 6: CRM And Public Vacancy Flow

Whenever a phase is completed:

- List the files/areas changed.
- Provide a feature testing checklist.
- Do not claim completion if any listed phase item was skipped.

Phase 6 current scope:

- Public available units/listings.
- Safe public listing details only, with exact address hidden.
- Internal Leads page for landlord, IPM, PMC, and permitted staff.
- Admin/admin staff oversight with admin staff country restrictions.
- Separate listing leads from general contact enquiries.
- Lead conversion creates a tenant-link request first, not an automatic lease.

## Current Supabase Rules

- `rentradar_loop1_schema.sql` must be runnable on a fresh empty Supabase project after everything has been deleted.
- Create tables before triggers, policies, or functions that reference them.
- Create helper functions before policies/RPCs that call them.
- Do not leave references to missing helper functions, old tables, or stale columns.
- If a function signature, return type, or parameter name changes, include `drop function if exists ...` before recreating it.
- Never put service-role/private secrets in frontend files. Supabase URL and anon key are public by design; RLS and RPC security are the real protection.

Act as an expert full-stack software engineer, product architect, and senior technical consultant. We are building **Mushavo Homes**, a multi-tenant property management SaaS for landlords, tenants, staff, and property/estate management companies.  you must use logical sense and see if the actions taken or something that is created is logically connected and correct.

Branding:

- Product name: **Mushavo Homes**
- Tagline: **Your property, handled simply.**
- Logo file expected beside `index.html`: `mushavo-logo.png`
- Do not reintroduce the old RentRadar/Musha branding unless the user explicitly asks.

This is a continuation of an existing build. **Do not restart from scratch.** Continue from the current deliverables:

- `outputs/index.html`
- `outputs/rentradar_loop1_schema.sql`
- `outputs/rentradar_next_chat_prompt.md`

Create a new file called Mushavo Homes and save all the files there.

The app is a **single-file static HTML app** using:

- HTML
- Tailwind CSS CDN
- Alpine.js CDN
- Supabase JS SDK CDN
- jsPDF CDN
- Inter font
- Supabase PostgreSQL/Auth/Storage
- GitHub Pages/static hosting

There is no npm, no bundler, no React, no server-side app code, and no API routes. Everything must run client-side through Supabase with RLS as the real security boundary.

## Latest State Added In Current Loop

The app now includes a first-pass **Management Companies** model:

- New roles: `management_leader` and `management_staff`.
- Admin has a **Management** page to invite management leaders, view country-scoped counts, and manage management company landlord/property/staff limits plus subscription status/expiry.
- Management leaders are created by admin invite only.
- Management leaders log into the normal app shell, can enter a landlord's 6-digit landlord code, and send an access request.
- Landlords review management company requests from the Staff page and approve/reject them.
- Approved management leaders can switch between approved landlords and use the landlord-style operational pages according to permission flags.
- Management leaders can invite internal management staff from the Staff page. These staff live under the management company and should not be listed as admin-level freelancer staff.
- Management staff are scoped to the landlord used at invite time and should be constrained by both the management company's landlord permission and the individual management staff permission.

Schema additions include:

- `management_companies`
- `management_landlord_requests`
- `management_landlord_permissions`
- `management_staff_permissions`
- RPCs: `request_management_landlord_access`, `approve_management_landlord_request`, `reject_management_landlord_request`
- Helpers: `current_management_company_id`, `management_permission_flag`, `management_can_access_property`, `management_can_access_unit`, `management_can_access_lease`, `management_can_access_tenant`

Important: after applying the SQL, test the management flow end-to-end because this feature touches Auth, invites, RLS, admin pages, landlord pages, and shared app pages.

## Latest Staff/Management Access Rules

- There are three staff types:
  - Landlord staff: invited by a landlord, works only for that landlord.
  - Freelancer staff: admin-invited only, can request access to multiple landlords within their subscription/limit.
  - Management staff: invited by a management leader, works only inside that management company.
- Admin Staff page should list and create only freelancer staff. Landlord staff and management company staff should not be shown in the admin freelancer staff list.
- Public staff signup is disabled in the UI; staff access should come from invite/admin flows.
- Admin-created freelancer staff invites require a country. Store the country on both `invite_tokens.country_id` and invite metadata so accepted freelancer staff profiles inherit the country.
- RLS must allow super admins to create freelancer staff invite tokens: `role = 'staff'`, `landlord_id is null`, `metadata ->> 'staff_type' = 'freelancer'`, and `country_id is not null`.
- Admin Staff page should merge accepted freelancer `profiles` with unused freelancer `invite_tokens`. Pending freelancer invites must show as `Invited` rows with Copy Link, Edit Invite, and Delete actions, but should not appear in Admin Finance staff payer dropdowns until accepted.
- Freelancer staff profiles created by admin invite can log in before any landlord approves them. If they have no approved `staff_permissions`, load the app with empty permissions and show the dashboard landlord-code request panel. They only need landlord approval after they submit a landlord code request.
- In Admin Staff, accepted freelancer accounts should show account status `Active` even when `landlord_count` is 0. Zero landlords means no approved landlord access yet, not pending account approval.
- Landlord-created personal staff invites are `invite_tokens` rows, not `staff_landlord_requests`. The landlord Staff page must display unused staff invite tokens as `Invited` rows with Copy Link/Edit/Delete actions.
- A landlord can only assign one external operator per property scope: either one management company or one freelancer staff member. Internal landlord staff are not part of this exclusivity rule.
- The SQL includes `prevent_external_assignment_overlap()` triggers on `staff_permissions` and `management_landlord_permissions` to enforce that rule outside the UI.
- The SQL also includes `prevent_management_staff_permission_overreach()` on `management_staff_permissions` so management leaders cannot assign internal staff beyond the properties that the landlord granted to the management company.
- Tenant Unit Details can call `tenant_unit_contacts(unit_id)` to show the assigned landlord staff, freelancer staff, management company, or management staff contact details.
- Management staff rows are scoped by `profiles.landlord_id`; when a management leader switches landlord, the Staff page should only show internal management staff assigned to that active landlord.
- Management leaders have the landlord-style dashboard, My Account, subscription badge, and a landlord switcher; fresh login should land on Dashboard even if `localStorage` has Staff saved from an earlier session.

## Permission Hierarchy Rules To Preserve

Permissions must work like a parent-child tree. Do not show child actions unless the parent permission is also granted, and enforce the same rule in Supabase RLS/triggers.

Properties:

- `can_view_properties`: can see property name, address, city, and landlord name. This alone does not reveal units.
- `can_add_properties`, `can_edit_properties`, and `can_archive_properties` require `can_view_properties`.
- `can_view_units` requires `can_view_properties` and controls Open Units, unit info, unit detail, and maintenance history under a property.
- `can_add_units`, `can_edit_units`, `can_archive_units`, and `can_mark_units_vacant` require `can_view_units`.

Tenants:

- `can_view_tenants`: can see tenant lists/details.
- `can_add_tenants`, `can_edit_tenants`, and `can_archive_tenants` require `can_view_tenants`.
- Tenant details inside unit/property views should only appear when both the relevant unit view and tenant view permission make sense.

Leases and documents:

- `can_view_leases` requires unit visibility.
- `can_create_leases` requires unit visibility and tenant visibility.
- `can_edit_leases`, `can_terminate_leases`, `can_view_lease_documents`, and `can_upload_lease_documents` require lease/unit visibility.
- Do not use the broad legacy `can_manage_leases` as a UI action check. Use exact helpers like `canCreateLeases()`, `canTerminateLeases()`, `canViewLeaseDocuments()`, and `canUploadLeaseDocuments()`. The SQL may still treat `can_manage_leases` as a legacy override for old rows.

Database enforcement:

- UI hiding is not enough. Every permission-sensitive action should also be enforced through RLS policies, RPC checks, or triggers.
- Existing SQL includes trigger guards for property, unit, lease, and tenant updates. Preserve those guards when changing schema.
- In the app shell, the account role label belongs beside the logo in the sidebar/mobile drawer, while the main topbar shows the current page. Tenant and admin shells already show their labels beside the logo.

## Critical Rules

1. Do not restart from scratch.
2. Read `outputs/index.html` and `outputs/rentradar_loop1_schema.sql` before editing.
3. Preserve all completed work.
4. Use `apply_patch` for manual code edits.
5. Do not expose or request a Supabase service role key.
6. Use only the Supabase anon key in browser code.
7. RLS remains the security boundary.
8. Invite tokens must remain single-use and 48-hour expiring.
9. Passwords must never be stored or logged in app code.
10. Keep UI light, professional, operational, and dense enough for SaaS workflows.
11. Inline forms must have visible labels. Do not regress to placeholder-only inputs.
12. After edits, run the inline JavaScript parse check.
13. Scan for `TODO`, `stub`, `placeholder logic`, `placeholder=`, `Ã‚`, `Â·`, `tenant-shell-placeholder`, `service_role`, and `service role`.
14. If using the in-app browser, note that browser automation may block `file://` URLs. Do not try to bypass that policy.

## Supabase Project Details

The current `outputs/index.html` already contains the Supabase URL and anon key supplied by the user.

Important Supabase Auth configuration:

- Email signups must be enabled.
- Email confirmation should be disabled for now, because the static invite flow needs `supabase.auth.signUp()` to immediately return a session so it can insert `profiles`, role-specific rows, and mark invite tokens used.
- The UI remains invite-only. There is no public registration page.

## Current Deliverables

### `outputs/rentradar_loop1_schema.sql`

Contains the complete Supabase SQL schema and RLS policies. It includes:

- `profiles`
- `landlord_subscriptions`
- `invite_tokens`
- `properties`
- `units`
- `staff_permissions`
- `tenants`
- `leases`
- `payment_submissions`
- `payments`
- `receipt_counters`
- `maintenance_requests`
- `notifications`
- `telegram_link_tokens`
- private Supabase Storage bucket `lease-documents`
- private Supabase Storage buckets `payment-proofs` and `maintenance-photos`
- RLS policies
- helper functions
- triggers
- `create_super_admin`
- `validate_invite_token`
- `check_lease_expiries`
- `accept_payment_submission`
- `link_current_tenant_account`
- `accept_tenant_invite`
- `attach_payment_record_proof`
- `delete_tenant_account`
- `delete_staff_account`

Important schema notes:

- Invalid `grant usage on all types in schema public` was replaced with explicit enum grants.
- `invite_tokens` is not publicly selectable for invite validation. Invite validation uses `validate_invite_token(token)`.
- `create_super_admin(email text, password text)` exists and is revoked from public/anon/authenticated execution after creation.
- Tenant invite metadata includes `tenant_id`, so invite acceptance links the exact tenant row.
- Tenant invite acceptance is handled by `accept_tenant_invite(invite_id)`, which links `tenants.profile_id`, sets `invite_accepted = true`, and marks the invite used atomically. Tenant page loading also calls `link_current_tenant_account()` to repair older tenant profiles that were created before the tenant row was linked.
- Payment receipt numbers are generated by DB trigger.
- Payment approvals should use `accept_payment_submission(p_submission_id uuid)`.
- Maintenance and payment notification triggers are present.
- Lease agreement PDFs are stored in the private `lease-documents` Supabase Storage bucket. Lease rows store the object path and metadata, and downloads should use short-lived signed URLs rather than public bucket URLs.
- Payment proof and maintenance photos are stored in private Supabase Storage buckets. Existing URL columns are kept for compatibility but now store private object paths, with metadata columns alongside them.
- Tenant portal property names and addresses rely on `tenant_can_access_property(property_id)` plus the `"properties tenant read own"` RLS policy. Keep the policy calling the helper; do not inline a `units` query inside the `properties` policy, because that causes infinite RLS recursion with the `units` policies.

### `outputs/index.html`

This is the full single-file app and contains all frontend work through the final integration loop plus follow-up bugfixes.

Lease page PDF uploads are implemented:

- landlords/staff with lease-management permission can upload a PDF when creating a lease
- landlords/staff can upload or replace the PDF from Lease Detail
- tenants can download their own active lease agreement
- Unit Detail and Lease Detail downloads use signed Supabase Storage URLs
- accepted file type is PDF only, max 20 MB
- bucket remains private; do not switch to public URLs

File uploads are implemented:

- tenant payment submissions use a Proof file picker instead of a URL
- landlord/staff manual payment logging uses a Proof file picker from both Payments > Log Payment Manually and the Unit Detail quick Log Payment form
- tenant maintenance requests use a Photo file picker instead of a URL
- landlord/staff maintenance logging uses a Photo file picker instead of a URL
- payment proof files use the private `payment-proofs` bucket
- manual payment proof metadata is stored on `payments.proof_file_*`; tenant-submitted proof metadata remains on `payment_submissions.proof_image_*`
- maintenance photos use the private `maintenance-photos` bucket
- payment proof accepted types are JPEG, PNG, WebP, and PDF, max 10 MB
- maintenance photo accepted types are JPEG, PNG, and WebP, max 10 MB
- proof/photo downloads/views use short-lived signed URLs
- proof/photo metadata is attached through RPCs `attach_payment_proof` and `attach_maintenance_photo`

Delete and vacancy controls are implemented:

- super admin can delete accepted or pending landlords from Landlord Management through `delete_landlord_account`
- landlords can delete properties and units, with confirmation because these cascade related records
- landlords can mark occupied units as vacant; this terminates the active lease when present
- landlords can delete tenants through `delete_tenant_account`, which removes the tenant row and linked Supabase Auth user so the deleted tenant cannot log in again
- landlords/staff with lease-management permission can delete leases
- landlords/staff with maintenance permission can delete maintenance requests
- accepted staff rows use `delete_staff_account`, which removes the staff permissions and linked Supabase Auth user; pending staff invites delete only the invite token
- lease delete now updates unit vacancy through a dedicated delete trigger

## Completed Loops And Features

### Loop 1 - Supabase SQL Schema: Complete

Built all schema tables, RLS policies, triggers, helper functions, invite validation RPC, lease expiry check, and payment approval RPC.

Super admin account creation remains a SQL Editor operation:

```sql
SELECT public.create_super_admin(
  'your@email.com',
  'YourStrongPasswordHere'
);
```

### Loop 2 - App Shell, Router, Auth, Login: Complete

Built:

- CDN imports
- Supabase client initialization
- Alpine app state
- session check
- sign-in-only login page
- no register link
- no forgot password link
- role routing
- landlord subscription/suspension check
- suspended screen
- base shells

### Loop 3 - Invite Flow: Complete

Built:

- detects `#invite=<token>`
- calls `validate_invite_token`
- invalid invite screen
- read-only full name/email fields
- password and confirm password fields
- `supabase.auth.signUp`
- inserts `profiles`
- landlord profile triggers subscription linking
- staff acceptance inserts `staff_permissions`
- tenant acceptance updates exact tenant row by metadata `tenant_id`
- marks invite token used
- redirects to login with success message

### Loop 4 - Super Admin Shell: Complete

Built:

- Super Admin shell/top nav
- `Mushavo Homes Admin` branding
- logout
- Landlord Management page
- stats: Total Landlords, Active, Trial, Suspended
- accepted/pending landlord table
- Add Landlord modal
- landlord invite generation
- linked landlord subscription trial row
- invite link copy
- edit accepted landlord profile
- edit pending landlord invite metadata
- manage subscription modal
- suspend quick action

Static-only caveat:

- Creating landlord invite and subscription is two client-side calls, not a transaction. Later this could become an RPC for atomicity.

### Loop 5 - Landlord/Staff Shell + Dashboard: Complete

Built:

- landlord/staff shell
- collapsible sidebar
- sidebar icons
- staff nav visibility by permissions
- top nav
- notification bell unread badge
- logout
- Dashboard stats
- Recent Payments
- Upcoming Lease Expirations

Extra changes preserved:

- Removed duplicate topbar Mushavo Homes branding.
- Sidebar/mobile nav keeps branding.
- Landlord profile/name chip on right opens landlord `My Account`.
- `My Account` is landlord-only.

### Loop 6 - Properties + Units: Complete

Built:

- Properties page
- Add Property form
- click property opens the Units panel inside Properties, filtered to that property
- Units is no longer a standalone sidebar page
- Add Unit form
- Assign Tenant for vacant units
- Unit Detail panel
- current tenant/lease details
- verified payment history
- maintenance history
- quick actions: Edit Unit, Log Payment, Change Tenant
- shared `createLease(payload)` function

### Loop 7 - Tenants + Leases: Complete

Built:

- Tenants page
- Add Tenant form
- creates `tenants` row
- creates tenant invite token
- invite metadata includes `tenant_id`
- generated tenant invite link
- tenant detail with lease/payment history
- Leases page
- Add Lease form
- filters units to vacant units
- shared `createLease()` reused
- lease detail/payment history

### Loop 8 - Payments + jsPDF Receipts: Complete

Built:

- Payments page with `Pending Submissions` and `Verified Payments` tabs
- pending submissions table
- approve via `accept_payment_submission`
- reject modal with reason
- verified payments table
- manual Log Payment modal
- jsPDF receipt generator
- receipt downloads from Payments and Unit Detail
- staff payment permissions enforced:
  - view with `can_view_payments` or `can_verify_payments`
  - approve/reject/log only with landlord or `can_verify_payments`

### Loop 9 - Maintenance + Staff: Complete

Built:

- Maintenance page
- filters by status/priority/property/assigned staff
- request list
- status update
- assign to staff
- resolution notes
- Log Request modal
- Staff page
- accepted/pending staff list
- permission badges
- staff invite form
- edit permissions modal
- copy invite
- remove staff/pending invite

### Loop 10 - Notifications: Complete

Built:

- Notifications feed
- unread styling
- mark all read
- click notification marks read
- click routes where possible:
  - payments
  - maintenance
  - leases
  - tenant pages
- live unread badge refresh by polling

### Loop 11 - Settings: Complete

Built:

- Settings page separate from landlord `My Account`
- edit profile full name/phone
- Telegram connection scaffold
- creates `telegram_link_tokens`
- Telegram link generation was removed from settings; do not re-add it unless the user explicitly asks.
- copy Telegram link
- connected status display
- change password with `supabase.auth.updateUser`
- code comment included:

```js
// Telegram bot webhook is a Supabase Edge Function - future step.
```

### Loop 12 - Tenant Shell: Complete

Built:

- tenant mobile-first top-nav shell
- Tenant Home:
  - unit details
  - lease details
  - current balance card
  - recent maintenance
  - quick actions
- Tenant Payments:
  - submit payment form
  - submissions history
  - verified payments
  - receipt downloads
- Tenant Maintenance:
  - own requests
  - new request form
- Tenant Notifications
- Tenant Settings

### Loop 13 - Final Review: Complete

Reviewed and fixed:

- all navigation anchors
- table references against schema
- no placeholder/stub/TODO markers
- shared `createLease()`
- receipt generation from Payments, Unit Detail, and Tenant Payments
- staff permission checks
- notification badge behavior
- UI labels
- no duplicate topbar branding regression
- landlord-only `My Account`

## Follow-Up Bugfixes After Loop 13

### Reload / Tab Switch / Permanent Loader Fix

User reported that switching browser tabs or returning to the site could reload the app and leave it stuck on:

```text
Loading Mushavo Homes...
```

Fixes applied:

- Added route persistence per user:
  - `routeStorageKey()`
  - `readStoredPage()`
  - `storeCurrentPage()`
  - `clearStoredPage()`
  - `isPageAllowed(page)`
  - `restorePage(defaultPage)`
- `navigate(page)` now:
  - validates page access for the current shell/role
  - stores the current page
  - loads only the data for that page
- Auth restoration now:
    - restores the last valid page for the user
    - does not always force landlord/staff back to Dashboard
- If Supabase Auth succeeds but the matching `profiles` row is missing, the login page shows a customer-facing removed-account message rather than exposing internal profile repair wording.
  - does not always force tenants back to Home
- Supabase Auth focus/session-refresh events are ignored when the same user is already loaded, so switching tabs/apps should not flash the boot screen, rerun page loaders, or route the user back to Dashboard/Home.
- `loadAuthenticatedUser()` uses `resolveActivePage(defaultPage, previousShell, previousPage)` so an already-open valid page is preserved when a full auth reload is genuinely needed.
- Added `refreshCurrentPage()` and wired app/tenant page Refresh buttons to it.
- Explicit logout clears the remembered route.
- Added `withTimeout(promise, milliseconds, message)` for session/profile/role startup calls.
- `init()` now catches startup errors and exits the boot loader.
- `loadAuthenticatedUser()` now sets `booting = false` before running page refresh/data loading. This prevents data refresh stalls from leaving the UI permanently on the loading card.

Important implementation detail:

- The browser can still physically reload a static `file://` page when a tab is restored. The app cannot fully prevent the browser from reloading the document, but it should now restore the last valid page and should not remain stuck on the boot loader.

Known verification note:

- The Codex in-app browser automation refused direct `file://` verification because of browser URL policy. Do not bypass this. Use local static checks and user-visible manual testing.

## Current Navigation State

Landlord/staff sidebar includes:

- Dashboard
- Properties, including property-filtered unit management
- Tenants
- Leases
- Payments
- Maintenance
- Staff, landlord only
- Notifications
- My Account, landlord only
- Settings

Tenant top navigation includes:

- Home
- Payments
- Maintenance
- Settings

Tenant notifications are accessed through the notification bell.

Staff cannot see:

- Staff page
- My Account page
- pages hidden by permission checks

## Important Product Changes To Preserve

1. **Landlord My Account page**
   - landlord-only
   - subscription/account details
   - separate from Settings

2. **Topbar branding**
   - do not re-add duplicate topbar Mushavo Homes branding in landlord/staff shell
   - sidebar/mobile nav keeps branding

3. **Visible labels**
   - all forms must keep visible labels
   - no placeholder-only inputs

4. **Tenant invite metadata**
   - must include `tenant_id`

5. **Invite token validation**
   - remains RPC-based through `validate_invite_token`
   - do not add public table select on `invite_tokens`

6. **Reload behavior**
   - returning to the app must not leave permanent `Loading Mushavo Homes...`
   - restored users should return to their last valid page
   - Refresh buttons must reload current page data, not route back to Dashboard/Home

## Design Constraints To Preserve

- App background: `#f8fafc`
- Sidebar/nav: white
- Cards: white, subtle shadow
- Primary accent: `#10b981`
- Primary hover: `#059669`
- Text primary: `#0f172a`
- Text secondary: `#64748b`
- Borders: `#e2e8f0`
- Inputs: `#f1f5f9`
- Focus ring: emerald
- Tables: white, alternating subtle row tint
- No dark gradients
- No glassmorphism
- No marketing landing page
- Operational pages should be dense and clear
- Cards are practical, not decorative

## Verification Commands


Expected result:

- no stale direct page refresh handlers should be returned for app/tenant Refresh buttons
- the normal page navigation and form submit handlers may still call loader methods internally

## What The Next Chat Should Do

This is no longer a loop-build task; all planned loops are complete.

The next chat should:

1. Start by reading:
   - `outputs/index.html`
   - `outputs/rentradar_loop1_schema.sql`
   - this prompt
2. Focus on bugfixes, QA, and polish only.
3. If the reload issue persists, inspect startup around:
   - `init()`
   - `withTimeout()`
   - `loadAuthenticatedUser()`
   - `restorePage()`
   - `refreshCurrentPage()`
4. Pay special attention to any promise awaited before `booting = false`.
5. Do not reintroduce forced default routing to Dashboard/Home after auth restoration.
6. Keep Refresh buttons using `refreshCurrentPage()`.
7. Preserve all completed features.

## Latest Feature Patch

Admin can now see archived users and act on them:

- landlord, staff, tenant, and management lists have archive/unarchive/permanent delete actions where relevant
- archive keeps operational history
- permanent delete removes the auth/profile record and cascades linked operational records according to the SQL foreign keys
- platform finance rows using `on delete set null` may remain as unassigned history after permanent delete
- management leaders can open `My Account` and see management subscription status, expiry, landlord/property/staff limits, and notes
- management leaders permanently delete their internal management staff through `permanently_delete_management_staff_account(uuid)`
- admin finance payments now support `payer_type = 'management'` with `platform_payments.management_company_id`
- landlord edit country fallback resolves from profile country, subscription country, or displayed country name

New SQL RPCs added:

- `unarchive_landlord_account(uuid)`
- `unarchive_staff_account(uuid)`
- `unarchive_management_company(uuid)`
- `permanently_delete_landlord_account(uuid, uuid)`
- `permanently_delete_tenant_account(uuid)`
- `permanently_delete_staff_account(uuid)`
- `permanently_delete_management_company(uuid, uuid)`
- `permanently_delete_management_staff_account(uuid)`

## Latest Management Patch

Management-company landlord access is now permission-first:

- landlord-side pending management requests open a permission checklist instead of approving with default all-property access
- the landlord accepts through `approve_management_landlord_request_with_permissions(uuid, jsonb)`
- approved management companies now have Edit and Unassign actions on the landlord Staff page
- Unassign uses `unassign_management_landlord_permission(uuid)` and suspends access without deleting history
- management leaders have a separate `management-landlords` page for connected/pending landlords
- the Connected Landlords Open button switches the active landlord and navigates to Dashboard
- management leaders can invite internal management staff before any landlord is connected
- management-staff invites can be tied to a management company without a landlord, creating a no-property-access placeholder until later assignment
- SQL RLS/constraints were updated for `invite_tokens` so management leaders can manage their own management-staff invite tokens
- management staff created by a management leader can log in immediately after setting their password, even if no landlord is assigned yet
- the visible login-page staff-access/signup link has been removed
- management staff login now tolerates an unreadable embedded management company as long as the approved management staff permission row exists
- SQL RLS now lets management staff read their own management company and lets management leaders read their own management staff profiles
- the management staff table now de-duplicates stale unused invite rows against accepted staff rows and falls back to invite metadata if the profile join is blank
- fixed an RLS infinite-recursion bug: `management_staff_permissions` policies no longer query `management_companies` directly while `management_companies` policies query `management_staff_permissions`; both now use security-definer helpers `is_management_leader_for_company(uuid)` and `is_management_staff_for_company(uuid)`

## Latest UI Responsiveness Patch

The interface has been refreshed with a cleaner Apple-style glass UI:

- added a shared glassmorphism style layer with soft gradients, translucent cards, backdrop blur, subtle borders, and softer shadows
- made the body and main shells overflow-safe with `overflow-x-hidden` while keeping wide tables scrollable only inside their own `overflow-x-auto` wrappers
- made the super admin header wrap on mobile instead of forcing a single wide desktop nav row
- made the landlord/staff/management shell use `min-w-0`, `overflow-x-hidden`, wrapped header actions, and a viewport-safe mobile drawer width
- made the tenant shell header wrap and constrained tenant page content with responsive max width
- preserved alert/status colors after the glass overrides
- verified JS parsing and RPC references after the styling changes

## Latest User-Reported Issue Before This Prompt Was Updated

The app could still show the permanent boot screen after returning to the website:

```text
Loading Mushavo Homes...
```

The current file has been patched to avoid this by timing out startup calls and rendering the restored shell before page data refreshes. The next chat should verify manually with the user if possible and continue debugging only if the issue remains.

## Latest Terminology, Subscription, and PMC Admin Patch

The visible product terminology has moved to:

- Freelancer manager / freelancer staff in user-facing copy = **Individual Portfolio Manager (IPM)**
- Company management / management company in user-facing copy = **Property Management Company (PMC)**
- Internal database role names such as `freelancer`, `management_leader`, `management_staff`, and `management_companies` are intentionally unchanged.

Latest implementation notes:

- The expired subscription lockout screen now says: “Your Mushavo Homes subscription has expired, and your account access is currently paused. Your data is still safely stored. Please contact support to renew your subscription and restore access.”
- Expired/suspended subscription access now routes to the paused-access shell for landlords, IPMs, PMCs, landlord staff, and PMC staff instead of showing misleading missing-profile or waiting-approval errors.
- Admin PMC list now has Edit and Suspend actions. Edit reuses the PMC modal and can update company name, leader name, leader email, phone, country, limits, status, and expiry.
- PMC account Tenants page no longer shows the tenant ID column.
- PMC Landlords page View button now opens the Properties page and expands the first property/unit panel for that landlord.
- JS parsing and frontend RPC reference checks passed after this patch.

## Latest Admin IPM and PMC Header Patch

- Admin top navigation and page title now use **IPM** / **IPM Management** instead of Staff for admin-level freelancer manager accounts.
- Admin IPM rows now have Edit, Subscription, Suspend, Archive, Delete, and Copy Link actions where applicable.
- Admin IPM Edit can update full name, email, phone, country, landlord limit, subscription status, and expiry for accepted IPMs or pending IPM invites.
- Admin PMC Add no longer requires choosing a country card first; the Add PMC modal opens from any admin context and requires the country inside the form.
- PMC leaders and PMC staff now show the PMC company name in the top app header beside the page title via `pmcCompanyName()`. The sidebar label remains the account type (`PMC` / `PMC Staff`) via `accountRoleLabel()`.

## Latest Admin Staff Patch

The platform admin now has a separate **Staff** page for Mushavo Homes' own internal admin staff. This is distinct from:

- **IPM** accounts (`role = 'staff'`, `staff_type = 'freelancer'`)
- landlord staff
- PMC staff

Implementation notes:

- Added a new database role: `admin_staff`.
- Super admin can open Admin > Staff, create invite links, edit pending/accepted staff, assign one country, archive/unarchive accepted admin staff, and delete pending invites.
- Admin staff log into the same admin shell, but their country is forced from `profiles.country_id`.
- Admin staff cannot see the Admin Staff page and cannot add countries.
- Admin staff country cards hide “All countries” and only show the assigned country.
- SQL constraints, invite-token checks, profile insertion, and RLS helpers/policies were updated so `admin_staff` can read/manage admin data scoped to their assigned country.
- Admin Staff rows now support Suspend and Reactivate; suspended admin staff are blocked from logging in until reactivated.
- Admin Finance payment type badges now show IPM for `payer_type = 'staff'` instead of the generic Staff label.
- JavaScript parsing passed after the patch.

## Latest Public Website Split

The Mushavo Homes public website has now been split away from the logged-in client app.


- `index.html` - new public home page for Mushavo Homes
- `about.html` - public About page with vision, mission, goals, and values
- `pricing.html` - public Pricing page with country-based pricing for Zimbabwe and Malaysia
- `contact.html` - public Contact page with support/sales sections and a visual enquiry form placeholder
- `client.html` - preserved copy of the original full Mushavo Homes login/dashboard app
- `mushavo-logo.png` - shared public/app logo asset

Important behavior:

- The old all-in-one app was copied from `index.html` to `client.html`.
- The new `index.html` is now only the public home page.
- Public navigation links point to `about.html`, `pricing.html`, `contact.html`, and `client.html`.
- GitHub Pages should upload these files to the repository root:
  - `index.html`
  - `about.html`
  - `pricing.html`
  - `contact.html`
  - `client.html`
  - `mushavo-logo.png`
- The SQL and prompt files are reference/setup files and are not required for the public website to display on GitHub Pages.

Pricing page details:

- The pricing page has a manual country selector for Zimbabwe and Malaysia.
- It also attempts lightweight country pre-selection using browser timezone first, then IP lookup fallback.
- Zimbabwe pricing is shown in USD; Malaysia pricing is shown in MYR.
- The plan categories are Landlords, IPM, and PMC.
- Billing can switch between monthly and yearly.

Contact page details:

- The contact page does not currently submit data anywhere.
- The enquiry form is intentionally a placeholder until the official Mushavo Homes email address or backend email service is confirmed.
- Do not wire the form to a personal email address unless the user explicitly approves that destination.

Implementation caution for future chats:

- Do not overwrite `client.html` when changing the public home page.
- Do not rename `client.html` back to `index.html` unless the user explicitly wants the login page to become the root page again.
- If updating the logged-in app, edit `client.html` or intentionally sync changes back from the latest app file.
- If updating the public marketing site, edit the standalone public files and keep them lightweight/static for GitHub Pages.

## Latest Landlord Staff Invite/Login Fix

User reported that after a landlord invited a staff member:

- the staff member could register from the invite link
- logging in showed the account as suspended
- the landlord Staff page showed duplicate rows for the same staff member: one Approved row and one Invited row

Fixes applied:

- `client.html` landlord Staff page now de-duplicates pending invite-token rows against accepted staff permission rows by email/profile id.
- This hides stale unused invite rows once the staff member has an approved `staff_permissions` row.
- `rentradar_loop1_schema.sql` now has a missing RLS select policy on `landlord_subscriptions`:
  - policy name: `landlord subscriptions approved staff read assigned landlord`
  - approved landlord staff can read the subscription row for their assigned landlord through `staff_permissions`.
- This prevents landlord staff login from falsely treating the landlord subscription check as paused/suspended just because RLS blocked the subscription read.
- JavaScript parsing passed after the patch.

Deployment reminder:

- Upload the updated `client.html`.
- Also run the updated SQL in Supabase, otherwise existing deployed code may still fail the staff login subscription check because the RLS policy is missing in the database.

## Latest Landlord Personal Staff Permanent Delete Fix

User clarified that when a landlord deletes their own personal staff member, that staff account must be entirely deleted from Supabase so the same email can be invited and registered again.

Important distinction:

- Landlord-created personal staff (`role = 'staff'`, `staff_type = 'landlord'`) should be permanently deleted by the landlord.
- IPM/freelancer staff (`role = 'staff'`, `staff_type = 'freelancer'`) should only be unassigned from that landlord and remain available for other landlords.

Fixes applied:

- Updated SQL function `public.delete_staff_account(uuid)`:
  - verifies the staff member belongs to the logged-in landlord through `staff_permissions`
  - deletes the staff permission row
  - cancels pending staff landlord requests for that landlord/staff pair
  - deletes matching landlord staff invite tokens for that staff email
  - if `staff_type <> 'freelancer'`, deletes the Supabase Auth user from `auth.users`, which cascades the profile
  - if `staff_type = 'freelancer'`, only clears `profiles.landlord_id` when no approved staff permissions remain
- Updated landlord Staff delete confirmation text in `client.html`:
  - personal landlord staff now says the staff login will be removed from Supabase and the email can be invited again
  - IPM/freelancer staff still says their IPM login remains available for other landlords
- JavaScript parsing passed after the patch.

Deployment reminder:

- Upload the updated `client.html`.
- Run the updated SQL in Supabase so `delete_staff_account(uuid)` actually deletes landlord personal staff Auth users.

## Latest Properties/Units Permission Fix

User reported these landlord account issues:

- Properties page needed an Edit button for property details.
- Staff with Add Property permission could see Archive buttons even though Archive permission was not granted.
- Several property/unit actions were mixed together under broad permission checks.

Fixes applied in `client.html`:

- Added property editing on the Properties page:
  - Edit button on each property card
  - Inline edit form for property name, address, and city
  - `startEditProperty(property)`, `cancelPropertyEdit()`, and `savePropertyEdit()`
- Added exact frontend permission helpers:
  - `canEditProperties()`
  - `canArchiveProperties()`
  - `canAddUnits()`
  - `canEditUnits()`
  - `canMarkUnitsVacant()`
- Replaced broad `canManageProperties()` usage on property/unit buttons:
  - Add Property uses `canAddProperties()`
  - Edit Property uses `canEditProperties()`
  - Archive Property uses `canArchiveProperties()`
  - Add Unit uses `canAddUnits()`
  - Edit Unit uses `canEditUnits()`
  - Mark Vacant uses `canMarkUnitsVacant()`
  - Archive Unit uses `canArchiveUnits()`
- Added function-level permission guards so actions refuse even if called directly from the UI.

Fixes applied in `rentradar_loop1_schema.sql`:

- Added RLS policies for staff and PMC/management property insert/update/archive actions.
- Added RLS policies for staff and PMC/management unit insert/edit/mark-vacant/archive actions.
- Added lease update policies that allow Mark Unit Vacant permission to terminate the active lease as part of the vacancy flow.
- Added update enforcement triggers:
  - `enforce_property_update_permissions()`
  - `enforce_unit_update_permissions()`
  - `enforce_lease_update_permissions()`
  - `enforce_tenant_update_permissions()`
  - These compare OLD vs NEW values and require the exact permission for edit, archive, and mark-vacant changes.
  - This helps prevent a broad update policy from being used to change a column that belongs to a different permission.

Important design note:

- `can_archive_units` now exists separately from `can_archive_properties`.
- Archive Unit must stay tied to `canArchiveUnits()` / `can_archive_units`, not property archive permission.
- For the most reliable permission audit, test every permission with two layers:
  1. UI visibility: the button/form should be hidden when permission is off.
  2. Supabase enforcement: the same insert/update/delete should fail under RLS when permission is off.

Deployment reminder:

- Upload the updated `client.html`.
- Run the updated SQL in Supabase or the frontend buttons may look correct while the database still blocks/permits the wrong actions.

## Tenant Global Account Reuse Flow

Tenant logins must be global Mushavo Homes identities, not permanently owned by one landlord.

Rules implemented:

- `profiles.email` stays globally unique, so one tenant email has one Mushavo Homes login.
- `tenants` rows are landlord-specific relationship records.
- The same tenant can be invited by another landlord later, using the same email/login.
- When a landlord archives/deletes a tenant relationship:
  - active leases are terminated
  - the unit is marked vacant
  - the tenant relationship row is archived
  - the tenant profile/auth login is not archived or deleted
- When a tenant invite is accepted:
  - existing tenant accounts sign in with their existing password and accept the new invite
  - new tenant accounts are created through the invite link
  - `accept_tenant_invite(uuid)` links the tenant relationship to the tenant profile
- Tenants can only read active, accepted, non-archived tenant rows tied to their own profile.
- A database trigger prevents creating two active tenant relationship records for the same landlord and tenant email.

New SQL added:

- `public.create_tenant_invite(uuid, text, text, text, text)`
- `public.enforce_active_tenant_relationship_unique()`
- trigger `tenants_enforce_active_relationship_unique`

Frontend change:

- `addTenantInvite()` now calls `create_tenant_invite(...)` instead of directly inserting into `tenants` and `invite_tokens`.

Deployment reminder:

- Upload the updated `client.html`.
- Run the updated SQL in Supabase so tenant account reuse and duplicate prevention work from the database layer.

## Latest Free Landlord Plan and IPM/PMC Onboarding Flow

Rules implemented:

- Landlords can now create a free landlord account directly from the login page.
- The free landlord plan is intentionally limited:
  - 1 property
  - 1 unit
  - Finance page access
  - 0 personal landlord staff
  - 1 external partner connection, either IPM or PMC
- IPM and PMC accounts do not have a free signup path. They remain invite/admin-created accounts.
- IPMs and PMCs now have a Landlords page by default.
- IPM/PMC landlord discovery uses landlord email only:
  - If the landlord email exists, show that the landlord is on Mushavo Homes and allow an access request.
  - If the landlord email does not exist, create an invite link for that landlord to join on the free landlord plan.
- When a landlord accepts an IPM/PMC-generated invite, the landlord account is created on the free plan and a pending access request is created for the IPM or PMC. The landlord still approves permissions before access is granted.
- Pricing page now shows:
  - Landlord Free plan with "Sign up for free"
  - Paid landlord plans above free limits
  - IPM paid plans only
  - PMC paid plans only

Frontend changes:

- `client.html` login now has landlord-only free signup mode via `authMode === 'landlord-signup'`.
- `client.html?signup=landlord` opens the landlord signup form directly.
- Added IPM/PMC landlord email search and invite/request actions on the `management-landlords` page.
- Landlord subscription display now includes plan, unit limit, personal staff limit, and IPM/PMC connection limit.
- Admin landlord subscription modal can update `subscription_plan`, `property_limit`, `unit_limit`, `personal_staff_limit`, and `partner_connection_limit`.
- `pricing.html` now links the landlord free plan CTA to `client.html?signup=landlord`.

SQL changes:

- Added `landlord_subscriptions` columns:
  - `subscription_plan`
  - `unit_limit`
  - `personal_staff_limit`
  - `partner_connection_limit`
- Added/updated enforcement helpers:
  - `landlord_can_add_property(uuid)`
  - `landlord_can_add_unit(uuid)`
  - `landlord_can_invite_personal_staff(uuid)`
  - `landlord_can_accept_partner_connection(uuid)`
- Unit limit is enforced with `units_enforce_subscription_limit`.
- Property limit is enforced through property insert RLS using `landlord_can_add_property(...)`.
- Personal staff invite limit is enforced through invite token RLS.
- Frontend must pre-check subscription limits before attempting Supabase writes. This is especially important for the free landlord plan where `personal_staff_limit = 0`; do not use `||` fallbacks that turn zero into a paid-plan default.
- Never show raw Supabase/RLS/constraint messages to end users for plan-limit failures. Convert them to clean Mushavo Homes messages such as "Your current plan does not include personal staff members..." or "Personal staff limit reached...".
- IPM/PMC partner approval is enforced inside approval RPCs.
- Added RPCs:
  - `register_free_landlord(text, text)`
  - `search_landlord_by_email(text)`
  - `request_staff_landlord_access_by_email(text)`
  - `invite_landlord_from_ipm(text)`
  - `request_management_landlord_access_by_email(text)`
  - `invite_landlord_from_management(text)`
- `handle_landlord_subscription_link()` now links landlord invites to free subscriptions and creates pending IPM/PMC access requests from invite metadata.

Deployment reminder:

- Upload the updated `client.html` and `pricing.html`.
- Run the updated SQL in Supabase before testing free signup, partner invites, or subscription limits.

## Latest Invite Token SQL Compatibility Fix

Problem fixed:

- IPM/PMC landlord invites failed in Supabase with:
  - `function gen_random_bytes(integer) does not exist`
- The same missing function could also affect tenant invite token creation and old token defaults.

SQL fix:

- Added `public.generate_invite_token(p_bytes integer default 32)`.
- Replaced all SQL usage of `encode(gen_random_bytes(...), 'hex')` with `public.generate_invite_token(...)`.
- Updated existing table defaults:
  - `invite_tokens.token`
  - `telegram_link_tokens.token`
- Updated RPC token generation in:
  - `invite_landlord_from_ipm(text)`
  - `invite_landlord_from_management(text)`
  - `create_tenant_invite(uuid, text, text, text, text)`

Deployment reminder:

- Run the updated SQL before testing IPM/PMC landlord invites again.

## Latest Public Site, Contact Enquiries, And Translation Update - July 13, 2026



Current important files:

- `index.html` - public home page
- `about.html` - public about page
- `pricing.html` - public pricing page
- `contact.html` - public contact/enquiry page
- `client.html` - logged-in Mushavo Homes client area
- `i18n.js` - shared language/translation script loaded by all public pages and `client.html`
- `rentradar_loop1_schema.sql` - Supabase schema/RLS/RPC setup
- `mushavo-logo.png` - shared logo
- `mushavo_customer_pitch_guide.pdf` - generated customer pitch/guide PDF

Important current file relationship:

- Do not put the logged-in client app back into `index.html` unless the user explicitly asks.
- Public website edits should go into `index.html`, `about.html`, `pricing.html`, and `contact.html`.
- Logged-in app edits should go into `client.html`.
- Shared translations should go into `i18n.js`.


### Translation / Language System

Mushavo Homes now has a shared translation layer for:

- English
- Bahasa Melayu
- Chinese

The translation system is in `i18n.js`.

Key behavior:

- Language is saved in `localStorage` under `mushavo_language`.
- The script injects a language selector into supported pages.
- It translates visible text nodes and common attributes such as placeholders/titles/aria labels.
- It uses a `MutationObserver` so Alpine-rendered dynamic content can be translated after page updates.
- It intentionally does not translate user data such as names, emails, typed notes, property names, or uploaded filenames.
- It contains special handling for mixed dynamic labels like:
  - `Unit 24`
  - values ending with ` - Paid` / ` - Unpaid`

Recent translation audit:

- A scan across the public pages and `client.html` found 690 candidate visible text strings.
- Missing dictionary keys were reduced from 458 to 29.
- The remaining scanner hits were mostly code fragments, icon names, function names, email placeholders, or template expressions rather than real UI labels.
- A large supplemental dictionary was added inside `i18n.js` for high-confidence missing labels, buttons, empty states, and page descriptions.
- Both source and output copies of `i18n.js` passed JavaScript syntax checks.

Future translation guidance:

- If the user shows a screenshot with untranslated text, add the exact English source text to `i18n.js` for both `ms` and `zh`.
- Prefer adding exact keys rather than changing app logic.
- Do not translate brand names like Mushavo Homes.
- Do not translate dynamic/user-created content unless the user specifically requests machine translation.

### Public Contact Page And Enquiries

The public `contact.html` no longer uses only a `mailto:` flow.

Current behavior:

- The enquiry form submits to Supabase table `enquiries`.
- Country selection exists so Mushavo Homes can see which country the enquiry came from, including countries where Mushavo Homes does not yet operate.
- `client.html` includes an Admin `Enquiries` page.
- Super admin can review all enquiries.
- Admin staff should only see enquiries scoped to their assigned country.
- The SQL must include the `enquiries` table, RLS policies, and any needed admin/admin_staff access policies.

If the enquiry form fails:

- Check browser console for Supabase/RLS errors.
- Confirm `enquiries` table exists in Supabase.
- Confirm anon insert policy allows public enquiry submission while only exposing reads to super admin/admin staff.
- Confirm `countries` rows exist when mapping a selected country to `country_id`.

### Current Subscription Lockout Message

For all paid-account types, expired subscriptions should show a clear paused-access message:

```text
Your Mushavo Homes subscription has expired, and your account access is currently paused. Your data is still safely stored.

Please contact support to renew your subscription and restore access.
```

This applies to:

- landlords
- Individual Portfolio Managers (IPM)
- Property Management Companies (PMC)
- landlord staff when their landlord subscription blocks access
- PMC staff when their PMC subscription blocks access

### Current Terminology

Use these user-facing terms:

- **IPM** = Individual Portfolio Manager
- **PMC** = Property Management Company
- **Landlord staff** = staff created by one landlord and only serving that landlord
- **PMC staff** = staff created by a PMC and only serving that PMC
- **Admin staff** = Mushavo Homes internal staff assigned by super admin to a country

Do not use "freelancer" or "management company" in user-facing UI unless the user explicitly asks. The database may still contain legacy/internal terms.

### Recent Payment Logic Notes

Payment forms now support `Payment is for` with rent periods, advance rent where allowed, unpaid refundable `Deposit`, and `Other`.

Rules to preserve:

- If payment is for rent, labels can say `Rent amount`.
- If payment is for `Deposit` or `Other`, the label must say `Amount`, not `Rent amount`.
- The `Deposit` option should only show when the active lease has a positive deposit amount and the lease deposit is not already paid or fully covered by a pending/verified deposit payment.
- Deposit payments must be stored with `payment_purpose = 'deposit'`, may mark the lease deposit as paid, and must not count as landlord rental revenue.
- If `Other` is selected, a description box appears and is required.
- Non-rent payments must not reduce the tenant's current rent balance.
- Tenant current balance should be based only on rent due minus verified rent payments.
- Copy now says: `Based on this month's rent and verified rent payments only.`

This logic must apply to:

- tenant payment submission
- landlord/staff manual payment logging
- unit detail quick payment logging

### Tenant Account Reuse And Search Flow

Tenant accounts are global Mushavo Homes identities. Landlords/IPMs/PMCs should not create duplicate Auth users for the same tenant email.

Desired UI flow:

- On tenant pages, first search tenant by email.
- If the tenant exists, show a request/link flow.
- If the tenant is not found, only then show the Add Tenant fields so a new tenant relationship/account can be created.
- The Add Tenant form should not be visible by default before a search result says the tenant was not found.
- The tenant invite/search panel itself should stay collapsed behind an `Add Tenant` button until the user chooses to add or invite a tenant.

Database rule to preserve:

- `profiles.email` remains globally unique.
- Tenant rows are landlord-specific relationship records.
- Archiving a tenant relationship should not delete the global tenant profile/Auth user.

### Properties And Units UX

Open Units behavior should be local to the property card:

- When a user clicks `Open Units` for a property, the units panel should open directly under that property card.
- It should not open at the bottom of the entire properties page.
- This matters when there are many properties.

Property edit behavior:

- Avoid cramped inline edit forms inside small property cards.
- Preferred UX: click `Edit`, populate the top Add Property form with the selected property's details, change the submit button to `Edit Property`, and save updates from that top form.

Collapsed add-form behavior:

- Properties page: do not show the property creation fields by default. Show an `Add Property` button; clicking it opens the property fields. Editing a property should also open the same top form with the existing details filled in.
- Tenants page: do not show tenant creation fields by default. Show `Add Tenant`; inside that flow search by email first, and only reveal the new tenant fields after the search says no tenant was found.
- Leases page: do not show lease creation fields by default. Show an `Add Lease` button that opens the lease form.
- Maintenance page: keep creation behind an action button/modal. Use `Add Maintenance` or equivalent wording, not a permanently visible maintenance form.
- Apply this consistently for landlord, landlord staff, IPM, PMC, and PMC staff where these pages are shared.
- Every opened add/create panel needs a Cancel action and should close/reset after successful save.

### Maintenance Permissions And Assignment

Maintenance permissions need careful handling. Avoid broad or confusing permission names.

Recommended interpretation:

- `View maintenance`: can see maintenance requests.
- `Create maintenance`: can log/create maintenance requests.
- `Assign maintenance`: can assign a request to a staff member.
- `Update maintenance`: can change status/priority/details where allowed.
- `Add resolution notes`: can add work done/resolution notes.
- `Delete maintenance`: landlord-only unless explicitly expanded later.

Rules:

- If `Create maintenance` is not granted, hide the Log Maintenance button.
- If `Assign maintenance` is not granted, hide the assigned-staff dropdown.
- Staff assignment dropdowns must only list staff/users that are actually under the current landlord/PMC scope and allowed for that property/unit.
- Users must not be able to assign maintenance to random staff outside their team or outside the active landlord/company relationship.
- The database has maintenance RLS and a maintenance assignment scope trigger; keep those aligned with the UI.

Current app note:

- `client.html` includes `deleteMaintenanceRequest(request)`.
- Maintenance delete button is shown only through `canDeleteMaintenance()`.
- Current delete copy indicates only the landlord can delete maintenance requests.

### Assigned Staff Visibility

When viewing units under a property, show assigned staff/operator information for landlord and PMC contexts:

- landlord staff assigned to that unit/property
- IPM assigned to that unit/property
- PMC assigned to that unit/property
- PMC staff assigned to that unit/property where applicable

Tenant Unit Details should also show assigned contact information when the property/unit has an assigned landlord staff, IPM, PMC, or PMC staff contact.

### Public Website Content Direction

The public home page should explain Mushavo Homes more transparently than a simple hero section.

Keep the public pages clear about:

- what Mushavo Homes is
- who benefits
- landlords
- tenants
- IPMs
- PMCs
- rent/payment tracking
- lease records and PDFs
- maintenance tracking
- private file uploads via Supabase Storage
- subscription model
- country-based pricing
- client area/login

The public site should remain static-hosting friendly.

### Deployment / Hosting Notes

Current hosting can remain static:

- GitHub Pages
- Hostinger static hosting
- Cloudflare Pages
- Netlify
- Vercel

Important security note:

- The Supabase anon key and Supabase URL are visible in browser code by design.
- They are not secret credentials.
- RLS policies, private buckets, signed URLs, and RPC permission checks are the real security boundary.
- Never put a Supabase service role key in `client.html`, public pages, GitHub Pages, or any frontend JavaScript.

### Subscription Access Rules

Do not treat `trial` as `suspended`.

### Subscription Plan / Status Save Rules

The admin/admin-staff Manage Subscription dialog must preserve the selected combined Plan / Status value.

Important failure that already happened:

- The admin selected `Growth - Active`.
- The limit fields changed to Growth values.
- Reopening Manage Subscription still showed `Free - Active`.

Do not repeat this. The code must:

- Save `subscription_plan` directly from the selected dropdown value.
- Save `status` directly from the selected dropdown value.
- Reopen the modal using the saved selected plan/status.
- If old Supabase data has stale `subscription_plan = 'free'` but the stored limits clearly match Starter, Growth, or Portfolio, infer and display the matching plan instead of blindly showing `Free - Active`.
- If duplicate `landlord_subscriptions` rows exist for one landlord, prefer the newest row and repair/remove old duplicates in SQL before enforcing uniqueness.
- When testing this, do not stop after the first save. Save a non-free option, close the modal, reopen it, and confirm the same option is selected.

Landlord access logic:

- `status = 'suspended'` means access is paused by admin.
- `status = 'trial'` is allowed while the trial expiry date is still valid.
- expired trial accounts should show a clear `Trial Expired` paused-access message, not a suspended-account message.
- `subscription_plan = 'free'` should stay accessible unless the status is explicitly `suspended`; old/free rows may still have `status = 'trial'`, and that must not lock the landlord out.
- missing or malformed expiry dates should not automatically suspend a trial account.
- New landlord accounts created from direct signup, admin invite, IPM invite, or PMC invite should default to the free landlord plan with `subscription_plan = 'free'`, `status = 'active'`, no practical expiry, 1 property, 1 unit, 0 personal staff, and 1 IPM/PMC connection.
- Subscription badges and admin list labels should show combined plan/status, not status alone:
  - free landlord: `Active - Free`
  - paid landlord examples: `Starter - Trial`, `Starter - Active`, `Growth - Trial`, `Growth - Active`, `Portfolio - Trial`, `Portfolio - Active`, `Custom - Trial`, `Custom - Active`
  - IPM/PMC accounts should use the same combined plan/status concept according to the plan/status fields available for those account types.

Paused-access wording should be specific:

- suspended by admin: account paused by administrator
- trial expired: trial expired
- paid subscription expired: subscription expired

This same distinction should be preserved anywhere landlord staff access depends on the landlord subscription check.

### Validation Checklist For Future Edits

After editing `client.html` or `i18n.js`, run:

```powershell
node --check client.html
node --check i18n.js
```

If `node --check client.html` is not directly useful because it is HTML, extract/check inline scripts or at least use a targeted script parse check.



### Dropdown / Dialog State Rule

A recurring bug happened where dropdown values saved correctly in Supabase but reopened dialogs showed the first option, such as `Unassigned` or `Free - Active`. Do not repeat this.

For every Alpine `<select>` using `x-model`, especially modals, edit dialogs, filters, subscription dialogs, and dynamic `x-for` option lists:

- Add an after-render value sync: `x-effect='$nextTick(() => { $el.value = form.field ?? "" })'`.
- Store stable IDs/enums, not display labels, for country, landlord, tenant, unit, staff, property, payer, and plan/status fields.
- When opening edit dialogs, resolve saved names/codes/legacy values back to the current option ID before setting form state.
- After saving, refresh or update the local row so reopening shows the saved value.
- Test by selecting a non-first option, saving, closing, reopening, and confirming the same option is selected.
- Dialogs must remain scrollable on small screens with visible close/cancel/save actions.

### Table Sorting Rule

If a table heading shows a sort arrow, clicking that heading must actually sort the visible rows. Do not leave decorative arrows that only change direction without changing row order.

For Alpine-rendered tables, either sort the underlying filtered data or store the clicked table column/direction and reapply the DOM row sort after Alpine finishes rendering.

Sorting requirements:

- Text columns sort alphabetically with case-insensitive natural sorting.
- Number and currency columns sort numerically.
- Date columns sort by date.
- Sorting must keep working after filters, refreshes, page changes, and Alpine re-renders.
- Empty-state rows with `colspan` are not sortable data rows.
- Actions columns are not meaningful business sorting unless specifically requested.

Before handoff, test at least one non-default column such as Account, Country, Name, Property, Amount, Expiry, or Status and confirm the row order changes correctly.

### Admin Dashboard And Notes Rule

Admin and admin staff must both land on an `admin-dashboard` page after login. This dashboard summarizes landlords, finance, enquiries, IPM, PMC, and notes, while keeping the existing detail pages available.

Admin notes are stored in Supabase in `admin_notes`. They are not browser-only state.

Notes behavior:

- personal notes are visible to the creator and super admin
- assigned notes are visible to the assigned admin staff member, creator, and super admin
- notes can be edited
- notes can be ticked as done
- super admin or the creator can delete a note

Any future notes changes must update both frontend behavior and RLS policies.

### Historical Payment Records Rule

Landlords, IPMs, and PMCs must be able to log historical/backdated rent payments for onboarding old tenant/property records. This belongs only in manager-side payment logging, not tenant proof submission.

Historical rent records must be saved as structured rent payments:

- `payment_purpose = 'rent'`
- `is_historical = true`
- `rent_period_start` and `rent_period_end` set to the selected historical month

Other payments such as maintenance, repairs, deposits, late fees, or custom charges must not reduce tenant rent balance. Balance logic must use structured purpose fields such as `payment_purpose`, not only free-text notes or labels.

Tenant current balance should only subtract verified rent payments for the current rent month. Historical rent for previous months stays in payment history and reports but does not reduce the current month balance.

Current balance refinement: tenant `Current Balance` should show all unpaid rent due from the active lease start month through the current month. It should subtract only verified payments whose structured `payment_purpose` is rent and whose rent period belongs to those months. Deposit, maintenance, repair, late fee, and custom other payments must not reduce rent balance.

### Tenant-Landlord Request Lifecycle

Existing tenant accounts use a persisted request workflow. Sending a request does not grant access and does not make the tenant assignable.

- Pending requests appear in the landlord's `Requests Sent` section, never in Accepted Tenants.
- Only explicit tenant acceptance sets `profile_id`, sets `invite_accepted = true`, exposes the tenant in Accepted Tenants, and permits unit assignment.
- Rejection archives the pending relationship and removes it from the landlord's pending list without creating an accepted relationship.
- Tenant Notifications retain and display `Accepted` or `Rejected` after the response instead of continuing to show action buttons.
- Tenant Settings lists accepted landlords and their contact/property/unit information.
- A tenant may drop a landlord only after no active lease remains. Historical lease and payment records are retained.
- The frontend shows RPC errors and reloads notifications, unread counts, relationship data, and Settings data after a response.

### Stable Loading And Mobile Layout

Do not let pages jump vertically when data refreshes. Once a section has loaded, keep the existing container, cards, and rows visible during background data refreshes instead of setting the bucket back to full loading state.

Use the shared `beginDataLoad(sectionKey, bucket)` / `finishDataLoad(sectionKey, bucket)` pattern for section loaders. Stable table/panel wrappers should keep minimum height during refresh, and wide tables should scroll only inside their own `overflow-x-auto` wrapper.

On mobile, fix layout overflow at the source with responsive Tailwind classes (`w-full`, `max-w-full`, `min-w-0`, responsive grids/flex, and internal table scrolling). The whole page must not horizontally scroll on phone screens.

### Direct Signup Country Rule

Direct landlord signup and direct tenant signup must require country. New accounts must not be created as `Unassigned`.

- Load active countries for public signup forms.
- Save country to `profiles.country_id` for both landlord and tenant direct signup.
- Save country to `landlord_subscriptions.country_id` for landlord direct signup.
- Save country to `tenants.country_id` for tenant direct signup.
- Country dropdowns must store stable country IDs and follow the dropdown state sync rule.
- If signup RPC signatures change, update the full SQL file with `drop function if exists` cleanup for old signatures before the new functions and update grants for the new signatures.

### Latest Product Rules To Preserve

Work from the local project folder unless the owner explicitly says otherwise:

```text
C:\Users\HP\Desktop\Mushavo Homes
```

Do not use the GitHub repo as the source of truth unless the owner asks for it.

Country handling:

- Public landlord signup and tenant signup can show all world countries.
- Admin country cards must not show every world country by default.
- Admin country cards should show only enabled Mushavo Homes markets or countries that already have activity.
- Admin Add Country should use a controlled country dropdown from the world country list, not free text.
- Admin staff can only select/manage countries assigned to them and cannot add countries.

Signup page split:

- `client.html` is login/authenticated client area only.
- Direct free landlord signup belongs on its own page such as `landlord-signup.html`.
- Direct tenant signup belongs on its own page such as `tenant-signup.html`.
- If a tenant is missing, landlord invite/copy action must point to the tenant signup page.
- If a landlord is missing, IPM/PMC invite/copy action must point to the free landlord signup page.
- Do not show raw signup URLs as the main success message. Use text like `Free tenant signup link ready. Copy and send it to the tenant.` and provide a Copy Link button.

Customer-facing wording:

- Contact success text must say `Enquiry submitted. The Mushavo Homes team will review it.`
- Do not mention the admin area to customers.
- Convert raw Supabase/RPC messages into clean product messages wherever possible.

Admin pricing:

- Admin has a Pricing page controlling public pricing and default subscription limits.
- Pricing records drive public `pricing.html` and default plan limits for landlord, IPM, and PMC creation/subscription dialogs.
- Yearly billing gives one month free.
- Landlord unit limits are units per property where applicable.
- IPM limits include landlord count and property-per-landlord limits.
- PMC limits include landlords, properties, units, and staff.

IPM/PMC finance:

- Landlord Finance is private to the landlord and must not be exposed to IPM/PMC by permission.
- IPM/PMC menu label `Payments` should become `Landlord Payments` when it records payments from connected landlords.
- IPM/PMC menu label `Finance` should become `Personal Finance` for the IPM/PMC business finance dashboard.
- IPM/PMC personal finance is like admin finance but scoped to connected landlords, not countries.

Admin notes:

- If an admin/admin staff user creates a note and chooses `assign to staff`, the assignee dropdown must not include the current creator.
- Admin staff must still be able to assign notes to the super admin/admin.

Property units UI:

- Property card button controls the unit panel.
- Closed state: `Open Units`.
- Open state for that property: `Close Units`.
- Do not also show a duplicate `Close Units` button beside Refresh in the expanded units panel.
- Expanded units appear directly below the selected property card.

Realtime/granular refresh:

- Avoid full-page reloads after add/edit/delete/payment/notification changes.
- Refresh only the affected section/component where possible.
- Preserve current page, selected tab, selected landlord, filters, open unit panel, and scroll position.
- Keep stable containers/skeletons so pages do not jump during background refreshes.

Mobile shell:

- All account types must use a phone-friendly header/menu pattern.
- Navigation goes behind a hamburger menu on mobile.
- Notification bell stays visible on the mobile main header.
- Logout goes inside the mobile menu/drawer.
- Plan/status badges that do not fit move into the mobile menu/drawer.
- No page-wide horizontal scrolling on phones.

Tenant relationship lifecycle:

- Sending a tenant request never makes the tenant assignable.
- Only tenant acceptance moves the tenant into Accepted Tenants.
- Rejection removes the request without creating an accepted relationship.
- Tenant Settings lists accepted landlords and supports dropping a landlord only after no active lease remains.
- Dropping a landlord/tenant relationship must not delete historical leases, payments, receipts, maintenance, or landlord records.

Recent continuation notes:

- Source of truth: the canonical folder synchronized with the latest GitHub `main`, with all changes made on a focused branch.
- Update `rules.md` and this prompt file only when the user explicitly asks.
- When SQL or HTML changes are needed, update the full local file, not a partial snippet.

Page feedback and loading:

- Success/error/status messages must be page-scoped.
- When `currentPage` changes, clear transient page feedback so messages from one page do not appear on another page.
- Keep confirmation dialogs and QR dialogs separate from transient page feedback.
- Loading pages must not flash false `0` values or `No records found` before data finishes loading. Use loading/skeleton states and stable container heights.
- Avoid full-page reloads. Refresh only the affected component/section while preserving current page, tab, filters, selected landlord, open unit panel, and scroll position.

Mobile layout:

- All accounts should use the same clean mobile header pattern that worked well for admin/admin staff.
- On mobile, show logo, account label/name, notification bell where applicable, language selector, and hamburger menu without overlap.
- Logout should be inside the mobile menu/drawer.
- Plan/status badges that do not fit in the mobile header should move into the menu/drawer.
- Admin/admin staff should use a menu/drawer because the full horizontal menu does not fit.
- Admin/admin staff menu order: Dashboard, Notes, Landlords, IPM, PMC, Staff, Tenants, Finance, Enquiries, Pricing, Leads, Automation, Audit. Skip pages not available to admin staff. Audit is admin-only.

Admin and admin staff:

- Admin dashboard should summarize landlords, finance, enquiries, IPM, PMC, and notes.
- Admin staff can manage operational items only within assigned country scope.
- One admin staff member can be assigned to multiple countries.
- Admin staff must not see Audit.
- Admin staff must not delete/archive landlords, IPMs, PMCs, or edit/delete payment history.
- If admin suspends an admin staff account, login should show a clear suspension message: `Your account is suspended. Please contact the admin.`
- Do not show `This account role is not supported` for suspended staff.

Notes:

- Admin/admin staff Notes page should keep the New Note form collapsed by default.
- Show the form after clicking Add Note.
- After adding a note, collapse the form again.
- If assigning a note to staff, do not show the current creator in the assignee list.
- Admin staff can assign notes to the admin.

Countries:

- Admin country cards should not list every world country by default.
- Admin country cards show `All countries` plus countries that have landlords/active market data.
- Landlord signup and tenant signup country selectors should show all world countries.
- Add Country should use a dropdown from the world country list instead of free typing country name/code/currency.
- Admin staff can only select countries assigned to them for country-related actions.

Signup and invite links:

- Free landlord signup and tenant signup are separate pages from `client.html`.
- After successful landlord signup, redirect to the login/client page.
- If IPM/PMC invites a landlord not on Mushavo Homes, the generated/copy link should go to the free landlord signup page only.
- If landlord invites a tenant not on Mushavo Homes, the generated/copy link should go to the tenant signup page only.
- Do not display raw signup URLs as success text. Use friendly messages such as `Free tenant signup link ready. Copy and send it to the tenant.`
- Contact form success text must not mention `admin area`; use `Enquiry submitted. The Mushavo Homes team will review it.`
- If QR codes are generated for links, they should point to the same temporary invite/signup link and inherit its expiry/safety behavior.

Subscription and status:

- Use combined `Plan / Status` labels such as `Active - Free`, `Starter - Active`, `Growth - Trial`, etc.
- Trial must not be treated as suspended.
- Suspended and expired are separate states: suspended shows a suspension page; expired shows a subscription expired page.
- When admin suspends landlord/IPM/PMC, keep the plan/status intact and allow Unsuspend to restore access.
- Active-Free accounts should show `Unlimited` or `-` for expiry/days remaining, including admin/admin staff tables and My Account pages.

Forms, panels, and dialogs:

- Large add forms should be collapsed by default behind Add buttons.
- After successful add, collapse the form again.
- Applies to properties, tenants, leases, maintenance, notes, and equivalent landlord staff/IPM/PMC/PMC staff pages.
- Unit panels should open directly below the selected property card.
- When a property unit panel is open, change the card button from `Open Units` to `Close Units`; remove the duplicate Close Units button beside Refresh.
- All dialogs need max-height and internal scrolling so X, Cancel, and Save/Submit are reachable on smaller screens.
- Dropdowns in edit dialogs must hydrate with the saved value, not reset to the first/default option.
- Sort arrows on tables must sort by the clicked column without hidden primary sorting overriding the result.

Tenant relationship lifecycle:

- Existing tenants are found by email/phone but cannot be assigned automatically.
- Searching an existing tenant sends a request only.
- Landlord/IPM/PMC pages must show pending tenant requests separately.
- Accepted Tenants should include a tenant only after tenant acceptance.
- Rejection removes the pending request.
- Tenant Settings should list accepted landlords and show Drop Landlord only when no active lease/unit relationship remains.
- Dropping a tenant-landlord relationship must not delete historical leases, payments, receipts, maintenance, or financial records.

Payments and finance:

- Tenant current balance is rent-only and should include historical outstanding rent.
- Non-rent payments such as maintenance or Other must not reduce rent balance.
- Payment type `Other` requires a description and should label the amount field as `Amount`, not `Rent amount`.
- Deposit should appear as a payment option when unpaid, but deposits are refundable and must not count as revenue.
- IPM/PMC menu label `Payments` should be `Landlord Payments`.
- IPM/PMC menu label `Finance` should be `Personal Finance`.
- IPM/PMC personal finance is their business finance dashboard, separate from landlord rent finance.

Maintenance and assigned staff:

- Maintenance requests need a delete option where allowed.
- Staff assignment dropdowns must only show staff actually under or assigned to the relevant landlord/PMC/IPM scope.
- If assignment permission is missing, hide the assignment dropdown.
- Maintenance permissions should be clear: create/log maintenance, assign, update status/resolution, and view.
- Landlord and PMC/IPM unit detail views should show which staff member is assigned to the unit.

Phase delivery:

- Completed phases so far include Phase 1 Trust and Finance Core, Phase 2 Owner/Landlord Statements, Phase 3 Maintenance Workflow, Phase 4 Leasing and Tenant Lifecycle, Phase 5 Inspections, Phase 6 CRM and Public Vacancy Flow, Phase 7 Permissions and Audit Control, and Phase 8 Automation.
- Whenever a phase is completed, provide where changes were made and a testing checklist.
- Do not claim a phase is complete if any listed phase item was skipped.

Phase 7 permissions and audit:

- Use one central permission matrix.
- Parent-child permission rules are mandatory. Example: cannot edit unit unless can view unit.
- Hide every button, dropdown, field, and sensitive data block when permission is missing.
- Supabase RLS/functions must enforce the same permission rules as the UI.
- Audit log create/edit/delete/archive/approve/reject/export/view financial record actions.
- Staff action history matters.

Phase 8 automation:

- Automation includes rent due reminders, overdue rent alerts, lease expiry reminders, subscription expiry reminders, maintenance escalation, payment received notifications, and custom message templates.
- Email integration comes later, but keep templates and notification records ready.
- Never expose email provider or AI provider API keys in client HTML.

AI lease writer:

- Lease page may include a button: `Let AI help you write your lease agreement`.
- The client must call a server/Cloudflare Worker proxy, not the AI provider directly.
- API keys must be stored as server-side secrets/environment variables and must never appear in `client.html`.
- Provider may change, so keep endpoint/key configurable in the Worker/backend layer.

## Current Working Folder

Continue Mushavo Homes work from `C:\Users\HP\Desktop\Mushavo Homes`.

Use `client.html` for the client area, standalone public/signup pages for public flows, and `rentradar_loop1_schema.sql` for Supabase schema/RLS/RPC/storage/realtime. Treat the database as fresh when the user says Supabase was reset.
