# ggplot2_polyps.R -------
# a quickstart guide to plotting with ggplot2

# Remember there's a cheat sheet to help you!
# https://github.com/rstudio/cheatsheets/blob/main/data-visualization.pdf

## Libraries ------

#' first, do this once to install the packages we need:
# install.packages(
#   c('tidyverse', 'janitor', 'ggrepel', 'ggbeeswarm',
#     'patchwork', 'scales', 'ggtext', 'medicaldata')
#   )

# check out the environment pane... see global...

# use library() to load packages
library(tidyverse)
library(janitor)
library(ggtext)
library(medicaldata)



## Data ----------

# assign data to an obj in the global environment
polyps <- medicaldata::polyps

# check out the data
polyps |> str()


## Simple example ------

# verbose
ggplot(data = polyps, mapping = aes(x = sex)) +
  geom_bar()

# terse
ggplot(polyps, aes(sex)) +
  geom_bar()

# or specify data and aes on individual geoms
ggplot() +
  geom_bar(data = polyps, aes(x = sex))




#' *do a bar plot for treatment arms: are sample sizes equal?*
ggplot(data = polyps, mapping = aes(treatment)) +
  geom_bar()


## notes
# data can be global or specified in layers
# aes can be global or specified in layers
# use '+' to add more layers to same canvas


## geom_*s ---------------

# _bar computes a stat (count)
# alternately compute bar height and use geom_col
# polyps |>
  count(polyps, treatment) |>
  ggplot(aes(x = treatment, y = n)) +
  geom_col()

# protip: flip groups onto y-axis
polyps |>
  ggplot(aes(y = treatment)) +
  geom_bar()

# add colouring for 2nd set of categories
# default position is 'stack' bar
polyps |>
  ggplot() +
  geom_bar(aes(y = treatment, fill = sex),
           position = 'stack')

# position argument changes geom appearance
polyps |>
  ggplot() +
  geom_bar(aes(y = treatment, fill = sex),
           position = 'dodge')

# stack & normalize total to 1
polyps |>
  ggplot() +
  geom_bar(aes(y = treatment, fill = sex),
           position = 'fill')



## Histogram, other distributions

# histo
polyps |>
  ggplot(aes(x = baseline)) +
  geom_histogram(aes(fill = treatment),
                 bins = 10,
                 position = 'stack')

# density
polyps |>
  ggplot(aes(x = baseline)) +
  geom_density(aes(color = treatment))


## Comparing distributions
polyps |>
  ggplot(aes(baseline, treatment)) +
  geom_boxplot()

# scattered points
polyps |>
  ggplot(aes(baseline, treatment)) +
  geom_jitter(aes(size = age, color = sex),
              height = .35,
              alpha = .5)

# nicer shape with this ggbeeswarm::geom_beeswarm
# no overlaps!
polyps |>
  ggplot(aes(baseline, treatment,
             # color = sex,
             # size = age
             )) +
  ggbeeswarm::geom_beeswarm(
    alpha = .81,
    cex = 5,
    show.legend = F
  )


## Scatterplots -----

# examine corr between baseline & 3mo timepoint
# stratify by sex...
p <-
  polyps |>
  ggplot(aes(
    x = baseline,
    y = number3m,
    color = sex,
    fill = sex
  )) +
  geom_point(aes(size = age),
             shape = 1,
             alpha = .76,
             size = 2.5) +
  geom_smooth(method = 'lm',
              formula = 'y ~ x',
              linewidth = .25,
              alpha = .2)

#
p
print(p)

# SCALES ---------------

# alter aesthetic mappings
p +
  scale_color_viridis_d(begin = .2, end = .7) +
  scale_fill_viridis_d(begin = .2, end = .7) +
  scale_y_log10() +
  scale_x_log10()

# LABS ---------------

# add labs() to pretty it up
p <- p +
  labs(
    x = 'Polyps at Baseline (n)',
    y = 'Polyps at 3 mo (n)',
    fill = 'Sex', color = 'Sex',
    title = 'My Title',
    subtitle = 'My subtitle'
  )
print(p)



# FACETS ---------------

polyps_long <-
  polyps |>
  select(where(is.numeric)) |>
  pivot_longer(everything())

a <- polyps_long |>
  ggplot(aes(value)) +
  geom_histogram(bins = 10, na.rm = T) +
  facet_wrap(~name, scales = 'free_x') +
  scale_y_continuous(breaks = scales::pretty_breaks())

a

# Patchwork ------

a + p


# THEME ---------------

# easy: use a preset theme_ on individual plot
p + theme_classic()

# harder: customize theme with theme()
p + theme(
  panel.border = element_blank(),
  axis.line = element_line(colour = 'red'),
  legend.text = element_text(
    family = 'mono',
    face = 'italic',
    size = 12,
    colour = 'blue',
    angle = 15,
    hjust = 1,
    vjust = 1
  ),
  axis.title = element_text(family = 'Tourney'),
  plot.title = element_text(family = 'Papyrus'),
  plot.subtitle = element_text(family = 'Wingdings')
)

# can add multiple theme_*, eg. a preset + custom
# recommended: set a global theme
theme_set(
  theme_bw() + theme(
    # remove any element w element_blank()
    panel.border = element_blank(),
    # otherwise use element_* to modify properties
    axis.line = element_line(
      colour = 'purple',
      arrow = grid::arrow(
        type = 'closed',
        length = unit(x = 1, 'mm')),
    )))

print(p)

theme_set(theme_bw())



# Save to file -------

ggsave('filename_goes_here.png', plot = p, device = 'png')
ggsave('filename_goes_here.pdf', plot = p, device = 'pdf')
ggsave('filename_goes_here.svg', plot = p, device = 'svg')



## Recap/extend: a more complex example

polyps_by_timept <-
  polyps |>
  pivot_longer(
    cols = c(baseline, number3m, number12m),
    names_to = 'time',
    values_to = 'polyps'
  ) |>
  mutate(
    time = str_remove(time, 'number') |>
      factor(levels = c('baseline', '3m', '12m')),
    across(c(treatment, sex), str_to_title)
    ) |>
  filter(!is.na(polyps))

fig <- polyps_by_timept |>
  ggplot(aes(fct_rev(time), polyps)) +
  ggbeeswarm::geom_quasirandom(
    aes(color = sex),
    width = .20,
    shape = 1,
    dodge.width = .5,
    size = .8
    ) +
  stat_summary(
    fun.data = mean_cl_boot,
    mapping = aes(color = sex),
    alpha = .5,
    geom = "pointrange",
    position = position_dodge(width = .5),
    fun.args = list(conf.int = .95)
  ) +
  facet_wrap(~treatment, ncol = 1) +
  rcartocolor::scale_color_carto_d() +
  scale_y_log10() +
  labs(
    x = 'Timepoint',
    y = 'Polyp count',
    color = 'Sex',
    title = 'RCT of Sulindac for Polyp Prevention in <br/> Familial Adenomatous Polyposis',
    subtitle = 'Pointranges show group mean and 95% CI',
    caption = 'Source: *medicaldata::polyps*'
  ) +
  theme(
    plot.title = ggtext::element_markdown(
      padding = unit(x = c(0,0,0,0), units = 'mm'),
      margin = unit(x = c(0,0,2,0), units = 'mm'),
      lineheight = 1.1,
      size = 10
    ),
    plot.subtitle = ggtext::element_markdown(
      face = 'italic',
      family = 'Roboto',
      size = 9
      ),
    plot.caption = ggtext::element_markdown(),
    strip.background = element_blank(),
    strip.text = element_markdown(
      margin = unit(c(0,0,0,0), 'mm'),
      hjust = 0, size = 8, face = 'bold')

  ) +
  coord_flip()

fig


## Stats ----

# a duality between stats & geoms

# same as a barplot
ggplot(polyps, aes(y = sex)) + stat_count()

# other styles available
ggplot(polyps, aes(x = baseline, color = sex)) +
  stat_ecdf()


# I'm not a huge fan of stat_*; prefer to compute results separately, beforehand, in my data-handling steps where possible...





# COORDS ---------------

# not used too often but you can, eg.
# circular plots with coord_polar()
tibble(
  # simulate data
  x = sample(x = 1:12, size = 100, replace = T),
  y = rpois(n = 100, lambda = 20),
  z = sample(c(T, F), 100, replace = T)
) |>
  ggplot(aes(x, y, fill = z)) +
  coord_polar() +
  geom_col() +
  scale_x_continuous(
    breaks = scales::pretty_breaks(),
    limits = c(0, 12)
  )
