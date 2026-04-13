import React, { useEffect, useState } from 'react';
import { Alert, FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { supabase } from '../../../lib/supabase';
import { useLocalization } from '../../../localization/LocalizationProvider';

type PodcastRow = { id: string; name: string; created_at: string };
type ProfileRow = { id: string; is_admin: boolean };

export function AdminScreen(): React.JSX.Element {
  const { t } = useLocalization();
  const [isAdmin, setIsAdmin] = useState(false);
  const [podcasts, setPodcasts] = useState<PodcastRow[]>([]);
  const [profiles, setProfiles] = useState<ProfileRow[]>([]);

  const load = async (): Promise<void> => {
    const { data: auth } = await supabase.auth.getUser();
    if (!auth.user) return;

    const { data: profile } = await supabase.from('profiles').select('is_admin').eq('id', auth.user.id).single();
    const admin = profile?.is_admin === true;
    setIsAdmin(admin);
    if (!admin) return;

    const [podcastResult, profileResult] = await Promise.all([
      supabase.from('podcasts').select('id,name,created_at').order('created_at', { ascending: false }),
      supabase.from('profiles').select('id,is_admin').order('created_at', { ascending: false }),
    ]);

    setPodcasts((podcastResult.data ?? []) as PodcastRow[]);
    setProfiles((profileResult.data ?? []) as ProfileRow[]);
  };

  useEffect(() => {
    load().catch((e) => Alert.alert('Error', String(e.message ?? e)));
  }, []);

  const deletePodcast = async (podcastId: string): Promise<void> => {
    await supabase.from('podcasts').delete().eq('id', podcastId);
    await load();
  };

  const toggleAdmin = async (profileId: string, admin: boolean): Promise<void> => {
    await supabase.from('profiles').update({ is_admin: !admin }).eq('id', profileId);
    await load();
  };

  if (!isAdmin) {
    return <View style={styles.center}><Text style={styles.warning}>{t('adminAccessRequired')}</Text></View>;
  }

  return (
    <FlatList
      style={styles.list}
      data={podcasts}
      keyExtractor={(item) => item.id}
      ListHeaderComponent={
        <View style={styles.headerBlock}>
          <Text style={styles.sectionTitle}>{t('userManagement')}</Text>
          {profiles.map((profile) => (
            <View style={styles.row} key={profile.id}>
              <Text style={styles.name}>{profile.id.slice(0, 8)}...</Text>
              <Pressable style={styles.toggleBtn} onPress={() => toggleAdmin(profile.id, profile.is_admin)}>
                <Text style={styles.buttonText}>{profile.is_admin ? t('revokeAdmin') : t('makeAdmin')}</Text>
              </Pressable>
            </View>
          ))}
          <Text style={styles.sectionTitle}>{t('christianPodcastManagement')}</Text>
        </View>
      }
      renderItem={({ item }) => (
        <View style={styles.row}>
          <View>
            <Text style={styles.name}>{item.name}</Text>
            <Text style={styles.date}>{new Date(item.created_at).toLocaleString()}</Text>
          </View>
          <Pressable style={styles.deleteBtn} onPress={() => deletePodcast(item.id)}>
            <Text style={styles.buttonText}>{t('delete')}</Text>
          </Pressable>
        </View>
      )}
    />
  );
}

const styles = StyleSheet.create({
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#fff' },
  warning: { color: '#b91c1c', fontWeight: '700' },
  list: { flex: 1, backgroundColor: '#fff' },
  headerBlock: { paddingTop: 8 },
  sectionTitle: { fontSize: 16, fontWeight: '700', marginVertical: 8, paddingHorizontal: 12 },
  row: { padding: 12, borderBottomWidth: 1, borderColor: '#eee', flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  name: { fontWeight: '700', maxWidth: '70%' },
  date: { color: '#666', marginTop: 2 },
  deleteBtn: { backgroundColor: '#dc2626', borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8 },
  toggleBtn: { backgroundColor: '#2563eb', borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8 },
  buttonText: { color: '#fff', fontWeight: '700' },
});
