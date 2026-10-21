# 整理说明（相对原始工程）

本仓库从本地工程 `6-tyg` 整理而来，只保留 R 代码与说明文档。原始工程未删除，整理前的完整备份 `6-tyg-backup-2026-10-21.zip` 已在本地另行保存（未入库）。

## 1. 未收录的内容

| 内容 | 处理 |
|---|---|
| `*.xlsx` / `*.xls` / `*.csv` / `*.RData` / `*.rds` | 未复制；`.gitignore` 已屏蔽 |
| `*.pdf` / `*.docx` / `*.pptx` | 未复制 |
| 脚本运行产生的图（PNG/PDF/TIFF） | 未复制；仓库只保留绘图代码 |
| 数据库中的患者级记录 | 未导出、未收录 |

原始目录本身就只有 49 个 `.R` 文件，没有数据文件；整理时未从其它目录引入任何数据。

## 2. 目录调整

| 原始位置 | 新位置 |
|---|---|
| `1-0517/1-简单合并处理.R`、`12-分层数据.R`、`20-数据缺失统计.R` | `scripts/01_data_prep/` |
| `1-0517/1-计算tyg.R`、`2-四分位间距.R`、`3-MI因子开发.R`、`4-tyg因子开发.R` | `scripts/02_tyg/` |
| `1-0517/tyg热图绘制.R`、`8-绘制线性相关.R` | `scripts/03_descriptive/` |
| `1-0517/14-VIF-检查共线性.R`、`5-1-COX模型.R`、`6-KM1.R`、`7-累计死亡率.R`、`cox模型比较.R`、`10-cox交互.R`、`11-联合分析.R` | `scripts/04_survival/` |
| `1-0517/0/AUC-ROC.R`、`0/检验auc.R`、`17-计算比较AIC模型加强版.R`、`18-auc比较.R`、`1-大修/15-DCA-决策曲线.R` | `scripts/05_prediction/` |
| `1-0517/13-多个亚组变量比较分析.R`、`13-亚组分析单独计算p交互.R`、`19-森林图.R`、`19-森林图绘制-子项.R` | `scripts/06_subgroup/` |
| `1-0517/0/1-细胞因子标准化.R`、`0/2-细胞因子散点图绘制.R`、`0/4-graphpad处理数据.R`、`16-细胞因子热图绘制.R` | `scripts/07_cytokine/` |
| `1-0517/9-跑通中介效应.R` | `scripts/08_exploratory/` |
| `1-0517/17-计算比较AIC模型.R`、`12-亚组分析.R`、`2-建立两个模型比较.R`、`21-细胞因子热图横置.R` | `scripts/99_superseded/` |
| 根目录 2024 年 15 个脚本 | `scripts/90_archive_mimic_2024/` |

脚本文件名与内部代码结构保持不变；只调整了所在目录。

## 3. 代码改动

### 3.1 数据目录改为可配置（16 处）

原始脚本中的：

```r
setwd("D:/Desktop")
setwd("D:/Desktop/")
setwd("D:/Desktop/肝衰竭")
setwd("D:/Desktop/Cursor/")
```

统一替换为：

```r
setwd(Sys.getenv("TYG_DATA_DIR", unset = "<原路径>"))
```

未设置环境变量时行为与原来完全一致；设置后可在其他机器/数据目录上复现。

`scripts/01_data_prep/1-简单合并处理.R` 中的：

```r
file_path <- "D:/Desktop/Cursor/"
```

改为：

```r
file_path <- paste0(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop/Cursor"), "/")
```

### 3.2 脱敏（2 个文件）

`scripts/90_archive_mimic_2024/7-23-连接数据库-提取血糖.R` 与 `7-25-从csv找数据库信息.R` 中的 PostgreSQL 明文口令：

```r
password = "<REDACTED>"
```

已改为从环境变量读取：

```r
password = Sys.getenv("MIMIC_DB_PASSWORD")
```

数据库名、主机、端口、用户名也一并改为环境变量，默认值与原脚本一致。使用前请：

```r
Sys.setenv(MIMIC_DB_PASSWORD = "your_password")
```

### 3.3 第二轮代码修复（2026-10-21）

第一轮只处理路径与凭据，未改分析逻辑。第二轮逐一审查后，修复了一批明确缺陷，包括：

- 热图 `summarise()` 整列求和；
- `TyG3` 被二分位覆盖；
- `TyGbmi4` 切点误用 `TyG_index`；
- P for trend 结局口径不一致；
- KM 两两比较引用不存在的 `year1_*` 变量；
- 联合分析 `AUC[2]` 索引与协变量命名错误；
- 多个脚本缺失 `library()`；
- macOS 专用 `system("open ...")`；
- 森林图模板的读取/清理顺序等。

完整清单、可能影响的数值与复核顺序见 [`code-review.md`](code-review.md)。**这些修复会改变部分结果，重跑后需与论文/原始结果核对。** 涉及统计设计但无法确定作者意图的问题（如森林图硬编码、两版细胞因子标准化数据、中介模型设定等）保留未改，并在 `code-review.md` 中标注。

没有重新编号脚本，保留作者原始编号，便于与本地分析记录对应。

## 4. 第二轮新增的文档与工具

| 文件 | 作用 |
|---|---|
| `docs/README.md` | 文档导航与推荐阅读顺序 |
| `docs/script-manifest.csv` | 49 个脚本的机器可读清单（其它文档的源数据） |
| `docs/code-index.md` | 由清单生成的完整脚本索引 |
| `docs/dependencies.md` | 生产者 → 消费者依赖图、同名文件、终点输出 |
| `docs/required-data.md` | 27 个必须自备的外部输入文件 |
| `docs/package-versions.csv` | 47 个包的版本与使用脚本数 |
| `docs/data-dictionary.md` | 结局、暴露、协变量、细胞因子等变量说明 |
| `docs/code-review.md` | 修复清单、保留问题、复核顺序 |
| `docs/audit.md` | 仓库自检报告 |
| `scripts/<stage>/README.md` | 10 个阶段目录各自的脚本表与说明 |
| `tools/build_docs.R` | 由清单重新生成索引/依赖/数据清单/阶段 README |
| `tools/audit_repo.R` | 仓库自检（parse、数据泄漏、凭据、路径、README） |
| `.github/workflows/r-ci.yml` | push / PR 时自动运行自检 |

## 5. 编码与换行

- 全部脚本为 UTF-8 编码。
- `.gitattributes` 将 `.R` / `.md` 统一为 LF 换行，避免 Windows/Linux 协作时产生无意义 diff。

## 6. 校验

整理后已用 R 4.4.0 对 54 个 R 文件（49 个分析脚本 + `00_setup.R` + `packages.R` + `tools/build_docs.R` + `tools/audit_repo.R` + `tools/make_graphical_abstract.R`）做 `parse()` 语法检查，全部通过；`tools/audit_repo.R` 的仓库自检结论为 **PASS**。`parse()` 只验证语法，不代表脚本能在缺少数据/内存对象时直接运行。
