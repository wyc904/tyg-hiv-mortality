library(forestplot)
library(grid)

# 更新数据准备 - 糖尿病分层
data <- data.frame(
  Level = c(1,1,1,1,0,0,0,0), # 1=Diabetes, 0=Non-Diabetes
  Group = c(1,2,3,4,1,2,3,4), # 四个联合分层组
  Number = c(20,21,15,26,292,98,601,205),
  HR = c(1,0.898,1.731,2.852,1,1.949,2.671,4.332),
  CI_lower = c(NA,0.122,0.202,0.477,NA,1.066,1.704,2.661),
  CI_upper = c(NA,6.634,14.841,17.072,NA,3.566,4.188,7.050),
  P_value = c(NA,0.916,0.617,0.251,NA,0.030,0.001,0.001),
  stringsAsFactors = FALSE
)

# 添加分组标签
data$Group_Label <- c(
  "CD4≥50,TYG<9.22", "CD4≥50,TYG≥9.22", "CD4<50,TYG<9.22", "CD4<50,TYG≥9.22",
  "CD4≥50,TYG<9.22", "CD4≥50,TYG≥9.22", "CD4<50,TYG<9.22", "CD4<50,TYG≥9.22"
)

# 创建亚组标题行
insert_rows <- data.frame(
  Level = c(NA, NA),
  Group = c(NA, NA),
  Number = c(NA, NA),
  HR = c(NA, NA),
  CI_lower = c(NA, NA),
  CI_upper = c(NA, NA),
  P_value = c(NA, NA),
  Group_Label = c("Diabetes", "Non-Diabetes"), 
  stringsAsFactors = FALSE
)

# 整合数据
data_new <- rbind(
  insert_rows[1, ],   # Diabetes标题
  data[1:4, ],        # Diabetes数据
  insert_rows[2, ],   # Non-Diabetes标题
  data[5:8, ]         # Non-Diabetes数据
)

# 创建HR (95% CI)标签
data_new$hr_ci <- ifelse(
  is.na(data_new$HR),
  NA,
  ifelse(is.na(data_new$CI_lower),
         "Reference",
         sprintf("%.3f (%.3f-%.3f)", data_new$HR, data_new$CI_lower, data_new$CI_upper))
)

# 构建标签文本
labeltext <- cbind(
  c("Subgroup", data_new$Group_Label),
  c("HR (95% CI)", data_new$hr_ci),
  c("N", as.character(data_new$Number)),
  c("P value", ifelse(is.na(data_new$P_value), "", 
                      ifelse(data_new$P_value < 0.001, "<0.001", 
                             sprintf("%.3f", data_new$P_value))))
)

# 设置森林图数据
mean_val <- c(NA, data_new$HR)
lower_val <- c(NA, data_new$CI_lower)
upper_val <- c(NA, data_new$CI_upper)

# 确定摘要行
is_summary <- c(TRUE, 
                TRUE,  # Diabetes标题
                rep(FALSE, 4), # 4个Diabetes亚组
                TRUE,  # Non-Diabetes标题
                rep(FALSE, 4)) # 4个Non-Diabetes亚组

# 创建PNG文件
png("forest_plot_diabetes_stratified.png", width = 2000, height = 1200, res = 200)

# 绘制森林图
forestplot(labeltext = labeltext,
           mean = mean_val,
           lower = lower_val,
           upper = upper_val,
           is.summary = is_summary,
           graph.pos = 2,
           xlog = TRUE,
           zero = 1,
           boxsize = 0.25,
           col = fpColors(box = "blue",
                          line = "blue",
                          summary = "blue"),
           xticks = c(0.1, 1, 10, 100),
           txt_gp = fpTxtGp(label = gpar(cex = 0.9),
                            ticks = gpar(cex = 0.9),
                            xlab = gpar(cex = 1.0)),
           lineheight = unit(0.8, "lines"),
           graphwidth = unit(0.4, "npc"),
           colgap = unit(0.02, "npc"),
           lwd.ci = 1.5,
           lty.ci = "solid",
           ci.vertices = TRUE,
           ci.vertices.height = 0.15,
           clip = c(0.05, 100))

# 更新标题
grid.text("Prognostic Value of Combined TyG-CD4 Stratification by Diabetes Status", 
          x = unit(0.5, "npc"), y = unit(0.97, "npc"),
          gp = gpar(fontsize = 14, fontface = "bold"))

grid.text("HIV/AIDS Patients with Sepsis (N=1,278)", 
          x = unit(0.5, "npc"), y = unit(0.94, "npc"),
          gp = gpar(fontsize = 11, col = "gray40"))

# 添加交互作用P值
grid.text("P for interaction = 0.049", 
          x = unit(0.9, "npc"), y = unit(0.90, "npc"),
          gp = gpar(fontsize = 10, fontface = "italic"))

# 关闭图形设备
dev.off()

# 打开图片（跨平台；原为 macOS 专用的 system("open ...")）
if (interactive()) browseURL(normalizePath("forest_plot_diabetes_stratified.png", mustWork = FALSE))