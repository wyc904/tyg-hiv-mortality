# 加载必要的包
library(survival)
library(survminer)



data<-X642_sephf_全

# 假设data是你的数据框，并且已经包含了TyG/BMI指数列和year1_outcome列
# 创建生存对象
surv_obj <- Surv(data$day28, data$day28_outcome)

# 拟合Cox比例风险模型
cox_model <- coxph(surv_obj ~ TyGbmi, data = data)

# 查看Cox模型结果
summary(cox_model)

# 绘制Cox比例风险模型的生存曲线
ggsurvplot(survfit(cox_model), data = data,
           xlab = "Time (years)",
           ylab = "Survival Probability",
           title = "Cox Proportional-Hazards Model: TyG/BMI Index")

# 检查比例风险假设
cox.zph(cox_model)
