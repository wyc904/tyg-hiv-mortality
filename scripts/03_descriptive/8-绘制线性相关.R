# 加载必要的包
library(ggplot2)
library(dplyr)
library(readxl)
library(ggpubr)
library(extrafont) # 用于新罗马字体

# 确保新罗马字体已加载
if (!"Times New Roman" %in% fonts()) {
  font_import(prompt = FALSE, pattern = "times")
  loadfonts(device = "win") # Windows系统
  # loadfonts(device = "pdf") # Mac/Linux系统
}

# 读取Excel数据
data <- read_excel("tyg-1300-hiv.xlsx")
# 提取需要的列（TyG和住院死亡）
tyg_data <- data %>%
  select(TyG = CD4, 
         Mortality = D28)

# 确保数据类型正确
tyg_data <- tyg_data %>%
  mutate(
    TyG = as.numeric(TyG),
    Mortality = as.numeric(Mortality),
    Mortality = factor(Mortality, levels = c(0, 1), labels = c("存活", "死亡"))
  ) %>%
  filter(!is.na(TyG) & !is.na(Mortality))  # 移除缺失值

# 准备统计信息
model <- glm(Mortality ~ TyG, data = tyg_data, family = binomial(link = "logit"))
sum_model <- summary(model)

# 计算拟合概率
tyg_data$Fitted_Prob <- predict(model, type = "response")

# 自定义统计标签
coefficients <- coef(sum_model)
p_value <- coefficients[2, 4]
stat_label <- sprintf("OR = %.2f (95%% CI: %.2f-%.2f)\np = %.3f", 
                      exp(coefficients[2, 1]), 
                      exp(coefficients[2, 1] - 1.96*coefficients[2, 2]),
                      exp(coefficients[2, 1] + 1.96*coefficients[2, 2]),
                      p_value)

# 计算x轴刻度（间隔为2）
x_min <- floor(min(tyg_data$TyG))
x_max <- ceiling(max(tyg_data$TyG))
x_breaks <- seq(x_min, x_max, by = 200)

# 创建逻辑回归曲线图
p <- ggplot(tyg_data, aes(x = TyG)) +
  # 添加逻辑回归曲线（黑色实线）
  geom_line(aes(y = Fitted_Prob), color = "black", size = 1.2) +
  
  # 添加置信区间
  geom_ribbon(aes(ymin = Fitted_Prob - 1.96 * predict(model, type = "response", se.fit = TRUE)$se.fit,
                  ymax = Fitted_Prob + 1.96 * predict(model, type = "response", se.fit = TRUE)$se.fit),
              alpha = 0.2, fill = "#ffa0a0") +
  
  # 添加统计标签（左上角）
  annotate("text", 
           x = min(tyg_data$TyG) + 0.05 * diff(range(tyg_data$TyG)),
           y = 0.45,
           label = stat_label, 
           hjust = 0, vjust = 1, size = 5, color = "black", family = "Times New Roman") +
  
  # 设置坐标轴和标题
  labs(
    x = "CD4 T cell",
    y = "Mortality (%)") +
  
  # 调整图表主题（使用新罗马字体）
  theme_classic(base_size = 14) +
  theme(
    text = element_text(family = "Times New Roman"),
    axis.title.x = element_text(face = "bold", size = 16, margin = margin(t = 10)),
    axis.title.y = element_text(face = "bold", size = 16, margin = margin(r = 10)),
    axis.text.x = element_text(color = "black", size = 14),
    axis.text.y = element_text(color = "black", size = 14),
    panel.border = element_rect(color = "black", fill = NA, size = 0.8),
    legend.position = c(0.95, 0.05),
    legend.justification = c(1, 0),
    legend.title = element_blank(),
    legend.background = element_blank(),
    legend.key = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black", size = 0.5),
    plot.margin = margin(15, 15, 15, 15)
  ) +
  
  # 设置y轴为百分比格式，范围0-50%
  scale_y_continuous(breaks = seq(0, 0.5, 0.1), 
                     labels = scales::percent,
                     limits = c(0, 0.4),
                     expand = c(0, 0)) + # 移除多余空白
  
  # 设置x轴范围和刻度间隔为2
  scale_x_continuous(limits = c(min(tyg_data$TyG)*0.98, max(tyg_data$TyG)*1.02),
                     breaks = x_breaks,
                     expand = c(0, 0.5)) # 轻微扩展x轴范围


print(p)

# # 保存高分辨率图片（600dpi）使用新罗马字体
# ggsave("TyG_Mortality_Correlation.tiff", plot = p, 
#        width = 8, height = 6, dpi = 600, compression = "lzw")