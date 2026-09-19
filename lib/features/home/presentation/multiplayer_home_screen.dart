import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bible_memory_app_kids/core/localization/app_localizations.dart';
import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/shared/presentation/background_scaffold.dart';
import 'package:bible_memory_app_kids/ui/screens/home_screen.dart' as legacy;
import 'package:bible_memory_app_kids/ui/widgets/rounded_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MultiplayerHomeScreen extends ConsumerWidget {
  const MultiplayerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final profile = session.profile;
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          RoundedPanel(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  child: Text(_avatarLabel(profile?.displayName)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.homeGreeting, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(profile?.displayName ?? l10n.noProfileYet, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.multiplayerHomeSubtitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.add_circle_outline,
            title: l10n.createRoom,
            subtitle: l10n.createRoomSubtitle,
            onTap: () => context.push('/room/create'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.login,
            title: l10n.joinRoom,
            subtitle: l10n.joinRoomSubtitle,
            onTap: () => context.push('/room/join'),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.auto_awesome,
            title: l10n.legacyMode,
            subtitle: l10n.legacyModeSubtitle,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const legacy.HomeScreen()));
            },
          ),
        ],
      ),
    );
  }
}

String _avatarLabel(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed.characters.first.toUpperCase();
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RoundedPanel(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              CircleAvatar(radius: 24, child: Icon(icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
