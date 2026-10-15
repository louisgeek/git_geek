# AGENTS.md

GitGeek：跨平台 Git tag/commit/子模块对比工具（Flutter 桌面+移动）。核心是调本地 `git` CLI 解析仓库，UI 展示 tag 同步状态与 commit 图。

## 技术栈

- 状态管理/DI：Riverpod 3 + `riverpod_annotation` 代码生成（**禁止**手写 Provider 定义，默认 `@riverpod`；仅应用单例用 `@Riverpod(keepAlive: true)`）
- 模型：Freezed 3 + `json_serializable`（禁止手写 `copyWith`/equals）
- 路由：`go_router`（装配在 `lib/app/router/app_router.dart`，StatefulShellRoute 双分支 `/tags` 对比页与 `/commits` 日志页，`/` 重定向到 `/tags`，路径常量在 `core/navigation/routes.dart`）
- 网络：`dio`（装配在 `core/network/network_providers.dart`，工厂在 `dio_factory.dart`，拦截器在 `interceptors/` 按 logging→auth→error 顺序挂载），只用于 GitHub/GitLab REST；**仓库操作必须走本地 git CLI**（`core/git/git_runner*.dart`），别用 HTTP 替代
- 日志：`logger` 包，统一从 `loggerProvider` 取（装配在 `core/logging/logger.dart`）；禁止 `print`/`debugPrint`
- 存储分层（按数据类型选，别混用；类在 `core/storage/`，无状态装配在 `core/storage/storage_providers.dart`，唯一的例外是 `appPrefsProvider` 与消费者 `SettingsRepository` 同在 `core/storage/app_prefs.dart`，避免 core→di 反向引用）：
  - token/密码 → `flutter_secure_storage`（`TokenStore` 类）
  - 简单偏好（repoPath/remote/lang/sort）→ `SharedPreferences`（`appPrefsProvider` + 有状态的 `SettingsRepository`，同在 `core/storage/app_prefs.dart`）
  - 离线缓存（remote tags 兜底，一仓一条文档）→ Sembast（`AppDatabase`）

## 目录结构（feature-first MVVM）

```
lib/
  main.dart                       # 入口：调 app/bootstrap.dart 启动流程
  app/                            # 应用外壳：app.dart 根组件 + bootstrap + router(ShellRoute) + shell(MainShell/MainTab) + theme
  core/                           # 跨 feature 纯能力：network/storage/error/navigation/logging/git(runner+resolver+url+装配)；不依赖 Flutter UI 库，不依赖 shared/features/app
  shared/                         # 跨 feature 共享：l10n(arb/+gen/+strings) + widgets(通用组件)，可依赖 Flutter，只依赖 core 和外部包，不依赖 features/app
  features/
    tags/                         # domain(模型+semver) / data(仓储类+sources 解析器) / tags_providers.dart(feature 装配) / presentation(Notifier+State+页面+widgets)
    commits/                      # 同结构（domain 含提交/分支/子模块模型）
    workspace/                    # 应用外壳协调：仓库配置+tags 内页签/范围+跨页跳转+共享壳组件（唯一同时认识 tags 和 commits 的地方）
```

依赖方向：`presentation → data(repository) → core`，`app → features`，`features/shared → core`，反向禁止。Notifier 不直调 DataSource/Sembast；presentation 只 import 本 feature 的 repository 与 `*_providers.dart`，不得 import sources；core 内代码不得 import shared/features/app，文案由调用方按语言备好后传入（如 `GitMessages`）。

**全局无状态依赖装配 Provider**（实例创建/组合）就近放在各层 `*_providers.dart` / `app/router` / `core/git/git_providers.dart`，不再设任何 `di/` 目录。应用单例（logging/storage/network/router/git/theme）用 `@Riverpod(keepAlive: true)`；feature 薄封装（tags/commits Repository）用默认 `@riverpod`（autoDispose）即可。有状态 Notifier 一律不进装配文件：feature 的放 `presentation/`，全局的（如 `SettingsRepository`/`ThemeModeNotifier`）留在 `core/`/`app/` 对应文件。装配文件只 import 类定义，不 import 有状态 Notifier。唯一的例外是 `appPrefsProvider` 与消费者 `SettingsRepository` 同在 `core/storage/app_prefs.dart`，避免反向引用。

## 代码生成

改了 `@riverpod`/`@freezed` 后必须跑：

```bash
dart run build_runner build
```

提交前验证：

```bash
flutter analyze    # 无 error、无 warning 为准（已清零，保持新增为零）
flutter test       # 全绿，且 merge-drift/溯源等核心链路必须有单测
```

## 编码约定

- 注释、commit message、交流一律中文
- 业务失败日志用 `logger.w(msg, error: e, stackTrace: st)`，别吞异常不留痕；模块前缀打 tag，如 `[tags] xxx`
- Dio 拦截器只打 method/url/status，**不打 body**（防 token 泄漏）
- Freezed `copyWith` 支持显式置 null，需要清字段时直接 `copyWith(x: null)`
- 新功能放 `features/<名>/`，别往 `core/git` 里加业务东西（git CLI 基础设施除外）

## 已完成：老架构迁移

- 老 `GitTagController`/`GitTagUiState`（700+ 行 God State）已迁为 `features/workspace`（`WorkspaceNotifier` + Freezed `WorkspaceState`），`lib/state/` 已删除；`lib/data/settings.dart` 已删除。
- 偏好唯一源为 `SettingsRepository`（key 与老 `GitTagSettings` 一致，老数据直接复用）。
- `GitTagDataSource`/`GitCommitDataSource` 已改为实例类（构造注入 `GitRunner` + `RemoteRepoResolver`，语言按调用透传 `AppLang`，无全局语言状态）；`RemoteRepoResolver` 已由静态工具类改为实例类（构造注入 `GitRunner`，串行锁实例级，单例下等价进程级）。
- 顶层 `lib/di/` 已删除：`router → app/router/app_router.dart`（StatefulShellRoute + MainShellPage/MainTab），`network → core/network/network_providers.dart + dio_factory + interceptors/`，`storage → core/storage/storage_providers.dart`（`token_store.dart → token_storage.dart`），`logging → core/logging/logger.dart`，`git → data/git_providers.dart`；`core/result.dart → core/error/`（result + result_extensions + app_error），路径常量收敛到 `core/navigation/routes.dart`，主题收敛到 `app/theme/`，入口收敛到 `main.dart → app/bootstrap.dart → app/app.dart`。未涉及的 session/auth/cache/mixin/utils/deeplink/splash 暂不新建。
- 顶层 `lib/models/`、`lib/logic/`、`lib/data/`、`lib/l10n/` 已打散：`models/git_tag + logic/semver → features/tags/domain/`，`models/git_commit → features/commits/domain/`，`logic/git_tag_parser + data/git_tag_source → features/tags/data/sources/`，`logic/git_log_parser + data/git_commit_source → features/commits/data/sources/`，共享 git 设施（runner/resolver/url/providers）→ `core/git/`，文案（arb+gen+strings）→ `core/l10n/`（`l10n.yaml` 与翻译管线配置同步更新）。
- `core/l10n/` → `shared/l10n/`（core 不依赖 Flutter UI 库；`l10n.yaml`/管线同步更新），`core/widgets/` → `shared/widgets/`；`core/git` 经 `GitMessages` 收文案（调用方在 features 层按语言备好传入，core 零依赖 shared）；`features/*/di/providers.dart` → feature 根 `*_providers.dart`；`RepoCard` 改为自 watch，tags/commits 两页不再直连对方 feature（仅经 workspace 协调）。
