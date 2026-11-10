import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_geek/core/git/git_providers.dart';
import 'package:git_geek/features/workspace/presentation/widgets/about_dialog.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';
import 'package:git_geek/shared/l10n/strings.dart';

/// 应用标题栏：标题 + 语言切换 + 关于弹窗入口。
class AppTitle extends ConsumerWidget {
  final AppLang lang;
  final AppLocalizations t;
  final ValueChanged<AppLang> onLangSelected;

  const AppTitle({
    super.key,
    required this.lang,
    required this.t,
    required this.onLangSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportsNativeGit = ref.watch(supportsNativeGitProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'GitGeek',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            PopupMenuButton<AppLang>(
              onSelected: onLangSelected,
              itemBuilder: (c) => [
                for (final lang in AppLang.values)
                  PopupMenuItem(value: lang, child: Text(lang.nativeName)),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text('${lang.nativeName} ▾'),
              ),
            ),
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AppAboutDialog(t: t),
              ),
              child: Text(t.about),
            ),
          ],
        ),
        Text(
          supportsNativeGit ? t.subtitleDesktop : t.subtitleNoGit,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
