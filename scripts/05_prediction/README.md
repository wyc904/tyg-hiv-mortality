# 05 预测性能

预测性能评价：ROC / AUC / DeLong、AIC / BIC / Hosmer–Lemeshow、DCA。

本目录共 **5** 个脚本，其中绘图脚本 **3** 个。

- 返回总索引：[docs/code-index.md](../../docs/code-index.md)
- 机器可读清单：[docs/script-manifest.csv](../../docs/script-manifest.csv)
- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`AUC-ROC.R`](AUC-ROC.R) | 标准化 CD4/TYG/TYGCD4 后建 logistic 模型比较 AUC/AIC 并画 ROC 与校准曲线 | (会话对象 df) | (屏幕输出) | 是 | 依赖会话对象 | 列名 death_28 为旧数据版本 |
| [`检验auc.R`](检验auc.R) | 单变量 logistic OR 表与 AUC/AIC/BIC/LRT 比较 | 1300-hiv.xlsx | (控制台输出) | 否 | 独立运行 | 已补 knitr/kableExtra；death_28 已改为 D28 |
| [`17-计算比较AIC模型加强版.R`](17-计算比较AIC模型加强版.R) | 三模型 AUC/Brier/HL/AIC/BIC 比较并导出 JAMA 风格三线表 | tyg-1300-hiv.xlsx | JAMA_Model_Comparison_Table_Fixed.xlsx | 否 | 独立运行 | 推荐版本 |
| [`18-auc比较.R`](18-auc比较.R) | 三模型 AUC/DeLong/敏感度特异度/PPV-NPV 比较并生成 Word 报告 | tyg-1300-hiv.xlsx | 模型性能比较分析报告.docx | 是 | 独立运行 | 已补 readxl/dplyr |
| [`15-DCA-决策曲线.R`](15-DCA-决策曲线.R) | TYGCD4 与 SOFA 的决策曲线分析 | tyg-1300-hiv.xlsx | (屏幕输出) | 是 | 独立运行 | 曲线名 HISPS 与 TYGCD4 的对应关系需说明 |

