# turn completed script into bare script for teaching
library(tidyverse)

reset_script <- function(file, outfile){
  readLines(file) |>
    map_chr(~str_detect(., '^#') |> if_else(., '\n')) |>
    write_lines(outfile)
}

fs::dir_ls('completed')
