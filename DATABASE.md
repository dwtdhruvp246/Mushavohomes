# Database And Supabase Guide

`rentradar_loop1_schema.sql` must be runnable on a fresh empty Supabase project. Do not assume old tables, policies, functions, or auth users exist.

## What Lives In The SQL File

- Extensions.
- Types/enums.
- Tables.
- Indexes.
- Triggers.
- Helper functions.
- RPC functions.
- RLS policies.
- Storage buckets.
- Storage policies.
- Realtime publication setup.
- Admin bootstrap function.

## Fresh Database Rules

- Create helper functions before any RLS policy that references them.
- Create tables before functions/triggers that reference them.
- Drop policies before dropping functions they depend on.
- If a function signature changes, include `drop function if exists function_name(args);`.
- If return type changes, the old function must be dropped first.
- Do not use enum values in constraints/policies in the same transaction before the enum value is safely committed, unless the file is structured to avoid Postgres unsafe enum use.

## Permission Enforcement

UI checks are not enough. Any sensitive action also needs database protection.

Protect:

- Create/edit/delete/archive.
- Approve/reject.
- Staff assignments.
- Lease/payment/finance records.
- Tenant relationship actions.
- File uploads and downloads.
- Public listing publish/unpublish.
- Audit visibility.

## Storage

Storage policies should match feature rules:

- Lease documents: only allowed users.
- Payment proofs: tenant submit, allowed managers review.
- Maintenance photos: scoped to the request/unit/property.
- Inspection files: scoped to inspection/property/unit/lease.
- Listing photos: public-read images stored as `uploader_profile_id/unit_id/file`; write and delete access requires the uploader identity plus listing permission for that unit.

## Common Errors And Fixes

- `cannot change return type of existing function`: drop the function with its exact old signature before recreating it.
- `cannot drop function because policies depend on it`: drop dependent policies first, then function, then recreate policies.
- `relation does not exist`: table/function order is wrong for fresh database.
- `function does not exist`: helper function is referenced before it is created or signature changed.
- `new row violates row-level security`: either policy is missing/too strict or the UI is trying the wrong action/role.
- `check constraint`: allowed enum/status values are missing from constraints.

## SQL Change Protocol

When the user asks for SQL changes:

1. Update the full `rentradar_loop1_schema.sql`.
2. Keep it fresh-run safe.
3. Mention any new tables, columns, policies, functions, or storage changes.
4. Avoid partial snippets unless explicitly requested.
