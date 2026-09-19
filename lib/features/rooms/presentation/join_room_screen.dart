import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';
import 'package:bible_memory_app_kids/core/localization/app_localizations.dart';
import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/rooms/domain/room_code.dart';
import 'package:bible_memory_app_kids/features/shared/presentation/background_scaffold.dart';
import 'package:bible_memory_app_kids/ui/widgets/primary_button.dart';
import 'package:bible_memory_app_kids/ui/widgets/rounded_panel.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  late final TextEditingController _codeController;
  late final TextEditingController _nicknameController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(sessionControllerProvider).profile;
    _codeController = TextEditingController();
    _nicknameController = TextEditingController(text: profile?.displayName ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BackgroundScaffold(
      appBar: AppBar(title: Text(l10n.joinRoom)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RoundedPanel(
            child: Column(
              children: [
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(labelText: l10n.roomCode),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(labelText: l10n.nickname),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: l10n.joinRoomAction,
                  onPressed: _submitting ? null : _joinRoom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinRoom() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final roomCode = _codeController.text.trim().toUpperCase();
    final nickname = _nicknameController.text.trim();
    if (roomCode.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.codeRequired)));
      return;
    }
    if (!RoomCodeHelper.isValid(roomCode)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.invalidRoomCode)));
      return;
    }
    if (nickname.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nameRequired)));
      return;
    }

    setState(() => _submitting = true);
    try {
      final createdRoom = await ref.read(roomRepositoryProvider).joinRoom(roomCode: roomCode, nickname: nickname);
      await ref.read(sessionControllerProvider).refreshProfileAndMembership();
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.roomJoined)));
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
