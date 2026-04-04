import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { LibraryScreen } from './src/screens/LibraryScreen';
import { EpisodesScreen } from './src/screens/EpisodesScreen';
import { SearchScreen } from './src/screens/SearchScreen';
import { AdminScreen } from './src/screens/AdminScreen';

export type RootStackParamList = {
  Library: undefined;
  Episodes: { podcastId: string; podcastName: string };
  Search: undefined;
  Admin: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App(): React.JSX.Element {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Library" component={LibraryScreen} options={{ title: 'Christian Podcast Library' }} />
        <Stack.Screen name="Episodes" component={EpisodesScreen} />
        <Stack.Screen name="Search" component={SearchScreen} />
        <Stack.Screen name="Admin" component={AdminScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
