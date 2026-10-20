# 01 数据准备

原始表合并、去重、质控、器官障碍评分与缺失统计，产出后续分析使用的主表。

本目录共 **3** 个脚本，其中绘图脚本 **0** 个。

- 返回总索引：[docs/code-index.md](../../docs/code-index.md)
- 机器可读清单：[docs/script-manifest.csv](../../docs/script-manifest.csv)
- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`1-简单合并处理.R`](1-简单合并处理.R) | 6 段独立流程：细胞因子×TyG 合并、诊断合并、1.5 万总表合并、1800 质控批量合并、入院/病程/出院合并、诊断时间标记 | 标准化样本1.xlsx<br>tyg-1300-hiv.xlsx<br>总.xlsx<br>最后总诊断1.xlsx<br>0211.xlsx<br>1.5w-总表1.xlsx<br>肾.xlsx<br>CRRT.xlsx<br>时间内的透析.xlsx<br>1800质控.xlsx<br>7-入院记录时间内166.xlsx<br>8-首日病程合166.xlsx<br>9-116出院记录合.xlsx<br>hiv表单在时间内140人.xlsx<br>8sss.xlsx | s82s.xlsx<br>12.xlsx<br>1.5w-总表1_合并后.xlsx<br>合并后的1800质控.xlsx<br>8ssss.xlsx | 否 | 独立运行 | 含姓名/性别/年龄/住院号等敏感字段；输出 12.xlsx 与其它脚本撞名 |
| [`12-分层数据.R`](12-分层数据.R) | 构建 PLT/Cr/TBIL/呼吸指数器官障碍评分，以及 CD4/HIVRNA/ThTs/GCS-SOFA 评分 | 1300-hiv.xlsx<br>29-3991-总- (2).xlsx<br>47-4065-3200-住院-首日病程-gcs.xlsx | 8-4067-初步总3991s.xlsx<br>processed1.xlsx<br>数据.csv | 否 | 独立运行 | 已删除重复的 bilirubin_score 定义 |
| [`20-数据缺失统计.R`](20-数据缺失统计.R) | 统计各变量缺失例数与百分比 | 数据缺失情况.xlsx | Missing_Data_Report.xlsx | 否 | 独立运行 | — |

