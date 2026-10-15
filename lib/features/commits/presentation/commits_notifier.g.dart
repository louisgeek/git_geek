// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commits_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Commits 子 Notifier（新架构）：唯一持有 commits/branches/submodules +
/// 查询/排序/limit + 各自 loading/error。调用方传 repoPath/scope/remote/lang，
/// 内部一次 resolve 后并行拉取。

@ProviderFor(CommitsNotifier)
final commitsProvider = CommitsNotifierProvider._();

/// Commits 子 Notifier（新架构）：唯一持有 commits/branches/submodules +
/// 查询/排序/limit + 各自 loading/error。调用方传 repoPath/scope/remote/lang，
/// 内部一次 resolve 后并行拉取。
final class CommitsNotifierProvider
    extends $NotifierProvider<CommitsNotifier, CommitsState> {
  /// Commits 子 Notifier（新架构）：唯一持有 commits/branches/submodules +
  /// 查询/排序/limit + 各自 loading/error。调用方传 repoPath/scope/remote/lang，
  /// 内部一次 resolve 后并行拉取。
  CommitsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commitsNotifierHash();

  @$internal
  @override
  CommitsNotifier create() => CommitsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommitsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommitsState>(value),
    );
  }
}

String _$commitsNotifierHash() => r'39b0ac7ece2c9b3f89071ea0488208ba41d3d21a';

/// Commits 子 Notifier（新架构）：唯一持有 commits/branches/submodules +
/// 查询/排序/limit + 各自 loading/error。调用方传 repoPath/scope/remote/lang，
/// 内部一次 resolve 后并行拉取。

abstract class _$CommitsNotifier extends $Notifier<CommitsState> {
  CommitsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CommitsState, CommitsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CommitsState, CommitsState>,
              CommitsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
