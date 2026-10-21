# 代码审查与修复记录

- 审查日期：2026-10-21
- 审查范围：`scripts/` 下 49 个分析脚本、`scripts/00_setup.R`、`packages.R`、`tools/`
- 审查方式：逐文件阅读 + 依赖/文件名扫描 + R 4.4.0 `parse()` + 仓库自检
- 原则：**分析设计不擅自改动**；只修复明确的依赖缺失、笔误、执行顺序和平台兼容问题。涉及统计口径的改动逐条列出，重跑后需与原文结果核对。

> 本轮修复会改变部分数值（尤其是热图死亡率、TyG 分组、P for trend、AUC）。原文件已另行备份（未入库），Git 历史中也可追溯。

---

## 1. 已修复的问题

| # | 文件 | 原问题 | 处理 | 可能影响 |
|---:|---|---|---|---|
| 1 | `scripts/03_descriptive/tyg热图绘制.R` | `summarise()` 中 `sum(df$'28天死亡')` 取整列，每个格子重复计数 | 改为按当前分组 `sum(\`28天死亡\`, na.rm = TRUE)` | **热图四格死亡数与死亡率会变化**，必须重跑图 |
| 2 | `scripts/02_tyg/1-计算tyg.R` | `TyG3` 先按三分位生成，随后被二分位赋值覆盖 | 二分位改存为 `TyG2`，保留三分位 `TyG3` | 若下游使用 `TyG3`，分组由 2 类恢复为 3 类 |
| 3 | `scripts/02_tyg/2-四分位间距.R` | `TyGbmi4` 的切点由 `TyG_index` 计算，却用于切 `TyGbmi` | 切点改为 `quantile(data$TyGbmi, ...)` | TyG-BMI 四分位分组会变化 |
| 4 | `scripts/04_survival/5-1-COX模型.R` | P for trend 模型使用 `Surv(hoslos, 住院死亡)`，与主模型 `Surv(d28, D28)` 口径不一致 | 统一为 `Surv(d28, D28)` | P for trend 数值会变化 |
| 5 | `scripts/04_survival/6-KM1.R` | 两两 log-rank 使用不存在的 `year1_los` / `year1_outcome` / `tyg_group` | 改为 `Surv(d28, D28) ~ TYGCD4` | 两两比较从报错变为可运行 |
| 6 | `scripts/04_survival/11-联合分析.R` | 单时间点 `timeROC` 却取 `$AUC[2]`，得到 NA；校正模型使用 `sex` / `SOFA`，数据中为 `gender` / `sofa` | `$AUC[2]` → `$AUC[1]`；协变量改为 `age + gender + sofa` | AUC 提升百分比与校正 Cox 从 NA/报错变为可计算 |
| 7 | `scripts/05_prediction/检验auc.R` | 组合模型使用不存在的 `death_28` | 改为 `D28` | 脚本后半段从报错变为可运行 |
| 8 | `scripts/99_superseded/2-建立两个模型比较.R` | 引用未定义的 `model_sofa` / `model_full` | 改为已定义的 `model1` / `model3` | C-index 可计算；该文件仍为被替代版本 |
| 9 | `scripts/01_data_prep/12-分层数据.R` | `bilirubin_score` 连续定义两次，阈值 101/102 不一致，后者覆盖前者 | 删除第一段，保留 101–204 版本 | TBIL 101–102 区间的评分可能变化 |
| 10 | `scripts/90_archive_mimic_2024/7-29-RCS.R` | `labs()` 前缺少 `+`，标签未加到图上 | 补 `+` | 仅影响图轴标签 |
| 11 | `scripts/90_archive_mimic_2024/8-18-对比refer亚组.R` | 两个 `write_xlsx()` 写同名文件，第二次覆盖第一次 | 第二个输出改名为 `stratified_analysis_counts.xlsx` | 两份结果都保留 |
| 12 | `scripts/90_archive_mimic_2024/cox回归单因素森林图.R` | `read.csv()` 在使用 `results` 之后才执行，且提前 `rm()` 掉 `results` / `HIVdata` | 调整读取顺序；绘图后再清理 | 模板从不可运行变为可运行（仍需交互选择 CSV） |
| 13 | `scripts/06_subgroup/19-森林图绘制-子项.R` | 末尾 `system("open ...")` 为 macOS 专用 | 改为 `browseURL()` | Windows/Linux 不再报错 |
| 14 | 多个脚本 | 调用 `read_excel` / `write_xlsx` / `pivot_wider` / `ggforest` 等但未 `library()` | 补齐缺失依赖（见下表） | 脚本不再因 `could not find function` 中断 |

### 补齐的 `library()`

| 文件 | 补充的包 |
|---|---|
| `scripts/02_tyg/3-MI因子开发.R` | `readxl`、`writexl` |
| `scripts/02_tyg/4-tyg因子开发.R` | `writexl` |
| `scripts/04_survival/7-累计死亡率.R` | `dplyr` |
| `scripts/04_survival/10-cox交互.R` | `readxl` |
| `scripts/05_prediction/18-auc比较.R` | `readxl`、`dplyr` |
| `scripts/05_prediction/检验auc.R` | `knitr`、`kableExtra` |
| `scripts/07_cytokine/2-细胞因子散点图绘制.R` | `readxl` |
| `scripts/07_cytokine/4-graphpad处理数据.R` | `dplyr`、`tidyr`、`writexl` |
| `scripts/90_archive_mimic_2024/7-25-从csv找数据库信息.R` | `writexl` |
| `scripts/90_archive_mimic_2024/cox回归单因素森林图.R` | `survival`、`forestmodel`、`survminer`、`ggplot2`、`ggpubr` |

---

## 2. 保留未改、需要作者确认的问题

| # | 文件 | 问题 | 建议 |
|---:|---|---|---|
| 1 | `scripts/03_descriptive/8-绘制线性相关.R` | `select(TyG = CD4, Mortality = D28)` 把 CD4 重命名为 TyG，图实际展示 CD4 | 明确图的暴露变量；若论文写的是 TyG，应改回 `TyG_index` 并调整 x 轴刻度 |
| 2 | `scripts/06_subgroup/13-多个亚组变量比较分析.R` | `stratify_vars` 实际只保留 `gender`，其余变量被注释 | 若论文报告多个亚组，取消注释并核对交互项命名 |
| 3 | `scripts/06_subgroup/19-森林图.R`、`19-森林图绘制-子项.R` | N / HR / CI / P 全部手工写死，不随分析更新 | 用 `13-` 系列最新结果替换；建议改为读取结果表自动绘图 |
| 4 | `scripts/06_subgroup/13-亚组分析单独计算p交互.R` | 手算交互 P 时自由度取 3，而 3 组比较应为 G−1=2，p 值偏大 | 改为 `qchisq(1-p, df = 2)` 或直接用 LRT |
| 5 | `scripts/07_cytokine/` | 散点图用 `标准化样本1.xlsx`，热图用 `标准化样本-0729.xlsx`，是两版标准化结果 | 统一标准化流程与数据版本后再出图 |
| 6 | `scripts/02_tyg/4-tyg因子开发.R` | 读取 `MI_2.0.xlsx`，仓库内没有生成它的脚本 | 补上游脚本，或把已生成的 `MI_2.0.xlsx` 放入数据目录 |
| 7 | `scripts/02_tyg/3-MI因子开发.R` / `4-tyg因子开发.R` | `8-4s0.xlsx` 与 `MI_score.xlsx` 的上下游关系存在循环，文件命名不直观 | 明确“先 4-tyg 还是先 3-MI”，并改用有方向性的文件名 |
| 8 | `scripts/04_survival/11-联合分析.R` | 不读文件，直接使用 `10-cox交互.R` 会话中的 `hiv_pos` | 建议在脚本开头保存/读取 `hiv_pos.rds`，或合并为一个可独立运行脚本 |
| 9 | `scripts/04_survival/cox模型比较.R` | 时间依赖 AUC 固定 14 天，主分析为 28 天 | 确认是否为敏感性分析；若应统一，改为 28 天 |
| 10 | `scripts/05_prediction/AUC-ROC.R` | 使用 `death_28`，主数据为 `D28`，属旧数据版本 | 核对数据版本后统一列名 |
| 11 | `scripts/08_exploratory/9-跑通中介效应.R` | `boot=1000` 未设 `set.seed()`；结局为二分类但中介模型用 `lm` | 加 `set.seed()`；考虑 `glm(binomial)` 或说明用线性近似 |
| 12 | `scripts/05_prediction/15-DCA-决策曲线.R` | 曲线名写死 `HISPS`；`ylim = c(-0.05, 0.2)` 可能截断 | 改为实际模型名；检查 y 轴范围 |
| 13 | `scripts/01_data_prep/1-简单合并处理.R` | 以“姓名 + 性别 + 年龄”作为连接键，重名会错配；含敏感字段 | 改用住院号/就诊号等唯一 ID；确认脱敏后再共享 |
| 14 | `scripts/04_survival/14-VIF-检查共线性.R` | 二分类结局却用 `lm()` 求 VIF | 仅用于共线性诊断尚可，但需在方法中说明；或用 `car::vif()` 的 logistic 版本 |
| 15 | `scripts/90_archive_mimic_2024/7-26-Rcs曲线.R` | RCS 模型与 rcsplot 的结局分别用 day28 / year1_outcome | 归档脚本，不影响主分析；复用前统一结局 |
| 16 | `scripts/90_archive_mimic_2024/7-29-RCS.R` | 模型用 day28，末尾 `rcsplot()` 仍用 `year1_outcome` | 同上 |
| 17 | `scripts/90_archive_mimic_2024/8-6-亚组分析森林图.R` | `xticks = c(0.990, 1.015)` 范围极窄 | 归档练习稿；按实际 HR 调整 |
| 18 | 多个脚本 | `14.xlsx` 被 3 个脚本写入，存在覆盖风险 | 保留原文件名以兼容原流程；建议改为 `14-tyg.xlsx` / `14-mi.xlsx` 等唯一名 |

---

## 3. 验证结果

| 检查项 | 结果 |
|---|---|
| 清单脚本数 vs `scripts/` 脚本数 | 49 / 49 |
| `parse()` 语法检查 | 53 个 R 文件，0 失败（49 分析脚本 + `00_setup.R` + `packages.R` + 2 个 `tools/` 脚本） |
| Git 跟踪数据文件 | 0 |
| 明文凭据 | 0 |
| 硬编码 `setwd("...")` | 0（统一为 `Sys.getenv("TYG_DATA_DIR", ...)`） |
| 阶段目录 README | 10 / 10 |
| 仓库自检结论 | **PASS** |

> `parse()` 和自检只验证语法与仓库卫生，**不验证运行时数据是否齐备、包版本是否兼容、修复后数值是否与论文一致**。由于本仓库不含数据，本轮未做运行时回归测试。

---

## 4. 建议的复核顺序

1. 先跑 `scripts/03_descriptive/tyg热图绘制.R`，确认四格死亡数与论文 Figure 一致。
2. 再跑 `scripts/02_tyg/1-计算tyg.R` 与 `2-四分位间距.R`，确认 TyG3 / TyGbmi4 分组人数。
3. 跑 `scripts/04_survival/5-1-COX模型.R`，核对 P for trend 是否与正文一致。
4. 跑 `scripts/04_survival/10-cox交互.R` → `11-联合分析.R`（同一会话），核对 AUC / NRI / DCA。
5. 最后重跑 `scripts/06_subgroup/` 并用结果替换两个 `19-森林图` 中的硬编码数值。
6. 细胞因子部分先统一 `标准化样本1.xlsx` 与 `标准化样本-0729.xlsx` 的版本，再重跑热图与散点图。

完整运行顺序见 [`pipeline.md`](pipeline.md)，文件级依赖见 [`dependencies.md`](dependencies.md)。
