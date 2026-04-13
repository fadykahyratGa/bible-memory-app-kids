import React, { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { Session } from '@supabase/supabase-js';
import { LibraryScreen } from './src/screens/LibraryScreen';
import { EpisodesScreen } from './src/screens/EpisodesScreen';
import { SearchScreen } from './src/screens/SearchScreen';
import { AdminScreen } from './src/screens/AdminScreen';
import { AuthScreen } from './src/screens/AuthScreen';
import { supabase } from './src/lib/supabase';

export type RootStackParamList = {
  Auth: undefined;
  Library: undefined;
  Episodes: { podcastId: string; podcastName: string };
  Search: undefined;
  Admin: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App(): React.JSX.Element {
  const [session, setSession] = useState<Session | null>(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => setSession(data.session ?? null));

    const { data: subscription } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      setSession(nextSession);
    });

    return () => subscription.subscription.unsubscribe();
  }, []);

  return (
    <NavigationContainer>
      <Stack.Navigator>
        {session ? (
          <>
            <Stack.Screen name="Library" component={LibraryScreen} options={{ title: 'Christian Podcast Library' }} />
            <Stack.Screen name="Episodes" component={EpisodesScreen} />
            <Stack.Screen name="Search" component={SearchScreen} />
            <Stack.Screen name="Admin" component={AdminScreen} />
          </>
        ) : (
          <Stack.Screen name="Auth" component={AuthScreen} options={{ headerShown: false }} />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}
