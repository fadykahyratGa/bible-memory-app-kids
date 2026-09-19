import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bible_memory_app_kids/core/errors/error_mapper.dart';
import 'package:bible_memory_app_kids/core/localization/app_localizations.dart';
import 'package:bible_memory_app_kids/features/auth/providers/auth_providers.dart';
import 'package:bible_memory_app_kids/features/shared/presentation/background_scaffold.dart';
import 'package:bible_memory_app_kids/ui/widgets/primary_button.dart';
import 'package:bible_memory_app_kids/ui/widgets/rounded_panel.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _nameController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final existingName = ref.read(sessionControllerProvider).profile?.displayName ?? '';
    _nameController = TextEditingController(text: existingName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BackgroundScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: RoundedPanel(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.profileQuestion, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: l10n.displayNameLabel),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l10n.continueLabel,
                    onPressed: _submitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.nameRequired)));
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(sessionControllerProvider).saveProfile(name);
      await ref.read(sessionControllerProvider).refreshProfileAndMembership();
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(AppErrorMapper.map(error).userMessage)));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
