# 安装必要的包

# 加载包

rm(list=ls())
dev.off()


library(rms)
library(plotRCS)

data<-X642_sephf_全



datadis <- datadist(X642_sephf_全)
options(datadist='datadis')

# 线性回归模型
# fit1 <- lm(size ~ rcs(age, 4) + sex + race + metastasis, data = cancer)
# summary(fit1)


# 线性回归模型
fit1 <- lm(year1_outcome ~ rcs(TyGbmi, 3) +age, data =X642_sephf_全)
# summary(fit1)


# Rcs曲线的线性回归模型
rcsplot(data = X642_sephf_全, outcome="year1_outcome",
 exposure = "TyGbmi", covariates = c("age"))

















