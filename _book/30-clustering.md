# Clustering

One common effort in sports is to classify teams and players -- who are this players peers? What teams are like this one? Who should we compare a player to? Truth is, most sports commentators use nothing more sophisticated that looking at a couple of stats or use the "eye test" to say a player is like this or that. 

There's better ways. 

In this chapter, we're going to use a method that sounds advanced but it really quite simple called k-means clustering. It's based on the concept of the k-nearest neighbor algorithm. You're probably already scared. Don't be. 

Imagine two dots on a scatterplot. If you took a ruler out and measured the distance between those dots, you'd know how far apart they are. In math, that's called the Euclidean distance. It's just the space between them in numbers. Where k-nearest neighbor comes in, you have lots of dots and you want measure the distance between all of them. What does k-means clustering do? It lumps them into groups based on the average distance between them. Players who are good on offense but bad on defense are over here, good offense good defense are over here. And using the Eucliean distance between them, we can decide who is in and who is out of those groups.

For this exercise, I want to look at Cam Mack, Nebraska's point guard and probably the most interesting player on Fred Hoiberg's first team. This is Mack's first year in major college basketball -- he played a year at a community college -- so we don't have much to go on. But with three games in the books, who does Cam Mack compare to? 

To answer this, we'll use k-means clustering. 

First thing we do is load some libraries and set a seed, so if we run this repeatedly, our random numbers are generated from the same base. If you don't have the cluster library, just add it on the console with `install.packages("cluster")`


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

```r
library(cluster)
```

```
## Warning: package 'cluster' was built under R version 3.5.2
```

```r
set.seed(1234)
```

I've gone and scraped [stats for every player in this current season](https://unl.box.com/s/0g56ve61y6hakyxzr1u4t534721bqvg8) so let's load that up. 


```r
players <- read_csv("data/players20.csv")
```

```
## Parsed with column specification:
## cols(
##   .default = col_double(),
##   Team = col_character(),
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

To cluster this data properly, we have some work to do.

First, it won't do to have players who haven't played, so we can use filter to find anyone with greater than 0 minutes played. Next, Cam Mack is a guard, so let's just look at guards. Third, we want to limit the data to things that make sense to look at for Cam Mack -- things like shooting, three point shooting, assists, turnovers and points. 


```r
playersselected <- players %>% 
  filter(MP>0) %>% filter(Pos == "G") %>% 
  select(Player, Team, Pos, MP, `FG%`, `3P%`, AST, TOV, PTS) %>% 
  na.omit() 
```

Now, k-means clustering doesn't work as well with data that can be on different scales. So comparing a percentage to a count metric -- shooting percentage to points -- would create chaos because shooting percentages are a fraction of 1 and points, depending on when they are in the season, could be quite large. So we have to scale each metric -- put them on a similar basis using the distance from the max value as our guide. Also, k-means clustering won't work with text data, so we need to create a dataframe that's just the numbers, but scaled. We can do that with another select, and using mutate_all with the scale function. The `na.omit()` means get rid of any blanks, because they too will cause errors. 


```r
playersscaled <- playersselected %>% 
  select(MP, `FG%`, `3P%`, AST, TOV, PTS) %>% 
  mutate_all(scale) %>% 
  na.omit()
```

With k-means clustering, we decide how many clusters we want. Most often, researchers will try a handful of different cluster numbers and see what works. But there are methods for finding the optimal number. One method is called the Elbow method. One implementation of this, [borrowed from the University of Cincinnati's Business Analytics program](https://uc-r.github.io/kmeans_clustering), does this quite nicely with a graph that will help you decide for yourself. 

All you need to do in this code is change out the data frame -- `playersscaled` in this case -- and run it. 


```r
# function to compute total within-cluster sum of square 
wss <- function(k) {
  kmeans(playersscaled, k, nstart = 10 )$tot.withinss
}

# Compute and plot wss for k = 1 to k = 15
k.values <- 1:15

# extract wss for 2-15 clusters
wss_values <- map_dbl(k.values, wss)
```

```
## Warning: did not converge in 10 iterations
```

```r
plot(k.values, wss_values,
       type="b", pch = 19, frame = FALSE, 
       xlab="Number of clusters K",
       ylab="Total within-clusters sum of squares")
```

![](30-clustering_files/figure-epub3/unnamed-chunk-5-1.png)<!-- -->

The Elbow method -- so named because you're looking for the "elbow" where the line flattens out. In this case, it looks like a K of 5 is ideal. So let's try that. We're going to use the kmeans function, saving it to an object called k5. We just need to tell it our dataframe name, how many centers (k) we want, and we'll use a sensible default for how many different configurations to try. 


```r
k5 <- kmeans(playersscaled, centers = 5, nstart = 25)
```

Let's look at what we get.


```r
k5
```

```
## K-means clustering with 5 clusters of sizes 938, 269, 62, 492, 827
## 
## Cluster means:
##           MP         FG%         3P%        AST        TOV        PTS
## 1  0.5282971  0.15363487  0.14152811  0.1363357  0.2504842  0.3332227
## 2 -1.3531329 -1.87642108 -1.59454294 -0.9101220 -1.0975493 -1.1601489
## 3 -1.4384970  3.05056826  3.60389234 -0.9656115 -1.1944675 -1.1052748
## 4  1.2341811  0.26382467  0.17294980  1.5057608  1.4809956  1.3909547
## 5 -0.7854658  0.05043627 -0.01493827 -0.6820150 -0.7186291 -0.7452304
## 
## Clustering vector:
##    [1] 4 1 1 1 1 1 5 5 5 4 1 4 1 5 5 5 4 4 5 5 2 2 4 1 1 1 1 5 3 1 1 4 1 1 5 2 4
##   [38] 4 1 1 1 1 5 5 1 4 1 1 5 5 1 4 1 5 1 1 5 5 2 1 4 1 5 1 5 5 5 2 5 1 1 4 1 5
##   [75] 2 2 5 2 4 1 1 1 5 2 5 2 4 1 1 1 1 5 2 4 1 1 5 5 5 4 1 1 5 5 5 5 3 2 1 1 5
##  [112] 5 5 5 5 2 4 1 1 1 5 5 5 4 4 1 2 5 2 4 1 5 5 1 5 4 1 1 1 1 5 5 1 4 1 1 1 1
##  [149] 2 4 1 1 5 5 5 5 2 4 1 1 1 5 4 5 2 4 1 4 1 1 1 5 5 4 1 1 1 1 5 5 5 5 2 4 1
##  [186] 2 2 4 1 1 5 5 5 2 5 4 4 1 5 3 3 3 2 2 4 1 1 1 4 1 5 3 2 2 4 4 5 5 5 2 2 4
##  [223] 4 1 1 1 1 1 2 4 1 4 4 5 1 1 4 1 1 5 5 5 4 1 1 1 1 1 2 4 4 4 1 5 1 5 3 2 4
##  [260] 4 1 1 1 5 5 5 5 4 4 1 5 1 5 3 2 4 1 1 1 2 4 4 1 1 5 2 1 1 1 1 4 5 5 5 4 4
##  [297] 1 1 5 5 5 5 5 4 1 1 5 5 2 2 4 4 1 1 5 5 4 4 1 1 5 5 3 1 1 1 1 5 5 5 4 4 1
##  [334] 1 1 1 5 4 4 1 5 5 2 2 1 1 1 1 1 5 2 4 4 1 1 1 5 5 2 2 1 1 4 1 5 5 5 5 4 1
##  [371] 4 1 5 5 2 5 3 4 4 4 4 1 5 5 5 4 1 1 5 5 4 1 1 5 5 2 4 4 2 5 2 4 4 1 5 5 5
##  [408] 4 1 1 1 1 5 5 5 3 4 1 1 1 1 5 5 5 4 4 1 5 5 4 1 1 1 5 1 1 2 4 1 1 1 5 5 5
##  [445] 2 4 4 1 1 5 2 1 1 1 5 5 5 5 5 1 4 1 1 1 5 5 2 4 1 4 5 5 5 2 2 4 4 1 5 5 5
##  [482] 2 2 1 4 1 5 5 5 5 4 4 4 1 1 5 5 2 1 1 1 4 5 5 4 1 1 5 1 5 2 4 1 1 5 5 3 5
##  [519] 2 4 4 1 1 1 5 2 3 4 1 4 1 5 5 5 2 1 1 1 4 1 5 5 2 5 4 1 1 5 5 2 4 1 1 1 5
##  [556] 1 5 2 1 1 1 1 5 2 2 2 1 1 1 5 5 5 2 1 4 1 5 5 5 2 4 4 1 1 5 1 4 4 1 1 1 1
##  [593] 5 5 3 4 1 1 5 2 2 2 4 4 1 1 1 5 5 5 5 4 4 1 1 5 4 4 4 1 5 5 2 4 1 4 5 1 2
##  [630] 2 4 1 1 1 5 3 2 4 1 1 1 1 5 5 1 1 1 1 5 5 5 2 4 1 4 5 5 5 4 1 1 5 4 5 5 3
##  [667] 2 4 1 1 5 5 5 4 1 1 1 5 5 1 2 4 4 1 1 5 5 1 1 1 5 2 5 2 1 1 1 1 1 1 3 5 2
##  [704] 4 1 1 4 4 5 2 1 4 5 1 2 2 5 4 4 1 5 5 1 1 4 1 1 5 5 5 2 4 1 1 5 4 1 5 1 5
##  [741] 5 5 3 2 4 1 1 5 4 1 1 5 1 2 5 4 4 4 1 1 5 3 4 1 5 5 5 2 5 2 4 1 1 1 5 5 5
##  [778] 2 2 1 1 1 5 5 5 1 5 4 1 1 4 1 1 5 4 1 1 5 5 5 5 4 4 1 1 5 2 2 4 1 1 5 5 2
##  [815] 4 1 1 5 5 5 5 5 5 4 1 1 1 1 5 2 2 4 1 4 1 1 5 1 5 4 1 4 1 5 4 1 5 5 2 1 4
##  [852] 1 5 1 5 5 4 1 4 5 5 5 3 2 4 1 5 1 2 1 1 1 1 5 5 5 5 4 1 1 2 5 2 2 4 1 1 1
##  [889] 5 1 4 1 5 5 2 2 2 4 4 1 1 5 2 2 4 1 5 5 1 1 1 1 5 5 5 5 5 5 4 4 4 5 5 1 5
##  [926] 2 5 4 1 1 1 5 5 4 1 1 5 5 5 5 1 4 1 1 1 5 5 4 1 1 1 5 5 2 4 4 1 1 1 1 5 5
##  [963] 2 4 4 1 1 5 5 5 5 5 4 1 4 1 5 2 4 4 1 5 5 5 2 4 4 1 1 5 5 5 5 5 1 1 5 1 1
## [1000] 5 5 5 2 4 4 4 1 1 4 5 5 5 3 4 1 1 1 5 2 4 5 5 1 1 2 5 1 1 4 1 5 1 5 2 1 1
## [1037] 4 1 5 5 2 1 1 1 1 1 5 5 2 4 4 1 5 5 2 2 4 1 4 1 1 5 5 5 2 5 5 4 1 1 5 5 5
## [1074] 5 4 1 1 4 5 5 5 5 5 1 1 1 1 5 5 2 5 4 4 1 5 1 5 5 5 4 1 1 4 4 5 5 5 3 2 2
## [1111] 4 1 1 1 1 5 5 5 3 5 2 4 1 1 1 5 5 4 4 4 1 5 2 4 1 1 5 1 1 4 1 1 1 5 5 5 4
## [1148] 1 1 4 1 5 5 5 4 1 1 5 3 2 2 2 4 1 4 1 2 5 2 4 1 1 5 2 2 2 3 2 4 4 4 1 1 5
## [1185] 2 5 4 1 4 1 1 5 4 4 1 1 5 4 4 1 5 5 1 4 1 1 5 5 5 4 1 1 1 5 2 5 3 4 4 1 5
## [1222] 5 5 2 4 1 1 1 5 1 5 5 4 4 1 5 5 2 2 5 4 1 1 5 5 5 2 4 1 1 1 5 2 4 1 1 5 2
## [1259] 2 4 4 1 1 5 5 5 3 1 4 4 1 1 5 2 4 1 1 1 5 3 2 4 1 5 5 5 5 2 2 4 1 1 1 1 5
## [1296] 3 1 1 1 1 5 2 4 1 1 1 1 5 5 2 5 4 4 1 5 5 5 5 5 1 4 1 1 4 5 5 4 1 1 1 5 1
## [1333] 5 5 1 4 1 1 5 5 3 2 4 4 1 4 1 5 2 2 4 1 1 1 5 2 3 3 1 1 1 5 1 1 5 2 1 4 1
## [1370] 1 5 5 5 2 4 4 1 5 5 5 4 1 4 1 5 1 1 1 5 5 5 2 1 1 1 1 5 3 2 4 1 5 5 2 5 2
## [1407] 4 4 1 1 1 5 2 2 2 2 1 1 5 5 5 4 1 1 5 1 5 5 2 1 1 1 5 5 2 4 1 1 1 5 5 5 5
## [1444] 2 4 4 1 5 5 5 5 4 4 1 5 5 5 2 4 4 1 5 5 5 5 2 4 1 1 1 5 5 4 4 1 1 1 5 3 2
## [1481] 4 4 4 5 1 1 5 1 1 1 5 1 5 5 5 5 1 1 1 1 5 5 5 4 1 1 1 5 2 2 4 4 4 1 5 5 4
## [1518] 1 1 1 5 3 1 1 1 1 1 1 1 4 4 1 2 4 1 1 5 5 1 5 1 1 5 5 5 5 5 2 4 4 4 1 5 5
## [1555] 5 3 5 4 1 1 5 5 4 4 4 5 5 5 5 1 4 1 5 1 1 5 2 5 1 1 1 1 1 4 1 5 2 4 4 1 1
## [1592] 5 5 5 1 5 2 4 4 4 1 1 5 4 1 1 1 1 5 2 1 1 1 1 1 5 2 2 4 4 1 5 5 5 3 2 2 1
## [1629] 1 5 1 2 2 2 4 1 1 1 3 4 4 1 1 5 5 5 3 1 4 1 1 5 5 2 4 4 1 1 1 5 2 4 1 1 1
## [1666] 1 1 5 2 5 4 4 1 1 5 1 1 1 5 5 1 5 2 4 1 1 5 5 5 3 3 4 1 1 1 1 5 1 5 4 1 1
## [1703] 4 1 4 1 1 1 5 5 2 4 1 1 5 2 5 2 4 4 4 1 5 5 2 1 1 1 1 5 2 1 1 4 5 5 5 4 1
## [1740] 1 1 1 5 5 4 4 1 1 5 5 5 4 1 1 1 5 5 3 5 2 4 4 1 4 1 1 1 3 4 4 1 5 5 4 1 1
## [1777] 1 1 5 5 5 5 5 2 4 4 1 5 5 3 4 4 1 1 5 5 2 2 4 1 1 5 5 5 4 4 4 4 1 2 4 4 1
## [1814] 1 1 5 5 5 4 1 1 4 4 1 4 1 4 5 5 5 5 2 1 4 1 1 5 2 4 4 1 5 5 1 3 2 4 1 4 1
## [1851] 5 5 5 1 1 1 1 5 1 5 5 2 1 1 1 5 5 2 2 4 1 1 5 5 1 4 1 1 5 5 3 5 1 4 1 1 1
## [1888] 1 5 2 1 4 4 1 5 5 5 2 4 1 1 1 1 5 1 4 1 5 1 5 1 1 1 1 5 5 2 1 1 1 5 5 4 1
## [1925] 1 1 1 5 5 3 4 4 4 1 1 2 2 5 2 2 4 1 4 1 5 5 5 5 5 5 1 4 1 5 5 1 4 4 1 1 5
## [1962] 5 2 1 1 4 4 1 5 5 5 1 4 4 1 1 2 4 1 1 1 1 5 5 4 1 1 5 2 2 3 3 4 1 5 1 2 4
## [1999] 4 1 5 2 4 1 1 5 1 1 5 5 3 2 4 1 5 5 5 2 4 1 5 5 5 5 2 4 4 4 1 1 5 3 2 4 4
## [2036] 4 5 3 2 4 1 5 4 5 5 5 2 4 1 1 4 5 5 5 2 4 4 1 5 1 5 5 5 1 1 1 1 1 5 5 4 4
## [2073] 1 5 5 5 5 5 1 5 5 5 1 4 4 1 1 5 5 5 4 4 1 1 5 5 2 4 1 1 1 5 5 2 4 4 1 1 5
## [2110] 5 5 4 4 1 1 1 5 5 5 4 1 1 5 3 5 5 3 4 1 4 1 5 5 4 1 1 1 5 5 5 2 1 4 1 1 1
## [2147] 1 5 2 3 2 1 1 4 1 5 5 5 3 5 1 1 1 1 4 5 5 2 1 4 1 1 1 5 2 5 4 4 1 5 5 4 4
## [2184] 1 1 1 5 5 5 4 1 1 1 1 5 5 5 2 4 4 1 1 5 5 5 2 1 1 1 4 1 5 5 4 4 1 1 1 5 5
## [2221] 2 1 1 1 5 5 1 5 5 2 4 4 1 1 1 5 5 1 4 1 1 5 5 1 1 1 1 1 5 5 2 3 4 1 1 5 1
## [2258] 2 2 4 4 1 5 5 5 1 1 5 5 1 1 5 5 4 1 5 1 5 5 4 4 1 1 1 1 5 5 5 5 4 1 4 5 5
## [2295] 5 3 5 4 4 4 1 2 4 1 1 5 5 3 2 1 4 1 1 1 1 1 1 5 1 2 4 4 5 5 4 4 1 1 2 2 4
## [2332] 1 1 5 5 5 4 1 1 4 1 2 3 4 1 5 5 5 5 2 2 4 4 1 1 1 5 5 5 5 4 1 1 1 5 5 5 4
## [2369] 1 1 1 1 1 5 2 5 1 4 1 1 5 5 2 5 4 1 1 1 5 4 4 4 1 5 5 5 3 4 1 1 1 5 5 5 4
## [2406] 1 1 1 1 1 5 4 4 1 1 5 5 5 5 4 1 1 1 1 5 2 2 4 1 1 5 1 5 2 4 4 1 4 1 5 5 5
## [2443] 5 4 4 5 5 5 2 5 4 1 1 1 5 5 5 2 2 4 4 1 1 4 4 4 1 1 5 2 2 1 5 5 5 5 5 5 5
## [2480] 2 4 4 4 5 5 5 5 2 4 1 1 1 5 5 4 1 1 1 5 5 5 4 1 1 5 5 5 2 5 2 4 1 1 1 5 5
## [2517] 2 1 1 1 1 5 5 5 2 4 4 1 1 1 5 2 4 4 1 1 5 5 4 1 1 1 1 5 5 5 5 5 2 4 1 4 5
## [2554] 5 5 5 2 1 1 1 1 2 5 2 2 4 4 1 1 2 2 4 1 1 1 5 5 3 5 5 1 1 1 5 5 1 5 5
## 
## Within cluster sum of squares by cluster:
## [1] 1372.4850  344.7167  208.7650 1231.6898 1387.6263
##  (between_SS / total_SS =  70.7 %)
## 
## Available components:
## 
## [1] "cluster"      "centers"      "totss"        "withinss"     "tot.withinss"
## [6] "betweenss"    "size"         "iter"         "ifault"
```

Interpreting this output, the very first thing you need to know is that **the cluster numbers are meaningless**. They aren't ranks. They aren't anything. After you have taken that on board, look at the cluster sizes at the top. Clusters 3 and 5 are pretty large compared to others. That's notable. Then we can look at the cluster means. For reference, 0 is going to be average. So group 1 are well above average on minutes played. Group 3 is slightly above, group 5 is slightly below. In fact, group 5 is below average on every metric. Group 3 is slightly above average on all metrics. 

So which group is Cam Mack in? Well, first we have to put our data back together again. In K5, there is a list of cluster assignments in the same order we put them in, but recall we have no names. So we need to re-combine them with our original data. We can do that with the following:


```r
playercluster <- data.frame(playersselected, k5$cluster) 
```

Now we have a dataframe called playercluster that has our player names and what cluster they are in. The fastest way to find Cam Mack is to double click on the playercluster table in the environment and use the search in the top right of the table. Because this is based on some random selections of points to start the groupings, these may change from person to person, but Mack is in Group 1 in my data. 

We now have a dataset and can plot it like anything else. Let's get Cam Mack and then plot him against the rest of college basketball on assists versus minutes played. 


```r
cm <- playercluster %>% filter(Player == "Cameron Mack")
```


```r
ggplot() + 
  geom_point(data=playercluster, aes(x=MP, y=AST, color=k5.cluster)) + 
  geom_point(data=cm, aes(x=MP, y=AST), color="red")
```

![](30-clustering_files/figure-epub3/unnamed-chunk-10-1.png)<!-- -->

Not bad, not bad. But who are Cam Mack's peers? If we look at the numbers in Group 1, there's 335 of them. So let's limit them to just Big Ten guards. Unfortunately, my scraper didn't quite work and in the place of Conference is the coach's name. So I'm going to have to do this the hard way and make a list of Big Ten teams and filter on that. Then I'll sort by minutes played. 


```r
big10 <- c("Nebraska Cornhuskers", "Iowa Hawkeyes", "Minnesota Golden Gophers", "Illinois Fighting Illini", "Northwestern Wildcats", "Wisconsin Badgers", "Indiana Hoosiers", "Purdue Boilermakers", "Ohio State Buckeyes", "Michigan Wolverines", "Michigan State Spartans", "Penn State Nittany Lions", "Rutgers Scarlet Knights", "Maryland Terrapins")

playercluster %>% filter(k5.cluster == 4) %>% filter(Team %in% big10) %>% arrange(desc(MP))
```

```
##             Player                     Team Pos  MP   FG.  X3P. AST TOV PTS
## 1     Cameron Mack     Nebraska Cornhuskers   G 563 0.425 0.343 108  44 203
## 2      Marcus Carr Minnesota Golden Gophers   G 544 0.369 0.310 103  49 233
## 3      Ayo Dosunmu Illinois Fighting Illini   G 538 0.468 0.304  50  45 263
## 4    Anthony Cowan       Maryland Terrapins   G 532 0.388 0.344  65  36 259
## 5  Eric Hunter Jr.      Purdue Boilermakers   G 517 0.415 0.390  48  34 174
## 6   Zavier Simpson      Michigan Wolverines   G 495 0.497 0.341 133  52 182
## 7   D'Mitrik Trice        Wisconsin Badgers   G 484 0.372 0.338  51  26 151
## 8     Myreon Jones Penn State Nittany Lions   G 472 0.443 0.400  44  26 221
## 9  Cassius Winston  Michigan State Spartans   G 471 0.439 0.386  94  40 291
## 10   Aljami Durham         Indiana Hoosiers   G 427 0.455 0.362  43  33 172
## 11    Andres Feliz Illinois Fighting Illini   G 426 0.478 0.273  54  29 180
## 12     Pat Spencer    Northwestern Wildcats   G 408 0.443 0.333  59  39 162
## 13     D.J. Carton      Ohio State Buckeyes   G 372 0.483 0.409  44  45 160
##    k5.cluster
## 1           4
## 2           4
## 3           4
## 4           4
## 5           4
## 6           4
## 7           4
## 8           4
## 9           4
## 10          4
## 11          4
## 12          4
## 13          4
```

So there are the 8 guards most like Cam Mack in the Big Ten. It'll be interesting to watch this evolve over the season. Fred Hoiberg and others think he might be one of the best guards in the league. We'll see, using cluster analysis. 

## Advanced metrics

How much does this change if we change the metrics? I used pretty standard box score metrics above. What if we did it using Player Efficiency Rating, True Shooting Percentage, Point Production, Assist Percentage, Win Shares Per 40 Minutes and Box Plus Minus (you can get definitions of all of them by [hovering over the stats on Nebraksa's stats page](https://www.sports-reference.com/cbb/schools/nebraska/2020.html)). 

We'll repeat the process. Filter out players who don't play, players with stats missing, and just focus on those stats listed above. 


```r
playersadvanced <- players %>% 
  filter(MP>0) %>% 
  filter(Pos == "G") %>% 
  select(Player, Team, Pos, PER, `TS%`, PProd, `AST%`, `WS/40`, BPM) %>% 
  na.omit() 
```

Now to scale them. 


```r
playersadvscaled <- playersadvanced %>% 
  select(PER, `TS%`, PProd, `AST%`, `WS/40`, BPM) %>% 
  mutate_all(scale) %>% 
  na.omit()
```

Let's find the optimal number of clusters.


```r
# function to compute total within-cluster sum of square 
wss <- function(k) {
  kmeans(playersadvscaled, k, nstart = 10 )$tot.withinss
}

# Compute and plot wss for k = 1 to k = 15
k.values <- 1:15

# extract wss for 2-15 clusters
wss_values <- map_dbl(k.values, wss)

plot(k.values, wss_values,
       type="b", pch = 19, frame = FALSE, 
       xlab="Number of clusters K",
       ylab="Total within-clusters sum of squares")
```

![](30-clustering_files/figure-epub3/unnamed-chunk-14-1.png)<!-- -->

Looks like 5 again. 


```r
advk5 <- kmeans(playersadvscaled, centers = 5, nstart = 25)
```

What do we have here?


```r
advk5
```

```
## K-means clustering with 5 clusters of sizes 101, 5, 230, 966, 1411
## 
## Cluster means:
##          PER        TS%     PProd       AST%       WS/40        BPM
## 1  1.8173376  2.5167347 -1.095507  0.5995651  1.35903666  1.2047065
## 2 12.2334911  4.9361050 -1.147474 -1.3499301 13.72609915  7.7293600
## 3 -1.7517603 -2.0432886 -1.142946 -0.6041075 -1.74472104 -1.9096527
## 4  0.3911772  0.2471997  1.090278  0.4522807  0.34379345  0.4644269
## 5 -0.1556987 -0.0338124 -0.477638 -0.2493018 -0.09689003 -0.1202965
## 
## Clustering vector:
##    [1] 4 5 5 5 5 5 5 5 5 4 5 4 5 5 5 1 4 4 5 5 5 5 5 3 4 5 4 5 5 5 5 5 4 4 4 5 5
##   [38] 5 3 4 4 4 5 4 5 5 5 1 4 4 4 4 5 5 1 4 4 5 5 4 4 5 5 1 4 4 4 4 5 5 5 5 5 5
##   [75] 5 4 4 4 4 5 5 3 5 3 4 5 5 5 5 5 5 3 4 4 4 4 5 5 3 4 4 5 5 5 5 3 4 4 5 5 5
##  [112] 5 5 1 3 4 4 5 5 5 5 5 3 4 4 5 5 5 5 5 4 4 5 5 1 1 3 4 5 5 5 5 5 4 4 5 5 5
##  [149] 5 5 3 4 4 5 5 5 5 3 4 4 5 5 5 5 1 5 3 4 4 4 4 5 4 4 3 4 4 4 5 4 5 5 5 4 4
##  [186] 5 4 5 5 5 5 5 5 4 4 5 3 4 4 5 5 5 5 5 5 4 4 5 5 5 2 1 3 3 4 5 4 5 4 5 1 5
##  [223] 5 5 4 4 5 5 5 3 3 4 4 4 5 4 5 5 5 4 4 4 4 5 4 4 4 4 5 5 5 1 5 3 4 4 4 5 5
##  [260] 5 3 4 4 4 4 5 5 5 5 3 3 4 4 5 5 5 5 5 5 3 4 4 5 5 5 5 1 5 3 4 4 5 5 1 5 4
##  [297] 4 4 4 5 3 4 4 4 4 4 5 5 5 4 4 4 4 5 5 5 5 1 4 5 5 5 5 5 3 5 4 4 5 5 5 5 4
##  [334] 4 5 5 5 5 1 4 4 5 4 5 5 5 4 4 4 5 4 4 5 4 4 5 5 5 5 5 4 5 5 5 5 5 3 4 4 5
##  [371] 5 5 5 5 3 3 4 4 4 4 5 5 4 5 4 5 4 5 5 5 3 3 1 5 3 4 4 4 5 5 5 5 1 4 4 5 5
##  [408] 5 5 4 4 4 5 5 1 3 4 4 5 5 3 3 3 4 4 4 5 5 5 1 4 5 4 5 5 5 5 5 1 4 4 5 4 4
##  [445] 5 5 5 4 4 5 5 5 5 4 4 4 4 5 4 5 3 3 4 4 5 5 5 5 5 3 4 4 5 5 5 5 3 5 5 5 5
##  [482] 5 5 5 5 4 4 4 5 5 5 5 3 4 4 5 5 5 5 5 5 3 4 4 5 5 5 1 5 3 4 4 5 4 5 5 5 4
##  [519] 4 4 5 5 5 5 5 5 4 5 5 4 5 5 3 3 4 5 5 5 5 5 3 4 5 5 5 5 5 5 5 4 4 5 5 5 5
##  [556] 5 1 4 4 4 5 5 5 5 3 4 4 4 4 4 5 5 5 1 4 4 4 5 5 5 4 4 5 5 5 5 5 5 5 5 5 4
##  [593] 5 3 5 3 4 4 5 5 5 5 5 3 4 4 4 5 5 5 3 4 4 4 5 5 4 5 4 4 5 5 5 5 5 5 5 4 4
##  [630] 5 5 5 3 3 4 4 5 4 5 5 5 5 5 4 4 4 4 5 4 4 4 5 5 5 5 3 4 4 4 5 5 5 3 4 4 5
##  [667] 5 5 1 3 5 4 4 4 4 4 5 5 4 5 5 5 5 5 5 3 3 4 4 4 5 5 5 4 4 5 5 4 5 5 2 3 4
##  [704] 5 5 5 5 5 4 4 5 5 5 5 5 5 1 3 5 4 4 4 5 5 5 4 5 4 5 5 5 5 4 4 4 4 5 4 1 5
##  [741] 3 4 4 4 4 4 5 3 3 4 4 5 5 3 5 3 5 4 4 4 5 5 1 3 4 4 4 5 5 4 5 5 3 4 4 4 5
##  [778] 4 4 5 5 5 5 5 5 5 4 4 5 5 3 4 4 4 5 5 5 5 4 4 4 4 5 5 1 4 4 5 5 5 5 5 3 4
##  [815] 5 5 5 5 5 5 5 3 4 4 5 5 5 5 4 5 5 5 3 4 4 4 4 5 5 5 4 4 5 5 5 5 5 4 4 4 4
##  [852] 5 5 5 3 4 4 5 5 5 3 3 4 4 4 5 5 5 5 5 5 4 4 4 5 5 1 3 4 4 4 4 4 5 5 4 5 4
##  [889] 4 4 4 5 4 4 5 5 5 5 4 4 5 5 5 5 5 4 4 4 5 5 5 1 3 4 4 5 5 1 3 4 4 5 5 5 5
##  [926] 5 5 4 4 5 5 5 3 3 4 4 4 5 5 4 4 5 5 5 5 5 5 4 4 4 4 5 5 3 4 4 5 5 5 5 4 4
##  [963] 5 5 5 5 5 5 4 4 4 5 5 4 5 5 5 4 4 4 5 5 5 4 4 5 5 5 5 5 4 4 4 5 5 4 5 4 4
## [1000] 5 4 5 5 1 3 4 4 4 5 5 5 5 5 3 4 4 5 5 5 5 5 5 1 4 4 4 5 5 3 4 4 5 5 5 5 3
## [1037] 4 4 4 5 5 5 5 5 5 4 4 5 5 5 5 5 1 5 4 4 4 5 5 5 5 5 5 1 4 4 4 5 3 3 4 5 4
## [1074] 4 5 5 5 5 5 4 5 5 5 5 3 5 4 4 5 5 5 3 4 4 4 4 5 5 5 5 3 4 4 4 5 5 5 3 4 4
## [1111] 4 4 5 5 5 5 5 5 1 4 4 5 5 5 5 5 4 4 5 4 4 5 5 5 5 4 4 5 5 5 5 5 5 5 4 4 4
## [1148] 5 5 5 5 5 4 4 4 4 4 5 5 5 1 5 3 4 4 5 5 5 4 1 1 1 1 3 4 5 5 5 5 5 4 4 4 4
## [1185] 5 3 4 4 4 5 5 5 3 4 4 4 5 5 5 5 5 4 4 4 4 5 5 5 5 4 4 4 5 2 5 3 3 4 4 4 4
## [1222] 5 5 3 4 5 4 5 3 5 3 1 3 4 4 4 5 5 5 3 5 4 4 4 4 5 3 4 4 5 5 5 4 4 5 5 5 4
## [1259] 4 4 5 5 5 5 4 4 4 4 5 5 5 1 4 4 5 5 5 5 5 4 4 4 4 5 5 5 5 4 4 5 5 5 5 3 3
## [1296] 4 5 5 5 5 5 3 4 4 4 5 5 3 4 4 4 5 5 3 4 4 4 5 5 5 5 1 4 4 4 4 5 5 3 4 4 4
## [1333] 5 5 1 3 1 4 5 1 5 5 1 3 3 4 4 4 5 5 5 1 4 4 4 5 5 3 4 5 5 5 5 5 5 5 1 4 4
## [1370] 5 5 5 5 5 5 5 4 5 4 4 5 5 4 4 4 5 5 5 5 5 4 4 4 5 5 5 5 1 3 4 4 4 5 5 5 3
## [1407] 3 4 4 4 4 5 5 1 5 4 5 5 5 5 5 5 5 3 4 4 5 4 5 5 5 3 4 4 5 5 5 5 4 4 4 5 5
## [1444] 5 5 5 5 5 5 3 5 5 5 5 5 1 3 5 4 5 5 3 5 5 3 4 4 4 4 5 5 5 3 3 3 3 5 5 5 5
## [1481] 5 4 4 4 5 5 5 5 3 3 4 4 4 5 5 5 5 4 4 4 4 5 5 5 1 5 4 4 4 5 5 5 5 4 4 5 5
## [1518] 5 3 5 4 4 4 5 5 5 5 5 4 5 4 5 5 5 4 4 5 4 4 5 1 5 4 4 4 5 5 5 5 4 4 4 5 5
## [1555] 5 5 5 5 4 4 4 4 5 5 5 5 4 5 5 5 5 3 3 4 4 4 4 5 5 4 4 5 5 5 1 5 4 5 5 4 5
## [1592] 4 5 4 4 4 5 5 4 4 4 5 5 5 5 5 5 5 5 5 3 3 3 4 4 4 5 5 5 5 1 5 4 5 4 5 5 4
## [1629] 4 4 5 5 5 5 4 4 5 5 5 5 5 3 5 4 5 4 4 5 4 5 5 5 4 4 5 5 5 5 5 5 5 3 1 4 4
## [1666] 4 5 5 5 3 4 4 5 5 4 5 3 4 4 4 4 4 5 3 3 4 4 5 5 5 5 5 1 3 3 4 5 5 5 5 3 3
## [1703] 3 4 4 4 5 1 3 4 4 4 4 5 5 5 5 3 3 4 4 4 5 5 5 5 5 1 4 4 4 4 5 5 3 4 5 5 5
## [1740] 5 4 5 5 5 4 4 5 5 5 4 5 4 5 5 5 5 5 4 4 5 1 5 5 1 1 4 4 5 5 5 5 5 5 4 4 4
## [1777] 4 5 4 4 5 5 5 5 3 4 4 5 5 3 5 3 4 4 4 4 5 5 5 5 3 4 4 5 5 5 3 4 4 4 5 5 5
## [1814] 4 4 5 5 5 5 5 4 4 4 5 5 5 5 4 4 5 5 5 5 5 5 5 1 3 4 4 4 4 4 5 5 1 4 4 4 5
## [1851] 5 4 5 5 5 5 5 1 5 1 5 3 4 4 4 5 5 1 4 4 5 4 5 5 3 3 4 5 4 5 5 5 1 4 4 4 4
## [1888] 4 3 3 4 4 4 4 5 5 1 5 3 4 4 4 4 4 4 3 4 5 4 5 5 5 1 3 4 4 4 4 5 3 3 3 4 4
## [1925] 4 5 5 5 1 4 4 4 4 5 5 5 5 5 4 4 4 5 5 5 5 5 3 4 4 5 5 5 5 5 4 5 4 5 5 4 4
## [1962] 4 5 5 1 1 5 5 3 4 4 5 5 5 4 5 5 5 4 4 4 5 3 5 5 3 4 4 4 5 5 5 5 4 5 5 5 5
## [1999] 4 5 5 5 5 5 3 4 4 4 5 5 4 4 4 5 5 5 5 1 3 3 4 4 4 4 5 3 3 5 3 3 4 4 4 5 5
## [2036] 5 5 5 5 5 5 4 4 5 5 5 5 4 4 5 5 5 5 5 4 4 4 4 4 5 5 5 4 4 4 4 4 3 4 5 5 5
## [2073] 5 5 5 4 4 4 5 5 3 1 1 4 4 5 4 3 4 4 4 5 3 4 4 4 5 5 5 5 5 1 3 4 5 5 5 5 3
## [2110] 4 4 5 5 5 5 3 3 4 4 5 5 5 5 5 5 4 4 4 5 5 1 3 4 4 5 5 5 5 5 5 5 4 4 4 4 5
## [2147] 5 5 1 1 3 4 4 4 4 5 5 5 5 4 4 4 5 5 5 1 5 1 4 4 4 5 5 5 5 5 4 5 5 1 5 5 4
## [2184] 4 4 4 5 5 5 5 5 4 4 5 4 5 5 3 3 4 5 5 5 5 5 5 5 4 4 4 5 5 5 5 4 4 4 5 5 5
## [2221] 1 1 4 4 4 5 5 5 5 2 4 4 4 5 5 5 1 1 4 4 4 4 4 5 5 3 4 4 4 5 5 5 5 5 1 5 4
## [2258] 4 4 4 5 5 5 5 5 4 4 4 5 4 5 5 3 4 4 4 5 5 5 5 5 4 4 5 5 3 4 4 5 5 5 4 5 5
## [2295] 4 4 4 4 5 5 5 5 3 4 4 5 5 5 5 5 5 4 4 4 4 4 5 5 4 4 5 4 5 5 5 3 4 5 5 5 5
## [2332] 5 5 3 3 4 4 4 5 5 5 5 4 4 5 5 5 5 4 4 4 4 5 5 5 5 2 4 4 5 5 5 3 3 4 4 5 5
## [2369] 5 5 4 4 5 4 5 4 5 5 4 5 5 5 5 5 4 4 4 4 5 5 5 5 5 1 4 4 4 5 5 5 1 5 4 4 4
## [2406] 5 3 4 4 5 5 5 1 5 4 4 5 5 5 5 5 5 5 5 5 1 4 4 5 5 4 4 5 4 5 5 3 3 4 5 4 5
## [2443] 5 5 4 5 4 4 4 5 1 4 5 5 5 5 5 5 3 4 4 4 4 4 5 5 5 5 3 4 4 5 5 5 5 5 4 4 4
## [2480] 5 5 5 5 5 5 1 4 4 5 5 5 5 5 5 3 4 4 4 5 5 3 4 4 4 5 5 5 1 5 4 4 5 5 5 5 5
## [2517] 4 5 5 5 5 5 5 4 4 5 5 5 5 5 5 5 4 4 4 5 4 5 3 3 4 4 5 5 4 5 5 4 4 4 4 5 5
## [2554] 5 5 5 4 4 5 5 5 5 5 3 4 4 5 5 5 5 5 3 3 4 4 4 5 5 3 4 4 4 5 5 5 3 3 5 5 5
## [2591] 5 5 5 5 5 5 3 3 4 4 4 5 5 5 5 3 4 4 5 4 5 5 4 4 5 4 5 5 5 5 4 4 4 5 5 5 3
## [2628] 5 3 4 4 5 5 5 5 3 5 4 4 4 5 5 5 5 1 3 4 4 4 4 5 5 3 4 4 4 5 5 5 4 5 5 5 5
## [2665] 5 5 5 3 3 3 4 4 4 5 5 5 5 3 3 4 5 5 5 5 5 3 3 4 4 4 5 3 1 3 4 4 5 5 5 5 1
## [2702] 5 5 5 5 4 4 4 5 5 5 5 1
## 
## Within cluster sum of squares by cluster:
## [1] 1222.64345   55.88366 1433.24343 1701.23755 2324.79583
##  (between_SS / total_SS =  58.6 %)
## 
## Available components:
## 
## [1] "cluster"      "centers"      "totss"        "withinss"     "tot.withinss"
## [6] "betweenss"    "size"         "iter"         "ifault"
```

Looks like this time, cluster 1 is all below average and cluster 5 is all above. Which cluster is Cam Mack in?


```r
playeradvcluster <- data.frame(playersadvanced, advk5$cluster) 
```

Cluster 5 on my dataset. So three games in, we can say he's in a big group of players who are all above average on these advanced metrics. 

Now who are his Big Ten peers?


```r
playeradvcluster %>% 
  filter(advk5.cluster == 5) %>% 
  filter(Team %in% big10) %>% 
  arrange(desc(PProd))
```

```
##                   Player                     Team Pos  PER   TS. PProd AST.
## 1           Jervay Green     Nebraska Cornhuskers   G 11.6 0.463   114 16.6
## 2          Montez Mathis  Rutgers Scarlet Knights   G 11.4 0.429   109 10.2
## 3       Curtis Jones Jr. Penn State Nittany Lions   G 11.8 0.459   105 12.2
## 4        Luther Muhammad      Ohio State Buckeyes   G  9.2 0.519   100 10.8
## 5  Thorir Thorbjarnarson     Nebraska Cornhuskers   G 14.1 0.641   100  6.9
## 6           Franz Wagner      Michigan Wolverines   G 12.8 0.544    89  2.7
## 7          Nojel Eastern      Purdue Boilermakers   G  8.9 0.362    83 20.1
## 8         Jamari Wheeler Penn State Nittany Lions   G 11.6 0.596    80 18.2
## 9        Armaan Franklin         Indiana Hoosiers   G  6.5 0.432    80 18.0
## 10            Mark Watts  Michigan State Spartans   G  7.7 0.411    79 18.9
## 11           Matej Kavas     Nebraska Cornhuskers   G  9.9 0.511    78  6.7
## 12       Isaiah Thompson      Purdue Boilermakers   G  7.2 0.438    72  8.9
## 13        Anthony Gaines    Northwestern Wildcats   G 12.6 0.505    65 11.9
## 14         Tre' Williams Minnesota Golden Gophers   G  5.8 0.399    63 11.9
## 15     Da'Monte Williams Illinois Fighting Illini   G  9.4 0.452    57  9.9
## 16           Kyle Ahrens  Michigan State Spartans   G  7.6 0.537    46  5.7
## 17         Bakari Evelyn            Iowa Hawkeyes   G  3.0 0.448    45 11.9
## 18       Trevor Anderson        Wisconsin Badgers   G  9.0 0.514    37 21.4
## 19          Adrien Nunez      Michigan Wolverines   G  3.2 0.449    28  1.4
## 20       Serrel Smith Jr       Maryland Terrapins   G  3.8 0.402    28 13.6
## 21            Hakim Hart       Maryland Terrapins   G  7.9 0.392    24 22.6
## 22            Ryan Greer    Northwestern Wildcats   G  7.0 0.355    17 25.5
## 23        Charlie Easley     Nebraska Cornhuskers   G  9.0 0.465    17  9.0
## 24         Conner George  Michigan State Spartans   G 19.1 0.473    16  4.3
## 25          Walt McGrory        Wisconsin Badgers   G  8.9 0.460    12 11.9
## 26         Samari Curtis     Nebraska Cornhuskers   G  9.7 0.639    11  3.7
## 27         Daniel Hummer      Ohio State Buckeyes   G 12.2 0.391    10 28.2
## 28       Tyler Underwood Illinois Fighting Illini   G  7.3 0.434     9 12.5
## 29            Tommy Luce      Purdue Boilermakers   G  6.2 0.250     6 46.2
## 30        Bryan Greenlee Minnesota Golden Gophers   G -1.0 0.250     3 15.1
## 31         Travis Valmon       Maryland Terrapins   G 19.0 0.678     3  0.0
## 32           Nick Brooks  Rutgers Scarlet Knights   G  4.9 0.500     2 22.2
## 33         Jared Wulbrun      Purdue Boilermakers   G -0.4 0.750     2  0.0
##     WS.40   BPM advk5.cluster
## 1   0.061   1.7             5
## 2   0.123   3.1             5
## 3   0.106   0.8             5
## 4   0.122   4.9             5
## 5   0.121   3.6             5
## 6   0.113   5.7             5
## 7   0.079   3.2             5
## 8   0.109   4.6             5
## 9   0.057  -0.6             5
## 10  0.078   0.7             5
## 11  0.065  -1.6             5
## 12  0.094   0.9             5
## 13  0.107   4.0             5
## 14  0.041   0.6             5
## 15  0.110   6.2             5
## 16  0.091   3.5             5
## 17  0.014   0.5             5
## 18  0.097   2.4             5
## 19  0.020  -1.5             5
## 20  0.035  -0.9             5
## 21  0.104   1.0             5
## 22  0.053  -3.4             5
## 23  0.049  -2.4             5
## 24  0.204   1.6             5
## 25  0.117   2.0             5
## 26  0.088  -1.2             5
## 27  0.129   7.7             5
## 28  0.100  -0.5             5
## 29  0.014  -3.6             5
## 30 -0.063  -4.1             5
## 31  0.212   3.4             5
## 32  0.023 -10.1             5
## 33 -0.054  -5.9             5
```

Sorting on Points Produced, Cam Mack is eighth out of the 31 guards in the Big Ten who land in Cluster 5. 

It's early goings, but watch this player. He's fun to watch and the stats back it up. 
