
## Web Scraping ----

# the art of extracting data from html
# (1) download the html from a url
# (2) then find the right element to target
# (3) parse the html into a dataframe (tibble)
#
# NB - Don't use 'scraping' in any other context
# querying a database is not scraping


library(tidyverse)
library(rvest)

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
