
rm(list=ls());gc()


# 加载必要的包
library(dplyr)
library(readxl)
library(writexl)

# 读取CSV文件
data <- read_excel("8-4s0.xlsx")


# 计算MI_2.0
data$MI_2.0 <- (data$TyG^2) / log10(data$CD4 + 50) + 
  3 * data$TyG * (data$CD4 < 50) * (data$TyG > 9.0)



write_xlsx(data, "MI_score.xlsx")



#####################33


data$MI_score4<- cut(data$MI_2.0,
                breaks = quantile(data$MI_2.0, probs = seq(0, 1, 0.25), na.rm = TRUE),
                include.lowest = TRUE,
                labels = c("1", "2", "3", "4"))
# 
data$total_score3<- cut(data$total_score,
                breaks = quantile(data$total_score, probs = seq(0, 1, by = 1/3), na.rm = TRUE),
                include.lowest = TRUE,
                labels = c("1", "2", "3"))
#

# 


write_xlsx(data, "14.xlsx")















































































