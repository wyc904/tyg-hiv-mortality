# rm(list=ls());gc()

# dev.off()
# 加载必要的库
library(survival)
library(survminer)
library(writexl)
# 加载必要的库
library(readxl)

# 读取Excel数据
data <- read_excel("tyg-1300-hiv.xlsx")




# # 创建生存对象
# surv_obj <- Surv(data$hoslos, data$death)
# 
# # 进行KM生存分析
# km_fit <- survfit(surv_obj ~ data$zongff)
# # 重建生存模型
km_fit <- survfit(Surv(data$d28, data$D28) ~ TYGCD4, data = data)

# table(data$TYGCD4)

# 绘制KM曲线
flatui_colors <- c(
  "#34495E", "#2ECC71", "#E74C3C", "#3498DB", "#9B59B6", 
  "#F1C40F", "#1ABC9C", "#E67E22", "#95A5A6", "#D35400", 
  "#16A085", "#27AE60"
)
# # # 
# TyG:"#FC4E07", "#E69F00""TYG<9.22", "TYG≥9.22"
# CD4: "#270C01FF", "#3498DB" "CD4<50", "CD4≥50"
# # # 补充的新颜色 - 确保与已有颜色有足够区分度
# TYG-cd4   "#228B22","#FF00FF", "#FF0000", "#000000"
# # # title = "Overall Survival",

# "CD4≥50,TYG<9.22", "CD4≥50,TYG≥9.22","CD4<50,TYG<9.22", "CD4<50,TYG≥9.22"


# Define color palette for the four groups
flatui_colors <- c("#228B22", "#3498DB", "#FC4E07", "#FF0000")  # Colors for the 4 groups

# Create KM plot using ggsurvplot
p <- ggsurvplot(
  km_fit, 
  data = data,
  pval = TRUE,
  pval.coord = c(20,0.98),  # Position for p-value
  conf.int = FALSE,        # No confidence intervals
  risk.table = TRUE,       # Include risk table
  palette = flatui_colors, # Use specified colors
  legend = "none",         # Suppress default legend
  legend.labs = c("CD4≥50 & TyG<9.22", "CD4≥50 & TyG≥9.22", "CD4<50 & TyG<9.22", "CD4<50 & TyG≥9.22"), # Group labels (not used since legend is removed)
  xlab = "Time (days)",
  ylab = "Survival Probability",
  xlim = c(0, 28),         # X-axis limit
  ylim = c(0.5, 1),        # Y-axis limit
  size = 0.5,              # Line size
  break.time.by = 7,       # X-axis breaks
  tables.theme = theme(
    axis.title.y = element_blank(),
    axis.text.y = element_text(face = "bold", size = 10),
    panel.border = element_rect(colour = "black", fill = NA, size = 1)  # Risk table border
  ),
  risk.table.title = "Number at risk",
  risk.table.y.text = TRUE,
  risk.table.fontsize = 4,  # Risk table font size
  ggtheme = theme_bw(),     # Use black-and-white theme
  risk.table.coord = c(0.1, 0.1)  # Adjust risk table position to (0.1, 0.1)
)

# Modify plot theme (remove legend-related settings)
p$plot <- p$plot +
  theme(
    panel.border = element_rect(color = "black", fill = NA, size = 0.5),  # Plot border
    panel.grid.major = element_blank(),       # Remove major grid lines
    panel.grid.minor = element_blank(),       # Remove minor grid lines
    text = element_text(family = "Times New Roman", size = 11)  # Set font
  )

# Adjust risk table font
p$table <- p$table + 
  theme(text = element_text(family = "Times New Roman", size = 9))

# Print the final plot
print(p)


















ggsurvplot(
  km_fit, 
  data = data,
  pval = TRUE, # 显示p值
  conf.int = FALSE, # 显示置信区间
  risk.table = F, # 显示风险表
  palette = c( "#FC4E07", "#E69F00","#009E73"), # 自定义颜色
  legend.title = "Quartile", # 图例标题
  legend.labs = unique(data$TyGbmi3), # 使用分层名作为图例标签
  xlab = "Survival Time",
  ylab = "Survival Probability (%)",
  title = "Overall Survival",
  xlim = c(0, 90),
  ylim = c(0, 1), # 设置 y 轴坐标
  break.time.by = 7, # x轴的坐标轴设为7为一个间距
  
)


# 计算四个TyG组之间的两两比较的p值
pairwise_pvals <- pairwise_survdiff(Surv(d28, D28) ~ TYGCD4, data = data)

# 提取和输出p值
pairwise_pvals


# 提取p值并格式化输出
pvals_matrix <- pairwise_pvals$p.value
pvals_matrix <- as.data.frame(as.table(pvals_matrix))

# 打印p值矩阵
print(pvals_matrix)




































