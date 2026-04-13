import React, { useCallback, useEffect, useState } from 'react';
import { Alert, FlatList, Image, Modal, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../../App';
import { supabase } from '../lib/supabase';
import { addFavoritePodcast, fetchFavoritePodcasts, Podcast, removeFavoritePodcast } from '../services/podcastService';

type Props = NativeStackScreenProps<RootStackParamList, 'Library'>;

export function LibraryScreen({ navigation }: Props): React.JSX.Element {
  const [podcasts, setPodcasts] = useState<Podcast[]>([]);
  const [modalOpen, setModalOpen] = useState(false);
  const [url, setUrl] = useState('');

  const load = useCallback(async () => {
    const { data: auth } = await supabase.auth.getUser();
    if (!auth.user) return;
    const favorites = await fetchFavoritePodcasts(auth.user.id);
    setPodcasts(favorites);
  }, []);

  useEffect(() => {
    load().catch((error) => Alert.alert('Error', String(error.message ?? error)));
  }, [load]);

  const onSavePodcast = async (): Promise<void> => {
    const { data: auth } = await supabase.auth.getUser();
    if (!auth.user) {
      Alert.alert('Authentication', 'Please sign in first.');
      return;
    }

    try {
      await addFavoritePodcast(auth.user.id, url.trim());
      setUrl('');
      setModalOpen(false);
      await load();
    } catch (error: any) {
      Alert.alert('Invalid podcast URL', error.message ?? 'Could not add podcast.');
    }
  };

  const onRemovePodcast = async (podcastId: string): Promise<void> => {
    const { data: auth } = await supabase.auth.getUser();
    if (!auth.user) return;

    await removeFavoritePodcast(auth.user.id, podcastId);
    await load();
  };

  return (
    <View style={styles.container}>
      <View style={styles.actions}>
        <Pressable onPress={() => setModalOpen(true)} style={styles.button}>
          <Text style={styles.buttonText}>＋</Text>
        </Pressable>
        <Pressable onPress={() => navigation.navigate('Search')} style={styles.button}>
          <Text style={styles.buttonText}>Search</Text>
        </Pressable>
        <Pressable onPress={() => navigation.navigate('Admin')} style={styles.button}>
          <Text style={styles.buttonText}>Admin</Text>
        </Pressable>
        <Pressable onPress={() => supabase.auth.signOut()} style={styles.button}>
          <Text style={styles.buttonText}>Logout</Text>
        </Pressable>
      </View>

      {podcasts.length === 0 ? (
        <View style={styles.emptyState}>
          <Text style={styles.emptyText}>No podcasts added yet</Text>
        </View>
      ) : (
        <FlatList
          data={podcasts}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <View style={styles.row}>
              <Pressable
                style={styles.rowMain}
                onPress={() => navigation.navigate('Episodes', { podcastId: item.id, podcastName: item.name })}
              >
                {item.icon_url ? <Image source={{ uri: item.icon_url }} style={styles.icon} /> : <View style={styles.icon} />}
                <View style={styles.info}>
                  <Text style={styles.name}>{item.name}</Text>
                  <Text style={styles.count}>{item.episode_count} recent episodes</Text>
                </View>
              </Pressable>
              <Pressable onPress={() => onRemovePodcast(item.id)} style={styles.removeBtn}>
                <Text style={styles.removeText}>✕</Text>
              </Pressable>
            </View>
          )}
        />
      )}

      <Modal visible={modalOpen} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalCard}>
            <Text style={styles.modalTitle}>Add a new podcast</Text>
            <Text style={styles.modalHint}>Christian podcasts only (Bible, Gospel, Church, Sermon...)</Text>
            <TextInput
              style={styles.input}
              autoCapitalize="none"
              value={url}
              onChangeText={setUrl}
              placeholder="https://www.podbean.com/podcast-detail/..."
            />
            <View style={styles.modalActions}>
              <Pressable onPress={onSavePodcast} style={styles.button}>
                <Text style={styles.buttonText}>Save</Text>
              </Pressable>
              <Pressable onPress={() => setModalOpen(false)} style={styles.button}>
                <Text style={styles.buttonText}>Cancel</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, backgroundColor: '#fff' },
  actions: { flexDirection: 'row', gap: 8, marginBottom: 12 },
  button: { backgroundColor: '#2f6fed', borderRadius: 8, paddingVertical: 10, paddingHorizontal: 14 },
  buttonText: { color: '#fff', fontWeight: '700' },
  emptyState: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  emptyText: { color: '#a1a1aa', fontSize: 22, fontWeight: '700' },
  row: { flexDirection: 'row', alignItems: 'center', paddingVertical: 10, borderBottomWidth: 1, borderColor: '#eee' },
  rowMain: { flex: 1, flexDirection: 'row', alignItems: 'center' },
  info: { flex: 1 },
  icon: { width: 56, height: 56, borderRadius: 8, backgroundColor: '#ddd', marginRight: 10 },
  name: { fontSize: 16, fontWeight: '600', flex: 1 },
  count: { color: '#6b7280', marginTop: 2 },
  removeBtn: { backgroundColor: '#e5e7eb', width: 30, height: 30, borderRadius: 15, alignItems: 'center', justifyContent: 'center' },
  removeText: { color: '#111827', fontWeight: '700' },
  modalOverlay: { flex: 1, justifyContent: 'center', padding: 20, backgroundColor: 'rgba(0,0,0,0.3)' },
  modalCard: { backgroundColor: '#fff', borderRadius: 12, padding: 14 },
  modalTitle: { fontSize: 17, fontWeight: '700', marginBottom: 8 },
  modalHint: { color: '#6b7280', marginBottom: 8 },
  input: { borderWidth: 1, borderColor: '#ddd', borderRadius: 8, paddingHorizontal: 10, paddingVertical: 9 },
  modalActions: { flexDirection: 'row', marginTop: 12, gap: 8 },
});
