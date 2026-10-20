library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyr)
library(readxl)


# 读取数据
df_total <- read_excel("标准化样本1.xlsx")





# 定义因子映射：原始列名 -> 显示名称
因子映射 <- c("std_IFN-a2" = "IFN-α2",
          "std_IFN-y" = "IFN-γ",
          "std_TNF-a" = "TNF-α",
          "std_MCP-1" = "MCP-1",
          "std_IL-6" = "IL-6",
          "std_IL-8" = "IL-8"  # 这里可能应该是 "IL-8"
          
          
          
)
# ,
# `IL-10` = `std_IL-10`,
# `IL-12p70` = `std_IL-12p70`,
# `IL-17A` = `std_IL-17A`,
# `IL-18` = `std_IL-18`,
# `IL-23` = `std_IL-23`,
# `IL-33` = `std_IL-33`
# 




标准化样本 <- df_total

# 转换为长表格
df_long <- 标准化样本 %>%
  select(TYG, all_of(names(因子映射))) %>%
  pivot_longer(
    cols = -TYG,
    names_to = "因子代码",
    values_to = "浓度"
  ) %>%
  mutate(
    因子 = 因子映射[因子代码],
    TYG = factor(TYG, levels = c(0, 1), labels = c("Low", "High"))
  )

# 设置因子顺序
df_long$因子 <- factor(df_long$因子, levels = unique(因子映射))

# ===================
# 绘图：保留所有因子（JAMA要求全面）
# ===================
p <- ggplot(df_long, aes(x = TYG, y = 浓度, fill = TYG)) +
  geom_violin(trim = FALSE, alpha = 0.3, color = NA) +
  geom_jitter(
    position = position_jitter(width = 0.15, height = 0),
    shape = 21, size = 1, alpha = 0.6, stroke = 0.2
  ) +
  stat_compare_means(
    method = "wilcox.test",
    label = "p.signif",
    comparisons = list(c("Low", "High")),
    label.y.npc = "top",
    size = 4,
    hide.ns = TRUE  # 不显示 ns
  ) +
  facet_wrap(~因子, scales = "free_y", ncol = 3) +
  scale_fill_manual(values = c("#4575b4", "#d73027")) +
  labs(x = "TYG Group", y = "Standardized Cytokine Level", fill = "TYG") +
  theme_classic(base_size = 12) +
  theme(
    strip.text = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 10)
  )

# 输出图形
print(p)
