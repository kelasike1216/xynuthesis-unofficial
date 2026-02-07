# 信阳师范大学学位论文 LaTeX 模板（xynuthesis）

本模板基于 ustcthesis 进行二次改写，面向信阳师范大学研究生学位论文排版需求。
已适配学校最新的论文撰写规范，支持 XeLaTeX 编译，兼容 TeX Live / MacTeX / MiKTeX
的最新发行版，跨平台可用。

## 特性

- 面向学校规范的论文结构与版式设置
- 预置页边距、标题格式、正文字体与行距
- 内置参考文献与引用样式（作者—年份 / 数字）
- 支持中英文摘要、致谢、成果、创新点等常用章节
- 示例与说明文档配套，开箱即用

## 目录结构

- main.tex：论文主文件
- xynuthesis.cls：模板类文件
- xynusetup.tex：全局配置入口
- chapters/：章节内容
- bib/：参考文献数据库
- figures/：图表资源

## 快速开始

1. 安装 TeX 发行版（推荐 TeX Live / MacTeX / MiKTeX 最新版）。
2. 修改 main.tex 与 chapters/ 中的内容。
3. 选择编译方式生成 PDF。

### 编译论文

```
latexmk -xelatex main.tex
```

### 清理临时文件

```
latexmk -c
```

### 使用 Makefile

```
make            # 编译生成 main.pdf
make clean      # 删除编译过程产生的临时文件
```

## 使用说明

仓库内提供若干说明文档，建议先阅读：

- 章节标题格式设置说明.md
- 正文格式设置说明.md
- 页边距设置说明.md
- xynuthesis.cls说明.md

## 兼容性说明

- 仅支持 XeLaTeX 编译。
- 不支持 CTeX 套装。
- 建议使用 2017 及以上版本的 TeX 发行版，并尽量更新到最新。

## 反馈与贡献

若发现格式与学校规范不一致或存在功能缺失，请在问题反馈中提供：

- TeX 发行版与版本号
- 复现步骤与最小示例
- 期望结果与实际结果截图

欢迎提交改进建议或修正。
