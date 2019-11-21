# Mutating data

One of the most common data analysis techniques is to look at change over time. The most common way of comparing change over time is through percent change. The math behind calculating percent change is very simple, and you should know it off the top of your head. The easy way to remember it is:

`(new - old) / old` 

Or new minus old divided by old. Your new number minus the old number, the result of which is divided by the old number. To do that in R, we can use `dplyr` and `mutate` to calculate new metrics in a new field using existing fields of data. 

So first we'll import the tidyverse so we can read in our data and begin to work with it.


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

Now we'll import a common and [simple dataset of total attendance](https://unl.box.com/s/hvxmnxhr41x4ikgt3vk38aczcbrf97pn) at NCAA football games over the last few seasons. 


```r
attendance <- read_csv('data/attendance.csv')
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

```r
head(attendance)
```

```
## # A tibble: 6 x 8
##   Institution     Conference      `2013` `2014` `2015` `2016` `2017` `2018`
##   <chr>           <chr>            <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
## 1 Air Force       MWC             228562 168967 156158 177519 174924 166205
## 2 Akron           MAC             107101  55019 108588  62021 117416  92575
## 3 Alabama         SEC             710538 710736 707786 712747 712053 710931
## 4 Appalachian St. FBS Independent 149366     NA     NA     NA     NA     NA
## 5 Appalachian St. Sun Belt            NA 138995 128755 156916 154722 131716
## 6 Arizona         Pac-12          285713 354973 308355 338017 255791 318051
```
The code to calculate percent change is pretty simple. Remember, with `summarize`, we used `n()` to count things. With `mutate`, we use very similar syntax to calculate a new value using other values in our dataset. So in this case, we're trying to do (new-old)/old, but we're doing it with fields. If we look at what we got when we did `head`, you'll see there's \`2018\` as the new data, and we'll use \`2017\` as the old data. So we're looking at one year. Then, to help us, we'll use arrange again to sort it, so we get the fastest growing school over one year. 


```r
attendance %>% mutate(
  change = (`2018` - `2017`)/`2017`
) 
```

```
## # A tibble: 150 x 9
##    Institution Conference `2013` `2014` `2015` `2016` `2017` `2018`
##    <chr>       <chr>       <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
##  1 Air Force   MWC        228562 168967 156158 177519 174924 166205
##  2 Akron       MAC        107101  55019 108588  62021 117416  92575
##  3 Alabama     SEC        710538 710736 707786 712747 712053 710931
##  4 Appalachia… FBS Indep… 149366     NA     NA     NA     NA     NA
##  5 Appalachia… Sun Belt       NA 138995 128755 156916 154722 131716
##  6 Arizona     Pac-12     285713 354973 308355 338017 255791 318051
##  7 Arizona St. Pac-12     501509 343073 368985 286417 359660 291091
##  8 Arkansas    SEC        431174 399124 471279 487067 442569 367748
##  9 Arkansas S… Sun Belt   149477 149163 138043 136200 119538 119001
## 10 Army West … FBS Indep… 169781 171310 185946 163267 185543 190156
## # … with 140 more rows, and 1 more variable: change <dbl>
```
What do we see right away? Do those numbers look like we expect them to? No. They're a decimal expressed as a percentage. So let's fix that by multiplying by 100. 


```r
attendance %>% mutate(
  change = ((`2018` - `2017`)/`2017`)*100
) 
```

```
## # A tibble: 150 x 9
##    Institution Conference `2013` `2014` `2015` `2016` `2017` `2018`  change
##    <chr>       <chr>       <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>
##  1 Air Force   MWC        228562 168967 156158 177519 174924 166205  -4.98 
##  2 Akron       MAC        107101  55019 108588  62021 117416  92575 -21.2  
##  3 Alabama     SEC        710538 710736 707786 712747 712053 710931  -0.158
##  4 Appalachia… FBS Indep… 149366     NA     NA     NA     NA     NA  NA    
##  5 Appalachia… Sun Belt       NA 138995 128755 156916 154722 131716 -14.9  
##  6 Arizona     Pac-12     285713 354973 308355 338017 255791 318051  24.3  
##  7 Arizona St. Pac-12     501509 343073 368985 286417 359660 291091 -19.1  
##  8 Arkansas    SEC        431174 399124 471279 487067 442569 367748 -16.9  
##  9 Arkansas S… Sun Belt   149477 149163 138043 136200 119538 119001  -0.449
## 10 Army West … FBS Indep… 169781 171310 185946 163267 185543 190156   2.49 
## # … with 140 more rows
```
Now, does this ordering do anything for us? No. Let's fix that with arrange. 


```r
attendance %>% mutate(
  change = ((`2018` - `2017`)/`2017`)*100
) %>% arrange(desc(change))
```

```
## # A tibble: 150 x 9
##    Institution  Conference `2013` `2014` `2015` `2016` `2017` `2018` change
##    <chr>        <chr>       <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
##  1 Ga. Southern Sun Belt       NA 105510 124681 104095  61031 100814   65.2
##  2 La.-Monroe   Sun Belt    85177  90540  58659  67057  49640  71048   43.1
##  3 Louisiana    Sun Belt   129878 154652 129577 121346  78754 111303   41.3
##  4 Hawaii       MWC        185931 192159 164031 170299 145463 205455   41.2
##  5 Buffalo      MAC        136418 122418 110743 104957  80102 110280   37.7
##  6 California   Pac-12     345303 286051 292797 279769 219290 300061   36.8
##  7 UCF          AAC        252505 226869 180388 214814 257924 352148   36.5
##  8 UTSA         C-USA      175282 165458 138048 138226 114104 148257   29.9
##  9 Eastern Mic… MAC         20255  75127  29381 106064  73649  95632   29.8
## 10 Louisville   ACC            NA 317829 294413 324391 276957 351755   27.0
## # … with 140 more rows
```

So who had the most growth last year from the year before? Something going on at Georgia Southern. 

## A more complex example

There's metric in basketball that's easy to understand -- shooting percentage. It's the number of shots made divided by the number of shots attempted. Simple, right? Except it's a little too simple. Because what about three point shooters? They tend to be more vailable because the three point shot is worth more. What about players who get to the line? In shooting percentage, free throws are nowhere to be found. 

Basketball nerds, because of these weaknesses, have created a new metric called [True Shooting Percentage](https://en.wikipedia.org/wiki/True_shooting_percentage). True shooting percentage takes into account all aspects of a players shooting to determine who the real shooters are. 

Using `dplyr` and `mutate`, we can calculate true shooting percentage. So let's look at a new dataset, one of [every college basketball player's season stats in 2018-19 season](https://unl.box.com/s/s1wzw61u9ia50qmirfhuvprgpmmah9rj). It's a dataset of 5,386 players, and we've got 59 variables -- one of them is True Shooting Percentage, but we're going to ignore that. 


```r
players <- read_csv("data/players19.csv")
```

```
## Warning: Missing column names filled in: 'X1' [1]
```

```
## Parsed with column specification:
## cols(
##   .default = col_double(),
##   Team = col_character(),
##   Conference = col_character(),
##   Player = col_character(),
##   Class = col_character(),
##   Pos = col_character(),
##   Height = col_character(),
##   Hometown = col_character(),
##   `High School` = col_character(),
##   Summary = col_character()
## )
```

```
## See spec(...) for full column specifications.
```

The basic true shooting percentage formula is `(Points / (2*(FieldGoalAttempts + (.44 * FreeThrowAttempts)))) * 100`. Let's talk that through. Points divided by a lot. It's really field goal attempts plus 44 percent of the free throw attempts. Why? Because that's about what a free throw is worth, compared to other ways to score. After adding those things together, you double it. And after you divide points by that number, you multiply the whole lot by 100. 

In our data, we need to be able to find the fields so we can complete the formula. To do that, one way is to use the Environment tab in R Studio. In the Environment tab is a listing of all the data you've imported, and if you click the triangle next to it, it'll list all the field names, giving you a bit of information about each one. 

<img src="images/environment.png" width="1306" />

So what does True Shooting Percentage look like in code? 

Let's think about this differently. Who had the best true shooting season last year? 


```r
players %>%
  mutate(trueshooting = (PTS/(2*(FGA + (.44*FTA))))*100) %>%
  arrange(desc(trueshooting))
```

```
## # A tibble: 5,386 x 60
##       X1 Team  Conference Player   `#` Class Pos   Height Weight Hometown
##    <dbl> <chr> <chr>      <chr>  <dbl> <chr> <chr> <chr>   <dbl> <chr>   
##  1   579 Texa… Big 12     Drayt…     4 JR    G     6-0       156 Austin,…
##  2   843 Ston… AEC        Nick …    42 FR    F     6-7       240 Port Je…
##  3  1059 Sout… Southland  Patri…    22 SO    F     6-3       210 Folsom,…
##  4  4269 Dayt… A-10       Camro…    52 SO    G     5-7       160 Country…
##  5  4681 Cali… Pac-12     David…    21 JR    G     6-4       185 Newbury…
##  6   326 Virg… ACC        Grant…     1 FR    G     <NA>       NA Charlot…
##  7   410 Vand… SEC        Mac H…    42 FR    G     6-6       182 Chattan…
##  8  1390 Sain… A-10       Jack …    31 JR    G     6-6       205 Mattoon…
##  9  2230 NJIT… A-Sun      Patri…     3 SO    G     5-9       160 West Or…
## 10   266 Wash… Pac-12     Reaga…    34 FR    F     6-6       225 Santa A…
## # … with 5,376 more rows, and 50 more variables: `High School` <chr>,
## #   Summary <chr>, Rk.x <dbl>, G <dbl>, GS <dbl>, MP <dbl>, FG <dbl>,
## #   FGA <dbl>, `FG%` <dbl>, `2P` <dbl>, `2PA` <dbl>, `2P%` <dbl>,
## #   `3P` <dbl>, `3PA` <dbl>, `3P%` <dbl>, FT <dbl>, FTA <dbl>,
## #   `FT%` <dbl>, ORB <dbl>, DRB <dbl>, TRB <dbl>, AST <dbl>, STL <dbl>,
## #   BLK <dbl>, TOV <dbl>, PF <dbl>, PTS <dbl>, Rk.y <dbl>, PER <dbl>,
## #   `TS%` <dbl>, `eFG%` <dbl>, `3PAr` <dbl>, FTr <dbl>, PProd <dbl>,
## #   `ORB%` <dbl>, `DRB%` <dbl>, `TRB%` <dbl>, `AST%` <dbl>, `STL%` <dbl>,
## #   `BLK%` <dbl>, `TOV%` <dbl>, `USG%` <dbl>, OWS <dbl>, DWS <dbl>,
## #   WS <dbl>, `WS/40` <dbl>, OBPM <dbl>, DBPM <dbl>, BPM <dbl>,
## #   trueshooting <dbl>
```

You'll be forgiven if you did not hear about Texas Longhorns shooting sensation Drayton Whiteside. He played in six games, took one shot and actually hit it. It happened to be a three pointer, which is one more three pointer than I've hit in college basketball. So props to him. Does that mean he had the best true shooting season in college basketball last year? Not hardly. 

We'll talk about how to narrow the pile and filter out data in the next chapter.
