#####跑单因素cox森林图####
library(survival)
library(forestmodel)
library(survminer)
library(ggplot2)
library(ggpubr)

# 先读取变量清单：原脚本在 read.csv() 之前就使用 results，且随后 rm()，
# 会导致公式构造失败 / ggforest 缺少数据。
results <- read.csv(file.choose())
formula <- as.formula(paste("Surv(survivaltime, status) ~", paste(results$variable, collapse = " + ")))
formula#确认公式中的自变量是否正确
cox_model <- coxph(formula, data = HIVdata)
# 注意：HIVdata 在后面的 ggforest() 中还要使用，不能在这里删除
#提取cox回归中的结果及数据可视化
data_use <- summary(cox_model)

cox_HR <- round(data_use$coefficients[,2],2)#提取HR值
cox_CI2.5 <- round(data_use$conf.int[,3],2)
cox_CI97.5 <- CI95<-round(data_use$conf.int[,4],2)
cox_CI <- paste0('(',cox_CI2.5,'-',cox_CI97.5,')')#HR的95%置信区间
cox_P_value <- round(data_use$coefficients[,5],3)#P值
Variable <- row.names(data.frame(data_use$coefficients))
cox_result<- data.frame(Variable,cox_HR,cox_CI2.5,cox_CI97.5,cox_CI,cox_P_value)
write.csv(cox_result, file = "cox_result.csv")

#可视化--森林图1--基于forestmodel包。下面的代码改一下即可跑多因素森林图
forest_model(cox_model) 
#可视化--森林图2--基于survminer包
ggforest(cox_model,
         main = "Hazard ratio",#图像的标题
         data = HIVdata,#模型的数据。
         cpositions = c(0.01, 0.15, 0.35), # 更改前三列的相对位置
         fontsize = 1.2#字体大小
)
#可视化--森林图3--基于ggplot包
colnames(cox_result)#查看数据变量名称

ggplot(cox_result, aes(cox_HR, Variable)) + 
  geom_vline(xintercept = 1,
             linetype = "dashed",
             size = 1) +
  geom_errorbar(aes(xmin = cox_CI2.5, xmax = cox_CI97.5),width = 0.1) +
  geom_point(aes(color = cox_P_value),size = 5, shape = 18) +
  scale_color_continuous(low = 'skyblue', high = 'red') +
  labs(x = 'Hazard ratio', title = 'Forest plot for univariate cox regression') +
  theme_pubr() +
  theme(legend.position = 'right')

# 绘图结束后清理
rm(HIVdata, results)