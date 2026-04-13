import React, { useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../../../App';
import { supabase } from '../../../lib/supabase';
import { useLocalization } from '../../../localization/LocalizationProvider';

type Props = NativeStackScreenProps<RootStackParamList, 'Search'>;
type SearchResult = { id: string; title: string; hashtag: string | null; rating: number };

export function SearchScreen({ navigation }: Props): React.JSX.Element {
  const { t } = useLocalization();
  const [tag, setTag] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);

  const onSearch = async (): Promise<void> => {
    const normalized = tag.trim().replace(/^#/, '');
    const { data: auth } = await supabase.auth.getUser();
    if (!auth.user || !normalized) {
      setResults([]);
      return;
    }

    const { data } = await supabase
      .from('episode_user_meta')
      .select('rating,hashtag,episodes(id,title)')
      .eq('user_id', auth.user.id)
      .ilike('hashtag', `%${normalized}%`)
      .order('rating', { ascending: false });

    const mapped = (data ?? []).flatMap((row: any) =>
      row.episodes
        ? [{ id: row.episodes.id as string, title: row.episodes.title as string, hashtag: row.hashtag as string | null, rating: row.rating as number }]
        : [],
    );

    setResults(mapped);
  };

  return (
    <View style={styles.container}>
      <View style={styles.row}>
        <TextInput style={styles.input} value={tag} onChangeText={setTag} placeholder="#bible #technology" />
        <Pressable style={styles.button} onPress={onSearch}><Text style={styles.buttonText}>{t('search')}</Text></Pressable>
      </View>

      <FlatList
        data={results}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text style={styles.title}>{item.title}</Text>
            <Text style={styles.tag}>#{item.hashtag} · {item.rating}★</Text>
          </View>
        )}
      />

      <Pressable style={[styles.button, styles.cancel]} onPress={() => navigation.goBack()}><Text style={styles.buttonText}>{t('cancel')}</Text></Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, backgroundColor: '#fff' },
  row: { flexDirection: 'row', gap: 8, marginBottom: 12 },
  input: { flex: 1, borderWidth: 1, borderColor: '#ddd', borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8 },
  button: { backgroundColor: '#2f6fed', borderRadius: 8, paddingHorizontal: 12, justifyContent: 'center', minHeight: 42 },
  buttonText: { color: '#fff', fontWeight: '700' },
  card: { paddingVertical: 10, borderBottomWidth: 1, borderColor: '#eee' },
  title: { fontWeight: '600' },
  tag: { color: '#666' },
  cancel: { marginTop: 10, alignItems: 'center' },
});
