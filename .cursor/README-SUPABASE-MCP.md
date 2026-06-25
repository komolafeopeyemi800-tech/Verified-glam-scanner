# Supabase MCP (Cursor)

This project includes [Supabase MCP](https://supabase.com/docs/guides/ai-tools/mcp) in [`.cursor/mcp.json`](mcp.json) for project `qmivgvctmxvpnbouqslj`.

## One-time setup

1. Create a **Personal Access Token** (not the anon key):  
   https://supabase.com/dashboard/account/tokens

2. Set it so Cursor can read it (pick one):
   - **Windows user env var:** `SUPABASE_ACCESS_TOKEN` = your token, then restart Cursor.
   - Or edit `mcp.json` and replace `${SUPABASE_ACCESS_TOKEN}` with the token (do not commit that change).

3. In Cursor: **Settings → Tools & MCP** → enable the **supabase** server.

4. Reload the window. In Composer, type `@` and look for Supabase tools.

## Notes

- MCP is for **development in the IDE** (SQL, migrations, docs). The Flutter app uses `supabase_flutter` + `--dart-define`, not MCP.
- Use `--read-only` in `mcp.json` args if you only want safe queries.
