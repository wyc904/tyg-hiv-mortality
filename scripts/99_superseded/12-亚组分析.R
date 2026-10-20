library(survival)
library(dplyr)
library(writexl)
library(readxl)

# 读取Excel文件
df_total <- read_excel("亚组分析表.xlsx")

# 优化后的分层分析函数
stratified_analysis <- function(data, stratify_var, time_var, outcome_var, TyGbmi, covariates) {
  results <- data.frame(
    Level = character(),
    Number = integer(),
    HR = numeric(),
    CI_lower = numeric(),
    CI_upper = numeric(),
    P_value = numeric(),
    P_interaction = numeric(),
    stringsAsFactors = FALSE
  )
  
  # 删除分层变量中的缺失值
  data <- data %>% filter(!is.na(!!sym(stratify_var)))
  
  # 计算交互作用P值
  interaction_formula <- as.formula(paste(
    "Surv(", time_var, ", ", outcome_var, ") ~", 
    paste(c(TyGbmi, stratify_var, paste0(TyGbmi, ":", stratify_var), covariates), collapse = " + ")
  ))
  
  interaction_model <- tryCatch(
    {
      coxph(interaction_formula, data = data)
    },
    error = function(e) {
      cat("Error in interaction model for", stratify_var, ":", e$message, "\n")
      return(NULL)
    }
  )
  
  if(is.null(interaction_model)) {
    interaction_p_value <- NA
  } else {
    # 提取交互作用项的P值
    coef_names <- names(coef(interaction_model))
    interaction_term <- paste0(TyGbmi, ":", stratify_var)
    
    if(interaction_term %in% coef_names) {
      interaction_p_value <- summary(interaction_model)$coefficients[interaction_term, "Pr(>|z|)"]
    } else {
      cat("Warning: Interaction term not found for", stratify_var, "\n")
      interaction_p_value <- NA
    }
  }
  
  # 分层分析
  for(level in unique(data[[stratify_var]])) {
    sub_data <- data %>% filter(!!sym(stratify_var) == level)
    n <- nrow(sub_data)
    
    if(n < 5) {  # 样本量过少时跳过
      results <- rbind(results, data.frame(
        Level = as.character(level),
        Number = n,
        HR = NA,
        CI_lower = NA,
        CI_upper = NA,
        P_value = NA,
        P_interaction = interaction_p_value
      ))
      next
    }
    
    # 构建分层模型公式
    formula <- as.formula(paste(
      "Surv(", time_var, ", ", outcome_var, ") ~", 
      paste(c(TyGbmi, covariates), collapse = " + ")
    ))
    
    model <- tryCatch(
      {
        coxph(formula, data = sub_data)
      },
      error = function(e) {
        cat("Error in level", level, "of", stratify_var, ":", e$message, "\n")
        return(NULL)
      }
    )
    
    if(is.null(model)) {
      results <- rbind(results, data.frame(
        Level = as.character(level),
        Number = n,
        HR = NA,
        CI_lower = NA,
        CI_upper = NA,
        P_value = NA,
        P_interaction = interaction_p_value
      ))
      next
    }
    
    # 提取结果
    model_summary <- summary(model)
    hr_row <- grep(TyGbmi, rownames(model_summary$conf.int))
    
    if(length(hr_row) > 0) {
      HR <- model_summary$conf.int[hr_row[1], 1]
      CI_lower <- model_summary$conf.int[hr_row[1], 3]
      CI_upper <- model_summary$conf.int[hr_row[1], 4]
      p_value <- model_summary$coefficients[hr_row[1], "Pr(>|z|)"]
    } else {
      HR <- NA
      CI_lower <- NA
      CI_upper <- NA
      p_value <- NA
    }
    
    results <- rbind(results, data.frame(
      Level = as.character(level),
      Number = n,
      HR = HR,
      CI_lower = CI_lower,
      CI_upper = CI_upper,
      P_value = p_value,
      P_interaction = interaction_p_value
    ))
  }
  
  return(results)
}

# 设置分析参数
time_var <- "d28"  # 时间变量
outcome_var <- "D28"  # 结局变量
TyGbmi <- "TYGCD4"  # 主要自变量
covariates <- c("LYM" , "UREA", "AST",  "CRP",   "WBC", "LYM", "MONO" ,"ALB")
stratify_vars <- c("性别10", "年龄分层", "sofaf", "Diabetes", "Hypertension", "CHD",  "LiverCirrhosis",  "CKD"
 , "Talaromycosis", "PCP", "Cryptococcosis", "念珠")  # 分层变量

# 执行分层分析
all_results <- list()

for(stratify_var in stratify_vars) {
  cat("Processing:", stratify_var, "\n")
  results <- stratified_analysis(df_total, stratify_var, time_var, outcome_var, TyGbmi, covariates)
  all_results[[stratify_var]] <- results
}

# 保存结果
write_xlsx(all_results, "day28.xlsx")
cat("分析完成，结果已保存至 day28.xlsx\n")