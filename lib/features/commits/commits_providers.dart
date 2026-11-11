import 'package:git_geek/features/commits/domain/commits_repository_contract.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'commits_providers.g.dart';

/// Commits 仓储的**契约声明**：只声明类型，不提供默认实现。
///
/// 具体实现由组合根 `app/bootstrap.dart` 用 `overrideWith` 工厂注入。
/// 未 override 就读取会在首次求值时显式抛错。
///
/// 用默认 autoDispose：仓储只持 `final` 依赖、不存可变数据，重建只是
/// 重新绑定引用；串行锁由 `remoteRepoResolverProvider`（keepAlive）持有。
@riverpod
CommitsRepositoryContract commitsRepository(Ref ref) =>
    throw UnimplementedError(
      'commitsRepositoryProvider 必须在 bootstrap 中由组合根 override 注入实现',
    );
