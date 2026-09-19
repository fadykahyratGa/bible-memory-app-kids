import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:bible_memory_app_kids/features/auth/data/auth_repository.dart';
import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/core/localization/app_localizations.dart';
import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';
import 'package:bible_memory_app_kids/features/game/data/game_repository.dart';
import 'package:bible_memory_app_kids/features/game/presentation/game_screen.dart';
import 'package:bible_memory_app_kids/features/game/providers/game_providers.dart';
import 'package:bible_memory_app_kids/features/rooms/data/room_repository.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_enums.dart';
import 'package:bible_memory_app_kids/features/rooms/providers/room_providers.dart';
import 'package:bible_memory_app_kids/features/profile/data/profile_repository.dart';

void main() {
  testWidgets('navigates to results when game state becomes finished', (tester) async {
    final controller = StreamController<GameSession?>();
    addTearDown(controller.close);

    final fakeSession = _FakeSessionController();
    final router = GoRouter(
      initialLocation: '/room/room-1/game',
      routes: [
        GoRoute(
          path: '/room/:roomId/game',
          builder: (context, state) => MultiplayerGameScreen(roomId: state.pathParameters['roomId']!),
        ),
        GoRoute(
          path: '/room/:roomId/results',
          builder: (context, state) => const Scaffold(body: Text('results-screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith((ref) => fakeSession),
          roomProvider('room-1').overrideWith((ref) => Stream.value(const Room(
                id: 'room-1',
                code: 'ABCDE',
                hostUserId: 'host-1',
                gameMode: RoomGameMode.individual,
                judgeMode: RoomJudgeMode.none,
                status: RoomStatus.playing,
                isPrivate: true,
              ))),
          roomPlayersProvider('room-1').overrideWith((ref) => Stream.value(const [])),
          activeGameProvider('room-1').overrideWith((ref) => controller.stream),
          currentChallengeProvider('room-1').overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    controller.add(const GameSession(
      id: 'game-1',
      roomId: 'room-1',
      state: MultiplayerGameState.playing,
      currentRoundOrder: 1,
      currentChallengeOrder: 1,
    ));
    await tester.pump();

    controller.add(const GameSession(
      id: 'game-1',
      roomId: 'room-1',
      state: MultiplayerGameState.gameResults,
      currentRoundOrder: 1,
      currentChallengeOrder: 2,
    ));
    await tester.pumpAndSettle();

    expect(find.text('results-screen'), findsOneWidget);
  });

  testWidgets('submits canonical true-false answers in English locale', (tester) async {
    final fakeSession = _FakeSessionController();
    final fakeGameRepository = _FakeGameRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith((ref) => fakeSession),
          gameRepositoryProvider.overrideWithValue(fakeGameRepository),
          roomProvider('room-1').overrideWith((ref) => Stream.value(const Room(
                id: 'room-1',
                code: 'ABCDE',
                hostUserId: 'host-1',
                gameMode: RoomGameMode.individual,
                judgeMode: RoomJudgeMode.none,
                status: RoomStatus.playing,
                isPrivate: true,
              ))),
          roomPlayersProvider('room-1').overrideWith((ref) => Stream.value(const [])),
          activeGameProvider('room-1').overrideWith((ref) => Stream.value(const GameSession(
                id: 'game-1',
                roomId: 'room-1',
                state: MultiplayerGameState.playing,
                currentRoundOrder: 1,
                currentChallengeOrder: 1,
              ))),
          currentChallengeProvider('room-1').overrideWith((ref) => Stream.value(const GameChallenge(
                id: 'challenge-1',
                roundId: 'round-1',
                challengeOrder: 1,
                type: ChallengeType.trueFalse,
                prompt: 'True or false?',
                correctAnswer: 'صح',
                points: 10,
                options: ['صح', 'خطأ'],
              ))),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MultiplayerGameScreen(roomId: 'room-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('True'));
    await tester.pump();
    await tester.tap(find.text('Submit answer'));
    await tester.pump();

    expect(fakeGameRepository.submittedAnswer, 'صح');
  });
}

class _FakeSessionController extends AppSessionController {
  _FakeSessionController()
      : super(
          authRepository: AuthRepository(null),
          profileRepository: ProfileRepository(null),
          roomRepository: RoomRepository(null),
        );

  @override
  Future<void> bootstrap() async {}

  @override
  bool get isLoading => false;
}

class _FakeGameRepository extends GameRepository {
  _FakeGameRepository() : super(null);

  String? submittedAnswer;

  @override
  Future<void> submitAnswer({required String roomId, required String challengeId, required String answer}) async {
    submittedAnswer = answer;
  }
}
