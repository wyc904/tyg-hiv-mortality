# 加载必要的包
library(survival)
library(pROC)
library(survIDINRI)
library(dplyr)
library(readxl)
library(survcomp)  # 用于计算C-index
library(timeROC)   # 时间依赖ROC曲线

# 读取数据
data <- read_excel("3-864-hiv-tyg.xlsx")

# 创建无缺失的数据子集（包括SOFA评分，如果有的话）
data_sub <- data %>%
  dplyr::select(hoslos, 死亡, CD43, TyG_index分层,TYGCD, sofa) %>%
  na.omit()

# 构建模型
model1 <- coxph(Surv(hoslos, 死亡) ~ CD43, data = data_sub)
model2 <- coxph(Surv(hoslos, 死亡) ~ TyG_index分层, data = data_sub)
model3 <- coxph(Surv(hoslos, 死亡) ~ TYGCD, data = data_sub)
model4 <- coxph(Surv(hoslos, 死亡) ~ CD43 * TyG_index分层, data = data_sub)
model5 <- coxph(Surv(hoslos, 死亡) ~   sofa, data = data_sub)
# TYGCD +
# 获取预测风险
data_sub$risk1 <- predict(model1, type = "risk")
data_sub$risk2 <- predict(model2, type = "risk")
data_sub$risk3 <- predict(model3, type = "risk")
data_sub$risk4 <- predict(model4, type = "risk")
data_sub$risk5 <- predict(model5, type = "risk")

# 生存时间和状态
time <- data_sub$hoslos
status <- data_sub$死亡

# ---------- C-index ----------
c_index <- function(pred, time, status) {
  concordance.index(pred, surv.time = time, surv.event = status, method = "noether")$c.index
}

c1 <- c_index(data_sub$risk1, time, status)
c2 <- c_index(data_sub$risk2, time, status)
c3 <- c_index(data_sub$risk3, time, status)
c4 <- c_index(data_sub$risk4, time, status)
c5 <- c_index(data_sub$risk5, time, status)

cat("C-index:\n")
cat("Model1 (CD4):", c1, "\n")
cat("Model2 (TyG):", c2, "\n")
cat("Model3 (CD4 + TyG):", c3, "\n")
cat("Model4 (CD4 * TyG):", c4, "\n")
cat("Model5 (+SOFA):", c5, "\n\n")

# ---------- AUC（以hoslos = 14天为例） ----------
auc3 <- timeROC(T = time, delta = status,
                marker = data_sub$risk3,
                cause = 1, times = 14, iid = TRUE)

auc4 <- timeROC(T = time, delta = status,
                marker = data_sub$risk4,
                cause = 1, times = 14, iid = TRUE)

cat("AUC at 14 days:\n")
cat("Model3:", auc3$AUC, "\n")
cat("Model4:", auc4$AUC, "\n\n")

# ---------- IDI 和 NRI ----------
# 比较 model3 和 model4（是否添加交互有提升）
IDI_NRI <- IDI.INF(
  T = data_sub$hoslos,
  D = data_sub$死亡,
  covs0 = data.frame(data_sub$risk3),
  covs1 = data.frame(data_sub$risk4),
  t0 = 14
)


cat("IDI:", IDI_NRI$IDI, "\n")
cat("NRI:", IDI_NRI$NRI, "\n")
