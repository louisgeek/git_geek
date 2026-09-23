import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';

/// 复制文本并弹已复制提示（仓库卡的缓存路径复制、提交列表的 sha 复制共用）。
void copyAndNotify(BuildContext context, String value, AppLocalizations t) {
  Clipboard.setData(ClipboardData(text: value));
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(t.copied)));
}
