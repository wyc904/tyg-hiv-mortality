# 仓库自检报告

- 生成日期：2026-10-21
- 环境：Windows 11，R 4.4.0
- 命令：`Rscript tools/audit_repo.R`（可随时重跑）
- 触发方式：本地手动 + GitHub Actions（`.github/workflows/r-ci.yml`）

## 结果摘要

| 检查项 | 结果 |
|---|---|
| 清单脚本数 vs `scripts/` 脚本数 | 49 / 49 |
| `parse()` 语法检查 | **53 个 R 文件，0 失败**（49 分析脚本 + `00_setup.R` + `packages.R` + 2 个 `tools/` 脚本） |
| Git 跟踪文件 | 82 |
| 数据/文档二进制文件混入（xlsx / csv / RData / rds / pdf / docx / pptx） | **0** |
| 明文凭据残留（password / token / secret / API key） | **0** |
| 硬编码 `setwd("...")` | **0**（统一为 `Sys.getenv("TYG_DATA_DIR", ...)`） |
| 阶段目录 README | **10 / 10** |
| 结论 | **PASS** |

## 包依赖快照

脚本中通过 `library()` / `require()` / `pkg::` 引用的包共 **47 个**：

- 已安装：**46 个**
- 未安装：**1 个**：`ggpmisc`（仅 `scripts/90_archive_mimic_2024/7-29-线性回归 - 副本.R` 使用，属 2024 模板脚本）
- 版本与使用脚本数见 [`package-versions.csv`](package-versions.csv)

> `plotRCS` 与 `rmda` 已从 CRAN 归档，安装方式见 `packages.R` 注释；本机已安装 `plotRCS 0.1.5`。

## 依赖扫描

按脚本中的字面量文件名自动匹配（详见 [`dependencies.md`](dependencies.md)）：

| 项目 | 数量 |
|---|---|
| 原始输入文件（非仓库内脚本生成） | 27 |
| 确定的脚本间文件依赖 | 3 条 |
| 同名/歧义文件（被多个脚本写入） | 1 个（`14.xlsx`） |
| 只写不读的产物（图、结果表等终点输出） | 见 `dependencies.md` 第 3 节 |

原始数据准备清单见 [`required-data.md`](required-data.md)。

## 说明与边界

- 自检覆盖**语法、数据泄漏、明文凭据、硬编码路径、清单一致性、阶段 README** 六项；不验证运行时数据是否齐备、包版本是否兼容、修复后的数值是否与论文一致。
- 凭据扫描是正则近似匹配，会跳过注释行；不能替代 GitHub 的 secret scanning，提交前仍应人工复核。
- 依赖关系按文件名匹配，通用文件名与动态拼接路径不会被准确识别，详见 `dependencies.md` 的说明。
- 本仓库不含数据，因此未做运行时回归测试；代码修复的影响与复核顺序见 [`code-review.md`](code-review.md)。
