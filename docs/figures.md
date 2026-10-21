# 绘图脚本与图形目录

除 [`figures/graphical-abstract.png`](../figures/graphical-abstract.png)（论文官方图形摘要）外，本仓库**不收录运行生成的图片**，只保留绘图代码。所有图形均由脚本在本地运行后生成，输出到工作目录（默认数据目录）或 `output/`。

| 图形 | 脚本 | 输出文件 | 数据来源 |
|---|---|---|---|
| 图形摘要（官方 Graphical abstract） | —（论文 PDF 第 2 页，BioRender） | `figures/graphical-abstract.png` | 论文 PDF；Wu et al., Front Med 2026;12:1688334 |
| TyG × CD4 四格 28 天死亡率热图 | `scripts/03_descriptive/tyg热图绘制.R` | `tyg_cd4_heatmap.png`<br>`tyg_cd4_heatmap.pdf`<br>`tyg_cd4_heatmap_data.csv` | `1300-hiv.xlsx` |
| CD4 与 28 天死亡的预测概率曲线 | `scripts/03_descriptive/8-绘制线性相关.R` | 屏幕输出（`ggsave` 被注释） | `tyg-1300-hiv.xlsx` |
| TYGCD4 四组 28 天 KM 曲线（含 risk table） | `scripts/04_survival/6-KM1.R` | 屏幕输出（未保存） | `tyg-1300-hiv.xlsx` |
| 累积死亡概率曲线 | `scripts/04_survival/7-累计死亡率.R` | `cumulative_mortality_risk.png`<br>`cumulative_mortality_risk.pdf` | 会话对象 `data` |
| TyG 截断值 ROC 曲线 | `scripts/02_tyg/1-计算tyg.R` | `TyG_index_ROC_curve.png`<br>`TyG_index_ROC_curve.pdf` | `1500-插补.xlsx` |
| 多模型 ROC 与校准曲线 | `scripts/05_prediction/AUC-ROC.R` | 屏幕输出 | 会话对象 `df` |
| 三模型 ROC / DeLong 比较（嵌入 Word） | `scripts/05_prediction/18-auc比较.R` | `模型性能比较分析报告.docx` | `tyg-1300-hiv.xlsx` |
| 决策曲线（DCA） | `scripts/05_prediction/15-DCA-决策曲线.R` | 屏幕输出（未保存） | `tyg-1300-hiv.xlsx` |
| 肝硬化分层森林图 | `scripts/06_subgroup/19-森林图.R` | `jama_style_forestplot.png` | 脚本内硬编码 |
| 糖尿病分层森林图 | `scripts/06_subgroup/19-森林图绘制-子项.R` | `forest_plot_diabetes_stratified.png` | 脚本内硬编码 |
| 细胞因子分组热图 | `scripts/07_cytokine/16-细胞因子热图绘制.R` | 屏幕输出（未保存） | `标准化样本-0729.xlsx` |
| 细胞因子小提琴 + 散点图 | `scripts/07_cytokine/2-细胞因子散点图绘制.R` | 屏幕输出（未保存） | `标准化样本1.xlsx` |
| RCS 曲线（MIMIC 练习） | `scripts/90_archive_mimic_2024/7-26-Rcs曲线.R`<br>`7-29-RCS.R` | 屏幕输出 | 会话对象 |
| Cox 生存曲线（MIMIC 练习） | `scripts/90_archive_mimic_2024/7-26-cox风险比例模型.R` | 屏幕输出 | 会话对象 |
| HR 柱状图模板 | `scripts/90_archive_mimic_2024/8-20-柱状图.R` | 屏幕输出 | 脚本内硬编码 |
| 亚组森林图练习 | `scripts/90_archive_mimic_2024/8-6-亚组分析森林图.R` | 屏幕输出 | 会话对象 |

## 绘图相关包

`ggplot2`、`ggpubr`、`ggpmisc`、`ggtext`、`pheatmap`、`forestplot`、`survminer`、`timeROC`、`rmda`、`patchwork`、`grid`、`showtext`、`extrafont`、`plotRCS`。

## 注意

- 两个 `19-森林图` 脚本的 N / HR / CI / P 为手工写死，不代表脚本运行时的最新分析结果。
- `8-绘制线性相关.R` 中的变量被重命名为 `TyG`，实际绘制的是 CD4。
- `tyg热图绘制.R` 的 `summarise()` 存在整列求和问题，详见 [`pipeline.md`](pipeline.md) 的“已知代码问题”。
