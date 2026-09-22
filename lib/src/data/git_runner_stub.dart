import 'package:git_geek/src/data/git_runner_base.dart';

class NoopGitRunner extends GitRunner {
  @override
  bool get supportsNativeGit => false;

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

GitRunner createRunner() => NoopGitRunner();
