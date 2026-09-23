/// git 进程执行结果
class GitResult {
  final bool ok;
  final String stdout;
  final String stderr;
  final String command;

  const GitResult({
    required this.ok,
    required this.stdout,
    required this.stderr,
    required this.command,
  });
}

/// 平台相关的 git 执行器：桌面端用 dart:io Process，其它平台返回友好错误。
/// 用条件导出实现，[git_runner.dart] 统一对外。
abstract class GitRunner {
  Future<GitResult> run(String? workDir, List<String> args,
      {void Function(String line)? onProgress});
  bool get supportsNativeGit;
}
