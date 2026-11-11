import 'package:git_geek/features/tags/domain/tags_repository_contract.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tags_providers.g.dart';

/// Tags 仓储的**契约声明**：只声明类型，不提供默认实现。
///
/// 具体实现由组合根 `app/bootstrap.dart` 用 `overrideWith` 工厂注入
/// （`ProviderScope.overrides`）。未 override 就读取会在首次求值时显式抛错，
/// 不会静默造出第二个实现实例。
///
/// 用默认 autoDispose：仓储只持 `final` 依赖、不存可变数据，重建只是
/// 重新绑定引用；缓存与串行锁由它依赖的组件持有（`appDatabaseProvider`、
/// `remoteRepoResolverProvider` 各自 keepAlive）。
@riverpod
TagsRepositoryContract tagsRepository(Ref ref) => throw UnimplementedError(
      'tagsRepositoryProvider 必须在 bootstrap 中由组合根 override 注入实现',
    );
