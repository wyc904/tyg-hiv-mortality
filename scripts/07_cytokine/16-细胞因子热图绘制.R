
# 加载必要的库
library(readxl)
library(dplyr)
library(lubridate)
library(writexl)
# 加载必要的包
library(tidyverse)
library(pheatmap)


setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"))
# 
# setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop/Cursor"))
# # 
# list.files()




# 读取数据
df_total <- read_excel("标准化样本-0729.xlsx")


colnames(df_total)

# `IL-17A` = `IL-17A`,低于检测下线

heatmap_data <- df_total %>% 
  select(group = TYGCD4, 
         `IFN-α2` = `IFN-a2`, 
         `IFN-γ` = `IFN-y`, 
         `TNF-α` = `TNF-a`,
         `MCP-1` = `MCP-1`,
         `IL-6` = `IL-6`,
         `IL-8` = `IL-8`,
         `IL-10` = `IL-10`,
         `IL-12p70` = `IL-12p70`,
         `IL-18` = `IL-18`,
         `IL-23` = `IL-23`,
         `IL-33` = `IL-33`,
         `IL-1β` = `IL-1b`)


# 
# # 提取分组和细胞因子数据
# heatmap_data <- df_total %>% 
#   select(group = TYGCD4, 
#          `IFN-α2` = `std_IFN-a2 (A5)`, 
#          `IFN-γ` = `std_IFN-y`, 
#          `TNF-α` = `std_TNF-a`,
#          `MCP-1` = `std_MCP-1`,
#          `IL-6` = `std_IL-6`,
#          `IL-8` = `std_IL-8`,
#          `IL-10` = `std_IL-10`,
#          `IL-12p70` = `std_IL-12p70`,
#          `IL-17A` = `std_IL-17A`,
#          `IL-18` = `std_IL-18`,
#          `IL-23` = `std_IL-23`,
#          `IL-33` = `std_IL-33`)
# `IL-1β` = `std_IL-1b`,
# 确保数值格式
heatmap_data[, -1] <- lapply(heatmap_data[, -1], as.numeric)

# 按分组计算均值
grouped_median <- heatmap_data %>% 
  group_by(group) %>% 
  summarise(across(everything(), mean, na.rm = TRUE)) %>% 
  column_to_rownames("group") %>% 
  t()  # 转置矩阵

# 创建带说明的分组标签 (1234组对应的描述)
group_labels <- c(
  "1" = "CD4≥50 & TYG<9.22",
  "2" = "CD4≥50 & TYG≥9.22",
  "3" = "CD4<50 & TYG<9.22",
  "4" = "CD4<50 & TYG≥9.22"
)

# 创建注释数据框
annotation_col <- data.frame(
  Group = factor(colnames(grouped_median), 
                 levels = names(group_labels),
                 labels = group_labels)
)
rownames(annotation_col) <- colnames(grouped_median)

# 自定义分组颜色（可选）
ann_colors <- list(
  Group = c(
    "CD4≥50 & TYG<9.22" = "#1f77b4",
    "CD4≥50 & TYG≥9.22" = "#ff7f0e",
    "CD4<50 & TYG<9.22" = "#2ca02c",
    "CD4<50 & TYG≥9.22" = "#d62728"
  )
)

# 绘制热图（完整标签版）
pheatmap(grouped_median,
         main = "Cytokine Expression by TYG-CD4",
         color = colorRampPalette(c("navy", "white", "firebrick3"))(100),
         scale = "row",            # 按行标准化
         cluster_rows = TRUE,      # 聚类细胞因子
         cluster_cols = FALSE,     # 保持分组顺序(1-4)
         show_rownames = TRUE,     # 显示细胞因子名称
         show_colnames = FALSE,    # 隐藏原始列名（用注释代替）
         annotation_col = annotation_col,
         annotation_colors = ann_colors, # 使用自定义颜色
         fontsize_row = 10,         # 行名字体大小
         fontsize = 11,            # 通用字体大小
         angle_col = 0,            # 列名水平显示
         cellwidth = 40,           # 单元格宽度
         cellheight = 25,          # 单元格高度
         border_color = "grey70",  # 边框颜色
         treeheight_row = 40,      # 行聚类树高度
         gaps_col = 1:3            # 在分组间添加间隔
)










# 单元格高度