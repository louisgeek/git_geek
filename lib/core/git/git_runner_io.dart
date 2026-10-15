import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:git_geek/core/git/git_runner_base.dart';

/// 桌面/移动端 git 执行器：基于 dart:io Process 调本地 git CLI
class IoGitRunner extends GitRunner {
  @override
  bool get supportsNativeGit => true;

  /// 执行 git 命令：空目录归一为 null（用当前目录）
  @override
  Future<GitResult> run(
    String? workDir,
    List<String> args, {
    void Function(String line)? onProgress,
  }) async {
    // 空路径/点都归一为 null，避免传 `-C .` 影响相对路径语义
    final displayWorkDir =
        (workDir == null || workDir == '.' || workDir.trim().isEmpty)
        ? null
        : workDir;
    //Dart 进程只有一个 cwd（进程当前所在目录），多仓库并发查时 cd 会互相踩，用 -C 每个命令各指定各的目录（让每个命令自带目录信息），互不干扰
    final fullArgs = <String>[
      if (displayWorkDir != null) ...['-C', displayWorkDir],
      ...args,
    ];
    try {
      //Process.start 起一个外部进程，但不等它跑完，立刻返回 Process 句柄 proc ，通过 proc 实现边跑边收输出
      //runInShell=false 直接拉起 git.exe，不过 shell
      final proc = await Process.start('git', fullArgs, runInShell: false);
      final stdoutBuf = StringBuffer();
      final stderrBuf = StringBuffer();
      final outDone = Completer<void>();
      final errDone = Completer<void>();
      proc.stdout
          .transform(utf8.decoder)
          .listen(
            (chunk) {
              stdoutBuf.write(chunk);
              if (onProgress != null && args.firstOrNull == 'clone') {
                //仅 clone 回调 stdout 进度
                for (final line in const LineSplitter().convert(chunk)) {
                  onProgress(line);
                }
              }
            },
            onDone: () => outDone.complete(),
            onError: (_) => outDone.complete(),
          );
      proc.stderr
          .transform(utf8.decoder)
          .listen(
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
      final exitCode = await proc.exitCode;
      //等流刷完再取值，避免 stdout/stderr 截断
      await Future.wait([outDone.future, errDone.future]);
      final stdout = stdoutBuf.toString();
      var stderr = stderrBuf.toString().trimRight();
      //无 stderr 但非零退出时补一句，避免上层拿到空错误
      if (stderr.isEmpty && exitCode != 0) {
        stderr = 'git ${args.join(' ')} 退出码=$exitCode';
      }
      return GitResult(
        ok: exitCode == 0,
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

/// 创建桌面/移动端 git 执行器。
GitRunner createRunner() => IoGitRunner();
