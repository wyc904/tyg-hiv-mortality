# 定义数据
df <- data.frame(
  Level = c(2, 2, 2, 1, 1, 1),
  Group = c(2, 3, 4, 2, 3, 4),
  HR = c(1.181263226, 1.44519114, 2.429551616, 2.057494185, 2.301385156, 2.012108959),
  CI_lower = c(0.56962615, 0.810812273, 1.310294809, 0.787817258, 1.100716688, 0.927508479),
  CI_upper = c(2.449646681, 2.575907518, 4.504880136, 5.373431816, 4.811750103, 4.365008573)
)

# 1. 计算log(HR)和标准误
df$logHR <- log(df$HR)
df$SE <- (log(df$CI_upper) - log(df$CI_lower)) / (2 * 1.96)

# 2. 按Group分组计算交互效应
group_list <- unique(df$Group)
chi_sq_sum <- 0

for (g in group_list) {
  # 提取水平1和水平2的数据
  level2 <- df[df$Level == 2 & df$Group == g, ]
  level1 <- df[df$Level == 1 & df$Group == g, ]
  
  # 计算差异和标准误差异
  diff_beta <- level1$logHR - level2$logHR
  se_diff <- sqrt(level1$SE^2 + level2$SE^2)
  
  # 计算卡方值
  chi_sq <- (diff_beta / se_diff)^2
  chi_sq_sum <- chi_sq_sum + chi_sq
}

# 3. 计算P_interaction
df_chi <- length(group_list)  # 自由度
p_interaction <- pchisq(chi_sq_sum, df = df_chi, lower.tail = FALSE)

# 显示结果
cat(sprintf("P_interaction = %.3f\n", p_interaction))