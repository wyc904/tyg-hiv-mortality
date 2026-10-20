rm(list=ls());gc()

library(writexl)

data<-X595_重新计算

# 
# head(data)

# 
# # Calculate the quartiles for the TYG column
# 修正：四分位切点应基于 TyGbmi（原代码误用了 TyG_index）
tyg_quartiles <- quantile(data$TyGbmi, probs = seq(0, 1, 0.25), na.rm = TRUE)


# 
data$TyGbmi3<- cut(data$TyGbmi,
                      breaks = quantile(data$TyGbmi, probs = seq(0, 1, by = 1/3), na.rm = TRUE),
                      include.lowest = TRUE,
                      labels = c("1", "2", "3"))
#
# # 
data$TyG3<- cut(data$TyG_index,
                   breaks = quantile(data$TyG_index, probs = seq(0, 1, by = 1/3), na.rm = TRUE),
                   include.lowest = TRUE,
                   labels = c("1", "2", "3"))
#


# Create a new column 'tyg_group' to classify the TYG values into four quartiles
data$TyGbmi4<- cut(data$TyGbmi, 
                    breaks = tyg_quartiles, 
                    include.lowest = TRUE, 
                    labels = c("1", "2", "3", "4"))

# Print the first few rows of the updated dataframe to see the classification


write_xlsx(data, "14.xlsx")


