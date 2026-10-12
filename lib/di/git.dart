import 'package:git_geek/data/git_runner.dart';
import 'package:git_geek/data/remote_repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'git.g.dart';

/// 本地 git 执行器装配：桌面/移动走 IoGitRunner，Web 走 NoopGitRunner。
/// 无状态应用单例，keepAlive 常驻；测试用 overrideWithValue(fake) 替换。
@Riverpod(keepAlive: true)
GitRunner gitRunner(Ref ref) => createGitRunner();

/// 远程仓库解析器装配：实例类，构造注入 GitRunner，进程级串行锁在实例内。
@Riverpod(keepAlive: true)
RemoteRepoResolver remoteRepoResolver(Ref ref) =>
    RemoteRepoResolver(ref.watch(gitRunnerProvider));

/// 是否支持本地 git：桌面/移动为 true，Web 等无 git 平台为 false。
/// UI/Notifier 统一经此 provider 读取，禁止再直引全局单例。
@Riverpod(keepAlive: true)
bool supportsNativeGit(Ref ref) => ref.watch(gitRunnerProvider).supportsNativeGit;
