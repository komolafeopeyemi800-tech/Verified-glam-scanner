-- Evening streak fallback (spec §4.3 — 7 PM if earlier reminder not acted on).

alter table public.challenge_notification_jobs
  drop constraint if exists challenge_notification_jobs_kind_check;

alter table public.challenge_notification_jobs
  add constraint challenge_notification_jobs_kind_check
  check (kind in ('unlock', 'streak', 'evening', 'reminder', 'completion'));
