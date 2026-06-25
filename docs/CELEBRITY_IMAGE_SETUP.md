# Celebrity Look Alike — match portrait images

Live Celebrity Look Alike scans attach a portrait `imageUrl` to each match in the analysis payload. The Flutter app renders these in [`VGCelebrityMatchCard`](../lib/components/vg/results/vg_celebrity_match_card.dart).

## How it works

1. OpenAI returns celebrity names + similarity copy in the `analyze-scan` Edge Function.
2. **TMDB (primary):** If `TMDB_API_KEY` is set, each name is looked up via TMDB Person Search and `imageUrl` is set to `https://image.tmdb.org/t/p/w185{profile_path}`.
3. **Generated fallback:** Names still missing `imageUrl` get a DALL·E 2 portrait (256×256), uploaded to the public `celebrity-match-portraits` storage bucket, and cached by celebrity name slug. The function retries generation once on failure.

Mock/offline analysis uses bundled assets under `images/vg/mock/celebrities/`.

## Beauty Score Showdown avatars

Function version **7** also generates rival/member avatars for the showdown podium:

- **Simulated board** (&lt; 5 engaged users): DALL·E 2 portraits cached in `showdown-avatars` with realistic first names (Bella, Loveth, Amara, …).
- **Live board** (≥ 5 engaged users): ranks from `get_showdown_leaderboard()` using scans + challenge activity; avatars cached on `profiles.showdown_avatar_url`.

Apply migrations [`012_showdown_avatars.sql`](../supabase/migrations/012_showdown_avatars.sql) and [`013_showdown_engagement.sql`](../supabase/migrations/013_showdown_engagement.sql).

## Supabase setup

### 1. Apply migrations

Run in the SQL Editor (or `supabase db push`):

- [`supabase/migrations/011_celebrity_match_portraits.sql`](../supabase/migrations/011_celebrity_match_portraits.sql)
- [`supabase/migrations/012_showdown_avatars.sql`](../supabase/migrations/012_showdown_avatars.sql)
- [`supabase/migrations/013_showdown_engagement.sql`](../supabase/migrations/013_showdown_engagement.sql)

### 2. Edge Function secrets

| Secret | Required | Purpose |
|--------|----------|---------|
| `OPENAI_API_KEY` | Yes | Analysis + portrait fallbacks |
| `TMDB_API_KEY` | Recommended | Free TMDB v3 API key from [themoviedb.org](https://www.themoviedb.org/settings/api) |

```bash
supabase secrets set TMDB_API_KEY=your_tmdb_v3_key
```

### 3. Redeploy analyze-scan

```bash
supabase functions deploy analyze-scan
```

Function version **7** includes score normalization, celebrity portrait hardening, and hybrid showdown enrichment.

## Notes

- Existing scans in history keep their stored payload; re-run scans to get normalized scores and portraits.
- TMDB is preferred (faster, no extra OpenAI image cost). Generation runs only when TMDB has no `profile_path`.
- Portraits are cached in storage — the same celebrity name or showdown seed reuses the uploaded file.
