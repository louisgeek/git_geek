import 'package:git_geek/features/commits/domain/git_commit.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';

/// Commit / Submodule 相关枚举的展示文案。
///
/// 放在 presentation 而非 domain：domain 必须保持纯 Dart（不依赖 Flutter/l10n），
/// 文案映射属于展示职责。
extension SubmoduleStatusLabelX on SubmoduleStatus {
  /// 取该状态的展示文案（正常返回空串）。
  String label(AppLocalizations t) {
    switch (this) {
      case SubmoduleStatus.ok:
        return '';
      case SubmoduleStatus.uninitialized:
        return t.subUninitialized;
      case SubmoduleStatus.modified:
        return t.subModified;
      case SubmoduleStatus.conflict:
        return t.subConflict;
    }
  }
}
