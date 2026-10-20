# 加载必要的包
library(survival)
library(pROC)
library(dplyr)
# rm(list=ls());gc()
library(survival)  # 用于Cox回归模型
library(dplyr)     # 数据操作
library(broom)
library(openxlsx)
# 加载必要的库
library(readxl)
library(dplyr)
library(lubridate)
library(writexl)
library(survIDINRI)



# 假设数据存储在名为 `data` 的数据框中
data<- read_excel("3-864-hiv-tyg.xlsx")




# 拟合未调整的Cox模型（模型1）
model1 <- coxph(Surv(data$hoslos, 死亡) ~ TyG_index分层, data = data)


# 拟合未调整的Cox模型（模型1）
model2 <- coxph(Surv(data$hoslos, 死亡) ~ CD43, data = data)

# 创建完整模型 (SOFA + 免疫指标 + 协变量)
# 拟合未调整的Cox模型（模型1）
model3 <- coxph(Surv(data$hoslos, 死亡) ~TYGCD, data = data)


# 计算两个模型的C指数 (等效AUC)
c_index_ <- summary(model1)$concordance[1]
c_index_full <- summary(model3)$concordance[1]

