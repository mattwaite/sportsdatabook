# Circular bar plots

At the 27:36 mark in the [Half Court Podcast](https://www.omaha.com/sports/podcasts/half-court-press/half-court-press-creighton-cruises-in-opener-nebraska-stunned-in/article_67081a35-3a8f-5e9e-ae67-e88fcacbb362.html), Omaha World Herald Writer Chris Heady said "November basketball doesn't matter, but it shows you where you are."

It's a tempting phrase to believe, especially a day after Nebraska lost the first game of the Fred Hoiberg era at home to a baseball school, UC Riverside. And it wasn't close. The Huskers, because of a total roster turnover, were a complete mystery before the game. And what happened during it wasn't pretty, so there was a little soul searching going on in Lincoln.

But does November basketball really not matter?

Let's look, using a new form of chart called a circular bar plot. It's a chart type that combines several forms we've used before: bar charts to show magnitude, stacked bar charts to show proportion, but we're going to add bending the chart around a circle to add some visual interstingness to it. We're also going to use time as an x-axis value to make a not subtle circle of time reference. 

First we need some libraries.


```r
library(tidyverse)
```

```
## ── Attaching packages ──────── tidyverse 1.2.1 ──
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
## ── Conflicts ─────────── tidyverse_conflicts() ──
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

```r
library(lubridate)
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following object is masked from 'package:base':
## 
##     date
```

Let's import [every basketball game from last year](https://unl.box.com/s/a8m91bro10t89watsyo13yjegb1fy009). 


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

So let's test the notion of November Basketball Doesn't Matter. What matters in basketball? Let's start simple: Wins.

Sports Reference's win columns are weird, so we need to scan through them and find W and L and we'll give them numbers using `case_when`. 


```r
winlosslogs <- logs %>% mutate(winloss = case_when(
  grepl("W", W_L) ~ 1, 
  grepl("L", W_L) ~ 0)
) %>% filter(Date < "2019-03-19")
```

Now we can group by date and conference and sum up the wins. How many wins by day does each conference get?


```r
dates <- winlosslogs %>% group_by(Date, Conference) %>% summarize(wins = sum(winloss))
```

Earlier, we did stacked bar charts. We have what we need to do that now.


```r
ggplot() + geom_bar(data=dates, aes(x=Date, weight=wins, fill=Conference)) + theme_minimal()
```

![](23-circularbarcharts_files/figure-epub3/unnamed-chunk-5-1.png)<!-- -->

Eeek. This is already looking not great. But to make it a circular bar chart, we add `coord_polar()` to our chart.


```r
ggplot() + geom_bar(data=dates, aes(x=Date, weight=wins, fill=Conference)) + theme_minimal() + coord_polar()
```

![](23-circularbarcharts_files/figure-epub3/unnamed-chunk-6-1.png)<!-- -->

Based on that, the day is probably too thin a slice, and there's way too many conferences in college basketball. Let's group this by months and filter out all but the power five conferences. 


```r
p5 <- c("SEC", "Big Ten", "Pac-12", "Big 12", "ACC")
```

To get months, we're going to use a function in the library `lubridate` called `floor_date`, which combine with mutate will give us a field of just months.


```r
wins <- winlosslogs %>% mutate(month = floor_date(Date, unit="months")) %>% group_by(month, Conference) %>% summarize(wins=sum(winloss)) %>% filter(Conference %in% p5) 
```

Now we can use wins to make our circular bar chart of wins by month in the Power Five.


```r
ggplot() + geom_bar(data=wins, aes(x=month, weight=wins, fill=Conference)) + theme_minimal() + coord_polar()
```

![](23-circularbarcharts_files/figure-epub3/unnamed-chunk-9-1.png)<!-- -->

Yikes. That looks a lot like a broken pie chart. So months are too thick of a slice. Let's use weeks in our floor date to see what that gives us.


```r
wins <- winlosslogs %>% mutate(week = floor_date(Date, unit="weeks")) %>% group_by(week, Conference) %>% summarize(wins=sum(winloss)) %>% filter(Conference %in% p5) 
```


```r
ggplot() + geom_bar(data=wins, aes(x=week, weight=wins, fill=Conference)) + theme_minimal() + coord_polar()
```

![](23-circularbarcharts_files/figure-epub3/unnamed-chunk-11-1.png)<!-- -->

That looks better. But what does it say? Does November basketball matter? What this is saying is ... yeah, it kinda does. The reason? Lots of wins get piled up in November and December, during non-conference play. So if you are a team with NCAA tournament dreams, you need to win games in November to make sure your tournament resume is where it needs to be come March. Does an individual win or loss matter? Probably not. But your record in November does.


