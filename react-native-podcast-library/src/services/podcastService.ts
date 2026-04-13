import { supabase } from '../lib/supabase';

export type Podcast = {
  id: string;
  name: string;
  icon_url: string | null;
  podbean_url: string;
  episode_count: number;
};

const PODBEAN_PREFIX = 'https://www.podbean.com/podcast-detail/';
const CHRISTIAN_KEYWORDS = [
  'christ',
  'christian',
  'bible',
  'gospel',
  'church',
  'jesus',
  'faith',
  'sermon',
  'worship',
  'ministry',
];

export function isValidPodbeanPodcastUrl(url: string): boolean {
  return url.startsWith(PODBEAN_PREFIX);
}

export function isLikelyChristianPodcast(name: string): boolean {
  const normalized = name.toLowerCase();
  return CHRISTIAN_KEYWORDS.some((keyword) => normalized.includes(keyword));
}

export async function fetchFavoritePodcasts(userId: string): Promise<Podcast[]> {
  const { data, error } = await supabase
    .from('favorite_podcasts')
    .select('podcasts(id,name,icon_url,podbean_url)')
    .eq('user_id', userId);

  if (error) throw error;

  const podcasts = (data ?? []).flatMap((row: any) => (row.podcasts ? [row.podcasts] : []));

  const withCounts = await Promise.all(
    podcasts.map(async (podcast: Omit<Podcast, 'episode_count'>) => {
      const { count } = await supabase
        .from('episodes')
        .select('id', { count: 'exact', head: true })
        .eq('podcast_id', podcast.id);

      return { ...podcast, episode_count: count ?? 0 };
    }),
  );

  return withCounts;
}

export async function addFavoritePodcast(userId: string, podbeanUrl: string): Promise<void> {
  if (!isValidPodbeanPodcastUrl(podbeanUrl)) {
    throw new Error(`URL must start with ${PODBEAN_PREFIX}`);
  }

  const scrapeResult = await supabase.functions.invoke('scrape-podcast', {
    body: { podbeanUrl },
  });

  if (scrapeResult.error || !scrapeResult.data) {
    throw new Error(scrapeResult.error?.message ?? 'Unable to scrape podcast page');
  }

  const { podcast, episodes } = scrapeResult.data as {
    podcast: Omit<Podcast, 'episode_count'>;
    episodes: Array<{ title: string; published_at: string; episode_url: string; icon_url: string | null }>;
  };

  if (!isLikelyChristianPodcast(podcast.name)) {
    throw new Error('Only Christian podcasts are allowed in this app.');
  }

  const { error: podcastUpsertError } = await supabase.from('podcasts').upsert(podcast);
  if (podcastUpsertError) throw podcastUpsertError;

  const { error: favoriteError } = await supabase
    .from('favorite_podcasts')
    .upsert({ user_id: userId, podcast_id: podcast.id });
  if (favoriteError) throw favoriteError;

  if (episodes.length > 0) {
    const { error: episodeError } = await supabase.from('episodes').upsert(
      episodes.map((ep) => ({ ...ep, podcast_id: podcast.id })),
      { onConflict: 'episode_url' },
    );
    if (episodeError) throw episodeError;
  }
}

export async function removeFavoritePodcast(userId: string, podcastId: string): Promise<void> {
  const { error } = await supabase
    .from('favorite_podcasts')
    .delete()
    .eq('user_id', userId)
    .eq('podcast_id', podcastId);
  if (error) throw error;
}
