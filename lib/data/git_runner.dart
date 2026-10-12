// 条件导入：io 平台用 Process 实现，其余平台用空实现。
import 'package:git_geek/data/git_runner_base.dart';
import 'package:git_geek/data/git_runner_stub.dart'
    if (dart.library.io) 'package:git_geek/data/git_runner_io.dart' as impl;

export 'package:git_geek/data/git_runner_base.dart';

/// 按平台创建 git 执行器：桌面/移动走本地 git CLI，Web 等无 git 平台走空实现。
/// 单例语义由 `lib/di/git.dart` 的 `gitRunnerProvider`（keepAlive）保证，
/// 此处只保留无状态工厂，禁止再建全局单例。
GitRunner createGitRunner() => impl.createRunner();
