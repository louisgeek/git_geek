// 条件导入：io 平台用 Process 实现，其余平台用空实现。
import 'package:git_geek/data/git_runner_base.dart';
import 'package:git_geek/data/git_runner_stub.dart'
    if (dart.library.io) 'package:git_geek/data/git_runner_io.dart' as impl;

export 'package:git_geek/data/git_runner_base.dart';

/// 全局 git 执行器单例：仓库操作统一走本地 git CLI。
final GitRunner gitRunner = impl.createRunner();

/// 是否支持本地 git：桌面/移动为 true，Web 等无 git 平台为 false。
bool get supportsNativeGit => gitRunner.supportsNativeGit;
