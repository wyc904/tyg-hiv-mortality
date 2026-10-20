# 07 细胞因子

细胞因子标准曲线标准化、小提琴/散点图、热图与 GraphPad 宽表导出。

本目录共 **4** 个脚本，其中绘图脚本 **2** 个。

- 返回总索引：[docs/code-index.md](../../docs/code-index.md)
- 机器可读清单：[docs/script-manifest.csv](../../docs/script-manifest.csv)
- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`1-细胞因子标准化.R`](1-细胞因子标准化.R) | C0–C7 标准曲线对 13 种细胞因子插值标准化 | 细胞因子1300初步数据1.xlsx | 标准化样本1.xlsx | 否 | 独立运行 | approx() 线性插值而非四参数 logistic |
| [`2-细胞因子散点图绘制.R`](2-细胞因子散点图绘制.R) | 细胞因子长表按 TyG 高低画小提琴+散点并标 Wilcoxon | 标准化样本1.xlsx | (屏幕输出) | 是 | 独立运行 | 已补 readxl；只展示 6 个细胞因子 |
| [`16-细胞因子热图绘制.R`](16-细胞因子热图绘制.R) | TYGCD4 分组 12 种细胞因子均值 pheatmap 热图 | 标准化样本-0729.xlsx | (屏幕输出) | 是 | 独立运行 | 与散点图使用的标准化版本不同 |
| [`4-graphpad处理数据.R`](4-graphpad处理数据.R) | 整理 GraphPad 可直接粘贴的分组宽表 | 标准化样本-0729.xlsx | cytokine_grouped_data.xlsx | 否 | 独立运行 | 已补 dplyr/tidyr/writexl |

