import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';
import 'package:bible_memory_app_kids/core/localization/app_localizations.dart';
import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/rooms/providers/room_providers.dart';
import 'package:bible_memory_app_kids/features/shared/presentation/background_scaffold.dart';
import 'package:bible_memory_app_kids/ui/widgets/primary_button.dart';
import 'package:bible_memory_app_kids/ui/widgets/rounded_panel.dart';

String _playerInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed.characters.first;
}

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final playersAsync = ref.watch(roomPlayersProvider(roomId));
    return BackgroundScaffold(
      appBar: AppBar(title: Text(l10n.results)),
      child: playersAsync.when(
        data: (players) {
          final sortedPlayers = [...players]..sort((a, b) => b.score.compareTo(a.score));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RoundedPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.gameFinished, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    for (final player in sortedPlayers)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text(_playerInitial(player.displayName))),
                        title: Text(player.displayName),
                        trailing: Text('${player.score} ${l10n.points}'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.returnHome,
                onPressed: () async {
                  try {
                    await ref.read(roomRepositoryProvider).leaveRoom(roomId);
                  } catch (_) {}

                  try {
                    await ref.read(sessionControllerProvider).refreshProfileAndMembership();
                    if (context.mounted) {
                      context.go('/home');
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppErrorMapper.map(error).userMessage)));
                    }
                  } finally {
                    ref.read(sessionControllerProvider).clearRestoreLocation();
                  }
                },
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
