# 90 2024 年 MIMIC 练习（归档）

2024 年 MIMIC-IV / bdmcc 脓毒症数据练习。变量体系与 HIV 主分析不同，不属于论文主分析，仅作方法参考。

本目录共 **15** 个脚本，其中绘图脚本 **9** 个。

- 返回总索引：[docs/code-index.md](../../docs/code-index.md)
- 机器可读清单：[docs/script-manifest.csv](../../docs/script-manifest.csv)
- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`6-7合并数据.R`](6-7合并数据.R) | 随访表与 bdmcc 人群表按 subject_id 左连接;并演示按 ID 合并桌面 CSV | ndxz.csv<br>(会话对象 final/CD/X2306/X5800总) | finasl.xlsx<br>f.csv | 否 | 依赖会话对象 | 文件名 finasl 为原拼写；路径已改为 TYG_DATA_DIR |
| [`7-23-处理 时间格式.R`](7-23-处理 时间格式.R) | lubridate 统一入院时间格式 | (会话对象 X9869_icu大于24) | final.xlsx | 否 | 依赖会话对象 | — |
| [`7-23-连接数据库-提取血糖.R`](7-23-连接数据库-提取血糖.R) | 连接 PostgreSQL 按 hadm_id 提取 itemid=51000 血糖 | mimic4_v22.mimiciv_hosp.labevents<br>(会话对象 lianxi) | tg.xlsx | 否 | 依赖会话对象 | 凭据改为环境变量 |
| [`7-24-挑选接近时间.R`](7-24-挑选接近时间.R) | 取与入院时间最接近的血糖记录 | (会话对象 lianxi/tg) | closest_times1.csv | 否 | 依赖会话对象 | 时间差并列时会保留多行 |
| [`7-25-从csv找数据库信息.R`](7-25-从csv找数据库信息.R) | 按 subject_id 批量查询 bdmcc_population | mimic4_v22.bdmcc.bdmcc_population<br>(会话对象 final) | bdmcc_population_data .xlsx | 否 | 依赖会话对象 | 已补 writexl；凭据改为环境变量 |
| [`7-26-Rcs曲线.R`](7-26-Rcs曲线.R) | lm+rcs(TyGbmi;3)+plotRCS 画 RCS 曲线 | (会话对象 X642_sephf_全) | (屏幕输出) | 是 | 依赖会话对象 | 结局用 year1_outcome 而非 day28 |
| [`7-26-cox风险比例模型.R`](7-26-cox风险比例模型.R) | TyGbmi 单因素 Cox、生存曲线与 cox.zph | (会话对象 X642_sephf_全) | (屏幕输出) | 是 | 依赖会话对象 | ggsurvplot 画的是协变量均值处单条曲线 |
| [`7-29-RCS.R`](7-29-RCS.R) | cph+rcs(TyGbmi;4) 拟合 28 天结局并用 ggplot 画 HR 曲线 | (会话对象 X642_sephf_全) | (屏幕输出) | 是 | 依赖会话对象 | 已补 labs() 前缺失的 +；rcsplot 仍用 year1_outcome |
| [`7-29-gpt-RCS.R`](7-29-gpt-RCS.R) | 同类 RCS 的 GPT 改写版 | (会话对象 X11) | (屏幕输出) | 是 | 依赖会话对象 | 旧版可弃 |
| [`7-29-线性回归 - 副本.R`](7-29-线性回归 - 副本.R) | HbA1c–Protein_A 散点图+回归线模板 | file.choose() 选择的 CSV | (屏幕输出) | 是 | 独立运行 | 与 TyG 项目无关的模板 |
| [`8-18-对比refer亚组.R`](8-18-对比refer亚组.R) | TyGbmi3 按 10 个变量分层 Cox 输出 Q2/Q3 HR 与交互 P | (会话对象 data) | stratified_analysis_results.xlsx<br>stratified_analysis_counts.xlsx | 否 | 依赖会话对象 | 已拆分第二次输出避免覆盖 |
| [`8-20-柱状图.R`](8-20-柱状图.R) | HR 柱状图排版模板 | (脚本内硬编码) | (屏幕输出) | 是 | 模板/硬编码 | 数值写死 |
| [`8-6-亚组分析森林图.R`](8-6-亚组分析森林图.R) | forestplot 亚组森林图练习 | (会话对象 森林图练习) | (屏幕输出) | 是 | 依赖会话对象 | xticks 范围极窄，仅适合特定 HR |
| [`8-8-ROC.R`](8-8-ROC.R) | TyG_index 单指标 ROC/AUC | (会话对象 X595_重新计算C) | (屏幕输出) | 是 | 依赖会话对象 | 未建模直接使用指标值 |
| [`cox回归单因素森林图.R`](cox回归单因素森林图.R) | 单因素 Cox 森林图模板（forestmodel/ggforest/ggplot） | (会话对象 HIVdata)<br>file.choose() 选择的 CSV | cox_result.csv | 是 | 依赖会话对象 | 已补依赖并修正 read.csv 与 rm 的执行顺序 |

