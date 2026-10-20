# 修改后的完整代码（特别修复了HL检验自由度处理）

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
  data$TYGCD4 <- interaction(data$TYG, data$CD4, drop = TRUE)
}

# 建立模型
model_TYG <- glm(D28 ~ TYG + sofa, data = data, family = binomial())
model_CD4 <- glm(D28 ~ CD4 + sofa, data = data, family = binomial())
model_joint <- glm(D28 ~ TYGCD4 + sofa, data = data, family = binomial())

# 修改后的模型指标函数（修复自由度提取问题）
calculate_model_metrics <- function(model, data, outcome_var = "D28") {
  tryCatch({
    pred_prob <- predict(model, type = "response")
    outcome <- data[[outcome_var]]
    
    # ROC和AUC
    roc_obj <- suppressMessages(roc(outcome, pred_prob))
    auc_ci <- ci.auc(roc_obj)
    
    # Brier Score
    brier_score <- mean((outcome - pred_prob)^2)
    
    # HL检验 (稳定版本)
    hl <- hoslem.test(outcome, pred_prob, g = 10)
    
    # 提取自由度：使用$parameter避免属性访问问题
    hl_df <- tryCatch({
      hl$parameter[["df"]]  # 直接访问列表元素
    }, error = function(e) {
      # 固定为10组-2=8自由度
      message("HL自由度自动设为8")
      8
    })
    
    return(list(
      auc = auc(roc_obj),
      auc_ci = auc_ci,
      brier = brier_score,
      hl_stat = hl$statistic,
      hl_df = hl_df,
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
      hl_stat = NA,
      hl_df = NA,
      hl_p = NA,
      aic = NA,
      bic = NA
    ))
  })
}

# 计算每个模型的指标
metrics_TYG   <- calculate_model_metrics(model_TYG, data)
metrics_CD4   <- calculate_model_metrics(model_CD4, data)
metrics_joint <- calculate_model_metrics(model_joint, data)

# 模型比较函数 (不变)
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

# 修改后的格式化函数 (修复参数长度错误)
fmt_hl <- function(x) {
  if (is.null(x$hl_stat) || length(x$hl_stat) == 0) return("NA")
  if (is.na(x$hl_stat)) return("NA")
  sprintf("%.1f", x$hl_stat)
}

fmt_hl_df <- function(x) {
  # 处理NULL或空值情况
  if (is.null(x$hl_df) || length(x$hl_df) == 0) {
    return("8*")  # 默认HL检验自由度
  }
  if (is.na(x$hl_df)) return("8*")
  as.character(x$hl_df)
}

fmt_hl_p <- function(x) {
  if (is.null(x$hl_p) || length(x$hl_p) == 0) return("NA")
  if (is.na(x$hl_p)) return("NA")
  ifelse(x$hl_p < 0.001, "<0.001", sprintf("%.3f", x$hl_p))
}

fmt_auc <- function(x) {
  if (any(is.na(x$auc_ci))) return("NA")
  sprintf("%.3f (%.3f-%.3f)", x$auc, x$auc_ci[1], x$auc_ci[3])
}

fmt_pval <- function(p) {
  if (is.null(p) || length(p) == 0 || is.na(p)) return("NA")
  ifelse(p < 0.001, "<0.001", sprintf("%.3f", p))
}

# 结果表格构建
results_table <- data.frame(
  性能指标 = c(
    "拟合优度",
    "AIC",
    "BIC",
    "",
    "判别能力",
    "AUC (95% CI)",
    "Brier评分",
    "",
    "校准精度",
    "Hosmer-Lemeshow χ²",
    "  df",    
    "  P-value" 
  ),
  
  `TYG单独模型` = c(
    "",
    sprintf("%.1f", metrics_TYG$aic),
    sprintf("%.1f", metrics_TYG$bic),
    "",
    "",
    fmt_auc(metrics_TYG),
    sprintf("%.3f", metrics_TYG$brier),
    "",
    "",
    fmt_hl(metrics_TYG),
    fmt_hl_df(metrics_TYG),
    fmt_hl_p(metrics_TYG)
  ),
  
  `CD4单独模型` = c(
    "",
    sprintf("%.1f", metrics_CD4$aic),
    sprintf("%.1f", metrics_CD4$bic),
    "",
    "",
    fmt_auc(metrics_CD4),
    sprintf("%.3f", metrics_CD4$brier),
    "",
    "",
    fmt_hl(metrics_CD4),
    fmt_hl_df(metrics_CD4),
    fmt_hl_p(metrics_CD4)
  ),
  
  `联合分层模型` = c(
    "",
    sprintf("%.1f", metrics_joint$aic),
    sprintf("%.1f", metrics_joint$bic),
    "",
    "",
    fmt_auc(metrics_joint),
    sprintf("%.3f", metrics_joint$brier),
    "",
    "",
    fmt_hl(metrics_joint),
    fmt_hl_df(metrics_joint),
    fmt_hl_p(metrics_joint)
  ),
  
  `联合模型 vs TYG模型` = c(
    "",
    sprintf("%.1f", compare_TYG_joint$aic_diff),
    "",
    "",
    "",
    ifelse(is.na(compare_TYG_joint$auc_diff), "NA",
           sprintf("Δ = %.3f (%.3f–%.3f)", 
                   compare_TYG_joint$auc_diff, 
                   compare_TYG_joint$auc_ci[1], 
                   compare_TYG_joint$auc_ci[2])),
    "",
    "",
    "",
    "", "", ""  # 占位符
  ),
  
  `联合模型 vs CD4模型` = c(
    "",
    sprintf("%.1f", compare_CD4_joint$aic_diff),
    "",
    "",
    "",
    ifelse(is.na(compare_CD4_joint$auc_diff), "NA",
           sprintf("Δ = %.3f (%.3f–%.3f)", 
                   compare_CD4_joint$auc_diff, 
                   compare_CD4_joint$auc_ci[1], 
                   compare_CD4_joint$auc_ci[2])),
    "",
    "",
    "",
    "", "", ""  # 占位符
  )
)

# 设置工作簿
wb <- createWorkbook()
addWorksheet(wb, "Model Comparison")

writeData(wb, "Model Comparison", "Table 1. 预测模型性能比较：单独变量模型 vs 联合分层模型", startRow = 1)
writeData(wb, "Model Comparison", results_table, startRow = 3, headerStyle = createStyle(textDecoration = "bold"))

mergeCells(wb, "Model Comparison", cols = 1:6, rows = 1:2)

addStyle(wb, "Model Comparison", createStyle(textDecoration = "bold", fontSize = 14, halign = "center"), rows = 1, cols = 1)
addStyle(wb, "Model Comparison", createStyle(textDecoration = "bold", halign = "center", border = "Bottom"), rows = 3, cols = 1:6)
addStyle(wb, "Model Comparison", createStyle(halign = "center"), rows = 4:(nrow(results_table)+3), cols = 1:6, gridExpand = TRUE)

setColWidths(wb, "Model Comparison", cols = 1, widths = 22)
setColWidths(wb, "Model Comparison", cols = 2:6, widths = 18)

# 添加脚注
footnote_start <- nrow(results_table) + 5
notes <- data.frame(Note = c(
  "Abbreviations: AIC, Akaike information criterion; AUC, area under the ROC curve; BIC, Bayesian information criterion; CI, confidence interval; HL, Hosmer-Lemeshow.",
  "a Data are presented as point estimate (95% CI) unless otherwise indicated.",
  "b AUC differences calculated using DeLong's method.",
  "c AIC differences represent reduction in joint model relative to comparator model.",
  "d Hosmer-Lemeshow test for model calibration: df = g - 2 (g = groups; default=10).",
  "e * denotes assumed df value when not available",
  "* P < 0.05; ** P < 0.01; *** P < 0.001"
))
writeData(wb, "Model Comparison", "Notes:", startRow = footnote_start)
writeData(wb, "Model Comparison", notes, startRow = footnote_start + 1, colNames = FALSE)

# 保存文件
saveWorkbook(wb, "JAMA_Model_Comparison_Table_Fixed.xlsx", overwrite = TRUE)

# 打印模型信息
cat("JAMA格式表格已成功导出至 'JAMA_Model_Comparison_Table_Fixed.xlsx'\n")
cat("Hosmer-Lemeshow检验结果:\n")
cat("- TYG模型: χ² =", metrics_TYG$hl_stat, "df =", metrics_TYG$hl_df, "p =", metrics_TYG$hl_p, "\n")
cat("- CD4模型: χ² =", metrics_CD4$hl_stat, "df =", metrics_CD4$hl_df, "p =", metrics_CD4$hl_p, "\n")
cat("- 联合模型: χ² =", metrics_joint$hl_stat, "df =", metrics_joint$hl_df, "p =", metrics_joint$hl_p, "\n")