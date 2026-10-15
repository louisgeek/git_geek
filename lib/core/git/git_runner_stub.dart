import 'package:git_geek/core/git/git_runner_base.dart';

/// 无 git 平台的空实现：直接返回失败，由上层转友好提示。
class NoopGitRunner extends GitRunner {
  @override
  bool get supportsNativeGit => false;

  /// 空执行：不调进程，直接返回失败。
  @override
  Future<GitResult> run(String? workDir, List<String> args,
      {void Function(String line)? onProgress}) async {
    return GitResult(
      ok: false,
      stdout: '',
      stderr: 'noop',
      command: 'git ${args.join(' ')}',
    );
  }
}

/// 创建无 git 平台的空执行器。
GitRunner createRunner() => NoopGitRunner();
