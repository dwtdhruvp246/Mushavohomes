# Mushavo Project Map

This map helps future agents find the right file quickly without scanning the whole project.

## Architecture At A Glance

Mushavo is currently a static multi-page HTML application backed by Supabase.

- Public website pages are separate HTML files.
- The authenticated client area is mainly in `client.html`.
- State management is mostly inside the Alpine app function in `client.html`.
- Supabase handles Auth, Postgres, RLS, RPC functions, Storage, and Realtime.
- SQL schema, policies, functions, storage, and realtime setup live in `rentradar_loop1_schema.sql`.
- AI lease generation is designed to use `ai-lease-worker.js` as a server-side proxy so API keys do not appear in browser code.

## File Map

| Area | File | Notes |
| --- | --- | --- |
| Home page | `index.html` | Public marketing homepage |
| About page | `about.html` | Company story, vision, mission |
| Pricing page | `pricing.html` | Public plan display, pricing controls reflected from admin pricing data where implemented |
| Contact page | `contact.html` | Public enquiry form; must not mention internal admin area |
| Available units | `available-units.html` | Public CRM/listings page |
| Client area | `client.html` | Main authenticated app for admin, admin staff, landlords, tenants, IPM, PMC, and staff |
| Landlord signup | `landlord-signup.html` | Free landlord self-signup |
| Tenant signup | `tenant-signup.html` | Tenant self-signup |
| Translations | `i18n.js` | English, Bahasa Melayu, Chinese translation dictionary/helpers |
| Database | `rentradar_loop1_schema.sql` | Supabase schema, RLS, RPC, storage, realtime |
| AI lease proxy | `ai-lease-worker.js` | Cloudflare Worker style AI API proxy |
| Prompt context | `rentradar_next_chat_prompt.md` | Long-running project prompt/context |
| User rules | `rules.md` | Extra user-specific rules |

## Feature Map

| Feature | Primary Files | Database Areas | Notes |
| --- | --- | --- | --- |
| Auth and profiles | `client.html`, signup pages | `profiles`, auth triggers/functions | Login messages must be user-friendly |
| Admin dashboard | `client.html` | finance, enquiries, notes, audit, automation tables | Admin sees global data |
| Admin staff | `client.html` | admin staff tables, country assignments | Country-scoped; no delete/archive for landlord/IPM/PMC |
| Countries | `client.html`, signup pages | `countries` | Admin country cards show active/added markets, signup can show all countries |
| Landlords | `client.html`, `landlord-signup.html` | profiles, landlord subscriptions, properties | Free-active defaults for self/invited landlords |
| Tenants | `client.html`, `tenant-signup.html` | tenants, tenant link requests, notifications | Tenant must accept relationship before assignment |
| IPM | `client.html` | IPM profile/subscription/access tables | Individual Portfolio Manager; not staff |
| PMC | `client.html` | management companies, PMC staff, permissions | Property Management Company with internal staff |
| Properties and units | `client.html` | properties, units | Units open directly under selected property |
| Leases | `client.html` | leases, lease documents, lifecycle/checklists | Lease actions require tenant/unit/permission context |
| Payments and rent | `client.html` | payments, submissions, allocations, receipts | Rent balance only includes rent-related payments |
| Deposits | `client.html` | lease/payment fields | Track as refundable/non-revenue |
| Finance | `client.html` | platform payments, partner payments, finance audit | Landlord finance is private to landlord |
| Maintenance | `client.html` | maintenance requests, quotes, activity | Staff assignment must be scope-safe |
| Inspections | `client.html` | property inspections, inspection files | Should require tenant/lease context where appropriate |
| Notifications | `client.html` | notifications | Used for tenant link, reminders, requests |
| Enquiries | `contact.html`, `client.html` | enquiries | General contact enquiries separate from listing leads |
| CRM/listings/leads | `available-units.html`, `client.html` | unit listings, listing leads, viewing requests, followups | Public sees safe listing data only |
| Notes | `client.html` | admin notes | Admin staff can assign notes to admin/staff; add form should be collapsible |
| Audit | `client.html` | audit events | Admin only |
| Automation | `client.html` | automation rules/templates/logs | Loading state should not flash zero/no data |
| AI lease writer | `client.html`, `ai-lease-worker.js` | optional generated lease storage | API key only in worker env |

## When To Touch SQL

Touch `rentradar_loop1_schema.sql` only when the change requires tables, columns, policies, functions, storage buckets, storage policies, realtime publication, or backend permission checks.

For ordinary UI text, layout, button placement, list rendering, or client-side validation, start in `client.html` or the public page involved.
