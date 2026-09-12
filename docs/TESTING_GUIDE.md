# Testing Guide

Use this guide to choose targeted tests. Do not run every test for every small change.

## Auth And Signup

- Admin can log in.
- Wrong email/password shows a credential error, not a session error.
- Suspended user sees suspension message.
- Expired user sees subscription expired message.
- Free active landlord shows unlimited/no expiry.
- Landlord signup redirects to login after successful signup.
- Tenant signup creates a tenant account without requiring landlord permission.
- Duplicate email or phone blocks signup before leaving unwanted auth/profile records.

## Admin And Admin Staff

- Admin sees dashboard, notes, landlords, IPM, PMC, staff, tenants, finance, enquiries, pricing, leads, automation, and audit.
- Admin staff does not see audit.
- Admin staff only sees assigned-country data.
- Admin staff cannot delete/archive landlords, IPMs, PMCs.
- Admin staff cannot edit/delete payment history.
- Admin staff can assign notes to admin and other eligible staff, but not themselves when assigning to staff.

## Landlord

- Free landlord starts active/free with correct limits.
- Property limit is enforced with friendly message.
- Staff limit is checked before opening invite modal.
- Open Units button changes to Close Units when expanded.
- Units panel appears directly under the selected property.
- Staff list only includes landlord staff.
- Tenant search sends request and does not add to accepted list before acceptance.
- Accepted tenant appears only after tenant accepts.

## Tenant

- Tenant sees landlord link request notification.
- Accept marks accepted and enables landlord relationship.
- Reject marks rejected/removes pending request.
- Settings shows accepted landlords.
- Drop landlord only appears when allowed by vacant/unit lifecycle.
- Dropping landlord does not delete landlord payment/lease history.

## Payments And Finance

- Rent payment reduces rent balance.
- Other payment does not reduce rent balance.
- Maintenance payment does not reduce rent balance.
- Deposit can be paid but is not revenue.
- Receipts download where available.
- Landlord finance is not visible to IPM/PMC as landlord private finance.
- IPM/PMC personal finance tracks landlord payments to IPM/PMC.

## Maintenance

- Create/log button respects create permission.
- Assign dropdown respects assign permission.
- Assign dropdown only shows staff in valid scope.
- Status/resolution controls respect permissions.
- Maintenance history/view details works from property/unit context.

## CRM/Listings/Leads

- Public sees only published listings.
- Public does not see exact address.
- Lead is linked to listing, unit, property, landlord, country, and manager.
- Viewing request appears in Leads.
- Admin sees all leads.
- Admin staff sees assigned-country leads.
- Landlord/IPM/PMC sees scoped leads.
- Conversion creates tenant-link request, not automatic lease.

## UI Regression Checks

- Mobile has no horizontal page scroll.
- Header does not overlap.
- Notification bell is visible where required.
- Logout is in mobile menu.
- Modals are scrollable and show close/save/cancel.
- Dropdowns reopen with saved value.
- Page messages clear on navigation.
- Loading states do not flash false zero/no-data.
