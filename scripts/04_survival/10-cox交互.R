# 加载必要的包
library(survival)
library(dplyr)
library(forestplot)
library(readxl)



setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"))
# 
# setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop/Cursor"))
# # 
# list.files()


# "姓名", "性别", "当前年龄"
# 工作簿1
# 读取两个Excel文件
cat("开始读取Excel文件...\n")
hiv_pos<- read_excel("1300-hiv.xlsx")

# 确保分类变量为因子类型
hiv_pos$`CD4分3层` <- factor(hiv_pos$CD4, levels = 0:1, 
                           labels = c("<50", ">50"))


hiv_pos$`HIVRNA分层` <- factor(hiv_pos$TyG, levels = 0:1, 
                             labels = c("<9.22",">9.22"))
# hiv_pos$ART <- as.factor(hiv_pos$ART)
# hiv_pos$`性别10` <- as.factor(hiv_pos$`性别10`)
# # 将分类变量转换为因子类型
# hiv_pos$Talaromycosis <- as.factor(hiv_pos$Talaromycosis)
# hiv_pos$PCP <- as.factor(hiv_pos$PCP)
# hiv_pos$Cryptococcosis <- as.factor(hiv_pos$Cryptococcosis)
# hiv_pos$念珠 <- as.factor(hiv_pos$念珠)
# hiv_pos$`性别10` <- as.factor(hiv_pos$`性别10`)
# hiv_pos$SepticShock <- as.factor(hiv_pos$SepticShock)
# hiv_pos$Heparin <- as.factor(hiv_pos$Heparin)
# hiv_pos$Vasopressor <- as.factor(hiv_pos$Vasopressor)
# hiv_pos$Glucocorticoid <- as.factor(hiv_pos$Glucocorticoid)
# hiv_pos$IMV <- as.factor(hiv_pos$IMV)
# hiv_pos$CRRT <- as.factor(hiv_pos$CRRT)
# hiv_pos$ICU <- as.factor(hiv_pos$ICU)
# hiv_pos$MainInfectionSite <- as.factor(hiv_pos$MainInfectionSite)
# 



# +  `就诊年龄` +   Talaromycosis + 
#   + PCP          + Cryptococcosis+ 念珠+  `性别10` + SepticShock  +Heparin +Vasopressor +Glucocorticoid +IMV +          
#   +CRRT +ICU+MainInfectionSite 
# 
# +   Talaromycosis + 
# + PCP          + Cryptococcosis+ 念珠 

# sofa * CD4 + sofa * HIVRNA

# 

model_sofa <- coxph(Surv(d28, D28) ~ TyG, data = hiv_pos)

model_full <- coxph(Surv(d28, D28) ~ TyG+CD4 ,      
                    data = hiv_pos)


model_interaction <- coxph(Surv(d28, D28) ~ TyG*CD4, 
                           data = hiv_pos)

# 计算三个模型的C指数 (等效AUC)
c_index_sofa <- summary(model_sofa)$concordance[1]
c_index_full <- summary(model_full)$concordance[1]
c_index_interaction <- summary(model_interaction)$concordance[1]

# 计算AIC和BIC
aic_sofa <- AIC(model_sofa)
aic_full <- AIC(model_full)
aic_interaction <- AIC(model_interaction)

bic_sofa <- BIC(model_sofa)
bic_full <- BIC(model_full)
bic_interaction <- BIC(model_interaction)

# 创建结果比较表格
results <- data.frame(
  Model = c("SOFA alone", "Full model (no interaction)", "Interaction model"),
  C_index = c(c_index_sofa, c_index_full, c_index_interaction),
  AIC = c(aic_sofa, aic_full, aic_interaction),
  BIC = c(bic_sofa, bic_full, bic_interaction)
)

# 打印结果
print(results)

# 交互项模型结果解读
summary(model_interaction)

# 提取交互项模型结果用于森林图
interaction_results <- data.frame(
  Variable = names(model_interaction$coefficients),
  HR = exp(model_interaction$coefficients),
  Lower = exp(confint(model_interaction))[, 1],
  Upper = exp(confint(model_interaction))[, 2],
  stringsAsFactors = FALSE
)

# 生成森林图 - 重点关注交互项
# 筛选交互项结果显示
interaction_terms <- interaction_results[grepl(":", interaction_results$Variable), ]

# # 生成交互项森林图
# forestplot(
#   labeltext = as.matrix(interaction_terms$Variable),
#   mean = interaction_terms$HR,
#   lower = interaction_terms$Lower,
#   upper = interaction_terms$Upper,
#   zero = 1,
#   xlog = TRUE,
#   col = fpColors(box = "darkred", line = "darkgrey"),
#   title = "Interaction Term Hazard Ratios"
# )

# 似然比检验比较模型
# 比较SOFA单独模型和完整模型
lr_test1 <- anova(model_sofa, model_full, test = "Chisq")
print("Likelihood ratio test: SOFA alone vs Full model")
print(lr_test1)

# 比较完整模型和交互项模型
lr_test2 <- anova(model_full, model_interaction, test = "Chisq")
print("Likelihood ratio test: Full model vs Interaction model")
print(lr_test2)











