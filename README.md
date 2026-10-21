# TyG 指数与 HIV 住院患者 28 天死亡风险 · 分析代码

**Prognostic value of combined stratification using TyG index and CD4+ T cell count for 28-day all-cause mortality risk in patients with HIV infection and sepsis: a retrospective cohort study**

*Frontiers in Medicine* 2026;12:1688334 · [论文页面](https://www.frontiersin.org/journals/medicine/articles/10.3389/fmed.2025.1688334/full) · [PDF](https://www.frontiersin.org/journals/medicine/articles/10.3389/fmed.2025.1688334/pdf) · [doi:10.3389/fmed.2025.1688334](https://doi.org/10.3389/fmed.2025.1688334)

本仓库包含该研究**可复现的 R 分析代码**：数据合并与清洗、TyG 指数计算与分组、描述性统计、Cox / KM / RCS 生存分析、ROC / AUC / DeLong / NRI-IDI / DCA 预测评价、亚组分析与森林图、细胞因子标准化与热图，以及中介效应探索。

> **本仓库不包含原始数据。** 原始 Excel 表、患者级数据、论文稿件均未上传；仓库只保留 R 代码、脚本清单、分析说明、变量字典、官方图形摘要与自检工具。原始数据含姓名、住院号、就诊号等可识别字段，受医院伦理审批与患者隐私限制，不能公开。

**研究背景**：HIV 感染者合并脓毒症时，代谢紊乱与免疫损伤共同影响短期预后。TyG 指数是胰岛素抵抗的简易替代指标，CD4+ T 细胞计数反映免疫损伤程度；两者单独与不良结局相关，但联合分层对 28 天死亡风险的评估价值尚不明确。

## 图形摘要

![Graphical abstract](figures/graphical-abstract.png)

*论文官方图形摘要（Graphical Abstract，PDF 第 2 页；Figure created with BioRender.com）。来源：Wu et al., Front Med 2026;12:1688334（CC BY 4.0）。*

**论文摘要要点**：

**方法**：单中心回顾性队列，纳入 2014 年 1 月至 2024 年 12 月广州医科大学附属市八医院收治的 HIV 合并脓毒症（Sepsis-3）成人住院患者 1,278 例。以 TyG 截断值 9.22（约登指数）与 CD4 50 cells/μL 交叉分为四组；主要终点为 28 天全因死亡，次要终点为 7 天与住院全因死亡。采用 Kaplan–Meier、Cox 比例风险模型（三套调整）、Boruta 特征筛选、ROC / AUC 与 DeLong 检验；155 例子队列用 LEGENDplex 检测 13 种炎症细胞因子。

**结果**：中位 CD4 为 24.0（8.0–82.8）cells/μL，847 例 CD4 < 50；28 天死亡 231 例（18.1%）。四组 28 天死亡率依次为 10.3%、16.0%、18.5%、28.6%（P < 0.001）；CD4 < 50 且 TyG ≥ 9.22 组全调整 HR 2.82（95% CI 1.77–4.50），P for trend < 0.001。联合模型 AUC 0.605（0.568–0.642），高于 TyG（0.541）与 CD4（0.556）；高风险组呈现特定细胞因子谱。

**结论**：TyG-CD4 联合分层可低成本、快速地识别 HIV 合并脓毒症高危患者，可作为 SOFA 的补充；但模型判别力中等、研究为单中心回顾性，仍需多中心前瞻性验证。

---

## 1. 研究设计

| 项目 | 内容 |
|---|---|
| 研究类型 | 单中心回顾性队列研究 |
| 研究对象 | HIV 合并脓毒症成人住院患者 1,278 例（2014–2024，广州医科大学附属市八医院） |
| 暴露 | TyG 指数 = ln[TG (mg/dL) × FPG (mg/dL) / 2] |
| 分组 | TyG 9.22（约登指数）× CD4 50 cells/μL 四分组；另含二分位 / 三分位 / 四分位敏感性分组 |
| 主要终点 | 28 天全因死亡（`d28` / `D28`） |
| 次要终点 | 7 天全因死亡、住院全因死亡 |
| 协变量 | 年龄、性别、糖尿病、高血压、CKD、肝硬化、CHD、COPD、SOFA、ART、机会性感染（马尔尼菲篮状菌、PCP、隐球菌、念珠菌）等 |
| 统计方法 | Cox 比例风险模型、KM、RCS、VIF、Boruta、ROC / DeLong、时间依赖 AUC、NRI / IDI、DCA、亚组交互、中介分析 |
| 细胞因子 | 155 例子队列，13 种炎症细胞因子；C0–C7 标准曲线标准化，热图使用其中 12 项 |

### 1.1 论文信息

| 项目 | 内容 |
|---|---|
| 作者 | Yongchang Wu, Jiejing Chen, Yu Meng, Mingyue Ren, Zhenyi Zou, Linghua Li, Xilong Deng, Yueping Li |
| 期刊 | *Frontiers in Medicine*, 2026;12:1688334 |
| 时间 | Received 21 Aug 2025 · Accepted 15 Dec 2025 · Published 12 Jan 2026 |
| DOI | [10.3389/fmed.2025.1688334](https://doi.org/10.3389/fmed.2025.1688334) |
| PubMed | [PMID 41601726](https://pubmed.ncbi.nlm.nih.gov/41601726/) · PMCID PMC12832338 |
| 论文许可 | CC BY 4.0（开放获取） |
| 代码许可 | Academic Non-Commercial License（见 [`LICENSE`](LICENSE)） |

---

## 2. 仓库结构

```text
6-tyg/
├── README.md                       # 项目总览（本文件）
├── LICENSE                         # 学术非商业许可
├── CITATION.cff                    # 机器可读引用信息（含论文 preferred-citation）
├── packages.R                      # 依赖包一键安装
├── data/README.md                  # 数据放置说明（不含数据）
├── figures/
│   ├── README.md                   # 图片来源、提取命令与版权说明
│   └── graphical-abstract.png      # 论文官方图形摘要（PDF 第 2 页）
├── docs/
│   ├── README.md                   # 文档导航
│   ├── code-index.md               # 49 个脚本的完整索引（自动生成）
│   ├── pipeline.md                 # 分析流程、依赖关系、已知问题
│   ├── input-output.md             # 每个脚本的输入/输出文件
│   ├── dependencies.md             # 生产者→消费者依赖图（自动生成）
│   ├── required-data.md            # 27 个外部输入清单（自动生成）
│   ├── data-dictionary.md          # 变量字典
│   ├── figures.md                  # 绘图脚本与图形目录
│   ├── code-review.md              # 代码审查、修复记录与复核顺序
│   ├── audit.md                    # 仓库自检报告
│   ├── notes.md                    # 相对原始工程的整理说明
│   ├── script-manifest.csv         # 49 条机器可读脚本清单（源数据）
│   └── package-versions.csv        # 47 个包的版本快照（自动生成）
├── output/.gitkeep                 # 运行输出占位（内容不入库）
├── scripts/
│   ├── 00_setup.R                  # 数据目录与运行环境设置
│   ├── 01_data_prep/README.md
│   ├── 02_tyg/README.md
│   ├── 03_descriptive/README.md
│   ├── 04_survival/README.md
│   ├── 05_prediction/README.md
│   ├── 06_subgroup/README.md
│   ├── 07_cytokine/README.md
│   ├── 08_exploratory/README.md
│   ├── 90_archive_mimic_2024/README.md
│   └── 99_superseded/README.md
├── tools/
│   ├── build_docs.R                # 由清单生成索引/依赖/数据清单/阶段 README
│   └── audit_repo.R                # 仓库自检
└── .github/workflows/r-ci.yml      # push/PR 时自动运行自检
```

### 2.1 代码分类

49 个分析脚本按阶段分为 10 类，每个目录都有独立 README：

| 类别 | 目录 | 内容 | 脚本数 | 性质 |
|---|---|---|---:|---|
| 01 数据准备 | [`scripts/01_data_prep/`](scripts/01_data_prep/README.md) | 多源 Excel 合并与去重、器官障碍评分、缺失统计 | 3 | 主分析 |
| 02 TyG 指数与分组 | [`scripts/02_tyg/`](scripts/02_tyg/README.md) | TyG 计算、ROC 截断值、二分/三分/四分位分组、MI/TyG 因子 | 4 | 主分析 |
| 03 描述性分析与绘图 | [`scripts/03_descriptive/`](scripts/03_descriptive/README.md) | TyG×CD4 死亡率热图、CD4–死亡关系曲线 | 2 | 主分析 |
| 04 生存分析 | [`scripts/04_survival/`](scripts/04_survival/README.md) | VIF、Cox、KM、累积死亡、模型比较、交互、联合分析 | 7 | 主分析 |
| 05 预测性能 | [`scripts/05_prediction/`](scripts/05_prediction/README.md) | ROC/AUC/DeLong、AIC/BIC/HL、DCA、Word 报告 | 5 | 主分析 |
| 06 亚组与森林图 | [`scripts/06_subgroup/`](scripts/06_subgroup/README.md) | 分层 Cox、交互 P、肝硬化/糖尿病森林图 | 4 | 主分析 |
| 07 细胞因子 | [`scripts/07_cytokine/`](scripts/07_cytokine/README.md) | 标准化、小提琴/散点、热图、GraphPad 导出 | 4 | 主分析 |
| 08 探索性分析 | [`scripts/08_exploratory/`](scripts/08_exploratory/README.md) | TyG → CD4 → 28 天死亡的中介效应 | 1 | 探索 |
| 90 MIMIC 练习 | [`scripts/90_archive_mimic_2024/`](scripts/90_archive_mimic_2024/README.md) | 2024 年 MIMIC-IV / bdmcc 数据接入、RCS、Cox、ROC、森林图 | 15 | 归档，非论文 |
| 99 被替代/半成品 | [`scripts/99_superseded/`](scripts/99_superseded/README.md) | 旧版模型表、基础版亚组、未完成比较、半成品热图 | 4 | 仅溯源 |

完整的逐脚本索引见 [`docs/code-index.md`](docs/code-index.md)。

---

## 3. 快速开始

### 3.1 环境

- **R 4.4.0**（开发与运行环境），RStudio
- 主要依赖见 [`packages.R`](packages.R)：`tidyverse`、`readxl`、`writexl`、`openxlsx`、`survival`、`survminer`、`rms`、`maxstat`、`timeROC`、`survcomp`、`survIDINRI`、`nricens`、`pROC`、`caret`、`ResourceSelection`、`rmda`、`ggplot2`、`ggpubr`、`ggtext`、`pheatmap`、`forestplot`、`flextable`、`officer` 等
- 已从 CRAN 归档的包（`plotRCS`、`rmda`）安装方式见 `packages.R` 注释
- 47 个包的版本与使用脚本数见 [`docs/package-versions.csv`](docs/package-versions.csv)

```r
# 一键安装
source("packages.R")
```

### 3.2 放入数据

把所有输入 Excel 表放在同一个目录，文件名与脚本中的字面量一致（清单见 [`data/README.md`](data/README.md) 与 [`docs/required-data.md`](docs/required-data.md)）。然后设置数据目录：

```powershell
# Windows PowerShell
$env:TYG_DATA_DIR = "D:/tyg-data"
```

```bash
# macOS / Linux
export TYG_DATA_DIR=/path/to/tyg-data
```

仓库中的脚本已统一改成：

```r
setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"))
```

即：未设置环境变量时，仍沿用原作者的 `D:/Desktop`；设置后即可指向任意数据目录。少数原本指向 `D:/Desktop/肝衰竭` 或 `D:/Desktop/Cursor` 的脚本，默认值保留原路径，设置环境变量后同样会统一覆盖。

### 3.3 运行顺序

先看 [`docs/pipeline.md`](docs/pipeline.md)。脚本之间存在先后依赖（前一步的 `write_xlsx` 是后一步的 `read_excel`），输出默认写回当前工作目录。

**关键依赖**：

- `04_survival/10-cox交互.R` 在会话中生成 `hiv_pos`，`04_survival/11-联合分析.R` 直接使用它，两者必须在同一 R 会话中按顺序运行。
- `90_archive_mimic_2024/` 的数据库与合并脚本全程依赖内存对象，不能单独复现。
- `02_tyg/4-tyg因子开发.R` 读取的 `MI_2.0.xlsx` 在仓库内没有生成脚本。
- 部分脚本（`02_tyg/2-四分位间距.R`、`04_survival/7-累计死亡率.R`、`08_exploratory/9-跑通中介效应.R`、`05_prediction/AUC-ROC.R`）直接使用会话内对象，不能独立运行。

---

## 4. 分析流程

```text
01_data_prep      原始表 → 合并、清洗、器官障碍评分、缺失统计 → 分析主表
      │
      ├── 02_tyg              TyG 计算、截断值、分组、MI / TyG 因子
      ├── 03_descriptive      死亡率热图、CD4–死亡关系曲线
      ├── 04_survival         VIF → Cox → KM → 累积死亡 → 模型比较 → 交互 → 联合分析
      ├── 05_prediction       ROC/AUC/DeLong → AIC/BIC/HL → DCA
      ├── 06_subgroup         分层 Cox → 交互 P → 森林图
      ├── 07_cytokine         标准化 → 小提琴图 → 热图 → GraphPad 导出
      └── 08_exploratory      中介效应
```

完整的阶段说明见 [`docs/pipeline.md`](docs/pipeline.md)，文件级依赖见 [`docs/dependencies.md`](docs/dependencies.md)。

---

## 5. 绘图与图件索引

除论文官方图形摘要外，仓库不收录运行生成的图片；所有图形均由脚本在本地运行后生成。图与脚本的对应关系见 [`docs/figures.md`](docs/figures.md)。

| 图形 | 脚本 |
|---|---|
| 图形摘要（官方 Graphical abstract） | 论文 PDF 第 2 页（BioRender），见 `figures/graphical-abstract.png` |
| TyG × CD4 四格死亡率热图 | `scripts/03_descriptive/tyg热图绘制.R` |
| 28 天 KM 曲线 | `scripts/04_survival/6-KM1.R` |
| 累积死亡曲线 | `scripts/04_survival/7-累计死亡率.R` |
| TyG 截断值 ROC | `scripts/02_tyg/1-计算tyg.R` |
| 多模型 ROC / 校准曲线 | `scripts/05_prediction/AUC-ROC.R`、`18-auc比较.R` |
| 决策曲线 DCA | `scripts/05_prediction/15-DCA-决策曲线.R` |
| 亚组森林图 | `scripts/06_subgroup/19-森林图.R`、`19-森林图绘制-子项.R` |
| 细胞因子热图 / 小提琴图 | `scripts/07_cytokine/16-细胞因子热图绘制.R`、`2-细胞因子散点图绘制.R` |
| RCS 曲线（MIMIC 练习） | `scripts/90_archive_mimic_2024/7-26-Rcs曲线.R`、`7-29-RCS.R` |

---

## 6. 数据与参数

| 文档 | 内容 |
|---|---|
| [`data/README.md`](data/README.md) | 数据放置说明与期望输入文件 |
| [`docs/required-data.md`](docs/required-data.md) | 27 个必须自备的外部输入文件 |
| [`docs/input-output.md`](docs/input-output.md) | 每个脚本读写的文件名 |
| [`docs/data-dictionary.md`](docs/data-dictionary.md) | 结局、TyG、CD4、SOFA、合并症、细胞因子等变量说明 |
| [`docs/dependencies.md`](docs/dependencies.md) | 生产者 → 消费者依赖图、同名文件、终点输出 |
| [`docs/package-versions.csv`](docs/package-versions.csv) | 47 个包的版本快照 |

> 本仓库不含数据；`data/`、`output/` 和常见数据格式均已在 `.gitignore` 中排除。数据库凭据通过 `MIMIC_DB_PASSWORD` 等环境变量提供。

---

## 7. 代码质量与自检

| 检查项 | 结果 |
|---|---|
| 清单脚本数 vs `scripts/` 脚本数 | 49 / 49 |
| `parse()` 语法检查 | 53 个 R 文件，0 失败 |
| Git 跟踪数据文件 | 0 |
| 明文凭据 | 0 |
| 硬编码 `setwd("...")` | 0 |
| 阶段目录 README | 10 / 10 |
| 仓库自检结论 | **PASS** |

```bash
# 重新生成索引/依赖/数据清单/阶段 README
Rscript tools/build_docs.R

# 仓库自检
Rscript tools/audit_repo.R
```

GitHub Actions 会在每次 push / PR 时运行同一自检（`.github/workflows/r-ci.yml`）。详细修复清单与仍需人工确认的问题见 [`docs/code-review.md`](docs/code-review.md)，自检结果见 [`docs/audit.md`](docs/audit.md)。

> **重要**：本轮修复了若干明确缺陷（如热图整列求和、TyG3 被覆盖、TyGbmi4 切点、P for trend 结局口径、AUC 索引等），**部分数值会与修复前不同**。重跑后请与论文/原始结果逐项核对；原文件已在本地另行备份（未入库）。

---

## 8. 注意事项与已知限制

- 本仓库不含数据，未做运行时回归测试；`parse()` 与自检不能替代真实数据上的验证。
- `04_survival/11-联合分析.R` 依赖 `10-cox交互.R` 的会话对象，不是独立脚本。
- `02_tyg/4-tyg因子开发.R` 的上游 `MI_2.0.xlsx` 没有生成脚本。
- 两个 `06_subgroup/19-森林图*.R` 中的 N / HR / CI / P 为手工写死，正式复用前必须用最新结果替换。
- 细胞因子散点图与热图使用两版不同的标准化结果（`标准化样本1.xlsx` vs `标准化样本-0729.xlsx`）。
- `14.xlsx` 被 3 个脚本写入，存在覆盖风险；为兼容原流程未改名。
- 2024 MIMIC 归档脚本大量依赖会话内存对象，不能独立复现。

详见 [`docs/code-review.md`](docs/code-review.md) 与 [`docs/pipeline.md`](docs/pipeline.md)。

---

## 9. 数据与代码可用性

### 9.1 数据可用性

受医院伦理审批与患者隐私限制，原始数据与个体级中间数据不能公开。如需合作或数据申请，请联系研究负责人。

### 9.2 代码许可与引用

- **代码许可**：**Academic Research License (Non-Commercial)**，详见 [`LICENSE`](LICENSE)。允许非商业学术研究、教学与复现；商业使用需事先取得书面许可。
- **论文许可**：CC BY 4.0。
- **引用**：如使用本代码，请引用论文与本仓库；机器可读的引用信息见 [`CITATION.cff`](CITATION.cff)（含论文的 `preferred-citation`）。

**BibTeX**

```bibtex
@article{wu2026tyg,
  title   = {Prognostic value of combined stratification using TyG index and CD4+ T cell
             count for 28-day all-cause mortality risk in patients with HIV infection and
             sepsis: a retrospective cohort study},
  author  = {Wu, Yongchang and Chen, Jiejing and Meng, Yu and Ren, Mingyue and
             Zou, Zhenyi and Li, Linghua and Deng, Xilong and Li, Yueping},
  journal = {Frontiers in Medicine},
  volume  = {12},
  pages   = {1688334},
  year    = {2026},
  doi     = {10.3389/fmed.2025.1688334}
}
```

### 9.3 相关文献（阅读导航）

> 下表为相关文献的**要点摘录**（非原文摘要全文），仅用于阅读导航；版权归原作者，DOI 链接指向出版社页面。

| 文献 | 与本研究的关联 |
|---|---|
| Rudd KE, et al. Global, regional, and national sepsis incidence and mortality, 1990–2017. *Lancet*. 2020;395:200–211. [DOI](https://doi.org/10.1016/S0140-6736%2819%2932989-7) | 全球脓毒症疾病负担与死亡规模，说明早期风险分层的公共卫生意义。 |
| Singer M, et al. The Third International Consensus Definitions for Sepsis and Septic Shock (Sepsis-3). *JAMA*. 2016;315:801–810. [DOI](https://doi.org/10.1001/jama.2016.0287) | Sepsis-3 定义（疑似感染 + SOFA ≥ 2）是本队列纳入标准的基础。 |
| Lou J, et al. A retrospective study utilized MIMIC-IV database to explore the potential association between triglyceride-glucose index and mortality in critically ill patients with sepsis. *Sci Rep*. 2024;14:24081. [DOI](https://doi.org/10.1038/s41598-024-75050-8) | 重症脓毒症中 TyG 与死亡风险相关，支持 TyG 作为代谢风险标志。 |
| Zheng R, et al. Association between triglyceride-glucose index and in-hospital mortality in critically ill patients with sepsis: analysis of the MIMIC-IV database. *Cardiovasc Diabetol*. 2023;22:307. [DOI](https://doi.org/10.1186/s12933-023-02041-w) | TyG 与脓毒症住院死亡独立相关，但单独判别能力有限，提示需要联合免疫指标。 |
| Grinspoon S, Carr A. Cardiovascular risk and body-fat abnormalities in HIV-infected adults. *N Engl J Med*. 2005;352:48–62. [DOI](https://doi.org/10.1056/NEJMra041811) | HIV 感染与体脂异常、代谢紊乱及心血管风险增加相关。 |
| Obare LM, et al. Inflammation in HIV and its impact on atherosclerotic cardiovascular disease. *Circ Res*. 2024;134:1515–1545. [DOI](https://doi.org/10.1161/CIRCRESAHA.124.323891) | 慢性炎症是 HIV 感染者“代谢-免疫轴”的核心机制之一。 |
| Non LR, Escota GV, Powderly WG. HIV and its relationship to insulin resistance and lipid abnormalities. *Transl Res*. 2017;183:41–56. [DOI](https://doi.org/10.1016/j.trsl.2016.12.007) | HIV 及 ART 相关胰岛素抵抗/血脂异常，为 TyG 的生物学基础提供支持。 |
| Boomer JS, et al. Immunosuppression in patients who die of sepsis and multiple organ failure. *JAMA*. 2011;306:2594–2605. [DOI](https://doi.org/10.1001/jama.2011.1829) | 脓毒症致死与 CD4+ T 细胞耗竭/免疫抑制相关，支持 CD4 分层的合理性。 |

---

## 10. 整理记录

- 2026-10-21：从本地工程 `6-tyg` 整理为纯代码仓库，共 49 个分析脚本 + `scripts/00_setup.R`；未收录任何数据文件。整理前的完整备份已在本地另行保存（未入库）。
- 2026-10-21（第二轮）：补齐 10 个阶段 README、49 条脚本清单、依赖图、27 个外部输入清单、47 个包版本快照、变量字典、代码审查、自检脚本与 GitHub Actions；修复明确代码缺陷并记录。详细改动见 [`docs/notes.md`](docs/notes.md) 与 [`docs/code-review.md`](docs/code-review.md)。
- 2026-10-21（第三轮）：添加发表论文信息与 Frontiers 页面链接、相关文献阅读导航、图形摘要、BibTeX 与 `CITATION.cff` 的 `preferred-citation`；版本标记为 `v1.2.0`。
- 2026-10-21（第四轮）：将图形摘要替换为论文 PDF 第 2 页的 **官方 GRAPHICAL ABSTRACT**（BioRender），删除此前的重绘脚本；版本标记为 `v1.3.0`。
- 2026-10-21（第五轮）：README 改为论文摘要式开头（题目 / 期刊 / 背景 / 图形摘要 / 摘要要点），并增加“关于代码仓库”的项目介绍；版本标记为 `v1.4.0`。

---

## English summary

This repository contains the R analysis code for a single-centre retrospective cohort study evaluating the association between the triglyceride-glucose (TyG) index and 28-day mortality in hospitalized people with HIV and sepsis. It covers data harmonisation, TyG derivation and grouping, descriptive analyses, Cox / Kaplan–Meier / restricted cubic spline models, ROC / AUC / DeLong / NRI-IDI / decision-curve analyses, subgroup and forest plots, and cytokine standardisation and visualisation. Raw data and patient-level information are **not** included for privacy reasons. The `scripts/90_archive_mimic_2024/` folder contains unrelated 2024 MIMIC-IV sepsis practice code kept for reference only.
