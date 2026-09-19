import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';
import 'package:bible_memory_app_kids/core/localization/app_localizations.dart';
import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/rooms/data/room_repository.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_enums.dart';
import 'package:bible_memory_app_kids/features/shared/presentation/background_scaffold.dart';
import 'package:bible_memory_app_kids/ui/widgets/primary_button.dart';
import 'package:bible_memory_app_kids/ui/widgets/rounded_panel.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  RoomGameMode _gameMode = RoomGameMode.individual;
  RoomJudgeMode _judgeMode = RoomJudgeMode.none;
  int _teamCount = 2;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BackgroundScaffold(
      appBar: AppBar(title: Text(l10n.createRoom)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.gameMode, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                RadioListTile<RoomGameMode>(
                  value: RoomGameMode.individual,
                  groupValue: _gameMode,
                  title: Text(l10n.individualMode),
                  onChanged: (value) => setState(() => _gameMode = value!),
                ),
                RadioListTile<RoomGameMode>(
                  value: RoomGameMode.teams,
                  groupValue: _gameMode,
                  title: Text(l10n.teamsMode),
                  onChanged: (value) => setState(() => _gameMode = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RoomJudgeMode>(
                  value: _judgeMode,
                  decoration: InputDecoration(labelText: l10n.judgeMode),
                  items: [
                    DropdownMenuItem(value: RoomJudgeMode.none, child: Text(l10n.judgeNone)),
                    DropdownMenuItem(value: RoomJudgeMode.host, child: Text(l10n.judgeHost)),
                  ],
                  onChanged: (value) => setState(() => _judgeMode = value ?? RoomJudgeMode.none),
                ),
                if (_gameMode == RoomGameMode.teams) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _teamCount,
                    decoration: InputDecoration(labelText: l10n.teamCount),
                    items: const [2, 3, 4].map((count) => DropdownMenuItem(value: count, child: Text('$count'))).toList(),
                    onChanged: (value) => setState(() => _teamCount = value ?? 2),
                  ),
                ],
                const SizedBox(height: 16),
                PrimaryButton(
                  label: l10n.createRoomAction,
                  onPressed: _submitting ? null : _createRoom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createRoom() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _submitting = true);
    try {
      final createdRoom = await ref.read(roomRepositoryProvider).createRoom(
            CreateRoomRequest(
              gameMode: _gameMode,
              judgeMode: _judgeMode,
              teamCount: _gameMode == RoomGameMode.teams ? _teamCount : null,
            ),
          );
      await ref.read(sessionControllerProvider).refreshProfileAndMembership();
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('${l10n.roomCreated}: ${createdRoom.roomCode}')));
        context.go('/room/${createdRoom.roomId}/lobby');
      }
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(AppErrorMapper.map(error).userMessage)));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
