import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';

class GuestNameScreen extends ConsumerStatefulWidget {
  const GuestNameScreen({super.key});

  @override
  ConsumerState<GuestNameScreen> createState() => _GuestNameScreenState();
}

class _GuestNameScreenState extends ConsumerState<GuestNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.isAuthenticated && context.mounted) {
        context.go('/home');
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('اسم الضيف')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم العرض'),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'أدخل اسمًا صالحًا من حرفين على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        await ref.read(authControllerProvider.notifier).continueAsGuest(_nameController.text.trim());
                      },
                child: state.isLoading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('الدخول كضيف'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
