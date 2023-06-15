install.packages('babynames')
library(babynames)

# many rows? excel's a no-go
xlsx::write.xlsx(babynames, 'babynames.xlsx')

# csv is not size limited
readr::write_csv(babynames, 'babynames.csv')

# maybe just don't use xls(x) at all.
# https://www.bbc.com/news/technology-54423988