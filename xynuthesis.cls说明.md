# xynuthesis.cls 修改说明

本文对 `xynuthesis.cls` 的结构和常见改动位置做逐段说明，告诉你“改什么 → 去哪里改”。  
建议优先通过 `xynuthesis/xynusetup.tex` 的 `\xynusetup{...}` 设置接口修改，只有需要改模板结构/版式时才修改 `.cls`。

## 快速索引（改什么 → 去哪里）

- 封面信息（题目/学位申请人/申请学位类别/专业学位领域/导师/院系/提交日期等）：`xynuthesis/xynusetup.tex` 的 `\xynusetup{...}` 与类选项（`degree`/`degree-type`）；内部渲染在 `xynuthesis.cls` 的“封面”段落（`\xynu@title@page@...`）。
- 页边距/页眉位置：`xynuthesis.cls` 中 `\geometry{...}` 与 `\fancypagestyle{plain}`。
- 标题字体大小与间距：`xynuthesis.cls` 中 `\ctexset{chapter/section/...}`。
- 中英文固定词汇（目录、致谢、参考文献等）：`xynuthesis.cls` 中 `\xynu@set@chapter@names`。
- 西文字体/中文字体/数学字体：`xynuthesis.cls` 的“字体”“数学字体”段落（`\xynu@set@font@...`、`\xynu@set@cjk@font@...`、`\xynu@set@math@font@...`）。
- 图表标题与表格正文字号：`xynuthesis.cls` 的“浮动体”段落（`\xynu@caption@font`、`\xynu@table@font`）。
- 参考文献引用样式：`xynuthesis.cls` 的“参考文献”段落（natbib/biblatex 设置）+ `xynusetup.tex` 里的 `\bibliographystyle{xynuthesis-...}`。
- 原创性/授权声明文字：`xynuthesis.cls` 中 `\xynu@originality` 与 `\xynu@authorization`。

## 1. 类选项与 `\xynusetup` 接口

**位置**：文件开头 `\xynu@define@key{...}` 与 `\xynu@option@hook{...}`。

`xynuthesis.cls` 通过 key-value 方式定义全局选项；这些选项可在：

- `\documentclass[...]{xynuthesis}` 中作为类选项传入
- `\xynusetup{...}` 中设置（推荐，集中放在 `xynusetup.tex`）

常见 key（在 `\xynu@define@key{...}` 中定义）：

- `degree`: `master`（学位层次）
- `degree-type`: `academic|professional|engineering`（学位类型）
- `main-language`: `chinese|english`（论文主语言）
- `language`: `chinese|english`（当前语言，允许正文局部切换）
- `output`: `print|electronic`（印刷/电子版影响超链接色彩、单双面等）
- `fontset`, `font`, `cjk-font`, `math-font`, `math-style` 等（字体相关）
- `cite-style`: `super|inline|authoryear`
- `badge-color`: `blue|black`
- `reviewer`: `true|false`（声明页是否显示评审专家签名）
- `eqn-paren-style`: `full|half`（中文括号/英文括号）

**新增/修改 key 的步骤**：

1) 在 `\xynu@define@key{...}` 中增加 key，并定义 `choices/default`  
2) 若需要执行逻辑，添加 `\xynu@option@hook{key}{...}`  
3) 如需兼容旧类选项，添加 `\DeclareVoidOption{...}{\xynusetup{key=...}}`

## 2. 语言与章节名称

**位置**：`处理语言` 段落。

- `\xynu@set@punctuations`：根据 `language` 处理中英文混用标点字符类。
- `\xynu@set@chapter@names`：设置目录/附录/致谢/参考文献等固定名词（中英版）。  
  这里可改 “致谢/附录/参考文献”等固定文本。
- `\xynu@set@names`：设置 `\figurename`/`\tablename` 的中英文。

## 3. 字体与字号

**位置**：`字体`、`数学字体` 段落。

### 3.1 正文字号/行距

- `\xynu@set@font@size`：设置 `\normalsize` 的字号与行距。
- `\linespread{1}`：整体行距倍率。

### 3.2 系统检测与字体集

- `system=auto` 时检测 `mac/windows/unix`。
- `fontset=auto` 根据系统与字体可用性选择 `windows/mac/ubuntu/fandol`。
- `font=auto` 根据 `fontset` 决定西文字体（Times/Termes）。

### 3.3 西文字体

**位置**：`\xynu@set@font@times`、`\xynu@set@font@termes`、`\xynu@set@font@stix`、`\xynu@set@font@xits`、`\xynu@set@font@libertinus`、`\xynu@set@font@newcm`、`\xynu@set@font@lm`、`\xynu@set@font@newtx`。

要更换西文字体：

- 新增一个 `\xynu@set@font@<name>` 宏
- 把 `<name>` 加入 `font` 的 `choices` 列表

### 3.4 中文字体

**位置**：`\xynu@set@cjk@font@windows`、`\xynu@set@cjk@font@mac`、`\xynu@set@cjk@font@noto`、`\xynu@set@cjk@font@fandol`。

要改中文字体：

- 修改对应宏里 `\setCJKmainfont`/`\setCJKsansfont`/`\setCJKfamilyfont` 的字体名  
- 或新增 `cjk-font` 选项并定义 `\xynu@set@cjk@font@<name>`

### 3.5 数学字体与符号样式

**位置**：`\xynu@set@math@style`、`\xynu@set@math@font@...`。

- `math-style` 会联动设置 `uppercase-greek`、`integral`、`real-part` 等细节。  
  具体逻辑在 `\xynu@set@math@style`。
- `math-font` 控制数学字体族，自动加载 `unicode-math` 或 `newtxmath`。  
  每个字体族的细节在对应 `\xynu@set@math@font@...` 宏内。

## 4. 纸张与页面（版心、页眉页脚）

**位置**：`纸张和页面` 段落。

- `\geometry{...}`：页边距、页眉/页脚位置，直接修改数值即可。
- `\pagestyle{fancy}` 与 `\fancypagestyle{plain}`：页眉/页脚内容与字号。  
  页眉使用 `\leftmark`。
- `\frontmatter`/`\mainmatter`：控制页码样式与起始页逻辑。

## 5. 封面与元信息

**位置**：`封面` 段落。

### 5.1 可设置字段（用 `\xynusetup{...}`）

位于 `\xynu@define@key{...}`：

- 题目：`title` / `title*`
- 学位申请人姓名：`author` / `author*`
- 专业学位领域：`speciality` / `speciality*`
- 校内导师：`supervisor` / `supervisor*`
- 校外导师：`practice-supervisor` / `practice-supervisor*`
- 所属院（系、所）：`department`
- 分类号：`classification-number`（如需）
- 学校代码：`school-code`（需用户自行设置）
- 论文提交日期：`date`
- 学号：`student-id`（如需）
- 密级与年限：`secret-level` / `secret-year`
- 关键词：`keywords` / `keywords*`

申请学位类别由 `degree` 与 `degree-type` 组合生成 `\xynu@degree@category`（如需自定义文案可在类文件内调整）。

### 5.2 封面版式

**位置**：1854

- 中文封面：`\xynu@title@page@graduate@zh`
- 英文封面：`\xynu@title@page@graduate@en`

要改封面布局/字号/Logo：

- 直接修改上述宏内的排版代码
- Logo 文件位于 `xynuthesis/figures/`（如 `xynu-badge.pdf`、`xynu-name-stxingkai.pdf`）

### 5.3 学位名称

**位置**：`\xynu@thesis@name` / `\xynu@thesis@name@en` / `\xynu@degree@category`。  
此处根据 `degree` 与 `degree-type` 组合决定“学位论文”名称，可按需调整文案。

## 6. 原创性声明与授权页

**位置**：`原创性声明` 段落。

- `\xynu@originality`、`\xynu@authorization`：声明文字
- `\copyrightpage`：排版细节与签名栏  
  `reviewer=true` 会显示评审专家签名行

## 7. 章节标题样式

**位置**：`章节标题` 段落。

- `\ctexset{chapter/section/...}`：章/节/小节的字号、间距、编号格式
- `\setcounter{secnumdepth}{...}`：章节层级深度限制

## 8. 摘要与关键词

**位置**：`摘要` 段落。

- 中文摘要环境：`abstract`
- 英文摘要环境：`abstract*`
- 关键词输出：`\xynu@keywords@text`、`\xynu@keywords@en@text`

关键词来自 `\xynusetup{keywords=..., keywords*=...}`。

## 9. 目录与图表清单

**位置**：`目录` 段落。

- `\titlecontents{chapter/section/...}`：目录格式
- `\xynu@leaders`：目录引导点
- `\listoffigures`、`\listoftables`、`\listoffiguresandtables`：图表清单样式

## 10. 符号说明（Notation）

**位置**：`符号说明` 段落。

- 环境：`notation`、`notationlist`
- 标题名由 `\xynu@notation@name` 控制（在“处理语言”里定义）

## 11. 正文段落与细节

**位置**：`正文` 段落。

- `\sloppy`、`\raggedbottom`：段落/页面伸缩策略
- `\parskip`、`autoindent`、`\@afterindenttrue`：段落间距与缩进
- URL 断行：`\UrlBreaks`、`\Urlmuskip`

## 12. 脚注格式

**位置**：`正文` 段落中的脚注设置。

- `\thefootnote`：用带圈数字
- `\footnoterule`、`\@makefntext`：脚注线和缩进
- `footmisc` 以每页重置脚注（已在导言区加载）

## 13. 列表间距

**位置**：`列表` 段落。

- `\xynu@nolistsep` 与 `\@listi/\@listii/\@listiii`：控制列表段前/段后间距

## 14. 图表与浮动体

**位置**：`浮动体` 段落。

- `\xynu@caption@font`：图题/表题字号与行距
- `\xynu@table@font`：表格内容字号与行距
- `\captionsetup{...}`：标题位置、间距、对齐方式
- `\figurenote`/`\tablenote`：图注/表注样式
- `\floatsep`、`\textfloatsep`、`\intextsep`：浮动体与正文间距
- `\fps@figure` / `\fps@table`：默认浮动位置

## 15. 公式编号括号

**位置**：`表达式` 段落。

- `eqn-paren-style=full|half` 控制中文全角/英文半角括号  
  具体实现为 `\tagform@` 的重定义。

## 16. 参考文献与引用样式

**位置**：`参考文献` 段落。

### 16.1 natbib

- `cite-style` 影响 `\citestyle` 与 `\bibpunct` 风格  
  （super/inline/authoryear）
- `\bibfont`、`\bibsep`、`\bibhang` 控制参考文献列表排版
- `\bibsection` 重定义用于目录与书签

### 16.2 biblatex

在 `\AtEndOfPackageFile*{biblatex}` 中集中配置字号、悬挂缩进与标题。

## 17. 致谢与科研成果

**位置**：`附录` 段落。

- `acknowledgements`：致谢环境
- `achievements` / `theachievements`：科研成果环境及列表格式

## 18. 其他宏包配置

**位置**：`其他宏包的设置` 段落。

- `hyperref`：书签、链接颜色、PDF 元数据（中文/英文切换）
- `amsthm`：定理环境名称、字体、proof 环境格式
- `algorithm2e`：算法标题、清单与样式
- `mathtools`：修复 unicode-math 下的 underbrace/overbrace
- `nomencl`：符号说明列表样式
- `siunitx`：中英文单位列表分隔符与范围连接符
- `chapterbib`：章节参考文献时的标题设置

## 19. 建议的修改流程

1) **内容类修改**（题目/学位申请人/导师/院系/提交日期/关键词/学号等）：  
   在 `xynuthesis/xynusetup.tex` 的 `\xynusetup{...}` 中改。  
2) **样式类修改**（字号/间距/页边距/标题格式等）：  
   在 `xynuthesis/xynuthesis.cls` 对应段落改。  
3) **新选项**：  
   在 `\xynu@define@key{...}` 添加 key，并在 `\xynu@option@hook` 写逻辑。  
4) **涉及 Logo 或图形**：  
   替换 `xynuthesis/figures/` 下同名 PDF 或修改调用路径。
