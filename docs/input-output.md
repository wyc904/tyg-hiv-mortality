# 脚本输入 / 输出文件清单

> 由脚本中的 `read_excel()` / `read.csv()` / `write_xlsx()` / `write.csv()` / `ggsave()` / `pdf()` 字面量整理。
> 通过变量拼接路径、`list.files()` 批量读取、或直接使用会话内存对象的文件不会出现在“读取”列，已在备注中说明。
> 所有数据文件均**不在本仓库中**。

## 01 数据准备

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/01_data_prep/1-简单合并处理.R` | `标准化样本1.xlsx`<br>`tyg-1300-hiv.xlsx`<br>`总.xlsx`<br>`最后总诊断1.xlsx`<br>`0211.xlsx`<br>`1.5w-总表1.xlsx`<br>`肾.xlsx`<br>`CRRT.xlsx`<br>`时间内的透析.xlsx`<br>`1800质控.xlsx`<br>`7-入院记录时间内166.xlsx`<br>`8-首日病程合166.xlsx`<br>`9-116出院记录合.xlsx`<br>`hiv表单在时间内140人.xlsx`<br>`8sss.xlsx`<br>目录内全部 `*.xlsx`（`list.files`） | `s82s.xlsx`<br>`12.xlsx`<br>`<原文件名>id.xlsx`（批量）<br>`1.5w-总表1_合并后.xlsx`<br>`合并后的1800质控.xlsx`<br>`8ssss.xlsx` | 6 段独立流程；含姓名/性别/年龄/住院号等敏感字段 |
| `scripts/01_data_prep/12-分层数据.R` | `1300-hiv.xlsx`<br>`29-3991-总- (2).xlsx`<br>`47-4065-3200-住院-首日病程-gcs.xlsx` | `8-4067-初步总3991s.xlsx`<br>`processed1.xlsx`<br>`数据.csv` | 构建器官障碍评分与 CD4/HIV RNA 评分 |
| `scripts/01_data_prep/20-数据缺失统计.R` | `数据缺失情况.xlsx` | `Missing_Data_Report.xlsx` | 变量缺失例数与百分比 |

## 02 TyG 指数与分组

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/02_tyg/1-计算tyg.R` | `1500-插补.xlsx`<br>`tyg-1300-hiv.xlsx` | `8-40.xlsx`<br>`14.xlsx`<br>`TyG_Index_Cutoff_Analysis.xlsx`<br>`TyG_index_ROC_curve.png`<br>`TyG_index_ROC_curve.pdf` | `TyG_index = log(tg*glu/2)`；含 ROC 约登截断值 |
| `scripts/02_tyg/2-四分位间距.R` | —（会话对象 `X595_重新计算`） | `14.xlsx` | 不能独立运行；`14.xlsx` 与其它脚本撞名 |
| `scripts/02_tyg/3-MI因子开发.R` | `8-4s0.xlsx` | `MI_score.xlsx`<br>`14.xlsx` | MI_2.0 复合指标 |
| `scripts/02_tyg/4-tyg因子开发.R` | `MI_2.0.xlsx` | `8-4s0.xlsx` | **`MI_2.0.xlsx` 在仓库内无生成脚本**；含 RCS 节点选择与 maxstat |

## 03 描述性分析与绘图

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/03_descriptive/tyg热图绘制.R` | `1300-hiv.xlsx` | `tyg_cd4_heatmap.png`<br>`tyg_cd4_heatmap.pdf`<br>`tyg_cd4_heatmap_data.csv` | TyG × CD4 四格死亡率热图 |
| `scripts/03_descriptive/8-绘制线性相关.R` | `tyg-1300-hiv.xlsx` | —（`ggsave` 被注释） | 实际画的是 CD4，不是 TyG |

## 04 生存分析

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/04_survival/14-VIF-检查共线性.R` | `HIV.xlsx` | `vif.xlsx` | 18 个自变量 |
| `scripts/04_survival/5-1-COX模型.R` | `tyg-1300-hiv.xlsx` | `d28-TyG_index_results.xlsx`<br>`d28-CD41_results.xlsx`<br>`d28-TyG_results.xlsx`<br>`d28-CD4_results.xlsx`<br>`d28-TYGCD4_results.xlsx` | 5 个暴露 × 3 套模型 |
| `scripts/04_survival/6-KM1.R` | `tyg-1300-hiv.xlsx` | —（未保存） | TYGCD4 四组 28 天 KM + risk table |
| `scripts/04_survival/7-累计死亡率.R` | —（会话对象 `data`） | `cumulative_mortality_risk.png`<br>`cumulative_mortality_risk.pdf` | 累积死亡曲线 |
| `scripts/04_survival/cox模型比较.R` | `3-864-hiv-tyg.xlsx` | —（仅控制台） | C-index、14 天 timeROC、IDI/NRI |
| `scripts/04_survival/10-cox交互.R` | `1300-hiv.xlsx` | —（会话对象 `hiv_pos`） | 三模型 C/AIC/BIC/LR |
| `scripts/04_survival/11-联合分析.R` | —（会话对象 `hiv_pos`） | —（图未保存） | 必须接在 `10-cox交互.R` 之后 |

## 05 预测性能

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/05_prediction/AUC-ROC.R` | —（会话对象 `df`） | —（屏幕） | ROC + 校准曲线；列名 `death_28` |
| `scripts/05_prediction/检验auc.R` | `1300-hiv.xlsx` | —（控制台） | OR 表 + AUC/AIC/BIC/LRT |
| `scripts/05_prediction/17-计算比较AIC模型加强版.R` | `tyg-1300-hiv.xlsx` | `JAMA_Model_Comparison_Table_Fixed.xlsx` | 推荐版本 |
| `scripts/05_prediction/18-auc比较.R` | `tyg-1300-hiv.xlsx` | `模型性能比较分析报告.docx` | DeLong + flextable/officer |
| `scripts/05_prediction/15-DCA-决策曲线.R` | `tyg-1300-hiv.xlsx` | —（图未保存） | TYGCD4 vs SOFA 的 DCA |

## 06 亚组与森林图

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/06_subgroup/13-多个亚组变量比较分析.R` | `亚组分析表.xlsx` | `加day28_all_comparisonss.xlsx` | 推荐版本；参考组固定为 1 |
| `scripts/06_subgroup/13-亚组分析单独计算p交互.R` | —（脚本内硬编码 HR/CI） | —（控制台） | 手工交互 P 计算器 |
| `scripts/06_subgroup/19-森林图.R` | —（脚本内硬编码） | `jama_style_forestplot.png` | 肝硬化分层 |
| `scripts/06_subgroup/19-森林图绘制-子项.R` | —（脚本内硬编码） | `forest_plot_diabetes_stratified.png` | 糖尿病分层；末尾为 macOS `open` |

## 07 细胞因子

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/07_cytokine/1-细胞因子标准化.R` | `细胞因子1300初步数据1.xlsx` | `标准化样本1.xlsx` | C0–C7 标准曲线插值 |
| `scripts/07_cytokine/2-细胞因子散点图绘制.R` | `标准化样本1.xlsx` | —（未保存） | 小提琴 + 散点 + Wilcoxon |
| `scripts/07_cytokine/16-细胞因子热图绘制.R` | `标准化样本-0729.xlsx` | —（未保存） | 12 种细胞因子分组均值热图 |
| `scripts/07_cytokine/4-graphpad处理数据.R` | `标准化样本-0729.xlsx` | `cytokine_grouped_data.xlsx` | GraphPad 宽表 |

## 08 探索性分析

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/08_exploratory/9-跑通中介效应.R` | —（会话对象 `data`） | —（控制台） | CD41 中介；boot=1000 未设 seed |

## 90 2024 MIMIC 脓毒症练习（与论文无关）

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/90_archive_mimic_2024/7-23-连接数据库-提取血糖.R` | PostgreSQL `mimic4_v22.mimiciv_hosp.labevents` | `tg.xlsx` | 凭据改为环境变量 |
| `scripts/90_archive_mimic_2024/7-24-挑选接近时间.R` | —（会话对象 `lianxi`、`tg`） | `closest_times1.csv` | 取最接近入院时间的血糖 |
| `scripts/90_archive_mimic_2024/7-25-从csv找数据库信息.R` | PostgreSQL `mimic4_v22.bdmcc.bdmcc_population` | `bdmcc_population_data .xlsx` | 文件名含空格；凭据改为环境变量 |
| `scripts/90_archive_mimic_2024/6-7合并数据.R` | `ndxz.csv`；会话对象 | `finasl.xlsx`<br>`f.csv` | 文件名为原作者的拼写 |
| `scripts/90_archive_mimic_2024/7-23-处理 时间格式.R` | —（会话对象 `X9869_icu大于24`） | `final.xlsx` | 统一入院时间格式 |
| `scripts/90_archive_mimic_2024/7-26-Rcs曲线.R` | —（会话对象 `X642_sephf_全`） | —（屏幕） | `lm + rcs(,3)` + plotRCS |
| `scripts/90_archive_mimic_2024/7-26-cox风险比例模型.R` | —（会话对象 `X642_sephf_全`） | —（屏幕） | 单因素 Cox + cox.zph |
| `scripts/90_archive_mimic_2024/7-29-RCS.R` | —（会话对象 `X642_sephf_全`） | —（屏幕） | `cph + rcs(,4)` + ggplot |
| `scripts/90_archive_mimic_2024/7-29-gpt-RCS.R` | —（会话对象 `X11`） | —（屏幕） | GPT 改写旧版 |
| `scripts/90_archive_mimic_2024/7-29-线性回归 - 副本.R` | `file.choose()` 选择的 CSV | —（屏幕） | HbA1c–Protein_A，与 TyG 无关 |
| `scripts/90_archive_mimic_2024/8-18-对比refer亚组.R` | —（会话对象 `data`） | `stratified_analysis_results.xlsx`（写两次） | 第二次覆盖第一次 |
| `scripts/90_archive_mimic_2024/8-20-柱状图.R` | —（脚本内硬编码） | —（屏幕） | HR 柱状图模板 |
| `scripts/90_archive_mimic_2024/8-6-亚组分析森林图.R` | —（会话对象 `森林图练习`） | —（屏幕） | forestplot 练习 |
| `scripts/90_archive_mimic_2024/8-8-ROC.R` | —（会话对象 `X595_重新计算C`） | —（屏幕） | 单指标 ROC |
| `scripts/90_archive_mimic_2024/cox回归单因素森林图.R` | `file.choose()` 选择的 results CSV | `cox_result.csv` | 三种森林图模板 |

## 99 被替代 / 半成品

| 脚本 | 读取 | 输出 | 备注 |
|---|---|---|---|
| `scripts/99_superseded/12-亚组分析.R` | `亚组分析表.xlsx` | `day28.xlsx` | 已被 `06_subgroup/13-` 取代 |
| `scripts/99_superseded/17-计算比较AIC模型.R` | `tyg-1300-hiv.xlsx` | `JAMA_Model_Comparison_Table.xlsx` | 已被加强版取代 |
| `scripts/99_superseded/2-建立两个模型比较.R` | `3-864-hiv-tyg.xlsx` | — | 未完成，末尾引用未定义对象 |
| `scripts/99_superseded/21-细胞因子热图横置.R` | `1-188-聚类细胞因子-初次合并未处理.xlsx` | —（未保存） | 分组注释只定义 2 组 |
