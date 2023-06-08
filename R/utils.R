# turn completed script into bare script for teaching
library(tidyverse)

reset_script <- function(file, outfile){
  readLines(file) |>
    map_chr(~if_else(str_detect(., '^#'), ., '\n')) |>
    write_lines(outfile)
}

fs::dir_ls('completed')
