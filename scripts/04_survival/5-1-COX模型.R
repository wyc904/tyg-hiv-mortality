# 加载必要的包
library(survival)
library(readxl)
library(openxlsx)
library(purrr)
library(dplyr)

setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"))

# 读取数据
data <- read_excel("tyg-1300-hiv.xlsx")

# 设置分类变量的参考组
data$TyG     <- factor(data$TyG, levels = c(0, 1))             # 参考组=0
data$CD4     <- factor(data$CD4, levels = c(1, 0))             # 参考组=1
data$TYGCD4  <- factor(data$TYGCD4, levels = c(1, 2, 3, 4))    # 参考组=1

# 定义全调整模型的协变量
full_adjust_vars <- c(
  "age", "gender", "Diabetes", "Hypertension", "CKD", "LiverCirrhosis",
  "CHD", "COPD", "sofa", "ART", 
  "Talaromycosis", "PCP", "Cryptococcosis", "Candidiasis"
)

# 创建模型分析函数（包含多个P for trend）
analyze_models <- function(data, predictor, output_file) {
  # 主模型列表
  models <- list(
    model1 = as.formula(paste("Surv(d28, D28) ~", predictor)),
    model2 = as.formula(paste("Surv(d28, D28) ~", predictor, "+ age + gender")),
    model3 = as.formula(paste("Surv(d28, D28) ~", predictor, "+", paste(full_adjust_vars, collapse = " + ")))
  )
  
  # 拟合 Cox 模型
  results <- map(models, ~{
    tryCatch({
      coxph(.x, data = data)
    }, error = function(e) {
      message("模型拟合错误: ", conditionMessage(e))
      return(NULL)
    })
  })
  
  results <- compact(results)
  
  if (length(results) == 0) {
    message("所有模型拟合失败，跳过保存: ", output_file)
    return()
  }
  
  # 创建Excel工作簿
  wb <- createWorkbook()
  
  # 写入每个模型摘要
  walk2(results, names(results), ~{
    addWorksheet(wb, .y)
    writeData(wb, .y, capture.output(summary(.x)))
  })
  
  # ========== 计算每个模型的 P for trend（针对有序分类变量） ==========
  if (is.factor(data[[predictor]]) && nlevels(data[[predictor]]) > 2) {
    message("正在为多分类变量计算 P for trend: ", predictor)
    
    # 创建 trend 数值变量（有序编码）
    data$trend_var <- as.numeric(as.character(data[[predictor]]))
    
    # 构造 trend 模型列表
    trend_models <- list(
      model1 = as.formula("Surv(d28, D28) ~ trend_var"),
      model2 = as.formula("Surv(d28, D28) ~ trend_var + age + gender"),
      model3 = as.formula(paste("Surv(d28, D28) ~ trend_var +", paste(full_adjust_vars, collapse = " + ")))
    )
    
    # 拟合并提取P值
    trend_pvals <- map2(trend_models, names(trend_models), function(fm, name) {
      model <- tryCatch(coxph(fm, data = data), error = function(e) NULL)
      if (!is.null(model)) {
        pval <- summary(model)$coefficients["trend_var", "Pr(>|z|)"]
        return(data.frame(Model = name, P_for_trend = pval))
      } else {
        return(data.frame(Model = name, P_for_trend = NA))
      }
    }) %>% bind_rows()
    
    # 写入 Excel
    addWorksheet(wb, "P_for_trend")
    writeData(wb, "P_for_trend", trend_pvals)
  }
  
  # 保存工作簿
  saveWorkbook(wb, output_file, overwrite = TRUE)
  message("分析结果已保存到: ", output_file)
}


# ========== 分析连续变量（无需趋势性P值） ==========
analyze_models(data, "TyG_index", "d28-TyG_index_results.xlsx")
analyze_models(data, "CD41", "d28-CD41_results.xlsx")

# ========== 分析分类变量 ==========
analyze_models(data, "TyG", "d28-TyG_results.xlsx")         # 二分类
analyze_models(data, "CD4", "d28-CD4_results.xlsx")         # 二分类
analyze_models(data, "TYGCD4", "d28-TYGCD4_results.xlsx")   # 多分类（含 P for trend）

message("所有分析已完成！")
