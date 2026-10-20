# 数据目录说明

本仓库**不包含任何原始数据或患者级数据**。`data/` 仅保留本说明文件，`.gitignore` 已屏蔽常见数据格式（xlsx / csv / sav / dta / RData / rds 等）。

## 为什么不提供数据

- 原始数据含患者姓名、住院号、就诊号、门诊号等可识别信息，不能公开。
- 如期刊或审稿人需要数据，请通过伦理审批允许的受控渠道申请。

## 运行前如何准备数据

把所有输入表放在本机的一个目录中，然后二选一：

1. 设置环境变量（推荐）：

   ```r
   Sys.setenv(TYG_DATA_DIR = "D:/path/to/your/data")
   ```

2. 直接修改各脚本开头的 `setwd(...)`。旧脚本中保留了原始路径（如 `D:/Desktop/`），运行前请改成你的本地路径。

部分脚本不读取文件、而是依赖同一 R 会话中的内存对象（见 `docs/analysis-pipeline.md` 的“依赖关系”一节），需要按顺序在同一会话中运行。

## 脚本所需的输入文件

### HIV 主分析（`R/01`–`R/08`）

| 文件 | 用途 |
|---|---|
| `tyg-1300-hiv.xlsx` | 主分析数据集（TyG、CD4、28 天结局、协变量） |
| `1300-hiv.xlsx` | 主数据集较早版本，用于分层、热图、交互分析等 |
| `1500-插补.xlsx` | 缺失值插补后的 TyG 计算数据 |
| `3-864-hiv-tyg.xlsx` | 模型比较子集 |
| `HIV.xlsx` | VIF 共线性检查数据 |
| `亚组分析表.xlsx` | 亚组分析数据 |
| `数据缺失情况.xlsx` | 缺失统计 |
| `细胞因子1300初步数据1.xlsx` | 细胞因子原始读数（C0–C7 标准曲线） |
| `标准化样本1.xlsx` | 细胞因子标准化结果（脚本产物） |
| `标准化样本-0729.xlsx` | 细胞因子标准化结果（另一版本） |
| `1-188-聚类细胞因子-初次合并未处理.xlsx` | 细胞因子聚类前数据 |
| `MI_2.0.xlsx` | MI 因子中间数据（**仓库内无脚本生成，需自备**） |
| `8-4s0.xlsx` | TyG 因子开发中间数据 |
| `总.xlsx`、`最后总诊断1.xlsx` | 诊断信息合并 |
| `0211.xlsx` | 主表（批量合并用） |
| `1.5w-总表1.xlsx` | 大总表 |
| `肾.xlsx`、`CRRT.xlsx`、`时间内的透析.xlsx` | 肾脏/CRRT/透析信息 |
| `1800质控.xlsx` | 质控主表 |
| `7-入院记录时间内166.xlsx`、`8-首日病程合166.xlsx`、`9-116出院记录合.xlsx`、`hiv表单在时间内140人.xlsx` | 质控合并用表 |
| `29-3991-总- (2).xlsx`、`47-4065-3200-住院-首日病程-gcs.xlsx` | 器官障碍评分数据 |
| `8sss.xlsx` | 诊断时间标记中间数据 |

### 2024 MIMIC 练习分支（`R/90-archive-mimic-2024`，与论文主分析无关）

- PostgreSQL 数据库 `mimic4_v22`（`mimiciv_hosp.labevents`、`bdmcc.bdmcc_population`）
- `ndxz.csv`（默认与其它数据表放在同一目录）
- 其余脚本依赖 R 会话中的内存对象（`X642_sephf_全`、`X595_重新计算C` 等）

数据库连接凭据已改为环境变量：

```r
Sys.setenv(
  MIMIC_DB_NAME     = "mimic4_v22",
  MIMIC_DB_HOST     = "localhost",
  MIMIC_DB_PORT     = "5432",
  MIMIC_DB_USER     = "postgres",
  MIMIC_DB_PASSWORD = "your_password"
)
```

## 输出文件

分析产生的 xlsx/csv/png/pdf/docx 默认写到 `output/` 或脚本当前工作目录，均已被 `.gitignore` 排除。若需要保留结果，请自行复制到仓库外。
