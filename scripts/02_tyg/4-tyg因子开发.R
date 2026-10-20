# 全流程代码
library(survival)
library(rms)
library(maxstat)
# 加载必要的库
library(readxl)
library(writexl)











# 步骤1：数据准备
data <- read_excel("MI_2.0.xlsx")
colnames(data)

# 步骤2：RCS节点选择
aic_values <- sapply(3:5, function(k) {
  model <- cph(Surv(hoslos, 死亡) ~ rcs(sofa, k), data = data)
  AIC(model)
})
best_k <- which.min(aic_values) + 2

# 步骤3：最优拐点检测
maxstat_result <- maxstat.test(Surv(hoslos, 死亡) ~sofa, 
                               data = data, smethod = "LogRank")


# 使用Lausen1994方法计算校正p值
maxstat_result <- maxstat.test(
  Surv(hoslos, 死亡) ~ sofa, 
  data = data,
  smethod = "LogRank",
  pmethod = "Lau94"  # 显式指定校正方法
)
print(maxstat_result)



# 基于新拐点构建分层变量
data$TYG_strata <- cut2(data$TYG, cuts = c(9.28))  # 单拐点分层



# 构建Cox比例风险模型
final_model <- cph(
  Surv(hoslos, 死亡) ~  CD4_score +sofa,
  data = data,
  x = TRUE, 
  y = TRUE
)

# 模型验证（需加载rms包）
validate(final_model, method = "boot", B = 500, dxy = TRUE)
# 步骤5：验证模型性能
validate(final_model, method = "boot", B = 500)






#############################################3

# 假设原始数据框名为data
# 检查数据结构
head(data)

# Step 1: 创建三个评分列 --------------------------------------------------------
# CD4_s评分规则：当CD4_s == 1时加2分
data$CD4_s_score <- ifelse(data$CD4_s == 1, 2, 0)

# TYG2评分规则：当TYG2 == 1时加1.7分
data$TYG2_score <- ifelse(data$TYG2 == 1, 1.7, 0)

# # sofa评分规则：当sofa > 2时，每超过2的部分乘0.3（例如sofa=3 → 0.3分，sofa=4 → 0.6分）
# data$sofa_score <- ifelse(data$sofa > 2, (data$sofa - 2) * 0.3, 0)



# TYG2评分规则：当TYG2 == 1时加1.7分
data$sofa_score <- ifelse(data$sofa == 1, 1.7, 0)

# Step 2: 创建两两相加的组合列 --------------------------------------------------
# CD4_s + TYG2
data$CD4_TYG2_sum <- data$CD4_s_score + data$TYG2_score

# CD4_s + sofa
data$CD4_sofa_sum <- data$CD4_s_score + data$sofa_score

# TYG2 + sofa
data$TYG2_sofa_sum <- data$TYG2_score + data$sofa_score

# Step 3: 创建总分列（三列总和） -------------------------------------------------
data$total_score <- data$CD4_s_score + data$TYG2_score + data$sofa_score

# 验证结果（查看前6行）
head(data[, c("CD4_s_score", "TYG2_score", "sofa_score", 
              "CD4_TYG2_sum", "CD4_sofa_sum", "TYG2_sofa_sum", 
              "total_score")])




write_xlsx(data, "8-4s0.xlsx")









