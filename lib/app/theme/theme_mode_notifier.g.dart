// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 主题模式（跟随系统/亮/暗），全局常驻。
/// 默认跟随系统，设置页后续可接 SettingsRepository 持久化（暂不涉及先不接）。

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// 主题模式（跟随系统/亮/暗），全局常驻。
/// 默认跟随系统，设置页后续可接 SettingsRepository 持久化（暂不涉及先不接）。
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// 主题模式（跟随系统/亮/暗），全局常驻。
  /// 默认跟随系统，设置页后续可接 SettingsRepository 持久化（暂不涉及先不接）。
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'62c8d046edfe86f9b84b433650c856582779846a';

/// 主题模式（跟随系统/亮/暗），全局常驻。
/// 默认跟随系统，设置页后续可接 SettingsRepository 持久化（暂不涉及先不接）。

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
