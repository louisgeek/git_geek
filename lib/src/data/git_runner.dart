import 'package:git_geek/src/data/git_runner_base.dart';
import 'package:git_geek/src/data/git_runner_stub.dart'
    if (dart.library.io) 'package:git_geek/src/data/git_runner_io.dart' as impl;

export 'package:git_geek/src/data/git_runner_base.dart';

final GitRunner gitRunner = impl.createRunner();
bool get supportsNativeGit => gitRunner.supportsNativeGit;
