-- Allow streak reminder jobs and index for daily send cap queries.

alter table public.challenge_notification_jobs
  drop constraint if exists challenge_notification_jobs_kind_check;

alter table public.challenge_notification_jobs
  add constraint challenge_notification_jobs_kind_check
  check (kind in ('unlock', 'streak', 'reminder', 'completion'));

create index if not exists idx_challenge_notification_jobs_sent_daily
  on public.challenge_notification_jobs (user_id, challenge_id, sent_at)
  where status = 'sent';
