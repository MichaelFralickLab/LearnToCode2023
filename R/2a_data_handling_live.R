# ---------------------------------------------
# Data Handling with `dplyr` & friends
# ---------------------------------------------

# load core tidyverse
library(tidyverse)

# Get some example data for learning dplyr...
# 'sw' gets the starwars data from dpylr
# This data is a tibble dataframe (tbl_df)
# Here's some different ways to inspect data.


# -------------------------
# Operations on table rows
# -------------------------

# We'll start with operations on rows, using:
# filter | arrange | slice | distinct | bind_rows

# `filter` subsets rows passing your conditions
# `arrange` sorts the rows based on selected variables
# `slice` subsets rows by position
# `distinct` remove duplicated rows
# `bind_rows` adds new rows

#' *CHALLENGE*:
# Find the three tallest starwars characters
# from the group of non-human characters lighter
# than 50 kg. 

# -------------------------
# Operations on columns
# -------------------------

# `select` gets a subset of columns (tidyselect)
# `pull` gets a single column out as vector or list
# `mutate` creates or modifies variables
# `rename` columns individually 
# or `rename_with` to use functions on col names.

# -----------------------------------
# Aggregation and grouped operations
# -----------------------------------

# `group_by` groups observations for later operations

# `summarise` aggregates groups of rows into a single row for each group

# `count` number of rows per group


#' *CHALLENGE*: 
#' compute the number of observations, the mean, and the standard deviation (sd), for the masses and heights of starwars characters, separately for the male and female characters.
#' bonus: include how many species are represented

# sex | n  | height_mn | height_sd | mass_mn | mass_sd
# ----------------------------------------------------
# f   | ...| ...
# m   | ...| ...





# --------------------------------------
# Advanced: Pivots, Joins, and Nesting
# --------------------------------------

# Pivots - transpose column names to values (longer)
#  or values to column names (wider)
# Joins - link values from two tables based on keys.
# Nesting - nest multiple values per row in a list col

# `pivot_longer` -> turn column names into values
# `pivot_wider` -> turn values into column names

# `left_join` -> keeps all rows in left
# `right_join` -> keeps all rows in right
# `full_join` -> keeps all rows in both
# `anti_join` -> keeps all rows not in left

# `nest` and `unnnest` multiple values in list columns