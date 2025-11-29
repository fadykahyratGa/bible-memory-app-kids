import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game_state.dart';
import '../../providers/game_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.correct});

  final bool correct;

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final state = gameProvider.state!;
    final question = state.currentQuestion;
    return Scaffold(
      appBar: AppBar(title: const Text('النتيجة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(correct ? Icons.check_circle : Icons.cancel, size: 96, color: correct ? Colors.green : Colors.red),
            const SizedBox(height: 12),
            Text(correct ? 'إجابة صحيحة!' : 'إجابة غير صحيحة، حاول مرة أخرى',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('النص الكامل:', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(question.verse.textAr, style: const TextStyle(fontSize: 18)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final hasNext = gameProvider.nextQuestion();
                if (!hasNext) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(gameProvider.state!.status == GameStatus.completed ? 'إنهاء الجلسة' : 'التالي'),
            ),
          ],
        ),
      ),
    );
  }
}
