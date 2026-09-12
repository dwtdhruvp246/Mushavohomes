# AI Handoff

Use this file at the start of future AI sessions.

## Start Here

1. Read `AGENTS.md`.
2. Read `docs/PROJECT_MAP.md`.
3. Read the feature doc relevant to the request.
4. Open only the file(s) needed for the task.

## Current Project Path

`C:\Users\HP\Desktop\Mushavo Homes`

## Most Common Files

- Main app: `C:\Users\HP\Desktop\Mushavo Homes\client.html`
- SQL schema: `C:\Users\HP\Desktop\Mushavo Homes\rentradar_loop1_schema.sql`
- Public pricing: `C:\Users\HP\Desktop\Mushavo Homes\pricing.html`
- Public contact: `C:\Users\HP\Desktop\Mushavo Homes\contact.html`
- Translations: `C:\Users\HP\Desktop\Mushavo Homes\i18n.js`

## Do Not Forget

- Use GitHub feature branches for changes; never edit `main` directly or merge without owner approval.
- When SQL is changed, update the full schema file.
- When HTML is changed, update the relevant full local file.
- Do not update `rules.md` or `rentradar_next_chat_prompt.md` unless the user asks.
- Do not expose API keys in client files.
- Use friendly errors instead of raw Supabase messages.
- Preserve role logic and permission rules.
- Keep mobile responsive.

## Common Fast Checks

Use targeted search:

```powershell
rg -n "visible text or function name" "C:\Users\HP\Desktop\Mushavo Homes\client.html"
rg -n "table_name|function_name|policy name" "C:\Users\HP\Desktop\Mushavo Homes\rentradar_loop1_schema.sql"
```

Avoid repo-wide searches unless the target is unknown after checking the docs.
