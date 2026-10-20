library(survival)
library(dplyr)
library(writexl)
library(readxl)

# 读取Excel文件
df_total <- read_excel("亚组分析表.xlsx")

# 转换函数 - 将所有分类变量转换为因子
convert_to_factor <- function(data, vars) {
  for(var in vars) {
    if(var %in% names(data)) {
      if(!is.factor(data[[var]])) {
        unique_vals <- unique(data[[var]])
        data[[var]] <- factor(data[[var]], levels = unique_vals)
        cat("已将变量", var, "转换为因子\n")
      }
    } else {
      cat("警告：变量", var, "不存在于数据框中\n")
    }
  }
  return(data)
}

# 分类变量列表
categorical_vars <- c("gender")

# 转换所有分类变量为因子
df_total <- convert_to_factor(df_total, categorical_vars)

# 确保TYGCD4正确设置参考水平
if(!is.factor(df_total$TYGCD4)) {
  df_total$TYGCD4 <- factor(df_total$TYGCD4, levels = c(1, 2, 3, 4))
}

# 移除未使用的因子水平
df_total$TYGCD4 <- droplevels(df_total$TYGCD4)

# 检查并设置参考水平为1
if("1" %in% levels(df_total$TYGCD4)) {
  df_total$TYGCD4 <- relevel(df_total$TYGCD4, ref = "1")
  cat("已将TYGCD4的参考组设置为类别1\n")
} else if(1 %in% levels(df_total$TYGCD4)) {
  # 确保使用字符或数字一致
  df_total$TYGCD4 <- relevel(df_total$TYGCD4, ref = "1")
  cat("已将TYGCD4的参考组设置为类别1(数字)\n")
} else {
  # 如果1不在因子水平中，添加它
  new_levels <- unique(c("1", levels(df_total$TYGCD4)))
  df_total$TYGCD4 <- factor(df_total$TYGCD4, levels = new_levels)
  df_total$TYGCD4 <- relevel(df_total$TYGCD4, ref = "1")
  cat("添加并设置TYGCD4的参考组为类别1\n")
}

# 查看因子水平信息
cat("TYGCD4的因子水平:", paste(levels(df_total$TYGCD4), collapse = ", "), "\n")
cat("参考水平:", levels(df_total$TYGCD4)[1], "\n")

# 后续的分层分析函数保持不变...





# 转换所有分类变量为因子
df_total <- convert_to_factor(df_total, categorical_vars)

# 特别设置TYGCD4的参考水平为1
df_total$TYGCD4 <- relevel(df_total$TYGCD4, ref = "1")
cat("已将TYGCD4的参考组设置为类别1\n")

# 优化后的分层分析函数
stratified_analysis <- function(data, stratify_var, time_var, outcome_var, main_var, covariates) {
  results <- data.frame(
    Level = character(),
    Group = character(),
    Number = integer(),
    HR = numeric(),
    CI_lower = numeric(),
    CI_upper = numeric(),
    P_value = numeric(),
    P_interaction = numeric(),
    stringsAsFactors = FALSE
  )
  
  # 删除缺失值
  data <- data %>% filter(!is.na(!!sym(stratify_var)))
  
  # 计算交互作用P值
  main_formula <- as.formula(paste(
    "Surv(", time_var, ",", outcome_var, ") ~", 
    paste(c(main_var, stratify_var, covariates), collapse = " + ")
  ))
  
  interaction_formula <- as.formula(paste(
    "Surv(", time_var, ",", outcome_var, ") ~", 
    paste(c(paste0("as.factor(", main_var, ")*as.factor(", stratify_var, ")"), covariates), 
          collapse = " + ")
  ))
  
  # 更健壮的错误处理
  main_model <- tryCatch(
    coxph(main_formula, data = data),
    error = function(e) {
      cat("主模型错误:", e$message, "\n")
      return(NULL)
    },
    warning = function(w) {
      cat("主模型警告:", w$message, "\n")
      return(NULL)
    }
  )
  
  interaction_model <- tryCatch(
    coxph(interaction_formula, data = data),
    error = function(e) {
      cat("交互模型错误:", e$message, "\n")
      return(NULL)
    },
    warning = function(w) {
      cat("交互模型警告:", w$message, "\n")
      return(NULL)
    }
  )
  
  interaction_p_value <- NA
  if(!is.null(main_model) && !is.null(interaction_model)) {
    tryCatch({
      lrt <- anova(main_model, interaction_model, test = "LRT")
      interaction_p_value <- ifelse(nrow(lrt) >= 2, lrt[2, "P(>|Chi|)"], NA)
      cat("成功计算交互作用P值:", interaction_p_value, "\n")
    }, error = function(e) {
      cat("LRT检验错误:", e$message, "\n")
    })
  }
  
  # 分层分析
  for(level in levels(data[[stratify_var]])) {
    cat("处理水平:", level, "\n")
    
    sub_data <- data %>% filter(!!sym(stratify_var) == level)
    n <- nrow(sub_data)
    n_level1 <- sum(sub_data[[main_var]] == "1", na.rm = TRUE)  # 注意：因子变量要比较字符串
    
    if(n < 5 || n_level1 < 1) {
      cat("样本量不足 - 总数:", n, "参考组:", n_level1, "\n")
      for(comp_group in c("2", "3", "4")) {
        results <- rbind(results, data.frame(
          Level = as.character(level),
          Group = comp_group,
          Number = n,
          HR = NA,
          CI_lower = NA,
          CI_upper = NA,
          P_value = NA,
          P_interaction = interaction_p_value,
          stringsAsFactors = FALSE
        ))
      }
      next
    }
    
    # 构建模型（直接使用因子变量）
    formula <- as.formula(paste(
      "Surv(", time_var, ",", outcome_var, ") ~",
      paste(c(main_var, covariates), collapse = " + ")
    ))
    
    model <- tryCatch(
      coxph(formula, data = sub_data),
      error = function(e) {
        cat("模型错误:", e$message, "\n")
        return(NULL)
      },
      warning = function(w) {
        cat("模型警告:", w$message, "\n")
        return(coxph(formula, data = sub_data, control = coxph.control(iter.max = 50)))
      }
    )
    
    if(is.null(model)) {
      cat("模型创建失败\n")
      for(comp_group in c("2", "3", "4")) {
        results <- rbind(results, data.frame(
          Level = as.character(level),
          Group = comp_group,
          Number = n,
          HR = NA,
          CI_lower = NA,
          CI_upper = NA,
          P_value = NA,
          P_interaction = interaction_p_value,
          stringsAsFactors = FALSE
        ))
      }
      next
    }
    
    model_summary <- summary(model)
    cat("模型系数名称:", paste(rownames(model_summary$coefficients), collapse = ", "), "\n")
    
    for(comp_group in c("2", "3", "4")) {
      comp_name <- paste0(main_var, comp_group)
      n_comp <- sum(sub_data[[main_var]] == comp_group, na.rm = TRUE)
      cat("处理分组:", comp_group, "样本量:", n_comp, "\n")
      
      if(n_comp < 1) {
        results <- rbind(results, data.frame(
          Level = as.character(level),
          Group = comp_group,
          Number = n,
          HR = NA,
          CI_lower = NA,
          CI_upper = NA,
          P_value = NA,
          P_interaction = interaction_p_value,
          stringsAsFactors = FALSE
        ))
        next
      }
      
      if(comp_name %in% rownames(model_summary$coefficients)) {
        coef_row <- model_summary$coefficients[comp_name, ]
        HR <- exp(coef_row["coef"])
        CI_lower <- exp(coef_row["coef"] - 1.96 * coef_row["se(coef)"])
        CI_upper <- exp(coef_row["coef"] + 1.96 * coef_row["se(coef)"])
        p_value <- coef_row["Pr(>|z|)"]
        
        # 优先使用置信区间表（更精确）
        if("conf.int" %in% names(model_summary) &&
           comp_name %in% rownames(model_summary$conf.int)) {
          ci_row <- model_summary$conf.int[comp_name, ]
          CI_lower <- ci_row["lower .95"]
          CI_upper <- ci_row["upper .95"]
        }
      } else {
        HR <- NA
        CI_lower <- NA
        CI_upper <- NA
        p_value <- NA
        cat("系数未找到:", comp_name, "\n")
      }
      
      results <- rbind(results, data.frame(
        Level = as.character(level),
        Group = comp_group,
        Number = n,
        HR = HR,
        CI_lower = CI_lower,
        CI_upper = CI_upper,
        P_value = p_value,
        P_interaction = interaction_p_value,
        stringsAsFactors = FALSE
      ))
    }
  }
  
  return(results)
}

# 设置参数
time_var <- "d28"  # 生存时间变量
outcome_var <- "D28"  # 结局（死亡）变量
main_var <- "TYGCD4"  # 主变量，4级分类
covariates <- c("age","gender", "Hypertension", "CKD", "LiverCirrhosis","Diabetes",
                 "CHD", "COPD", 
                 "Talaromycosis", "PCP", "Cryptococcosis", "Candidiasis")  # 协变量
stratify_vars <- c("gender")  # 分层变量

# "ART", "SepticShock", "sofaf","ICU"
# 
# "性别10", "年龄分层", "sofaf", "Diabetes", "Hypertension", "CHD", "HF", "LiverCirrhosis"
# , "Talaromycosis", "PCP", "Cryptococcosis", "念珠", "CMV"
# 


# 执行所有分层分析
all_results <- list()

for(stratify_var in stratify_vars) {
  cat("\n=========== 正在处理：", stratify_var, "===========\n")
  results <- tryCatch({
    stratified_analysis(df_total, stratify_var, time_var, outcome_var, main_var, covariates)
  }, error = function(e) {
    cat("!!! 处理", stratify_var, "时发生严重错误:", e$message, "\n")
    return(data.frame())
  })
  all_results[[stratify_var]] <- results
}

# 保存为Excel文件
write_xlsx(all_results, "加day28_all_comparisonss.xlsx")
cat("\n✅ 分析完成，结果已保存为 day28_all_comparisons.xlsx\n")




















