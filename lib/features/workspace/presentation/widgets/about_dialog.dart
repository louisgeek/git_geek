import 'package:flutter/material.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';
import 'package:git_geek/shared/l10n/strings.dart';

/// 关于弹窗：版本 + 版权 + 关闭。
class AppAboutDialog extends StatelessWidget {
  final AppLocalizations t;

  const AppAboutDialog({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.aboutTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${t.aboutVersionLabel} $appVersion'),
          Text(t.aboutCopyright),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.close),
        ),
      ],
    );
  }
}
