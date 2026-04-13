# My Podcast Library (React Native + Supabase)

This folder contains a React Native (Expo) starter for the **My Podcast Library** project with a **Christian podcast focus**:

- Favorite podcast management
- Email/password login and registration
- Most recent episode list per podcast
- Per-user episode favorites, ratings, and hashtags
- Search by hashtags across your own saved episode metadata
- Admin panel for managing podcasts and profiles
- Supabase-backed persistence + RLS

> The app accepts only Christian podcasts when adding new Podbean URLs (validated from scraped podcast name keywords).

## Why scraping runs in Supabase

Puppeteer does not run directly on React Native devices. Instead, scraping is delegated to a Supabase Edge Function (or another backend worker) that:

1. Validates Podbean URLs
2. Scrapes podcast details and recent episodes
3. Returns normalized JSON
4. Persists records in Supabase

The mobile app only calls secure endpoints.

## Quick start

1. Create `.env` based on `.env.example`.
2. Install deps in this folder:
   ```bash
   npm install
   ```
3. Start the app:
   ```bash
   npm run start
   ```
4. Apply SQL schema in `supabase/schema.sql`.
5. Deploy an edge function at `/functions/v1/scrape-podcast`.

## Admin user

Set `profiles.is_admin = true` for the user in Supabase to unlock admin UI.

## Extra features added

- Remove podcast from favorites directly in the main list.
- Episode rows sorted with favorites first, then higher-rated items, then recent publish date.
- Search screen includes a Cancel button to return to main flow.
