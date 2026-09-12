# Efficient Change Process

Use this process to avoid long, expensive, unfocused work.

## For Small UI Changes

Examples: button text, moving a button, hiding a label, changing status wording.

1. Read `docs/PROJECT_MAP.md`.
2. Open the exact file.
3. Search for the visible text or function name.
4. Patch the smallest block.
5. Check for repeated copies of the same UI.
6. Do a focused syntax/visual sanity check.

Do not inspect SQL unless the UI action touches data rules.

## For Data Or Permission Bugs

Examples: accepted tenant showing too early, permission mismatch, RLS error.

1. Identify the role and workflow.
2. Read `docs/ROLES_PERMISSIONS.md`.
3. Inspect the UI method in `client.html`.
4. Inspect only the related SQL tables/functions/policies.
5. Patch both UI and SQL if needed.
6. Test happy path and blocked path.

## For SQL Errors

1. Read the exact Supabase error.
2. Identify line/function/table.
3. Check object order in `rentradar_loop1_schema.sql`.
4. Check whether a function signature changed.
5. Check whether policies depend on a function being dropped.
6. Patch full schema safely.

## For Broad Phases

Before building:

1. Write the intended scope.
2. List files expected to change.
3. List database objects expected to change.
4. Build in small slices.
5. After completing, provide a testing list and locations changed.

## When To Stop

Stop when:

- The requested behavior is implemented.
- Related files are validated.
- No required command is still running.
- Any known limitation is clearly reported.

Do not continue into unrelated cleanup.
