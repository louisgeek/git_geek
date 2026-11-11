# AGENTS.md

GitGeek：跨平台 Git tag/commit/子模块对比工具（Flutter 桌面+移动）。核心是调本地 `git` CLI 解析仓库，UI 展示 tag 同步状态与 commit 图。

## 技术栈

- 状态管理/DI：Riverpod 3 + `riverpod_annotation` 代码生成（**禁止**手写 Provider 定义，默认 `@riverpod`；仅应用单例用 `@Riverpod(keepAlive: true)`）
- 模型：Freezed 3 生成不可变模型（禁止手写 `copyWith`/equals）。`json_serializable` 只在 data 层的 DTO 上使用；**domain model 不带序列化注解**（见下方分层判据）。
- 路由：`go_router`（装配在 `lib/app/router/app_router.dart`，StatefulShellRoute 双分支 `/tags` 对比页与 `/commits` 日志页，`/` 重定向到 `/tags`，路径常量在 `core/navigation/routes.dart`）
- 网络：`dio`（装配在 `core/network/network_providers.dart`，工厂在 `dio_factory.dart`，拦截器在 `interceptors/` 按 logging→auth→error 顺序挂载），只用于 GitHub/GitLab REST；**仓库操作必须走本地 git CLI**（`core/git/git_runner*.dart`），别用 HTTP 替代
- 日志：`logger` 包，统一从 `loggerProvider` 取（装配在 `core/logging/logger.dart`）；**禁止 `print`/`debugPrint`，无例外**（错误兜底也走 Logger，`FlutterError.presentError` 保留）。
- 错误上报链路（#5.24）：① Flutter 侧两入口在组合根 `app/bootstrap.dart` 注册——`FlutterError.onError` 处理 framework 错误、`PlatformDispatcher.instance.onError` 处理未捕获异步错误（两入口互补、不保证全覆盖，isolate/原生侧错误按各自机制处理）；② Riverpod 侧 `RiverpodObserver`（`core/logging/provider_observer.dart`）挂 `ProviderScope.observers`，按 3.0 新签名实现 `providerDidFail(context, error, stackTrace)` 转发 error 级，**转发前先跳过 `ProviderException`**——依赖链上游失败会让下游 provider 重复触发，跳过才能同一根因只上报一次（`ProviderException` 仅经 `package:riverpod/misc.dart` 导出）。
- 存储分层（按数据类型选，别混用；技术实现在 `core/storage/`，无状态装配在 `core/storage/storage_providers.dart`）：
  - token/密码 → `flutter_secure_storage`（`TokenStore` 类）
  - 简单偏好（repoPath/remote/lang/sort）→ `SharedPreferences`（`core/storage/app_prefs.dart` 只留 `appPrefsProvider` 实例；业务语义的 `SettingsRepository` 在 `core/storage/settings_repository.dart`）
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

依赖方向：`app → features → shared → core` 单向不成环，反向禁止。约定：

- **presentation 不得 import 任何 `data/`**。仓储以 domain 契约（`*_repository_contract.dart`）声明，provider 只声明抽象类型、不提供默认实现（`throw UnimplementedError`），由组合根 `app/bootstrap.dart` 的 `ProviderScope.overrides` 注入实现。
- Notifier 不直调 DataSource / Sembast；实现在 data 层，装配只在组合根。
- feature 内：domain 只依赖 core 的纯 Dart 契约（`Result`/`AppError`），**不依赖 Flutter、不依赖 shared、不带序列化注解**；data 与 presentation 都依赖 domain。
- core 内代码不得 import shared/features/app，文案由调用方按语言备好后传入（如 `GitMessages`）；shared 不得 import features/app。
- 分层判据（三条，不用「能否跨项目复用」这类前提）。**来源分级**：业内对 core/shared 边界无统一定义（详见参考文档 §4.3），以下三条是本项目约定，非外部权威规定，落地时以本地约定为准：
  1. **不得依赖 feature**：core 与 shared 都禁止 import 任何 `features/`；core 还不得 import shared。「core 不得依赖 feature」来自 NIA 示例项目的工程约定（非 Android 架构指南原文），本项目据 Low Coupling 推及 shared。
  2. **是否带业务语义**：不出现领域概念（tag/commit/repo 等）的进 core（network/storage/logging/git/config/error/navigation/utils）；出现但无单一 owner 的进 shared（通用 UI 组件、跨 feature 业务规则、l10n、design_system）。**这条与 Android 官方不同**——官方把 UI module 归 common/core，本项目因增设 shared 段而另行划分。
  3. **多消费方门槛**：进 shared 需至少两个 feature 实际在用；只有一个用就留在该 feature。

**组合根**在 `app/bootstrap.dart`：全应用唯一决定「接口配哪个实现」的地方，用 `ProviderScope.overrides` 装配（Repository 用 `overrideWith` 工厂，随容器单例复用 GitRunner/Logger/AppDatabase），`ProviderScope.observers` 挂 `RiverpodObserver` 承接 provider 失败转发，其余实例装配就近放各层 `*_providers.dart` / `app/router` / `core/git/git_providers.dart`，不设任何 `di/` 目录。应用单例（logging/storage/network/router/git/theme）一律 `@Riverpod(keepAlive: true)`。**Repository provider 用默认 `@riverpod`（autoDispose）**：Repository 只持 `final` 依赖、不存可变数据，重建只是重新绑定引用；缓存与串行锁这类状态由它依赖的组件持有（`appDatabaseProvider`、`remoteRepoResolverProvider` 各自 keepAlive），因此不需要在 Repository 上加 keepAlive。只有 Repository 自身引入内存缓存字段时才改 keepAlive（`SettingsRepository` 是偏好 SSOT、自身持有共享可变状态，属合法 keepAlive 例外）。有状态 Notifier 一律不进装配文件：feature 的放 `presentation/`，全局的（如 `SettingsRepository`/`ThemeModeNotifier`）留在 `core/`/`app/` 对应文件。装配文件只 import 类定义，不 import 有状态 Notifier。

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
- Riverpod 3.0 写法约定：用 Notifier/AsyncNotifier/StreamNotifier；`StateProvider`/`StateNotifierProvider`/`ChangeNotifierProvider` 属 legacy（`package:riverpod/legacy.dart`），新代码不用。Notifier 异步方法 await 之后先 `ref.mounted` 判活，再碰 ref/state（销毁后调用会抛 `UnmountedRefException`，不依赖该类型名做捕获）；依赖失败会被包成 `ProviderException` 且默认不重试，由真正抛错的源头 provider 承担重试
- riverpod_lint 按 analysis_server_plugin 新体系装在 analysis_options.yaml 顶层 `plugins:`（`riverpod_lint: <version>` Map 形式，版本与 pubspec.lock 一致；旧的 `analyzer.plugins` 列表写法已废弃勿用）；`ProviderException` 需 import `package:riverpod/misc.dart`（仅经 misc.dart 导出），pubspec 已直接声明 `riverpod` 依赖
- Dio 拦截器只打 method/url/status，**不打 body**（防 token 泄漏）
- Freezed `copyWith` 支持显式置 null，需要清字段时直接 `copyWith(x: null)`
- 新功能放 `features/<名>/`，别往 `core/git` 里加业务东西（git CLI 基础设施除外）
- l10n 生成物直接生成到源码目录（`l10n.yaml` 的 `output-dir` 指向 `lib/shared/l10n/gen`；本 SDK synthetic package 机制已移除，`synthetic-package` 参数已废弃不写——已按参考文档「按目标 Flutter SDK 实测确认」口径核实）；`flutter: generate: true` 已在 pubspec 声明
- 测试目录大体镜像 `lib/` 结构；`shared/l10n` 生成物不做单测；Fake 仓储实现 domain 契约、供 `ProviderContainer.test`/widget 测试注入（存量测试文件不强制搬迁，新增测试按 lib 路径放置）

## 已完成：老架构迁移

- 老 `GitTagController`/`GitTagUiState`（700+ 行 God State）已迁为 `features/workspace`（`WorkspaceNotifier` + Freezed `WorkspaceState`），`lib/state/` 已删除；`lib/data/settings.dart` 已删除。
- 偏好唯一源为 `SettingsRepository`（key 与老 `GitTagSettings` 一致，老数据直接复用），位于 `core/storage/settings_repository.dart`。
- `GitTagDataSource`/`GitCommitDataSource` 已改为实例类（构造注入 `GitRunner` + `RemoteRepoResolver`，语言按调用透传 `AppLang`，无全局语言状态）；`RemoteRepoResolver` 已由静态工具类改为实例类（构造注入 `GitRunner`，串行锁实例级，单例下等价进程级）。
- 顶层 `lib/di/` 已删除：`router → app/router/app_router.dart`（StatefulShellRoute + MainShellPage/MainTab），`network → core/network/network_providers.dart + dio_factory + interceptors/`，`storage → core/storage/storage_providers.dart`（`token_store.dart → token_storage.dart`），`logging → core/logging/logger.dart`，`git → data/git_providers.dart`；`core/result.dart → core/error/`（result + result_extensions + app_error），路径常量收敛到 `core/navigation/routes.dart`，主题收敛到 `app/theme/`，入口收敛到 `main.dart → app/bootstrap.dart → app/app.dart`。未涉及的 session/auth/cache/mixin/utils/deeplink/splash 暂不新建。
- 顶层 `lib/models/`、`lib/logic/`、`lib/data/`、`lib/l10n/` 已打散：`models/git_tag + logic/semver → features/tags/domain/`，`models/git_commit → features/commits/domain/`，`logic/git_tag_parser + data/git_tag_source → features/tags/data/sources/`，`logic/git_log_parser + data/git_commit_source → features/commits/data/sources/`，共享 git 设施（runner/resolver/url/providers）→ `core/git/`，文案（arb+gen+strings）→ `core/l10n/`（`l10n.yaml` 与翻译管线配置同步更新）。
- `core/l10n/` → `shared/l10n/`（core 不依赖 Flutter UI 库；`l10n.yaml`/管线同步更新），`core/widgets/` → `shared/widgets/`；`core/git` 经 `GitMessages` 收文案（调用方在 features 层按语言备好传入，core 零依赖 shared）；`features/*/di/providers.dart` → feature 根 `*_providers.dart`；`RepoCard` 改为自 watch，tags/commits 两页不再直连对方 feature（仅经 workspace 协调）。
