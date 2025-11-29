import 'package:flutter/material.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإنجازات')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: const [
          _BadgeTile(name: 'متعلم جديد', description: 'أكمل 5 آيات', unlocked: true),
          _BadgeTile(name: 'محارب الصلاة', description: 'أكمل 20 آية', unlocked: false),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.name, required this.description, required this.unlocked});

  final String name;
  final String description;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? Colors.yellow[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unlocked ? Colors.amber : Colors.grey),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(unlocked ? Icons.emoji_events : Icons.lock, size: 40, color: unlocked ? Colors.orange : Colors.grey),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
