import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/room_providers.dart';

class CreateRoomScreen extends ConsumerWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roomControllerProvider);

    ref.listen(roomControllerProvider, (previous, next) {
      final roomId = next.room?.id;
      if (roomId != null && roomId != previous?.room?.id && context.mounted) {
        context.go('/lobby/$roomId');
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء غرفة')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('سيتم إنشاء كود غرفة تلقائيًا من الخادم.'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      await ref.read(roomControllerProvider.notifier).createRoom();
                    },
              child: state.isLoading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('إنشاء غرفة'),
            ),
          ],
        ),
      ),
    );
  }
}
