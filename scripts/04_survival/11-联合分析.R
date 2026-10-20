# 加载所需包
library(survival)
library(timeROC)  # 用于时间依赖性AUC计算
library(ggplot2)
library(survminer)
library(pROC)     # 用于ROC曲线绘制和比较

# 1. 模型拟合 ---------------------------------------------------------------
# 单指标模型 - TyG
model_TyG <- coxph(Surv(d28, D28) ~ TyG, data = hiv_pos)

# 单指标模型 - CD4
model_CD4 <- coxph(Surv(d28, D28) ~ CD4, data = hiv_pos)

# 双指标模型 (TyG + CD4)
model_full <- coxph(Surv(d28, D28) ~ TyG + CD4, data = hiv_pos)

# 2. 计算C指数 (等效AUC) ---------------------------------------------------
# 计算各模型的C指数
c_index_TyG <- summary(model_TyG)$concordance["C"]
c_index_CD4 <- summary(model_CD4)$concordance["C"]
c_index_full <- summary(model_full)$concordance["C"]

# 3. 计算时间依赖AUC (28天) ------------------------------------------------
# 计算28天时间依赖AUC
auc_TyG <- timeROC(
  T = hiv_pos$d28,
  delta = hiv_pos$D28,
  marker = predict(model_TyG),
  cause = 1,
  times = 28,
  iid = TRUE
)

auc_CD4 <- timeROC(
  T = hiv_pos$d28,
  delta = hiv_pos$D28,
  marker = predict(model_CD4),
  cause = 1,
  times = 28,
  iid = TRUE
)

auc_full <- timeROC(
  T = hiv_pos$d28,
  delta = hiv_pos$D28,
  marker = predict(model_full),
  cause = 1,
  times = 28,
  iid = TRUE
)

# 4. AUC统计比较 -----------------------------------------------------------
# 计算AUC提升百分比 (与各个单指标比较)
auc_improve_vs_TyG <- (auc_full$AUC[1] - auc_TyG$AUC[1]) / auc_TyG$AUC[1] * 100
auc_improve_vs_CD4 <- (auc_full$AUC[1] - auc_CD4$AUC[1]) / auc_CD4$AUC[1] * 100

# Delong检验比较模型间差异
delong_test_vs_TyG <- compare(auc_TyG, auc_full)
delong_p_vs_TyG <- delong_test_vs_TyG$p_value

delong_test_vs_CD4 <- compare(auc_CD4, auc_full)
delong_p_vs_CD4 <- delong_test_vs_CD4$p_value

# 5. 结果汇总 --------------------------------------------------------------
# 修正结果数据框创建
results <- data.frame(
  Model = c("TyG alone", "CD4 alone", "TyG + CD4"),
  C_index = c(c_index_TyG, c_index_CD4, c_index_full),
  AUC_28d = c(auc_TyG$AUC[1], auc_CD4$AUC[1], auc_full$AUC[1]),  # 更改为索引1
  AUC_95CI_lower = c(
    auc_TyG$AUC_CI[1, 1],  # 更改为矩阵索引方式
    auc_CD4$AUC_CI[1, 1],
    auc_full$AUC_CI[1, 1]
  ),
  AUC_95CI_upper = c(
    auc_TyG$AUC_CI[2, 1],  # 更改为矩阵索引方式
    auc_CD4$AUC_CI[2, 1],
    auc_full$AUC_CI[2, 1]
  )
)

# 打印统计结果
cat("### 模型性能比较结果 ###\n")
print(results)
cat(sprintf("\n联合模型相比TyG单独模型: AUC提升%.1f%% (P = %.4f)", 
            auc_improve_vs_TyG, delong_p_vs_TyG))
cat(sprintf("\n联合模型相比CD4单独模型: AUC提升%.1f%% (P = %.4f)", 
            auc_improve_vs_CD4, delong_p_vs_CD4))






library(nricens)

# 计算NRI
nribin(mdl.std = predict(model_CD4), 
       mdl.new = predict(model_full),
       event = hiv_pos$D28,
       cut = c(0.2, 0.5)) # 临床相关风险阈值


library(rmda)
decision_curve <- decision_curve(
  D28 ~ CD4, data = hiv_pos, 
  fitted.risk = TRUE,
  policy = "opt-in",
  thresholds = seq(0, 1, 0.01)
)















# 6. 可视化展示 -----------------------------------------------------------
## 6.1 模型AUC性能比较图
ggplot(results, aes(x = Model, y = AUC_28d, fill = Model)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_errorbar(
    aes(ymin = AUC_95CI_lower, ymax = AUC_95CI_upper),
    width = 0.2, color = "black"
  ) +
  geom_text(
    aes(label = sprintf("%.3f (%.3f-%.3f)", AUC_28d, AUC_95CI_lower, AUC_95CI_upper)),
    vjust = -1.5, size = 4
  ) +
  geom_segment(
    aes(x = 1, xend = 3, y = max(results$AUC_28d) + 0.02, yend = max(results$AUC_28d) + 0.02),
    linetype = "dashed"
  ) +
  geom_text(
    x = 2, y = max(results$AUC_28d) + 0.04,
    label = sprintf("vs TyG alone: +%.1f%%***", auc_improve_vs_TyG),
    color = "darkred", size = 5, fontface = "bold"
  ) +
  geom_segment(
    aes(x = 2, xend = 3, y = max(results$AUC_28d) + 0.06, yend = max(results$AUC_28d) + 0.06),
    linetype = "dashed"
  ) +
  geom_text(
    x = 2.5, y = max(results$AUC_28d) + 0.08,
    label = sprintf("vs CD4 alone: +%.1f%%***", auc_improve_vs_CD4),
    color = "darkred", size = 5, fontface = "bold"
  ) +
  labs(
    title = "联合模型显著提升28天死亡预测能力",
    subtitle = "TyG指数与CD4水平的联合预测模型",
    y = "28天AUC (95% CI)",
    x = NULL,
    caption = ifelse(delong_p_vs_TyG < 0.001 & delong_p_vs_CD4 < 0.001, 
                     "*** P < 0.001", 
                     paste("*** P < 0.001, ** P < 0.01"))
  ) +
  scale_fill_manual(values = c("#E15759", "#4E79A7", "#59A14F")) +  # 颜色区分单指标与联合模型
  scale_y_continuous(limits = c(0, 1.1), breaks = seq(0, 1, 0.1)) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(color = "gray40")
  )

## 6.2 ROC曲线比较图（28天）
# 准备ROC数据
roc_data <- data.frame(
  TyG_pred = predict(model_TyG),
  CD4_pred = predict(model_CD4),
  Full_pred = predict(model_full),
  D28 = hiv_pos$D28
)

# 绘制ROC曲线
roc_curve_TyG <- roc(response = roc_data$D28, predictor = roc_data$TyG_pred)
roc_curve_CD4 <- roc(response = roc_data$D28, predictor = roc_data$CD4_pred)
roc_curve_Full <- roc(response = roc_data$D28, predictor = roc_data$Full_pred)

# 创建ROC图
ggroc(list("TyG alone" = roc_curve_TyG, 
           "CD4 alone" = roc_curve_CD4, 
           "TyG + CD4" = roc_curve_Full),
      legacy.axes = TRUE) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray") +
  labs(
    title = "28天死亡预测ROC曲线比较",
    x = "1 - Specificity (假阳性率)",
    y = "Sensitivity (真阳性率)",
    color = "模型"
  ) +
  scale_color_manual(values = c("#E15759", "#4E79A7", "#59A14F")) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 18),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12)
  ) +
  annotate("text", x = 0.8, y = 0.25, 
           label = sprintf("TyG AUC = %.3f", auc_TyG$AUC[1]), color = "#E15759") +
  annotate("text", x = 0.8, y = 0.15, 
           label = sprintf("CD4 AUC = %.3f", auc_CD4$AUC[1]), color = "#4E79A7") +
  annotate("text", x = 0.8, y = 0.35, 
           label = sprintf("TyG+CD4 AUC = %.3f", auc_full$AUC[1]), color = "#59A14F")

# 7. 四分组风险组合分析 ----------------------------------------------------
# 添加风险分组 (基于您提供的拐点: TyG=9.22, CD4=50)
hiv_pos$risk_group <- with(
  hiv_pos,
  ifelse(
    TyG >= 9.22 & CD4 < 50, "TyG高/CD4低 (高危)",
    ifelse(
      TyG < 9.22 & CD4 >= 50, "TyG低/CD4高 (低危)",
      ifelse(
        TyG >= 9.22 & CD4 >= 50, "TyG高/CD4高 (中危)",
        "TyG低/CD4低 (中危)"
      )
    )
  )
)

# 确保顺序合理
hiv_pos$risk_group <- factor(
  hiv_pos$risk_group,
  levels = c(
    "TyG低/CD4高 (低危)", 
    "TyG低/CD4低 (中危)",
    "TyG高/CD4高 (中危)",
    "TyG高/CD4低 (高危)"
  )
)

# KM生存曲线比较
km_plot <- ggsurvplot(
  survfit(Surv(d28, D28) ~ risk_group, data = hiv_pos),
  data = hiv_pos,
  pval = TRUE,
  pval.coord = c(5, 0.1),
  risk.table = TRUE,
  risk.table.height = 0.25,
  palette = c("#59A14F", "#76B7B2", "#F28E2B", "#E15759"),  # 绿→蓝→黄→红
  title = "基于TyG和CD4的四分组生存分析",
  xlab = "天数",
  ylab = "生存概率",
  break.time.by = 7,
  legend.title = "风险分组",
  font.legend = 12,
  ggtheme = theme_minimal()
)

# 自定义KM图
km_plot$plot <- km_plot$plot +
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5),
    axis.title = element_text(size = 14),
    legend.position = "right",
    legend.text = element_text(size = 12)
  )

# 自定义风险表
km_plot$table <- km_plot$table +
  theme(
    axis.title = element_blank(),
    axis.text = element_text(size = 10)
  )

# 显示组合图
km_plot

# 8. 多变量Cox回归分析四分组风险 ------------------------------------------
# 将低危组设为参考
hiv_pos$risk_group_ref <- relevel(factor(hiv_pos$risk_group), ref = "TyG低/CD4高 (低危)")

# 调整其他协变量后的模型
model_risk_adjusted <- coxph(Surv(d28, D28) ~ risk_group_ref + age + gender + sofa,
                             data = hiv_pos)

# 森林图展示
ggforest(model_risk_adjusted, data = hiv_pos, 
         main = "四分组死亡风险的多变量分析",
         fontsize = 1.2)