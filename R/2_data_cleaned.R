# ## Tidyverse ============================================
#
# library(tibble)
# library(dplyr)
# library(purrr)
#
# # we'll use some example data from dplyr
# print(storms)
#
# # print and glimpse
# glimpse(storms)
#
# ## How to use the pipe
# storms |> print()
#
#
# ## Key functions from 'dplyr'
#
# operations on rows
# - arrange
# - slice
# - distinct
# - filter

# - select
# - mutate
# - summarise
# - group_by
# - count


# ## Arrange sorts the table by any set of variables
# storms |>
#   arrange(-year, -month, -day)
