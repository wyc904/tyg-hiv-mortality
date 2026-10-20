rm(list=ls());gc()







# 全流程代码
library(survival)
library(rms)
library(maxstat)
# 加载必要的库
library(readxl)
library(dplyr)









# 读取CSV文件
data <- read_excel("1500-插补.xlsx")

colnames(data)



# 计算TyG指数
data <- data %>%
  mutate(TyG_index = log( (tg * glu) / 2 ))




write_xlsx(data, "8-40.xlsx")
# 






#########################################



# rm(list=ls());gc()






library(writexl)

# # 读取CSV文件
# data <- read_excel("tyg.xlsx")
# 
# # 
# head(data)

# 

data$TyG34<- cut(data$TyG_index,
                breaks = quantile(data$TyG_index, probs = seq(0, 1, 0.25), na.rm = TRUE),
                include.lowest = TRUE,
                labels = c("1", "2", "3", "4"))
# 
data$TyG3<- cut(data$TyG_index,
                   breaks = quantile(data$TyG_index, probs = seq(0, 1, by = 1/3), na.rm = TRUE),
                   include.lowest = TRUE,
                   labels = c("1", "2", "3"))
#

# 二分位分组另存为 TyG2，避免覆盖上面的三分位 TyG3
data$TyG2 <- cut(data$TyG_index,
breaks = quantile(data$TyG_index, probs = seq(0, 1, by = 1/2), na.rm = TRUE),
include.lowest = TRUE,
labels = c("0", "1"))
#


write_xlsx(data, "14.xlsx")



############################33计算拐点截断值





library(pROC)
library(ggplot2)
library(openxlsx)
library(dplyr)

# 从文本数据创建实际数据集 (更符合真实分析场景)
# 假设您的数据框中有两列：TyG_index 和 死亡（0=存活，1=死亡）
# 这里直接使用您提供的变量名构建数据集

# 创建包含TyG_index和死亡信息的真实数据集
# 在实际分析中，这部分应替换为您的真实数据

data<- read_excel("tyg-1300-hiv.xlsx")

# 计算ROC曲线和最优截断值
roc_obj <- roc( data$D28 ~ TyG_index, data = data, auc = TRUE)

# 获取完整的ROC曲线数据点
roc_data <- data.frame(
  specificity = roc_obj$specificities,
  sensitivity = roc_obj$sensitivities,
  threshold = roc_obj$thresholds
) %>%
  arrange(specificity)  # 按特异性排序

# 计算所有可能截断值的Youden指数
roc_data <- roc_data %>%
  mutate(youden = sensitivity + specificity - 1)

# 找到Youden指数最大的点（最优截断值）
optimal_index <- which.max(roc_data$youden)
optimal_threshold <- roc_data$threshold[optimal_index]
optimal_sensitivity <- roc_data$sensitivity[optimal_index]
optimal_specificity <- roc_data$specificity[optimal_index]
auc_value <- auc(roc_obj)[1]

# 打印结果
cat("计算的最优截断值 (拐点):", round(optimal_threshold, 4), "\n")
cat("敏感性:", round(optimal_sensitivity, 4), "\n")
cat("特异性:", round(optimal_specificity, 4), "\n")
cat("AUC值:", round(auc_value, 4), "\n")
cat("Youden指数:", round(roc_data$youden[optimal_index], 4), "\n")

# 创建结果数据框
results <- data.frame(
  Variable = "TyG_index",
  Cutoff = optimal_threshold,
  Sensitivity = optimal_sensitivity,
  Specificity = optimal_specificity,
  AUC = auc_value,
  Youden_Index = roc_data$youden[optimal_index],
  Number_Events = sum( data$D28),
  Number_NonEvents = sum(! data$D28)
)

# 将ROC曲线数据也保存到Excel
roc_results <- roc_data %>%
  select(Threshold = threshold, Sensitivity = sensitivity, Specificity = specificity, Youden_Index = youden)

# 导出为Excel文件
wb <- createWorkbook()

# 添加结果汇总表
addWorksheet(wb, "Summary")
writeData(wb, "Summary", results)

# 添加完整ROC曲线数据
addWorksheet(wb, "ROC_Curve_Data")
writeData(wb, "ROC_Curve_Data", roc_results)

# 添加计算说明
addWorksheet(wb, "Instructions")
instructions <- data.frame(
  Note = c("最佳截断值使用Youden指数方法计算: J = Sensitivity + Specificity - 1",
           "数据集: 使用模拟数据，实际应用中应替换为真实数据",
           "事件定义: 死亡 = 1, 存活 = 0")
)
writeData(wb, "Instructions", instructions)

# 保存Excel文件
saveWorkbook(wb, "TyG_Index_Cutoff_Analysis.xlsx", overwrite = TRUE)
cat("\n结果已保存至: TyG_Index_Cutoff_Analysis.xlsx\n")

# 可视化ROC曲线及拐点 (增强版)
p <- ggroc(roc_obj, color = "#2c7fb8", size = 1.2) +
  geom_point(aes(x = 1 - optimal_specificity, y = optimal_sensitivity), 
             color = "#e41a1c", size = 4) +
  geom_segment(aes(x = 1, xend = 1 - optimal_specificity, 
                   y = 0, yend = optimal_sensitivity), 
               color = "#e41a1c", linetype = "dashed") +
  geom_text(aes(x = 1 - optimal_specificity, y = optimal_sensitivity + 0.05,
                label = paste0("最佳截断值: ", round(optimal_threshold, 3), 
                               "\n敏感度: ", round(100 * optimal_sensitivity, 1), "%",
                               "\n特异度: ", round(100 * optimal_specificity, 1), "%",
                               "\nYouden指数: ", round(roc_data$youden[optimal_index], 3))),
            color = "#984ea3", size = 4.5, hjust = 1, vjust = 0) +
  labs(title = "TyG指数预测死亡的ROC曲线分析",
       subtitle = paste0("AUC = ", round(auc_value, 3), " (", 100 * round(auc_value, 3), "%)"),
       x = "1 - 特异性 (假阳性率)",
       y = "敏感性 (真阳性率)") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
        plot.subtitle = element_text(hjust = 0.5, size = 14),
        panel.grid.major = element_line(color = "gray90"),
        panel.grid.minor = element_blank())

print(p)

# 保存高清图像
ggsave("TyG_index_ROC_curve.png", plot = p, width = 8, height = 6, dpi = 300)
ggsave("TyG_index_ROC_curve.pdf", plot = p, width = 8, height = 6, dpi = 300)

# 提示使用实际数据
cat("\n重要提示: 当前使用模拟数据进行演示。\n",
    "要使用您自己的真实数据，请将创建数据框的代码替换为:\n",
    "data <- read.csv('your_data.csv') # 替换为实际数据文件\n",
    "并确保数据框包含两列: 'TyG_index' 和 '死亡'\n",
    "其中'死亡'列应该是二元变量(0=存活, 1=死亡)")







