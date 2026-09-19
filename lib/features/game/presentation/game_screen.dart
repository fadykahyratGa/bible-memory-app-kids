import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';
import 'package:bible_memory_app_kids/core/localization/app_localizations.dart';
import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';
import 'package:bible_memory_app_kids/features/game/providers/game_providers.dart';
import 'package:bible_memory_app_kids/features/rooms/providers/room_providers.dart';
import 'package:bible_memory_app_kids/features/shared/presentation/background_scaffold.dart';
import 'package:bible_memory_app_kids/ui/widgets/primary_button.dart';
import 'package:bible_memory_app_kids/ui/widgets/rounded_panel.dart';

class MultiplayerGameScreen extends ConsumerStatefulWidget {
  const MultiplayerGameScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends ConsumerState<MultiplayerGameScreen> {
  String? _selectedAnswer;
  bool _submitting = false;
  late final ProviderSubscription<AsyncValue<GameChallenge?>> _challengeSubscription;
  late final ProviderSubscription<AsyncValue<GameSession?>> _gameSubscription;

  @override
  void initState() {
    super.initState();
    _challengeSubscription = ref.listenManual(currentChallengeProvider(widget.roomId), (previous, next) {
      final previousId = previous?.valueOrNull?.id;
      final nextId = next.valueOrNull?.id;
      if (nextId != null && nextId != previousId && _selectedAnswer != null && mounted) {
        setState(() => _selectedAnswer = null);
      }
    });
    _gameSubscription = ref.listenManual(activeGameProvider(widget.roomId), (previous, next) {
      next.whenData((game) {
        if (game == null) {
          return;
        }
        if (game.state == MultiplayerGameState.gameResults || game.state == MultiplayerGameState.finished) {
          context.go('/room/${widget.roomId}/results');
        }
      });
    });
  }

  @override
  void dispose() {
    _challengeSubscription.close();
    _gameSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final roomAsync = ref.watch(roomProvider(widget.roomId));
    final playersAsync = ref.watch(roomPlayersProvider(widget.roomId));
    final gameAsync = ref.watch(activeGameProvider(widget.roomId));
    final challengeAsync = ref.watch(currentChallengeProvider(widget.roomId));
    final currentUserId = ref.watch(sessionControllerProvider).user?.id;
    final activeGame = gameAsync.valueOrNull;

    return BackgroundScaffold(
      appBar: AppBar(title: Text(l10n.gameInProgress)),
      child: roomAsync.when(
        data: (room) {
          final isHost = room.hostUserId == currentUserId;
          final isAnsweringState = activeGame?.state == MultiplayerGameState.playing || activeGame?.state == MultiplayerGameState.answering;
          final challengeExpired = activeGame?.challengeEndsAt != null && DateTime.now().isAfter(activeGame!.challengeEndsAt!);
          final canAdvance = isHost && activeGame != null && (!isAnsweringState || challengeExpired);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              gameAsync.when(
                data: (game) => RoundedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.currentChallenge, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(_stateLabel(l10n, game?.state ?? MultiplayerGameState.waiting)),
                      if (game?.challengeEndsAt != null) ...[
                        const SizedBox(height: 4),
                        Text('${l10n.challengeEndsAt}: ${DateFormat.Hm(Localizations.localeOf(context).languageCode).format(game!.challengeEndsAt!.toLocal())}'),
                      ],
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(AppErrorMapper.map(error).userMessage),
              ),
              const SizedBox(height: 12),
              challengeAsync.when(
                data: (challenge) {
                  if (challenge == null) {
                    return RoundedPanel(child: Text(l10n.noChallengeYet));
                  }
                  final answerChoices = _answerChoices(challenge, l10n);
                  return RoundedPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(challenge.prompt, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        for (final choice in answerChoices)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ChoiceChip(
                              label: Text(choice.label),
                              selected: _selectedAnswer == choice.value,
                              onSelected: (selected) => setState(() => _selectedAnswer = selected ? choice.value : null),
                            ),
                          ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          label: l10n.submitAnswer,
                          onPressed: _selectedAnswer == null || _submitting
                              ? null
                              : () => _submitAnswer(challenge.id, _selectedAnswer!),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(AppErrorMapper.map(error).userMessage),
              ),
              const SizedBox(height: 12),
              playersAsync.when(
                data: (players) => RoundedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.scoreboard, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      for (final player in [...players]..sort((a, b) => b.score.compareTo(a.score)))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(player.displayName),
                          trailing: Text('${player.score} ${l10n.points}'),
                        ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(AppErrorMapper.map(error).userMessage),
              ),
              if (canAdvance) ...[
                const SizedBox(height: 16),
                PrimaryButton(
                  label: l10n.advanceChallenge,
                  onPressed: () async {
                    try {
                      await ref.read(gameRepositoryProvider).advanceChallenge(widget.roomId);
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppErrorMapper.map(error).userMessage)));
                      }
                    }
                  },
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(AppErrorMapper.map(error).userMessage)),
      ),
    );
  }

  Future<void> _submitAnswer(String challengeId, String answer) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _submitting = true);
    try {
      await ref.read(gameRepositoryProvider).submitAnswer(roomId: widget.roomId, challengeId: challengeId, answer: answer);
      if (mounted) {
        setState(() => _selectedAnswer = null);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.answerSubmitted)));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppErrorMapper.map(error).userMessage)));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _AnswerChoice {
  const _AnswerChoice({required this.label, required this.value});

  final String label;
  final String value;
}

List<_AnswerChoice> _answerChoices(GameChallenge challenge, AppLocalizations l10n) {
  if (challenge.type != ChallengeType.trueFalse) {
    return challenge.options.map((option) => _AnswerChoice(label: option, value: option)).toList();
  }

  final trueValue = challenge.options.isNotEmpty ? challenge.options.first : 'صح';
  final falseValue = challenge.options.length > 1 ? challenge.options[1] : 'خطأ';
  return <_AnswerChoice>[
    _AnswerChoice(label: l10n.trueOption, value: trueValue),
    _AnswerChoice(label: l10n.falseOption, value: falseValue),
  ];
}

String _stateLabel(AppLocalizations l10n, MultiplayerGameState state) {
  switch (state) {
    case MultiplayerGameState.waiting:
      return l10n.stateWaiting;
    case MultiplayerGameState.starting:
      return l10n.stateStarting;
    case MultiplayerGameState.playing:
      return l10n.statePlaying;
    case MultiplayerGameState.answering:
      return l10n.stateAnswering;
    case MultiplayerGameState.reviewing:
      return l10n.stateReviewing;
    case MultiplayerGameState.roundResults:
      return l10n.stateRoundResults;
    case MultiplayerGameState.gameResults:
      return l10n.stateGameResults;
    case MultiplayerGameState.paused:
      return l10n.statePaused;
    case MultiplayerGameState.finished:
      return l10n.stateFinished;
  }
}
