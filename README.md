# GitGeek (Flutter)

一个面向开发者的 Git 仓库辅助工具，基于 Flutter 构建：Tag 对比、提交记录、子模块溯源。

---

## 功能

### 界面语言 & 关于
- 标题栏可切换简体中文 / English（全界面文案、提示、错误信息跟随切换，重启保留）
- 标题栏「关于」查看版本信息

### Tag 对比
- 读取本地仓库和远程（origin 或自定义远程）的 tag 列表
- 对比本地 / 远程 tag 的同步状态：已同步、仅本地、仅远程、sha 不一致
- 支持语义版本排序（SemVer）、名称排序、关键字过滤
- 支持粘贴导入（非桌面端或离线场景）

### 远程仓库支持（桌面端）
- 仓库路径可直接粘贴远程 URL：`https://github.com/owner/repo.git` 或 `git@github.com:owner/repo.git`
- 首次刷新自动克隆到缓存目录（`%APPDATA%\GitGeek\cache`），优先 `--filter=blob:none` 部分克隆，失败回退完整克隆
- 之后每次刷新增量 `git fetch --tags --prune`，Tag 对比、提交记录、子模块溯源均可正常使用

### 提交记录 & 子模块溯源
- 读取任意仓库、任意分支的提交历史
- 自动识别子模块指针变化（gitlink），展示切换前后的版本及子模块内信息
- 溯源“谁在什么时候切了子模块”：
  - 普通提交直接切换：展示上次切换者
  - merge 搬运：区分“搬运来源”和“原始切换者”
  - merge 静默丢失：检测并高亮 git 未弹出冲突却静默丢弃另一侧版本的情况
- 支持子模块范围切换，可直接查看子模块自己的 tag 和提交记录
- 支持粘贴导入（`git log` 输出直接粘贴解析）

---

## 平台支持

| 平台 | 运行方式 | 本地 git 支持 | 远程 URL 支持 |
|------|---------|-------------|--------------|
| Windows / macOS / Linux | 直接执行 git 命令（需本机安装 git） | ✅ | ✅ 自动克隆到缓存 |
| Android / iOS | 粘贴导入 | ❌ | ❌ |
| Web | 粘贴导入 | ❌ | ❌ |

---

## 运行

```bash
# 桌面（Windows，需先装 Visual Studio C++ 工作负载 + 开开发者模式）
flutter run -d windows

# Web
flutter run -d chrome

# 打 Windows 正式包（解压即用，见 build\windows\GitGeek-windows.zip）
flutter build windows --release

# 测试
flutter test
```

---

## 本地文件位置（Windows）

- 界面配置（仓库路径 / 远程名 / 语言）：`%APPDATA%\com.louisgeek\git_geek\shared_preferences.json`
- 远程仓库缓存：`%APPDATA%\GitGeek\cache\<repo名>-<短sha>\`

---

## 技术栈

- Flutter + Material 3
- `flutter_riverpod`（`riverpod`）状态管理（`@riverpod` 注解 + 代码生成）
- `shared_preferences` / `path_provider` / `crypto`
- 纯 Dart 解析器与溯源算法，状态层由 Riverpod 承载
