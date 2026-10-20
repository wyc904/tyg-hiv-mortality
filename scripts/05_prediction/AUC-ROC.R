# 加载必要的包
library(pROC)    # 用于ROC分析和AUC计算
library(ggplot2)  # 用于绘图
library(caret)    # 用于模型评估
library(rms)      # 用于模型验证
library(lmtest)   # 用于模型比较

# 假设数据集名为df，包含以下变量：
# death_28：二分类变量（0=存活，1=死亡）
# CD4：连续变量
# TYG：连续变量
# TYGCD4：连续变量（建议标准化后使用）

# 1. 数据准备（标准化处理）
df$CD4_z <- scale(df$CD4)
df$TYG_z <- scale(df$TYG)
df$TYGCD4_z <- scale(df$TYGCD4)

# 2. 分别建立逻辑回归模型
model_cd4 <- glm(death_28 ~ CD4_z, 
                 data = df, family = binomial)
model_tyg <- glm(death_28 ~ TYG_z, 
                 data = df, family = binomial)
model_tygcd4 <- glm(death_28 ~ TYGCD4_z, 
                    data = df, family = binomial)

# 3. 计算并比较AUC
# 生成预测概率
df$prob_cd4 <- predict(model_cd4, type = "response")
df$prob_tyg <- predict(model_tyg, type = "response")
df$prob_tygcd4 <- predict(model_tygcd4, type = "response")

# 计算ROC曲线
roc_cd4 <- roc(death_28 ~ prob_cd4, data = df)
roc_tyg <- roc(death_28 ~ prob_tyg, data = df)
roc_tygcd4 <- roc(death_28 ~ prob_tygcd4, data = df)

# 比较AUC（DeLong检验）
roc_test1 <- roc.test(roc_cd4, roc_tyg)       # CD4 vs TYG
roc_test2 <- roc.test(roc_cd4, roc_tygcd4)    # CD4 vs TYGCD4
roc_test3 <- roc.test(roc_tyg, roc_tygcd4)    # TYG vs TYGCD4

# 4. 模型拟合优度比较（AIC）
aic_comp <- data.frame(
  Model = c("CD4", "TYG", "TYGCD4"),
  AIC = c(AIC(model_cd4), AIC(model_tyg), AIC(model_tygcd4))
)

# 5. 绘制ROC曲线
ggroc(list(CD4 = roc_cd4, TYG = roc_tyg, TYGCD4 = roc_tygcd4)) +
  geom_abline(intercept = 1, slope = 1, linetype = "dashed") +
  labs(title = "ROC曲线比较：CD4 vs TYG vs TYGCD4",
       color = "预测指标") +
  theme_minimal()

# 6. 校准曲线评估（使用rms包）
val_cd4 <- val.prob(df$prob_cd4, df$death_28) 
val_tyg <- val.prob(df$prob_tyg, df$death_28)
val_tygcd4 <- val.prob(df$prob_tygcd4, df$death_28)

# 7. 结果汇总
cat("AUC值比较：\n",
    "CD4: ", auc(roc_cd4), "\n",
    "TYG: ", auc(roc_tyg), "\n",
    "TYGCD4: ", auc(roc_tygcd4), "\n\n")

cat("AUC差异检验（DeLong test）：\n",
    "CD4 vs TYG: p=", roc_test1$p.value, "\n",
    "CD4 vs TYGCD4: p=", roc_test2$p.value, "\n",
    "TYG vs TYGCD4: p=", roc_test3$p.value, "\n\n")

print("AIC比较：")
print(aic_comp)

# 8. 高级分析：多变量模型（可选）
# 加入所有指标比较增量价值
full_model <- glm(death_28 ~ CD4_z + TYG_z + TYGCD4_z, 
                  data = df, family = binomial)
lrtest(model_cd4, full_model)  # 似然比检验