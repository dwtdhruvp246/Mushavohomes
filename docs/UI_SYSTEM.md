# UI System

## Visual Direction

Mushavo uses a premium, calm glassmorphism style:

- Pale mint and aqua page backgrounds.
- White or near-white translucent cards.
- Soft shadows.
- Subtle borders.
- Rounded corners.
- Clean spacing.
- Dark navy/slate text.
- Green/teal primary actions.
- Red only for destructive actions.
- Amber/orange for trial, pending, or warning states.

## Tailwind Patterns

Preferred patterns:

- `w-full`
- `max-w-*`
- `mx-auto`
- `px-4 sm:px-6 lg:px-8`
- `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`
- `flex-col md:flex-row`
- `flex-wrap`
- `min-w-0`
- `break-words`
- `overflow-x-auto` only inside wide table wrappers
- `max-h-[90vh] overflow-y-auto` for modals

## Mobile Rules

- No whole-page horizontal scrolling.
- Use hamburger menu on account dashboards.
- Keep notification bell visible on mobile where the account has notifications.
- Move logout into the mobile menu.
- Keep plan/status visible in the mobile menu if it cannot fit in the header.
- Tables can scroll internally or convert to cards; the page itself must not overflow.
- Text must wrap cleanly and not stack letter-by-letter.

## Modals

Every modal must:

- Fit small screens.
- Have visible close/cancel/save controls.
- Scroll internally if content is tall.
- Reopen with saved field values, not first/default options.
- Avoid browser confirm/alert popups.

## Loading And Realtime

- Do not flash `0` or `No records` before real data loads.
- Use loading labels, skeletons, or stable placeholders.
- Keep container heights stable to avoid jumping.
- Clear page messages when navigating to a new page.

## Collapsed Forms

For crowded pages, prefer an Add button that reveals the form:

- Add Property.
- Add Tenant/request tenant.
- Add Lease.
- Add Maintenance.
- Add Note.

After successful add, collapse the form again unless the workflow clearly benefits from staying open.

## i18n

Supported languages:

- English.
- Bahasa Melayu.
- Chinese.

When adding visible text, update `i18n.js` or use the existing translation helper pattern. Do not leave major labels untranslated.
