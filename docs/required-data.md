# 原始数据准备清单

下表列出**不是由仓库内脚本生成、必须由使用者提供**的输入文件。
把这些文件放入 `TYG_DATA_DIR` 指向的目录，即可按 [`pipeline.md`](pipeline.md) 运行。

- 外部输入文件：**27** 个
- 仓库内脚本生成的中间文件：**2** 个
- 同名/歧义文件：**1** 个（见 [`dependencies.md`](dependencies.md) 第 2 节）

> 通过变量拼接路径、`list.files()` 批量读取或循环写入的文件无法被静态识别，个别“原始输入”实际上可能是上游脚本动态生成的中间表。

## 文件清单

| 原始文件 | 使用它的脚本 |
|---|---|
| `0211.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `1-188-聚类细胞因子-初次合并未处理.xlsx` | `scripts/99_superseded/21-细胞因子热图横置.R` |
| `1.5w-总表1.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `1300-hiv.xlsx` | `scripts/01_data_prep/12-分层数据.R`<br>`scripts/03_descriptive/tyg热图绘制.R`<br>`scripts/04_survival/10-cox交互.R`<br>`scripts/05_prediction/检验auc.R` |
| `1500-插补.xlsx` | `scripts/02_tyg/1-计算tyg.R` |
| `1800质控.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `29-3991-总- (2).xlsx` | `scripts/01_data_prep/12-分层数据.R` |
| `3-864-hiv-tyg.xlsx` | `scripts/04_survival/cox模型比较.R`<br>`scripts/99_superseded/2-建立两个模型比较.R` |
| `47-4065-3200-住院-首日病程-gcs.xlsx` | `scripts/01_data_prep/12-分层数据.R` |
| `7-入院记录时间内166.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `8-首日病程合166.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `8sss.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `9-116出院记录合.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `CRRT.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `HIV.xlsx` | `scripts/04_survival/14-VIF-检查共线性.R` |
| `hiv表单在时间内140人.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `MI_2.0.xlsx` | `scripts/02_tyg/4-tyg因子开发.R` |
| `ndxz.csv` | `scripts/90_archive_mimic_2024/6-7合并数据.R` |
| `tyg-1300-hiv.xlsx` | `scripts/01_data_prep/1-简单合并处理.R`<br>`scripts/02_tyg/1-计算tyg.R`<br>`scripts/03_descriptive/8-绘制线性相关.R`<br>`scripts/04_survival/5-1-COX模型.R`<br>`scripts/04_survival/6-KM1.R`<br>`scripts/05_prediction/17-计算比较AIC模型加强版.R`<br>`scripts/05_prediction/18-auc比较.R`<br>`scripts/05_prediction/15-DCA-决策曲线.R`<br>`scripts/99_superseded/17-计算比较AIC模型.R` |
| `标准化样本-0729.xlsx` | `scripts/07_cytokine/16-细胞因子热图绘制.R`<br>`scripts/07_cytokine/4-graphpad处理数据.R` |
| `肾.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `时间内的透析.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `数据缺失情况.xlsx` | `scripts/01_data_prep/20-数据缺失统计.R` |
| `细胞因子1300初步数据1.xlsx` | `scripts/07_cytokine/1-细胞因子标准化.R` |
| `亚组分析表.xlsx` | `scripts/06_subgroup/13-多个亚组变量比较分析.R`<br>`scripts/99_superseded/12-亚组分析.R` |
| `总.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |
| `最后总诊断1.xlsx` | `scripts/01_data_prep/1-简单合并处理.R` |

