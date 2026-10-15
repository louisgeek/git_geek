# 多语言翻译管线 · 设计文档

## 1. 它是什么

一台**通用的翻译管线工具**。核心约束：**人工不直接编辑产品文件**。

```
 人工 add（只写收件箱）        管线 ingest（唯一动产品文件的入口）
┌──────────────────┐        ┌──────────────────────────────┐
│ inbox.json    │  ───►  │ app_en.arb / app_zh_Hant.arb │
│ （append-only）   │        │ （行级插入，其余字节不动）    │
└──────────────────┘        └──────────────────────────────┘
```

| 输入 | 位置 | 性质 |
|---|---|---|
| 单一 en 待翻译源 | `pipeline.yaml` 的 `source.path` | 唯一真相源，**仅管线可写** |
| 项目描述 | `config/brief.yaml` | **管线消费**：注入 prompt + 机械可查约束 |
| 结构化术语表 | `config/glossary.csv` | **管线消费**：注入 prompt + 机械合规比对 |
| 人工待处理项 | `<源目录>/inbox.json` | 人工唯一可写 |

**关键点**：项目描述与术语表不是"附赠的说明文档"。它们被两个阶段机械地消费掉——
`assemble` 阶段把命中项注入 prompt，`qa` 阶段拿它们做规则比对。
一份 markdown 术语表对管线零作用，因为它无法被程序查询。

### 1.1 为什么必须有收件箱这一层

若让 `add` / `set` 直接写产品文件（初版就是这样），会有三个问题：

1. **并发冲突** —— 两人同时改同一个 arb，git 上直接打架
2. **职责混淆** —— 产品文件既有人工历史又混入机器产物，来源不可辨
3. **无法审计** —— 不知道某条是人写的还是机器翻的、何时加的

收件箱用**每行一条**的追加式格式：只追加不重排。这让它天然适合 diff
与合并（冲突面只有新增的那几行），也天然规避了「重排整个文件」这个我们
专门花大力气规避的问题（见 1.5）。建议提交进 git 让团队共享待处理项。

### 1.2 三个命令构成完整回路

```bash
# 1. 登记（只写收件箱，绝不碰产品文件）
python -m pipeline add --key btnFoo --text "Foo button" --description "..."
python -m pipeline add --key btnFoo --locale zh-Hant-TW --text "..." --replace

# 2. 查看
python -m pipeline inbox

# 3. 落地（唯一动产品文件的入口；成功项出箱，失败项留箱）
python -m pipeline ingest
```

`add` 在登记时就做查重与规范校验（lowerCamelCase、key 是否已存在、
术语命中、长度超限、源文混入 CJK），并预览警告 —— 让人在**写入收件箱那一刻**
就知道会不会有问题，而不是等到 ingest 才发现。

`ingest` 的处理顺序是「先源后译文」：源侧 key 必须先落地，译文才有意义。

### 1.3 翻译者可以是任何东西：agent 模式

初版把翻译硬绑在 `OpenAICompatProvider` 上，于是"没 API key 就跑不了"。
但翻译的本质是**给定上下文与规则产出一段文本** —— 执行者可以是 API 模型、
在场的智能体、或一个懂中文的人。管线不该关心是谁。

`pipeline batch export | import` 把待翻译条目连同**装配好的上下文**
（地区规则、命中术语与标准译法、禁用译法、长度上限、占位符）导出成 JSON
清单；填好 `translation` 后回填，过**完全相同的 QA 闸门**再写产物。
空 `translation` 拒绝落地。

设计要点：「谁来翻」自由，但「**翻完必须过检查**」不变 ——
这是它与直接手改 arb 的本质区别。

### 1.4 产物文件名必须显式映射

`output.file_map` 把 locale 映射到宿主工程既有的文件名：

```yaml
file_map:
  zh-Hans: zh          # → app_zh.arb
  zh-Hant-TW: zh_Hant # → app_zh_Hant.arb
  zh-Hant-HK: zh_Hant_HK
```

不能直接用 `{locale}` 拼 BCP-47 标签 —— 本项目用 `app_zh_Hant.arb` 表示
"繁体台湾桶"，若生成 `app_zh-Hans.arb` 会凭空多一套工程里不存在的文件，
而且 `gen_l10n` 不会加载它，问题会被静默掩盖。

### 1.5 产物写入必须保持原有 key 顺序

**实测踩坑**：`write_arb` 最初按 `entries`（源文件顺序）输出，而译文文件的
key 顺序与源文件**本来就不一致** —— 该项目 126 个 key 里只有 3 个位置相同。
于是每次写入都把译文文件整体重排：

```diff
   "about": "關於",
+  "aboutTitle": "關於 GitGeek",        ← 被挪到第 5 行
   "aboutVersionLabel": "版本",
   ...
-  "aboutTitle": "關於 GitGeek"          ← 原本在末尾
+  "str_app_version_available": "..."
```

**内容一个没变，位置全变了。** 这类 diff 比脏 diff 更危险 —— 它把真正要审的
那一行淹没在"全文件挪动"里，review 时看不出任何实质改动。

修法：`_output_order()` 优先沿用**目标文件原有顺序**，新 key 追加到末尾：

```diff
   "subConflict": "衝突",
-  "aboutTitle": "關於 GitGeek"
+  "aboutTitle": "關於 GitGeek",
+  "str_app_version_available": "版本 {version} 可用"
```

2 增 1 删（那 1 删只是给末行补逗号）。`write_json` / `write_key_value` 同样处理。

### 1.6 写入必须是"外科手术式"，不能整体重写

产物写入统一走 `stages/jsonpatch.py` 的行级 `upsert`：

- 已有 key 改值 → **只替换那一行**
- 新增 key → 在最后一个顶层 key（含其 `@key` 嵌套块）之后**追加一行**
- BOM、CRLF/LF、缩进、行尾空格、`@key` 元数据、key 顺序 —— 全部原样保留

**为什么不 `json.dumps` 全量重写**：往返会重排 key、规范化缩进、抹掉行尾空格。
即使内容恰好一致，也把整份文件重新序列化了一遍；一旦文件有刻意的格式
（UI 拼接依赖的行尾空格等）就会静默丢失。

实现要点（第一版栽在这里）：
- 不做「插入多处 + 逐个补逗号」的增量操作 —— 行号会漂移、补逗号会补错位置
- 流程固定为：读成行视图 → 一次性改完 → **统一规整逗号** → 校验 → 一次写
- 逗号规整要识别 `@key` 嵌套块：块内部不动，只看块闭合行
- 插入点要跳过整个嵌套块，不能停在最后一个 `}` 之前
- 写前双重校验：合法 JSON + 原有 key 一个不少（按 key 比对，不是按行）

13 个场景回归覆盖：平铺/嵌套/CRLF/BOM/空文件/多块/幂等/删除/嵌套元数据。

### 1.7 源文件写入同样走外科手术

源文件通常有人工历史（缩进风格、行尾空格、注释、key 顺序含义）。
朴素的 `json.loads` → `json.dumps(indent=2)` 往返会重排整个文件：

```
{                                    {
    "@comment": "勿重排顺序",    →       "@comment": "勿重排顺序",
    "loadingLocal": "Reading… ",         "loadingLocal": "Reading… ",
    "oldIndented":    "  多余空格  "  "oldIndented":    "  多余空格  "
}                                    }
```

实测：diff 从 **2 行** 变成 **全文件**，真正要审的那一行被淹没；
还可能引入 review 时看不出的语义漂移（例如刻意保留的行尾空格是 UI 拼接布局的一部分）。

因此 `new` 只做**行级插入**，并遵守四条硬约束：

1. 绝不改写已有 key 的值 —— 冲突时直接报错，由人决定
2. 绝不重排已有 key 的顺序
3. 绝不重排缩进 / 行尾空格 / 注释 / 换行符（CRLF 与 LF 都原样保留）
4. **写入前双重校验**：新内容必须是合法 JSON，且原有每一行都仍存在 —— 任一不满足则放弃写入

实现要点：

- 二进制读写（`read_bytes` / `write_bytes`）并禁用换行转换，避免 Windows 上
  `open(..., 'w')` 把整个文件转成 CRLF
- 探测顶层缩进基准（取最少缩进层级），支持整体缩进的历史文件
- 平铺文件的新 key 与既有 key **同级**；有嵌套时才缩进一级
- 自写行级渲染器而非 `json.dumps` 后逐行加逗号—— 后者会让嵌套对象的
  **开括号行**也挂上逗号，产出非法 JSON
- 写 arb 的 `@key` 元数据时，逗号只加在标量行与闭合行，**开括号行永不挂逗号**

实测（真实 126 key 的 `app_en.arb` 加一条带占位符的文案）：

```diff
   "subConflict": "Conflict"
+  "subConflict": "Conflict",
+  "btnRefreshCache": "Refresh remote cache {n}",
+  "@btnRefreshCache": {
+    "placeholders": {
+      "n": {
+        "type": "String"
+      }
+    },
+    "description": "按钮，n 为数量"
+  }
```

diff 只有新增的 10 行 + 末行补逗号，其余字节零改动，缩进风格一致。

回归覆盖 5 个场景：平铺历史文件、嵌套文件、重复 key 拒绝、非法命名拒绝、空文案拒绝 —— 全部通过，且拒绝时源文件保持原样。

## 2. 管道七阶段

```
extract → diff → tm → assemble → translate → qa → emit
 提取      增量    记忆   上下文装配   仅翻未命中   机械闸门   产物
```

| 阶段 | 模块 | 职责 | 关键设计 |
|---|---|---|---|
| 1 extract | `adapters/sources.py` | 抽 `(key, 源文, 占位符, 注释)` | 格式差异在此被抹平，新增格式只改这一处 |
| 2 diff | `stages/diff.py` | 判定每条要不要重翻 | 指纹 = `hash(源文) ⊕ glossary版本 ⊕ brief版本 ⊕ locale` |
| 3 tm | `stages/tm.py` | 记忆检索，命中即免翻 | 精确 + 归一化相似（阈值 0.92） |
| 4 assemble | `stages/assemble.py` | 装配 prompt | **只注入本条命中的术语**，不全表灌 |
| 5 translate | `stages/translate.py` | 调模型 | Provider 可插拔，`mock` 供离线 |
| 6 qa | `stages/qa.py` | 机械闸门 | blocking ⇒ **不写产物**，退出码 2 |
| 7 emit | `stages/emit.py` | 写产物 + TM 入库 + 报告 | 缺失回落 en，不卡住发布 |

## 3. 增量判定的关键设计

**只比源文 hash 是不够的。** 改了术语表或项目描述后，即使源文一字未动，
译文也可能过时（例：`refresh` 的 zh-Hant-TW 标准译法从「刷新」改为「重新整理」，
源文没变，但 12 条含 refresh 的文案全部该重翻）。

所以指纹必须把三个输入都编进去：

```python
fingerprint = f"{source_hash}.{glossary_version}.{brief_version}.{locale}"
```

实测验证：

| 场景 | 结果 |
|---|---|
| 源文未变 | 126 全部 `unchanged`（零 LLM 调用） |
| 只改 1 条源文 | `unchanged` 125 + `changed` 1 |
| 改了术语表 + brief | `ctx_changed` 121 + `changed` 5（**全部重翻**） |

## 4. 质检闸门规则

全部为确定性规则，不依赖 LLM 自觉。

| 规则 | 级别 | 说明 |
|---|---|---|
| `placeholder_mismatch` | BLOCK | 占位符漏译/多译。最高频事故 |
| `empty_translation` | BLOCK | 空译文 |
| `untranslated` | BLOCK | 译文与源文完全相同（源含 CJK 时） |
| `forbidden_term` | BLOCK | 命中术语表该 locale 的禁用译法 |
| `missing_term` | BLOCK | 源文术语的标准译法未出现在译文中 |
| `too_long` | BLOCK | CJK 长度超 brief 上限 |
| `forbidden_phrase` | BLOCK | 命中 brief 的禁忌短语 |
| `trailing_space` | WARN | 行尾空格（UI 拼接设计常需豁免） |
| `halfwidth_punct` | WARN | 中文里混用半角标点（团队风格常需豁免） |
| `cross_locale_term` | WARN | 同 key 在不同地区档用词差异未登记 |

## 5. 两个实测得出的重要结论

### 5.1 简繁/地区用词差异**无法靠字表检测**

第一版用字符类 `[標籤據設獲...]` 查简繁混用，报出 41 处。逐条核查后发现
**几乎全是假阳性**——「提交」「資料」「提取」「程」等在简体和台湾档里
codepoint 完全一致，却是简繁共通字。

结论：地区用词差异只能做**词条级比对**（`glossary.lookup_target`）。
这直接决定了术语表必须是结构化 CSV，而不是文档。

### 5.2 `forbidden` 列必须是**按 locale 生效**的

第一版 forbidden 是全局列，导致 zh-Hans 的标准译法「克隆」被自己的
forbidden 判为违规——因为「克隆」是为台港列的禁用译法。
**误报 305 条。**

正确模型：一个词可能在 A 档是标准译法、在 B 档是禁用译法
（`仓库` 对简中正确、对台港禁用）。所以：

```
forbidden,zh-Hans:重新載入;zh-Hant:倉庫;all:foo
```

配套需要**双向 locale 匹配**，因为 Flutter 用桶码（`zh_Hant`）而
brief/glossary 常写完整标签（`zh-Hant-TW`）。桶级规则（`zh-Hant:`）
能被两者命中，地区级规则（`zh-Hant-TW:`）只能被前者命中——
**因此桶级规则应写在桶码上**。

### 5.3 术语表需要自洽性校验

`local` 那一行我随手写了 `zh-Hant:遠端`（意为繁体禁用「遠端」），
但「遠端」正是 `remote` 在繁体档的标准译法。QA 闸门因此把正确译文判为违规。

`Glossary.validate()` 在**加载期**就抓出这类冲突：

```
术语「local」禁用「遠端」，但该词是术语「remote」的标准译法
```

核心不变式：**禁用译法不得是任何术语在该 locale 的标准译法。**

## 6. 实测数据（git_geek 126 key）

用真实 arb 跑出来的结果：

| 指标 | 值 |
|---|---|
| 抽取条目 | 126 |
| 命中术语表 | 76 条（24 条术语） |
| 误报（修 locale 匹配前） | 305 条 |
| 误报（修 locale 匹配 + 术语表自洽后） | **33 条，且全部是真实错误** |

剩下 33 条是真实问题：台湾档 8 处用了「倉庫」而非「儲存庫」，
香港档存在「位址/地址」混用——正是术语表该抓的漂移。

## 7. 已知边界

- **翻译质量本身无法机械保证**。闸门只保证格式、术语、结构合规。
  语义是否通顺仍需人工抽检（阶段 6 之后的流程，当前未自动化抽检比例）。
- `MockProvider` 只做英文单词替换，产出的中文必然不合规——
  它的用途是验证链路，不是产出可发布文案。
- 相似命中阈值 0.92 对短句偏严，可能漏掉本可复用的条目；调低会增加误复用风险。
- 未实现：批量化/并发调用、抽检抽样、问题自动回流到 glossary。

## 8. 命令

```bash
# 人工侧（只写收件箱，不碰产品文件）
python -m pipeline add --key btnFoo --text "Foo button" --description "..."
python -m pipeline add --key btnFoo --locale zh-Hant-TW --text "..." --replace
python -m pipeline inbox
python -m pipeline ingest             # --dry-run 只校验

# 管线侧
python -m pipeline extract
python -m pipeline run
python -m pipeline run --locales ja de --provider openai
python -m pipeline qa                 # 只质检（CI 用）
python -m pipeline glossary --matrix
python -m pipeline tm --stats --list
```