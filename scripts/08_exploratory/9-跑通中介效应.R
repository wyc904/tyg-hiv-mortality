
library(mediation)









# , "ICU", "MainInfectionSite", 
# "SepticShock", "CKD", "LiverCirrhosis", "COPD", "HF",
# "Diabetes", "Hypertension", "CHD", "sofa", "Heparin", 
# "Vasopressor", "Glucocorticoid", "IMV", "CRRT", "TBIL", 
# "Cr", "PLT", "LYM", "WBC", "UREA", "MONO", "LDH", "CRP", 
# "ALB", "AST"
# # -------------------------------
# Step 1: 中介模型（TyG_index ~ CD41 + 协变量）
# -------------------------------
covariates <- c("性别10", "就诊年龄", "ART")

# 构造协变量公式
cov_formula <- paste(covariates, collapse = " + ")

# 中介模型
med_model <- lm(as.formula(paste("CD41 ~ TyG_index +", cov_formula)), data =data)

# -------------------------------
# Step 2: 结局模型（D28 ~ CD41 + TyG_index + 协变量）
# -------------------------------
out_model <- glm(
  as.formula(paste("D28 ~ CD41 + TyG_index +", cov_formula)),
  family = binomial,
  data = data
)

# -------------------------------
# Step 3: 中介分析
# -------------------------------
med_result <- mediate(
  model.m = med_model,
  model.y = out_model,
  treat = "TyG_index",
  mediator = "CD41",
  boot = TRUE,
  sims = 1000
)

# -------------------------------
# Step 4: 输出结果
# -------------------------------
summary(med_result)







# 1. 验证数据质量
table(data$D28)  # 检查D28的分布（是否极端不平衡？）

# 2. 简化模型诊断
simple_model <- glm(D28 ~ CD41, 
                    family = binomial, 
                    data = data)
summary(simple_model)  # 检查CD41单独是否有效

# 3. 检查中介变量关联性
cor.test(data$CD41, data$TyG_index)  # CD41与中介变量相关性
glm(D28 ~ TyG_index, data = data)          # 中介变量与D28关联性















