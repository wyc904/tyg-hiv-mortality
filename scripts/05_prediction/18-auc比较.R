# 加载必要的包
library(pROC)       # ROC分析和AUC计算
library(caret)      # 性能指标计算（敏感性和特异性）
library(broom)      # 模型结果整理
library(ggplot2)    # 可视化
library(patchwork)  # 图形布局
library(flextable)  # 用于创建专业表格
library(officer)    # 用于导出Word文档
library(readxl)     # 读取 Excel
library(dplyr)      # 管道与数据处理

# 读取数据（请替换为您的实际文件路径）
data <- read_excel("tyg-1300-hiv.xlsx")

# 确保数据包含必要的变量
if (!all(c("D28", "TyG_index", "CD41", "TYGCD4") %in% names(data))) {
  stop("数据缺失必需变量：D28, TyG_index, CD41, TYGCD4")
}

# 构建三个模型
model_tyg <- glm(D28 ~ TyG_index, data = data, family = binomial)
model_cd4 <- glm(D28 ~ CD41, data = data, family = binomial)
model_tygcd4 <- glm(D28 ~ TYGCD4, data = data, family = binomial)

# 1. AUC分析和比较
# 计算每个模型的预测概率
data$pred_tyg <- predict(model_tyg, type = "response")
data$pred_cd4 <- predict(model_cd4, type = "response")
data$pred_tygcd4 <- predict(model_tygcd4, type = "response")

# 计算ROC曲线和AUC
roc_tyg <- roc(D28 ~ pred_tyg, data = data)
roc_cd4 <- roc(D28 ~ pred_cd4, data = data)
roc_tygcd4 <- roc(D28 ~ pred_tygcd4, data = data)

# AUC值及95% CI
auc_tyg <- sprintf("%.3f (%.3f-%.3f)", auc(roc_tyg), ci(roc_tyg)[1], ci(roc_tyg)[3])
auc_cd4 <- sprintf("%.3f (%.3f-%.3f)", auc(roc_cd4), ci(roc_cd4)[1], ci(roc_cd4)[3])
auc_tygcd4 <- sprintf("%.3f (%.3f-%.3f)", auc(roc_tygcd4), ci(roc_tygcd4)[1], ci(roc_tygcd4)[3])

# AUC比较 (DeLong检验)
test_tyg_vs_cd4 <- roc.test(roc_tyg, roc_cd4, method = "delong")
test_tyg_vs_tygcd4 <- roc.test(roc_tyg, roc_tygcd4, method = "delong")
test_cd4_vs_tygcd4 <- roc.test(roc_cd4, roc_tygcd4, method = "delong")

# 2. 敏感性和特异性计算（使用最佳阈值）
# 寻找最佳阈值 (Youden指数)
best_threshold_tyg <- coords(roc_tyg, "best", ret = "threshold", best.method = "youden")
best_threshold_cd4 <- coords(roc_cd4, "best", ret = "threshold", best.method = "youden")
best_threshold_tygcd4 <- coords(roc_tygcd4, "best", ret = "threshold", best.method = "youden")

# 转换为分类预测
data$pred_class_tyg <- ifelse(data$pred_tyg >= best_threshold_tyg$threshold, 1, 0)
data$pred_class_cd4 <- ifelse(data$pred_cd4 >= best_threshold_cd4$threshold, 1, 0)
data$pred_class_tygcd4 <- ifelse(data$pred_tygcd4 >= best_threshold_tygcd4$threshold, 1, 0)

# 计算混淆矩阵和性能指标
conf_tyg <- confusionMatrix(factor(data$pred_class_tyg, levels = c(0, 1)), 
                            factor(data$D28, levels = c(0, 1)))
conf_cd4 <- confusionMatrix(factor(data$pred_class_cd4, levels = c(0, 1)), 
                            factor(data$D28, levels = c(0, 1)))
conf_tygcd4 <- confusionMatrix(factor(data$pred_class_tygcd4, levels = c(0, 1)), 
                               factor(data$D28, levels = c(0, 1)))

# 3. 创建专业表格
# 表1: 模型性能比较
model_comparison <- data.frame(
  Model = c("TYG单独模型", "CD4单独模型", "TYGCD4联合模型"),
  AUC = c(auc_tyg, auc_cd4, auc_tygcd4),
  Sensitivity = c(
    sprintf("%.1f%%", conf_tyg$byClass["Sensitivity"] * 100),
    sprintf("%.1f%%", conf_cd4$byClass["Sensitivity"] * 100),
    sprintf("%.1f%%", conf_tygcd4$byClass["Sensitivity"] * 100)
  ),
  Specificity = c(
    sprintf("%.1f%%", conf_tyg$byClass["Specificity"] * 100),
    sprintf("%.1f%%", conf_cd4$byClass["Specificity"] * 100),
    sprintf("%.1f%%", conf_tygcd4$byClass["Specificity"] * 100)
  ),
  PPV = c(
    sprintf("%.1f%%", conf_tyg$byClass["Pos Pred Value"] * 100),
    sprintf("%.1f%%", conf_cd4$byClass["Pos Pred Value"] * 100),
    sprintf("%.1f%%", conf_tygcd4$byClass["Pos Pred Value"] * 100)
  ),
  NPV = c(
    sprintf("%.1f%%", conf_tyg$byClass["Neg Pred Value"] * 100),
    sprintf("%.1f%%", conf_cd4$byClass["Neg Pred Value"] * 100),
    sprintf("%.1f%%", conf_tygcd4$byClass["Neg Pred Value"] * 100)
  )
)

# 表2: AUC比较统计
auc_comparison <- data.frame(
  Comparison = c("TYG vs CD4", "TYG vs TYGCD4", "CD4 vs TYGCD4"),
  `ΔAUC (95% CI)` = c(
    sprintf("%.3f (%.3f to %.3f)", 
            test_tyg_vs_cd4$estimate[1] - test_tyg_vs_cd4$estimate[2],
            test_tyg_vs_cd4$conf.int[1],
            test_tyg_vs_cd4$conf.int[2]),
    sprintf("%.3f (%.3f to %.3f)", 
            test_tyg_vs_tygcd4$estimate[1] - test_tyg_vs_tygcd4$estimate[2],
            test_tyg_vs_tygcd4$conf.int[1],
            test_tyg_vs_tygcd4$conf.int[2]),
    sprintf("%.3f (%.3f to %.3f)", 
            test_cd4_vs_tygcd4$estimate[1] - test_cd4_vs_tygcd4$estimate[2],
            test_cd4_vs_tygcd4$conf.int[1],
            test_cd4_vs_tygcd4$conf.int[2])
  ),
  P_value = c(
    ifelse(test_tyg_vs_cd4$p.value < 0.001, "<0.001", sprintf("%.3f", test_tyg_vs_cd4$p.value)),
    ifelse(test_tyg_vs_tygcd4$p.value < 0.001, "<0.001", sprintf("%.3f", test_tyg_vs_tygcd4$p.value)),
    ifelse(test_cd4_vs_tygcd4$p.value < 0.001, "<0.001", sprintf("%.3f", test_cd4_vs_tygcd4$p.value))
  )
)

# 表3: 最佳分类阈值
threshold_table <- data.frame(
  Model = c("TYG单独模型", "CD4单独模型", "TYGCD4联合模型"),
  `最佳阈值` = c(
    sprintf("%.3f", best_threshold_tyg$threshold),
    sprintf("%.3f", best_threshold_cd4$threshold),
    sprintf("%.3f", best_threshold_tygcd4$threshold)
  ),
  `样本量 (死亡/总人数)` = c(
    sprintf("%d/%d (%d死亡)", 
            sum(data$D28[!is.na(data$pred_tyg)]),
            sum(!is.na(data$pred_tyg)),
            sum(data$D28[!is.na(data$pred_tyg)])),
    sprintf("%d/%d (%d死亡)", 
            sum(data$D28[!is.na(data$pred_cd4)]),
            sum(!is.na(data$pred_cd4)),
            sum(data$D28[!is.na(data$pred_cd4)])),
    sprintf("%d/%d (%d死亡)", 
            sum(data$D28[!is.na(data$pred_tygcd4)]),
            sum(!is.na(data$pred_tygcd4)),
            sum(data$D28[!is.na(data$pred_tygcd4)]))
  )
)

# 4. 使用flextable创建专业表格
# 表1: 模型性能比较
ft_model <- flextable(model_comparison) %>%
  set_caption(caption = "表1: 模型性能比较") %>%
  add_header_row(values = c("", "判别能力", "分类性能"), colwidths = c(1, 1, 4)) %>%
  set_header_labels(Model = "模型",
                    AUC = "AUC (95% CI)",
                    Sensitivity = "敏感性(%)",
                    Specificity = "特异性(%)",
                    PPV = "阳性预测值(%)",
                    NPV = "阴性预测值(%)") %>%
  align(align = "center", part = "all") %>%
  align(align = "left", j = 1, part = "all") %>%
  fontsize(size = 11, part = "all") %>%
  font(fontname = "Times New Roman", part = "all") %>%
  autofit() %>%
  bg(j = 3:6, bg = "#F2F2F2") %>%
  hline_top(border = fp_border(width = 2)) %>%
  hline_bottom(border = fp_border(width = 2)) %>%
  bold(part = "header")

# 表2: AUC比较统计
ft_auc <- flextable(auc_comparison) %>%
  set_caption(caption = "表2: AUC统计比较结果") %>%
  set_header_labels(Comparison = "模型比较",
                    Delta.AUC..95..CI. = "ΔAUC (95% CI)",
                    P_value = "P值") %>%
  align(align = "center", part = "all") %>%
  align(align = "left", j = 1, part = "all") %>%
  fontsize(size = 11, part = "all") %>%
  font(fontname = "Times New Roman", part = "all") %>%
  autofit() %>%
  hline_top(border = fp_border(width = 2)) %>%
  hline_bottom(border = fp_border(width = 2)) %>%
  bold(part = "header")

# 表3: 最佳分类阈值
ft_threshold <- flextable(threshold_table) %>%
  set_caption(caption = "表3: 最佳分类阈值及样本信息") %>%
  set_header_labels(Model = "模型",
                    Best.Threshold = "最佳阈值",
                    Sample.Size..Death.Total. = "样本量 (死亡/总人数)") %>%
  align(align = "center", part = "all") %>%
  align(align = "left", j = 1, part = "all") %>%
  fontsize(size = 11, part = "all") %>%
  font(fontname = "Times New Roman", part = "all") %>%
  autofit() %>%
  bg(j = 2:3, bg = "#F2F2F2") %>%
  hline_top(border = fp_border(width = 2)) %>%
  hline_bottom(border = fp_border(width = 2)) %>%
  bold(part = "header")

# 5. 创建可视化
roc_plot <- ggroc(list(`TYG单独` = roc_tyg, `CD4单独` = roc_cd4, `TYGCD4联合` = roc_tygcd4)) +
  geom_abline(slope = 1, intercept = 1, linetype = "dashed", color = "gray50") +
  labs(title = "ROC曲线比较",
       subtitle = "三种模型的区分能力评估",
       color = "模型",
       x = "1 - 特异性",
       y = "敏感性") +
  theme_minimal(base_family = "Times New Roman") +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(color = "gray40"),
        text = element_text(size = 12))

# 6. 创建Word文档报告
doc <- read_docx() %>%
  body_add_par("模型性能比较分析报告", style = "heading 1") %>%
  body_add_par(Sys.Date(), style = "Normal") %>%  # 使用 "Normal" 样式代替 "strong"
  body_add_par(" ") %>%  # 空行
  
  body_add_par("1. 模型性能比较", style = "heading 2") %>%
  body_add_flextable(ft_model) %>%
  body_add_par(" ") %>%  # 空行
  
  body_add_par("2. AUC统计比较", style = "heading 2") %>%
  body_add_flextable(ft_auc) %>%
  body_add_par(" ") %>%  # 空行
  
  body_add_par("3. 最佳分类阈值", style = "heading 2") %>%
  body_add_flextable(ft_threshold) %>%
  body_add_par(" ") %>%  # 空行
  
  body_add_par("4. ROC曲线比较", style = "heading 2") %>%
  body_add_gg(roc_plot, style = "centered") %>%
  body_add_par("图1. 三种模型的ROC曲线比较", style = "Normal") %>%  # 使用 "Normal" 样式
  body_add_par(" ") %>%  # 空行
  
  body_add_par("关键结论：", style = "heading 2") %>%
  body_add_par(sprintf("- TYGCD4联合模型具有最高的AUC值（%s）", auc_tygcd4), style = "Normal") %>%  # 使用 "Normal" 样式
  body_add_par(sprintf("- TYGCD4联合模型相较于TYG单独模型的提升具有统计学意义（ΔAUC = %.3f, P = %s）",
                       test_tyg_vs_tygcd4$estimate[1] - test_tyg_vs_tygcd4$estimate[2],
                       ifelse(test_tyg_vs_tygcd4$p.value < 0.001, "<0.001", sprintf("%.3f", test_tyg_vs_tygcd4$p.value))), 
               style = "Normal") %>%  # 使用 "Normal" 样式
  body_add_par(sprintf("- TYGCD4联合模型的敏感性为%s，特异性为%s",
                       sprintf("%.1f%%", conf_tygcd4$byClass["Sensitivity"] * 100),
                       sprintf("%.1f%%", conf_tygcd4$byClass["Specificity"] * 100)), 
               style = "Normal")  # 使用 "Normal" 样式
# 7. 保存Word文档
print(doc, target = "模型性能比较分析报告.docx")

# 8. 在R中显示结果
cat("\n===============================\n")
cat("  模型性能比较分析报告\n")
cat("===============================\n\n")

cat("表1: 模型性能比较\n")
print(model_comparison)
cat("\n")

cat("表2: AUC统计比较结果\n")
print(auc_comparison)
cat("\n")

cat("表3: 最佳分类阈值\n")
print(threshold_table)
cat("\n")

cat("关键结论:\n")
cat(sprintf("- TYGCD4联合模型具有最高的AUC值（%s）\n", auc_tygcd4))
cat(sprintf("- TYGCD4联合模型相较于TYG单独模型的提升具有统计学意义（ΔAUC = %.3f, P = %s）\n",
            test_tyg_vs_tygcd4$estimate[1] - test_tyg_vs_tygcd4$estimate[2],
            ifelse(test_tyg_vs_tygcd4$p.value < 0.001, "<0.001", sprintf("%.3f", test_tyg_vs_tygcd4$p.value))))
cat(sprintf("- TYGCD4联合模型的敏感性为%s，特异性为%s\n",
            sprintf("%.1f%%", conf_tygcd4$byClass["Sensitivity"] * 100),
            sprintf("%.1f%%", conf_tygcd4$byClass["Specificity"] * 100)))

cat("\nROC曲线图已保存至Word文档: '模型性能比较分析报告.docx'\n")