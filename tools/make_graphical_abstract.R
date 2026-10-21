# ============================================================
# 生成图形摘要（Graphical Abstract）
# 用法（在仓库根目录）：Rscript tools/make_graphical_abstract.R
# 输出：figures/graphical-abstract.png
#
# 说明：本文发表于 Frontiers in Medicine，原文没有独立图形摘要。
# 本图根据论文 Table 1 / Table 3 / Table 4 的结果重新绘制，
# 仅用于代码仓库展示，不是出版社正式图形摘要。
# ============================================================

suppressPackageStartupMessages(library(ggplot2))

root <- normalizePath(".")
out_dir <- file.path(root, "figures")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- 数据（来自论文 Table 1 / Table 3 / Table 4）---------------------------
strata <- data.frame(
  cd4 = rep(c("CD4 ≥ 50", "CD4 < 50"), each = 2),
  tyg = rep(c("TyG < 9.22", "TyG ≥ 9.22"), times = 2),
  n = c(312, 119, 616, 231),
  mortality = c(10.3, 16.0, 18.5, 28.6),
  x = c(6.7, 9.9, 6.7, 9.9),
  y = c(5.0, 5.0, 2.7, 2.7),
  stringsAsFactors = FALSE
)

strata$fill <- c(
  "10.3" = "#E8F4F8",
  "16"   = "#FDE0C5",
  "18.5" = "#F4A582",
  "28.6" = "#B2182B"
)[as.character(strata$mortality)]

strata$text_col <- ifelse(strata$mortality >= 25, "white", "#1A1A1A")
strata$badge <- ifelse(
  strata$mortality == max(strata$mortality), "HIGHEST RISK",
  ifelse(strata$mortality == min(strata$mortality), "REFERENCE", "")
)
strata$badge_col <- ifelse(strata$mortality == max(strata$mortality), "white", "#555555")

box_w <- 2.75
box_h <- 2.00

# ---- 绘图 -----------------------------------------------------------------
p <- ggplot() +
  # 画布背景
  annotate("rect", xmin = 0, xmax = 12, ymin = 0, ymax = 8,
           fill = "white", colour = NA) +

  # 标题
  annotate("text", x = 0.35, y = 7.72,
           label = "TyG × CD4 immunometabolic stratification in HIV-associated sepsis",
           hjust = 0, size = 8.2, fontface = "bold", colour = "#111111") +
  annotate("text", x = 0.35, y = 7.30,
           label = "Retrospective cohort  ·  1,278 adults  ·  Guangzhou Eighth People's Hospital, 2014–2024",
           hjust = 0, size = 4.0, colour = "#555555") +

  # 左侧设计面板
  annotate("rect", xmin = 0.35, xmax = 4.35, ymin = 1.15, ymax = 6.75,
           fill = "#F5F7FA", colour = "#D9DEE5", linewidth = 0.6) +
  annotate("text", x = 0.60, y = 6.45, label = "Study design",
           hjust = 0, size = 4.6, fontface = "bold", colour = "#2C3E50") +

  # 流程框 1
  annotate("rect", xmin = 0.70, xmax = 4.00, ymin = 5.35, ymax = 6.10,
           fill = "white", colour = "#4A6FA5", linewidth = 0.8) +
  annotate("text", x = 2.35, y = 5.73,
           label = "HIV infection + Sepsis-3\nn = 1,278",
           size = 3.9, fontface = "bold", colour = "#1A1A1A", lineheight = 1.05) +

  # 箭头 1
  annotate("segment", x = 2.35, xend = 2.35, y = 5.30, yend = 4.98,
           arrow = arrow(length = unit(0.13, "inches")),
           linewidth = 0.9, colour = "#4A6FA5") +

  # 流程框 2
  annotate("rect", xmin = 0.70, xmax = 4.00, ymin = 3.90, ymax = 4.93,
           fill = "white", colour = "#4A6FA5", linewidth = 0.8) +
  annotate("text", x = 2.35, y = 4.45,
           label = "TyG cut-off 9.22 (Youden)\nCD4 cut-off 50 cells/µL",
           size = 3.8, fontface = "bold", colour = "#1A1A1A", lineheight = 1.05) +

  # 箭头 2
  annotate("segment", x = 2.35, xend = 2.35, y = 3.85, yend = 3.53,
           arrow = arrow(length = unit(0.13, "inches")),
           linewidth = 0.9, colour = "#4A6FA5") +

  # 流程框 3
  annotate("rect", xmin = 0.70, xmax = 4.00, ymin = 2.62, ymax = 3.48,
           fill = "#EAF1F8", colour = "#4A6FA5", linewidth = 0.8) +
  annotate("text", x = 2.35, y = 3.05,
           label = "Four immunometabolic strata",
           size = 3.9, fontface = "bold", colour = "#1A1A1A") +

  # 细胞因子亚组
  annotate("text", x = 2.35, y = 1.95,
           label = "Cytokine sub-study\nn = 155  ·  13 inflammatory cytokines",
           size = 3.2, colour = "#555555", lineheight = 1.05) +

  # 左右连接箭头
  annotate("segment", x = 4.45, xend = 5.15, y = 3.55, yend = 3.55,
           arrow = arrow(length = unit(0.16, "inches")),
           linewidth = 1.3, colour = "#7A8A9A") +

  # 右侧标题
  annotate("text", x = 5.20, y = 6.42,
           label = "28-day all-cause mortality by TyG × CD4 stratum",
           hjust = 0, size = 4.8, fontface = "bold", colour = "#2C3E50") +
  annotate("text", x = 5.20, y = 6.12,
           label = "Mortality (%)",
           hjust = 0, size = 3.2, colour = "#777777") +

  # 四个分层框
  geom_rect(data = strata,
            aes(xmin = x - box_w / 2, xmax = x + box_w / 2,
                ymin = y - box_h / 2, ymax = y + box_h / 2,
                fill = fill),
            colour = "#333333", linewidth = 0.7) +
  scale_fill_identity() +

  # 高风险框加粗边框
  annotate("rect", xmin = 9.9 - box_w / 2, xmax = 9.9 + box_w / 2,
           ymin = 2.7 - box_h / 2, ymax = 2.7 + box_h / 2,
           fill = NA, colour = "#7F0000", linewidth = 2.0) +

  # 分层文字
  geom_text(data = strata,
            aes(x = x, y = y + 0.62, label = paste0(cd4, "  /  ", tyg)),
            size = 3.5, fontface = "bold", colour = strata$text_col) +
  geom_text(data = strata,
            aes(x = x, y = y + 0.12, label = paste0("n = ", n)),
            size = 3.0, colour = strata$text_col) +
  geom_text(data = strata,
            aes(x = x, y = y - 0.42, label = sprintf("%.1f%%", mortality)),
            size = 6.6, fontface = "bold", colour = strata$text_col) +
  geom_text(data = strata,
            aes(x = x, y = y - 0.80, label = "28-day mortality"),
            size = 2.7, colour = strata$text_col) +
  geom_text(data = subset(strata, badge == "HIGHEST RISK"),
            aes(x = x, y = y + 0.86, label = badge),
            size = 2.8, fontface = "bold", colour = "white") +
  geom_text(data = subset(strata, badge == "REFERENCE"),
            aes(x = x, y = y + 0.86, label = badge),
            size = 2.8, fontface = "bold", colour = "#555555") +

  # 底部结果条
  annotate("rect", xmin = 0.35, xmax = 11.70, ymin = 0.32, ymax = 1.02,
           fill = "#F0F3F7", colour = "#D9DEE5", linewidth = 0.6) +
  annotate("text", x = 0.60, y = 0.78,
           label = "Combined model AUC 0.605 (95% CI 0.568–0.642)  vs  TyG 0.541  vs  CD4 0.556",
           hjust = 0, size = 3.7, fontface = "bold", colour = "#1A1A1A") +
  annotate("text", x = 0.60, y = 0.50,
           label = "Adjusted HR 2.82 (95% CI 1.77–4.50) for CD4 < 50 / TyG ≥ 9.22 vs reference  ·  P for trend < 0.001",
           hjust = 0, size = 3.4, colour = "#444444") +

  # 脚注
  annotate("text", x = 0.35, y = 0.12,
           label = "Wu et al., Front Med 2026;12:1688334  ·  doi:10.3389/fmed.2025.1688334  ·  Graphical abstract prepared for this code repository; not part of the published article.",
           hjust = 0, size = 2.6, colour = "#777777") +

  coord_cartesian(xlim = c(0, 12), ylim = c(0, 8), expand = FALSE) +
  theme_void() +
  theme(plot.background = element_rect(fill = "white", colour = NA),
        plot.margin = margin(8, 8, 8, 8))

ggsave(
  filename = file.path(out_dir, "graphical-abstract.png"),
  plot = p, width = 12, height = 8, dpi = 300, bg = "white"
)

cat("Saved:", file.path(out_dir, "graphical-abstract.png"), "\n")
