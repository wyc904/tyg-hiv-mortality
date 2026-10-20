
library(car)
library(readxl)
library(lubridate)
library(writexl)

# 读取数据
data <- read_excel("HIV.xlsx")

colnames(data)


# 创建建模数据集（包含所有自变量）
model_data <- data[, c("死亡终", "0710ART", "Talaromycosis", "PCP", "CMV", "VL", "CD42", "sofa", "年龄分层", "PCT", "LYM", "PLT", "WBC", "UREA", "INR", "MONO", "LDH", "ALB", "GLU"
                        )]



# "D28", "age", "gender","sofa","hoslos","ICU", "SepticShock",
# "CKD", "LiverCirrhosis", "COPD",  "Diabetes", "Hypertension", "CHD",
# 
# "Talaromycosis", "PCP", "Crypto", "Candidiasis", 
# 
# "ART","Heparin", "Vasopressor", "Glucocorticoid",  "IMV", "CRRT",
# "CD4", "glu", "tg","TBIL", "Cr","PLT","LYM","WBC",  "UREA", "MONO",  "LDH", "ALB"






# "PLT", "TBIL", "Cr",
# 删除包含缺失值的观测（VIF计算需要完整数据）
model_data <- na.omit(model_data)

# 拟合包含所有自变量的线性回归模型
# 因变量需替换为你的实际结局变量（如"28天生存状态"）
# 这里假设你的结局变量名为"mortality"
full_model <- lm(`死亡终` ~ `0710ART` + Talaromycosis + PCP + CMV + VL + CD42 + sofa + `年龄分层` + PCT + LYM + PLT + WBC + UREA + INR + MONO + LDH + ALB + GLU, 
                 data = model_data)

# 
# age+gender+sofa+hoslos+ICU+SepticShock+
#   CKD+LiverCirrhosis+COPD+  Diabetes+Hypertension+CHD+
#   
#   Talaromycosis+PCP+Crypto+Candidiasis+ 
#   
#   ART+Heparin+Vasopressor+Glucocorticoid+  IMV+CRRT+
#   CD4+glu+tg+TBIL+Cr+PLT+LYM+WBC+  UREA+MONO+  LDH+ALB
# 







# 评估共线性：
# VIF > 5 表示中度共线性
# VIF > 10 表示严重共线性
# 计算方差膨胀因子(VIF)
vif_results <- vif(full_model)
print(vif_results)

library(openxlsx)

# 将 vif_results 转换为数据框
vif_df <- data.frame(
  Variable = names(vif_results),
  VIF = as.numeric(vif_results)
)

# 保存为 Excel 文件
write_xlsx(vif_df, "vif.xlsx")
















