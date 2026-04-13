# scrape-podcast Edge Function contract

The mobile app expects this endpoint:

`POST /functions/v1/scrape-podcast`

Request body:
```json
{ "podbeanUrl": "https://www.podbean.com/podcast-detail/..." }
```

Response body:
```json
{
  "podcast": {
    "id": "podbean-slug-or-stable-id",
    "name": "Podcast Name",
    "icon_url": "https://...",
    "podbean_url": "https://www.podbean.com/podcast-detail/..."
  },
  "episodes": [
    {
      "title": "Episode title",
      "published_at": "2026-03-10T00:00:00.000Z",
      "episode_url": "https://...",
      "icon_url": "https://..."
    }
  ]
}
```

Implementation detail:
- Use Puppeteer in the Edge Function (or a worker service) for scraping Podbean.
- Return 404-style validation error when podcast page doesn't exist.
- Keep the response normalized so the mobile app can upsert `podcasts` and `episodes` safely.
- Include enough metadata (name/category/description) so the client can enforce Christian-podcast-only rules.

## Scheduled refresh endpoint

To support automatic scraping every 12 hours, add:

`POST /functions/v1/scrape-refresh`

This endpoint should:
- refresh all favorited podcast feeds (or a curated Christian list),
- upsert latest episodes,
- return a small summary payload (`updated_podcasts`, `updated_episodes`).

`supabase/schema.sql` includes a cron-based trigger plan for **00:00 UTC** and **12:00 UTC** daily.
