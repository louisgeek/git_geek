// 语言枚举 + 无 context 场景的 l10n 访问（文案源为 lib/l10n/*.arb，gen_l10n 生成）
library;

import 'package:flutter/material.dart';
import 'package:git_geek/l10n/gen/app_localizations.dart';

enum AppLang {
  zh('zh'),
  zhHant('zh_Hant'),
  zhHantHK('zh_Hant_HK'),
  en('en');

  final String code;
  const AppLang(this.code);

  static AppLang of(String? code) {
    final c = code?.trim().toLowerCase();
    return AppLang.values.firstWhere(
      (e) => e.code.toLowerCase() == c,
      orElse: () => AppLang.zh,
    );
  }

  Locale get locale => switch (this) {
        AppLang.zhHant =>
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        AppLang.zhHantHK => const Locale.fromSubtags(
            languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
        _ => Locale(code),
      };

  /// 语言的自称（母语写法），不随界面语言变化
  String get nativeName => switch (this) {
        AppLang.zh => '中文',
        AppLang.zhHant => '繁體中文（臺灣）',
        AppLang.zhHantHK => '繁體中文（香港）',
        AppLang.en => 'English',
      };

  /// 按系统 locale 推断默认语言（CLDR 规则）：
  /// zh-Hant-* → 看地区（HK/MO 归香港桶，其余归台湾桶）；
  /// 无 script 时 HK/MO → 香港桶，TW → 台湾桶；
  /// zh-Hans-*/zh-CN/裸 zh/非 zh → 简体。
  static AppLang fromLocale(Locale locale) {
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
}

const String appVersion = '1.0';

/// 无 BuildContext 场景（data 层/Notifer）取文案：直接 lookup 生成类
AppLocalizations t(AppLang lang) =>
    lookupAppLocalizations(Locale(lang.code));
