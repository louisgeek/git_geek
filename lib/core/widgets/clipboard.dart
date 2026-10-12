import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 复制文本并弹已复制提示（仓库卡的缓存路径复制、提交列表的 sha 复制共用）。
/// 提示文案由调用方透传，core 不依赖业务 l10n。
void copyAndNotify(BuildContext context, String value, String copiedMessage) {
  Clipboard.setData(ClipboardData(text: value));
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(copiedMessage)));
}
