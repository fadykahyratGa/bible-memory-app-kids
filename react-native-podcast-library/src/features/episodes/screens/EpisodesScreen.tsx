import React, { useCallback, useEffect, useState } from 'react';
import { Alert, FlatList, Linking, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../../../App';
import { supabase } from '../../../lib/supabase';
import { EpisodeWithMeta, fetchEpisodesWithMeta, upsertEpisodeMeta } from '../../../services/episodeService';

type Props = NativeStackScreenProps<RootStackParamList, 'Episodes'>;

export function EpisodesScreen({ route }: Props): React.JSX.Element {
  const { podcastId } = route.params;
  const [episodes, setEpisodes] = useState<EpisodeWithMeta[]>([]);

  const loadEpisodes = useCallback(async (): Promise<void> => {
    const { data: auth } = await supabase.auth.getUser();
    if (!auth.user) return;

    const rows = await fetchEpisodesWithMeta(auth.user.id, podcastId);
    setEpisodes(rows);
  }, [podcastId]);

  useEffect(() => {
    loadEpisodes().catch((e) => Alert.alert('Error', String(e.message ?? e)));
  }, [loadEpisodes]);

  const updateEpisode = async (episodeId: string, patch: Partial<EpisodeWithMeta>): Promise<void> => {
    const { data: auth } = await supabase.auth.getUser();
    if (!auth.user) return;

    await upsertEpisodeMeta(auth.user.id, episodeId, patch);
    await loadEpisodes();
  };

  return (
    <FlatList
      style={styles.list}
      data={episodes}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => (
        <View style={styles.row}>
          <Pressable onPress={() => Linking.openURL(item.episode_url)}>
            <Text style={styles.linkIcon}>🔗</Text>
          </Pressable>
          <View style={styles.main}>
            <Text style={styles.title}>{item.title}</Text>
            <Text style={styles.meta}>{new Date(item.published_at).toDateString()}</Text>
            <TextInput
              style={styles.tagInput}
              defaultValue={item.hashtag ?? ''}
              placeholder="#hashtag"
              onEndEditing={(e) => updateEpisode(item.id, { hashtag: e.nativeEvent.text.trim() })}
            />
            <View style={styles.starRow}>
              {[1, 2, 3, 4, 5].map((star) => (
                <Pressable key={star} onPress={() => updateEpisode(item.id, { rating: star })}>
                  <Text style={styles.star}>{item.rating >= star ? '★' : '☆'}</Text>
                </Pressable>
              ))}
              <Pressable onPress={() => updateEpisode(item.id, { is_favorite: !item.is_favorite })}>
                <Text style={styles.heart}>{item.is_favorite ? '❤️' : '🤍'}</Text>
              </Pressable>
            </View>
          </View>
        </View>
      )}
    />
  );
}

const styles = StyleSheet.create({
  list: { backgroundColor: '#fff' },
  row: { flexDirection: 'row', padding: 10, borderBottomWidth: 1, borderColor: '#eee' },
  linkIcon: { fontSize: 22, marginRight: 10, marginTop: 4 },
  main: { flex: 1 },
  title: { fontSize: 15, fontWeight: '600' },
  meta: { color: '#666', marginTop: 2, marginBottom: 4 },
  tagInput: { borderWidth: 1, borderColor: '#ddd', borderRadius: 8, paddingHorizontal: 8, paddingVertical: 6 },
  starRow: { flexDirection: 'row', alignItems: 'center', marginTop: 6, gap: 4 },
  star: { fontSize: 22, color: '#f59e0b' },
  heart: { fontSize: 22, marginLeft: 8 },
});
