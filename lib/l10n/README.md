# 多语言（l10n）

采用 Flutter 官方方案：`flutter_localizations` + `gen_l10n`（SDK 自带命令行工具，ARB 文件驱动）

## 目录结构

```
lib/l10n/
  app_en.arb          # 手写源：key 清单 + @key 元数据（模板，占位符/类型声明都在这）
  app_zh.arb          # 手写源：key → 简体中文（只写值，不写元数据）
  app_zh_Hant.arb     # 手写源：key → 繁體中文（臺灣用詞）
  app_zh_Hant_HK.arb  # 手写源：key → 繁體中文（香港用詞）
  gen/                # flutter gen-l10n 生成产物，禁止手改
    app_localizations.dart       # 抽象类 + delegate + lookupAppLocalizations
    app_localizations_en.dart
    app_localizations_zh.dart    # 含 Zh / ZhHant / ZhHantHk 三个实现类（按语言分组）
```

- `l10n.yaml` 为工具配置（`template-arb-file: app_en.arb`，`output-dir: lib/l10n/gen`）
- en 是模板语言：基语言缺 key 时回退英文；地区变体缺 key 时继承同 language 基类
- 生成文件 import 路径统一为 `package:git_geek/l10n/gen/app_localizations.dart`

## ARB 文件名格式

| 输入语言标签 | CLDR `likelySubtags` 最大化结果 | 含义 |
|---|---|---|
| `zh` | `zh-Hans-CN` | 简中·大陆 |
| `zh-CN` | `zh-Hans-CN` | 简中·大陆 |
| `zh-SG` | `zh-Hans-SG` | 简中·新加坡 |
| `zh-MY` | `zh-Hans-MY` | 简中·马来西亚 |
| `zh-TW` | `zh-Hant-TW` | 繁中·台湾 |
| `zh-HK` | `zh-Hant-HK` | 繁中·香港 |
| `zh-MO` | `zh-Hant-MO` | 繁中·澳门 |
| `zh-Hans` | `zh-Hans-CN` | 简中·大陆 |
| `zh-Hant` | `zh-Hant-TW` | 繁中·台湾 |

- 输入语言标签：比如手机系统语言设置里的 zh-HK、浏览器 Accept-Language 里的 zh-TW、代码里写的 Locale('zh')

| 项目不提供 | 自然解析去向                                | 项目内最终归属                 |
|---|---------------------------------------|-------------------------|
| `zh-Hans-CN` | 简体·大陆（`zh`）                              | 简体·大陆（无需专属文件）           |
| `zh-Hans-SG` | 简体·大陆（语言+地区无 SG 条目，掉到 `zh`）              | 简体·大陆（新加坡本来就用简体，无需专属文件） |
| `zh-Hans-MY` | 简体·大陆（语言+地区无 MY 条目，掉到 `zh`）              | 简体·大陆（马来西亚通常用简体，无需专属文件） |
| `zh-Hant-MO` | 繁体·台湾（语言+文字先匹配上，掉到 `zh_Hant`） | 繁体·香港（需要手动纠正，澳门通常用港式繁体） |

- CN/SG/MY 无专属文件是刻意的（自然解析通常即正确）；MO 是唯一需要手动纠正的，通过 `fromLocale` 里 HK/MO 代码分支处理
- 文字已足够区分简繁时，地区可省（如 `zh_Hant` 不必写成 `zh_Hant_TW`，省了还能顺带兜底无 region 设备）

| arb 文件 | `@@locale` | 覆盖的最大化结果 | 说明 |
|---|---|---|---|
| `app_en.arb` | `en` | — | 英文模板：key 清单 + `@key` 元数据唯一来源 |
| `app_zh.arb` | `zh` | `zh-Hans-CN`、`zh-Hans-SG`、`zh-Hans-MY` | 简体全包（大陆/新马） |
| `app_zh_Hant.arb` | `zh_Hant` | `zh-Hant-TW` | 繁体·台湾 |
| `app_zh_Hant_HK.arb` | `zh_Hant_HK` | `zh-Hant-HK`、`zh-Hant-MO`（经 `fromLocale` 手动归入） | 繁体·香港（含澳门） |


## 生成命令

在**项目根目录**执行（子目录运行会因找不到项目配置而误报 generate 未开启）：

```bash
# 项目根目录执行
flutter gen-l10n
```

配了 `generate: true`（pubspec），`flutter run/build` 时也会自动触发；单独改 ARB 后跑上面命令即可。

## 加一条翻译的流程

1. 在 `app_en.arb` 加 key + 英文文案；带占位符时补 `@key` 元数据：

   ```json
   "tagsDeleted": "Deleted {count} tags",
   "@tagsDeleted": { "placeholders": { "count": { "type": "int" } } }
   ```

2. 在各中文 arb 加同 key 译文（只写值，台/港注意用词差异）。
   地区变体技术上可省略与基语言完全相同的 key（只写差异部分，缺的运行时自动继承基类文案），
   但更推荐全量显式写出：重复一行换来的是“每个语言的文案一眼可审计”，
   漏译/误继承不会静默发生，加 key 时也不用逐个文件回忆哪些省略过：

   ```
   "tagsDeleted": "已删除 {count} 个标签"   // app_zh.arb
   "tagsDeleted": "已刪除 {count} 個標籤"   // app_zh_Hant.arb（臺灣）
   "tagsDeleted": "已刪除 {count} 個標籤"   // app_zh_Hant_HK.arb（香港）
   ```

3. `flutter gen-l10n`，漏译/缺 en 侧 key 会有 untranslated 提示

4. 使用：

   ```dart
   // UI 层（有 context）
   final t = AppLocalizations.of(context);
   Text(t.tagsDeleted(3))

   // 无 context（data 层 / Notifier）
   final t = t(AppLang.zh);  // strings.dart 里的 helper，内部走 lookupAppLocalizations
   ```

## 注意

- 输入输出粒度不同：ARB 按 locale 分文件（翻译工作单元），Dart 产物按 language 分文件
  （如 `ZhHant`/`ZhHantHk` 都在 `app_localizations_zh.dart` 里）。
- 子类只生成其 arb 里实际存在的 key，缺的 key 不生成、运行时走 Dart 继承：
  例如某地区变体缺 key 时，继承同 language 基类的值（如简体），只有基类也没有才报 untranslated（回退 en 模板）。
  因此地区变体的 arb 允许只写差异 key；但漏写会静默显示基类文案，
  目前各语言保持全量显式。缺 key 时的回退：基语言缺 key → en 模板；地区变体缺 key → 同 language 基类
- 占位符类型支持 `String`/`int`/`num`/`DateTime`，数字用 `int` 可获得各语言数字格式化
- ICU 语法限制：字面 `{`/`}` 无法用引号转义，需改走占位符传参（如 `@key` 内声明 `placeholders`）
- MaterialApp 已接入 `localizationsDelegates`/`supportedLocales`，`locale` 由 Riverpod 状态（设置的语言）驱动，切换即时生效
- 1. **继承 ≠ 复用翻译文本**，文本来自各自 ARB，全部重写是生成器强制行为，**Dart 类继承 ≠ 翻译文本继承**，继承链只复用**格式化逻辑（复数 / 日期）**，**翻译字符串完全不走 Dart 继承链查找**
- 2. 继承拿到：**统一接口 + 公共格式化逻辑 + 语言层级 fallback 体系**；
- 3. 类型层面：所有中文变体共享同一个父接口，上层代码不需要区分繁简类型。
