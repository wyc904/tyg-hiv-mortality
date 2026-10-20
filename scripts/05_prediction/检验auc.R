# 加载必要的包
library(pROC)    # 用于ROC分析和AUC计算
library(gtsummary) # 用于制作专业表格
library(rms)      # 用于模型验证
library(lmtest)   # 用于模型比较
library(readxl)
library(knitr)      # kable
library(kableExtra) # kable_styling


# 读取Excel文件
df <- read_excel("1300-hiv.xlsx")


# 确保所有预测变量都是因子类型（分类变量）
df$CD4 <- as.factor(df$CD4)
df$TyG <- as.factor(df$TyG)
df$TYGCD4 <- as.factor(df$TYGCD4)

# 1. 单变量逻辑回归分析
uni_models <- list(
  CD4 = glm(D28 ~ CD4, data = df, family = binomial),
  TYG = glm(D28 ~ TyG, data = df, family = binomial),
  TYGCD4 = glm(D28 ~ TYGCD4, data = df, family = binomial)
)

# 2. 计算AUC值
auc_values <- c(
  CD4 = auc(roc(df$D28, predict(uni_models$CD4, type = "response"))),
  TyG = auc(roc(df$D28, predict(uni_models$TyG, type = "response"))),
  TYGCD4 = auc(roc(df$D28, predict(uni_models$TYGCD4, type = "response")))
)

# 3. 模型比较统计量
model_comparison <- lapply(uni_models, function(model) {
  data.frame(
    AIC = AIC(model),
    BIC = BIC(model),
    LogLik = logLik(model)[1]
  )
})

# 4. 创建综合结果表格
# 4.1 创建单变量模型OR表格
or_table <- tbl_uvregression(
  list(uni_models$CD4, uni_models$TYG, uni_models$TYGCD4),
  label = list(CD4 ~ "CD4", TYG ~ "TYG", TYGCD4 ~ "TYGCD4"),
  exponentiate = TRUE,
  show_yesno = FALSE
) %>%
  modify_caption("**表 1. 单变量逻辑回归分析结果(OR与95%CI)**")

# 4.2 创建模型性能比较表
perf_table <- data.frame(
  Model = c("CD4", "TYG", "TYGCD4"),
  AUC = round(auc_values, 3),
  AIC = sapply(model_comparison, function(x) round(x$AIC, 1)),
  BIC = sapply(model_comparison, function(x) round(x$BIC, 1))
)

# 5. 多变量模型比较（TYGCD4 vs CD4+TYG组合）
# 组合模型
combo_model <- glm(D28 ~ CD4 + TYG, data = df, family = binomial)
tygcd4_full <- glm(D28 ~ TYGCD4, data = df, family = binomial)

# 比较模型拟合优度
model_comp <- lrtest(combo_model, tygcd4_full)

# 创建模型比较表
comp_table <- data.frame(
  比较 = c("CD4+TYG组合 vs TYGCD4"),
  卡方 = round(model_comp$Chisq[2], 2),
  自由度 = model_comp$Df[2],
  P值 = ifelse(model_comp$`Pr(>Chisq)`[2] < 0.001, "<0.001", 
              round(model_comp$`Pr(>Chisq)`[2], 3))
)

# 6. 打印所有表格
# 6.1 单变量OR表
print(or_table)

# 6.2 模型性能表
cat("\n\n")
kable(perf_table, caption = "表 2. 模型性能比较", align = 'c') %>%
  kable_styling(bootstrap_options = "striped", full_width = FALSE)

# 6.3 模型比较表
cat("\n\n")
kable(comp_table, caption = "表 3. 多变量模型比较(似然比检验)", align = 'c') %>%
  kable_styling(bootstrap_options = "striped", full_width = FALSE)

# 7. 结果解释说明
cat("\n\n结果解释指南：
1. 表1展示了每个分类变量不同水平相对于参考水平的死亡风险比(OR)及其置信区间
2. 表2展示了各模型的预测性能：AUC >0.7表示良好区分能力，>0.8为优秀
3. 表3比较了组合模型与单一指标的拟合优度：
   - 显著P值(P<0.05)表示组合模型显著优于单一指标
   - 不显著P值表示单一指标可替代组合模型
")