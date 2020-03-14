# Arranging multiple plots together

Sometimes you have two or three (or more) charts that are really just one chart that you need to merge them together. It would be nice to be able to arrange them programmatically and not have to mess with it in illustrator.

Good news.

There is.

It's called `cowplot`, and it's pretty easy to use. First install cowplot with install.packages("cowplot"). Then let's load tidyverse and cowplot.


```r
library(tidyverse)
```

```
## Warning: package 'tidyverse' was built under R version 3.5.2
```

```
## ── Attaching packages ─────────────── tidyverse 1.3.0 ──
```

```
## ✓ ggplot2 3.2.1     ✓ purrr   0.3.3
## ✓ tibble  2.1.3     ✓ dplyr   0.8.3
## ✓ tidyr   1.0.0     ✓ stringr 1.4.0
## ✓ readr   1.3.1     ✓ forcats 0.4.0
```

```
## Warning: package 'ggplot2' was built under R version 3.5.2
```

```
## Warning: package 'tibble' was built under R version 3.5.2
```

```
## Warning: package 'tidyr' was built under R version 3.5.2
```

```
## Warning: package 'purrr' was built under R version 3.5.2
```

```
## Warning: package 'dplyr' was built under R version 3.5.2
```

```
## Warning: package 'stringr' was built under R version 3.5.2
```

```
## Warning: package 'forcats' was built under R version 3.5.2
```

```
## ── Conflicts ────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(cowplot)
```

```
## Warning: package 'cowplot' was built under R version 3.5.2
```

```
## 
## ********************************************************
```

```
## Note: As of version 1.0.0, cowplot does not change the
```

```
##   default ggplot2 theme anymore. To recover the previous
```

```
##   behavior, execute:
##   theme_set(theme_cowplot())
```

```
## ********************************************************
```

What follows is just stuff for me to set up a couple of bar charts. You can run it -- it'll work on your machine without changing a thing -- but what I'm doing here isn't important. The stuff you need to do is below.


```r
attendance <- read_csv("https://raw.githubusercontent.com/mattwaite/sportsdatabook/Master/data/attendance.csv")
```

```
## Parsed with column specification:
## cols(
##   Institution = col_character(),
##   Conference = col_character(),
##   `2013` = col_double(),
##   `2014` = col_double(),
##   `2015` = col_double(),
##   `2016` = col_double(),
##   `2017` = col_double(),
##   `2018` = col_double()
## )
```

Making a quick percent change.


```r
attendance <- attendance %>% mutate(change = ((`2018`-`2017`)/`2017`)*100)
```

Let's chart the top 10 and bottom 10 of college football ticket growth ... and shrinkage.


```r
top10 <- attendance %>% top_n(10, wt=change)
bottom10 <- attendance %>% top_n(10, wt=-change)
```

Okay, now to do this I need to save my plots to an object. We do this the same way we save things to a dataframe -- with the arrow. We'll make two identical bar charts, one with the top 10 and one with the bottom 10.


```r
bar1 <- ggplot() + geom_bar(data=top10, aes(x=reorder(Institution, change), weight=change)) + coord_flip()
```


```r
bar2 <- ggplot() + geom_bar(data=bottom10, aes(x=reorder(Institution, change), weight=change)) + coord_flip()
```

With cowplot, we can use a function called `plot_grid` to arrange the charts:


```r
plot_grid(bar1, bar2) 
```

![](32-cowplot_files/figure-epub3/unnamed-chunk-7-1.png)<!-- -->

We can also stack them on top of each other:


```r
plot_grid(bar1, bar2, ncol=1) 
```

![](32-cowplot_files/figure-epub3/unnamed-chunk-8-1.png)<!-- -->

To make these publishable, we should add headlines, chatter, decent labels, credit lines, etc. But to do this, we'll have to figure out which labels go on which charts, so we can make it look decent. For example -- both charts don't need x or y labels. If you don't have a title and subtitle on both, the spacing is off, so you need to leave one blank or the other blank. You'll just have to fiddle with it until you get it looking right. 


```r
bar1 <- ggplot() + geom_bar(data=top10, aes(x=reorder(Institution, change), weight=change)) + coord_flip() + labs(title="College football winners...", subtitle = "Not every football program saw attendance shrink in 2018. But some really did.",  x="", y="Percent change", caption = "") + theme_minimal() + 
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 8), 
    plot.subtitle = element_text(size=10), 
    panel.grid.minor = element_blank()
    )
```


```r
bar2 <- ggplot() + geom_bar(data=bottom10, aes(x=reorder(Institution, change), weight=change)) + coord_flip() +  labs(title = "... and losers", subtitle= "", x="", y="",  caption="Source: NCAA | By Matt Waite") + theme_minimal() + 
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 8), 
    plot.subtitle = element_text(size=10), 
    panel.grid.minor = element_blank()
    )
```

Saving a cowplot plot_grid is the same as anything else we did in the class:


```r
plot_grid(bar1, bar2) + ggsave("test.png")
```

```
## Saving 5 x 4 in image
```

![](32-cowplot_files/figure-epub3/unnamed-chunk-11-1.png)<!-- -->
