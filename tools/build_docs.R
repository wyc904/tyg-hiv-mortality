# ============================================================
# 文档生成脚本
# 用法（在仓库根目录）：Rscript tools/build_docs.R
# 输入：docs/script-manifest.csv
# 输出：
#   docs/code-index.md
#   docs/dependencies.md
#   docs/required-data.md
#   docs/package-versions.csv
#   scripts/<stage>/README.md（每个阶段一份）
# ============================================================

root <- normalizePath(".")
man_path <- file.path(root, "docs", "script-manifest.csv")
if (!file.exists(man_path)) stop("找不到 docs/script-manifest.csv")

man <- read.csv(
  man_path,
  fileEncoding = "UTF-8",
  check.names = FALSE,
  stringsAsFactors = FALSE
)

required_cols <- c("stage", "script", "original", "purpose", "inputs",
                   "outputs", "plotting", "run_mode", "notes")
if (!all(required_cols %in% names(man))) {
  stop("清单缺少列：", paste(setdiff(required_cols, names(man)), collapse = ", "))
}

stage_order <- c(
  "01_data_prep", "02_tyg", "03_descriptive", "04_survival",
  "05_prediction", "06_subgroup", "07_cytokine", "08_exploratory",
  "90_archive_mimic_2024", "99_superseded"
)

stage_title <- c(
  "01_data_prep" = "01 数据准备",
  "02_tyg" = "02 TyG 指数与分组",
  "03_descriptive" = "03 描述性分析与绘图",
  "04_survival" = "04 生存分析",
  "05_prediction" = "05 预测性能",
  "06_subgroup" = "06 亚组与森林图",
  "07_cytokine" = "07 细胞因子",
  "08_exploratory" = "08 探索性分析",
  "90_archive_mimic_2024" = "90 2024 年 MIMIC 练习（归档）",
  "99_superseded" = "99 被替代 / 半成品"
)

stage_intro <- c(
  "01_data_prep" = "原始表合并、去重、质控、器官障碍评分与缺失统计，产出后续分析使用的主表。",
  "02_tyg" = "TyG 指数定义、ROC 截断值、二分/三分/四分位分组，以及 MI / TyG 复合因子。",
  "03_descriptive" = "描述性统计与图表：TyG × CD4 死亡率热图、CD4 与死亡的关系曲线。",
  "04_survival" = "生存分析主链：VIF 共线性、Cox 模型、KM、累积死亡、模型比较、交互与联合分析。",
  "05_prediction" = "预测性能评价：ROC / AUC / DeLong、AIC / BIC / Hosmer–Lemeshow、DCA。",
  "06_subgroup" = "亚组 Cox、交互 P 计算与森林图。注意两个 19- 脚本的数值为手工录入。",
  "07_cytokine" = "细胞因子标准曲线标准化、小提琴/散点图、热图与 GraphPad 宽表导出。",
  "08_exploratory" = "探索性中介分析（TyG → CD4 → 28 天死亡）。",
  "90_archive_mimic_2024" = "2024 年 MIMIC-IV / bdmcc 脓毒症数据练习。变量体系与 HIV 主分析不同，不属于论文主分析，仅作方法参考。",
  "99_superseded" = "被替代版本、未完成稿与半成品，保留用于与原始分析记录对照。"
)

run_label <- c(
  "standalone" = "独立运行",
  "session" = "依赖会话对象",
  "template" = "模板/硬编码"
)

plot_label <- c("yes" = "是", "no" = "否")

# ---- 工具函数 --------------------------------------------------------------

split_items <- function(x) {
  if (is.na(x) || !nzchar(x)) return(character(0))
  parts <- trimws(strsplit(x, ";", fixed = TRUE)[[1]])
  parts[nzchar(parts)]
}

is_file_item <- function(x) {
  grepl("\\.(xlsx|xls|xlsm|csv|tsv|rdata|rds|sav|dta|docx|pdf|png|tif|tiff|db|sqlite)$",
        x, ignore.case = TRUE)
}

is_object_item <- function(x) {
  grepl("^\\(会话对象|^\\(脚本内硬编码|^file\\.choose\\(\\)|^mimic4_v22", x)
}

md_cell <- function(x) {
  if (length(x) == 0 || all(is.na(x)) || !any(nzchar(x))) return("—")
  paste(x, collapse = "<br>")
}

rel_link <- function(path, from_dir) {
  # path 为仓库根目录相对路径
  target <- normalizePath(file.path(root, path), mustWork = FALSE)
  base <- normalizePath(file.path(root, from_dir), mustWork = FALSE)
  # Windows 下 normalizePath 会给出反斜杠，统一成正斜杠
  target <- chartr("\\", "/", target)
  base <- chartr("\\", "/", base)
  common <- strsplit(base, "/", fixed = TRUE)[[1]]
  tp <- strsplit(target, "/", fixed = TRUE)[[1]]
  i <- 0
  while (i < length(common) && i < length(tp) && common[i + 1] == tp[i + 1]) i <- i + 1
  up <- rep("..", length(common) - i)
  paste(c(up, tp[(i + 1):length(tp)]), collapse = "/")
}

# ---- 1. docs/code-index.md -------------------------------------------------

lines <- c(
  "# 脚本代码索引",
  "",
  "> 由 [`script-manifest.csv`](script-manifest.csv) 自动生成。修改清单后运行 `Rscript tools/build_docs.R`，不要手工编辑本文件。",
  "",
  sprintf("共 **%d** 个分析脚本，按 **%d** 个阶段分类。每个阶段目录下另有一份 README。", nrow(man), length(stage_order)),
  "",
  "## 总览",
  "",
  "| 阶段 | 目录 | 脚本数 | 其中绘图脚本 |",
  "|---|---|---:|---:|"
)

for (s in stage_order) {
  sub <- man[man$stage == s, , drop = FALSE]
  lines <- c(lines, sprintf(
    "| %s | [`scripts/%s/`](%s) | %d | %d |",
    stage_title[[s]], s, rel_link(file.path("scripts", s, "README.md"), "docs"),
    nrow(sub), sum(sub$plotting == "yes")
  ))
}
lines <- c(lines, "")

for (s in stage_order) {
  sub <- man[man$stage == s, , drop = FALSE]
  lines <- c(
    lines,
    sprintf("## %s（`scripts/%s/`）", stage_title[[s]], s),
    "",
    stage_intro[[s]],
    "",
    "| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |",
    "|---|---|---|---|:---:|---|---|"
  )
  for (i in seq_len(nrow(sub))) {
    r <- sub[i, ]
    lines <- c(lines, sprintf(
      "| [`%s`](%s) | %s | %s | %s | %s | %s | %s |",
      basename(r$script), rel_link(r$script, "docs"), r$purpose,
      md_cell(split_items(r$inputs)), md_cell(split_items(r$outputs)),
      plot_label[[r$plotting]], run_label[[r$run_mode]], r$notes
    ))
  }
  lines <- c(lines, "")
}
writeLines(enc2utf8(lines), file.path(root, "docs", "code-index.md"), useBytes = TRUE)

# ---- 2. 每个阶段的 README --------------------------------------------------

for (s in stage_order) {
  sub <- man[man$stage == s, , drop = FALSE]
  out_dir <- file.path(root, "scripts", s)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  rel_docs <- rel_link("docs/code-index.md", file.path("scripts", s))
  rel_manifest <- rel_link("docs/script-manifest.csv", file.path("scripts", s))

  lines <- c(
    sprintf("# %s", stage_title[[s]]),
    "",
    stage_intro[[s]],
    "",
    sprintf("本目录共 **%d** 个脚本，其中绘图脚本 **%d** 个。", nrow(sub), sum(sub$plotting == "yes")),
    "",
    sprintf("- 返回总索引：[docs/code-index.md](%s)", rel_docs),
    sprintf("- 机器可读清单：[docs/script-manifest.csv](%s)", rel_manifest),
    "- 数据与运行方式见仓库根目录 `README.md` 与 `docs/pipeline.md`。",
    "",
    "| 脚本 | 作用 | 输入 | 输出 | 绘图 | 运行方式 | 备注 |",
    "|---|---|---|---|:---:|---|---|"
  )
  for (i in seq_len(nrow(sub))) {
    r <- sub[i, ]
    lines <- c(lines, sprintf(
      "| [`%s`](%s) | %s | %s | %s | %s | %s | %s |",
      basename(r$script), basename(r$script), r$purpose,
      md_cell(split_items(r$inputs)), md_cell(split_items(r$outputs)),
      plot_label[[r$plotting]], run_label[[r$run_mode]], r$notes
    ))
  }
  lines <- c(lines, "")
  writeLines(enc2utf8(lines), file.path(out_dir, "README.md"), useBytes = TRUE)
}

# ---- 3. docs/dependencies.md ----------------------------------------------

produced <- list()
for (i in seq_len(nrow(man))) {
  for (f in split_items(man$outputs[i])) {
    if (!is_file_item(f)) next
    produced[[f]] <- c(produced[[f]], man$script[i])
  }
}

consumed <- list()
for (i in seq_len(nrow(man))) {
  for (f in split_items(man$inputs[i])) {
    if (!is_file_item(f)) next
    consumed[[f]] <- c(consumed[[f]], man$script[i])
  }
}

edges <- data.frame(producer = character(0), file = character(0), consumer = character(0),
                    stringsAsFactors = FALSE)
for (f in names(produced)) {
  if (!f %in% names(consumed)) next
  for (p in unique(produced[[f]])) {
    for (c in unique(consumed[[f]])) {
      edges <- rbind(edges, data.frame(producer = p, file = f, consumer = c,
                                       stringsAsFactors = FALSE))
    }
  }
}
edges <- unique(edges)

all_names <- union(names(produced), names(consumed))
# 只把“被多个脚本写入”的文件视为歧义；共享外部输入不算
ambiguous <- all_names[lengths(produced[all_names]) > 1]
terminal <- setdiff(names(produced), names(consumed))
external <- setdiff(names(consumed), names(produced))

lines <- c(
  "# 脚本依赖关系",
  "",
  "> 由 [`script-manifest.csv`](script-manifest.csv) 中的文件名自动推断。",
  "> 这是**按文件名匹配**的近似依赖图；通过变量拼接路径、`list.files()` 批量读取，或直接使用会话内存对象的依赖不会出现在确定依赖中。",
  "",
  "## 1. 生产者 → 消费者（确定依赖）",
  "",
  if (nrow(edges)) c("| 上游脚本 | 产物 | 下游脚本 |", "|---|---|---|") else "未发现文件级确定依赖。",
  if (nrow(edges)) sprintf("| `%s` | `%s` | `%s` |", edges$producer, edges$file, edges$consumer) else character(0),
  "",
  "## 2. 同名 / 歧义文件",
  "",
  "| 文件名 | 被写入次数 | 被读取次数 | 说明 |",
  "|---|---:|---:|---|",
  if (length(ambiguous)) sprintf(
    "| `%s` | %d | %d | 同名中间表可能指向不同版本，需人工确认 |",
    ambiguous, lengths(produced[ambiguous]), lengths(consumed[ambiguous])
  ) else "| — | 0 | 0 | 无 |",
  "",
  "## 3. 只写不读的产物（终点输出）",
  "",
  "| 产物 | 生成脚本 |",
  "|---|---|",
  if (length(terminal)) sprintf("| `%s` | `%s` |", terminal, sapply(terminal, function(f) paste(unique(produced[[f]]), collapse = "；"))) else "| — | — |",
  "",
  "## 4. 外部输入（不由仓库内脚本生成）",
  "",
  sprintf("共 **%d** 个文件会作为输入被读取，但仓库内没有对应产物；清单见 [`required-data.md`](required-data.md)。", length(external)),
  ""
)
writeLines(enc2utf8(lines), file.path(root, "docs", "dependencies.md"), useBytes = TRUE)

# ---- 4. docs/required-data.md ---------------------------------------------

lines <- c(
  "# 原始数据准备清单",
  "",
  "下表列出**不是由仓库内脚本生成、必须由使用者提供**的输入文件。",
  "把这些文件放入 `TYG_DATA_DIR` 指向的目录，即可按 [`pipeline.md`](pipeline.md) 运行。",
  "",
  sprintf("- 外部输入文件：**%d** 个", length(external)),
  sprintf("- 仓库内脚本生成的中间文件：**%d** 个", length(intersect(names(produced), names(consumed)))),
  sprintf("- 同名/歧义文件：**%d** 个（见 [`dependencies.md`](dependencies.md) 第 2 节）", length(ambiguous)),
  "",
  "> 通过变量拼接路径、`list.files()` 批量读取或循环写入的文件无法被静态识别，个别“原始输入”实际上可能是上游脚本动态生成的中间表。",
  "",
  "## 文件清单",
  "",
  "| 原始文件 | 使用它的脚本 |",
  "|---|---|"
)
if (length(external)) {
  for (f in sort(external)) {
    lines <- c(lines, sprintf("| `%s` | %s |", f,
                              paste(sprintf("`%s`", unique(consumed[[f]])), collapse = "<br>")))
  }
} else {
  lines <- c(lines, "| — | — |")
}
lines <- c(lines, "")
writeLines(enc2utf8(lines), file.path(root, "docs", "required-data.md"), useBytes = TRUE)

# ---- 5. docs/package-versions.csv -----------------------------------------

r_files <- c(
  list.files(file.path(root, "scripts"), pattern = "[.]R$", recursive = TRUE, full.names = TRUE),
  file.path(root, "packages.R")
)

pkg_hits <- list()
add_pkg <- function(pkg, file) {
  pkg <- trimws(pkg)
  if (!nzchar(pkg)) return()
  pkg_hits[[pkg]] <<- unique(c(pkg_hits[[pkg]], file))
}
for (f in r_files) {
  txt <- readLines(f, warn = FALSE, encoding = "UTF-8")
  for (line in txt) {
    m <- regmatches(line, gregexpr("(?:library|require)\\(([A-Za-z0-9_.]+)\\)", line, perl = TRUE))[[1]]
    for (hit in m) {
      pkg <- sub("^(?:library|require)\\(([A-Za-z0-9_.]+)\\)$", "\\1", hit)
      add_pkg(pkg, basename(f))
    }
    m2 <- regmatches(line, gregexpr("\\b([A-Za-z][A-Za-z0-9_.]*)::", line, perl = TRUE))[[1]]
    for (hit in m2) {
      add_pkg(sub("::$", "", hit), basename(f))
    }
  }
}

pkgs <- sort(names(pkg_hits))
versions <- vapply(pkgs, function(p) {
  if (requireNamespace(p, quietly = TRUE)) as.character(packageVersion(p)) else NA_character_
}, character(1))
counts <- lengths(pkg_hits[pkgs])
pkg_df <- data.frame(
  package = pkgs,
  version = versions,
  installed = !is.na(versions),
  used_by_scripts = counts,
  stringsAsFactors = FALSE
)
pkg_df <- pkg_df[order(-pkg_df$used_by_scripts, pkg_df$package), ]
write.csv(pkg_df, file.path(root, "docs", "package-versions.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

cat("Generated:\n")
cat("  docs/code-index.md\n")
cat("  docs/dependencies.md\n")
cat("  docs/required-data.md\n")
cat("  docs/package-versions.csv\n")
cat("  scripts/*/README.md\n")
cat("Scripts:", nrow(man), "| packages:", nrow(pkg_df), "| dependencies:", nrow(edges), "\n")
