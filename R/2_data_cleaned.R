## Data Handling
#
# We will introduce
# - assignment
# - functions
# - vectors
#   - predicates
#   - vectorized ops
# - lists
# - data-frames
5 %/% 2
5 %% 2


# *Assign* a variable with `<-`




# get the value back later using the name




# the basic data structure in R is the "vector"
# even single values are stored in vectors




# vectors store values of a single data-type
# use c() to create new vectors




# vectors have a specific data-type






# easy ways to make vectors programmatically
# colon operator; seq(); rep()






# vectors can store any type of 'primitive' data






# c() will coerce values to the most generic type





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
# # - arrange
# # - select
# # - filter
# # - mutate
# # - summarise
# # - group_by
#
# ## Arrange sorts the table by any set of variables
# storms |>
#   arrange(-year, -month, -day)
