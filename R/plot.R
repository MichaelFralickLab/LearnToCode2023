library(tidyverse)


random_geom_plot <- function(data, geom, color, text) {

  plt <- data |>
    ggplot() +
    rcartocolor::scale_color_carto_c(
      palette = 'ag_Sunset'
    ) +
    rcartocolor::scale_fill_carto_c(
      palette = 'ag_Sunset'
    ) +
    theme_void() +
    theme(
      panel.background = element_rect(fill = '#000000'),
      plot.background = element_rect(fill = '#000000'))

  plt <- switch(
    geom,
    point = plt + geom_point(
      aes(x, y, color = color),
      size = 4,
      alpha = 0.75,
      show.legend = F
    ),
    line = plt + geom_line(
      aes(x, y, color = color),
      alpha = .76,
      linewidth = 3.2,
      show.legend = F
    ),
    density = plt + geom_density2d(
      aes(x, y),
      show.legend = F,
      color = color,
      linewidth = 2
    ),
    hex = plt + geom_hex(
      aes(x, y),
      show.legend = F,
      linewidth = 2
    ),
    densitypoint = plt +
      geom_density2d(
        aes(x, y),
        show.legend = F,
        color = color,
        linewidth = 2
      ) + geom_point(
        aes(x, y, size = x*y/10, color = color),
      size = 4,
      alpha = 0.75,
      show.legend = F
    )
  )

  if (runif(1, 0, 1) > .05) {
    return(plt)
  }
  return(
    plt +
      geom_text(
        data = tibble(
          x = mean(data$x),
          y = mean(data$y),
          text = str_wrap(text, 15)
        ),
        aes(label = text, x = x/2000, y = y/1000,
            alpha = runif(1, 0.2, 1)),

        color = 'white', size = 20)
  )
}

geoms <- c('point', 'line', 'density', #'bar',
           'density2', 'hex', 'densitypoint')
colors <- c('#ee44e5', '#5faeff', '#5fae9f', '#4444ff')
N <- 1000
bard <-
  bardr::all_works_df |>
  tibble() |>
  filter(name == 'Hamlet',
         !str_detect(content, '[A-Z]{2}+')) |>
  pull(content) |>
  str_replace_all('\032', "'")

config <- tibble(
  id = 1:N,
  geom = sample(geoms, size = N, replace = T),
  color = sample(colors, N, replace = T),
  text = rep(x = sample(bard, N/50, replace = T),
             each = 50),
  data = map(
    .x = id,
    ~tibble(
      x = rnorm(N, mean = 0, sd = 1),
      y = runif(N, -1, 1),
      color = rbeta(N, 1, 2)
    ))
) |>
  group_by(text) |>
  mutate(plt = pmap(
    .l = list(data, geom, color, text),
    .f = \(data, geom, color, text)
      random_geom_plot(data, geom, color, text),
    .progress = T)
    ) |>
  glimpse()


gifski::save_gif(
  expr = walk(config$plt, ~print(.)),
  width = 800,
  height = 800,
  progress = T,
  loop = T,
  delay = .12,
  gif_file = 'gif.gif')




