# 03 描述性分析与绘图

描述性统计与图表：TyG × CD4 死亡率热图、CD4 与死亡的关系曲线。

本目录共 **2** 个脚本，其中绘图脚本 **2** 个。

- 返回总索引：[docs/code-index.md](../../docs/code-index.md)
- 机器可读清单：[docs/script-manifest.csv](../../docs/script-manifest.csv)
- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`tyg热图绘制.R`](tyg热图绘制.R) | TyG×CD4 四格 28 天死亡率热图 | 1300-hiv.xlsx | tyg_cd4_heatmap.png<br>tyg_cd4_heatmap.pdf<br>tyg_cd4_heatmap_data.csv | 是 | 独立运行 | 已修复 summarise 整列求和导致的重复计数 |
| [`8-绘制线性相关.R`](8-绘制线性相关.R) | logistic 拟合 CD4 与 28 天死亡并画预测概率曲线 | tyg-1300-hiv.xlsx | (屏幕输出) | 是 | 独立运行 | 代码把 CD4 重命名为 TyG；图实际展示 CD4 |

