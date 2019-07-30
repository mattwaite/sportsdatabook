# Line charts

Bar charts -- stacked or otherwise -- are good for showing relative size of a thing compared to another thing. Line charts, which we work on here, are good for showing change over time. 

So let's look at how we can answer this question: Why was Nebraska terrible last season?

Let's start getting all that we need. We can use the tidyverse shortcut. 


```r
library(tidyverse)
```

```
## ── Attaching packages ── tidyverse 1.2.1 ──
```

```
## ✔ ggplot2 3.2.0     ✔ purrr   0.3.2
## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
## ✔ tidyr   0.8.3     ✔ stringr 1.4.0
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
## ── Conflicts ───── tidyverse_conflicts() ──
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

Now we'll import the data you created. Mine looks like this: 


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

This data has every game from every team in it, so we need to use filtering to limit it, because we just want to look at Nebraska. If you don't remember, flip back to chapter 5. 


```r
nu <- logs %>% filter(Team == "Nebraska Cornhuskers")
```

Because this data has just Nebraska data in it, the dates are formatted correctly, and the data is long data (instead of wide), we have what we need to make line charts.

Line charts, unlike bar charts, do have a y-axis. So in our ggplot step, we have to define what our x and y axes are. In this case, the x axis is our Date -- the most common x axis in line charts is going to be a date of some variety -- and y in this case is up to us. We've seen from previous walkthroughs that how well a team shoots the ball has a lot to do with how well a team does in a season, so let's chart that. 


```r
ggplot(nu, aes(x=Date, y=TeamFGPCT)) + geom_line()
```

![](15-linecharts_files/figure-epub3/unnamed-chunk-4-1.png)<!-- -->

See a problem here? Note the Y axis doesn't start with zero. That makes this look worse than it is (and that February swoon is pretty bad). To make the axis what you want, you can use `scale_x_continuous` or `scale_y_continuous` and pass in a list with the bottom and top value you want. You do that like this:


```r
ggplot(nu, aes(x=Date, y=TeamFGPCT)) + geom_line() + scale_y_continuous(limits = c(0, .6))
```

![](15-linecharts_files/figure-epub3/unnamed-chunk-5-1.png)<!-- -->

Note also that our X axis labels are automated. It knows it's a date and it just labels it by month. 
## This is too simple. 

With datasets, we want to invite comparison. So let's answer the question visually. Let's put two lines on the same chart. How does Nebraska compare to Michigan State and Purdue, the eventual regular season co-champions? 


```r
msu <- logs %>% filter(Team == "Michigan State Spartans")
```

In this case, because we have two different datasets, we're going to put everything in the geom instead of the ggplot step. We also have to explicitly state what dataset we're using by saying `data=` in the geom step.

First, let's chart Nebraska. Read carefully. First we set the data. Then we set our aesthetic. Unlike bars, we need an X and a Y variable. In this case, our X is the date of the game, Y is the thing we want the lines to move with. In this case, the Team Field Goal Percentage -- TeamFGPCT. 


```r
ggplot() + geom_line(data=nu, aes(x=Date, y=TeamFGPCT), color="red")
```

![](15-linecharts_files/figure-epub3/unnamed-chunk-7-1.png)<!-- -->

Now, by using +, we can add Michigan State to it. REMEMBER COPY AND PASTE IS A THING. Nothing changes except what data you are using.


```r
ggplot() + geom_line(data=nu, aes(x=Date, y=TeamFGPCT), color="red") + geom_line(data=msu, aes(x=Date, y=TeamFGPCT), color="dark green")
```

![](15-linecharts_files/figure-epub3/unnamed-chunk-8-1.png)<!-- -->

Let's flatten our lines out by zeroing the Y axis.


```r
ggplot() + geom_line(data=nu, aes(x=Date, y=TeamFGPCT), color="red") + geom_line(data=msu, aes(x=Date, y=TeamFGPCT), color="dark green") + scale_y_continuous(limits = c(0, .6))
```

![](15-linecharts_files/figure-epub3/unnamed-chunk-9-1.png)<!-- -->

So visually speaking, the difference between Nebraska and Michigan State's season is that Michigan State stayed mostly on an even keel, and Nebraska went on a two month swoon.

## But what if I wanted to add a lot of lines. 

Fine. How about all Power Five Schools? This data for example purposes. You don't have to do it. 


```r
powerfive <- c("SEC", "Big Ten", "Pac-12", "Big 12", "ACC")

p5conf <- logs %>% filter(Conference %in% powerfive)
```

I can keep layering on layers all day if I want. And if my dataset has more than one team in it, I need to use the `group` command. And, the layering comes in order -- so if you're going to layer a bunch of lines with a smaller group of lines, you want the bunch on the bottom. So to do that, your code stacks from the bottom. The first geom in the code gets rendered first. The second gets layered on top of that. The third gets layered on that and so on. 


```r
ggplot() + geom_line(data=p5conf, aes(x=Date, y=TeamFGPCT, group=Team), color="light grey") + geom_line(data=nu, aes(x=Date, y=TeamFGPCT), color="red") + geom_line(data=msu, aes(x=Date, y=TeamFGPCT), color="dark green") + scale_y_continuous(limits = c(0, .6))
```

```
## Warning: Removed 1 rows containing missing values (geom_path).
```

![](15-linecharts_files/figure-epub3/unnamed-chunk-11-1.png)<!-- -->

What do we see here? How has Nebraska and Michigan State's season evolved against all the rest of the teams in college basketball?

But how does that compare to the average? We can add that pretty easily by creating a new dataframe with it and add another geom_line. 


```r
average <- logs %>% group_by(Date) %>% summarise(mean_shooting=mean(TeamFGPCT))
```


```r
ggplot() + geom_line(data=p5conf, aes(x=Date, y=TeamFGPCT, group=Team), color="light grey") + geom_line(data=nu, aes(x=Date, y=TeamFGPCT), color="red") + geom_line(data=msu, aes(x=Date, y=TeamFGPCT), color="dark green") + geom_line(data=average, aes(x=Date, y=mean_shooting), color="black") + scale_y_continuous(limits = c(0, .6))
```

```
## Warning: Removed 1 rows containing missing values (geom_path).
```

![](15-linecharts_files/figure-epub3/unnamed-chunk-13-1.png)<!-- -->
