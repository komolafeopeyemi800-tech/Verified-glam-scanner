# FCM challenge push — setup checklist

## Which Firebase file?

| File | Where it goes |
|------|----------------|
| `verified-glam-firebase-adminsdk-*.json` | Supabase secret **`FCM_SERVICE_ACCOUNT_JSON`** only |
| `google-services.json` | **`android/app/google-services.json`** only (client config) |

Do **not** swap them. The Admin SDK file has `"type": "service_account"` and a `private_key`. `google-services.json` has `project_info` and `client[]`.

**Legacy FCM is disabled** in Firebase Console (Cloud Messaging API Legacy). This project uses **FCM HTTP v1** only via `FCM_SERVICE_ACCOUNT_JSON`, matching [Supabase’s FCM guide](https://supabase.com/docs/guides/functions/examples/push-notifications?queryGroups=platform&platform=fcm). Do not set `FCM_SERVER_KEY`.

---

## Automated setup (recommended)

1. Add [Personal Access Token](https://supabase.com/dashboard/account/tokens) to `.env`:
   ```
   SUPABASE_ACCESS_TOKEN=sbp_...
   ```
2. Run (default path to your Downloads adminsdk file):
   ```powershell
   .\scripts\setup-fcm-push.ps1
   ```
3. Complete Dashboard steps printed at the end (cron schedule if not using Supabase Schedules UI during setup).

Individual scripts:

| Script | Purpose |
|--------|---------|
| `scripts\set-fcm-service-account-secret.ps1` | Upload Admin SDK JSON |
| `scripts\deploy-challenge-push-functions.ps1` | Deploy send + dispatch functions |
| `scripts\apply-migration-007.ps1` | Apply streak kind migration |
| `scripts\setup-dispatch-cron.ps1` | Schedule pg_cron dispatch every 10 min |
| `tools\test-challenge-push-dispatch.ps1` | Manually trigger dispatch (testing) |
| `tools\diagnose-push.ps1` | Re-upload secret, deploy, dispatch test with error details |
| `tools\verify-push-readiness.ps1` | Functions + token/job counts + dispatch smoke test |

---

## Manual Dashboard setup

If CLI returns 403 or “Access token not provided”:

1. **Secret:** [Edge Functions → Secrets](https://supabase.com/dashboard/project/qmivgvctmxvpnbouqslj/functions/secrets) → `FCM_SERVICE_ACCOUNT_JSON` → paste full `verified-glam-firebase-adminsdk-fbsvc-0e18943006.json`.
2. **Deploy:** Use CLI after login, or deploy from Dashboard if available to your role.
3. **Migration:** SQL Editor → run [`007_notification_streak_kind.sql`](../supabase/migrations/007_notification_streak_kind.sql).
4. **Cron:** Run `.\scripts\setup-dispatch-cron.ps1` (or Dashboard → `dispatch-challenge-notifications` → every 10 minutes).

---

## Device test matrix

| Step | Expected |
|------|----------|
| Run app with Supabase defines | See [`SUPABASE_SETUP.md`](SUPABASE_SETUP.md) |
| Sign in, allow notifications | Row in `device_push_tokens` with `is_active = true` |
| Mark challenge day done | Jobs in `challenge_notification_jobs` with `status = pending` |
| Run dispatch (cron or `tools\test-challenge-push-dispatch.ps1`) | Jobs → `sent`, notification on device |
| Tap unlock push | Opens day task (`/challenge/dayN`) |
| Final day complete | Completion push → reward screen |

**Quick test:** In SQL Editor, set one job’s `scheduled_for` to `now() - interval '1 minute'`, then invoke dispatch.

---

## Production and Play Store (no MCP at runtime)

The shipped app does **not** use Cursor MCP or `SUPABASE_ACCESS_TOKEN`.

| What | Where in production |
|------|---------------------|
| Supabase API | `SUPABASE_URL` + `SUPABASE_ANON_KEY` baked in at build via `--dart-define` |
| FCM client | [`android/app/google-services.json`](../android/app/google-services.json) in the APK |
| FCM server send | `FCM_SERVICE_ACCOUNT_JSON` in **Supabase Edge Function secrets** (set once during setup) |
| Job dispatch | Supabase **cron** on `dispatch-challenge-notifications` (every 10 min) |

**Release build** (same defines as dev):

```powershell
.\scripts\build-release-apk.ps1              # Play Store app bundle
.\scripts\build-release-apk.ps1 -Target apk  # release APK for sideload test
```

**Dev-only on your PC:** `SUPABASE_ACCESS_TOKEN` in `.env` runs `setup-fcm-push.ps1` / deploy scripts. Safe if `.env` stays gitignored; never put this token in Flutter code or `mcp.json` as a committed literal.

Pre-flight:

```powershell
.\scripts\check-supabase-cli-ready.ps1
.\scripts\validate-fcm-credentials.ps1
```

One-time backend setup (after token in `.env`):

```powershell
.\scripts\setup-fcm-push.ps1
.\scripts\apply-migration-007.ps1
```

Or pass token without saving to `.env`:

```powershell
.\scripts\setup-fcm-push.ps1 -AccessToken 'sbp_...'
```

---

## Cron (required for automatic push)

[Dashboard → dispatch-challenge-notifications → Schedules](https://supabase.com/dashboard/project/qmivgvctmxvpnbouqslj/functions) → **every 10 minutes**.

Until cron exists, run `.\tools\test-challenge-push-dispatch.ps1` after jobs are due.

---

## Device test (step by step)

1. Uncomment and set `SUPABASE_ACCESS_TOKEN` in `.env`, then run `.\scripts\setup-fcm-push.ps1` (or complete Manual Dashboard setup above).
2. Schedule cron (above).
3. `.\scripts\run-dev.ps1` on a **physical** Android device (emulator FCM is unreliable).
4. Sign in → allow notifications when prompted.
5. Supabase **Table Editor** → `device_push_tokens`: your user has `is_active = true`.
6. Complete a challenge day (**Mark as done**).
7. **Table Editor** → `challenge_notification_jobs`: rows with `status = pending`.
8. Fast test: SQL Editor → `update challenge_notification_jobs set scheduled_for = now() - interval '1 minute' where status = 'pending' limit 1;`
9. `.\tools\test-challenge-push-dispatch.ps1` → expect HTTP 200 and jobs → `sent`.
10. Notification appears on phone; tap opens day task or reward screen.

---

## Security

Rotate the Firebase service account key if the JSON was ever shared. Never commit `*firebase-adminsdk*.json`.
