# Z scores

Z scores are a handy way to standardize scores so you can compare things across groupings. In our case, we may want to compare teams by year, or era. We can use z scores to answer questions like who was the greatest X of all time, because a Z score can put them in context to their era. 

We can also use z scores to ask how much better is team A from team B. 

So let's use Nebraska basketball, which if you haven't been reading lately is at a bit of a crossroads. 

A Z score is a measure of how far a number is from the population mean of that number. An easier way to say that -- how different is my grade from the average grade in the class. The formula for calculating a Z score is `(MyScore - AverageScore)/Standard Deviation of Scores`. The standard deviation is a number calculated to show the amount of variation in a set of data. In a normal distribution, 68 percent of all scores will be within 1 standard deviation, 95 percent will be within 2 and 99 within 3. 

## Calculating a Z score in R


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


```r
gamelogs <- read_csv("data/logs19.csv")
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

The first thing we need to do is select some fields we think represent team quality:


```r
teamquality <- gamelogs %>% select(Conference, Team, TeamFGPCT, TeamTotalRebounds, OpponentFGPCT)
```

And since we have individual game data, we need to collapse this into one record for each team. We do that with ... group by.


```r
teamtotals <- teamquality %>% 
  group_by(Conference, Team) %>% 
  summarise(
    FGAvg = mean(TeamFGPCT), 
    ReboundAvg = mean(TeamTotalRebounds), 
    OppFGAvg = mean(OpponentFGPCT)
    )
```

To calculate a Z score in R, the easiest way is to use the scale function in base R. To use it, you use `scale(FieldName, center=TRUE, scale=TRUE)`. The center and scale indicate if you want to subtract from the mean and if you want to divide by the standard deviation, respectively. We do.

When we have multiple Z Scores, it's pretty standard practice to add them together into a composite score. That's what we're doing at the end here with `TotalZscore`. Note: We have to invert OppZscore by multiplying it by a negative 1 because the lower someone's opponent shooting percentage is, the better. 


```r
teamzscore <- teamtotals %>% mutate(
  FGzscore = as.numeric(scale(FGAvg, center = TRUE, scale = TRUE)),
  RebZscore = as.numeric(scale(ReboundAvg, center = TRUE, scale = TRUE)),
  OppZscore = as.numeric(scale(OppFGAvg, center = TRUE, scale = TRUE)) * -1,
  TotalZscore = FGzscore + RebZscore + OppZscore
  )  
```

So now we have a dataframe called `teamzscore` that has 353 basketball teams with Z scores. What does it look like? 


```r
head(teamzscore)
```

```
## # A tibble: 6 x 9
## # Groups:   Conference [1]
##   Conference Team  FGAvg ReboundAvg OppFGAvg FGzscore RebZscore OppZscore
##   <chr>      <chr> <dbl>      <dbl>    <dbl>    <dbl>     <dbl>     <dbl>
## 1 A-10       Davi… 0.453       32.2    0.409    0.606    0.106      1.000
## 2 A-10       Dayt… 0.506       32.1    0.415    2.42     0.0525     0.753
## 3 A-10       Duqu… 0.427       32.7    0.444   -0.286    0.339     -0.511
## 4 A-10       Ford… 0.402       31      0.436   -1.12    -0.432     -0.169
## 5 A-10       Geor… 0.443       32      0.441    0.278    0.0248    -0.380
## 6 A-10       Geor… 0.409       31.3    0.445   -0.891   -0.308     -0.559
## # … with 1 more variable: TotalZscore <dbl>
```

A way to read this -- a team at zero is precisely average. The larger the positive number, the more exceptional they are. The larger the negative number, the more truly terrible they are. 

So who are the best teams in the country? 


```r
teamzscore %>% arrange(desc(TotalZscore))
```

```
## # A tibble: 353 x 9
## # Groups:   Conference [32]
##    Conference Team  FGAvg ReboundAvg OppFGAvg FGzscore RebZscore OppZscore
##    <chr>      <chr> <dbl>      <dbl>    <dbl>    <dbl>     <dbl>     <dbl>
##  1 WCC        Gonz… 0.531       36.3    0.386    2.25      2.02       2.23
##  2 Big Ten    Mich… 0.486       38.1    0.378    2.13      2.22       1.86
##  3 Summit     Sout… 0.501       35.1    0.419    1.89      1.68       2.27
##  4 Ivy        Yale… 0.494       36.2    0.414    1.84      1.80       1.42
##  5 AAC        Hous… 0.447       37.2    0.370    0.530     2.14       2.22
##  6 SEC        Kent… 0.479       36.2    0.399    1.31      1.48       2.08
##  7 SEC        Tenn… 0.496       34.7    0.400    2.08      0.775      2.01
##  8 SWAC       Gram… 0.451       34.7    0.395    1.18      1.19       2.26
##  9 Big West   UC-I… 0.457       36.5    0.382    0.774     1.55       2.29
## 10 OVC        Belm… 0.501       36.2    0.423    1.91      1.46       1.09
## # … with 343 more rows, and 1 more variable: TotalZscore <dbl>
```

Don't sleep on South Dakota State come tournament time!

But closer to home, how is Nebraska doing.


```r
teamzscore %>% filter(Conference == "Big Ten") %>% arrange(desc(TotalZscore))
```

```
## # A tibble: 14 x 9
## # Groups:   Conference [1]
##    Conference Team  FGAvg ReboundAvg OppFGAvg FGzscore RebZscore OppZscore
##    <chr>      <chr> <dbl>      <dbl>    <dbl>    <dbl>     <dbl>     <dbl>
##  1 Big Ten    Mich… 0.486       38.1    0.378    2.13     2.22     1.86   
##  2 Big Ten    Mary… 0.451       36.1    0.398    0.439    1.31     0.996  
##  3 Big Ten    Mich… 0.451       32.4    0.397    0.480   -0.414    1.02   
##  4 Big Ten    Wisc… 0.450       32.4    0.397    0.421   -0.430    1.01   
##  5 Big Ten    Purd… 0.450       34.1    0.416    0.421    0.354    0.218  
##  6 Big Ten    Indi… 0.460       33.4    0.421    0.911    0.0431   0.0192 
##  7 Big Ten    Rutg… 0.419       35.9    0.425   -1.06     1.20    -0.147  
##  8 Big Ten    Iowa… 0.457       32.7    0.450    0.726   -0.251   -1.22   
##  9 Big Ten    Nebr… 0.431       32.5    0.423   -0.509   -0.363   -0.0525 
## 10 Big Ten    Ohio… 0.436       31.9    0.426   -0.264   -0.632   -0.185  
## 11 Big Ten    Minn… 0.435       32.7    0.439   -0.277   -0.261   -0.757  
## 12 Big Ten    Penn… 0.418       33.1    0.442   -1.09    -0.0897  -0.891  
## 13 Big Ten    Nort… 0.403       30.9    0.421   -1.84    -1.10     0.00345
## 14 Big Ten    Illi… 0.431       29.8    0.466   -0.489   -1.60    -1.88   
## # … with 1 more variable: TotalZscore <dbl>
```

So, as we can see, with our composite Z Score, Nebraska is ... not bad, but not good either: 9 of 14 teams in the Big Ten.
