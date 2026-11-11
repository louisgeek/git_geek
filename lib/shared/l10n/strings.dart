// 语言枚举 + 无 context 场景的 l10n 访问（文案源为 lib/shared/l10n/*.arb，gen_l10n 生成）
library;

// 让调用方继续只 import 本文件即可拿到 AppLang。
export 'package:git_geek/core/config/app_lang.dart';

import 'package:flutter/material.dart';
import 'package:git_geek/core/config/app_lang.dart';
import 'package:git_geek/core/git/git_messages.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';

/// Flutter 侧对 core 语言枚举的扩展：Locale 转换与系统语言推断。
///
/// [AppLang] 本身定义在 `core/config/app_lang.dart`（纯 Dart，domain 可用），
/// 这里只补依赖 Flutter 的 `Locale` 能力，导出后调用方仍只 import 本文件。
extension AppLangLocaleX on AppLang {
  /// 转 Flutter Locale：繁体需带 scriptCode。
  Locale get locale => switch (this) {
    AppLang.zhHant =>
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    AppLang.zhHantHK => const Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
    _ => Locale(code),
  };
}

/// 按系统 locale 推断默认语言（CLDR 规则）：
/// zh-Hant-* → 看地区（HK/MO 归香港桶，其余归台湾桶）；
/// 无 script 时 HK/MO → 香港桶，TW → 台湾桶；
/// zh-Hans-*/zh-CN/裸 zh/非 zh → 简体。
AppLang appLangFromLocale(Locale locale) {
  if (locale.languageCode != 'zh') return AppLang.zh;
  final script = locale.scriptCode?.toLowerCase();
  final region = locale.countryCode?.toUpperCase();
  if (script == 'hans') return AppLang.zh;
  if (script == 'hant') {
    return (region == 'HK' || region == 'MO')
        ? AppLang.zhHantHK
        : AppLang.zhHant;
  }
  if (region == 'HK' || region == 'MO') return AppLang.zhHantHK;
  if (region == 'TW') return AppLang.zhHant;
  return AppLang.zh;
}

/// 应用版本号：关于弹窗展示用。
const String appVersion = '1.0';

/// 无 BuildContext 场景（data 层/Notifer）取文案：直接 lookup 生成类
AppLocalizations t(AppLang lang) =>
    lookupAppLocalizations(Locale(lang.code));

/// AppLang 一键备好 git 层所需的文案包：core/git 只收字符串，不读 l10n。
extension AppLangGitMessagesX on AppLang {
  GitMessages get gitMessages {
    final tr = t(this);
    return GitMessages(
      cacheCleanFail: tr.cacheCleanFail,
      filterFallback: tr.filterFallback,
      dirNotExist: tr.dirNotExist,
      platformUnsupported: tr.platformUnsupported('Web'),
      updatingCache: tr.updatingCache,
      updateStaleCache: tr.updateStaleCache,
      cloningCache: tr.cloningCache,
      cloneUnusable: tr.cloneUnusable,
    );
  }
}
