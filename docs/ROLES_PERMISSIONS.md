# Roles And Permissions

## Platform Roles

| Role | Purpose | Scope |
| --- | --- | --- |
| Admin | Platform owner | All countries and all account types |
| Admin staff | Country operator | Assigned countries only |
| Landlord | Property owner | Own account and delegated staff/partners |
| Landlord staff | Landlord employee | One landlord only |
| Tenant | Renter | Own tenant account and accepted landlord relationships |
| IPM | Individual Portfolio Manager | Approved landlord/property scope |
| PMC leader | Property Management Company leader | Own company and approved landlord/property scope |
| PMC staff | Staff under PMC | One PMC only, assigned by PMC leader |

## Admin Staff Limits

Admin staff may help manage assigned countries but should not:

- See audit logs.
- Delete landlords, IPMs, or PMCs.
- Archive landlords, IPMs, or PMCs.
- Edit or delete payment history.
- See countries not assigned to them in operational workflows.

## Permission Matrix Rules

Permissions must be parent-child aware.

Examples:

- `edit_property` requires `view_property`.
- `archive_property` requires `view_property`.
- `view_unit` requires `view_property`.
- `add_unit`, `edit_unit`, `archive_unit`, and `mark_unit_vacant` require `view_unit`.
- `edit_tenant` and `archive_tenant` require `view_tenant`.
- `create_lease`, `edit_lease`, `terminate_lease`, and `view_lease_documents` require `view_lease`.
- `verify_payment`, `reject_payment`, and `view_proof_files` require `view_payments`.
- `assign_maintenance` requires maintenance visibility and valid staff scope.

## UI And Backend Must Match

If a button is hidden because permission is missing, the backend must also reject the same action. If the backend rejects an action, show a friendly message instead of raw Supabase text.

## Tenant Consent

Landlords, IPMs, and PMCs do not automatically own a tenant account.

Tenant relationship flow:

1. Search tenant by email.
2. If found, send request.
3. Tenant accepts or rejects.
4. Only after acceptance can the tenant be assigned to a unit/lease.
5. Rejection removes pending request.
6. Landlord history remains intact after relationship drop.

## Suspension And Expiry

Suspended:

- Admin/admin staff intentionally paused account.
- User sees account suspended page.
- Plan/status remains intact.
- Unsuspend restores access if subscription is otherwise valid.

Expired:

- Subscription date passed.
- User sees subscription expired page.
- Different message from suspension.

Free active:

- No meaningful expiry.
- Display `Unlimited` or `-`.
