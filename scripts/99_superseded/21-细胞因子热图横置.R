# 加载必要的库
library(readxl)
library(dplyr)
library(lubridate)
library(writexl)
library(tidyverse)
library(pheatmap)

# 设置工作目录
setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"))

# 读取数据
df_total <- read_excel("1-188-聚类细胞因子-初次合并未处理.xlsx")


# `IL-17A` = `IL-17A`,检测线下

# 提取分组和细胞因子数据
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

# 确保数值格式
heatmap_data[, -1] <- lapply(heatmap_data[, -1], as.numeric)

# 按分组计算均值
grouped_median <- heatmap_data %>% 
  group_by(group) %>% 
  summarise(across(everything(), mean, na.rm = TRUE)) %>% 
  column_to_rownames("group")  # 不转置，保持分组为行，细胞因子为列

# 创建带说明的分组标签
group_labels <- c(
  "1" = "CD4≥50 & TYG<9.22",
  "2" = "CD4≥50 & TYG≥9.22",
  
)

# 创建注释数据框（用于行注释，因为分组现在是行）
annotation_row <- data.frame(
  Group = factor(rownames(grouped_median), 
                 levels = names(group_labels),
                 labels = group_labels)
)
rownames(annotation_row) <- rownames(grouped_median)

# 自定义分组颜色
ann_colors <- list(
  Group = c(
    "CD4≥50 & TYG<9.22" = "#1f77b4",
    "CD4≥50 & TYG≥9.22" = "#ff7f0e",
    
  )
)

# 绘制热图
pheatmap(grouped_median,
         main = "Cytokine Expression by TYG-CD4",
         color = colorRampPalette(c("navy", "white", "firebrick3"))(100),
         scale = "column",          # 按列标准化（因为细胞因子现在是列）
         cluster_rows = FALSE,      # 保持分组顺序（1-4）
         cluster_cols = TRUE,       # 聚类细胞因子
         show_rownames = TRUE,      # 显示分组名称
         show_colnames = TRUE,      # 显示细胞因子名称
         annotation_row = annotation_row,  # 使用行注释
         annotation_colors = ann_colors,   # 使用自定义颜色
         fontsize_row = 10,         # 行名字体大小
         fontsize = 11,            # 通用字体大小
         fontfamily = "Times New Roman",  # 设置字体为Times New Roman
         angle_col = 45,           # 列名倾斜45度以适应更多标签
         cellwidth = 40,           # 单元格宽度
         cellheight = 35,          # 单元格高度
         border_color = "grey70",  # 边框颜色
         treeheight_col = 40,      # 列聚类树高度
         gaps_row = 1:3,           # 在分组间添加间隔
         annotation_legend = TRUE,  # 显示注释图例
         legend = TRUE,            # 显示颜色比例图例
         annotation_legend_side = "right"  # 强制注释图例在右边
)