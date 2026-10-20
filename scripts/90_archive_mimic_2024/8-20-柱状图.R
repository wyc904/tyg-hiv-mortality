# 安装并加载必要的包

library(ggplot2)

# 假设的示例数据
labels <- c("T1", "T2", "T3")
HR <- c(1, 0.8, 1.5)
CI_lower <- c(1.0, 0.6, 1.2)
CI_upper <- c(1.4, 1.0, 1.5)

# 创建数据框
data <- data.frame(labels, HR, CI_lower, CI_upper)



# 绘制柱状图
ggplot(data, aes(x = labels, y = HR, fill = labels)) +
  geom_bar(stat = "identity", width = 0.4) +
  geom_errorbar(aes(ymin = ifelse(labels != "T1", CI_lower, NA), 
                    ymax = ifelse(labels != "T1", CI_upper, NA)), 
                width = 0.2) +
  theme_minimal() +
  theme(panel.grid = element_blank()) +  # 去除网格线
  scale_fill_manual(values = c("T1" = "skyblue", "T2" = "orange", "T3" = "green")) +  # 自定义柱子颜色
  labs(x = "Groups", y = "Hazard Ratio (HR)", title = "") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +  # 添加虚线
  theme(
    axis.title.x = element_text(face = "bold", size = 14),  # 加粗加大 X 轴标签
    axis.title.y = element_text(face = "bold", size = 14),  # 加粗加大 Y 轴标签
    axis.text.x = element_text(size = 14),  # 加大 X 轴刻度标签
    axis.text.y = element_text(size = 14),  # 加大 Y 轴刻度标签
    axis.line = element_line(color = "black", size = 1.5),  # 设置轴线的颜色和粗细
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14)  # 标题居中，加粗并加大字体
  ) +
  ylim(0, 2) +  # 设置 Y 轴的范围
  annotate("text", x = 2, y = 1.8, label = "HR with 95% CI\np = 0.009", size = 5, hjust = 0.5, fontface = "bold") +  # 在图形中部添加文本，模拟标题
  coord_cartesian(clip = "off") +  # 确保柱子紧挨 X 轴
  theme(
    legend.position = "none"  # 去除图例
  ) +
  # 添加 X 轴和 Y 轴箭头
  theme(axis.line = element_line(color = "black", size = 1),
        axis.line.x.bottom = element_line(arrow = grid::arrow(type = "closed", length = unit(0.1, "inches"))),
        axis.line.y.left = element_line(arrow = grid::arrow(type = "closed", length = unit(0.1, "inches"))))



# 绘制柱状图
ggplot(data, aes(x = labels, y = HR, fill = labels)) +
  geom_bar(stat = "identity", width = 0.4, position = position_dodge(width = 0)) +  # 确保柱子紧贴 X 轴
  geom_errorbar(aes(ymin = ifelse(labels != "T1", CI_lower, NA), 
                    ymax = ifelse(labels != "T1", CI_upper, NA)), 
                width = 0.2) +
  theme_minimal() +
  theme(panel.grid = element_blank()) +  # 去除网格线
  scale_fill_manual(values = c("T1" = "skyblue", "T2" = "orange", "T3" = "green")) +  # 自定义柱子颜色
  labs(x = "Groups", y = "Hazard Ratio (HR)", title = "") +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +  # 添加虚线
  theme(
    axis.title.x = element_text(face = "bold", size = 14),  # 加粗加大 X 轴标签
    axis.title.y = element_text(face = "bold", size = 14),  # 加粗加大 Y 轴标签
    axis.text.x = element_text(size = 14),  # 加大 X 轴刻度标签
    axis.text.y = element_text(size = 14),  # 加大 Y 轴刻度标签
    axis.line = element_line(color = "black", size = 1.5),  # 设置轴线的颜色和粗细
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),  # 标题居中，加粗并加大字体
    panel.spacing = unit(0, "lines")  # 控制 X 轴和 Y 轴的间距
  ) +
  ylim(0, 2) +  # 设置 Y 轴的范围
  annotate("text", x = 2, y = 1.8, label = "HR with 95% CI\np = 0.009", size = 5, hjust = 0.5, fontface = "bold") +  # 在图形中部添加文本，模拟标题
  theme(
    legend.position = "none"  # 去除图例
  ) +
  # 添加 X 轴和 Y 轴箭头
  theme(axis.line = element_line(color = "black", size = 1.5),
        axis.line.x.bottom = element_line(arrow = grid::arrow(type = "closed", length = unit(0.15, "inches"))),
        axis.line.y.left = element_line(arrow = grid::arrow(type = "closed", length = unit(0.15, "inches"))))



