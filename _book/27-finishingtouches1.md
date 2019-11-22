# Finishing touches, part 1

The output from ggplot is good, but not great. We need to add some pieces to it. The elements of a good graphic are:

* Headline
* Chatter
* The main body
* Annotations
* Labels
* Source line
* Credit line

That looks like:

<img src="images/chartannotated.png" width="934" />

## Graphics vs visual stories

While the elements above are nearly required in every chart, they aren't when you are making visual stories. 

* When you have a visual story, things like credit lines can become a byline.
* In visual stories, source lines are often a note at the end of the story. 
* Graphics don’t always get headlines – sometimes just labels, letting the visual story headline carry the load.

[An example from The Upshot](https://www.nytimes.com/interactive/2018/02/14/business/economy/inflation-prices.html). Note how the charts don't have headlines, source or credit lines.

## Getting ggplot closer to output

Let's explore fixing up ggplot's output before we send it to a finishing program like Adobe Illustrator. We'll need a graphic to work with first. 


```r
library(tidyverse)
```

```
## ── Attaching packages ───────────────
```

```
## ✔ ggplot2 3.2.1     ✔ purrr   0.3.3
## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
## ✔ tidyr   1.0.0     ✔ stringr 1.4.0
## ✔ readr   1.3.1     ✔ forcats 0.4.0
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
## ── Conflicts ────────────────────────
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

```r
library(ggrepel)
```

```
## Warning: package 'ggrepel' was built under R version 3.5.2
```



```r
scoring <- read_csv("data/scoringoffense.csv")
```

```
## Parsed with column specification:
## cols(
##   Name = col_character(),
##   G = col_double(),
##   TD = col_double(),
##   FG = col_double(),
##   `1XP` = col_double(),
##   `2XP` = col_double(),
##   Safety = col_double(),
##   Points = col_double(),
##   `Points/G` = col_double(),
##   Year = col_double()
## )
```

```r
total <- read_csv("data/totaloffense.csv")
```

```
## Parsed with column specification:
## cols(
##   Name = col_character(),
##   G = col_double(),
##   `Rush Yards` = col_double(),
##   `Pass Yards` = col_double(),
##   Plays = col_double(),
##   `Total Yards` = col_double(),
##   `Yards/Play` = col_double(),
##   `Yards/G` = col_double(),
##   Year = col_double()
## )
```

```r
offense <- total %>% left_join(scoring, by=c("Name", "Year"))
```

We're going to need this later, so let's grab Nebraska's 2018 stats from this dataframe. 


```r
nu <- offense %>% filter(Name == "Nebraska") %>% filter(Year == 2018)
```

We'll start with the basics.


```r
ggplot(offense, aes(x=`Yards/G`, y=`Points/G`)) + 
  geom_point(color="grey")
```

![](27-finishingtouches1_files/figure-epub3/unnamed-chunk-5-1.png)<!-- -->

Let's take changing things one by one. The first thing we can do is change the figure size. Sometimes you don't want a square. We can use the `knitr` output settings in our chunk to do this easily in our notebooks. 


```r
ggplot(offense, aes(x=`Yards/G`, y=`Points/G`)) + 
  geom_point(color="grey")
```

![](27-finishingtouches1_files/figure-epub3/unnamed-chunk-6-1.png)<!-- -->

Now let's add a fit line. 


```r
ggplot(offense, aes(x=`Yards/G`, y=`Points/G`)) + 
  geom_point(color="grey") + geom_smooth(method=lm, se=FALSE)
```

![](27-finishingtouches1_files/figure-epub3/unnamed-chunk-7-1.png)<!-- -->

And now some labels.


```r
ggplot(offense, aes(x=`Yards/G`, y=`Points/G`)) + 
  geom_point(color="grey") + geom_smooth(method=lm, se=FALSE) + 
  labs(x="Total yards per game", y="Points per game", title="Nebraska's underperforming offense", subtitle="The Husker's offense was the strength of the team. They underperformed.", caption="Source: NCAA | By Matt Waite")
```

![](27-finishingtouches1_files/figure-epub3/unnamed-chunk-8-1.png)<!-- -->

Let's get rid of the default plot look and drop the grey background. 


```r
ggplot(offense, aes(x=`Yards/G`, y=`Points/G`)) + 
  geom_point(color="grey") + geom_smooth(method=lm, se=FALSE) + 
  labs(x="Total yards per game", y="Points per game", title="Nebraska's underperforming offense", subtitle="The Husker's offense was the strength of the team. They underperformed.", caption="Source: NCAA | By Matt Waite") + 
  theme_minimal()
```

![](27-finishingtouches1_files/figure-epub3/unnamed-chunk-9-1.png)<!-- -->

Off to a good start, but our text has no real heirarchy. We'd want our headline to stand out more. So let's change that. When it comes to changing text, the place to do that is in the theme element. [There are a lot of ways to modify the theme](http://ggplot2.tidyverse.org/reference/theme.html). We'll start easy. Let's make the headline bigger and bold.


```r
ggplot(offense, aes(x=`Yards/G`, y=`Points/G`)) + 
  geom_point(color="grey") + geom_smooth(method=lm, se=FALSE) + 
  labs(x="Total yards per game", y="Points per game", title="Nebraska's underperforming offense", subtitle="The Husker's offense was the strength of the team. They underperformed.", caption="Source: NCAA | By Matt Waite") + 
  theme_minimal() + 
  theme(
    plot.title = element_text(size = 16, face = "bold")
    ) 
```

![](27-finishingtouches1_files/figure-epub3/unnamed-chunk-10-1.png)<!-- -->

Now let's fix a few other things -- like the axis labels being too big, the subtitle could be bigger and lets drop some grid lines.


```r
ggplot(offense, aes(x=`Yards/G`, y=`Points/G`)) + 
  geom_point(color="grey") + geom_smooth(method=lm, se=FALSE) + 
  labs(x="Total yards per game", y="Points per game", title="Nebraska's underperforming offense", subtitle="The Husker's offense was the strength of the team. They underperformed.", caption="Source: NCAA | By Matt Waite") + 
  theme_minimal() + 
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 8), 
    plot.subtitle = element_text(size=10), 
    panel.grid.minor = element_blank()
    ) 
```

![](27-finishingtouches1_files/figure-epub3/unnamed-chunk-11-1.png)<!-- -->

Missing from this graph is the context that the headline promises. Where is Nebraska? We haven't added it yet. So let's add a point and a label for it. 


```r
ggplot(offense, aes(x=`Yards/G`, y=`Points/G`)) + 
  geom_point(color="grey") + geom_smooth(method=lm, se=FALSE) + 
  labs(x="Total yards per game", y="Points per game", title="Nebraska's underperforming offense", subtitle="The Husker's offense was the strength of the team. They underperformed.", caption="Source: NCAA | By Matt Waite") + 
  theme_minimal() + 
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 8), 
    plot.subtitle = element_text(size=10), 
    panel.grid.minor = element_blank()
    ) +
  geom_point(data=nu, aes(x=`Yards/G`, y=`Points/G`), color="red") + 
  geom_text_repel(data=nu, aes(x=`Yards/G`, y=`Points/G`, label="Nebraska 2018"))
```

![](27-finishingtouches1_files/figure-epub3/unnamed-chunk-12-1.png)<!-- -->

If we're happy with this output -- if it meets all of our needs for publication -- then we can simply export it as a png file. We do that by adding `+ ggsave("plot.png", width=5, height=2)` to the end of our code. Note the width and the height are from our knitr parameters at the top -- you have to repeat them or the graph will export at the default 7x7. 

If there's more work you want to do with this graph that isn't easy or possible in R but is in Illustrator, simply change the file extension to `pdf` instead of `png`. The pdf will open as a vector file in Illustrator with everything being fully editable. 
