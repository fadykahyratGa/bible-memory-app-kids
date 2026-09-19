import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';
import 'package:bible_memory_app_kids/core/localization/app_localizations.dart';
import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/game/domain/game_models.dart';
import 'package:bible_memory_app_kids/features/game/providers/game_providers.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_enums.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_team.dart';
import 'package:bible_memory_app_kids/features/rooms/providers/room_providers.dart';
import 'package:bible_memory_app_kids/features/shared/presentation/background_scaffold.dart';
import 'package:bible_memory_app_kids/ui/widgets/primary_button.dart';
import 'package:bible_memory_app_kids/ui/widgets/rounded_panel.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(activeGameProvider(roomId), (previous, next) {
      next.whenData((game) {
        if (game == null) {
          return;
        }
        if (game.state == MultiplayerGameState.gameResults || game.state == MultiplayerGameState.finished) {
          context.go('/room/$roomId/results');
        } else if (game.state != MultiplayerGameState.waiting) {
          context.go('/room/$roomId/game');
        }
      });
    });

    final l10n = AppLocalizations.of(context);
    final roomAsync = ref.watch(roomProvider(roomId));
    final playersAsync = ref.watch(roomPlayersProvider(roomId));
    final teamsAsync = ref.watch(roomTeamsProvider(roomId));
    final currentUserId = ref.watch(sessionControllerProvider).user?.id;
    final teams = teamsAsync.valueOrNull ?? const <RoomTeam>[];

    return BackgroundScaffold(
      appBar: AppBar(title: Text(l10n.roomLobby)),
      child: roomAsync.when(
        data: (room) {
          final isHost = room.hostUserId == currentUserId;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RoundedPanel(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.roomCode, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(room.code, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: room.code));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.copied)));
                        }
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              playersAsync.when(
                data: (players) => RoundedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.players, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      for (final player in players)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(player.displayName),
                          subtitle: Text(_teamLabel(teams, player.teamId, l10n.teamLabel)),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              if (player.isHost) Chip(label: Text(l10n.host)),
                              if (player.isJudge) Chip(label: Text(l10n.judge)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(AppErrorMapper.map(error).userMessage),
              ),
              if (room.gameMode == RoomGameMode.teams) ...[
                const SizedBox(height: 12),
                teamsAsync.when(
                  data: (teams) => RoundedPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.teams, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        for (final team in teams)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(team.name),
                            trailing: Text('${team.score}'),
                          ),
                      ],
                    ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text(AppErrorMapper.map(error).userMessage),
                ),
              ],
              const SizedBox(height: 16),
              if (isHost)
                PrimaryButton(
                  label: l10n.startGame,
                  onPressed: () async {
                    try {
                      await ref.read(gameRepositoryProvider).startGame(roomId);
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppErrorMapper.map(error).userMessage)));
                      }
                    }
                  },
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  try {
                    await ref.read(roomRepositoryProvider).leaveRoom(roomId);
                    await ref.read(sessionControllerProvider).refreshProfileAndMembership();
                    if (context.mounted) {
                      context.go('/home');
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppErrorMapper.map(error).userMessage)));
                    }
                  }
                },
                child: Text(l10n.leaveRoom),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(AppErrorMapper.map(error).userMessage)),
      ),
    );
  }
}

String _teamLabel(List<RoomTeam> teams, String? teamId, String fallbackLabel) {
  if (teamId == null) {
    return '';
  }
  for (final team in teams) {
    if (team.id == teamId) {
      return '$fallbackLabel: ${team.name}';
    }
  }
  return fallbackLabel;
}
