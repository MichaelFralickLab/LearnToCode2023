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


## Simple examples & syntax explanation ------

ggplot(data = polyps,
       mapping = aes(x = age,
                     y = baseline)
       ) +
  geom_point()


# verbose
ggplot(data = polyps, mapping = aes(x = sex)) +
  geom_bar()

# terse
polyps |>
  ggplot(aes(sex)) +
  geom_bar()

# or specify data and aes on individual geoms
ggplot() +
  geom_bar(data = polyps, aes(sex))


#' *Do a quick bar plot showing randomization to each treatment arm. Are sample sizes equal?*


## notes
# data can be across all geom_*s or specified w/in a geom_* layer
# aes can be global or specified in layers
# use '+' to add more layers to same canvas


## geom_*s & aes---------------

# protip: flip groups onto y-axis for legibility
starwars |>
  ggplot(aes(x = species)) +
  geom_bar()

starwars |>
  ggplot(aes(y = fct_rev(species))) +
  geom_bar()


# add colouring for 2nd set of categories
# one geom - different 'position' adjutsments
polyps |>
  ggplot() +
  geom_bar(
    aes(y = treatment, fill = sex),
    # position => stack, fill, dodge, ...
    position = 'dodge'
  )

# _bar computes a stat (count)
# alternately compute bar height and use geom_col
polyps |>
  count(treatment) |>
  ggplot(aes(x = treatment, y = n)) +
  geom_col()


# Continuous Distributions... lets' examine `baseline`

# histograms
polyps |>
  ggplot(aes(x = baseline)) +
  geom_histogram(aes(fill = treatment),
                 bins = 10,
                 position = 'stack')

# density lines
polyps |>
  ggplot(aes(x = baseline)) +
  geom_density(aes(color = treatment))

# boxplots
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
# less overplotting!
polyps |>
  ggplot(aes(baseline, treatment,
             color = sex,
             size = age
             )) +
  ggbeeswarm::geom_beeswarm(
    alpha = .5,
    cex = 5,
    show.legend = F
  )



## Adjusting aesthetics -----

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
  geom_point(
    aes(size = age),
    # see cheat sheet
    shape = 1,
    # transparency range 0-1
    alpha = .76
  ) +
  # add a linear fit (lm)
  geom_smooth(method = 'lm',
              formula = 'y ~ x',
              linewidth = .25,
              alpha = .2,
              show.legend = F)

print(p)


#' *make this plot look better, add a fit line(s)*
ggplot2::diamonds |>
  ggplot(aes(carat, price)) +
  geom_point()


#' *make this plot look better*: solved
ggplot2::diamonds |>
  ggplot(aes(carat, price, color = cut)) +
  geom_point(size = .1, shape = 0, alpha = .5) +
  guides(color = guide_legend(
    override.aes = list(size = 5, shape = 15, alpha = 1)
  ))

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
    title = 'Polyps at 3 months ~ baseline ',
    subtitle = 'strong positive correlation...'
  )

print(p)



# FACETS ---------------

polyps_long <-
  polyps |>
  select(where(is.numeric)) |>
  pivot_longer(everything())

polyps_long |>
  ggplot(aes(value)) +
  geom_histogram(bins = 10, na.rm = T) +
  facet_wrap(~name, scales = 'free_x') +
  scale_y_continuous(breaks = scales::pretty_breaks())



# Patchwork ------

# grab some plots from earlier just to illustrate...
a <- polyps_long |>
  ggplot(aes(value)) +
  geom_histogram(bins = 10, na.rm = T) +
  facet_wrap(~name, scales = 'free_x') +
  scale_y_continuous(breaks = scales::pretty_breaks())

b <- polyps |>
  ggplot(aes(baseline, treatment)) +
  geom_boxplot()

library(patchwork)

# combine in row
a | p
# combine in col
a / p

# group together many plots into complex arrangement
complex_panel <- ((a / p) | (b / a / b))

# add annotations by chaining with '&'
complex_panel &
  patchwork::plot_annotation(tag_levels = 'A')



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

## Stats ----

# a duality between stats & geoms

# same as a barplot
ggplot(polyps, aes(y = sex)) + stat_count()

# other styles available
ggplot(polyps, aes(x = baseline, color = sex)) +
  stat_ecdf()


# I'm not a huge fan of stat_*; prefer to compute results separately, beforehand, in my data-handling steps where possible...





## COORDS ---------

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


## Recap/extend: a more complex example ----

# preview of next weeks' data-handling seminar
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

# publication-quality example with bells + whistles
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

print(fig)




## Programming with ggplot2 : preview ----

# plot barplot in a given 'position'
my_barplot_fn <- function(position_arg) {
  polyps |>
    ggplot() +
    geom_bar(aes(y = treatment, fill = sex),
             position = position_arg) +
    labs(title = paste('Position:', position_arg))
}

# for each position, create the barplot
map(
  .x = c('stack', 'fill', 'dodge'),
  .f = my_barplot_fn
) |>
  # combine the list of barplots into a single panel
  patchwork::wrap_plots(ncol = 1, guides = 'collect')





## Animations

# animations are fun and easy too
# https://gganimate.com/index.html

library(gganimate)

animated <-
  polyps |>
  pivot_longer(
    cols = c(baseline, number3m, number12m),
    names_to = 'timepoint',
    values_to = 'polyps'
  ) |>
  mutate(
    timepoint = timepoint |>
      str_remove('number') |>
      factor(levels = c('baseline', '3m', '12m'))
  ) |>
  # plot all phases together
  ggplot(aes(
    polyps, treatment,
    color = sex,
    fill = sex,
  )) +
  stat_summary(
    fun.data = 'mean_cl_boot',
    na.rm = T,
    position = position_dodge(width = .4)
  ) +
  ggbeeswarm::geom_beeswarm(
    cex = 2,
    size = 2,
    shape = 1,
    alpha = .74,
    dodge.width = .8
  ) +
  scale_x_log10() +
  labs(
    title = 'Timepoint:',
    subtitle = '{closest_state}',
    x = 'Polyp count',
    y = 'Arm',
    color = 'Sex',
    fill = 'Sex',
    ) +
  theme_minimal() +
  theme(
    text = element_text(size = 10),
    plot.title = element_markdown(face = 'bold'),
    ) +
  # then split into an animation on some variable
  gganimate::transition_states(timepoint,
                               transition_length = 2,
                               state_length = 2) +
  gganimate::shadow_wake(wake_length = 0.1) +
  gganimate::ease_aes(x = 'cubic-in-out')

gganimate::animate(animated,
                   height = 4, width = 4,
                   units = 'in',
                   res = 150)

# save last animation
gganimate::anim_save('sulindac_animation.gif')





## Solutions ------------

#' *do a bar plot for treatment arms: are sample sizes equal?*: solved, yes
ggplot(data = polyps, mapping = aes(treatment)) +
  geom_bar()


#' *make this plot look better*: solved
ggplot2::diamonds |>
  ggplot(aes(carat, price, color = cut)) +
  geom_point(size = .1, shape = 0, alpha = .5) +
  guides(color = guide_legend(
    override.aes = list(size = 5, shape = 15, alpha = 1)
  ))


