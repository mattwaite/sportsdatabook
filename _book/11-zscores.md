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
## 1 A-10       Davi… 0.454       31.1    0.437      30.4    0.507   -0.623 
## 2 A-10       Dayt… 0.525       32.5    0.413      29.0    2.56     0.0380
## 3 A-10       Duqu… 0.444       32.4    0.427      32.4    0.222   -0.0145
## 4 A-10       Ford… 0.380       30.0    0.403      34.1   -1.61    -1.14  
## 5 A-10       Geor… 0.422       33.5    0.441      30.7   -0.398    0.480 
## 6 A-10       Geor… 0.424       30.5    0.451      32.7   -0.341   -0.904 
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
##  1 Big West   UC-I… 0.473       36.6    0.390      27.1    1.60     2.23  
##  2 Big 12     Kans… 0.482       35.9    0.378      29.0    2.38     1.12  
##  3 WCC        Gonz… 0.517       37.6    0.422      28.4    1.65     1.94  
##  4 Big Ten    Mich… 0.460       37.8    0.379      29.7    1.41     1.59  
##  5 Southland  Step… 0.490       34.2    0.427      26.6    1.71     1.02  
##  6 OVC        Murr… 0.477       35.3    0.401      29.2    1.31     1.36  
##  7 Summit     Sout… 0.492       35.5    0.423      31.3    1.51     1.60  
##  8 A-10       Sain… 0.457       37.4    0.403      30.5    0.598    2.23  
##  9 A-10       Dayt… 0.525       32.5    0.413      29.0    2.56     0.0380
## 10 Horizon    Wrig… 0.463       37.1    0.416      33.5    1.53     2.28  
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
##  1 Big Ten    Mich… 0.460       37.8    0.379      29.7    1.41     1.59  
##  2 Big Ten    Rutg… 0.449       37      0.385      31.1    0.789    1.20  
##  3 Big Ten    Ohio… 0.446       33.8    0.397      28.2    0.639   -0.307 
##  4 Big Ten    Illi… 0.442       36.4    0.416      29.1    0.402    0.895 
##  5 Big Ten    Indi… 0.442       34.7    0.423      29.3    0.377    0.0934
##  6 Big Ten    Mich… 0.463       33.4    0.423      32.0    1.60    -0.513 
##  7 Big Ten    Mary… 0.415       36.4    0.399      32.3   -1.20     0.895 
##  8 Big Ten    Penn… 0.432       35.6    0.411      34.2   -0.195    0.522 
##  9 Big Ten    Iowa… 0.451       34.3    0.428      32.6    0.892   -0.0698
## 10 Big Ten    Purd… 0.418       33.8    0.410      29.3   -0.994   -0.304 
## 11 Big Ten    Minn… 0.422       35.1    0.412      33.4   -0.758    0.312 
## 12 Big Ten    Wisc… 0.426       31.3    0.410      32.0   -0.552   -1.53  
## 13 Big Ten    Nort… 0.417       30.6    0.423      34.6   -1.08    -1.84  
## 14 Big Ten    Nebr… 0.412       32.5    0.446      42     -1.34    -0.939 
## # … with 3 more variables: OppZscore <dbl>, OppRebZScore <dbl>,
## #   TotalZscore <dbl>
```

So, as we can see, with our composite Z Score, Nebraska is ... not good. Not good at all. 
