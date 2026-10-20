# ============================================================
# 依赖包安装脚本
# 用法：Rscript packages.R   或在 RStudio 中 source("packages.R")
# 环境：R 4.4.0
# ============================================================

pkgs <- c(
  # ---- 数据处理 ----
  "dplyr", "tidyr", "tidyverse", "purrr", "readr", "lubridate",
  # ---- Excel ----
  "readxl", "writexl", "openxlsx",
  # ---- 数据库（仅 2024 MIMIC 归档脚本使用）----
  "DBI", "RPostgres",
  # ---- 生存分析 ----
  "survival", "survminer", "rms", "maxstat",
  "timeROC", "survcomp", "survIDINRI", "nricens",
  # ---- 统计与模型 ----
  "pROC", "car", "lmtest", "ResourceSelection", "DescTools",
  "broom", "caret", "mediation", "gtsummary",
  # ---- 绘图 ----
  "ggplot2", "ggpubr", "ggpmisc", "ggtext", "pheatmap",
  "forestplot", "forestmodel", "patchwork", "scales", "grid",
  "showtext", "extrafont",
  # ---- 表格与报告 ----
  "flextable", "officer", "knitr", "kableExtra",
  # ---- 决策曲线 ----
  "rmda"
)

to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) {
  install.packages(to_install, repos = "https://cloud.r-project.org")
} else {
  message("所有依赖包均已安装。")
}

# ------------------------------------------------------------
# 已从 CRAN 归档的包（普通 install.packages 会失败）
# ------------------------------------------------------------
# plotRCS：RCS 曲线绘图（scripts/90_archive_mimic_2024 使用）
# install.packages(
#   "https://cran.r-project.org/src/contrib/Archive/plotRCS/plotRCS_0.1.4.tar.gz",
#   repos = NULL, type = "source"
# )

# rmda：决策曲线分析（scripts/05_prediction/15-DCA-决策曲线.R 使用）
# install.packages(
#   "https://cran.r-project.org/src/contrib/Archive/rmda/rmda_1.6.tar.gz",
#   repos = NULL, type = "source"
# )

# ------------------------------------------------------------
# 说明
# ------------------------------------------------------------
# 1. 个别脚本在调用包函数前漏写 library()（如 readxl、writexl、tidyr），
#    属于原始代码保留，运行前请按报错手动加载，或先 source 本文件。
# 2. extrafont / showtext 首次使用需要注册字体，见脚本内注释。
