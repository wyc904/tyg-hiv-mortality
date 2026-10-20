# 加载必要的包
library(lubridate)
library(dplyr)
library(readr)
library(writexl)

# 读取 CSV 文件
x833 <- X9869_icu大于24

# 使用 lubridate 包来解析和格式化 intime 列
x833 <- x833 %>%
  mutate(intime = dmy_hms(intime)) %>% # 解析日期时间
  mutate(intime = format(intime, "%Y-%m-%d %H:%M:%S")) # 格式化日期时间

# # 显示结果
# print(x833)

# 将修改后的数据框写入 Excel 文件
write_xlsx(x833, "final.xlsx")
