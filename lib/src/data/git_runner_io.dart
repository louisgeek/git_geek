import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:git_geek/src/data/git_runner_base.dart';

class IoGitRunner extends GitRunner {
  @override
  bool get supportsNativeGit => true;

  @override
  Future<GitResult> run(String? workDir, List<String> args,
      {void Function(String line)? onProgress}) async {
    final displayWorkDir =
        (workDir == null || workDir == '.' || workDir.trim().isEmpty)
            ? null
            : workDir;
    final fullArgs = <String>[
      if (displayWorkDir != null) ...['-C', displayWorkDir],
      ...args,
    ];
    try {
      final proc = await Process.start('git', fullArgs, runInShell: false);
      final stdoutBuf = StringBuffer();
      final stderrBuf = StringBuffer();
      final outDone = Completer<void>();
      final errDone = Completer<void>();
      proc.stdout.transform(utf8.decoder).listen(
        (chunk) {
          stdoutBuf.write(chunk);
          if (onProgress != null && args.firstOrNull == 'clone') {
            for (final line in const LineSplitter().convert(chunk)) {
              onProgress(line);
            }
          }
        },
        onDone: () => outDone.complete(),
        onError: (_) => outDone.complete(),
      );
      proc.stderr.transform(utf8.decoder).listen(
        (chunk) {
          stderrBuf.write(chunk);
          if (onProgress != null) {
            for (final line in const LineSplitter().convert(chunk)) {
              onProgress(line);
            }
          }
        },
        onDone: () => errDone.complete(),
        onError: (_) => errDone.complete(),
      );
      final code = await proc.exitCode;
      await Future.wait([outDone.future, errDone.future]);
      final stdout = stdoutBuf.toString();
      var stderr = stderrBuf.toString().trimRight();
      if (stderr.isEmpty && code != 0) {
        stderr = 'git ${args.join(' ')} 退出码=$code';
      }
      return GitResult(
        ok: code == 0,
        stdout: stdout,
        stderr: stderr,
        command: 'git ${args.join(' ')}',
      );
    } catch (e) {
      return GitResult(
        ok: false,
        stdout: '',
        stderr: 'gitRunFail: $e',
        command: 'git ${args.join(' ')}',
      );
    }
  }
}

GitRunner createRunner() => IoGitRunner();
