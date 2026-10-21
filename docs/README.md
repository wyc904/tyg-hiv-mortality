# 文档导航

本目录存放项目的分析流程、脚本索引、依赖关系、变量字典、代码审查与整理记录。

## 推荐阅读顺序

| 顺序 | 文档 | 适合谁 | 内容 |
|---:|---|---|---|
| 1 | [`../README.md`](../README.md) | 所有人 | 论文题目与期刊链接、研究背景、官方图形摘要、摘要要点、研究设计、代码分类、快速开始、数据与自检 |
| 2 | [`pipeline.md`](pipeline.md) | 想复现分析的人 | 10 个阶段的流程、脚本作用、关键依赖、已知代码问题 |
| 3 | [`code-index.md`](code-index.md) | 想找具体脚本的人 | 49 个脚本的完整索引（作用 / 输入 / 输出 / 是否绘图 / 运行方式） |
| 4 | [`input-output.md`](input-output.md) | 准备数据的人 | 每个脚本读写的文件名 |
| 5 | [`required-data.md`](required-data.md) | 准备数据的人 | 27 个必须自备的外部输入文件 |
| 6 | [`dependencies.md`](dependencies.md) | 想理清上下游的人 | 生产者 → 消费者依赖图、同名文件、终点输出 |
| 7 | [`data-dictionary.md`](data-dictionary.md) | 写方法/做数据核对的人 | 结局、TyG、CD4、SOFA、合并症、细胞因子等变量说明 |
| 8 | [`figures.md`](figures.md) | 要出图的人 | 图 → 绘图脚本 → 输出文件 |
| 9 | [`code-review.md`](code-review.md) | 要复用/修改代码的人 | 本轮修复清单、保留未改的问题、复核顺序 |
| 10 | [`audit.md`](audit.md) | 维护仓库的人 | 自检结果（parse / 数据泄漏 / 凭据 / README 完整性） |
| 11 | [`notes.md`](notes.md) | 想对照原工程的人 | 目录调整、路径与凭据处理、未改动内容 |
| 12 | [`package-versions.csv`](package-versions.csv) | 配环境的人 | 47 个包的版本与使用脚本数 |
| 13 | [`script-manifest.csv`](script-manifest.csv) | 做自动化的人 | 49 个脚本的机器可读清单（生成其它文档的源数据） |

## 自动生成的文件

以下文件由 `Rscript tools/build_docs.R` 从 `script-manifest.csv` 生成，**不要手工编辑**：

- `code-index.md`
- `dependencies.md`
- `required-data.md`
- `package-versions.csv`
- `scripts/<stage>/README.md`（10 份）

修改脚本或清单后，重新运行：

```bash
Rscript tools/build_docs.R
```

## 仓库自检

```bash
Rscript tools/audit_repo.R
```

检查清单一致性、`parse()` 语法、数据文件泄漏、明文凭据、硬编码路径和阶段 README 完整性。GitHub Actions 也会在每次 push / PR 时运行同一脚本（`.github/workflows/r-ci.yml`）。
