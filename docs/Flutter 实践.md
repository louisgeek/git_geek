# Flutter 实践

1 main.dart → bootstrap.dart → app.dart
```
main.dart 管进进程
bootstrap.dart 管启动前置条件
app.dart 管界面装配
```

2 app → features → shared → core 单向依赖
```
app 依赖 features、shared、core
features 依赖 shared、core
shared 依赖 core
core 最底层，跟业务无关，无 Flutter 依赖，可以跨项目复用
```

3 Repository 模式，按需引入接口
4 Result 惯用法
5 Feature-first，features 按用户任务划分 feature，feature 内再按层（data/domain/presentation）切分
6 data/domain/presentation 模型
```
data 里模型 XxxDto，DTO 不出 data 层，用 json_serializable，出去前必须经 mapper 转成 domain 模型
domain 里模型 Xxx 不带后缀，纯业务，用 freezed 管 copyWith 和相等性，无 Flutter 依赖
presentation 里模型 XxxState，用 freezed 管 copyWith 和相等性，只含 UI 字段
```

7 定义 Logger 接口，通过依赖注入 Repository 使用，不采用 LogUtil 形式
8 常用前缀：doXxx、onXxx、fetchXxx、normalizeXxx（归一化） 、resolveXxx 解析（解决）
9 同文件 xxx_notifier.dart 放 XxxNotifier + XxxState 是 Flutter Riverpod 官方常见组织，小 feature 内聚好；大了再拆 xxx_state.dart（和 Android 的 XxxViewModel.kt 同文件放 XxxViewModel + XxxUiState 一致，在小 feature 里很常见，大了才拆成 XxxUiState.kt 单独文件）
10 xxx_factory（纯构造）+ xxx_providers（DI 装配） 是 Riverpod 项目的常规组合,原则：构造复杂到值得单测就单拎形成 factory，否则直接写 providers 里
11 异步实例才进 bootstrap 预加载（比如 SharedPreferences），同步 const 构造一律留在 provider 里懒创建（比如 FlutterSecureStorage）








##
2 app：启动、router/navigation、di、network（dio）
core：network（dio_client、interceptor）、logger、storage（cache）
1 应用级 di 放 app 里，功能级 di 放 features 中对应的功能里（备选）