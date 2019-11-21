# Step charts

Step charts are a method of showing progress toward something. There's been two great examples lately. First is the Washignton Post looking at [Lebron passing Jordan's career point total](https://www.washingtonpost.com/graphics/sports/lebron-james-michael-jordan-nba-scoring-list/?utm_term=.481074150849). Another is John Burn-Murdoch's work at the Financial Times (which is paywalled) about soccer stars. [Here's an example of his work outside the paywall](http://johnburnmurdoch.github.io/projects/goal-lines/CL/).

To replicate this, we need cumulative data -- data that is the running total of data at a given point. So think of it this way -- Nebraska scores 50 points in a basketball game and then 50 more the next, their cumulative total at two games is 100 points. 

Step charts can be used for all kinds of things -- showing how a player's career has evolved over time, how a team fares over a season, or franchise history. Let's walk through an example. 


```r
library(tidyverse)
```

```
## ── Attaching packages ─────────────────
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
## ── Conflicts ──────────────────────────
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

And we'll use our basketball log data. 


```r
logs <- read_csv("data/logs19.csv")
```

```
## Warning: Missing column names filled in: 'X1' [1]
```

```
## Parsed with column specification:
## cols(
##   .default = col_double(),
##   Date = col_date(format = ""),
##   HomeAway = col_character(),
##   Opponent = col_character(),
##   W_L = col_character(),
##   Blank = col_logical(),
##   Team = col_character(),
##   Conference = col_character(),
##   season = col_character()
## )
```

```
## See spec(...) for full column specifications.
```

Here we're going to look at the scoring differential of teams. If you score more than your opponent, you win. So it stands to reason that if you score a lot more than your opponent over the course of a season, you should be very good, right? Let's see.

The first thing we're going to do is calculate that differential. Then, we'll group it by the team. After that, we're going to summarize using a new function called `cumsum` or cumulative sum -- the sum for each game as we go forward.


```r
difflogs <- logs %>% mutate(Differential = TeamScore - OpponentScore) %>% group_by(Team) %>% mutate(CumDiff = cumsum(Differential))
```

Now that we have the cumulative sum for each, let's filter it down to just Big Ten teams.


```r
bigdiff <- difflogs %>% filter(Conference == "Big Ten")
```

The step chart is it's own geom, so we can employ it just like we have the others. It works almost exactly the same as a line chart, but it just has to use the cumulative sum instead of a regular value.


```r
ggplot() + geom_step(data=bigdiff, aes(x=Date, y=CumDiff, group=Team))
```

![](16-stepcharts_files/figure-epub3/unnamed-chunk-5-1.png)<!-- -->

Let's try a different element of the aesthetic: color, but this time inside the aesthetic. Last time, we did the color outside. When you put it inside, you pass it a column name and ggplot will color each line based on what thing that is, and it will create a legend that labels each line that thing. 


```r
ggplot() + geom_step(data=bigdiff, aes(x=Date, y=CumDiff, group=Team, color=Team))
```

![](16-stepcharts_files/figure-epub3/unnamed-chunk-6-1.png)<!-- -->

From this, we can see two teams in the Big Ten have negative point differentials on the season -- Illinois and Rutgers. 

Let's look at those top teams plus Nebraska.


```r
nu <- bigdiff %>% filter(Team == "Nebraska Cornhuskers")
mi <- bigdiff %>% filter(Team == "Michigan Wolverines")
ms <- bigdiff %>% filter(Team == "Michigan State Spartans")
```

Let's introduce a couple of new things here. First, note when I take the color OUT of the aesthetic, the legend disappears. 

The second thing I'm going to add is the annotation layer. In this case, I am adding a text annotation layer, and I can specify where by adding in a x and a y value where I want to put it. This takes some finesse. After that, I'm going to add labels and a theme. 


```r
ggplot() + 
  geom_step(data=bigdiff, aes(x=Date, y=CumDiff, group=Team), color="light grey") +
  geom_step(data=nu, aes(x=Date, y=CumDiff, group=Team), color="red") + 
  geom_step(data=mi, aes(x=Date, y=CumDiff, group=Team), color="blue") + 
  geom_step(data=ms, aes(x=Date, y=CumDiff, group=Team), color="dark green") +
  annotate("text", x=(as.Date("2018-12-10")), y=220, label="Nebraska") +
  labs(x="Date", y="Cumulative Point Differential", title="Nebraska was among the league's most dominant", subtitle="Before the misseason skid, Nebraska was at the top of the Big Ten in point differential", caption="Source: Sports-Reference.com | By Matt Waite") +
  theme_minimal()
```

![](16-stepcharts_files/figure-epub3/unnamed-chunk-8-1.png)<!-- -->
