# ---------------------------------------------
# Data Handling with `dplyr` & friends
# ---------------------------------------------

# load core tidyverse
library(tidyverse)

# get some example data for learning dplyr...
# 'sw' gets the starwars data from dpylr
sw <- dplyr::starwars

# this data is a tibble (tbl) dataframe
class(sw)

# different ways to inspect data
print(sw)
# str(sw)
# glimpse(sw)
# View(sw)


# -------------------------
# Operations on table rows
# -------------------------

# We'll start with operations on rows, using:
# `filter`, `arrange`, `slice`, `distinct`

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

# `distinct` remove duplicated rows
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
sw |> select(name, species)

# use colon to get a range 
sw |> select(name:sex)

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

# ------------------------------
# Reshaping Tables with `tidyr`
# ------------------------------

# Pivot tables are a very common form of untidy data.
# They usually have a single variable across multiple columns for the repeated observations on a subject.

example <- tribble(
  ~name, ~value,
  'A', 1,
  'B', 2,
  'C', 3
) |> 
  print()

wide <- example |> 
  pivot_wider(names_from = name, 
              values_from = value) |> 
  print()

long <- wide |> 
  pivot_longer(cols = everything(),
               names_to = 'name',
               values_to = 'value') |> 
  print()


# pivot_longer useful with pivot tables
# turn years to single column to tidy
tribble(
  ~key, ~'2020', ~'2021', ~'2022',
  'A', 1, 9, 5,
  'B', 2, 8, 3,
  'C', 3, 7, 1
) |> 
  pivot_longer(`2020`:`2022`, names_to = 'year')


# pivot_wider useful for creating indicators
# generate an indicator for each starship
pilots <- sw |> 
  select(name, starships) |> 
  unnest(starships, keep_empty = T) |> 
  mutate(value = T) |> 
  pivot_wider(names_from = starships, 
              names_prefix = 'pilot_',
              values_from = value,
              values_fill = F,
              names_repair = 'universal') |> 
  select(-pilot_NA) |> 
  glimpse()
  

# We have `pivot_longer` which takes columns, and reshapes them so that the new ones have either the former names and or the values.
pilots |> 
  pivot_longer(contains('pilot'),
               names_to = 'ship', 
               ) |> 
  filter(value) |> 
  select(-value) |> 
  mutate(
    ship = str_remove(ship, 'pilot_') |> 
      str_replace_all('\\.', ' '))




## Read & Write Common Filetypes ----------------

# read/write common file types
# readr::write_*
# readr::read_*



# read in a file


## Worked examples with various forms -----

library(readxl)    # parses excel data
library(janitor)   # more helpers
library(rvest)

# Data from `medicaldata`
# https://cran.r-project.org/web/packages/medicaldata/index.html


## Web Scraping ----

# the art of extracting data from html
# (1) download the html from a url
# (2) then find the right element to target
# (3) parse the html into a dataframe (tibble)
#
# NB - Don't use 'scraping' in any other context
# querying a database is not scraping


# simple example using rvest
source_url <- 'https://higgi13425.github.io/medicaldata/#available-messy-datasets-beta'

# get the table with the messy datasets
datasets <-
  # read the webpage into R
  rvest::read_html(source_url) |>
  # extract all tables from html
  rvest::html_nodes('table') |>
  # take the second table from the list
  purrr::pluck(2) |>
  # parse the table into a dataframe
  rvest::html_table() |>
  # clean those names so no spaces
  janitor::clean_names() |>
  # all done
  glimpse()







## Filesystem -----

# R code uses file paths relative to the current
# working directory (wherever you opened Rstudio).
# Find out where your working directory is with:
getwd()

# PSA don't use setwd() -> not reproducible!
# Use Rprojects & set your paths relative to 'project root' (aka '.') where your .Rproj file lives.

# open a project, sets wd at the project root
here::here() == getwd()

# here::here is a helper to get the absolute path
here::here('...some_path/to/files')

# ^ especially useful when code is running elsewhere, eg. live on a server, or with a collaborator.

# lets download all those excels but
# we want ensure our destination directory
# exists first!
destdir <- 'data/messy_excels/'
if (!dir.exists(destdir)) {
  dir.create(destdir, recursive = T)
}

# to download the excels...
# 1. create the destination file paths
# 2. fix the urls - they have the bad quotes
#
datasets |>
  mutate(
    # fix the urls
    url = str_remove_all(url, '“|”'),
    # url = str_sub(url, 2L, -2L),
    dest = str_glue('{destdir}{dataset}.xlsx'),
    download = map2_lgl(url, dest, download.file)
    ) |>
  glimpse()

