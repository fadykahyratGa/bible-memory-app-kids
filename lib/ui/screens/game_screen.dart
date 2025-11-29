import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/game_provider.dart';
import '../../providers/progress_provider.dart';
import '../../ui/screens/result_screen.dart';
import '../widgets/app_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/tile_button.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final state = gameProvider.state;
    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final question = state.currentQuestion;
    return Scaffold(
      appBar: AppBar(title: Text('${state.config.bookName} ${state.config.chapter}:${state.config.fromVerse}-${state.config.toVerse}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الصعوبة: ${state.config.difficulty.name}'),
                  const SizedBox(height: 8),
                  Text(question.maskedText, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ProgressBar(
              value: (state.currentIndex + 1) / state.questions.length,
              label: 'السؤال ${state.currentIndex + 1} من ${state.questions.length}',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: gameProvider.currentAnswer
                  .map((word) => Chip(label: Text(word), onDeleted: () => gameProvider.removeAnswer(word)))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                children: question.options
                    .map((option) => TileButton(
                          text: option,
                          onTap: () => gameProvider.addAnswer(option),
                        ))
                    .toList(),
              ),
            ),
            ElevatedButton(
              onPressed: gameProvider.currentAnswer.length == question.hiddenWords.length
                  ? () {
                      final beforeScore = gameProvider.state!.score;
                      final correct = gameProvider.checkAnswer();
                      final delta = gameProvider.state!.score - beforeScore;
                      context.read<ProgressProvider>().recordResult(
                            correct: correct,
                            config: gameProvider.state!.config,
                            score: delta,
                          );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(correct: correct),
                        ),
                      );
                    }
                  : null,
              child: const Text('تحقق'),
            ),
          ],
        ),
      ),
    );
  }
}
