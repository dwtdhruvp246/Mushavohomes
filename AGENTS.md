# Mushavo Homes Agent Instructions

This file is the permanent operating guide for AI agents working on Mushavo Homes. It exists to reduce wasted searches, token use, accidental refactors, and repeated mistakes.

## Source Of Truth

- The real source of truth is the current code and SQL in this repository.
- Documentation is a map, not authority. If docs disagree with implementation, verify the implementation first.
- Correct stale docs when needed, but do not change working code just to match stale docs.

## Default Work Mode

Most requests are targeted. Treat a request as broad only when the user explicitly asks for a full audit, security audit, architecture review, major refactor, performance audit, database redesign, repo-wide cleanup, or major system-wide change.

For targeted work:

1. Identify the feature first.
2. Read the relevant docs before searching broadly.
3. Inspect only directly related files.
4. Inspect direct dependencies only when necessary.
5. Expand scope only with evidence.
6. Modify the minimum number of files.
7. Preserve unrelated behavior.
8. Do not opportunistically refactor.
9. Do not fix unrelated bugs automatically.
10. Do not reformat unrelated files.
11. Do not rename unrelated components, variables, functions, routes, tables, folders, or files.
12. Do not change DB architecture unless required.
13. Do not change auth unless required.
14. Do not change permissions unless required.
15. Reuse existing components, helpers, patterns, and UI conventions.
16. Prefer targeted validation over broad testing.
17. Stop once the requested change is done and validated.

## Required Search Order

Use this order unless the task is explicitly broad:

1. User request.
2. `docs/PROJECT_MAP.md`.
3. Relevant feature doc.
4. Relevant page or component.
5. Direct helper/state method.
6. Supabase RPC/RLS/schema only if the change touches data or permissions.
7. Shared architecture only if direct files prove it is needed.
8. Wider repo search only if the previous steps do not locate the issue.

## Key Local Files

- Public website: `index.html`, `about.html`, `pricing.html`, `contact.html`, `available-units.html`
- Client area: `client.html`
- Signup pages: `landlord-signup.html`, `tenant-signup.html`
- Translations: `i18n.js`
- Supabase schema/RLS/RPC/storage/realtime: `rentradar_loop1_schema.sql`
- AI lease worker proxy: `ai-lease-worker.js`
- Long-term prompt/context: `rentradar_next_chat_prompt.md`
- User rules: `rules.md`

## Product Rules That Must Not Be Broken

- All account pages should remain visible unless the user explicitly changes that rule. Missing permission should hide or disable actions, not hide the whole page.
- Buttons and sensitive information must respect permissions in both UI and Supabase RLS/RPC.
- Parent-child permissions apply. Example: a user cannot edit a unit unless they can view units.
- Admin audit is for super admin only, not admin staff.
- Admin staff are country-scoped and must not delete or archive landlords, IPMs, PMCs, or edit/delete payment history.
- Suspended and expired are different states. Suspended users see a suspension page. Expired users see a subscription expired page.
- Suspension must not erase the user's plan/status or subscription data.
- Free active landlord plans should show unlimited or `-` for expiry/days remaining, not year 2100.
- Landlord free plan means: active/free, 1 property, 1 unit, finance page, 0 personal staff, 1 IPM/PMC connection, no expiry.
- Landlord staff serve only their landlord. They must not add or switch landlords.
- PMC staff serve only their PMC. IPMs are individual portfolio managers, not landlord staff.
- Tenant accounts are independent. A landlord must send a tenant-link request, and the tenant must accept before assignment.
- Dropping a tenant-landlord relationship must not delete lease, payment, or history records for the landlord.
- Rent payments reduce rent balance only. Other payments, maintenance payments, and deposits must not reduce rent balance.
- Deposits are refundable/non-revenue. They can be tracked as paid/unpaid but should not count as revenue.
- IPM/PMC finance is their own partner finance. It is not the landlord's rental finance.
- Public contact/enquiry messages must not mention internal admin areas.
- Invite links should lead to the correct standalone signup page: `landlord-signup.html` or `tenant-signup.html`.
- API keys must never be placed in client HTML. AI lease generation must use a server-side proxy such as the Cloudflare Worker.

## Inspection Security Architecture

- Create and update inspections through `save_property_inspection`; do not directly insert or update `property_inspections` from the browser.
- The database derives property, landlord, active lease, tenant, and actor IDs from `auth.uid()` plus the selected unit and stored relationships.
- Tenant inspection loading resolves `tenants.profile_id = auth.uid()` server-side and returns only completed or locked inspections linked through the stored lease.
- Tenant signatures use the authenticated `tenant_sign_inspection` RPC. Management users must never set tenant signature fields.
- Inspection evidence paths are `landlord_id/inspection_id/file`; Storage RLS and metadata registration must use the same convention.
- RLS remains enabled. Never add permissive `using (true)` or `with check (true)` inspection policies or expose a service-role key in the frontend.

## UI Rules

- Maintain the existing premium glass UI: pale mint/aqua background, translucent cards, soft borders, rounded corners, soft shadows, and clean spacing.
- No horizontal scrolling on mobile. Fix the source of overflow instead of only hiding it.
- Mobile account headers should use the compact format already approved by the user: logo, role/name, notification bell where applicable, hamburger menu, language selector, and logout inside the mobile menu.
- Dialogs and modals must fit small screens with `max-height` and internal scrolling.
- Data loading should not collapse page layout. Use loading states, placeholders, or stable container heights to prevent jumping.
- Page-specific success/error messages must clear when navigating away from that page.
- Repeated add/create forms should usually be collapsed behind an Add button.
- Dropdowns must reopen with the saved value, not the first option.
- Table sort headers must sort by the clicked column without hidden primary grouping unless the user explicitly asks for grouping.

## SQL And Supabase Rules

- For schema changes, update the full `rentradar_loop1_schema.sql` file, not a small snippet, unless the user explicitly asks for a snippet.
- When an existing Supabase database needs the change, also maintain `existing_database_patch.sql` as an idempotent deployment patch and keep it consistent with the master schema.
- Keep table/function creation order valid for a fresh empty Supabase project.
- If changing function signatures, include safe `drop function if exists ...` statements before recreating them.
- Do not rely on old database state. The schema must run on a fresh database.
- RLS policies that depend on functions must be dropped before dropping those functions.
- Any UI permission change must be backed by RLS/RPC checks where data security matters.
- Storage buckets and policies are part of the schema and must be kept in sync with upload features.

## Validation

Use targeted validation:

- For HTML/JS changes: check syntax and the specific changed flow.
- For SQL changes: check function/table order, conflicting signatures, and fresh-run safety.
- For UI changes: inspect desktop and mobile behavior conceptually or with browser testing when available.
- For permission changes: test both button visibility and backend denial.

## Documentation Updates

Update docs only when the product structure, role rules, permission model, data model, workflow, or major UI pattern changes. Do not spend tokens updating docs for tiny text or styling changes unless the user asks.

Do not update project documentation for ordinary bug fixes, CSS or spacing changes, wording, small responsive fixes, button behavior fixes, or internal implementation changes with no navigational impact. Update only the relevant section when a project map or project-intelligence document is materially inaccurate.

## Mandatory Pre-Task Compliance Gate

Before implementing any normal task:

1. Read the applicable `AGENTS.md`.
2. Determine the primary feature or module.
3. Check `docs/FEATURES.md` and/or `docs/PROJECT_MAP.md`.
4. Classify the task internally as Level 1, 2, 3, or 4.
5. Establish the smallest likely file scope.
6. Start within that scope.
7. Expand only when evidence requires it.

For Level 1 and Level 2 tasks, repository-wide exploration is prohibited by default. A broad search is allowed only when the project map cannot locate the implementation, the bug clearly crosses features, a shared dependency must be traced, documentation appears wrong, or targeted investigation has failed. Have a concrete reason before broad searching.

## Search Budget

- Level 1 — Tiny change: inspect the project map, relevant page/component, and a direct dependency only if needed. Avoid broad search.
- Level 2 — Feature change or isolated bug: inspect the relevant feature, page/component, direct handler/hook/service, and direct database/API dependency only if needed. Do not inspect unrelated modules.
- Level 3 — Cross-feature change: list affected modules first, then inspect only those modules.
- Level 4 — Architecture change: broader investigation is acceptable, but stop opening files once sufficient evidence exists.

Correctness has priority over a numerical file limit, but additional file reads require a task-relevant reason.

## Stop-Searching Rule

Once the responsible code, actual cause, required dependencies, and a safe implementation are identified, stop exploratory searching and implement. Do not continue merely to understand unrelated architecture more completely.

When `docs/PROJECT_MAP.md` already identifies a feature location, use that path first. Rediscover it with a broad search only if the path is missing, outdated, moved, or an undocumented dependency is implicated. Correct only the stale documentation section after the task.

## Targeted Bug-Fix Fast Path

When a specific page, button, modal, form, workflow, or feature is reported broken:

1. Identify the exact feature.
2. Locate its UI/component through `docs/PROJECT_MAP.md`.
3. Reproduce or trace the failure from that component.
4. Inspect its direct event handler, hook, service, or API dependency.
5. Identify the actual failure before changing code where practical.
6. Fix the root cause.
7. Test the affected workflow.
8. Stop.

Do not begin with a whole-project audit. Move outward only when evidence points outward.

## Multiple Reported Bugs

Several reported problems do not authorize a whole-project audit. List the problems briefly, group them by feature/module, handle each group independently, and reuse context only for shared dependencies. Do not inspect unrelated modules.

## Evidence-Based Retry Rule

If a fix fails, do not make random alternatives. Re-check the observed failure, identify which earlier assumption was wrong, inspect only the dependency needed to test the new hypothesis, and make the next evidence-based change.

## Validation Economy

Use lightweight targeted validation while implementing a related group of changes, then run the appropriate broader validation once after the group is stable. Do not repeatedly run full-project validation after every edit.

A full production build is normally appropriate after meaningful cross-feature or shared-architecture changes, before completion when deployment risk warrants it, or when targeted checks cannot provide enough confidence. It is not automatic for CSS, wording, spacing, or isolated component adjustments.

## Workflow Self-Correction

If the workflow expands into unrelated modules, repeats broad searches or file reads, starts unnecessary refactoring, or runs disproportionate validation, immediately narrow the scope again. Do not continue an inefficient workflow merely because it has begun.

## Post-Task Compliance Check

Before declaring a development task complete, internally check:

- Did I follow the applicable `AGENTS.md`?
- Did I stay within the necessary feature scope?
- Did I use the project map?
- Did I make only necessary changes?
- Did I perform proportionate validation?
- Did I avoid unnecessary broad searching?
- Did I stop once the task was complete?

Do not produce a long compliance report after every task. Report only violations that materially affected the work.


## Current Workspace And Workflow Compliance

- Canonical working folder: `C:\Users\HP\Desktop\Mushavo Homes`. Use this folder for Mushavo Homes work unless the user explicitly changes it.
- Do not edit GitHub clones, downloaded copies, or older `ne\outputs` files unless the user explicitly points to them.
- Before changing code, identify the owning file and reuse existing helpers. Touch only the necessary file(s), plus `rentradar_loop1_schema.sql` when schema/RLS/RPC is required.
- For Supabase changes, keep `rentradar_loop1_schema.sql` runnable on a fresh empty Supabase project and do not assume old tables/functions/policies exist.
- When a repeated issue appears, search all similar UI/RPC patterns before fixing only the visible instance.
## GitHub Branch And Deployment Workflow

- Repository: `https://github.com/dwtdhruvp246/Mushavohomes.git`.
- Default production branch: `main`.
- Canonical Windows folder: `C:\Users\HP\Desktop\Mushavo Homes`.
- Current test deployment: `https://mushavohomes.dhruvp246.workers.dev/`; do not describe it as the final production website.
- Verify the connected GitHub account, repository access, permission level, and default branch before repository work.
- Before implementation, protect uncommitted work, fetch `origin`, inspect the latest `main`, read applicable instructions, and establish the smallest necessary scope.
- Never implement directly on `main`. Create a focused feature, fix, documentation, or reconciliation branch from the latest `main`.
- Preserve unrelated work and existing features. Do not use destructive Git commands, force pushes, or discard local changes without explicit approval.
- Run proportionate tests, inspect the final diff, and scan for secrets before committing.
- Commit clearly and push only the focused branch. Report the exact branch, commit, changed files, tests, manual configuration, limitations, and risks.
- Give the owner exact PowerShell commands for the canonical Windows folder and stop if `git status` reveals unprotected changes.
- Provide a focused testing checklist and wait for owner confirmation. Fix failures on the same branch.
- Merge into `main` only after explicit owner approval and a final check that the branch is current, tested, focused, and free of secrets.
- Treat GitHub push, build completion, Cloudflare deployment, and public-site verification as separate statuses.
- Never claim private Cloudflare or Supabase access without verifying it. Database migrations require review, explanation, and confirmed execution.
