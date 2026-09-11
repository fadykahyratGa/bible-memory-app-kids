import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/guest_name_screen.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/lobby/presentation/screens/lobby_screen.dart';
import 'features/rooms/presentation/screens/create_room_screen.dart';
import 'features/rooms/presentation/screens/join_room_screen.dart';
import 'theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BibleMemoryApp extends ConsumerWidget {
  const BibleMemoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authChanges = ref.watch(authStateChangesProvider);

    final router = GoRouter(
      initialLocation: '/welcome',
      refreshListenable: GoRouterRefreshStream(authChanges),
      redirect: (context, state) {
        final authState = ref.read(authControllerProvider);
        final isAuthenticated = authState.isAuthenticated;
        final onAuthRoute = state.matchedLocation == '/welcome' ||
            state.matchedLocation == '/guest-name' ||
            state.matchedLocation == '/sign-in' ||
            state.matchedLocation == '/sign-up' ||
            state.matchedLocation == '/forgot-password';

        if (!isAuthenticated && !onAuthRoute) {
          return '/welcome';
        }

        if (isAuthenticated && onAuthRoute) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
        GoRoute(path: '/guest-name', builder: (context, state) => const GuestNameScreen()),
        GoRoute(path: '/sign-in', builder: (context, state) => const SignInScreen()),
        GoRoute(path: '/sign-up', builder: (context, state) => const SignUpScreen()),
        GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/create-room', builder: (context, state) => const CreateRoomScreen()),
        GoRoute(path: '/join-room', builder: (context, state) => const JoinRoomScreen()),
        GoRoute(
          path: '/lobby/:roomId',
          builder: (context, state) => LobbyScreen(roomId: state.pathParameters['roomId']!),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.buildTheme(GoogleFonts.cairoTextTheme()),
      routerConfig: router,
    );
  }
}
