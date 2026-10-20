library(ggplot2)
library(ggpubr)
#install.packages("ggpmisc")  如果没有安装的话先安装
library(ggpmisc)
theme_set(
  theme_minimal() +
    theme(legend.position = "top")
)
data_correlation_Protein_A<-read.csv(file.choose())# Load data或者时这样data("mtcars")
df <- data_correlation_Protein_A
# Add regression line and confidence interval
# Add correlation coefficient: stat_cor()
ggscatter(df, x = "HbA1c", y = "Protein_A",
          add = "reg.line", conf.int = TRUE,    
          add.params = list(fill = "lightblue")
          
)#结束

