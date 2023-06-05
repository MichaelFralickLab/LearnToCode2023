library(tidyverse)

anscombe_long <-
  anscombe |>
  pivot_longer(everything()) |>
  mutate(
    dataset = str_extract(name, '[1-4]'),
    name = str_remove(name, '[1-4]'),
  ) |>
  pivot_wider(
    names_from = name,
    values_from = value,
    values_fn = list
    ) |>
  unnest(c(x, y))

anscombe_long |>
  group_by(dataset) |>
  summarise(across(
    .cols = c(x,y),
    .fns = list(mean = mean, sd = sd, min = min, max = max)
    )
  )

anscombe_long |>
  ggplot(aes(x, y)) +
  geom_point() +
  facet_wrap(~dataset)
