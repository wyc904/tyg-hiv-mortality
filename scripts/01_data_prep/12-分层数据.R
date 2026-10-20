  # 加载必要的库
  library(readxl)
  library(dplyr)
  library(lubridate)
  library(writexl)



df<- read_excel("1300-hiv.xlsx")


colnames(df)


# 假设原始数据框名为 df
df <- df %>%
  mutate(
    
    
    # 血小板评分
    PLT_score = case_when(
      PLT > 149              ~ 0,
      between(PLT, 100, 149) ~ 1,
      between(PLT, 50, 99)   ~ 2,
      between(PLT, 20, 49)   ~ 3,
      PLT < 20              ~ 4,
      TRUE ~ NA_integer_
    ),
    
    # 肌酐评分（假设单位为 μmol/L）
    Cr_score = case_when(
      Cr < 110              ~ 0,
      between(Cr, 110, 170) ~ 1,
      between(Cr, 170, 299) ~ 2,
      between(Cr, 300, 440) ~ 3,
      Cr > 440             ~ 4,
      TRUE ~ NA_integer_
    ),
    
    # 胆红素评分（假设单位为 μmol/L）
    # 修正：删除重复定义（原有两个 bilirubin_score，后者覆盖前者且阈值不一致）
    bilirubin_score = case_when(
      TBIL < 20             ~ 0,
      between(TBIL, 20, 32) ~ 1,
      between(TBIL, 32, 101) ~ 2,
      between(TBIL, 101, 204) ~ 3,
      TBIL > 204           ~ 4,
      TRUE ~ NA_integer_
    )
  )


df <- df %>%
  mutate(
    
    
    # 新增CD4分层评分
    呼吸_score = case_when(
      呼吸指数 < 100               ~ 4,   # <50为1
      between(呼吸指数, 100, 199)  ~ 3,   # 50-199为2
      between(呼吸指数, 200, 299)  ~ 2,  
      between(呼吸指数, 300, 399)  ~ 1, 
      呼吸指数 >= 400             ~ 0,   # >=200为3
      TRUE ~ NA_integer_            # 其他情况（如缺失值）设为NA
    )
  )


write_xlsx(df, "8-4067-初步总3991s.xlsx")


# 
# # 创建测试数据
# test_data <- tibble(
#   GCSsofa = c(15, 14, 11, 8, 3),
#   sofa呼吸 = c(450, 350, 250, 150, 80),
#   PLT = c(160, 120, 70, 30, 15),
#   Cr = c(100, 150, 200, 350, 500),
#   bilirubin = c(18, 25, 50, 150, 210)
# )
# 
# # 应用评分函数
# test_data %>% 
#   mutate(
#     GCS_score = case_when(...),  # 使用上述评分逻辑
#     # 其他评分同理...
#   )


#########




df<- read_excel("29-3991-总- (2).xlsx")



# 创建新列'organ_dysfunction_count'存储累加结果
df$器官障碍11 <- rowSums(
  # 对6个指定列同时进行判断
  df[, c("PLT_score", "Cr_score", "bilirubin_score", "GCS", "呼吸", "循环")] >= 2
)

# 查看结果
write_xlsx(df, "processed1.xlsx")


#########################################







library(dplyr)
library(readxl)

df <- read_excel("47-4065-3200-住院-首日病程-gcs.xlsx")

# colnames(df)
# 


df <- df %>%
  mutate(
   
    
    # 新增CD4分层评分
    CD4_score = case_when(
      CD4 < 50               ~ 1,   # <50为1
      between(CD4, 50, 199)  ~ 2,   # 50-199为2
      CD4 >= 200             ~ 3,   # >=200为3
      TRUE ~ NA_integer_            # 其他情况（如缺失值）设为NA
    )
  )

df <- df %>%
  mutate(


    # 新增CD4分层评分
    HIVRNA_score = case_when(
      HIVRNA < 50               ~ 1,   # <50为1
      between(HIVRNA, 50, 1000)  ~ 2,   # 50-199为2
      between(HIVRNA, 1000, 1000000)  ~ 3, 
      HIVRNA >= 1000000          ~ 4,   # >=200为3
      TRUE ~ NA_integer_            # 其他情况（如缺失值）设为NA
    )
  )


df <- df %>%
  mutate(
    
    
    # 新增CD4分层评分
    ThTs_score = case_when(
      ThTs < 0.5               ~ 1,   # <50为1
      between(ThTs, 0.5, 1)  ~ 2,   # 50-199为2
      ThTs >= 1         ~ 3,   # >=200为3
      TRUE ~ NA_integer_            # 其他情况（如缺失值）设为NA
    )
  )

df <- df %>%
  mutate(
    
    
    # 新增CD4分层评分
    GCS_sofa = case_when(
      GCS < 6               ~ 4,   # <50为1
      between(GCS, 6, 9)  ~ 3,   # 50-199为2
      between(GCS,10,12)  ~ 2,   # 50-199为2
      between(GCS,12,14)  ~ 1,   # 50-199为2
      GCS >= 15         ~ 0,   # >=200为3
      TRUE ~ NA_integer_            # 其他情况（如缺失值）设为NA
    )
  )
# 将数据框保存为CSV格式
write.csv(df, "数据.csv", row.names = FALSE)
