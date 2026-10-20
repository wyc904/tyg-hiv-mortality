rm(list=ls());gc()

library(dplyr)
library(readr)
library(writexl)


bdmcc_population_data_$subject_id <- as.numeric(bdmcc_population_data_$subject_id)

final$subject_id <- as.numeric(final$subject_id)

X2306$id <- as.numeric(X2306$id)
X5800总$id <- as.numeric(X5800总$id)



combined_file <- left_join(final,bdmcc_population_data_, by = "subject_id")
# write_csv(combined_file, "158.csv")


write_xlsx(combined_file, "finasl.xlsx")


b <- read.csv(file.path(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"), "ndxz.csv"))
combined_file <- left_join(CD, b, by = "subject_id")

write_csv(combined_file, file.path(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"), "f.csv"))


#删除重复项
combined_file <- df[!duplicated(df$`12`), ]





