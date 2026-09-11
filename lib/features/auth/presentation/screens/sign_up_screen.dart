import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.isAuthenticated && context.mounted) {
        context.go('/home');
      }
      if (next.infoMessage != null && next.infoMessage != previous?.infoMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.infoMessage!)));
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'اسم العرض'),
                validator: (value) => value != null && value.trim().length >= 2 ? null : 'أدخل اسم عرض صالحًا',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                validator: (value) => value != null && value.contains('@') ? null : 'أدخل بريدًا إلكترونيًا صحيحًا',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                validator: (value) => value != null && value.length >= 6 ? null : 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                validator: (value) => value == _passwordController.text ? null : 'كلمتا المرور غير متطابقتين',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        await ref.read(authControllerProvider.notifier).signUp(
                              displayName: _displayNameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                      },
                child: state.isLoading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('إنشاء الحساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
