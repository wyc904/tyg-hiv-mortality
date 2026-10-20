# 安装并加载必要的包

library(pROC)

# 读取CSV文件
data <- X595_重新计算C

# 假设CSV文件中有两个变量：一个是实际分类标签sofa_score，另一个是预测概率year1_outcome
# day28_outcome##TyGbmi#TyG_index

actual <- data$year1_outcome
predicted <- data$TyG_index

# 绘制ROC曲线并计算AUC
roc_obj <- roc(actual, predicted)
auc_value <- auc(roc_obj)

# 确定最佳临界点（Youden's J statistic）
best_threshold <- coords(roc_obj, "best", ret = "threshold")
best_coords <- coords(roc_obj, "best", ret = c("threshold", "specificity", "sensitivity"))
best_coords


# # 绘制ROC曲线
# plot(roc_obj, main = paste("ROC Curve (AUC =", round(auc_value, 2), ")"), col = "blue")

# 计算AUC的95%置信区间
ci_auc <- ci.auc(roc_obj)
ci_auc
# 输出AUC值及最佳临界点的详细信息
print(paste("AUC =", round(auc_value, 3)))
print(paste("Best Threshold =", round(best_coords[1], 2)))
print(paste("Specificity =", round(best_coords[2] * 100, 1), "%"))
print(paste("Sensitivity =", round(best_coords[3] * 100, 1), "%"))



# 绘制ROC曲线
plot(roc_obj, 
     main = paste("ROC Curve (AUC =", round(auc_value, 2), ")"), 
     col = "blue", 
     lwd = 2,                         # 线条宽度
     xlab = "1 - Specificity", 
     ylab = "Sensitivity", 
     xlim = c(1, 0), 
     ylim = c(0, 1), 
     cex.main = 1,                  # 标题大小
     cex.lab = 1.2, 
      smooth=FALSE,# 轴标签大小
     cex.axis = 1.1)                  # 坐标轴刻度大小

# 
# auc1 <- roc(actual~predicted, data=BPRI4, smooth=FALSE)

# # 添加网格线
# grid(col = "gray", lty = "dotted")

# # 添加参考线（y = x线）
# abline(a = 0, b = 1, col = "red", lty = 2)

# 添加AUC值文本
legend("bottomright", 
       legend = paste("AUC =", round(auc_value, 2)), 
       col = "blue", 
       lwd = 2, 
       bty = "n",                      # 不显示图例边框
       cex = 1.2)                      # 图例文字大小

# # 添加阈值点
# coords <- coords(roc_obj, "best", ret = "all", transpose = FALSE)
# points(coords$specificity, coords$sensitivity, 
#        pch = 19,                        # 点形状
#        col = "darkorange", 
#        cex = 1.5)                       # 点大小
# text(coords$specificity, coords$sensitivity, 
#      labels = paste0("Threshold = ", round(coords$threshold, 2)), 
#      pos = 4,                           # 文本位置（右侧）
#      col = "darkorange", 
#      cex = 1)                           # 文本大小

# 添加图例
# legend("bottomright", 
#        legend = c("ROC Curve", "Reference Line", "Optimal Threshold"), 
#        col = c("blue", "red", "darkorange"), 
#        lwd = 2, 
#        pch = c(NA, NA, 19), 
#        lty = c(1, 2, NA), 
#        bty = "n", 
#        cex = 1.2)




