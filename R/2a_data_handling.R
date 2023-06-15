#----------------------------------------------
# Data Handling with `dplyr` & friends
#----------------------------------------------

# load core tidyverse
library(tidyverse)

# get some example data for learning dplyr...
# 'sw' gets the starwars data from dpylr
sw <- dplyr::starwars

# this data is a tibble (tbl) dataframe
class(sw)

# different ways to inspect data
print(sw)
# glimpse(sw)
# View(sw)


# -------------------------
# Operations on table rows
# -------------------------

# We'll start with operations on rows, using:
# `filter`, `arrange`, `slice`, 
# `distinct`, and `bind_rows`

# `filter` subsets rows passing your conditions
sw |>
  filter(
    height >= 100,
    eye_color == 'brown',
    hair_color %in% c('black', 'none'),
    str_detect(name, '^B'),
    !is.na(species)
  )

# `arrange` sorts the rows based on selected variables
sw |> arrange(sex, desc(mass))

# `slice` subsets rows by position
sw |> slice(1:10)

# but there are other variants
sw |> slice_head(n = 10)
sw |> slice_max(mass)
sw |> slice_sample(n = 10)

# `distinct` removes duplicated rows
sw |> distinct(homeworld, species)

# `bind_rows` adds new rows
sw |> bind_rows(sw) |> distinct()


#' *CHALLENGE*:
#' find the three tallest characters from the group
#' of non-human characters lighter than 50 kg. 
sw |> 
  filter(species != 'Human', mass < 50) |> 
  slice_max(height, n = 3) |> 
  print()


# -------------------------
# Operations on columns
# -------------------------

# `select` gets a subset of columns
sw |> select(name, height, mass)

# use colon to get a range 
sw |> select(name:mass)

# tidyselect helpers for picking multiple columns...
# everything()
sw |> select(mass, everything())

# contains(), starts_with(), ends_with(), matches()
sw |> select(contains('color'))

# where(~f(x))
sw |> select(name, where(~is.list(.)))

# use minus to remove cols
sw |> select(-where(is.list)) |> glimpse()

#
# `pull` gets a single column out as vector or list
sw$species
sw[['species']]
sw |> pull(species)


# `mutate` creates/modifies variables
sw |>
  mutate(height_mass_prod = height * mass) |> 
  glimpse()

# functions that you might use within mutate:
# (not exhaustive!) 
# math: + - * / ^ %/% %% 
# transformations with math: log, sqrt
# cumulative math
# rankings, percentiles... 
# lead() & lag() to get a value from other rows
# boolean algebra:  ! & |  xor(x, y)
# inequality: < <= == >= > 
# string ops with stringr::str_*/

sw |> 
  select(name, height) |> 
  mutate(lag_height = lag(height),
         delta = height - lag_height)

# `mutate(across(cols, fns))` does multiple cols & fns
sw |>
  mutate(
    across(
      .cols = ends_with('color'), 
      .fns = ~as_factor(.)
    )
  ) |> 
  glimpse()

# use `map` with list columns
sw |>
  mutate(
    is_xwing_pilot = map_lgl(.x = starships, 
                             .f = ~'X-wing' %in% .)
    ) |>
  glimpse()

# `rename` columns individually or `_with` functions.
sw |>
  rename(fullname = name) |>
  rename_with(
    ~ str_replace_all(., '_', ' ') |>  str_to_title()
  ) |> 
  gt::gt()




# -----------------------------------
# Aggregation and grouped operations
# -----------------------------------

# `group_by` groups observations for later operations
# `summarise` aggregates groups of rows into a single row
# ie. (grouped) data -> (per-group) results


# `summarise` computes stats for whole dataset if not grouped
sw |> summarise(n_characters = n())

# `group_by` only modifies the grouping attribute on the df,
# doesn't modify the data on it's own
sw |> group_by(sex)

# summarise grouped data
sw |> group_by(sex) |> summarise(n_characters = n())

# an easier way to do a count
sw |> count(sex)


# why doesn't this work??
sw |> summarise(height = mean(height))

# missing values are contagious, remove them
sw |> summarise(height = mean(height, na.rm = T))


# summarise obs by group
sw |>
  group_by(sex) |>
  summarise(
    n = n(),
    height_mean = mean(height, na.rm = T),
    .groups = 'drop'
  ) |>
  arrange(desc(height_mean))


# summarise with across
sum_tbl <-
  sw |>
  group_by(sex) |>
  summarise(
    n = n(),
    across(
      .cols = c(mass, height), 
      .fns = list(
        avail = ~sum(!is.na(.)),
        mass_mn = ~mean(., na.rm = T),
        mass_sd = ~sd(., na.rm = T)
      ))
  )


# ### Nesting Data

# expand a list column to multiple rows/cols...
sw |> 
  select(name, starships) |> 
  unnest(starships)

# nest multiple rows/cols
# use map on list cols, including nested tbls
sw |> 
  group_nest(species, .key = 'characters') |> 
  mutate(biggest = map(characters, ~. |> slice_max(mass))) |> 
  unnest(biggest) |>
  print()







# --------------------------------------
# Advanced: Pivots, Joins, and Nesting
# --------------------------------------

# Pivots - transpose column names to values (longer)
#  or values to column names (wider)
# Joins - link values from two tables based on keys.
# Nesting - nest multiple values per row in a list col

# `pivot_longer` -> turn column names into values
# `pivot_wider` -> turn values into column names
summary_tbl |> 
  pivot_longer(cols = -sex, names_to = 'variable') |> 
  pivot_wider(names_from = sex, values_from = value)

# left-join
patients <- tibble(
  patient_id = c(LETTERS[1:10], 'ZZ'),
  doctor_id = c(sample(letters, size = 10, replace = T), NA)
) |> 
  print()

doctors <- tibble(doctor_id = letters,
                  score = rnorm(26))

# want to see what the doctor's score is for each patient...
patients |> left_join(doctors, by = 'doctor_id')

patients |> 
  full_join(doctors, by = 'doctor_id') |> 
  print(n = 50)

doctors |> 
  anti_join(patients, by = 'doctor_id') |> 
  print(n = 50)


# unnest
unnested <- sw |> 
  select(name, films) |> 
  unnest(films) |> 
  print()

# re-nest
sw |>   
  select(name, films) |> 
  unnest(films) |> 
  nest(data = films)

sw |>   
  select(name, films) |> 
  unnest(films) |> 
  group_by(name) |> 
  summarise(films = list(films))


















