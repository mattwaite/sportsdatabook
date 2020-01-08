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
## Warning: package 'tidyverse' was built under R version 3.5.2
```

```
## ── Attaching packages ────── tidyverse 1.3.0 ──
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
## ── Conflicts ───────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

Let's look at the current state of Nebraska basketball using the [same logs data we've been using, but for this season so far](). 


```r
gamelogs <- read_csv("data/logs20.csv")
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
teamquality <- gamelogs %>% 
  select(Conference, Team, TeamFGPCT, TeamTotalRebounds, OpponentFGPCT, OpponentTotalRebounds)
```

And since we have individual game data, we need to collapse this into one record for each team. We do that with ... group by.


```r
teamtotals <- teamquality %>% 
  group_by(Conference, Team) %>% 
  summarise(
    FGAvg = mean(TeamFGPCT), 
    ReboundAvg = mean(TeamTotalRebounds), 
    OppFGAvg = mean(OpponentFGPCT),
    OffRebAvg = mean(OpponentTotalRebounds)
    )
```

To calculate a Z score in R, the easiest way is to use the scale function in base R. To use it, you use `scale(FieldName, center=TRUE, scale=TRUE)`. The center and scale indicate if you want to subtract from the mean and if you want to divide by the standard deviation, respectively. We do.

When we have multiple Z Scores, it's pretty standard practice to add them together into a composite score. That's what we're doing at the end here with `TotalZscore`. Note: We have to invert OppZscore and OppRebZScore by multiplying it by a negative 1 because the lower someone's opponent number is, the better. 


```r
teamzscore <- teamtotals %>% 
  mutate(
    FGzscore = as.numeric(scale(FGAvg, center = TRUE, scale = TRUE)),
    RebZscore = as.numeric(scale(ReboundAvg, center = TRUE, scale = TRUE)),
    OppZscore = as.numeric(scale(OppFGAvg, center = TRUE, scale = TRUE)) * -1,
    OppRebZScore = as.numeric(scale(OffRebAvg, center = TRUE, scale = TRUE)) * -1,
    TotalZscore = FGzscore + RebZscore + OppZscore + OppRebZScore
  )  
```

So now we have a dataframe called `teamzscore` that has 353 basketball teams with Z scores. What does it look like? 


```r
head(teamzscore)
```

```
## # A tibble: 6 x 11
## # Groups:   Conference [1]
##   Conference Team  FGAvg ReboundAvg OppFGAvg OffRebAvg FGzscore RebZscore
##   <chr>      <chr> <dbl>      <dbl>    <dbl>     <dbl>    <dbl>     <dbl>
## 1 A-10       Davi… 0.454       28.8    0.447      30.4    0.513   -1.50  
## 2 A-10       Dayt… 0.530       31.9    0.421      28      2.68    -0.352 
## 3 A-10       Duqu… 0.452       32.5    0.412      29.5    0.441   -0.0997
## 4 A-10       Ford… 0.394       32.2    0.396      32.1   -1.22    -0.214 
## 5 A-10       Geor… 0.423       36      0.407      33.1   -0.397    1.18  
## 6 A-10       Geor… 0.418       30.8    0.441      32.9   -0.529   -0.726 
## # … with 3 more variables: OppZscore <dbl>, OppRebZScore <dbl>,
## #   TotalZscore <dbl>
```

A way to read this -- a team at zero is precisely average. The larger the positive number, the more exceptional they are. The larger the negative number, the more truly terrible they are. 

So who are the best teams in the country? 


```r
teamzscore %>% arrange(desc(TotalZscore))
```

```
## # A tibble: 353 x 11
## # Groups:   Conference [32]
##    Conference Team  FGAvg ReboundAvg OppFGAvg OffRebAvg FGzscore RebZscore
##    <chr>      <chr> <dbl>      <dbl>    <dbl>     <dbl>    <dbl>     <dbl>
##  1 Big West   UC-I… 0.460       38.2    0.379      28      0.815     1.99 
##  2 Southland  Step… 0.500       35.9    0.423      26.3    1.84      1.57 
##  3 OVC        Murr… 0.482       37.2    0.391      26.9    1.24      1.28 
##  4 SWAC       Gram… 0.463       34.6    0.433      30.9    1.85      1.16 
##  5 Horizon    Wrig… 0.467       38.4    0.417      32.9    1.45      2.23 
##  6 A-Sun      Libe… 0.484       31.6    0.363      27.2    1.74     -0.837
##  7 MEAC       Morg… 0.433       34.2    0.420      29.6    1.14      1.12 
##  8 Big 12     Kans… 0.506       35.5    0.375      28.7    2.34      0.275
##  9 ACC        Loui… 0.476       38.1    0.372      29.9    1.31      1.30 
## 10 NEC        Sacr… 0.442       37.8    0.413      33.4    1.01      1.58 
## # … with 343 more rows, and 3 more variables: OppZscore <dbl>,
## #   OppRebZScore <dbl>, TotalZscore <dbl>
```

Don't sleep on the Anteaters come tournament time!

But closer to home, how is Nebraska doing.


```r
teamzscore %>% 
  filter(Conference == "Big Ten") %>% 
  arrange(desc(TotalZscore))
```

```
## # A tibble: 14 x 11
## # Groups:   Conference [1]
##    Conference Team  FGAvg ReboundAvg OppFGAvg OffRebAvg FGzscore RebZscore
##    <chr>      <chr> <dbl>      <dbl>    <dbl>     <dbl>    <dbl>     <dbl>
##  1 Big Ten    Mich… 0.466       39.7    0.374      28.6   0.556     1.47  
##  2 Big Ten    Ohio… 0.473       36      0.359      27.9   0.870     0.0613
##  3 Big Ten    Rutg… 0.476       37.7    0.375      28.2   0.962     0.712 
##  4 Big Ten    Indi… 0.471       36.8    0.410      27.4   0.767     0.359 
##  5 Big Ten    Illi… 0.469       37.7    0.425      27     0.701     0.712 
##  6 Big Ten    Mary… 0.415       40.1    0.377      31.4  -1.56      1.61  
##  7 Big Ten    Penn… 0.455       37.4    0.393      32.7   0.0969    0.576 
##  8 Big Ten    Mich… 0.494       33.8    0.412      30.4   1.72     -0.785 
##  9 Big Ten    Purd… 0.428       35.4    0.390      29.1  -0.993    -0.183 
## 10 Big Ten    Iowa… 0.460       35.3    0.424      31.3   0.319    -0.210 
## 11 Big Ten    Minn… 0.444       35.4    0.408      31.7  -0.357    -0.172 
## 12 Big Ten    Wisc… 0.436       31.6    0.409      29    -0.703    -1.62  
## 13 Big Ten    Nort… 0.423       31.6    0.426      30.9  -1.21     -1.61  
## 14 Big Ten    Nebr… 0.424       33.4    0.427      43.7  -1.16     -0.914 
## # … with 3 more variables: OppZscore <dbl>, OppRebZScore <dbl>,
## #   TotalZscore <dbl>
```

So, as we can see, with our composite Z Score, Nebraska is ... not good. Not good at all. 
