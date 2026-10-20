
rm(list=ls())

library(rms)
# 绘制HR曲线
library(ggplot2)
# 设定数据集和模型公式


data <- X11  # 假设你的数据集名称是X642_sephf_全

# 创建 datadist 对象
dd <- datadist(data)
options(datadist = "dd")
# 创建一个生存对象，包含生存时间(day28)和事件状态(day28_outcome)
surv_obj <- Surv(data$year1, data$year1_outcome)


# 拟合Cox比例风险模型
# rcs(TyGbmi, 4) 表示对TyGbmi变量进行受限立方样条变换，分为4个结点
m3 <- cph(surv_obj ~ rcs(TyGbmi, 3) + age, data = data, x = TRUE, y = TRUE)


anova(m3)
# 计算预测值，fun=exp表示将线性预测转化为风险比(HR)
HR <- Predict(m3, TyGbmi, fun = exp, ref.zero = TRUE)



# 使用ggplot2绘制曲线
P2 <- ggplot() +
  geom_line(data = HR, aes(TyGbmi, yhat), linetype = "solid", size = 1, alpha = 0.7, colour = "darkblue") +
  geom_ribbon(data = HR, aes(TyGbmi, ymin = lower, ymax = upper), alpha = 0.1, fill = "darkblue") +
  theme_classic() +
  geom_hline(yintercept = 1, linetype = 2, size = 1) +  # 在HR=1的位置绘制水平线
  labs(x = "TyGbmi", y = "Hazard Ratio (95% CI)")  # 添加标签

# 显示图形
print(P2)
