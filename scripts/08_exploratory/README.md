# 08 探索性分析

探索性中介分析（TyG → CD4 → 28 天死亡）。

本目录共 **1** 个脚本，其中绘图脚本 **0** 个。

- 返回总索引：[docs/code-index.md](../../docs/code-index.md)
- 机器可读清单：[docs/script-manifest.csv](../../docs/script-manifest.csv)
- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`9-跑通中介效应.R`](9-跑通中介效应.R) | CD41 中介 TyG_index→28 天死亡的中介效应 | (会话对象 data) | (控制台输出) | 否 | 依赖会话对象 | boot=1000 未设 seed；结局二分类而中介模型用 lm |

