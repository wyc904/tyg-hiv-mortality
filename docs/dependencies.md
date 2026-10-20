# 脚本依赖关系

> 由 [`script-manifest.csv`](script-manifest.csv) 中的文件名自动推断。
> 这是**按文件名匹配**的近似依赖图；通过变量拼接路径、`list.files()` 批量读取，或直接使用会话内存对象的依赖不会出现在确定依赖中。

## 1. 生产者 → 消费者（确定依赖）

| 上游脚本 | 产物 | 下游脚本 |
|---|---|---|
| `scripts/02_tyg/4-tyg因子开发.R` | `8-4s0.xlsx` | `scripts/02_tyg/3-MI因子开发.R` |
| `scripts/07_cytokine/1-细胞因子标准化.R` | `标准化样本1.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `scripts/07_cytokine/1-细胞因子标准化.R` | `标准化样本1.xlsx` | `scripts/07_cytokine/2-细胞因子散点图绘制.R` |

## 2. 同名 / 歧义文件

| 文件名 | 被写入次数 | 被读取次数 | 说明 |
|---|---:|---:|---|
| `14.xlsx` | 3 | 0 | 同名中间表可能指向不同版本，需人工确认 |

## 3. 只写不读的产物（终点输出）

| 产物 | 生成脚本 |
|---|---|
| `s82s.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `12.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `1.5w-总表1_合并后.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `合并后的1800质控.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `8ssss.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `8-4067-初步总3991s.xlsx` | `scripts/01_data_prep/12-分层数据.R` |
| `processed1.xlsx` | `scripts/01_data_prep/12-分层数据.R` |
| `数据.csv` | `scripts/01_data_prep/12-分层数据.R` |
| `Missing_Data_Report.xlsx` | `scripts/01_data_prep/20-数据缺失统计.R` |
| `8-40.xlsx` | `scripts/02_tyg/1-计算tyg.R` |
| `14.xlsx` | `scripts/02_tyg/1-计算tyg.R；scripts/02_tyg/2-四分位间距.R；scripts/02_tyg/3-MI因子开发.R` |
| `TyG_Index_Cutoff_Analysis.xlsx` | `scripts/02_tyg/1-计算tyg.R` |
| `TyG_index_ROC_curve.png` | `scripts/02_tyg/1-计算tyg.R` |
| `TyG_index_ROC_curve.pdf` | `scripts/02_tyg/1-计算tyg.R` |
| `MI_score.xlsx` | `scripts/02_tyg/3-MI因子开发.R` |
| `tyg_cd4_heatmap.png` | `scripts/03_descriptive/tyg热图绘制.R` |
| `tyg_cd4_heatmap.pdf` | `scripts/03_descriptive/tyg热图绘制.R` |
| `tyg_cd4_heatmap_data.csv` | `scripts/03_descriptive/tyg热图绘制.R` |
| `vif.xlsx` | `scripts/04_survival/14-VIF-检查共线性.R` |
| `d28-TyG_index_results.xlsx` | `scripts/04_survival/5-1-COX模型.R` |
| `d28-CD41_results.xlsx` | `scripts/04_survival/5-1-COX模型.R` |
| `d28-TyG_results.xlsx` | `scripts/04_survival/5-1-COX模型.R` |
| `d28-CD4_results.xlsx` | `scripts/04_survival/5-1-COX模型.R` |
| `d28-TYGCD4_results.xlsx` | `scripts/04_survival/5-1-COX模型.R` |
| `cumulative_mortality_risk.png` | `scripts/04_survival/7-累计死亡率.R` |
| `cumulative_mortality_risk.pdf` | `scripts/04_survival/7-累计死亡率.R` |
| `JAMA_Model_Comparison_Table_Fixed.xlsx` | `scripts/05_prediction/17-计算比较AIC模型加强版.R` |
| `模型性能比较分析报告.docx` | `scripts/05_prediction/18-auc比较.R` |
| `加day28_all_comparisonss.xlsx` | `scripts/06_subgroup/13-多个亚组变量比较分析.R` |
| `jama_style_forestplot.png` | `scripts/06_subgroup/19-森林图.R` |
| `forest_plot_diabetes_stratified.png` | `scripts/06_subgroup/19-森林图绘制-子项.R` |
| `cytokine_grouped_data.xlsx` | `scripts/07_cytokine/4-graphpad处理数据.R` |
| `finasl.xlsx` | `scripts/90_archive_mimic_2024/6-7合并数据.R` |
| `f.csv` | `scripts/90_archive_mimic_2024/6-7合并数据.R` |
| `final.xlsx` | `scripts/90_archive_mimic_2024/7-23-处理 时间格式.R` |
| `tg.xlsx` | `scripts/90_archive_mimic_2024/7-23-连接数据库-提取血糖.R` |
| `closest_times1.csv` | `scripts/90_archive_mimic_2024/7-24-挑选接近时间.R` |
| `bdmcc_population_data .xlsx` | `scripts/90_archive_mimic_2024/7-25-从csv找数据库信息.R` |
| `stratified_analysis_results.xlsx` | `scripts/90_archive_mimic_2024/8-18-对比refer亚组.R` |
| `stratified_analysis_counts.xlsx` | `scripts/90_archive_mimic_2024/8-18-对比refer亚组.R` |
| `cox_result.csv` | `scripts/90_archive_mimic_2024/cox回归单因素森林图.R` |
| `day28.xlsx` | `scripts/99_superseded/12-亚组分析.R` |
| `JAMA_Model_Comparison_Table.xlsx` | `scripts/99_superseded/17-计算比较AIC模型.R` |

## 4. 外部输入（不由仓库内脚本生成）

共 **27** 个文件会作为输入被读取，但仓库内没有对应产物；清单见 [`required-data.md`](required-data.md)。

