import 'package:git_geek/features/tags/domain/git_tag.dart';
import 'package:git_geek/shared/l10n/gen/app_localizations.dart';

/// Tag 相关枚举的展示文案。
///
/// 放在 presentation 而非 domain：domain 必须保持纯 Dart（不依赖 Flutter/l10n），
/// 文案映射属于展示职责。调用方在 presentation 内按语言取。
extension TagSyncStatusLabelX on TagSyncStatus {
  /// 取该状态的展示文案。
  String label(AppLocalizations t) {
    switch (this) {
      case TagSyncStatus.synced:
        return t.statSynced;
      case TagSyncStatus.onlyLocal:
        return t.statOnlyLocal;
      case TagSyncStatus.onlyRemote:
        return t.statOnlyRemote;
      case TagSyncStatus.diverged:
        return t.diverged;
    }
  }
}

/// 排序模式的展示文案。
extension TagSortModeLabelX on TagSortMode {
  /// 取该排序模式的展示文案。
  String label(AppLocalizations t) {
    switch (this) {
      case TagSortMode.semverDesc:
        return '${t.sortSemver} ↓';
      case TagSortMode.semverAsc:
        return '${t.sortSemver} ↑';
      case TagSortMode.nameAsc:
        return '${t.sortName} A→Z';
      case TagSortMode.nameDesc:
        return '${t.sortName} Z→A';
    }
  }
}

/// 过滤条件的展示文案。
extension TagFilterLabelX on TagFilter {
  /// 取该过滤条件的展示文案。
  String label(AppLocalizations t) {
    switch (this) {
      case TagFilter.all:
        return t.filterAll;
      case TagFilter.synced:
        return t.statSynced;
      case TagFilter.onlyLocal:
        return t.statOnlyLocal;
      case TagFilter.onlyRemote:
        return t.statOnlyRemote;
      case TagFilter.diverged:
        return t.diverged;
    }
  }
}
