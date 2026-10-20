# 脚本代码索引

> 由 [`script-manifest.csv`](script-manifest.csv) 自动生成。修改清单后运行 `Rscript tools/build_docs.R`，不要手工编辑本文件。

共 **49** 个分析脚本，按 **10** 个阶段分类。每个阶段目录下另有一份 README。

## 总览

| 阶段 | 目录 | 脚本数 | 其中绘图脚本 |
|---|---|---:|---:|
| 01 数据准备 | [`scripts/01_data_prep/`](../scripts/01_data_prep/README.md) | 3 | 0 |
| 02 TyG 指数与分组 | [`scripts/02_tyg/`](../scripts/02_tyg/README.md) | 4 | 1 |
| 03 描述性分析与绘图 | [`scripts/03_descriptive/`](../scripts/03_descriptive/README.md) | 2 | 2 |
| 04 生存分析 | [`scripts/04_survival/`](../scripts/04_survival/README.md) | 7 | 3 |
| 05 预测性能 | [`scripts/05_prediction/`](../scripts/05_prediction/README.md) | 5 | 3 |
| 06 亚组与森林图 | [`scripts/06_subgroup/`](../scripts/06_subgroup/README.md) | 4 | 2 |
| 07 细胞因子 | [`scripts/07_cytokine/`](../scripts/07_cytokine/README.md) | 4 | 2 |
| 08 探索性分析 | [`scripts/08_exploratory/`](../scripts/08_exploratory/README.md) | 1 | 0 |
| 90 2024 年 MIMIC 练习（归档） | [`scripts/90_archive_mimic_2024/`](../scripts/90_archive_mimic_2024/README.md) | 15 | 9 |
| 99 被替代 / 半成品 | [`scripts/99_superseded/`](../scripts/99_superseded/README.md) | 4 | 1 |

## 01 数据准备（`scripts/01_data_prep/`）

原始表合并、去重、质控、器官障碍评分与缺失统计，产出后续分析使用的主表。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`1-简单合并处理.R`](../scripts/01_data_prep/1-简单合并处理.R) | 6 段独立流程：细胞因子×TyG 合并、诊断合并、1.5 万总表合并、1800 质控批量合并、入院/病程/出院合并、诊断时间标记 | 标准化样本1.xlsx<br>tyg-1300-hiv.xlsx<br>总.xlsx<br>最后总诊断1.xlsx<br>0211.xlsx<br>1.5w-总表1.xlsx<br>肾.xlsx<br>CRRT.xlsx<br>时间内的透析.xlsx<br>1800质控.xlsx<br>7-入院记录时间内166.xlsx<br>8-首日病程合166.xlsx<br>9-116出院记录合.xlsx<br>hiv表单在时间内140人.xlsx<br>8sss.xlsx | s82s.xlsx<br>12.xlsx<br>1.5w-总表1_合并后.xlsx<br>合并后的1800质控.xlsx<br>8ssss.xlsx | 否 | 独立运行 | 含姓名/性别/年龄/住院号等敏感字段；输出 12.xlsx 与其它脚本撞名 |
| [`12-分层数据.R`](../scripts/01_data_prep/12-分层数据.R) | 构建 PLT/Cr/TBIL/呼吸指数器官障碍评分，以及 CD4/HIVRNA/ThTs/GCS-SOFA 评分 | 1300-hiv.xlsx<br>29-3991-总- (2).xlsx<br>47-4065-3200-住院-首日病程-gcs.xlsx | 8-4067-初步总3991s.xlsx<br>processed1.xlsx<br>数据.csv | 否 | 独立运行 | 已删除重复的 bilirubin_score 定义 |
| [`20-数据缺失统计.R`](../scripts/01_data_prep/20-数据缺失统计.R) | 统计各变量缺失例数与百分比 | 数据缺失情况.xlsx | Missing_Data_Report.xlsx | 否 | 独立运行 | — |

## 02 TyG 指数与分组（`scripts/02_tyg/`）

TyG 指数定义、ROC 截断值、二分/三分/四分位分组，以及 MI / TyG 复合因子。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`1-计算tyg.R`](../scripts/02_tyg/1-计算tyg.R) | 计算 TyG_index，生成二分/三分/四分位分组，ROC 约登法确定截断值 | 1500-插补.xlsx<br>tyg-1300-hiv.xlsx | 8-40.xlsx<br>14.xlsx<br>TyG_Index_Cutoff_Analysis.xlsx<br>TyG_index_ROC_curve.png<br>TyG_index_ROC_curve.pdf | 是 | 独立运行 | 二分位已改名为 TyG2 避免覆盖 TyG3；14.xlsx 与其它脚本撞名 |
| [`2-四分位间距.R`](../scripts/02_tyg/2-四分位间距.R) | 由会话对象生成 TyGbmi3/TyG3/TyGbmi4 分组 | (会话对象 X595_重新计算) | 14.xlsx | 否 | 依赖会话对象 | 已修正 TyGbmi4 切点误用 TyG_index 的问题；14.xlsx 撞名 |
| [`3-MI因子开发.R`](../scripts/02_tyg/3-MI因子开发.R) | 由 TyG 与 CD4 构造 MI_2.0 复合指标并分组 | 8-4s0.xlsx | MI_score.xlsx<br>14.xlsx | 否 | 独立运行 | 已补 readxl/writexl；14.xlsx 撞名 |
| [`4-tyg因子开发.R`](../scripts/02_tyg/4-tyg因子开发.R) | RCS 节点选择与 maxstat 拐点；构建 CD4_s、TYG2、SOFA 评分与总分 | MI_2.0.xlsx | 8-4s0.xlsx | 否 | 独立运行 | 上游 MI_2.0.xlsx 在仓库内无生成脚本；已补 writexl |

## 03 描述性分析与绘图（`scripts/03_descriptive/`）

描述性统计与图表：TyG × CD4 死亡率热图、CD4 与死亡的关系曲线。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`tyg热图绘制.R`](../scripts/03_descriptive/tyg热图绘制.R) | TyG×CD4 四格 28 天死亡率热图 | 1300-hiv.xlsx | tyg_cd4_heatmap.png<br>tyg_cd4_heatmap.pdf<br>tyg_cd4_heatmap_data.csv | 是 | 独立运行 | 已修复 summarise 整列求和导致的重复计数 |
| [`8-绘制线性相关.R`](../scripts/03_descriptive/8-绘制线性相关.R) | logistic 拟合 CD4 与 28 天死亡并画预测概率曲线 | tyg-1300-hiv.xlsx | (屏幕输出) | 是 | 独立运行 | 代码把 CD4 重命名为 TyG；图实际展示 CD4 |

## 04 生存分析（`scripts/04_survival/`）

生存分析主链：VIF 共线性、Cox 模型、KM、累积死亡、模型比较、交互与联合分析。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`14-VIF-检查共线性.R`](../scripts/04_survival/14-VIF-检查共线性.R) | 18 个自变量 VIF 共线性检查 | HIV.xlsx | vif.xlsx | 否 | 独立运行 | — |
| [`5-1-COX模型.R`](../scripts/04_survival/5-1-COX模型.R) | 5 个暴露 × 3 套 Cox 模型，输出 HR 与 P for trend | tyg-1300-hiv.xlsx | d28-TyG_index_results.xlsx<br>d28-CD41_results.xlsx<br>d28-TyG_results.xlsx<br>d28-CD4_results.xlsx<br>d28-TYGCD4_results.xlsx | 否 | 独立运行 | P for trend 已统一为 Surv(d28; D28) |
| [`6-KM1.R`](../scripts/04_survival/6-KM1.R) | TYGCD4 四组 28 天 KM + risk table + 两两 log-rank | tyg-1300-hiv.xlsx | (屏幕输出) | 是 | 独立运行 | 两两比较已由 year1_* 改为 d28/D28 与 TYGCD4 |
| [`7-累计死亡率.R`](../scripts/04_survival/7-累计死亡率.R) | KM 生存概率转累积死亡概率并绘图 | (会话对象 data) | cumulative_mortality_risk.png<br>cumulative_mortality_risk.pdf | 是 | 依赖会话对象 | 已补 dplyr |
| [`cox模型比较.R`](../scripts/04_survival/cox模型比较.R) | 5 个 Cox 模型 C-index、14 天 timeROC、IDI/NRI | 3-864-hiv-tyg.xlsx | (控制台输出) | 否 | 独立运行 | 时间点固定 14 天，与主分析 28 天不同 |
| [`10-cox交互.R`](../scripts/04_survival/10-cox交互.R) | TyG、TyG+CD4、TyG×CD4 三模型比较并在会话中生成 hiv_pos | 1300-hiv.xlsx | (会话对象 hiv_pos) | 否 | 独立运行 | 已补 readxl；11-联合分析.R 依赖本脚本 |
| [`11-联合分析.R`](../scripts/04_survival/11-联合分析.R) | 联合模型 C-index、timeROC、DeLong、NRI、DCA、KM、森林图 | (会话对象 hiv_pos) | (屏幕输出) | 是 | 依赖会话对象 | 已修正 AUC 索引 [2]→[1] 与协变量 age+gender+sofa；须接在 10-cox交互.R 后 |

## 05 预测性能（`scripts/05_prediction/`）

预测性能评价：ROC / AUC / DeLong、AIC / BIC / Hosmer–Lemeshow、DCA。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`AUC-ROC.R`](../scripts/05_prediction/AUC-ROC.R) | 标准化 CD4/TYG/TYGCD4 后建 logistic 模型比较 AUC/AIC 并画 ROC 与校准曲线 | (会话对象 df) | (屏幕输出) | 是 | 依赖会话对象 | 列名 death_28 为旧数据版本 |
| [`检验auc.R`](../scripts/05_prediction/检验auc.R) | 单变量 logistic OR 表与 AUC/AIC/BIC/LRT 比较 | 1300-hiv.xlsx | (控制台输出) | 否 | 独立运行 | 已补 knitr/kableExtra；death_28 已改为 D28 |
| [`17-计算比较AIC模型加强版.R`](../scripts/05_prediction/17-计算比较AIC模型加强版.R) | 三模型 AUC/Brier/HL/AIC/BIC 比较并导出 JAMA 风格三线表 | tyg-1300-hiv.xlsx | JAMA_Model_Comparison_Table_Fixed.xlsx | 否 | 独立运行 | 推荐版本 |
| [`18-auc比较.R`](../scripts/05_prediction/18-auc比较.R) | 三模型 AUC/DeLong/敏感度特异度/PPV-NPV 比较并生成 Word 报告 | tyg-1300-hiv.xlsx | 模型性能比较分析报告.docx | 是 | 独立运行 | 已补 readxl/dplyr |
| [`15-DCA-决策曲线.R`](../scripts/05_prediction/15-DCA-决策曲线.R) | TYGCD4 与 SOFA 的决策曲线分析 | tyg-1300-hiv.xlsx | (屏幕输出) | 是 | 独立运行 | 曲线名 HISPS 与 TYGCD4 的对应关系需说明 |

## 06 亚组与森林图（`scripts/06_subgroup/`）

亚组 Cox、交互 P 计算与森林图。注意两个 19- 脚本的数值为手工录入。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`13-多个亚组变量比较分析.R`](../scripts/06_subgroup/13-多个亚组变量比较分析.R) | TYGCD4 四分类分层 Cox（2/3/4 vs 1），输出 HR 与 LRT 交互 P | 亚组分析表.xlsx | 加day28_all_comparisonss.xlsx | 否 | 独立运行 | 推荐版本；stratify_vars 实际只保留 gender |
| [`13-亚组分析单独计算p交互.R`](../scripts/06_subgroup/13-亚组分析单独计算p交互.R) | 由 6 组 HR/CI 手算交互 P | (脚本内硬编码) | (控制台输出) | 否 | 模板/硬编码 | 自由度取组数 3 而非 G−1=2，p 值偏大 |
| [`19-森林图.R`](../scripts/06_subgroup/19-森林图.R) | 肝硬化/非肝硬化分层 JAMA 风格森林图 | (脚本内硬编码) | jama_style_forestplot.png | 是 | 模板/硬编码 | N/HR/CI/P 全部写死；需用最新亚组结果替换 |
| [`19-森林图绘制-子项.R`](../scripts/06_subgroup/19-森林图绘制-子项.R) | 糖尿病/非糖尿病分层森林图 | (脚本内硬编码) | forest_plot_diabetes_stratified.png | 是 | 模板/硬编码 | 数值写死；打开图片已改为跨平台 browseURL |

## 07 细胞因子（`scripts/07_cytokine/`）

细胞因子标准曲线标准化、小提琴/散点图、热图与 GraphPad 宽表导出。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`1-细胞因子标准化.R`](../scripts/07_cytokine/1-细胞因子标准化.R) | C0–C7 标准曲线对 13 种细胞因子插值标准化 | 细胞因子1300初步数据1.xlsx | 标准化样本1.xlsx | 否 | 独立运行 | approx() 线性插值而非四参数 logistic |
| [`2-细胞因子散点图绘制.R`](../scripts/07_cytokine/2-细胞因子散点图绘制.R) | 细胞因子长表按 TyG 高低画小提琴+散点并标 Wilcoxon | 标准化样本1.xlsx | (屏幕输出) | 是 | 独立运行 | 已补 readxl；只展示 6 个细胞因子 |
| [`16-细胞因子热图绘制.R`](../scripts/07_cytokine/16-细胞因子热图绘制.R) | TYGCD4 分组 12 种细胞因子均值 pheatmap 热图 | 标准化样本-0729.xlsx | (屏幕输出) | 是 | 独立运行 | 与散点图使用的标准化版本不同 |
| [`4-graphpad处理数据.R`](../scripts/07_cytokine/4-graphpad处理数据.R) | 整理 GraphPad 可直接粘贴的分组宽表 | 标准化样本-0729.xlsx | cytokine_grouped_data.xlsx | 否 | 独立运行 | 已补 dplyr/tidyr/writexl |

## 08 探索性分析（`scripts/08_exploratory/`）

探索性中介分析（TyG → CD4 → 28 天死亡）。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`9-跑通中介效应.R`](../scripts/08_exploratory/9-跑通中介效应.R) | CD41 中介 TyG_index→28 天死亡的中介效应 | (会话对象 data) | (控制台输出) | 否 | 依赖会话对象 | boot=1000 未设 seed；结局二分类而中介模型用 lm |

## 90 2024 年 MIMIC 练习（归档）（`scripts/90_archive_mimic_2024/`）

2024 年 MIMIC-IV / bdmcc 脓毒症数据练习。变量体系与 HIV 主分析不同，不属于论文主分析，仅作方法参考。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`6-7合并数据.R`](../scripts/90_archive_mimic_2024/6-7合并数据.R) | 随访表与 bdmcc 人群表按 subject_id 左连接;并演示按 ID 合并桌面 CSV | ndxz.csv<br>(会话对象 final/CD/X2306/X5800总) | finasl.xlsx<br>f.csv | 否 | 依赖会话对象 | 文件名 finasl 为原拼写；路径已改为 TYG_DATA_DIR |
| [`7-23-处理 时间格式.R`](../scripts/90_archive_mimic_2024/7-23-处理 时间格式.R) | lubridate 统一入院时间格式 | (会话对象 X9869_icu大于24) | final.xlsx | 否 | 依赖会话对象 | — |
| [`7-23-连接数据库-提取血糖.R`](../scripts/90_archive_mimic_2024/7-23-连接数据库-提取血糖.R) | 连接 PostgreSQL 按 hadm_id 提取 itemid=51000 血糖 | mimic4_v22.mimiciv_hosp.labevents<br>(会话对象 lianxi) | tg.xlsx | 否 | 依赖会话对象 | 凭据改为环境变量 |
| [`7-24-挑选接近时间.R`](../scripts/90_archive_mimic_2024/7-24-挑选接近时间.R) | 取与入院时间最接近的血糖记录 | (会话对象 lianxi/tg) | closest_times1.csv | 否 | 依赖会话对象 | 时间差并列时会保留多行 |
| [`7-25-从csv找数据库信息.R`](../scripts/90_archive_mimic_2024/7-25-从csv找数据库信息.R) | 按 subject_id 批量查询 bdmcc_population | mimic4_v22.bdmcc.bdmcc_population<br>(会话对象 final) | bdmcc_population_data .xlsx | 否 | 依赖会话对象 | 已补 writexl；凭据改为环境变量 |
| [`7-26-Rcs曲线.R`](../scripts/90_archive_mimic_2024/7-26-Rcs曲线.R) | lm+rcs(TyGbmi;3)+plotRCS 画 RCS 曲线 | (会话对象 X642_sephf_全) | (屏幕输出) | 是 | 依赖会话对象 | 结局用 year1_outcome 而非 day28 |
| [`7-26-cox风险比例模型.R`](../scripts/90_archive_mimic_2024/7-26-cox风险比例模型.R) | TyGbmi 单因素 Cox、生存曲线与 cox.zph | (会话对象 X642_sephf_全) | (屏幕输出) | 是 | 依赖会话对象 | ggsurvplot 画的是协变量均值处单条曲线 |
| [`7-29-RCS.R`](../scripts/90_archive_mimic_2024/7-29-RCS.R) | cph+rcs(TyGbmi;4) 拟合 28 天结局并用 ggplot 画 HR 曲线 | (会话对象 X642_sephf_全) | (屏幕输出) | 是 | 依赖会话对象 | 已补 labs() 前缺失的 +；rcsplot 仍用 year1_outcome |
| [`7-29-gpt-RCS.R`](../scripts/90_archive_mimic_2024/7-29-gpt-RCS.R) | 同类 RCS 的 GPT 改写版 | (会话对象 X11) | (屏幕输出) | 是 | 依赖会话对象 | 旧版可弃 |
| [`7-29-线性回归 - 副本.R`](../scripts/90_archive_mimic_2024/7-29-线性回归 - 副本.R) | HbA1c–Protein_A 散点图+回归线模板 | file.choose() 选择的 CSV | (屏幕输出) | 是 | 独立运行 | 与 TyG 项目无关的模板 |
| [`8-18-对比refer亚组.R`](../scripts/90_archive_mimic_2024/8-18-对比refer亚组.R) | TyGbmi3 按 10 个变量分层 Cox 输出 Q2/Q3 HR 与交互 P | (会话对象 data) | stratified_analysis_results.xlsx<br>stratified_analysis_counts.xlsx | 否 | 依赖会话对象 | 已拆分第二次输出避免覆盖 |
| [`8-20-柱状图.R`](../scripts/90_archive_mimic_2024/8-20-柱状图.R) | HR 柱状图排版模板 | (脚本内硬编码) | (屏幕输出) | 是 | 模板/硬编码 | 数值写死 |
| [`8-6-亚组分析森林图.R`](../scripts/90_archive_mimic_2024/8-6-亚组分析森林图.R) | forestplot 亚组森林图练习 | (会话对象 森林图练习) | (屏幕输出) | 是 | 依赖会话对象 | xticks 范围极窄，仅适合特定 HR |
| [`8-8-ROC.R`](../scripts/90_archive_mimic_2024/8-8-ROC.R) | TyG_index 单指标 ROC/AUC | (会话对象 X595_重新计算C) | (屏幕输出) | 是 | 依赖会话对象 | 未建模直接使用指标值 |
| [`cox回归单因素森林图.R`](../scripts/90_archive_mimic_2024/cox回归单因素森林图.R) | 单因素 Cox 森林图模板（forestmodel/ggforest/ggplot） | (会话对象 HIVdata)<br>file.choose() 选择的 CSV | cox_result.csv | 是 | 依赖会话对象 | 已补依赖并修正 read.csv 与 rm 的执行顺序 |

## 99 被替代 / 半成品（`scripts/99_superseded/`）

被替代版本、未完成稿与半成品，保留用于与原始分析记录对照。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`12-亚组分析.R`](../scripts/99_superseded/12-亚组分析.R) | 亚组分析基础版（已被 13-多个亚组变量比较分析.R 取代） | 亚组分析表.xlsx | day28.xlsx | 否 | 独立运行 | 保留用于对照 |
| [`17-计算比较AIC模型.R`](../scripts/99_superseded/17-计算比较AIC模型.R) | 模型性能表旧版（已被加强版取代） | tyg-1300-hiv.xlsx | JAMA_Model_Comparison_Table.xlsx | 否 | 独立运行 | 保留用于对照 |
| [`2-建立两个模型比较.R`](../scripts/99_superseded/2-建立两个模型比较.R) | 两 Cox 模型比较未完成版 | 3-864-hiv-tyg.xlsx | (控制台输出) | 否 | 独立运行 | 已把 model_sofa/model_full 修正为 model1/model3 |
| [`21-细胞因子热图横置.R`](../scripts/99_superseded/21-细胞因子热图横置.R) | 细胞因子热图转置半成品 | 1-188-聚类细胞因子-初次合并未处理.xlsx | (屏幕输出) | 是 | 独立运行 | 分组注释只定义 2 组，数据含 3/4 组会失败 |

