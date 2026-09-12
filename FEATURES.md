# Mushavo Homes Feature Guide

This file summarizes what Mushavo Homes is expected to do. Use it before making changes so product logic stays consistent.

## Roles

- Admin: owns the platform, sees all countries, accounts, finance, enquiries, notes, automation, pricing, audit, landlords, tenants, IPMs, PMCs, and staff.
- Admin staff: helps admin by assigned countries only. Should not see audit. Should not delete/archive landlords, IPMs, PMCs, or edit/delete payment history.
- Landlord: manages own properties, units, tenants, leases, rent, finance, staff, maintenance, inspections, listings, and leads.
- Landlord staff: staff created by one landlord. They only serve that landlord.
- Tenant: self-owned account. Accepts/rejects landlord link requests, pays rent/proofs, sees lease/unit/contact info, and can drop a landlord after vacancy conditions are met.
- IPM: Individual Portfolio Manager. Can connect to multiple landlords by request/approval and manage assigned scope.
- PMC: Property Management Company. Has a leader account and internal PMC staff.
- PMC staff: staff created under a PMC. They only serve that PMC and assigned PMC scope.

## Tenant Relationship Flow

1. Tenant can create their own account from `tenant-signup.html`.
2. Landlord/IPM/PMC searches tenant by email.
3. If tenant exists, send a tenant-link request.
4. Tenant accepts or rejects from notifications.
5. Only accepted tenants appear in the accepted tenant list.
6. Assignment to a unit and lease creation happen after acceptance.
7. If tenant rejects, the pending request should disappear.
8. If a unit is marked vacant, the tenant may drop the landlord relationship in settings.
9. Dropping the relationship must not delete historical payments, leases, or reports.

## Landlord Signup And Free Plan

New landlords created directly or invited by IPM/PMC should default to:

- Plan/status: `Active - Free`
- 1 property
- 1 unit
- Finance page access
- 0 personal staff
- 1 IPM or PMC connection
- No visible expiry; show `Unlimited` or `-`

## Payments

- Rent payments affect tenant current rent balance.
- Other payments do not affect rent balance.
- Maintenance payments do not affect rent balance.
- Deposits are refundable/non-revenue and should not count as rent revenue.
- Payment receipts should be downloadable where payment records appear.
- Manual rent logging should require a lease where rent is involved.
- The landlord, IPM, and PMC Payments page should show pending rent by tenant and rent period. Only verified rent payments reduce the outstanding amount; proofs awaiting approval are identified separately.

## Finance

- Landlord finance belongs only to that landlord.
- IPM/PMC should not view a landlord's private rental finance page.
- IPM/PMC personal finance tracks payments they receive from landlords.
- Admin finance tracks platform payments from landlords, IPMs, and PMCs.
- Admin staff can view/record according to scope but must not edit/delete payment history.

## Permissions

Pages should generally remain visible. Missing permission should hide or block sensitive actions.

Parent-child examples:

- Cannot edit property without view property.
- Cannot archive property without view property.
- Cannot view/edit/add/archive units without the relevant unit permissions.
- Cannot assign tenant unless tenant relationship and unit scope are valid.
- Cannot assign maintenance to staff outside the account/scope.

## Maintenance

Maintenance should separate:

- Viewing requests.
- Creating/logging requests.
- Assigning staff.
- Updating status.
- Adding resolution notes.
- Quotes/activity/history.

Staff assignment must only show staff who belong to the relevant landlord, PMC, or allowed IPM/PMC scope.

## Inspections

Inspections include move-in, routine, and move-out records, photos/videos, meter readings, room conditions, signatures, locking records, comparisons, and deposit deduction evidence.

Inspection actions should require the correct property/unit/tenant/lease context. Do not allow inspection workflows to create implicit leases.

## CRM And Public Listings

Public listing flow is enquiry/viewing first, not full document application.

- Public users see only published listings.
- Exact address stays hidden.
- Listing rent is always read from the linked unit so later unit-rent changes appear automatically.
- Published listings require complete public details, a positive saved rent, bathroom details, and at least one uploaded photo; incomplete listings may only remain drafts or paused.
- Listing photos are uploaded to Supabase Storage. New arbitrary photo URLs are not accepted, and only the uploader may replace or delete their stored files.
- Listing leads are separate from general contact enquiries.
- Converted leads create tenant-link requests first, not automatic leases.

## Automation

Automation covers rent due reminders, lease expiry reminders, subscription expiry reminders, maintenance escalation, payment received notifications, overdue rent alerts, and message templates.

Automation status messages must clear when the user navigates to another page.
