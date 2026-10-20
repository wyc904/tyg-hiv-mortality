rm(list=ls());gc()



# 加载必要的包
library(dplyr)
library(lubridate)

# 读取表格1和表格2
table1 <- lianxi  # 替换为实际文件路径
table2 <-tg  # 替换为实际文件路径

# 确保时间列是POSIXct格式
# table1$intime <- as.POSIXct(table1$intime, format="%Y-%m-%d %H:%M:%S")
# table2$charttime <- as.POSIXct(table2$charttime, format="%Y-%m-%d %H:%M:%S")

# 假设 table1 和 table2 的时间格式为 "年-月-日 小时:分钟:秒"
closest_times <- table1 %>%
  left_join(table2, by = "subject_id") %>%
  group_by(subject_id) %>%
  mutate(time_diff = abs(difftime(charttime, admittime, units = "secs"))) %>%
  filter(time_diff == min(time_diff, na.rm = TRUE)) %>%
  ungroup() %>%
  select(-time_diff)  # 如果不再需要 time_diff，可以将其移除

# 保存结果到CSV文件
write.csv(closest_times, "closest_times1.csv", row.names = FALSE)  # 替换为实际文件路径



