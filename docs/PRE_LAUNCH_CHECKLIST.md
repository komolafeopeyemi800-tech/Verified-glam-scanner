# Pre-launch checklist (Verified Glam)

Maps spec §35 and Parts 4–7 to repo verification steps.

## Technical

| Item | How to verify | Status |
|------|----------------|--------|
| All 10 scan features E2E | `.\tools\e2e-test-supabase.ps1` | Run before release |
| OpenAI JSON per feature | E2E + phone matrix on TECNO | Manual |
| Structured error codes | `analyze-scan` returns `errorCode`; processing shows retry dialog | Implemented |
| Ads free vs Pro | Phase 7 RevenueCat (mock store today) | Pending Phase 7 |
| Subscription purchase/restore | Phase 7 | Pending Phase 7 |
| Challenge push (4 kinds) | `.\tools\verify-push-readiness.ps1` + `.\tools\test-send-push.ps1` | Ops + device |
| Cron dispatch every 10 min | Supabase Dashboard → `dispatch-challenge-notifications` | Manual |
| Migrations 005–008 applied | SQL Editor or `db push` | Manual |
| RLS on user tables | Migrations 001–006 | Done in repo |

## Push (Part 4)

| Item | Status |
|------|--------|
| FCM HTTP v1 (`FCM_SERVICE_ACCOUNT_JSON`) | Implemented |
| `notification_pref_time` wired to streak scheduling | Implemented |
| Daily cap = 2 with defer (not cancel) | Implemented |
| Deep links `/challenge/dayN`, `/challenge/reward` | Implemented |

## Challenge UX (Parts 5–7)

| Item | Status |
|------|--------|
| Mark done + countdown sheet | Done |
| Share progress (PNG + text fallback) | Implemented |
| Reward card + badges | Done |
| `best_streak` in UI | Implemented |

## Security (§33)

| Item | Status |
|------|--------|
| OpenAI key server-only | Done |
| Client 5 MB upload guard | Implemented |
| Storage bucket limits (008) | Migration added |
| Profile input sanitized on upsert | Implemented |

## Analytics (§34)

| Event | Trigger |
|-------|---------|
| `scan_started` / `scan_completed` / `scan_failed` | Processing screen |
| `challenge_day_completed` | Mark done |
| `push_opened` | Notification tap |
| `onboarding_completed` | Onboarding finish |
| `paywall_shown` | Wire in Phase 7 |

## Play Store (Phase 8)

- [ ] App icon, feature graphic, screenshots
- [ ] Privacy policy + terms URLs in settings
- [ ] Internal testing track upload
- [ ] QA matrix: onboarding → scan → results → challenge → push

## Quick smoke (phone)

1. Sign in → allow notifications → confirm `device_push_tokens` row
2. Run Beauty Tips scan → retry dialog on airplane mode
3. Mark challenge day done → share PNG
4. `.\tools\test-send-push.ps1` → notification on device
