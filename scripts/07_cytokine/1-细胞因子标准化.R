# 加载必要的库
library(readxl)
library(dplyr)
library(lubridate)
library(writexl)


setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"))
# 
# setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop/Cursor"))
# # 
# list.files()


# "姓名", "性别", "当前年龄"
# 工作簿1
# 读取两个Excel文件
cat("开始读取Excel文件...\n")
df_total <- read_excel("细胞因子1300初步数据1.xlsx")

# df_total <-merged_df

colnames(df_total)



library(dplyr)
library(tidyr)
library(purrr)



# ========== Step 1: 定义标准浓度映射 ==========
浓度对照 <- tibble(
  编号 = paste0("C", 0:7),
  浓度 = c(0, 1.220703125, 4.8828125, 19.53125, 78.125, 312.5, 1250, 5000)
)

# ========== Step 2: 合并浓度信息到原始数据 ==========
df_total <- df_total %>%
  left_join(浓度对照, by = "编号")

# ========== Step 3: 提取所有因子名称（列） ==========
因子列 <- c("IL-1b", "IFN-a2 (A5)", "IFN-y", "TNF-a", "MCP-1", "IL-6", "IL-8", "IL-10", "IL-12p70", "IL-17A", "IL-18", "IL-23", "IL-33")

# ========== Step 4: 分开标准曲线与样本数据 ==========
标准曲线_df <- df_total %>% filter(grepl("^C[0-7]$", 编号))
样本_df <- df_total %>% filter(!grepl("^C[0-7]$", 编号))

# ========== Step 5: 对每个因子执行标准化 ==========
标准化结果 <- purrr::map_dfc(因子列, function(factor_name) {
  purrr::map2_dfr(样本_df$batch, 1:nrow(样本_df), function(batch_id, i) {
    y0 <- 样本_df[[factor_name]][i]
    
    # 当前批次对应标准曲线
    std_sub <- 标准曲线_df %>%
      filter(batch == batch_id) %>%
      select(浓度, 响应值 = all_of(factor_name)) %>%
      arrange(响应值)
    
    # 插值计算
    std_val <- approx(
      x = std_sub$响应值,
      y = std_sub$浓度,
      xout = y0,
      rule = 2
    )$y
    
    tibble(!!paste0("std_", factor_name) := std_val)
  })
})

# ========== Step 6: 合并标准化结果到样本数据 ==========
标准化样本 <- bind_cols(
  样本_df %>% select(编号, batch, all_of(因子列)),
  标准化结果
)

# 查看结果
# print(head(标准化样本))

标准化样本 <- bind_cols(
  样本_df,
  标准化结果
)


write_xlsx(标准化样本, "标准化样本1.xlsx")

# ========== Step 6: 合并标准化结果到原始样本数据（保留所有列） ==========

# 查看结果


