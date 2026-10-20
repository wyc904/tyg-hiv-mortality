# 04 生存分析

生存分析主链：VIF 共线性、Cox 模型、KM、累积死亡、模型比较、交互与联合分析。

本目录共 **7** 个脚本，其中绘图脚本 **3** 个。

- 返回总索引：[docs/code-index.md](../../docs/code-index.md)
- 机器可读清单：[docs/script-manifest.csv](../../docs/script-manifest.csv)
- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`14-VIF-检查共线性.R`](14-VIF-检查共线性.R) | 18 个自变量 VIF 共线性检查 | HIV.xlsx | vif.xlsx | 否 | 独立运行 | — |
| [`5-1-COX模型.R`](5-1-COX模型.R) | 5 个暴露 × 3 套 Cox 模型，输出 HR 与 P for trend | tyg-1300-hiv.xlsx | d28-TyG_index_results.xlsx<br>d28-CD41_results.xlsx<br>d28-TyG_results.xlsx<br>d28-CD4_results.xlsx<br>d28-TYGCD4_results.xlsx | 否 | 独立运行 | P for trend 已统一为 Surv(d28; D28) |
| [`6-KM1.R`](6-KM1.R) | TYGCD4 四组 28 天 KM + risk table + 两两 log-rank | tyg-1300-hiv.xlsx | (屏幕输出) | 是 | 独立运行 | 两两比较已由 year1_* 改为 d28/D28 与 TYGCD4 |
| [`7-累计死亡率.R`](7-累计死亡率.R) | KM 生存概率转累积死亡概率并绘图 | (会话对象 data) | cumulative_mortality_risk.png<br>cumulative_mortality_risk.pdf | 是 | 依赖会话对象 | 已补 dplyr |
| [`cox模型比较.R`](cox模型比较.R) | 5 个 Cox 模型 C-index、14 天 timeROC、IDI/NRI | 3-864-hiv-tyg.xlsx | (控制台输出) | 否 | 独立运行 | 时间点固定 14 天，与主分析 28 天不同 |
| [`10-cox交互.R`](10-cox交互.R) | TyG、TyG+CD4、TyG×CD4 三模型比较并在会话中生成 hiv_pos | 1300-hiv.xlsx | (会话对象 hiv_pos) | 否 | 独立运行 | 已补 readxl；11-联合分析.R 依赖本脚本 |
| [`11-联合分析.R`](11-联合分析.R) | 联合模型 C-index、timeROC、DeLong、NRI、DCA、KM、森林图 | (会话对象 hiv_pos) | (屏幕输出) | 是 | 依赖会话对象 | 已修正 AUC 索引 [2]→[1] 与协变量 age+gender+sofa；须接在 10-cox交互.R 后 |

