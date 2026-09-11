import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../rooms/models/room_enums.dart';
import '../../rooms/models/room_settings.dart';
import '../../rooms/providers/room_providers.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(roomControllerProvider.notifier).loadRoom(widget.roomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomControllerProvider);
    final room = state.room;

    ref.listen(roomControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    if (state.isLoading || room == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final players = state.players;
    final activePlayers = players.where((player) => player.leftAt == null).toList();
    final canStartIndividual = room.mode == RoomMode.individual && activePlayers.length >= 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الردهة'),
        actions: [
          IconButton(
            onPressed: () async {
              final shouldLeave = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('مغادرة الغرفة'),
                      content: Text(state.isHost
                          ? 'مغادرتك الآن ستؤدي إلى إغلاق الغرفة لأنك المضيف.'
                          : 'هل تريد مغادرة الغرفة؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
                        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('مغادرة')),
                      ],
                    ),
                  ) ??
                  false;
              if (!shouldLeave) return;
              await ref.read(roomControllerProvider.notifier).leaveRoom();
              if (context.mounted) {
                context.go('/home');
              }
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('كود الغرفة', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(room.code, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('${activePlayers.length} / ${room.maxPlayers}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('اللاعبون', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ...players.map(
            (player) => ListTile(
              leading: CircleAvatar(
                child: Icon(
                  state.onlineUserIds.contains(player.userId) ? Icons.circle : Icons.circle_outlined,
                  color: state.onlineUserIds.contains(player.userId) ? Colors.green : Colors.grey,
                  size: 14,
                ),
              ),
              title: Text(player.displayName),
              subtitle: Text(state.onlineUserIds.contains(player.userId) ? 'متصل' : 'غير متصل'),
              trailing: player.isHost ? const Chip(label: Text('المضيف')) : null,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            room: room,
            isHost: state.isHost,
            isUpdating: state.isUpdatingSettings,
            onChanged: (settings) => ref.read(roomControllerProvider.notifier).updateSettings(settings),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.isHost && canStartIndividual ? null : null,
            child: Text(state.isHost
                ? room.mode == RoomMode.teams
                    ? 'ابدأ اللعبة (يتطلب إعداد الفرق أولاً)'
                    : 'ابدأ اللعبة (سيتم التفعيل في المرحلة التالية)'
                : 'بانتظار المضيف'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatefulWidget {
  const _SettingsSection({
    required this.room,
    required this.isHost,
    required this.isUpdating,
    required this.onChanged,
  });

  final dynamic room;
  final bool isHost;
  final bool isUpdating;
  final ValueChanged<RoomSettings> onChanged;

  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  late RoomSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.room.settings;
  }

  @override
  void didUpdateWidget(covariant _SettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _settings = widget.room.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إعدادات الغرفة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _buildDropdown<RoomMode>(
              label: 'النمط',
              value: _settings.mode,
              enabled: widget.isHost,
              items: const {
                RoomMode.individual: 'فردي',
                RoomMode.teams: 'فرق',
              },
              onChanged: (value) => _update(_settings.copyWith(mode: value!)),
            ),
            _buildDropdown<int>(
              label: 'الوقت',
              value: _settings.timerSeconds,
              enabled: widget.isHost,
              items: const {30: '30', 45: '45', 60: '60', 90: '90'},
              onChanged: (value) => _update(_settings.copyWith(timerSeconds: value!)),
            ),
            _buildDropdown<int>(
              label: 'عقوبة التخطي',
              value: _settings.skipPenaltySeconds,
              enabled: widget.isHost,
              items: const {0: '0', 3: '3', 5: '5'},
              onChanged: (value) => _update(_settings.copyWith(skipPenaltySeconds: value!)),
            ),
            _buildDropdown<int>(
              label: 'عدد ال��ولات للفوز',
              value: _settings.roundsToWin,
              enabled: widget.isHost,
              items: const {1: '1', 2: '2', 3: '3', 5: '5'},
              onChanged: (value) => _update(_settings.copyWith(roundsToWin: value!)),
            ),
            _buildDropdown<DifficultyLevel>(
              label: 'الصعوبة',
              value: _settings.difficulty,
              enabled: widget.isHost,
              items: const {
                DifficultyLevel.easy: 'سهل',
                DifficultyLevel.medium: 'متوسط',
                DifficultyLevel.hard: 'صعب',
                DifficultyLevel.mixed: 'مختلط',
              },
              onChanged: (value) => _update(_settings.copyWith(difficulty: value!)),
            ),
            _buildDropdown<TestamentScope>(
              label: 'العهد',
              value: _settings.testament,
              enabled: widget.isHost,
              items: const {
                TestamentScope.old: 'العهد القديم',
                TestamentScope.newTestament: 'العهد الجديد',
                TestamentScope.both: 'الاثنان',
              },
              onChanged: (value) => _update(_settings.copyWith(testament: value!)),
            ),
            SwitchListTile(
              value: _settings.showQuestionToOpponents,
              onChanged: widget.isHost ? (value) => _update(_settings.copyWith(showQuestionToOpponents: value)) : null,
              title: const Text('إظهار التحدي للخصم'),
            ),
            if (widget.isUpdating) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _update(RoomSettings settings) {
    setState(() {
      _settings = settings;
    });
    widget.onChanged(settings);
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required bool enabled,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(labelText: label),
        onChanged: enabled ? onChanged : null,
        items: items.entries
            .map((entry) => DropdownMenuItem<T>(value: entry.key, child: Text(entry.value)))
            .toList(),
      ),
    );
  }
}
