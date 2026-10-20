# ============================================================
# 公共运行设置
# ------------------------------------------------------------
# 本仓库的脚本默认从同一个目录读取 Excel 中间表（原作者为 D:/Desktop），
# 并把结果写回该目录。换机器时不必修改脚本，只要设置环境变量：
#
#   Windows PowerShell:  $env:TYG_DATA_DIR = "D:/tyg-data"
#   macOS / Linux:       export TYG_DATA_DIR=/path/to/tyg-data
#
# 各脚本中的写法为：
#   setwd(Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop"))
#
# 注意：原始脚本中有少数几步默认指向 D:/Desktop/肝衰竭 或
# D:/Desktop/Cursor；设置 TYG_DATA_DIR 后它们会统一指向同一个数据目录。
# ============================================================

TYG_DATA_DIR <- Sys.getenv("TYG_DATA_DIR", unset = "D:/Desktop")

if (!dir.exists(TYG_DATA_DIR)) {
  warning(
    "数据目录不存在：", TYG_DATA_DIR, "\n",
    "请设置环境变量 TYG_DATA_DIR，或修改本文件中的默认路径。",
    call. = FALSE
  )
} else {
  message("数据目录：", TYG_DATA_DIR)
}

# 便捷路径函数：data_path("tyg-1300-hiv.xlsx")
data_path <- function(...) file.path(TYG_DATA_DIR, ...)

# 切换到数据目录（与原脚本行为一致）
setwd(TYG_DATA_DIR)
