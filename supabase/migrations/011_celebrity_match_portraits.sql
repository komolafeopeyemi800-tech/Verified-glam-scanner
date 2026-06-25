-- Public bucket for cached celebrity match portrait thumbnails (TMDB URLs or generated fallbacks).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'celebrity-match-portraits',
  'celebrity-match-portraits',
  true,
  524288,
  array['image/png', 'image/jpeg', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Public read celebrity match portraits" on storage.objects;
create policy "Public read celebrity match portraits"
on storage.objects for select
using (bucket_id = 'celebrity-match-portraits');
