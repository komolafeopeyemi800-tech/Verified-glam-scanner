-- Reset failed challenge push jobs so dispatch can retry after FCM token is registered.
-- Run in Supabase Dashboard -> SQL Editor after device_push_tokens has an active row.

update public.challenge_notification_jobs
set
  status = 'pending',
  scheduled_for = now(),
  updated_at = now()
where status = 'failed';

-- Verify tokens exist:
-- select user_id, left(fcm_token, 16) as token_prefix, is_active, last_seen_at
-- from public.device_push_tokens
-- where is_active = true
-- order by last_seen_at desc;
