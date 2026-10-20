


# 加载必要的库
library(readxl)
library(dplyr)
library(lubridate)
library(writexl)


setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop/肝衰竭"))
# 
# setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop/Cursor"))
# # 
# list.files()


# "姓名", "性别", "当前年龄"
# 工作簿1
# 读取两个Excel文件
cat("开始读取Excel文件...\n")

df_total <- read_excel("标准化样本1.xlsx")
df_blood <- read_excel("tyg-1300-hiv.xlsx")

 # df_total <-merged_df

colnames(df_total)


# 合并数据
cat("开始合并表...\n")
merged_df <- left_join(df_total, df_blood, by = c("姓名"))
# 


dedup_df1 <- merged_df %>%
  distinct(.keep_all = TRUE) # 保留所有列的唯一组合


write_xlsx(dedup_df1, "s82s.xlsx")






colnames(df_total)













##########################


# "姓名", "性别", "当前年龄"
# 
# # 读取两个Excel文件
# cat("开始读取Excel文件...\n")
df_total <- read_excel("总.xlsx")
df_blood <- read_excel("最后总诊断1.xlsx")

# # 合并数据
# cat("开始合并表...\n")
merged_df <- left_join(df_total, df_blood, by = c("姓名","性别","当前年龄"))

# 
# merged_df  <-df_blood
# # # 
# merged_df  <- read_excel("工作簿1.xlsx")

# "就诊号", "机构", "门诊号", "住院号"
# 删除不需要的列
cat("删除不需要的列...\n")
columns_to_drop <- c("机构")
# 只删除在数据框中存在的列
columns_to_drop <- columns_to_drop[columns_to_drop %in% names(merged_df)]
merged_df <- merged_df[, !names(merged_df) %in% columns_to_drop]

# 将日期列转换为日期时间类型
cat("转换日期格式...\n")
date_columns <- c("入院日期", "出院日期", "报告时间")
for (col in date_columns) {
  if (col %in% names(merged_df)) {
    merged_df[[col]] <- as.POSIXct(merged_df[[col]], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
  }
}

# 删除开始时间为空白的数据
cat("删除开始时间为空白的数据...\n")
merged_df <- merged_df[!is.na(merged_df$报告时间), ]
cat(sprintf("删除空白开始时间后记录数: %d\n", nrow(merged_df)))

# 筛选开始时间在入院日期和出院日期之间的数据（允许前后3天误差）
cat("筛选开始时间在入院日期和出院日期之间的数据...\n")
merged_df <- merged_df %>%
  filter(
    报告时间>= (入院日期 - days(3)) & 
      报告时间<= (出院日期 + days(3))
  )
cat(sprintf("筛选后记录数: %d\n", nrow(merged_df)))

# "姓名.y", "性别.y","当前年龄", "年龄", "门诊住院", "开单科室",
# "检验组项目名称", "检验子项目中文名称",
# "检验子项目英文名称", "检验结果", "单位", "参考范围"
# 方法：使用正则表达式匹配列名删除（推荐）
# columns_to_remove <- c(
#   # 删除所有以 .x 结尾的列（如 姓名.x、性别.x）
#   grep("\\.x$", colnames(merged_df), value = TRUE),  
#   # 删除其他指定列
#   "姓名.y", "性别.y","当前年龄", "年龄", "门诊住院", "开单科室",
#   "检验组项目名称", "检验子项目中文名称",
#   "检验子项目英文名称", "检验结果", "单位", "参考范围"
# )
# merged_df <- merged_df[, !(colnames(merged_df) %in% columns_to_remove)]


dedup_df1 <- merged_df %>%
  distinct(.keep_all = TRUE) # 保留所有列的唯一组合



# 保存结果
cat("保存合并后的结果...\n")
write_xlsx(dedup_df1, "12.xlsx")
# cat(sprintf("处理完成，结果已保存到'4-3991-血液净化.xlsx'，共%d行数据\n", nrow(merged_df))) 


# colnames(merged_df)

########################










# "姓名", "性别", "当前年龄"





############



# 加载所需包
# library(readxl)
# library(dplyr)
# library(writexl)
# 
setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"))
# 


# 读取主数据表
message("读取0211表...")
main_data <- read_excel("0211.xlsx") 

# 数据校验强化
required_cols <- c("姓名", "性别", "当前年龄", "ID", "id")
if (!all(required_cols %in% colnames(main_data))) {
  stop("主数据缺失关键列:", setdiff(required_cols, colnames(main_data)))
}

# 创建轻量级主数据索引
main_index <- main_data %>%
  select(all_of(required_cols)) %>%
  distinct(姓名, 性别, 当前年龄, .keep_all = TRUE)  # 预防主数据本身重复

# 获取待处理文件列表
excel_files <- list.files(pattern = "\\.xlsx$", full.names = TRUE) %>%
  grep("0211\\.xlsx$", ., invert = TRUE, value = TRUE)

# 带进度条的批处理
pb <- txtProgressBar(min = 0, max = length(excel_files), style = 3)
for (i in seq_along(excel_files)) {
  file <- excel_files[i]
  tryCatch({
    # 读取实验室数据
    lab_data <- read_excel(file) 
    
    # 列名标准化处理
    names(lab_data) <- iconv(names(lab_data), "UTF-8", "UTF-8")
    
    # 动态列校验
    if (!all(c("姓名", "性别", "当前年龄") %in% names(lab_data))) {
      message("\n跳过文件 ", basename(file), ": 缺少关键标识列")
      next
    }
    
    # 执行合并操作
    merged_data <- lab_data %>%
      left_join(main_index, by = c("姓名", "性别", "当前年龄")) %>%
      distinct(across(everything()), .keep_all = TRUE)  # 全列去重
    
    # 生成带时间戳的输出文件名
    output_name <- paste0(
      tools::file_path_sans_ext(file), 
      "id", 
      ".xlsx"
    )
    
    # 保存结果
    write_xlsx(
      list(ProcessedData = merged_data, 
           Metadata = data.frame(ProcessingTime = Sys.time())),
      output_name
    )
    
    # 打印合并统计
    message(sprintf("\n文件 %s: 原始 %d 行 → 合并后 %d 行 (有效ID率 %.1f%%)",
                    basename(file), 
                    nrow(lab_data),
                    nrow(merged_data),
                    100 * sum(!is.na(merged_data$id))/nrow(merged_data)))
    
  }, error = function(e) {
    message("\n处理文件 ", basename(file), " 失败: ", conditionMessage(e))
  })
  setTxtProgressBar(pb, i)
}
close(pb)

message("\n处理完成! 共处理 ", length(excel_files), " 个文件")

#############多表合并



setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop/Cursor"))
# 



library(readxl)
library(dplyr)
library(writexl)
library(lubridate)

library(readxl)
library(dplyr)
library(writexl)

# 读取总表（保留所有列）
master_df <- read_excel("1.5w-总表1.xlsx") 

# 读取需要合并的三个表格（保留所有列）
kidney_df <- read_excel("肾.xlsx")
crrt_df <- read_excel("CRRT.xlsx")
dialysis_df <- read_excel("时间内的透析.xlsx")

# 纯合并操作（允许自动生成.x/.y后缀）
merged_data <- master_df %>%
  left_join(kidney_df, by = "ID") %>%
  left_join(crrt_df, by = "ID") %>%
  left_join(dialysis_df, by = "ID")

# 直接保存结果（保留所有原始列）
write_xlsx(merged_data, "1.5w-总表1_合并后.xlsx")


##########################批量合并



# 加载所需包
library(readxl)   # 读取Excel文件
library(dplyr)    # 数据操作
library(writexl)  # 写入Excel文件

# 设置文件路径（请修改为实际路径）
file_path <- paste0(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop/Cursor"), "/")
# setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop/Cursor"))
# # 
# # 读取主文件（左边数据）
main_data <- read_xlsx(paste0(file_path, "1800质控.xlsx")) %>% 
  mutate(ID = as.character(ID))  # 确保ID为字符型

# 定义需要合并的文件列表
merge_files <- c(
  "7-入院记录时间内166.xlsx",
  "8-首日病程合166.xlsx",
  "9-116出院记录合.xlsx",
  "hiv表单在时间内140人.xlsx"
)

# 循环合并所有文件
for(file in merge_files){
  # 读取当前文件
  temp_data <- read_xlsx(paste0(file_path, file)) %>% 
    mutate(ID = as.character(ID))  # 统一ID格式
  
  # 执行左连接合并
  main_data <- main_data %>% 
    left_join(temp_data, by = "ID", suffix = c("", "_new"))
  
  # 移除重复列后缀（可选）
  colnames(main_data) <- gsub("_new$", "", colnames(main_data))
}

# 保存合并结果
write_xlsx(main_data, paste0(file_path, "合并后的1800质控.xlsx"))




##############################




# 加载必要的包
library(dplyr)
library(lubridate)




# 工作簿1
# 读取两个Excel文件
cat("开始读取Excel文件...\n")
merged_df<- read_excel("8sss.xlsx")



# 将日期列转换为日期时间类型
cat("转换日期格式...\n")
date_columns <- c("入院日期", "出院日期", "诊断时间")
for (col in date_columns) {
  if (col %in% names(merged_df)) {
    merged_df[[col]] <- as.POSIXct(merged_df[[col]], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
  }
}




# 创建标记列（允许±3天误差）
df_total <- merged_df %>%
  mutate(
    within_period = ifelse(
      诊断时间 >= (入院日期 - days(3)) & 
        诊断时间 <= (出院日期 + days(3)),
      "是", "否"
    )
  )


write_xlsx(df_total, "8ssss.xlsx")






















































