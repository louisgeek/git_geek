import 'package:flutter/material.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';
import 'package:git_geek/data/git_runner.dart';
import 'package:git_geek/l10n/strings.dart';

/// 应用标题栏（原 GitTagPage._buildTitle + 关于弹窗，自包含 showAbout 状态）。
class AppTitle extends StatefulWidget {
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
  State<AppTitle> createState() => _AppTitleState();
}

class _AppTitleState extends State<AppTitle> {
  bool showAbout = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
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
                  onSelected: widget.onLangSelected,
                  itemBuilder: (c) => [
                    for (final lang in AppLang.values)
                      PopupMenuItem(value: lang, child: Text(lang.nativeName)),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text('${widget.lang.nativeName} ▾'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => showAbout = true),
                  child: Text(widget.t.about),
                ),
              ],
            ),
            Text(
              supportsNativeGit
                  ? widget.t.subtitleDesktop
                  : widget.t.subtitleNoGit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (showAbout) _buildAboutDialog(),
      ],
    );
  }

  Widget _buildAboutDialog() {
    final t = widget.t;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.aboutTitle,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text('${t.aboutVersionLabel} $appVersion'),
                Text(
                  t.aboutCopyright,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => showAbout = false),
                    child: Text(t.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
