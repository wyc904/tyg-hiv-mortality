library(readxl)
library(dplyr)
library(tidyr)
library(writexl)

# 读取 Excel 文件
cat("开始读取Excel文件...\n")
df_total <- read_excel("标准化样本-0729.xlsx")

# 重命名原始数据框中的列，以便后续处理（如果需要）
# names(df_total) <- c("编号", "batch", "TYGCD4", "TYG", ...)

# 创建一个新的数据框，选择需要的列
df_total_selected <- data.frame(
  TYG = df_total$TYG,
  `IFN-α2` = df_total$`IFN-a2`, 
  `IFN-γ` = df_total$`IFN-y`, 
  `TNF-α` = df_total$`TNF-a`,
  `MCP-1` = df_total$`MCP-1`,
  `IL-6` = df_total$`IL-6`,
  `IL-8` = df_total$`IL-8`,
  `IL-10` = df_total$`IL-10`,
  `IL-12p70` = df_total$`IL-12p70`,
  `IL-17A` = df_total$`IL-17A`,
  `IL-18` = df_total$`IL-18`,
  `IL-23` = df_total$`IL-23`,
  `IL-33` = df_total$`IL-33`,
  `IL-1β` = df_total$`IL-1b`
)
# 数据处理
result_df <- df_total %>%
  # 筛选有效分组
  filter(TYG %in% c(0, 1)) %>%
  # 转换为长格式
  pivot_longer(
    cols = c(`IFN-a2`, `IFN-y`, `TNF-a`, `MCP-1`, `IL-6`, `IL-8`, `IL-10`,
             `IL-12p70`, `IL-17A`, `IL-18`, `IL-23`, `IL-33`, `IL-1b`),
    names_to = "Cytokine",
    values_to = "Value"
  ) %>%
  # 添加分组标识
  mutate(Group = paste0(Cytokine, "-", TYG)) %>%
  # 明确设定 Group 顺序：先对 Cytokine 排序，然后拼接 -0 和 -1
  arrange(Cytokine, TYG) %>%
  select(Group, Value) %>%
  group_by(Group) %>%
  mutate(id = row_number()) %>%
  ungroup() %>%
  pivot_wider(
    names_from = Group,
    values_from = Value
  ) %>%
  select(-id)  # 移除临时ID列

# 导出到 Excel
write_xlsx(result_df, "cytokine_grouped_data.xlsx")
