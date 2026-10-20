# 06 亚组与森林图

亚组 Cox、交互 P 计算与森林图。注意两个 19- 脚本的数值为手工录入。

本目录共 **4** 个脚本，其中绘图脚本 **2** 个。

- 返回总索引：[docs/code-index.md](../../docs/code-index.md)
- 机器可读清单：[docs/script-manifest.csv](../../docs/script-manifest.csv)
- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。

| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |
|---|---|---|---|:---:|---|---|
| [`13-多个亚组变量比较分析.R`](13-多个亚组变量比较分析.R) | TYGCD4 四分类分层 Cox（2/3/4 vs 1），输出 HR 与 LRT 交互 P | 亚组分析表.xlsx | 加day28_all_comparisonss.xlsx | 否 | 独立运行 | 推荐版本；stratify_vars 实际只保留 gender |
| [`13-亚组分析单独计算p交互.R`](13-亚组分析单独计算p交互.R) | 由 6 组 HR/CI 手算交互 P | (脚本内硬编码) | (控制台输出) | 否 | 模板/硬编码 | 自由度取组数 3 而非 G−1=2，p 值偏大 |
| [`19-森林图.R`](19-森林图.R) | 肝硬化/非肝硬化分层 JAMA 风格森林图 | (脚本内硬编码) | jama_style_forestplot.png | 是 | 模板/硬编码 | N/HR/CI/P 全部写死；需用最新亚组结果替换 |
| [`19-森林图绘制-子项.R`](19-森林图绘制-子项.R) | 糖尿病/非糖尿病分层森林图 | (脚本内硬编码) | forest_plot_diabetes_stratified.png | 是 | 模板/硬编码 | 数值写死；打开图片已改为跨平台 browseURL |

