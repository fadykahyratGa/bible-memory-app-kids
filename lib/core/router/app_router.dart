import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bible_memory_app_kids/features/app/presentation/splash_screen.dart';
import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/game/presentation/game_screen.dart';
import 'package:bible_memory_app_kids/features/game/presentation/results_screen.dart';
import 'package:bible_memory_app_kids/features/home/presentation/multiplayer_home_screen.dart';
import 'package:bible_memory_app_kids/features/profile/presentation/profile_setup_screen.dart';
import 'package:bible_memory_app_kids/features/rooms/presentation/create_room_screen.dart';
import 'package:bible_memory_app_kids/features/rooms/presentation/join_room_screen.dart';
import 'package:bible_memory_app_kids/features/rooms/presentation/lobby_screen.dart';
import 'package:bible_memory_app_kids/ui/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: session,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (session.isLoading) {
        return location == '/' ? null : '/';
      }
      if (session.error != null) {
        return location == '/' ? null : '/';
      }
      if (session.needsProfile) {
        return location == '/profile-setup' ? null : '/profile-setup';
      }
      if (location == '/' || location == '/profile-setup') {
        return session.restoreLocation ?? '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/profile-setup', builder: (context, state) => const ProfileSetupScreen()),
      GoRoute(path: '/home', builder: (context, state) => const MultiplayerHomeScreen()),
      GoRoute(path: '/room/create', builder: (context, state) => const CreateRoomScreen()),
      GoRoute(path: '/room/join', builder: (context, state) => const JoinRoomScreen()),
      GoRoute(
        path: '/room/:roomId/lobby',
        builder: (context, state) => LobbyScreen(roomId: state.pathParameters['roomId']!),
      ),
      GoRoute(
        path: '/room/:roomId/game',
        builder: (context, state) => MultiplayerGameScreen(roomId: state.pathParameters['roomId']!),
      ),
      GoRoute(
        path: '/room/:roomId/results',
        builder: (context, state) => ResultsScreen(roomId: state.pathParameters['roomId']!),
      ),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
});
