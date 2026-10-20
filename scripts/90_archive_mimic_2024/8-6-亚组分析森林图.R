rm(list=ls());gc()



# 加载必要的R包
library(readxl)
library(forestplot)
library(dplyr)
library(tidyr)
# # 读取Excel文件
# file_path <- "subgroup_analysis.xlsx"
data <- 森林图练习
# # 准备数据
# data <- data %>%
#   mutate(
#     lower = HR - 1.96 * number,
#     upper =HR + 1.96 * number
#   )



# 创建森林图数据
forest_data <- data %>%
  select(Subgroups, HR, CI_lower, CI_upper, `P_value`, `P_interaction`) %>%
  mutate(
    Adjusted_HR = formatC(HR, format = "f", digits = 3),
    lower = formatC(CI_lower, format = "f", digits = 3),
    upper = formatC(CI_upper, format = "f", digits = 3),
    `P value` = formatC(`P_value`, format = "f", digits = 3),
    `P for interaction` = formatC(`P_interaction`, format = "f", digits = 3)
  )


# 去除包含NA值的行
forest_data <- data %>%
  filter(!is.na(HR) & !is.na(CI_lower) & !is.na(CI_upper) & !is.na(P_value) & !is.na(P_interaction)) %>%
  select(Subgroups, HR, CI_lower, CI_upper, P_value, P_interaction) %>%
  mutate(
    Adjusted_HR = formatC(HR, format = "f", digits = 3),
    lower = formatC(CI_lower, format = "f", digits = 3),
    upper = formatC(CI_upper, format = "f", digits = 3),
    `P value` = formatC(P_value, format = "f", digits = 3),
    `P for interaction` = formatC(P_interaction, format = "f", digits = 3)
  )

# 将数值列转换为数值型，并处理NA字符
forest_data <- data %>%
  mutate(
    HR = as.numeric(HR),
    CI_lower = as.numeric(CI_lower),
    CI_upper = as.numeric(CI_upper),
    P_value = as.numeric(P_value),
    P_interaction = as.numeric(P_interaction)
  ) %>%
  select(Subgroups, HR, CI_lower, CI_upper, P_value, P_interaction) %>%
  mutate(
    Adjusted_HR = formatC(HR, format = "f", digits = 3),
    lower = formatC(CI_lower, format = "f", digits = 3),
    upper = formatC(CI_upper, format = "f", digits = 3),
    `P value` = formatC(P_value, format = "f", digits = 3),
    `P for interaction` = formatC(P_interaction, format = "f", digits = 3)
  )
# forest_data
# 添加标题行
header <- c("Subgroups", "Adjusted HR (95% CI)", "P value", "P for interaction")
table_text <- rbind(header, forest_data %>%
                      mutate(Adjusted_HR_CI = paste0(Adjusted_HR, " (", lower, "-", upper, ")")) %>%
                      select(Subgroups, Adjusted_HR_CI, `P value`, `P for interaction`) %>%
                      as.matrix())

# 检查是否有空行
is_summary <- c(TRUE, rep(FALSE, nrow(forest_data)))

# 绘制森林图
forestplot(
  labeltext = table_text,
  mean = c(NA, as.numeric(forest_data$HR)),
  lower = c(NA, as.numeric(forest_data$CI_lower)),
  upper = c(NA, as.numeric(forest_data$CI_upper)),
  zero = 1,                        # 均值为1时的参考线，也就是零线
  boxsize = 0.3,                   # 方框的大小
  graph.pos = "right",             # 森林图在右侧显示
  graphwidth = unit(.25, "npc"),   # 森林图的宽度
  xticks = c(0.990, 1.015),        # x轴刻度
  is.summary = is_summary,  
  txt_gp = fpTxtGp(                # 文本样式的设置
    label = gpar(cex = 0.8),       # 标签的大小
    ticks = gpar(cex = 1),         # 刻度标记的大小
    xlab = gpar(cex = 0.9),        # x轴标签的大小
    title = gpar(cex = 1.2),       # 标题的大小
    summary = gpar(fontface = "bold") # 汇总行加粗
  ),
  lwd.zero = 1,                    # 均值线的宽度
  lwd.ci = 1.5,                    # 置信区间线的宽度
  lwd.xaxis = 2,                   # x轴线的宽度
  lty.ci = 1.5,                    # 置信区间线的样式
  ci.vertices = TRUE,              # 是否显示置信区间的顶点
  ci.vertices.height = 0.2,        # 置信区间顶点的高度
  clip = c(0.98, 1.2),             # x轴的截断范围
  lineheight = unit(8, 'mm'),      # 森林图内线的高度
  line.margin = unit(8, 'mm'),     # 森林图线的边距
  colgap = unit(6, 'mm'),          # 森林图中方框的间距
  fn.ci_norm = "fpDrawDiamondCI",  # 置信区间的形状（这里是钻石形）
  title = "多因素Cox回归森林图",   # 森林图的标题
  col = fpColors(                  # 颜色设置
    box = "blue4",                 # 方框颜色
    lines = "blue4",               # 线条颜色
    zero = "black"                 # 均值为0时的颜色
  )
)








