# https://hanukkah.bluebird.sh/5783/
#

#
# Get data from here:
# https://hanukkah.bluebird.sh/5783/data/
#
# Download the sqlite data and unzip with passcode 5777

library(fs)
library(curl)
library(DBI)
library(dplyr)
library(purrr)

# make a directory called data, if it doesn't exist
fs::dir_create('data')

# download the data
curl::curl_download(
  url = "https://hanukkah.bluebird.sh/5783/noahs-sqlite.zip",
  destfile = 'data/noahs-sqlite.zip'
  )

# unzip the file with password 5777
system('unzip -o -P 5777 data/noahs-sqlite.zip -d data')

# setup the database in memory from the unzipped file
db <- DBI::dbConnect(
  drv = RSQLite::SQLite(),
  dbname = 'data/noahs.sqlite'
)

# chechkout what tables are in the db
tables <- DBI::dbListTables(db) |> print()

tables |>
  purrr::set_names(tables) |>
  purrr::walk(
    ~{print(.); tbl(db, .) |> glimpse()}
  )


orders <- tbl(db, 'orders')


new_orders <- orders |>
  collect() |>
  select(-items)


DBI::dbWriteTable(db, 'orders', new_orders, overwrite = T)


orders |> glimpse()
