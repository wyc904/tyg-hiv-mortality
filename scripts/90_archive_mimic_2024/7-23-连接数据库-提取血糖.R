# rm(list=ls());gc()

library(DBI)
library(RPostgres)
library(writexl)



# Connect to the database
# 凭据通过环境变量提供，请勿把口令写进代码：
#   Sys.setenv(MIMIC_DB_PASSWORD = "your_password")
con <- dbConnect(RPostgres::Postgres(),
                 dbname = Sys.getenv("MIMIC_DB_NAME", "mimic4_v22"),
                 host = Sys.getenv("MIMIC_DB_HOST", "localhost"),
                 port = as.integer(Sys.getenv("MIMIC_DB_PORT", "5432")),
                 user = Sys.getenv("MIMIC_DB_USER", "postgres"),
                 password = Sys.getenv("MIMIC_DB_PASSWORD"))



# Extract subject_id column
subject_ids <- lianxi$hadm_id


# Create a temporary table to store subject IDs
dbExecute(con, "CREATE TEMP TABLE temp_subject_ids (hadm_id INT)")

# Insert subject IDs into the temporary table
subject_ids_chunked <- split(subject_ids, ceiling(seq_along(subject_ids)/1000))  # Split into chunks to avoid SQL length limits

for (chunk in subject_ids_chunked) {
  values <- paste0("(", paste(chunk, collapse = "), ("), ")")
  query <- paste("INSERT INTO temp_subject_ids (hadm_id) VALUES", values)
  dbExecute(con, query)
}


# Define the query to get the required data
query <- "
SELECT
    l.subject_id,
    l.hadm_id,
    l.itemid,
    l.charttime,
    l.value,
    l.valuenum,
    l.valueuom
FROM
    mimiciv_hosp.labevents l
JOIN
    temp_subject_ids t
ON
    l.hadm_id = t.hadm_id
WHERE
    l.itemid IN (51000);
"

# Execute the query and fetch results
result <- dbGetQuery(con, query)
# print(result)

write_xlsx(result, "tg.xlsx")

# Disconnect from the database
dbDisconnect(con)













































