import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_prefs.g.dart';

/// SharedPreferences 实例（core 基础设施）。
///
/// 启动期由组合根 `app/bootstrap.dart` 预加载后 override；
/// 业务只经此 provider 读取原始偏好，读写语义见 `settings_repository.dart`。
/// 普通偏好放这里；token/密码放 TokenStore；离线表结构数据放 Sembast。
@Riverpod(keepAlive: true)
SharedPreferences appPrefs(Ref ref) => throw UnimplementedError(
      'appPrefsProvider 必须在 bootstrap 中由组合根 override 注入已加载实例',
    );
