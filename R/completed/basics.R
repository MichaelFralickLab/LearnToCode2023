## Data Handling -------------------------------------
#
## Rstudio Orientation:
# - Console
# - Editor
# - Env/files/plot (browser)
#

# basic function(value) syntax
print('hello world')

# help!
?print

is.function(print)
is.('hello world')
#
## Concepts ----
#' *assignment*
#' built in *functions()* and *operators*
#' *data structures* {vectors, lists, data-frames }
#' *data types* { primitives, lists, closures }

# *Assign* a variable with `<-`
# see how it's in the environment?
a <- 1

# get the value back later using the name
a

#





# the basic data structure in R is the "vector"
# even single values are stored in vectors
is.vector(a)
typeof(a)
class(a)




# vectors store values of a single data-type
# use c() to create new vectors
b <- c(a, 2:10)
print(b)

# vectors have a specific data-type
typeof(b)
typeof(b)


# predicate functions to test data types
is.double(b)
is.integer(b)


# easy ways to make vectors programmatically
# colon operator; seq(); rep()
0L:9L
seq(0, 100, by = 2)
rep(5, 10)
sample(1:100, 100, replace = T)

# vectors store 1D sequences of 'primitive' data
lgl <- c(TRUE, FALSE, T, F, NA)
chr <- c('Abc', 'Bcd', 'Cdefgh', NA_character_)
dbl <- c(0, 1.1, 2.2, NA_real_, Inf, -Inf, NaN)
# int <- c(0L, 1L, 2L, NA_integer_, Inf, -Inf, NaN)
# cplx <- c(1 + 1i, 2 + 0i, NA_complex_)
# raw <- as.raw(1:100)

# implicit coercion...
# c() will coerce values to the most generic type
d <- c(1, 2, 'A')
typeof(d)
is.vector(d)
is.character(d)
is.numeric(d)

# Quiz: what data type will this vector have?
c(lgl, chr, dbl)

## Vectorized Ops --------------------------------

# Vectorization is implicit iteration:
# many (most) functions in R that deal with primitive values (esp. math, text manipulation) will do multiple computations at once.

# For example: math
1:10 + 2
1:10 - 2
1:10 * 2
1:10 / 2
(1:10)^2
1:10 %/% 2
1:10 %% 2

# For example: text concatenation
paste(LETTERS, letters)
paste(1:10, 1:10)

# What's the issue here?
d <- c(1, 2, 'A')
d + 1

# NA the missing value placeholder
missing <- NA
is.na(missing)

# NA is contagious
1 + 1
NA + 1


# there are other forms of vectors that hold special data types: date, factor, ...
todays_date <- Sys.Date()
right_now <- Sys.time()

# is this data in the Date type?
date()
typeof(date())
class(date())

typeof(todays_date)
class(todays_date)
arms <- c('Treatment', 'Control')
this_is_a_factor <- factor(sample(arms, 100, replace = T), levels =  arms)
summary(this_is_a_factor)
last_hundred_days <-  today:(today - 100) |> as.Date(origin)











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
# ## Hit this pipe
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


























## What you haven't seen (but should learn) ----
#' conditionals: if {} if else {} else {}; switch(){}
#' control flow: for(){} while(){} repeat(){}
#' error handling: try{} catch{}

