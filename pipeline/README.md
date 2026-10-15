# 多语言翻译管线

单 en 源 + 项目描述 + 术语表 → 管道执行一遍 → 多语言产物。

设计与实现说明见 [DESIGN.md](DESIGN.md)。

## 人工写在这个文件里

**`../lib/shared/l10n/inbox.json`** —— 与各语言文件平级，一眼可见。

```bash
python -m pipeline init      # 首次创建（已随项目提供）
```

格式极简，就是 key-value：

```
"str_app_version_available": "Version {version} is available"
```

### 完整语法

| 写法 | 含义 |
|---|---|
| `// ...` | 注释，忽略 |
| `"key": "文案"` | 一条文案 |
| `-- zh-Hant-TW` | 切换目标语言，影响后续所有条目 |
| `--replace` | 允许覆盖已有 key |
| `-- 说明文字` | 给翻译模型的提示 |

实际例子：

```
"btnSave": "Save changes"
"newVersion": "Version {version} is available"
"btnHelp": "Help" -- 问号图标的 tooltip

-- zh-Hant-TW
"btnSave": "儲存變更"
"btnDelete": "刪除" --replace
```

**直接手写这个文件就行**，也可以用命令行（自动格式化与校验）：

```bash
python -m pipeline add --key btnSave --text "Save changes" --description "工具栏主按钮"
python -m pipeline add --key btnSave --locale zh-Hant-TW --text "儲存變更" --replace
```

### 为什么后缀是 `.json`

Flutter 源码（`flutter_tools/lib/src/localizations/gen_l10n_types.dart`）
把扫描规则写死了：

```dart
final filenameRE = RegExp(r'(\w+)\.arb$');
directory.listSync().whereType<File>().where((e) => filenameRE.hasMatch(e.path))
```

**只扫 `.arb`，其他后缀一律不看。** 所以 `arb-dir` 下的 `.json`
（以及 `.txt` 等）都不会被解析或报警。已实测：`inbox.json` 放进去，
`flutter gen-l10n` 退出码 0、零警告、生成产物里不含它的 key。

唯一要避开的是 `.arb` —— 它匹配上面的正则，会被当成语言文件，
并因无法从文件名推断 locale 而报 `locale could not be determined`。

注意本文件**不是合法 JSON**（无外层 `{}`、无逗号分隔），
它只是长得像 JSON 的 key-value 文案表。

### 目录长什么样

```
lib/shared/l10n/
  arb/
    app_en.arb            ← 源文件，管线写，人工不碰
    app_zh.arb            ← 产物，管线写，人工不碰
    app_zh_Hant.arb       ← 产物，管线写，人工不碰
    app_zh_Hant_HK.arb    ← 产物，管线写，人工不碰
    inbox.json            ← 【人工只写这个】待翻译收件箱，入库共享
  gen/                    ← gen_l10n 生成产物

pipeline/
  config/                 ← pipeline.yaml / brief.yaml / glossary.csv
  .cache/                 ← 机器本地产物，不入库
    baseline/<locale>.json  ← 增量基线
    tm.json                  ← 翻译记忆库
```

**为什么收件箱和各语言文件放一起**：开发者打开 l10n 目录就该能看到"该写哪个
文件"，不该要翻隐藏目录或读文档才知道。命名 `inbox.json` 与 `app_*.arb`
不冲突 —— `gen_l10n` 只扫 `.arb`（源码已确认），`.json` 一律不看。

**为什么 baseline / tm 单独放**：它们是机器本地产物（增量状态、记忆库），
混进人工可读的目录只会干扰。放在 `pipeline/.cache/`，已 gitignore。

`inbox.json` **建议提交进 git**：append-only 的冲突面只有新增的那几行，
团队能共享待处理项；`baseline/` 与 `tm.json` 是本地产物，已在
`.pipeline/.gitignore` 里排除。

### 完整回路（三个命令）

```bash
# 1. 登记（手写 inbox 或用 add）
python -m pipeline inbox            # 查看待处理
python -m pipeline add --key ... --text "..."

# 2. 落地：自动去重 + 改写代码引用 + 写入 en 源
python -m pipeline ingest
python -m pipeline ingest --dry-run          # 先看会改什么
python -m pipeline ingest --accept-fuzzy     # 确认疑似重复也可合并
python -m pipeline ingest --apply-refs       # 实际改写代码引用（默认只预览）

# 3. 翻译：产出全部语言文件 + 清除收件箱 + 出复查报告
python -m pipeline run
```

## 不配 API key 也能译：agent 模式

翻译的本质是"给定上下文产出文本"——执行者可以是 API 模型、**在场的智能体**、
或一个懂中文的人。管线不该关心是谁。

`batch` 命令把待翻译条目连同**装配好的上下文**（地区规则、命中术语与标准译法、
禁用译法、长度上限、占位符）导出成 JSON 清单，填好 `translation` 后回填落地。

```bash
# 导出待办（--only-missing 只导现有产物里缺的）
python -m pipeline batch export --only-missing
# → 产出 lib/shared/l10n/arb/translate-tasks.json

# 填好每条的 translation 字段后回填（过完整 QA 闸门 + 写产物 + 出复查报告）
python -m pipeline batch import
```

清单长这样——上下文是齐的，翻译者不需要回头翻配置：

```json
{
  "key": "str_app_version_available",
  "source": "Version {version} is available",
  "locale": "zh-Hant-TW",
  "placeholders": ["version"],
  "hit_terms": ["refresh → 重新整理（禁用：重新載入）"],
  "locale_rules": ["用词：重新整理 / 資料 / 標籤 / 儲存庫"],
  "max_length": 24,
  "translation": ""
}
```

**空 `translation` 会被拒绝落地**，不会半成品写进产物。
"谁来翻"自由，但"翻完必须过检查"不变 —— 这是 agent 模式与直接手改 arb 的本质区别。

### 1. 自动去重

`ingest` 先在 en 源里找等价 key，命中则**丢弃待翻译项**并把代码引用改指向已有 key：

| 级别 | 判据 | 动作 |
|---|---|---|
| `exact` | 源文完全相同 | 自动复用，丢弃待翻译项 |
| `normalized` | 去标点/大小写后相同 | 自动复用，丢弃待翻译项 |
| `fuzzy` | 相似度 ≥ 0.72 | **阻断**，需 `--accept-fuzzy` 确认 |
| — | 无匹配 | 正常新增 |

模糊命中默认阻断而非自动合并——"看起来像但语义不同"被错误合并的代价
远大于多问一句。

### 2. 代码引用改写是白名单驱动的

复用已有 key 时要把 `t.oldKey` 改成 `t.newKey`。但 `t` 也可能是普通 Dart 变量
（`t.name`、`t.length`、`t.split`）。所以策略是**白名单**：只有捕获到的名字
确实是 en 源里存在的 key 才改写，`t.name` 天然被排除——不需要维护
"哪些成员名不是 key"的脆弱黑名单。

同时覆盖两种引用形态：`t.key`（UI 层）与 `t(AppLang.zh).key`（data 层），
并跳过 `l10n/gen` 生成目录。

**默认只预览不落盘**，需 `--apply-refs` 才真正改代码。

### 3. 收件箱自动出箱

`run` 成功后清除翻译完的条目。判定条件是**所有语言都有非 fallback 译文**——
任何一种语言还落回英文就说明没翻完，留在箱里等人处理。

于是**收件箱里剩下的永远是"还没搞定的东西"**，可以直接当待办清单用。

### 4. 复查报告

机械闸门保证形式合规，但保证不了语义正确。`run` 结束后输出复查清单：

| 复查原因 | 为什么机器判不了 |
|---|---|
| `llm` 首次翻译 | 没有对照基准，全新产出 |
| `tm_similar` 相似命中 | 复用的是"接近但不等价"的译文 |
| `fallback_en` 回落英文 | 该语言实际没译文，用户会看到英文 |
| `many_terms` 术语命中过多 | 可能是过度约束导致的不自然 |
| `placeholders` 含占位符 | 需确认语义与拼接 |
| `near_limit` 长度接近上限 | 未超限但窄屏可能被截断 |
| `script_mix` 字形疑似混用 | 词条级检查的漏网之鱼 |
| `human` 人工登记 | 未经机器校验 |

输出到 `report.json`（机器可读，供 CI）+ 终端摘要（人可读），
按高/中/低分级，高优先级会展开显示 en 源文与译文对照。

### 为什么要用收件箱

若人工直接写产品文件：两人同时改同一 arb 会在 git 上打架；产品文件既有人工
历史又混入机器产物，来源不可辨；也无法审计某条是人写的还是机器翻的。

收件箱是**每行一条**的追加式格式，只追加不重排，天然适合 diff 与合并
（冲突面只有新增的那几行），也天然规避了"重排整个文件"。
建议提交进 git 让团队共享待处理项。

## 完整命令表

```bash
# 人工侧
python -m pipeline add --key xxx --text "..."
python -m pipeline inbox
python -m pipeline ingest

# 管线侧
python -m pipeline run              # 源/语言/输出全从 pipeline.yaml 读
python -m pipeline run --locales ja de --provider openai
python -m pipeline extract
python -m pipeline qa               # 只质检（CI 用）
python -m pipeline glossary --matrix
python -m pipeline tm --stats --list
```

## 配置分三个文件，职责不重叠

| 文件 | 回答什么 | 谁消费 |
|---|---|---|
| `config/pipeline.yaml` | 源在哪、产物去哪（`file_map` 映射文件名）、目标语言、TM 在哪 | 管线接线 |
| `config/brief.yaml` | 产品是什么、什么语气、地区用词规则、禁忌词 | `assemble` 注入 prompt + `qa` 查长度/禁忌 |
| `config/glossary.csv` | 术语标准译法与禁用译法 | `assemble` 注入 prompt + `qa` 查合规 |

`output.file_map` 必须显式声明，因为产物文件名沿用宿主工程既有约定
（本项目是 `app_zh_Hant.arb` 表示"繁体台湾桶"），不是 BCP-47 标签。
若直接用 `{locale}` 拼接，管线会写出工程里不存在的 `app_zh-Hans.arb`，
凭空多一套产物且 `gen_l10n` 不会加载。

## 日常命令

```bash
# 开发者：加一条待翻译文案
python -m pipeline new --key xxx --text "..."
python -m pipeline new --key xxx --text "..." --dry-run    # 只校验不写入

# 看抽取结果与术语命中
python -m pipeline extract

# 跑完整管线（源/语言/输出全从 pipeline.yaml 读）
python -m pipeline run
python -m pipeline run --locales ja de --provider openai  # 临时覆盖

# 校验术语表自洽性 + 看译法矩阵
python -m pipeline glossary --matrix

# 只质检已有产物（CI 用）
python -m pipeline qa

# 查看记忆库
python -m pipeline tm --stats --list
```

## 换源格式

`adapters/sources.py` 里实现 `extract(path) -> list[Entry]` 并 `@register("fmt")`
即可，其余阶段无需改动。已支持 `arb` / `json` / `csv` / `po` / `md`。

## 接真实模型

```bash
export PIPELINE_LLM_BASE_URL=https://api.openai.com/v1
export PIPELINE_LLM_API_KEY=sk-...
export PIPELINE_LLM_MODEL=gpt-4o-mini

python -m pipeline run --provider openai
```

非 OpenAI 兼容网关改 `stages/translate.py` 的 `OpenAICompatProvider.base_url` 即可。