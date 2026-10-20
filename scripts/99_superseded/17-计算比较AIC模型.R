# 加载必要的包
library(readxl)
library(pROC)
library(ResourceSelection)
library(DescTools)
library(writexl)
library(dplyr)
library(openxlsx)

# 读取数据
data <- read_excel("tyg-1300-hiv.xlsx")

# 检查变量命名一致性
if (!("D28" %in% names(data))) stop("缺少变量：D28")
if (!("TYG" %in% names(data))) stop("缺少变量：TYG")
if (!("CD4" %in% names(data))) stop("缺少变量：CD4")
if (!("TYGCD4" %in% names(data))) {
  # 自动创建联合变量（如未提供）
  data$TYGCD4 <- interaction(data$TYG, data$CD4, drop = TRUE)
}


# 
# +  age + gender + Diabetes + Hypertension +
#   CKD + LiverCirrhosis + CHD + COPD + HF + sofa + ART +
#   Talaromycosis + PCP + Cryptococcosis + Candidiasis


# 建立模型
model_TYG <- glm(D28 ~ TYG +  sofa
                 ,
                 data = data, family = binomial())

model_CD4 <- glm(D28 ~ CD4+ sofa
                 ,
                 data = data, family = binomial())

model_joint <- glm(D28 ~ TYGCD4+  sofa
                   ,
                   data = data, family = binomial())

# 通用模型指标函数
calculate_model_metrics <- function(model, data, outcome_var = "D28") {
  tryCatch({
    pred_prob <- predict(model, type = "response")
    outcome <- data[[outcome_var]]
    
    # ROC和AUC
    roc_obj <- suppressMessages(roc(outcome, pred_prob))
    auc_ci <- ci.auc(roc_obj)
    
    # Brier Score
    brier_score <- mean((outcome - pred_prob)^2)
    
    # HL检验
    hl <- hoslem.test(outcome, pred_prob, g = 10)
    
    return(list(
      auc = auc(roc_obj),
      auc_ci = auc_ci,
      brier = brier_score,
      hl = hl$statistic,
      hl_p = hl$p.value,
      aic = AIC(model),
      bic = BIC(model)
    ))
  }, error = function(e) {
    message("模型指标计算失败：", conditionMessage(e))
    return(list(
      auc = NA,
      auc_ci = c(NA, NA, NA),
      brier = NA,
      hl = NA,
      hl_p = NA,
      aic = NA,
      bic = NA
    ))
  })
}

metrics_TYG   <- calculate_model_metrics(model_TYG, data)
metrics_CD4   <- calculate_model_metrics(model_CD4, data)
metrics_joint <- calculate_model_metrics(model_joint, data)

# 模型比较函数（DeLong）
compare_models <- function(model1, model2, data, outcome_var = "D28") {
  tryCatch({
    pred1 <- predict(model1, newdata = data, type = "response")
    pred2 <- predict(model2, newdata = data, type = "response")
    outcome <- data[[outcome_var]]
    
    roc1 <- roc(outcome, pred1)
    roc2 <- roc(outcome, pred2)
    auc_test <- roc.test(roc1, roc2, method = "delong")
    
    return(list(
      auc_diff = as.numeric(auc_test$estimate[2] - auc_test$estimate[1]),
      auc_ci = as.numeric(auc_test$conf.int[1:2]),
      auc_p = auc_test$p.value,
      aic_diff = AIC(model1) - AIC(model2),
      lr_p = anova(model1, model2, test = "Chisq")$`Pr(>Chi)`[2]
    ))
  }, error = function(e) {
    message("模型比较失败：", conditionMessage(e))
    return(list(
      auc_diff = NA,
      auc_ci = c(NA, NA),
      auc_p = NA,
      aic_diff = NA,
      lr_p = NA
    ))
  })
}

compare_TYG_joint  <- compare_models(model_TYG, model_joint, data)
compare_CD4_joint  <- compare_models(model_CD4, model_joint, data)

# 结果表格构建
fmt_auc <- function(x) {
  if (any(is.na(x$auc_ci))) return("NA")
  sprintf("%.3f (%.3f-%.3f)", x$auc, x$auc_ci[1], x$auc_ci[3])
}
fmt_hl <- function(x) {
  if (is.na(x$hl)) return("NA")
  sprintf("%.1f (p = %.3f)", x$hl, x$hl_p)
}

results_table <- data.frame(
  性能指标 = c("拟合优度", "AIC", "BIC", "", "判别能力", "AUC (95% CI)", "Brier评分", "", "校准精度", "Hosmer-Lemeshow χ²"),
  `TYG单独模型` = c("", round(metrics_TYG$aic, 1), round(metrics_TYG$bic, 1), "", "", fmt_auc(metrics_TYG),
                round(metrics_TYG$brier, 3), "", "", fmt_hl(metrics_TYG)),
  `CD4单独模型` = c("", round(metrics_CD4$aic, 1), round(metrics_CD4$bic, 1), "", "", fmt_auc(metrics_CD4),
                round(metrics_CD4$brier, 3), "", "", fmt_hl(metrics_CD4)),
  `联合分层模型` = c("", round(metrics_joint$aic, 1), round(metrics_joint$bic, 1), "", "", fmt_auc(metrics_joint),
               round(metrics_joint$brier, 3), "", "", fmt_hl(metrics_joint)),
  `联合模型 vs TYG模型` = c("", round(compare_TYG_joint$aic_diff, 1), "", "", "", 
                      ifelse(is.na(compare_TYG_joint$auc_diff), "NA",
                             sprintf("Δ = %.3f (%.3f–%.3f)", compare_TYG_joint$auc_diff, 
                                     compare_TYG_joint$auc_ci[1], compare_TYG_joint$auc_ci[2])),
                      "", "", "", ""),
  `联合模型 vs CD4模型` = c("", round(compare_CD4_joint$aic_diff, 1), "", "", "", 
                      ifelse(is.na(compare_CD4_joint$auc_diff), "NA",
                             sprintf("Δ = %.3f (%.3f–%.3f)", compare_CD4_joint$auc_diff, 
                                     compare_CD4_joint$auc_ci[1], compare_CD4_joint$auc_ci[2])),
                      "", "", "", "")
)

# 设置工作簿
wb <- createWorkbook()
addWorksheet(wb, "Model Comparison")

writeData(wb, "Model Comparison", "Table 1. 预测模型性能比较：单独变量模型 vs 联合分层模型", startRow = 1)
writeData(wb, "Model Comparison", results_table, startRow = 3, headerStyle = createStyle(textDecoration = "bold"))

mergeCells(wb, "Model Comparison", cols = 1:6, rows = 1:2)

addStyle(wb, "Model Comparison", createStyle(textDecoration = "bold", fontSize = 14, halign = "center"), rows = 1, cols = 1)
addStyle(wb, "Model Comparison", createStyle(textDecoration = "bold", halign = "center", border = "Bottom"), rows = 3, cols = 1:6)
addStyle(wb, "Model Comparison", createStyle(halign = "center"), rows = 4:(nrow(results_table)+3), cols = 2:6, gridExpand = TRUE)

setColWidths(wb, "Model Comparison", cols = 1, widths = 22)
setColWidths(wb, "Model Comparison", cols = 2:6, widths = 18)

# 添加脚注
footnote_start <- nrow(results_table) + 5
notes <- data.frame(Note = c(
  "Abbreviations: AIC, Akaike information criterion; AUC, area under the ROC curve; BIC, Bayesian information criterion; CI, confidence interval; HL, Hosmer-Lemeshow.",
  "a Data are presented as point estimate (95% CI) unless otherwise indicated.",
  "b AUC differences calculated using DeLong’s method.",
  "c AIC differences represent reduction in joint model relative to comparator model.",
  "d Hosmer–Lemeshow test for model calibration.",
  "* P < 0.05; ** P < 0.01; *** P < 0.001"
))
writeData(wb, "Model Comparison", "Notes:", startRow = footnote_start)
writeData(wb, "Model Comparison", notes, startRow = footnote_start + 1, colNames = FALSE)

# 保存文件
saveWorkbook(wb, "JAMA_Model_Comparison_Table.xlsx", overwrite = TRUE)

# 打印模型信息
cat("JAMA格式表格已成功导出至 'JAMA_Model_Comparison_Table.xlsx'\n")
cat("模型信息:\n")
cat("1. TYG单独模型 AIC:", metrics_TYG$aic, "\n")
cat("2. CD4单独模型 AIC:", metrics_CD4$aic, "\n")
cat("3. 联合模型 AIC:", metrics_joint$aic, "\n")
cat("AUC比较结果:\n")
cat("- 联合模型 vs TYG模型 ΔAUC:", compare_TYG_joint$auc_diff, 
    "(95% CI:", compare_TYG_joint$auc_ci[1], "-", compare_TYG_joint$auc_ci[2], ")\n")
cat("- 联合模型 vs CD4模型 ΔAUC:", compare_CD4_joint$auc_diff, 
    "(95% CI:", compare_CD4_joint$auc_ci[1], "-", compare_CD4_joint$auc_ci[2], ")\n")
