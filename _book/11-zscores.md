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
## ── Attaching packages ─── tidyverse 1.3.0 ──
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
## ── Conflicts ────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

Let's look at the current state of Nebraska basketball using the [same logs data we've been using, but for this season so far](https://unl.box.com/s/wnlh0u9low1yh56enion8zjmu8r7dc8p). 


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
## 1 A-10       Davi… 0.454       30.7    0.431      31.4    0.508    -0.835
## 2 A-10       Dayt… 0.526       32.4    0.420      28.5    2.57     -0.127
## 3 A-10       Duqu… 0.446       33.1    0.413      31.1    0.277     0.158
## 4 A-10       Ford… 0.383       29.8    0.411      33.2   -1.55     -1.21 
## 5 A-10       Geor… 0.415       34.2    0.43       32.5   -0.616     0.615
## 6 A-10       Geor… 0.428       30.7    0.442      32.8   -0.231    -0.825
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
##  1 Big West   UC-I… 0.468       38.0    0.378      27.5    1.32      2.24 
##  2 Big 12     Kans… 0.487       35.7    0.378      29.0    2.36      0.892
##  3 OVC        Murr… 0.487       35.5    0.400      27.7    1.43      1.11 
##  4 ACC        Loui… 0.468       37.4    0.374      30.3    1.41      1.43 
##  5 Ivy        Yale… 0.472       37.4    0.369      31.0    1.23      1.52 
##  6 WCC        Gonz… 0.513       37.9    0.418      28.8    1.48      1.92 
##  7 Big South  Wint… 0.463       37.7    0.426      30.8    1.06      2.18 
##  8 Summit     Sout… 0.488       35.9    0.421      31.4    1.45      1.51 
##  9 A-10       Dayt… 0.526       32.4    0.420      28.5    2.57     -0.127
## 10 NEC        Sacr… 0.442       37.1    0.414      31.7    0.770     1.70 
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
##  1 Big Ten    Mich… 0.457       38.3    0.379      28.8    1.02     1.52  
##  2 Big Ten    Rutg… 0.448       37.4    0.380      30.6    0.494    1.16  
##  3 Big Ten    Ohio… 0.454       34.0    0.384      28.5    0.843   -0.319 
##  4 Big Ten    Illi… 0.457       36.5    0.411      28.1    0.975    0.779 
##  5 Big Ten    Indi… 0.453       35.6    0.416      28.0    0.765    0.393 
##  6 Big Ten    Mary… 0.411       37.5    0.386      31.7   -1.58     1.20  
##  7 Big Ten    Penn… 0.442       35.7    0.394      34      0.185    0.413 
##  8 Big Ten    Mich… 0.464       33.0    0.430      32.0    1.40    -0.705 
##  9 Big Ten    Purd… 0.426       33.7    0.410      28.7   -0.738   -0.447 
## 10 Big Ten    Iowa… 0.451       34.8    0.433      31.6    0.641    0.0501
## 11 Big Ten    Minn… 0.422       35.0    0.406      33.1   -0.928    0.143 
## 12 Big Ten    Wisc… 0.422       31.3    0.410      31.7   -0.975   -1.44  
## 13 Big Ten    Nort… 0.420       30.6    0.420      31.9   -1.06    -1.75  
## 14 Big Ten    Nebr… 0.420       32.4    0.441      42.7   -1.05    -0.994 
## # … with 3 more variables: OppZscore <dbl>, OppRebZScore <dbl>,
## #   TotalZscore <dbl>
```

So, as we can see, with our composite Z Score, Nebraska is ... not good. Not good at all. 
