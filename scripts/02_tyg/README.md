# 02 TyG 指数与分组

TyG 指数定义、ROC 截断值、二分/三分/四分位分组，以及 MI / TyG 复合因子。

本目录共 **4** 个脚本，其中绘图脚本 **1** 个。

- 返回总索引：[docs/code-index.md](../../docs/code-index.md)
- 机器可读清单：[docs/script-manifest.csv](../../docs/script-manifest.csv)
- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`1-计算tyg.R`](1-计算tyg.R) | 计算 TyG_index，生成二分/三分/四分位分组，ROC 约登法确定截断值 | 1500-插补.xlsx<br>tyg-1300-hiv.xlsx | 8-40.xlsx<br>14.xlsx<br>TyG_Index_Cutoff_Analysis.xlsx<br>TyG_index_ROC_curve.png<br>TyG_index_ROC_curve.pdf | 是 | 独立运行 | 二分位已改名为 TyG2 避免覆盖 TyG3；14.xlsx 与其它脚本撞名 |
| [`2-四分位间距.R`](2-四分位间距.R) | 由会话对象生成 TyGbmi3/TyG3/TyGbmi4 分组 | (会话对象 X595_重新计算) | 14.xlsx | 否 | 依赖会话对象 | 已修正 TyGbmi4 切点误用 TyG_index 的问题；14.xlsx 撞名 |
| [`3-MI因子开发.R`](3-MI因子开发.R) | 由 TyG 与 CD4 构造 MI_2.0 复合指标并分组 | 8-4s0.xlsx | MI_score.xlsx<br>14.xlsx | 否 | 独立运行 | 已补 readxl/writexl；14.xlsx 撞名 |
| [`4-tyg因子开发.R`](4-tyg因子开发.R) | RCS 节点选择与 maxstat 拐点；构建 CD4_s、TYG2、SOFA 评分与总分 | MI_2.0.xlsx | 8-4s0.xlsx | 否 | 独立运行 | 上游 MI_2.0.xlsx 在仓库内无生成脚本；已补 writexl |

