library(forestplot)
library(grid)

# 更新数据
data <- data.frame(
  Level = c("LiverCirrhosis", rep(1, 4), "Non-LiverCirrhosis", rep(0, 4)),
  Group = c(NA, 1, 2, 3, 4, NA, 1, 2, 3, 4),
  Number = c(68, 30, 9, 23, 6, 1210, 282, 110, 593, 225),
  HR = c(NA, 1, 0.565476043, 0.731156543, 1.43432419, NA, 1, 1.526444777, 2.064638151, 2.502456826),
  CI_lower = c(NA, NA, 0.087129538, 0.222821857, 0.264343145, NA, NA, 0.817781241, 1.273229818, 1.503563336),
  CI_upper = c(NA, NA, 3.66997417, 2.399180659, 7.782633739, NA, NA, 2.849213875, 3.347966437, 4.164965994),
  P_value = c(NA, NA, 0.55022244, 0.605513874, 0.67593639, NA, NA, 0.184102593, 0.00328881, 0.001),
  P_interaction = c(NA, rep(NA, 8), NA),
  Group_Label = c(
    "Liver Cirrhosis",
    "CD4≥50,TYG<9.22", "CD4≥50,TYG≥9.22", "CD4<50,TYG<9.22", "CD4<50,TYG≥9.22",
    "Non-Liver Cirrhosis",
    "CD4≥50,TYG<9.22", "CD4≥50,TYG≥9.22", "CD4<50,TYG<9.22", "CD4<50,TYG≥9.22"
  ),
  stringsAsFactors = FALSE
)




# 插入分组标题行
insert_rows <- data.frame(
  Level = c(NA, NA),
  Group = c(NA, NA),
  Number = c(NA, NA),
  HR = c(NA, NA),
  CI_lower = c(NA, NA),
  CI_upper = c(NA, NA),
  P_value = c(NA, NA),
  P_interaction = c(NA, NA),
  Group_Label = c("Liver Cirrhosis", "Non-Liver Cirrhosis"),
  stringsAsFactors = FALSE
)

# 插入到原数据中：在第2行和第7行前插入
data_new <- rbind(
  data[1, ],
  insert_rows[1, ],   # Liver Cirrhosis
  data[2:5, ],
  insert_rows[2, ],   # Non-Liver Cirrhosis
  data[7:10, ]
)

# 添加 HR (95%CI) 标签
data_new$hr_ci <- ifelse(
  is.na(data_new$HR),
  NA,
  ifelse(is.na(data_new$CI_lower),
         "Reference",
         sprintf("%.2f (%.2f–%.2f)", data_new$HR, data_new$CI_lower, data_new$CI_upper))
)

# 构造 labeltext（共 11 行）
labeltext <- cbind(
  c("Subgroup", data_new$Group_Label[-1]),
  c("HR (95% CI)", data_new$hr_ci[-1]),
  c("N", as.character(data_new$Number[-1])),
  c("P value", ifelse(is.na(data_new$P_value[-1]), "", sprintf("%.3f", data_new$P_value[-1])))
)

# 构造 mean, lower, upper 向量（11行：1 header + 10 data）
mean_val <- c(NA, data_new$HR[-1])
lower_val <- c(NA, data_new$CI_lower[-1])
upper_val <- c(NA, data_new$CI_upper[-1])

# 设置 is.summary（用于加粗标题行）
is_summary <- c(TRUE,  # 表头
                TRUE,  # Liver Cirrhosis
                rep(FALSE, 4),  # 4组
                TRUE,  # Non-Liver Cirrhosis
                rep(FALSE, 4))  # 4组

# 开始绘图
png("jama_style_forestplot.png", width = 1800, height = 1200, res = 200)

forestplot(
  labeltext = labeltext,
  mean = mean_val,
  lower = lower_val,
  upper = upper_val,
  is.summary = is_summary,
  graph.pos = 2,
  xlog = TRUE,
  zero = 1,
  boxsize = 0.3,
  col = fpColors(
    box = "black",
    line = "black",
    summary = "black"
  ),
  xticks = c(0.1, 0.5, 1, 2, 5, 10),
  txt_gp = fpTxtGp(
    label = gpar(cex = 1.1),
    ticks = gpar(cex = 1.0),
    xlab = gpar(cex = 1.2),
    title = gpar(cex = 1.5)
  ),
  lineheight = unit(1.3, "lines"),
  graphwidth = unit(0.35, "npc"),
  colgap = unit(0.02, "npc"),
  lwd.ci = 2,
  lty.ci = "solid",
  ci.vertices = TRUE,
  ci.vertices.height = 0.2,
  clip = c(0.1, 10),
  align = "l"
)

grid.text("Subgroup Analysis of Liver Cirrhosis and Non-Liver Cirrhosis", 
          x = unit(0.5, "npc"), y = unit(0.97, "npc"),
          gp = gpar(fontsize = 16, fontface = "bold"))

grid.text("JAMA Style Forest Plot", 
          x = unit(0.5, "npc"), y = unit(0.93, "npc"),
          gp = gpar(fontsize = 12, col = "gray40"))

dev.off()
shell.exec("jama_style_forestplot.png")  # Windows 下自动打开图