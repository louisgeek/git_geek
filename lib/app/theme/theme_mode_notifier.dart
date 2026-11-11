import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_notifier.g.dart';

/// 主题模式（跟随系统/亮/暗），全局常驻。
/// 默认跟随系统，设置页后续可接 SettingsRepository 持久化（core/storage/settings_repository.dart，暂不涉及先不接）。
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}
