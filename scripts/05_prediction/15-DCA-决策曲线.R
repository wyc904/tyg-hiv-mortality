############################
## 一、准备与数据读取
############################
library(survival)
library(readxl)
library(dplyr)
library(rmda)    # DCA 分析

setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"))
df <- read_excel("tyg-1300-hiv.xlsx")

# 确保结局变量为 0/1（二分类）
df$D28 <- as.numeric(df$D28)

############################
## 二、构建 DCA 模型
############################
# new_score
dca_new <- decision_curve(D28 ~ TYGCD4,
                          data = df,
                          family = binomial(link = "logit"),
                          thresholds = seq(0.01, 0.99, by = 0.01),
                          confidence.intervals = 0.95, 
                          study.design = "cohort")

dca_sofa <- decision_curve(D28 ~ sofa,
                           data = df,
                           family = binomial(link = "logit"),
                           thresholds = seq(0.01, 0.99, by = 0.01),
                           confidence.intervals = 0.95, 
                           study.design = "cohort")
# 
# 
# # SOFA
# dca_1 <- decision_curve(死亡终 ~ age+gender,
#                         data = df,
#                         family = binomial(link = "logit"),
#                         thresholds = seq(0.01, 0.99, by = 0.01),
#                         confidence.intervals = 0.95, 
#                         study.design = "cohort")
# 
# 
# 
# dca_2 <- decision_curve(死亡终 ~ Vasopressor + CRRT + IMV,
#                         data = df,
#                         family = binomial(link = "logit"),
#                         thresholds = seq(0.01, 0.99, by = 0.01),
#                         confidence.intervals = 0.95, 
#                         study.design = "cohort")

############################
## 三、合并并绘图
# ############################
# dca_list <- list(NewScore = dca_new, SOFA = dca_sofa,NewScore = dca_1, SOFA = dca_2)
# 
# 
# plot_decision_curve(dca_list,
#                     curve.names = c("HISPS", "SOFA","Age+Gender", "Intervention"),
#                     cost.benefit.axis = FALSE,
#                     standardize = FALSE,
#                     n.cost.benefits =10,
#                     confidence.intervals = FALSE,
#                     col = c("#f94040","#0000ff","#00c000","#ffa040"),
#                    
#                     lwd = 2)
# 


# 
# # 添加主题
# title(main = "Decision Curve Analysis for New Score vs SOFA")








dca_list <- list(NewScore = dca_new, SOFA = dca_sofa)

# 先绘制决策曲线，不显示默认图例

plot_decision_curve(dca_list,
                    curve.names = c("HISPS", "SOFA"),
                    cost.benefit.axis = FALSE,
                    standardize = FALSE,
                    n.cost.benefits =10,
                    confidence.intervals = FALSE,
                    col = c("#f94040","#0000ff"),
                    
                    lwd = 2,
                    legend.position = "none",
                    xlim = c(0, 1),   # 设置x轴范围
                    ylim = c(-0.05, 0.2)) # 设置y轴范围


# 使用 legend() 函数手动添加放大的图例
legend("topright",
       legend = c("HISPS", "SOFA", "All", "None"),
       col = c("#f94040","#0000ff", "gray", "black"),
       lwd = c(2, 2, 2, 2),
       cex = 0.5)  # 使用 cex 参数控制图例文本大小

# # 添加主题
# title(main = "Decision Curve Analysis for HISPS vs SOFA")















