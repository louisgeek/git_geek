import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:git_geek/l10n/strings.dart';

part 'workspace_state.freezed.dart';

/// 应用外壳状态：仓库配置 + tags 内页签/范围（原 GitTagUiState，手写 copyWith 改为 Freezed）。
/// tags 数据在 TagsState，commits/branches/submodules 在 CommitsState。
/// tags 页与 commits 页的切换走路由（/tags、/commits），不再用 tab 索引。
@freezed
abstract class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState({
    @Default('') String repoPath,
    @Default('origin') String remote,
    @Default(AppLang.zh) AppLang lang,
    @Default(0) int selectedTagTab,
    @Default('') String selectedScope,
    @Default('') String cacheDirHint,
  }) = _WorkspaceState;
}
