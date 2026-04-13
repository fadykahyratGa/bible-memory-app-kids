import { supabase } from '../lib/supabase';

export type EpisodeBase = {
  id: string;
  podcast_id: string;
  title: string;
  published_at: string;
  episode_url: string;
  icon_url: string | null;
};

export type EpisodeMeta = {
  episode_id: string;
  is_favorite: boolean;
  rating: number;
  hashtag: string | null;
};

export type EpisodeWithMeta = EpisodeBase & EpisodeMeta;

export async function fetchEpisodesWithMeta(userId: string, podcastId: string): Promise<EpisodeWithMeta[]> {
  const { data: episodes, error: episodesError } = await supabase
    .from('episodes')
    .select('id,podcast_id,title,published_at,episode_url,icon_url')
    .eq('podcast_id', podcastId)
    .order('published_at', { ascending: false });

  if (episodesError) throw episodesError;

  const ids = (episodes ?? []).map((e) => e.id);
  if (ids.length === 0) return [];

  const { data: metas, error: metaError } = await supabase
    .from('episode_user_meta')
    .select('episode_id,is_favorite,rating,hashtag')
    .eq('user_id', userId)
    .in('episode_id', ids);

  if (metaError) throw metaError;

  const metaByEpisodeId = new Map((metas ?? []).map((m) => [m.episode_id, m]));

  return (episodes ?? [])
    .map((episode) => {
      const meta = metaByEpisodeId.get(episode.id);
      return {
        ...episode,
        episode_id: episode.id,
        is_favorite: meta?.is_favorite ?? false,
        rating: meta?.rating ?? 0,
        hashtag: meta?.hashtag ?? null,
      };
    })
    .sort((a, b) => {
      if (a.is_favorite !== b.is_favorite) return a.is_favorite ? -1 : 1;
      if (b.rating !== a.rating) return b.rating - a.rating;
      return new Date(b.published_at).getTime() - new Date(a.published_at).getTime();
    });
}

export async function upsertEpisodeMeta(userId: string, episodeId: string, patch: Partial<EpisodeMeta>): Promise<void> {
  const { data: existing } = await supabase
    .from('episode_user_meta')
    .select('is_favorite,rating,hashtag')
    .eq('user_id', userId)
    .eq('episode_id', episodeId)
    .maybeSingle();

  const payload = {
    user_id: userId,
    episode_id: episodeId,
    is_favorite: patch.is_favorite ?? existing?.is_favorite ?? false,
    rating: patch.rating ?? existing?.rating ?? 0,
    hashtag: patch.hashtag ?? existing?.hashtag ?? null,
  };

  const { error } = await supabase.from('episode_user_meta').upsert(payload);
  if (error) throw error;
}
