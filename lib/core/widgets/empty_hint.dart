import 'package:flutter/material.dart';

/// 跨 feature 共用的空态提示卡（tags 三个列表、commits 列表都在用）。
class EmptyHint extends StatelessWidget {
  final String text;

  const EmptyHint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
