# 分析流程与脚本说明

> 脚本按原始工作顺序整理，保留了作者的中文命名与编号。编号重复（两个 `13-`、两个 `19-` 等）代表同一阶段的不同迭代版本，不是错误。
> 每个脚本实际读写的文件名见 [`input-output.md`](input-output.md)。

---

## 总览

```
01_data_prep      原始表 → 合并、清洗、器官障碍评分、缺失统计 → 分析主表
      │
      ├── 02_tyg              TyG 计算、截断值、四分位分组、MI / TyG 因子
      │
      ├── 03_descriptive      死亡率热图、CD4–死亡关系曲线
      │
      ├── 04_survival         VIF、Cox、KM、累积死亡、模型比较、交互、联合分析
      │
      ├── 05_prediction       ROC / AUC / DeLong、AIC/BIC/HL、DCA
      │
      ├── 06_subgroup         亚组 Cox、交互 P、森林图
      │
      ├── 07_cytokine         细胞因子标准化、小提琴图、热图、GraphPad 导出
      │
      ├── 08_exploratory      中介效应
      │
      ├── 90_archive_mimic_2024   2024 年 MIMIC 脓毒症练习（与论文主分析无关）
      │
      └── 99_superseded       被替代版本 / 半成品
```

---

## 01 数据准备（`scripts/01_data_prep/`）

| 脚本 | 作用 |
|---|---|
| `1-简单合并处理.R` | 一个脚本包含 6 段独立的合并/去重流程：细胞因子表×TyG 表按姓名合并、诊断表合并、1.5 万总表合并、1800 质控表批量合并、入院/病程/出院记录合并、诊断时间标记。输入输出较多，见 `input-output.md` |
| `12-分层数据.R` | 依据 PLT、Cr、TBIL、呼吸指数、GCS 构建器官障碍评分；另构建 CD4、HIV RNA、ThTs、GCS-SOFA 评分。串联 3 份不同来源的数据 |
| `20-数据缺失统计.R` | 统计各变量缺失例数与百分比，导出 `Missing_Data_Report.xlsx` |

细胞因子标准化属于独立支线，放在 `07_cytokine/1-细胞因子标准化.R`。

---

## 02 TyG 指数与分组（`scripts/02_tyg/`）

| 脚本 | 作用 |
|---|---|
| `1-计算tyg.R` | 计算 `TyG_index = log(tg * glu / 2)`；用四分位/三分位/二分位分组；用 ROC 约登法确定 TyG 截断值并绘制 ROC |
| `2-四分位间距.R` | 由内存数据生成 `TyGbmi3` / `TyG3` / `TyGbmi4` 分组，导出 `14.xlsx` |
| `4-tyg因子开发.R` | 前半段做 RCS 节点选择与 maxstat 拐点；后半段构建 CD4_s、TYG2、SOFA 评分、两两组合与总分，输出 `8-4s0.xlsx` |
| `3-MI因子开发.R` | 由 TyG 与 CD4 构造 `MI_2.0` 复合指标并分组，输出 `MI_score.xlsx` |

> 顺序说明：`4-tyg因子开发.R` 读取 `MI_2.0.xlsx`，而该文件在本仓库中没有生成脚本（上游断点）；`3-MI因子开发.R` 读取 `8-4s0.xlsx`，两个脚本的文件名关系需要结合原始工程核对。

---

## 03 描述性分析与绘图（`scripts/03_descriptive/`）

| 脚本 | 作用 | 图 |
|---|---|---|
| `tyg热图绘制.R` | 按 TyG 高低 × CD4 高低四格汇总 28 天死亡率，画热图并导出汇总数据 | `tyg_cd4_heatmap.png/pdf` |
| `8-绘制线性相关.R` | logistic 回归拟合 CD4 与 28 天死亡的关系，画预测概率曲线 | 屏幕输出（`ggsave` 被注释） |

> `8-绘制线性相关.R` 内部把 `CD4` 重命名为 `TyG`，图实际展示的是 CD4 而非 TyG，引用前请先核对变量命名。

---

## 04 生存分析（`scripts/04_survival/`）

| 脚本 | 作用 |
|---|---|
| `14-VIF-检查共线性.R` | 对 18 个自变量拟合线性模型并计算 VIF，导出 `vif.xlsx` |
| `5-1-COX模型.R` | 对 TyG_index、CD41、TyG、CD4、TYGCD4 各拟合三套 Cox（未调整 / 部分调整 / 全调整），导出 5 个 `d28-*_results.xlsx` 与 P for trend |
| `6-KM1.R` | 按 TYGCD4 四分组画 28 天 KM 曲线（含 risk table），并做两两 log-rank |
| `7-累计死亡率.R` | 把 KM 生存概率换算为累积死亡概率，画累积事件曲线并拼风险表 |
| `cox模型比较.R` | 5 个 Cox 模型的 C-index、14 天时间依赖 AUC、IDI/NRI 比较（仅控制台输出） |
| `10-cox交互.R` | 比较 TyG、TyG+CD4、TyG×CD4 三模型的 C 指数 / AIC / BIC 与 LR 检验；在会话中生成 `hiv_pos` |
| `11-联合分析.R` | TyG+CD4 联合模型的 C 指数、时间依赖 AUC、DeLong、NRI、DCA、KM、森林图一站式分析 |

> **依赖**：`11-联合分析.R` 不读取文件，直接使用 `10-cox交互.R` 生成的 `hiv_pos`，两个脚本必须在同一 R 会话中按顺序运行。

---

## 05 预测性能（`scripts/05_prediction/`）

| 脚本 | 作用 |
|---|---|
| `AUC-ROC.R` | 标准化 CD4/TYG/TYGCD4 后建 logistic 模型，比较 AUC（DeLong）、AIC，画 ROC 与校准曲线 |
| `检验auc.R` | 单变量 logistic + `gtsummary` 生成 OR 表，比较 AUC/AIC/BIC 并做 LRT |
| `17-计算比较AIC模型加强版.R` | TYG / CD4 / TYG-CD4+SOFA 三个 logistic 模型的 AUC、Brier、Hosmer–Lemeshow、AIC/BIC 比较，导出 JAMA 风格三线表 |
| `18-auc比较.R` | 三模型 AUC / DeLong / 敏感度特异度 / PPV-NPV 比较，并用 `flextable` + `officer` 生成 Word 报告 |
| `15-DCA-决策曲线.R` | 对 TYGCD4 与 SOFA 做决策曲线分析（DCA），画决策曲线 |

> `17-计算比较AIC模型.R`（旧版）已移至 `99_superseded/`，请使用加强版。

---

## 06 亚组与森林图（`scripts/06_subgroup/`）

| 脚本 | 作用 |
|---|---|
| `13-多个亚组变量比较分析.R` | TYGCD4 四分类的分层 Cox（2/3/4 vs 1），输出各层 HR 与 LRT 交互 P（推荐版本） |
| `13-亚组分析单独计算p交互.R` | 手写卡方公式，由 6 组 HR/CI 反算交互 P（计算器脚本，硬编码输入） |
| `19-森林图.R` | 肝硬化 / 非肝硬化分层的 JAMA 风格森林图 |
| `19-森林图绘制-子项.R` | 糖尿病 / 非糖尿病分层的森林图 |

> 两个 `19-` 脚本中的 N、HR、CI、P 均为**手工写死**，不会随分析结果更新；正式出图前请用 `13-` 系列的最新结果替换。
> `12-亚组分析.R`（基础版）已移至 `99_superseded/`。

---

## 07 细胞因子（`scripts/07_cytokine/`）

| 脚本 | 作用 |
|---|---|
| `1-细胞因子标准化.R` | 用 C0–C7 标准曲线对 13 种细胞因子做插值标准化，输出 `标准化样本1.xlsx` |
| `2-细胞因子散点图绘制.R` | 标准化细胞因子转长表，按 TyG 高低画小提琴 + 散点并标 Wilcoxon 显著性 |
| `16-细胞因子热图绘制.R` | 按 TYGCD4 分组求 12 种细胞因子均值，画 `pheatmap` 热图 |
| `4-graphpad处理数据.R` | 把细胞因子宽表整理成 GraphPad 可直接粘贴的分组宽表 |

> 热图使用的是 `标准化样本-0729.xlsx`，散点图使用 `标准化样本1.xlsx`，是两份不同版本的标准化结果，不能混用。

---

## 08 探索性分析（`scripts/08_exploratory/`）

| 脚本 | 作用 |
|---|---|
| `9-跑通中介效应.R` | 以 CD41 为中介、TyG_index 为暴露的中介效应分析（`mediation`，boot=1000） |

---

## 90 2024 年 MIMIC 脓毒症练习（`scripts/90_archive_mimic_2024/`）

这一组脚本是 2024 年 7–8 月的 MIMIC-IV / bdmcc 脓毒症数据练习，变量体系（`TyGbmi`、`year1_outcome`、`day28`）与 HIV 主分析不同，**不属于论文主分析**，仅作方法参考归档。

| 脚本 | 作用 |
|---|---|
| `7-23-连接数据库-提取血糖.R` | 连接本地 PostgreSQL `mimic4_v22`，按 `hadm_id` 批量提取血糖（itemid=51000） |
| `7-24-挑选接近时间.R` | 取与入院时间最接近的血糖记录 |
| `7-25-从csv找数据库信息.R` | 用 subject_id 批量查询 `bdmcc_population` 并导出 |
| `6-7合并数据.R` | 随访表与 bdmcc 人群表按 subject_id 左连接 |
| `7-23-处理 时间格式.R` | 用 lubridate 统一入院时间格式 |
| `7-26-Rcs曲线.R` | `lm + rcs(TyGbmi, 3)` + `plotRCS` 画 RCS 曲线 |
| `7-26-cox风险比例模型.R` | TyGbmi 单因素 Cox、生存曲线与 `cox.zph` 检验 |
| `7-29-RCS.R` | `cph + rcs(TyGbmi, 4)` 拟合 28 天结局，ggplot 画 HR 曲线 |
| `7-29-gpt-RCS.R` | 同类 RCS 的 GPT 改写版（旧版，可弃） |
| `7-29-线性回归 - 副本.R` | HbA1c–Protein_A 散点图模板（与 TyG 无关） |
| `8-18-对比refer亚组.R` | TyGbmi3 按 10 个变量分层 Cox，输出 Q2/Q3 的 HR 与交互 P |
| `8-20-柱状图.R` | HR 柱状图排版模板（数值为硬编码） |
| `8-6-亚组分析森林图.R` | `forestplot` 亚组森林图练习稿 |
| `8-8-ROC.R` | TyG_index 直接对 year1_outcome 做 ROC / AUC |
| `cox回归单因素森林图.R` | 单因素 Cox 森林图模板（forestmodel / ggforest / ggplot 三种写法） |

> 这一组脚本大量依赖同一会话中的内存对象，且缺少可复现的中间落盘文件，不能独立运行。

---

## 99 被替代 / 半成品版本（`scripts/99_superseded/`）

| 脚本 | 说明 |
|---|---|
| `12-亚组分析.R` | 亚组分析基础版，已被 `06_subgroup/13-多个亚组变量比较分析.R` 取代 |
| `17-计算比较AIC模型.R` | 模型性能表旧版，已被 `05_prediction/17-计算比较AIC模型加强版.R` 取代 |
| `2-建立两个模型比较.R` | 未完成（末尾引用未定义的 `model_sofa` / `model_full`），已被 `04_survival/cox模型比较.R` 取代 |
| `21-细胞因子热图横置.R` | 热图转置半成品，分组注释只定义了 2 组，数据含 3/4 组时会失败 |

---

## 关键依赖关系

1. `04_survival/10-cox交互.R` → `04_survival/11-联合分析.R`（内存对象 `hiv_pos`，必须同会话顺序运行）。
2. `90_archive_mimic_2024/7-23-连接数据库-提取血糖.R` → `7-24-挑选接近时间.R` → `7-25-从csv找数据库信息.R` → `6-7合并数据.R`（全程内存传递）。
3. `02_tyg/4-tyg因子开发.R` 读取 `MI_2.0.xlsx`，仓库内无生成脚本，属于上游断点。
4. `02_tyg/2-四分位间距.R`、`04_survival/7-累计死亡率.R`、`08_exploratory/9-跑通中介效应.R`、`05_prediction/AUC-ROC.R` 均直接使用会话内对象，不能单独复现。
5. `06_subgroup/19-森林图*.R` 的数值为手工录入，与 `13-` 系列结果之间没有自动衔接。

---

## 已知代码问题

本轮已修复其中一批明确缺陷，完整清单、可能影响与复核顺序见 [`code-review.md`](code-review.md)。

### 已修复

- `03_descriptive/tyg热图绘制.R`：`summarise()` 中的整列求和已改为按当前分组求和。
- `02_tyg/1-计算tyg.R`：二分位分组已改名为 `TyG2`，不再覆盖三分位 `TyG3`。
- `02_tyg/2-四分位间距.R`：`TyGbmi4` 的切点改为基于 `TyGbmi`。
- `04_survival/5-1-COX模型.R`：P for trend 的结局已统一为 `Surv(d28, D28)`。
- `04_survival/6-KM1.R`：两两 log-rank 已改用 `Surv(d28, D28) ~ TYGCD4`。
- `04_survival/11-联合分析.R`：AUC 索引与协变量命名已修正。
- `05_prediction/检验auc.R`：`death_28` 已改为 `D28`。
- `99_superseded/2-建立两个模型比较.R`：`model_sofa` / `model_full` 已改为 `model1` / `model3`。
- `01_data_prep/12-分层数据.R`：重复的 `bilirubin_score` 已删除。
- 多个脚本缺失的 `library()` 已补齐；`19-森林图绘制-子项.R` 的 macOS `open` 已改为跨平台 `browseURL()`。

### 仍需人工确认

- `06_subgroup/19-森林图*.R`：N / HR / CI / P 仍为硬编码，必须用最新亚组结果替换。
- `03_descriptive/8-绘制线性相关.R`：图中变量被重命名为 `TyG`，实际展示的是 CD4。
- `07_cytokine/`：散点图与热图仍使用两版不同的标准化结果。
- `02_tyg/4-tyg因子开发.R`：上游 `MI_2.0.xlsx` 仍无生成脚本。
- `04_survival/11-联合分析.R`：仍依赖 `10-cox交互.R` 的会话对象 `hiv_pos`。
- `14.xlsx` 仍被 3 个脚本写入，存在覆盖风险。

> 修复会改变部分数值，重跑后请与论文/原始结果逐项核对；原文件备份在 `G:\1-Project\0-script\6-tyg-backup-2026-10-21.zip`。
