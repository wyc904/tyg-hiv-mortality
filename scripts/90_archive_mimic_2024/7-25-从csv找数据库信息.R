


# 加载必要的包
library(DBI)
library(RPostgres)
library(dplyr)
library(writexl)

# 读取 CSV 文件中的 subject_id
csv_data <- final
subject_ids <- csv_data$subject_id

# 连接到数据库
# 凭据通过环境变量提供，请勿把口令写进代码：
#   Sys.setenv(MIMIC_DB_PASSWORD = "your_password")
con <- dbConnect(RPostgres::Postgres(),
                 dbname = Sys.getenv("MIMIC_DB_NAME", "mimic4_v22"),
                 host = Sys.getenv("MIMIC_DB_HOST", "localhost"),
                 port = as.integer(Sys.getenv("MIMIC_DB_PORT", "5432")),
                 user = Sys.getenv("MIMIC_DB_USER", "postgres"),
                 password = Sys.getenv("MIMIC_DB_PASSWORD"))


# 构造 SQL 查询，提取与 CSV 文件中的 subject_id 匹配的记录
query <- sprintf("SELECT * FROM mimic4_v22.bdmcc.bdmcc_population WHERE subject_id IN (%s)", 
                 paste(subject_ids, collapse = ","))

# 执行查询并保存结果
bdmcc_population_data <- dbGetQuery(con, query)




write_xlsx(bdmcc_population_data , "bdmcc_population_data .xlsx")




# 关闭数据库连接
dbDisconnect(con)









