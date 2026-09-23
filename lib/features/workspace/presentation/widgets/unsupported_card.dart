import 'package:flutter/material.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';

/// 不支持本地 git 的平台：仅显示不支持提示，不提供粘贴导入。
class UnsupportedCard extends StatelessWidget {
  final AppLocalizations t;

  const UnsupportedCard({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.platformUnsupported('Web'),
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              t.subtitleNoGit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
