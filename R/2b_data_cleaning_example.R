library(tidyverse)
library(janitor)

# get the Ottawa Neighbourhood Study data from this url
url <-  "https://www.arcgis.com/sharing/rest/content/items/7cf545f26fb14b3f972116241e073ada/data"

# can read a csv right off the internet
ons <- read_csv(url)

# We need to make it tidy for visualization and analysis...
# we want data to have columns {neighbourhood, date, case rate}

tidy_ons <- 
  ons |> 
  janitor::clean_names() |> 
  select(
    contains('ons_'),
    starts_with('rate')
  ) |> 
  rename_with(
    ~str_remove_all(., '(per_.*?_in_)|(_exc.*?_rh)|ons_|_name')
  ) |> 
  pivot_longer(cols = starts_with('rate'),
               names_to = 'date',
               values_to = 'rate')  |> 
  mutate(
    date = str_remove(date, 'rate_') |> 
      lubridate::parse_date_time('%b_%y') |> 
      lubridate::as_date(),
    rate = suppressWarnings(as.numeric(rate))
  ) |>
  replace_na(list(rate = 0))

# can now compute summary stats easily
tidy_ons |> 
  group_by(neighbourhood) |> 
  summarise(across(
    .cols = rate,
    .fns = list(median = median, min = min, max = max, mean = mean, sd = sd),
    .names = '{.fn}'
  )) |> 
  arrange(desc(median)) |> 
  filter(mean != 0) 

# can now make plots easily
tidy_ons |> 
  ggplot(aes(date, rate + 1, 
             group = neighbourhood,
             color = neighbourhood)) +
  geom_line(alpha = .3, linewidth = .2, show.legend = F) +
  scale_y_log10()

