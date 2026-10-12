# AGENTS.md

GitGeek：跨平台 Git tag/commit/子模块对比工具（Flutter 桌面+移动）。核心是调本地 `git` CLI 解析仓库，UI 展示 tag 同步状态与 commit 图。

## 技术栈

- 状态管理/DI：Riverpod 3 + `riverpod_annotation` 代码生成（**禁止**手写 Provider 定义，默认 `@riverpod`；仅应用单例用 `@Riverpod(keepAlive: true)`）
- 模型：Freezed 3 + `json_serializable`（禁止手写 `copyWith`/equals）
- 路由：`go_router`（装配在 `lib/di/router.dart`，`/tags` 对比页与 `/commits` 日志页，`/` 重定向到 `/tags`）
- 网络：`dio`（装配在 `lib/di/network.dart`，封装类在 `core/network/dio_client.dart`），只用于 GitHub/GitLab REST；**仓库操作必须走本地 git CLI**（`lib/data/git_runner*.dart`），别用 HTTP 替代
- 日志：`logger` 包，统一从 `loggerProvider` 取（装配在 `lib/di/logging.dart`）；禁止 `print`/`debugPrint`
- 存储分层（按数据类型选，别混用；类在 `core/storage/`，无状态装配在 `lib/di/storage.dart`，唯一的例外是 `appPrefsProvider` 与消费者 `SettingsRepository` 同在 `core/storage/app_prefs.dart`，避免 core→di 反向引用）：
  - token/密码 → `flutter_secure_storage`（`TokenStore` 类）
  - 简单偏好（repoPath/remote/lang/sort）→ `SharedPreferences`（`appPrefsProvider` + 有状态的 `SettingsRepository`，同在 `core/storage/app_prefs.dart`）
  - 离线缓存（remote tags 兜底，一仓一条文档）→ Sembast（`AppDatabase`）

## 目录结构（feature-first MVVM）

```
lib/
  main.dart                       # 入口：预加载 prefs + ProviderScope override
  di/                             # 全局无状态依赖装配 Provider（network/storage/logging/router/git）
  core/                           # 跨 feature 纯能力类/封装（network/storage/widgets），不放 provider（偏好 provider 例外：appPrefs/SettingsRepository 同在 storage/app_prefs.dart）
  features/
    tags/                         # data(仓储类) / di(feature 装配) / presentation(Notifier+State+页面+widgets)
    commits/ workspace/ ...       # 同结构（workspace 为应用外壳：仓库配置+tags 内页签/范围+协调逻辑+共享壳组件）
  data/                           # git CLI runner + 数据源（实例类，经 feature/di 装配）
  logic/                          # 纯函数解析器（git log/tag 输出解析、semver）
  models/                         # Freezed 模型（git_tag.dart / git_commit.dart）
  l10n/                           # arb 文案源（*.arb + gen）+ AppLang helper（strings.dart）
```

依赖方向：`presentation → feature/di → data(repository) → core`，反向禁止。Notifier 不直调 DataSource/Sembast。

**di 目录只存放无状态依赖装配 Provider**（实例创建/组合）。应用单例（logging/storage/network/router/git）用 `@Riverpod(keepAlive: true)`；feature 薄封装（tags/commits Repository）用默认 `@riverpod`（autoDispose）即可。有状态 Notifier 一律不进 di：feature 的放 `presentation/`，全局的（如 `SettingsRepository`）留在 `core/` 对应文件。di 自身只 import 类定义，不 import 有状态 Notifier。唯一的例外是 `appPrefsProvider` 与消费者 `SettingsRepository` 同在 `core/storage/app_prefs.dart`，避免 core→di 反向引用。

## 代码生成

改了 `@riverpod`/`@freezed` 后必须跑：

```bash
dart run build_runner build
```

提交前验证：

```bash
flutter analyze    # 无 error、无 warning 为准（老 7 个 warning 待清，不新增）
flutter test       # 全绿，且 merge-drift/溯源等核心链路必须有单测
```

## 编码约定

- 注释、commit message、交流一律中文
- 业务失败日志用 `logger.w(msg, error: e, stackTrace: st)`，别吞异常不留痕；模块前缀打 tag，如 `[tags] xxx`
- Dio 拦截器只打 method/url/status，**不打 body**（防 token 泄漏）
- Freezed `copyWith` 支持显式置 null，需要清字段时直接 `copyWith(x: null)`
- 新功能放 `features/<名>/`，别往 `data/` 老目录里加东西

## 已完成：老架构迁移

- 老 `GitTagController`/`GitTagUiState`（700+ 行 God State）已迁为 `features/workspace`（`WorkspaceNotifier` + Freezed `WorkspaceState`），`lib/state/` 已删除；`lib/data/settings.dart` 已删除。
- 偏好唯一源为 `SettingsRepository`（key 与老 `GitTagSettings` 一致，老数据直接复用）。
- `GitTagDataSource`/`GitCommitDataSource` 已改为实例类（构造注入 `GitRunner` + `RemoteRepoResolver`，语言按调用透传 `AppLang`，无全局语言状态）；`RemoteRepoResolver` 已由静态工具类改为实例类（构造注入 `GitRunner`，串行锁实例级，单例下等价进程级）。
