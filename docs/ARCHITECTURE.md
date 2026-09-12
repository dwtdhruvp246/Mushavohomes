# Architecture Notes

## Current Shape

Mushavo is a static frontend with Supabase as the backend.

- Public marketing pages are standalone HTML files.
- The authenticated app is mostly `client.html`.
- `client.html` uses Alpine-style state and methods for all account shells.
- Supabase JS is used directly from the browser with anon key plus RLS/RPC protection.
- Heavy backend rules live in Postgres functions and RLS policies.
- The AI lease writer should call a Cloudflare Worker proxy, not an AI provider directly from the browser.

## Client State

The client app keeps role, current page, current account data, lists, form state, filters, modal state, and messages in one large state object.

Important state rules:

- Do not trigger global reloads for local changes.
- Refresh the smallest affected collection or component.
- Preserve current page, selected filters, selected landlord/property/unit, and open panels where possible.
- Clear page-specific success/error messages on navigation.
- Keep loading containers stable to prevent page jumping.

## Navigation

There are multiple shells:

- Public website pages.
- Admin/admin staff shell.
- Landlord shell.
- Landlord staff shell.
- Tenant shell.
- IPM shell.
- PMC leader shell.
- PMC staff shell.

All account menus should be mobile-safe. On small screens use hamburger menus and keep the notification bell visible where relevant.

## Supabase Access Model

The browser can see the Supabase URL and anon key. This is normal for Supabase client apps. Security must come from:

- RLS policies.
- RPC functions with permission checks.
- Storage policies.
- Not exposing service role keys.
- Not exposing third-party AI API keys.

## Realtime

Realtime should update affected data without resetting the whole app.

Expected pattern:

1. Subscribe to relevant tables.
2. Detect which feature changed.
3. Refresh only the affected data set.
4. Avoid changing unrelated shell/page state.

## AI Lease Writer

Client flow should be:

1. User clicks AI lease writer button.
2. UI collects structured lease details using fields/dropdowns/add-ons.
3. Browser sends a sanitized prompt payload to `ai-lease-worker.js`.
4. Worker adds the provider API key from environment variables.
5. Worker calls the AI provider.
6. Response returns to UI for review/editing.

Never place AI provider keys in `client.html`.
