library(survival)
library(survminer)
library(ggplot2)
library(dplyr)

surv_obj <- Surv(data$hoslos, data$死亡)

# 进行KM生存分析
km_fit <- survfit(surv_obj ~ data$TYGCD)

# 提取累积事件概率数据
cumulative_data <- fortify(km_fit) %>%
  mutate(cumulative_event = 1 - surv,
         upper_event = 1 - upper,
         lower_event = 1 - lower)

# 自定义颜色
group_colors <- c("#FC4E07", "#E69F00", "#009E73", "#3498DB", "#270C01FF", "#9B59B6")

# 创建累积事件曲线图
cumulative_plot <- ggplot(cumulative_data, 
                          aes(x = time, y = cumulative_event, 
                              color = strata, fill = strata)) +
  geom_step(size = 1) +
  geom_ribbon(aes(ymin = lower_event, ymax = upper_event), alpha = 0.1, color = NA) +
  scale_color_manual(values = group_colors) +
  scale_fill_manual(values = group_colors) +
  labs(
    title = "Cumulative Mortality Risk by TyG-CD4 Group",
    x = "Time (days)",
    y = "Cumulative Mortality Probability"
  ) +
  theme_minimal() +
  theme(
    text = element_text(family = "Times New Roman", size = 14),
    panel.grid.major = element_line(color = "grey90"),
    panel.grid.minor = element_blank(),
    legend.position = "none",
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16)
  ) +
  scale_x_continuous(breaks = seq(0, 28, 7), limits = c(0, 28)) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 0.6)) +
  guides(color = FALSE, fill = FALSE)  # 移除图例

# 创建风险表
risk_table <- ggsurvplot(
  km_fit,
  data = data,
  fun = "event",  # 计算累积事件概率
  palette = group_colors,
  risk.table = TRUE,
  risk.table.title = "Number at risk",
  risk.table.y.text = TRUE,
  tables.theme = theme(
    axis.title.y = element_blank(),
    axis.text.y = element_text(face = "bold", size = 10),
    panel.grid = element_blank()
  ),
  ggtheme = theme_minimal()
)$table +
  theme(
    text = element_text(family = "Times New Roman"),
    plot.title = element_text(size = 12, hjust = 0, face = "bold")
  )

# 将累积事件曲线和风险表合并
final_plot <- arrange_ggsurvplots(
  list(
    cumulative = list(plot = cumulative_plot, height = 0.7),
    risk_table = list(plot = risk_table, height = 0.3)
  ),
  print = FALSE,
  ncol = 1,
  heights = c(1, 0.4),  # 调整两部分的比例
  titles = "Cumulative Mortality Risk"
)

# 保存图形
ggsave("cumulative_mortality_risk.png", final_plot, width = 8, height = 8, dpi = 300)
ggsave("cumulative_mortality_risk.pdf", final_plot, width = 8, height = 8, dpi = 300)