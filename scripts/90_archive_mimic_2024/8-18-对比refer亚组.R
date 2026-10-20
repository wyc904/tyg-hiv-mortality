library(survival)
library(dplyr)
library(writexl)
library(tidyr)



# 定义函数来进行分层分析并计算交互作用p值
stratified_analysis_v2 <- function(data, stratify_var, time_var, outcome_var, TyGbmi3, covariates) {
  results <- data.frame(
    Subgroups = character(),
    Case = integer(),
    Total = integer(),
    HR_Q2 = character(),
    P_value_Q2 = numeric(),
    HR_Q3 = character(),
    P_value_Q3 = numeric(),
    P_for_interaction = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (level in unique(data[[stratify_var]])) {
    sub_data <- data %>% filter(!!sym(stratify_var) == level)
    
    formula <- as.formula(paste("Surv(", time_var, ", ", outcome_var, ") ~ factor(", TyGbmi3, ") +", paste(covariates, collapse = " + ")))
    
    cox_model <- coxph(formula, data = sub_data)
    summary_cox <- summary(cox_model)
    
    # 提取HR和95% CI以及p值
    hr_q2 <- sprintf("%.2f (%.2f, %.2f)", summary_cox$conf.int["factor(TyGbmi3)2", "exp(coef)"], summary_cox$conf.int["factor(TyGbmi3)2", "lower .95"], summary_cox$conf.int["factor(TyGbmi3)2", "upper .95"])
    p_value_q2 <- summary_cox$coefficients["factor(TyGbmi3)2", "Pr(>|z|)"]
    
    hr_q3 <- sprintf("%.2f (%.2f, %.2f)", summary_cox$conf.int["factor(TyGbmi3)3", "exp(coef)"], summary_cox$conf.int["factor(TyGbmi3)3", "lower .95"], summary_cox$conf.int["factor(TyGbmi3)3", "upper .95"])
    p_value_q3 <- summary_cox$coefficients["factor(TyGbmi3)3", "Pr(>|z|)"]
    
    # 样本数量
    n_total <- nrow(sub_data)
    n_cases <- sum(sub_data[[outcome_var]] == 1)
    
    # 保存结果
    results <- rbind(results, data.frame(
      Subgroups = as.character(level),
      Case = n_cases,
      Total = n_total,
      HR_Q2 = hr_q2,
      P_value_Q2 = p_value_q2,
      HR_Q3 = hr_q3,
      P_value_Q3 = p_value_q3,
      P_for_interaction = NA
    ))
  }
  
  # 计算交互作用p值
  interaction_formula <- as.formula(paste("Surv(", time_var, ", ", outcome_var, ") ~ factor(", TyGbmi3, ") *", stratify_var, "+", paste(covariates, collapse = " + ")))
  interaction_model <- coxph(interaction_formula, data = data)
  interaction_p_value <- summary(interaction_model)$coefficients[paste("factor(", TyGbmi3, ")2:", stratify_var, sep = ""), "Pr(>|z|)"]
  
  results$P_for_interaction <- interaction_p_value
  
  return(results)
}

# 定义变量
stratify_vars <- c("gender", "agefenzu", "icd_hypertension", "icd_afib", "icd_diabetes", "icd_renal", "icd_liver", "icd_cad", "icd_stroke", "icd_ss")  # 可以加入其他分组变量
time_var <- "day28"  # 替换为实际的时间变量
outcome_var <- "day28_outcome"  # 替换为实际的结局变量
TyGbmi3 <- "TyGbmi3"  # 替换为实际的因变量

# 协变量列表
covariates <- c("apsiii", "sapsii", "sofa", "gcs", "charlson",
                "vs_24h_map_first", "vs_24h_sbp_first", "vs_24h_dbp_first", "vs_24h_heart_rate_first",
                "vs_24h_resp_rate_first", "vs_24h_spo2_first", "lab_fst_24h_hco3_first",
                "lab_fst_24h_creatinine_first", "lab_fst_24h_bun_first", "lab_fst_24h_wbc_first",
                "lab_fst_24h_rbc_first", "lab_fst_24h_hct_first", "lab_fst_24h_rdw_first",
                "lab_fst_24h_hemoglobin_first", "lab_fst_24h_platelet_first", "lab_fst_24h_inr_first",
                "lab_fst_24h_pt_first", "lab_fst_24h_aptt_first", "lab_fst_24h_cl_first",
                "lab_fst_24h_na_first", "lab_fst_24h_k_first", "lab_fst_24h_bg_first",
                "lab_fst_24h_tg_first")

# 结果列表
all_results <- list()

# 分层分析
for (stratify_var in stratify_vars) {
  all_results[[stratify_var]] <- stratified_analysis_v2(data, stratify_var, time_var, outcome_var, TyGbmi3, covariates)
}

# 将所有结果写入 Excel
write_xlsx(all_results, "stratified_analysis_results.xlsx")





# 按TyGbmi3分组
data_subgroup_2_3 <- data %>% filter(TyGbmi3 %in% c(2, 3))

# 初始化空列表用于保存结果
results_list <- list()

# 循环遍历每个分层变量
for (stratify_var in stratify_vars) {
  # 对于TyGbmi3的每个分组计算每个分层变量中不同类别的Case数量
  result <- data_subgroup_2_3 %>%
    group_by(TyGbmi3, !!sym(stratify_var), !!sym(outcome_var)) %>%
    summarize(Count = n(), .groups = 'drop') %>%
    pivot_wider(names_from = !!sym(outcome_var), values_from = Count, values_fill = list(Count = 0)) %>%
    arrange(TyGbmi3, !!sym(stratify_var))
  
  # 将结果保存在列表中，便于后续访问
  results_list[[stratify_var]] <- result
  
  # 输出当前变量的结果
  print(paste("Results for:", stratify_var))
  print(result)
}

# 将所有结果写入 Excel
write_xlsx(results_list, "stratified_analysis_counts.xlsx")


















