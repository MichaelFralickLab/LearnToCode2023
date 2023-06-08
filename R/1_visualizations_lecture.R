# ggplot2_polyps.R -------
# a quickstart guide to plotting with ggplot2

# Remember there's a cheat sheet to help you!
# https://github.com/rstudio/cheatsheets/blob/main/data-visualization.pdf

# EDITOR > CONSOLE > ENVIRONMENT *

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

# name <- expression

# assign data to an obj in the global environment
polyps <- medicaldata::polyps

# check out the data
polyps |> str()


## Simple examples & syntax explanation ------

# verbose
# terse
# or specify data and aes on individual geoms

ggplot(
  data = polyps,
  mapping = aes(x = age, y = baseline)
  ) +
  geom_point()


ggplot(
  data = polyps,
  mapping = aes(y = sex)
) +
  geom_bar()



#' *Do a quick bar plot showing randomization to each treatment arm. Are sample sizes equal?*

# verbose
ggplot(
  data = polyps,
  mapping = aes(x = treatment)
) +
  geom_bar()

# terse
ggplot(polyps, aes(treatment)) + geom_bar()


ggplot(data = polyps, aes(treatment)) +
  geom_bar()

## notes
# data can be across all geom_*s or specified w/in a geom_* layer
# aes can be global or specified in layers
# use '+' to add more layers to same canvas


## geom_*s & aes---------------

# protip: flip groups onto y-axis for legibility
ggplot(data = polyps, aes(y = treatment)) +
  geom_bar()

starwars |>
  ggplot(aes(y = species)) +
  geom_bar()


# add colour for 2nd discrete variable
# protip: flip groups onto y-axis for legibility
ggplot(data = polyps,
       aes(y = treatment, fill = sex)) +
  geom_bar()





# one geom_* - different 'position' adjustments
# position = 'stack' | 'fill' | 'dodge'
# modify static geom_ level properties
ggplot(data = polyps,
       aes(y = treatment, fill = sex)) +
  geom_bar(position = 'dodge')



# Continuous Distributions... lets' examine `baseline`...

# histogram, bins
ggplot(data = polyps, aes(x = age)) +
  geom_histogram(bins = 10, color = 'white')


# density lines
ggplot(data = polyps, aes(x = age, color = treatment)) +
  geom_density()

# boxplots

ggplot(data = polyps, aes(
  x = age,
  y = treatment,
  color = treatment)) +
  geom_boxplot()


# jitter

ggplot(data = polyps, aes(
  x = baseline,
  y = treatment,
  color = treatment)
  ) +
  geom_jitter()


# nicer shape with this ggbeeswarm::geom_beeswarm
# less overplotting!
ggplot(data = polyps, aes(
  x = baseline,
  y = treatment,
  color = treatment)
) +
  geom_boxplot(position = position_nudge(y = .5),
               width = .25) +
  ggbeeswarm::geom_beeswarm(cex = 4)



## Adjusting aesthetics -----

# examine correlation between baseline & 3mo timepoint
# stratify by sex...

ggplot(polyps, aes(baseline, number3m,
                   fill = sex,
                   color = sex)) +
  geom_point(size = .5, shape = 1) +
  geom_smooth(method = 'lm', alpha = .2) +
  scale_x_log10() +
  scale_y_log10()





#' *make this plot look better, add a fit line(s)*
ggplot2::diamonds |>
  ggplot(aes(carat, price, color = cut)) +
  geom_point(size = .15, alpha = .15)



## scale_* ---------------

# transform aesthetic mappings
ggplot2::diamonds |>
  ggplot(aes(carat, price, color = cut)) +
  geom_point(size = .15, alpha = .15) +
  scale_color_viridis_d(option = 'B')


## labs ---------------

# add labs() to pretty it up
ggplot2::diamonds |>
  ggplot(aes(carat, price, color = cut)) +
  geom_point(size = .15, alpha = .15) +
  scale_color_viridis_d(option = 'B') +
  labs(title = 'My plot'
       )


## facet_* ---------------

# split panels by a discrete variable
ggplot2::diamonds |>
  ggplot(aes(carat, price, color = cut)) +
  geom_point(size = .15, alpha = .15) +
  scale_color_viridis_d(option = 'B') +
  facet_wrap(~cut) +
  labs(title = 'My plot'
  )




## patchwork ------

library(patchwork)

# grab some plots from earlier just to illustrate...
a <- ggplot2::diamonds |>
  ggplot(aes(carat, price, color = cut)) +
  geom_point(size = .15, alpha = .15) +
  scale_color_viridis_d(option = 'B') +
  facet_wrap(~cut) +
  labs(title = 'My plot'
  )
a

b <- polyps |>
  ggplot(aes(baseline, treatment)) +
  geom_boxplot()
b

(a | (b / a)) &
  plot_annotation(title = 'Something')

# combine in row with '|'
# combine in column with '/'
# group together many plots into complex arrangement
# add annotations by chaining with '&'








## theme_ ---------------

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

# easy: use a preset theme_ on individual plot
p + theme_classic()


# customize elements with theme()
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
    # use element_* to modify
    axis.line = element_line(
      colour = 'purple',
      arrow = grid::arrow(
        type = 'closed',
        length = unit(x = 1, 'mm')),
    )))

print(p)

# set a standard theme for all plots
theme_set(theme_bw())



## save plots -------


ggsave('myplot.png')


## stat_* layers ----

# I'm not a huge fan of stat_*. I prefer to compute results separately, beforehand, in my data-handling steps where possible...


# a duality between stats & geoms
# stat_count same as a geom_bar
ggplot(polyps, aes(y = sex)) + stat_count()

# other styles available with stat...
ggplot(polyps, aes(x = baseline, color = sex)) +
  stat_ecdf()





## coordinate systems ----

# not used too often but you can, eg.
# circular plots with coord_polar()
tibble(
  # simulate data
  x = sample(x = 1:24, size = 100, replace = T),
  y = rpois(n = 100, lambda = 20),
  z = sample(c(T, F), 100, replace = T)
) |>
  ggplot(aes(x, y, fill = z)) +
  coord_polar() +
  geom_col() +
  scale_x_continuous(
    breaks = scales::pretty_breaks(),
    limits = c(0, 24)
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
  )

# publication-quality example with bells + whistles
fig <- polyps_by_timept |>
  ggplot(aes(fct_rev(time), polyps)) +
  ggbeeswarm::geom_quasirandom(
    aes(color = sex),
    width = .20,
    shape = 1,
    dodge.width = .5,
    size = .8,
    na.rm = T
  ) +
  stat_summary(
    fun.data = mean_cl_boot,
    mapping = aes(color = sex),
    alpha = .5,
    geom = "pointrange",
    position = position_dodge(width = .5),
    fun.args = list(conf.int = .95),
    na.rm = T
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
  theme_light() +
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
      color = 'gray40',
      size = 9,
      margin = unit(c(0,0,0,0), 'mm'),
      hjust = 0,
      face = 'bold'
    )
  ) +
  coord_flip()

print(fig)


## Interactivity ----

# adding a tooltip for more info
library(ggiraph)
(polyps |>
    ggplot(aes(sex, baseline, color = age)) +
    geom_jitter_interactive(
      aes(tooltip = participant_id)
    )
) |> ggiraph::ggiraph(ggobj = _)

library(plotly)
(polyps |>
    ggplot(aes(sex, baseline,
               color = age,
               label = participant_id)) +
    geom_jitter()
) |> plotly::ggplotly()

## Animations ----

# animations are fun and easy too
# https://gganimate.com/index.html

library(gganimate)

polyps_long <-
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
  )

animate_this <-
  polyps_long |>
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
    cex = 3,
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
  )


# then split into an animation on some variable
animated <- animate_this +
  gganimate::transition_states(timepoint,
                               transition_length = 2,
                               state_length = 2) +
  gganimate::shadow_wake(wake_length = 0.1) +
  gganimate::ease_aes('cubic-in-out')

gganimate::animate(animated,
                   height = 4, width = 4,
                   units = 'in',
                   res = 150)

# save last animation
gganimate::anim_save('sulindac_animation.gif')



## Programming with ggplot2 : preview ----

# plot a barplot with a given 'position' argument
my_barplot_fn <- function(position_arg) {
  polyps |>
    ggplot() +
    geom_bar(aes(y = treatment, fill = sex),
             position = position_arg) +
    labs(title = paste('Position:', position_arg))
}

# for each position, create a barplot
map(
  .x = c('stack', 'fill', 'dodge'),
  .f = my_barplot_fn
) |>
  # combine the list of barplots into a single panel
  patchwork::wrap_plots(ncol = 1, guides = 'collect')




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


