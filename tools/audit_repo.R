# ============================================================
# 仓库自检脚本
# 用法（在仓库根目录）：Rscript tools/audit_repo.R
# 检查项：
#   1. 清单中的脚本是否都存在，数量是否与 scripts/ 一致
#   2. 所有 R 文件能否通过 parse()
#   3. Git 跟踪文件中是否混入数据/文档二进制文件
#   4. R 脚本中是否残留明文凭据或硬编码个人路径
#   5. 每个阶段目录是否都有 README.md
# ============================================================

root <- normalizePath(".")
if (!dir.exists(file.path(root, "scripts"))) {
  stop("请在仓库根目录运行：Rscript tools/audit_repo.R")
}

fail <- FALSE
cat("===== TyG-HIV 仓库自检 =====\n")

# ---- 1. 清单一致性 ---------------------------------------------------------
manifest_path <- file.path(root, "docs", "script-manifest.csv")
if (!file.exists(manifest_path)) {
  cat("清单文件            : 缺失\n")
  fail <- TRUE
  man <- NULL
} else {
  man <- read.csv(manifest_path, fileEncoding = "UTF-8",
                  check.names = FALSE, stringsAsFactors = FALSE)
  scripts_on_disk <- list.files(file.path(root, "scripts"), pattern = "[.]R$",
                                recursive = TRUE, full.names = FALSE)
  scripts_on_disk <- setdiff(paste0("scripts/", scripts_on_disk), "scripts/00_setup.R")
  missing_in_manifest <- setdiff(scripts_on_disk, man$script)
  missing_on_disk <- setdiff(man$script, scripts_on_disk)
  cat("清单脚本数          :", nrow(man), "\n")
  cat("scripts/ 下脚本数    :", length(scripts_on_disk), "\n")
  cat("清单有、磁盘无      :", length(missing_on_disk), "\n")
  if (length(missing_on_disk)) cat("  -", paste(missing_on_disk, collapse = "\n  - "), "\n")
  cat("磁盘有、清单无      :", length(missing_in_manifest), "\n")
  if (length(missing_in_manifest)) cat("  -", paste(missing_in_manifest, collapse = "\n  - "), "\n")
  if (length(missing_on_disk) || length(missing_in_manifest)) fail <- TRUE
}

# ---- 2. parse() ------------------------------------------------------------
r_files <- c(
  list.files(file.path(root, "scripts"), pattern = "[.]R$", recursive = TRUE, full.names = TRUE),
  file.path(root, "packages.R"),
  list.files(file.path(root, "tools"), pattern = "[.]R$", recursive = TRUE, full.names = TRUE)
)
r_files <- r_files[file.exists(r_files)]
parse_bad <- character(0)
for (f in r_files) {
  ok <- tryCatch({
    parse(f, encoding = "UTF-8")
    TRUE
  }, error = function(e) {
    cat("  parse 失败:", f, "->", conditionMessage(e), "\n")
    FALSE
  })
  if (!ok) parse_bad <- c(parse_bad, f)
}
cat("R 文件 parse()      :", sprintf("%d 个，%d 失败", length(r_files), length(parse_bad)), "\n")
if (length(parse_bad)) fail <- TRUE

# ---- 3. Git 跟踪文件与数据泄漏 --------------------------------------------
tracked <- tryCatch(
  system2("git", c("ls-files"), stdout = TRUE, stderr = FALSE),
  error = function(e) character(0)
)
data_pattern <- "\\.(xlsx|xls|xlsm|xlsb|csv|tsv|RData|Rdata|rda|rds|sav|dta|parquet|feather|db|sqlite|pdf|docx|pptx|ppt)$"
data_files <- grep(data_pattern, tracked, value = TRUE, ignore.case = TRUE)
cat("Git 跟踪文件        :", length(tracked), "\n")
cat("数据/文档二进制文件 :", length(data_files), "（应为 0）\n")
if (length(data_files)) cat("  -", paste(data_files, collapse = "\n  - "), "\n")
if (length(data_files)) fail <- TRUE

# ---- 4. 凭据与硬编码路径 ---------------------------------------------------
cred_patterns <- c(
  "password\\s*=\\s*['\"][^'\"]+['\"]",
  "passwd\\s*=\\s*['\"][^'\"]+['\"]",
  "token\\s*=\\s*['\"][A-Za-z0-9]",
  "secret\\s*=\\s*['\"][A-Za-z0-9]",
  "api[_-]?key\\s*=\\s*['\"][A-Za-z0-9]",
  "setAccountInfo\\s*\\(",
  "C:/Users/"
)
cred_hits <- character(0)
setwd_hits <- character(0)
scan_files <- r_files[grepl("scripts", r_files) & !grepl("tools", r_files)]
for (f in scan_files) {
  txt_lines <- readLines(f, warn = FALSE, encoding = "UTF-8")
  # 忽略注释行，避免把占位符说明误判为真实凭据
  txt_lines <- txt_lines[!grepl("^\\s*#", txt_lines)]
  txt <- paste(txt_lines, collapse = "\n")
  for (p in cred_patterns) {
    if (grepl(p, txt, perl = TRUE, ignore.case = TRUE)) {
      cred_hits <- c(cred_hits, paste0(sub("^.*/scripts/", "scripts/", f), " :: ", p))
    }
  }
  # 直接 setwd("...")；允许 setwd(Sys.getenv(...))
  if (grepl("setwd\\s*\\(\\s*['\"]", txt, perl = TRUE)) {
    setwd_hits <- c(setwd_hits, sub("^.*/scripts/", "scripts/", f))
  }
}
cat("明文凭据命中        :", length(cred_hits), "（应为 0）\n")
if (length(cred_hits)) cat("  -", paste(cred_hits, collapse = "\n  - "), "\n")
cat("硬编码 setwd()      :", length(setwd_hits), "（应为 0）\n")
if (length(setwd_hits)) cat("  -", paste(setwd_hits, collapse = "\n  - "), "\n")
if (length(cred_hits) || length(setwd_hits)) fail <- TRUE

# ---- 5. 阶段 README --------------------------------------------------------
stages <- unique(man$stage)
missing_readme <- stages[!file.exists(file.path(root, "scripts", stages, "README.md"))]
cat("阶段目录 README     :", sprintf("%d/%d", length(stages) - length(missing_readme), length(stages)), "\n")
if (length(missing_readme)) cat("  -", paste(missing_readme, collapse = "\n  - "), "\n")
if (length(missing_readme)) fail <- TRUE

# ---- 结论 ------------------------------------------------------------------
cat("结论                :", if (fail) "FAIL" else "PASS", "\n")
if (fail) quit(status = 1)
