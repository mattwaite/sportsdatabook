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
## ── Attaching packages ── tidyverse 1.2.1 ──
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
## ── Conflicts ───── tidyverse_conflicts() ──
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
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
##   Conference = col_character(),
##   Player = col_character(),
##   Class = col_logical(),
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
playersscaled <- playersselected %>% select(MP, `FG%`, `3P%`, AST, TOV, PTS) %>% mutate_all(scale) %>% na.omit()
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
## K-means clustering with 5 clusters of sizes 335, 278, 770, 176, 667
## 
## Cluster means:
##           MP        FG%        3P%        AST        TOV        PTS
## 1  1.3272437  0.2218012  0.1023867  1.5629745  1.5621897  1.3850514
## 2 -1.3023386 -1.6905294 -1.2541383 -0.8589040 -0.9787285 -1.2031088
## 3  0.5573612  0.2325889  0.1698514  0.2420667  0.2595768  0.4817384
## 4 -1.0266914  1.6112876  1.9878929 -0.7130793 -0.7795732 -0.6763580
## 5 -0.4963222 -0.1004742 -0.2493310 -0.5183066 -0.4706391 -0.5718554
## 
## Clustering vector:
##    [1] 3 5 5 5 5 2 2 3 3 3 4 5 5 2 3 3 5 5 2 1 3 5 5 5 4 3 3 3 3 5 5 1 1 3
##   [35] 3 3 5 4 2 3 3 3 3 5 1 3 3 5 5 5 5 5 2 1 3 1 5 5 5 3 5 5 3 4 5 2 1 3
##   [69] 3 5 5 2 1 1 3 3 3 5 2 3 3 5 5 5 1 3 3 5 5 4 2 2 2 4 5 4 5 5 5 5 5 5
##  [103] 5 2 2 2 2 3 1 5 2 3 4 5 2 2 1 3 3 5 5 1 1 1 3 5 2 2 5 3 5 2 2 2 5 2
##  [137] 1 3 5 4 3 1 5 2 1 1 3 1 3 3 4 1 3 5 5 5 5 5 4 3 3 2 3 3 3 5 5 1 3 4
##  [171] 5 1 3 1 3 5 5 4 2 3 1 5 4 4 5 1 3 1 3 3 3 1 1 3 3 1 5 3 3 1 5 5 5 3
##  [205] 3 3 1 3 3 3 3 3 3 5 4 5 2 1 3 3 3 2 2 1 3 3 3 5 4 1 3 3 3 2 1 3 3 3
##  [239] 4 3 3 3 5 5 4 5 1 1 1 3 5 5 5 2 3 5 5 5 2 2 1 1 4 5 2 2 1 3 1 3 3 3
##  [273] 3 3 4 2 2 3 3 4 3 5 3 2 3 3 3 5 2 2 3 3 5 5 3 2 1 1 3 3 3 2 4 2 3 3
##  [307] 1 3 5 4 1 3 3 1 5 2 2 3 3 3 3 1 5 5 3 1 3 4 5 3 3 3 5 5 3 3 5 2 1 1
##  [341] 1 5 2 2 3 3 3 5 5 5 5 4 4 1 3 1 3 5 2 5 1 3 3 5 4 1 1 3 5 3 5 5 2 1
##  [375] 3 3 3 2 1 1 3 5 3 3 5 5 5 5 5 5 1 3 3 3 3 2 2 3 3 5 2 1 3 3 5 1 1 3
##  [409] 5 5 5 1 3 3 1 3 5 2 3 3 1 5 5 1 3 3 5 5 5 2 4 5 4 4 2 2 3 1 5 5 4 5
##  [443] 5 1 1 1 3 5 5 5 1 1 3 3 5 3 2 2 2 3 4 3 5 5 2 3 3 3 5 3 1 4 5 3 4 5
##  [477] 3 4 5 2 2 3 5 5 5 5 1 1 3 5 5 5 2 3 3 5 5 4 3 1 3 5 3 3 3 5 4 3 3 3
##  [511] 4 5 3 3 3 5 4 4 5 2 3 1 3 3 5 1 1 3 3 5 5 3 4 3 4 2 2 1 1 3 3 5 4 2
##  [545] 3 5 3 5 5 5 5 4 5 5 5 5 2 2 1 3 4 4 5 4 1 3 5 5 1 5 4 4 2 1 3 3 5 2
##  [579] 1 1 3 3 3 4 3 1 5 5 2 4 5 5 4 5 2 1 3 3 3 5 5 2 1 3 1 3 5 1 3 3 5 4
##  [613] 2 1 3 3 2 5 3 1 3 1 3 3 2 3 3 3 4 1 3 4 5 5 5 4 2 5 5 5 2 3 1 5 5 5
##  [647] 1 1 3 3 5 4 3 5 5 5 2 4 1 3 5 3 5 5 5 2 3 3 5 3 5 1 5 5 3 3 3 5 1 4
##  [681] 4 3 1 5 5 5 1 1 1 3 3 2 2 1 3 5 4 5 5 3 3 3 5 2 5 3 3 5 5 4 2 1 3 3
##  [715] 5 3 3 5 1 3 3 4 3 1 3 5 5 2 3 1 3 1 5 4 1 3 3 5 5 1 3 3 5 3 1 3 5 5
##  [749] 5 2 1 3 3 2 1 3 3 3 2 1 1 5 2 2 2 2 1 1 3 3 5 5 2 5 5 2 3 3 3 5 5 4
##  [783] 5 5 5 4 1 4 1 3 3 5 2 2 3 1 3 5 5 5 1 3 5 3 5 5 2 1 1 3 3 5 3 5 3 4
##  [817] 5 5 5 2 2 1 3 3 5 4 5 2 3 1 3 4 5 2 4 2 1 1 3 3 5 2 3 3 5 2 4 2 1 1
##  [851] 3 3 3 3 5 5 4 1 5 5 5 5 3 3 3 1 5 5 5 5 2 1 3 3 1 2 2 1 3 3 3 1 4 1
##  [885] 3 5 5 1 4 2 1 5 3 5 5 2 3 3 3 3 3 5 5 3 3 1 2 2 3 3 3 3 5 5 5 5 4 2
##  [919] 2 1 3 5 5 5 4 1 3 3 1 5 5 4 1 3 3 3 5 5 5 2 3 3 3 4 5 4 5 1 3 3 3 3
##  [953] 1 4 2 2 1 3 3 3 3 5 2 2 1 3 3 4 5 5 1 1 3 5 5 1 1 3 3 1 5 3 5 5 5 2
##  [987] 1 1 3 3 5 2 2 2 3 3 3 5 4 5 2 3 3 3 5 2 5 1 3 5 5 2 4 3 3 3 5 5 5 2
## [1021] 1 3 1 5 3 1 3 3 3 5 1 1 1 5 2 1 3 3 3 1 5 5 1 3 1 3 5 2 1 1 3 2 5 2
## [1055] 3 3 3 5 1 5 4 5 3 3 5 5 5 5 1 3 3 3 2 2 1 3 3 3 1 3 3 5 3 1 3 3 4 5
## [1089] 5 4 1 3 3 5 1 2 3 1 5 5 1 3 5 5 2 2 2 3 5 3 4 5 4 2 3 3 3 3 5 1 3 3
## [1123] 3 3 5 5 1 1 3 3 4 5 5 1 3 5 3 1 5 2 1 1 3 3 5 3 5 1 3 3 3 4 5 4 4 2
## [1157] 1 1 1 1 3 5 2 2 3 4 3 3 5 5 4 5 3 3 3 5 5 5 1 3 3 3 4 2 2 3 1 5 3 3
## [1191] 5 4 2 3 5 5 5 5 2 5 5 5 5 4 2 2 1 5 4 2 1 3 3 5 5 3 2 2 5 5 5 2 3 3
## [1225] 3 5 5 5 3 3 1 3 2 3 3 5 3 5 5 4 2 1 1 5 2 2 1 1 2 5 2 3 1 5 5 3 1 3
## [1259] 1 5 3 1 5 3 3 5 3 1 3 5 5 5 5 3 3 3 3 5 5 5 2 1 3 3 3 2 1 3 3 3 5 2
## [1293] 1 1 1 3 5 1 3 3 3 3 3 5 5 5 3 3 2 1 1 3 2 3 3 3 5 5 2 2 3 5 5 4 5 2
## [1327] 3 3 4 3 4 4 5 4 1 5 5 5 1 3 3 5 5 5 1 3 1 1 3 2 5 4 5 5 5 4 4 5 1 1
## [1361] 3 3 5 5 5 5 2 1 3 3 3 3 2 1 1 3 3 3 5 3 3 3 4 5 2 3 1 5 4 5 2 2 3 3
## [1395] 5 5 2 3 3 3 2 3 3 4 5 5 2 4 3 3 5 3 3 2 2 1 1 3 5 5 3 5 5 3 5 4 4 1
## [1429] 3 3 5 1 3 5 1 3 5 5 1 3 5 5 5 4 1 3 5 3 5 3 5 5 5 5 5 5 3 3 3 5 3 2
## [1463] 3 3 5 2 3 3 3 1 5 4 5 3 3 5 5 5 1 1 1 3 5 2 3 1 3 5 5 5 5 3 3 3 1 3
## [1497] 5 1 3 5 5 5 4 5 2 2 1 3 3 5 4 5 5 1 3 1 3 3 3 4 4 3 5 4 5 5 3 1 3 5
## [1531] 4 4 3 3 3 5 5 2 3 5 5 5 2 1 1 3 3 3 3 3 3 3 3 5 2 1 3 3 3 5 5 1 3 5
## [1565] 5 2 3 1 3 3 2 1 3 5 5 4 1 3 3 5 4 5 3 3 1 5 5 5 5 3 5 5 5 2 2 2 3 1
## [1599] 5 5 2 3 3 5 5 3 3 5 5 3 4 2 3 1 1 5 5 2 3 3 3 5 5 2 3 1 5 3 5 1 3 3
## [1633] 3 5 2 1 3 1 5 3 3 3 3 5 5 4 1 3 5 5 3 2 2 2 2 3 3 3 5 4 5 4 2 2 3 3
## [1667] 3 3 5 1 3 3 5 4 5 2 3 1 3 3 5 5 5 4 3 3 4 3 3 2 1 3 5 5 5 1 5 5 5 2
## [1701] 4 2 1 3 3 5 2 1 1 1 5 5 3 1 4 5 3 5 4 5 4 2 1 5 5 2 1 3 3 3 2 5 3 3
## [1735] 3 3 3 5 1 1 1 4 5 1 1 5 1 5 2 2 3 3 5 5 5 2 4 2 3 3 5 3 5 5 4 2 1 3
## [1769] 3 3 3 5 2 3 3 3 5 4 5 2 1 5 3 2 1 1 3 3 3 5 5 2 3 3 5 5 2 1 3 5 5 5
## [1803] 5 3 3 3 4 5 5 4 3 3 3 5 4 2 1 5 5 5 2 1 3 3 5 4 5 3 3 3 3 1 2 2 3 3
## [1837] 3 5 3 4 5 4 2 3 3 3 3 5 5 4 5 3 1 5 5 5 5 5 3 3 5 3 5 5 2 2 1 3 3 5
## [1871] 3 1 3 5 5 3 3 3 5 5 5 2 2 2 1 1 5 3 5 5 2 2 3 3 3 5 3 4 5 5 5 3 3 5
## [1905] 2 2 2 3 3 3 5 3 2 1 1 3 3 3 5 5 1 5 5 5 5 4 3 3 3 5 3 5 5 5 4 1 3 3
## [1939] 3 5 3 3 5 3 2 3 3 5 3 3 5 1 3 5 3 5 1 1 1 3 3 4 4 5 5 2 1 3 3 5 5 5
## [1973] 4 2 1 3 1 1 5 1 3 3 4 5 2 3 3 3 5 5 3 3 3 3 5 3 1 5 5 3 3 3 3 2 1 3
## [2007] 4 4 2 2 1 1 1 3 1 5 4 1 3 4 2 2 1 3 1 3 5 2 4 1 3 3 5 5 2 1 1 5 3 3
## [2041] 5 5 2 3 3 3 5 4 5 5 1 3 4 5 2 3 3 3 5 5 5 5 4 1 3 3 5 5 2 2 3 1 3 3
## [2075] 5 5 3 3 3 1 5 4 5 4 4 3 3 3 5 5 5 2 2 3 3 5 3 5 5 2 3 3 3 5 5 5 5 5
## [2109] 1 1 4 4 5 5 5 3 3 1 5 5 5 4 2 2 3 3 5 4 1 1 3 3 5 5 2 4 2 5 5 2 1 1
## [2143] 3 5 2 2 1 3 3 3 3 4 1 3 3 5 5 5 4 1 1 3 3 2 2 3 3 3 3 5 2 3 3 3 3 3
## [2177] 2 5 2 3 3 3 5 2 2 1 3 3 5 2 2 3 5 3 5 5 5 5 4 3 3 3 5 3 3 3 5 5 2 1
## [2211] 1 3 2 3 3 3 5 5 3 5 5 4 5 2 4 2
## 
## Within cluster sum of squares by cluster:
## [1] 1347.9499  281.9458 1591.8521  551.1131 1160.1610
##  (between_SS / total_SS =  63.0 %)
## 
## Available components:
## 
## [1] "cluster"      "centers"      "totss"        "withinss"    
## [5] "tot.withinss" "betweenss"    "size"         "iter"        
## [9] "ifault"
```

Interpreting this output, first look at the cluster sizes at the top. Clusters 3 and 5 are pretty large compared to others. That's notable. Then we can look at the cluster means. For reference, 0 is going to be average. So group 1 are well above average on minutes played. Group 3 is slightly above, group 5 is slightly below. In fact, group 5 is below average on every metric. Group 3 is slightly above average on all metrics. 

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
big10 <- c("Nebraska Cornhuskers", "Iowa Hawkeyes", "Minnesota Golden Gophers", "Illinois Fighting Illini", "Northwestern Wildcats", "Wisconsin Badgers", "Indiana Hoosiers", "Purdue Boilermakers", "Ohio State Buckeyes", "Michigan Wolverines", "Mighigan State Spartans", "Penn State Nittany Lions", "Rutgers Scarlet Knights", "Maryland Terrapins")

playercluster %>% filter(k5.cluster == 1) %>% filter(Team %in% big10) %>% arrange(desc(MP))
```

```
##            Player                     Team Pos  MP   FG.  X3P. AST TOV PTS
## 1     Marcus Carr Minnesota Golden Gophers   G 141 0.321 0.286  27  12  58
## 2     Ayo Dosunmu Illinois Fighting Illini   G 135 0.438 0.308  15  16  54
## 3    Andres Feliz Illinois Fighting Illini   G 134 0.477 0.200  14  15  64
## 4       Geo Baker  Rutgers Scarlet Knights   G 128 0.444 0.280  16   7  53
## 5 Eric Hunter Jr.      Purdue Boilermakers   G 127 0.400 0.313  16   7  43
## 6    Cameron Mack     Nebraska Cornhuskers   G 109 0.415 0.294  18   6  48
## 7  Zavier Simpson      Michigan Wolverines   G  98 0.467 0.273  22  12  34
## 8     D.J. Carton      Ohio State Buckeyes   G  93 0.593 0.444  16   9  43
##   k5.cluster
## 1          1
## 2          1
## 3          1
## 4          1
## 5          1
## 6          1
## 7          1
## 8          1
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
## K-means clustering with 5 clusters of sizes 241, 326, 8, 1002, 808
## 
## Cluster means:
##          PER        TS%      PProd       AST%      WS/40        BPM
## 1 -1.5702160 -1.8030340 -1.1638772 -0.6167876 -1.5136922 -1.6897213
## 2  0.9231452  1.2775501 -0.5205117  0.1036917  0.8577993  0.9150073
## 3  8.5636838  3.9661652 -1.1353649 -1.2003654  9.6128403  4.8778275
## 4 -0.3065738 -0.2209112 -0.4137446 -0.2570207 -0.2757232 -0.2817422
## 5  0.3912800  0.2570218  1.0814805  0.4727475  0.3521401  0.4359078
## 
## Clustering vector:
##    [1] 5 4 4 4 2 4 1 4 4 4 2 5 4 4 4 2 5 4 4 4 4 4 1 5 4 2 4 4 4 2 4 5 5 4
##   [35] 4 4 4 5 5 5 5 4 4 4 4 5 2 5 5 2 4 5 5 4 2 4 4 4 4 2 1 5 5 5 2 4 4 4
##   [69] 5 5 2 5 2 4 1 5 4 5 4 4 4 1 1 5 5 5 2 5 2 1 5 5 4 4 4 1 5 5 4 4 4 2
##  [103] 1 1 1 2 4 2 4 4 5 4 4 4 4 1 1 4 1 5 4 4 4 5 4 4 1 4 5 5 4 4 4 4 1 5
##  [137] 5 5 4 4 1 1 2 5 4 1 4 4 2 2 1 5 5 2 2 4 5 4 1 5 5 5 5 4 4 2 5 5 4 5
##  [171] 2 4 4 2 4 4 5 1 5 4 4 4 4 5 4 4 4 5 5 5 5 2 4 4 1 5 5 2 2 2 2 1 5 4
##  [205] 5 5 4 5 5 2 5 5 5 5 4 5 5 5 4 4 4 5 5 4 4 4 4 5 5 2 5 4 4 4 1 1 5 5
##  [239] 5 4 4 1 1 5 5 5 5 2 2 4 5 5 5 2 2 1 5 5 4 4 2 2 2 5 4 5 2 4 5 5 5 5
##  [273] 5 2 4 2 2 1 5 4 4 4 4 1 1 1 5 5 2 4 4 1 5 4 5 4 4 4 5 2 5 2 4 4 5 5
##  [307] 2 5 5 5 1 5 5 5 4 4 4 1 5 5 4 4 4 1 5 5 4 4 4 1 4 1 5 2 5 4 2 2 5 5
##  [341] 4 4 4 4 1 1 5 5 5 4 4 4 4 2 5 5 4 2 4 4 5 5 5 4 4 5 2 1 2 4 5 5 5 4
##  [375] 4 1 5 5 4 4 4 4 4 4 2 5 5 5 4 4 4 4 2 5 2 5 2 2 5 5 5 4 4 4 4 1 1 5
##  [409] 4 4 4 4 4 5 5 5 4 5 4 4 4 4 4 4 4 5 5 5 5 5 4 4 1 4 4 4 1 1 1 5 4 4
##  [443] 4 5 5 4 4 4 4 5 5 5 4 4 1 4 1 5 5 5 4 4 4 4 5 4 4 4 4 4 1 2 4 4 4 1
##  [477] 4 5 4 4 4 4 1 2 5 5 5 5 4 4 4 5 5 4 4 2 4 4 4 4 5 2 5 4 4 2 4 4 4 5
##  [511] 4 4 4 4 4 2 4 4 2 4 2 1 5 5 4 4 4 5 5 5 5 4 4 4 4 5 5 5 4 2 5 5 4 4
##  [545] 5 4 4 4 2 5 5 4 2 4 5 5 5 4 2 2 4 1 5 5 5 5 2 5 5 5 4 2 4 5 2 5 2 4
##  [579] 4 1 5 4 5 4 4 2 1 1 5 5 2 4 2 4 4 2 4 1 4 4 1 1 5 2 2 2 4 2 5 2 4 4
##  [613] 5 4 2 3 4 5 5 5 4 1 5 5 5 4 4 2 4 5 5 4 1 1 2 2 2 2 4 1 1 5 5 5 5 5
##  [647] 4 1 5 4 4 4 4 4 5 5 4 4 2 1 1 5 5 5 4 4 5 5 2 5 4 4 4 1 5 5 5 2 5 4
##  [681] 2 4 4 2 2 4 4 4 4 4 1 5 5 2 4 4 5 5 5 4 5 4 2 5 4 4 4 1 2 2 5 4 4 4
##  [715] 4 1 4 1 5 5 4 4 4 5 4 4 2 1 1 5 5 5 4 5 5 2 5 5 4 2 4 4 5 5 5 5 4 4
##  [749] 4 5 4 4 2 4 4 5 4 4 4 4 4 2 5 5 4 4 2 2 1 5 5 2 4 4 4 5 4 5 2 5 2 5
##  [783] 5 5 4 4 4 1 5 5 4 4 4 2 5 5 5 4 4 5 5 5 4 5 5 2 2 4 4 1 2 5 5 4 1 5
##  [817] 2 2 5 4 5 5 2 4 4 4 1 5 5 5 5 4 4 1 5 2 1 4 4 5 4 4 4 2 4 4 4 2 5 2
##  [851] 5 5 5 4 4 4 2 5 5 2 4 4 4 5 5 2 4 4 4 4 5 5 5 5 4 5 4 5 2 4 4 2 4 2
##  [885] 1 5 5 4 2 4 4 1 5 4 4 2 4 4 5 2 4 5 5 5 4 4 1 5 5 4 4 4 1 5 5 5 5 5
##  [919] 4 4 4 2 5 5 2 4 4 1 5 5 5 4 4 4 4 1 1 5 5 5 5 1 1 5 5 5 5 5 2 5 4 4
##  [953] 4 4 4 1 5 4 4 1 4 4 1 5 5 5 5 4 2 4 4 5 5 5 4 4 4 5 5 5 4 2 4 4 2 2
##  [987] 4 1 5 5 2 4 4 4 2 5 5 5 5 4 4 2 5 5 4 4 4 4 4 1 5 5 5 4 4 4 2 5 5 2
## [1021] 5 2 4 5 2 2 1 1 5 2 4 4 4 2 1 1 5 5 4 2 4 2 5 5 5 4 4 5 5 4 4 5 4 4
## [1055] 4 4 4 4 1 5 5 5 4 4 1 1 1 5 4 5 4 3 4 3 1 5 2 5 4 4 4 5 5 2 4 1 4 2
## [1089] 5 4 4 4 4 4 1 5 5 5 5 2 5 4 4 4 4 5 5 5 4 4 5 4 4 4 4 4 4 5 5 5 4 4
## [1123] 4 1 5 5 4 4 4 1 5 5 5 4 4 4 4 2 5 5 2 4 4 4 1 5 4 4 4 1 1 5 5 5 5 1
## [1157] 5 5 4 4 5 5 5 4 2 4 2 2 5 5 5 5 4 4 1 5 5 4 4 5 4 4 4 2 2 1 5 4 5 4
## [1191] 4 2 1 5 5 5 5 4 5 4 4 4 4 1 4 5 5 5 4 2 4 4 5 5 4 5 5 2 4 5 5 5 5 5
## [1225] 2 4 2 5 5 5 5 4 2 4 2 1 5 5 5 4 4 4 4 1 5 2 5 5 2 4 2 1 4 4 4 4 4 4
## [1259] 4 1 5 5 5 2 2 4 4 5 5 4 1 5 5 4 2 1 4 4 4 4 4 1 4 5 4 4 2 4 1 5 4 2
## [1293] 1 1 5 2 4 4 4 4 1 1 1 4 5 2 2 1 5 5 5 4 4 4 2 5 5 5 4 4 5 5 2 2 4 5
## [1327] 4 1 5 5 4 4 4 1 5 5 4 4 1 5 5 4 4 4 5 5 5 5 4 2 5 5 4 4 4 1 5 5 4 2
## [1361] 4 2 1 5 5 4 4 4 4 2 2 1 5 5 4 5 1 5 4 5 4 4 4 1 5 5 5 5 4 5 5 4 4 4
## [1395] 4 4 4 4 4 4 4 5 5 5 4 5 5 5 5 4 4 1 4 4 4 4 4 1 5 5 2 5 2 2 4 2 2 5
## [1429] 4 2 4 5 5 4 4 4 2 4 5 5 4 4 4 4 4 1 4 2 5 4 4 2 2 4 5 5 4 4 4 4 4 4
## [1463] 1 5 5 4 4 4 1 1 5 5 4 4 4 4 5 2 5 2 4 4 5 5 4 2 4 4 2 1 4 4 4 4 4 5
## [1497] 5 4 4 1 5 5 2 4 4 2 4 4 4 4 4 4 4 4 4 1 5 5 5 2 4 5 5 2 5 2 2 4 5 5
## [1531] 4 1 5 4 5 5 4 4 4 5 5 4 4 4 3 2 5 4 4 4 4 4 4 2 2 2 4 2 4 5 5 5 4 4
## [1565] 2 1 5 4 4 1 5 5 5 5 4 2 4 2 1 4 4 4 4 4 5 5 5 4 4 4 5 5 2 4 4 4 2 5
## [1599] 5 5 4 4 4 5 2 4 4 4 2 4 2 4 1 1 5 2 4 5 2 4 4 5 5 5 4 5 5 2 2 5 4 2
## [1633] 2 4 5 5 2 2 2 2 5 5 5 2 2 1 5 5 4 4 1 5 5 2 5 4 5 5 5 4 4 4 1 5 5 5
## [1667] 2 4 4 5 4 2 4 5 4 5 5 5 5 1 1 5 4 4 4 2 4 5 5 5 4 2 4 1 1 5 2 5 4 4
## [1701] 4 4 4 5 2 2 4 1 1 1 4 5 4 4 1 5 5 4 4 5 5 4 4 4 2 4 2 1 5 5 4 4 4 4
## [1735] 5 4 5 4 1 4 4 5 4 1 4 5 4 4 4 4 4 5 5 5 4 5 5 5 4 4 4 2 5 4 4 4 4 1
## [1769] 4 1 1 5 5 5 4 2 2 2 2 4 1 5 2 5 5 4 4 5 5 4 4 2 4 2 5 5 5 5 4 4 4 2
## [1803] 5 2 2 4 5 1 5 4 4 4 4 5 4 4 4 1 3 1 5 5 5 4 1 4 5 5 4 1 5 5 5 2 4 2
## [1837] 4 4 2 4 5 4 4 1 5 4 5 2 4 4 1 5 5 4 4 4 4 5 5 5 2 4 2 1 5 5 4 4 4 1
## [1871] 1 2 5 4 4 4 4 2 3 1 5 2 2 5 2 4 3 4 5 5 5 5 4 4 1 5 5 5 4 4 2 4 5 4
## [1905] 4 1 5 5 5 4 4 1 4 4 5 4 4 4 1 5 4 4 4 4 4 1 5 5 2 2 4 4 2 5 5 4 4 2
## [1939] 4 5 4 4 4 2 1 5 4 4 4 4 4 2 5 5 5 5 5 4 1 1 5 4 4 5 4 4 4 1 2 4 5 5
## [1973] 5 5 4 4 4 1 5 5 4 4 4 4 4 5 5 4 4 4 4 4 4 5 5 4 4 5 5 4 2 4 4 1 5 5
## [2007] 5 4 4 4 4 1 1 5 4 4 4 4 4 4 1 5 5 5 5 5 2 4 2 2 5 5 5 1 1 1 5 4 4 4
## [2041] 4 5 2 5 5 5 4 4 4 1 5 4 4 1 4 2 5 5 2 2 4 4 4 2 3 5 5 5 4 4 5 5 4 4
## [2075] 4 1 5 2 2 5 4 4 5 5 4 4 4 4 5 5 5 4 4 4 2 4 4 1 5 5 5 4 4 4 2 1 5 5
## [2109] 5 5 1 5 5 4 2 4 1 5 5 4 4 4 4 5 4 5 4 4 4 5 5 2 4 5 2 5 2 2 4 1 1 5
## [2143] 5 2 2 4 4 5 5 5 5 5 4 2 5 4 4 4 1 1 5 5 5 2 4 4 2 2 5 5 5 4 4 4 1 5
## [2177] 5 2 5 4 5 2 4 2 4 5 4 4 4 2 4 4 1 5 5 4 4 4 5 5 5 4 4 4 2 2 5 4 4 4
## [2211] 4 1 1 5 5 5 4 4 4 4 5 5 5 4 2 4 2 2 4 5 5 5 4 4 4 1 5 5 5 2 5 4 4 1
## [2245] 5 5 5 4 4 4 4 4 4 5 5 2 2 4 2 4 1 5 5 5 4 4 4 4 1 1 5 5 5 4 2 1 5 5
## [2279] 5 5 4 1 1 4 2 1 4 1 2 1 5 5 4 4 4 1 5 5 2 2 4 2 5 5 5 5 4 2 4 2 5 5
## [2313] 5 4 2 1 1 5 5 5 5 4 1 5 4 4 5 4 1 4 2 1 5 5 4 4 2 1 5 4 4 4 4 1 5 4
## [2347] 5 4 4 4 4 2 4 1 2 5 4 4 2 5 4 4 4 4 1 1 5 5 5 4 1 5 5 4 2 4 4 5 4 4
## [2381] 2 4 4 2 1
## 
## Within cluster sum of squares by cluster:
## [1]  871.8404 1720.4383  148.9773 1643.4785 1711.7095
##  (between_SS / total_SS =  57.4 %)
## 
## Available components:
## 
## [1] "cluster"      "centers"      "totss"        "withinss"    
## [5] "tot.withinss" "betweenss"    "size"         "iter"        
## [9] "ifault"
```

Looks like this time, cluster 1 is all below average and cluster 5 is all above. Which cluster is Cam Mack in?


```r
playeradvcluster <- data.frame(playersadvanced, advk5$cluster) 
```

Cluster 5 on my dataset. So three games in, we can say he's in a big group of players who are all above average on these advanced metrics. 

Now who are his Big Ten peers?


```r
playeradvcluster %>% filter(advk5.cluster == 5) %>% filter(Team %in% big10) %>% arrange(desc(PProd))
```

```
##              Player                     Team Pos  PER   TS. PProd  AST.
## 1       Marcus Carr Minnesota Golden Gophers   G 16.1 0.413    68  39.0
## 2      Andres Feliz Illinois Fighting Illini   G 19.3 0.568    63  22.1
## 3      Brad Davison        Wisconsin Badgers   G 24.2 0.668    58  14.3
## 4    Jahaad Proctor      Purdue Boilermakers   G 22.8 0.551    58  17.3
## 5     Aljami Durham         Indiana Hoosiers   G 25.6 0.804    56  13.0
## 6       Ayo Dosunmu Illinois Fighting Illini   G 11.1 0.507    54  23.4
## 7         Geo Baker  Rutgers Scarlet Knights   G 20.4 0.548    51  25.3
## 8      Cameron Mack     Nebraska Cornhuskers   G 21.2 0.499    51  37.2
## 9   Eric Hunter Jr.      Purdue Boilermakers   G 14.4 0.502    47  22.2
## 10   Zavier Simpson      Michigan Wolverines   G 16.7 0.518    46  38.6
## 11      D.J. Carton      Ohio State Buckeyes   G 22.9 0.657    44  34.2
## 12    Payton Willis Minnesota Golden Gophers   G 13.8 0.530    43  15.1
## 13    Anthony Cowan       Maryland Terrapins   G 20.2 0.542    42  29.3
## 14     Myreon Jones Penn State Nittany Lions   G 22.1 0.709    41  25.4
## 15      Myles Dread Penn State Nittany Lions   G 23.7 0.578    38  26.7
## 16       Eli Brooks      Michigan Wolverines   G 16.7 0.644    38  13.7
## 17     Rob Phinisee         Indiana Hoosiers   G 20.3 0.554    38  39.0
## 18    Trent Frazier Illinois Fighting Illini   G 10.9 0.539    37   9.8
## 19   Ron Harper Jr.  Rutgers Scarlet Knights   G 22.7 0.554    36   5.9
## 20        Kobe King        Wisconsin Badgers   G 17.1 0.532    35  10.3
## 21      Jacob Young  Rutgers Scarlet Knights   G 10.9 0.446    35  28.9
## 22        CJ Walker      Ohio State Buckeyes   G 16.3 0.560    35  33.9
## 23    Montez Mathis  Rutgers Scarlet Knights   G 20.4 0.490    34  11.6
## 24   D'Mitrik Trice        Wisconsin Badgers   G 10.8 0.501    32  14.5
## 25    Aaron Wiggins       Maryland Terrapins   G 21.6 0.460    32  14.6
## 26     Joe Wieskamp            Iowa Hawkeyes   G 15.3 0.514    31  12.2
## 27       Eric Ayala       Maryland Terrapins   G 12.4 0.528    30  16.7
## 28 Connor McCaffery            Iowa Hawkeyes   G 17.8 0.678    29  28.7
## 29  Caleb McConnell  Rutgers Scarlet Knights   G 18.8 0.515    28  13.0
## 30      Pat Spencer    Northwestern Wildcats   G 16.8 0.482    21  32.9
## 31       Tommy Luce      Purdue Boilermakers   G 30.7 0.500     4 100.0
##    WS.40  BPM advk5.cluster
## 1  0.119  8.4             5
## 2  0.175  7.4             5
## 3  0.255 11.9             5
## 4  0.241  4.6             5
## 5  0.276  8.0             5
## 6  0.096  2.9             5
## 7  0.204  6.0             5
## 8  0.166  6.8             5
## 9  0.159  1.2             5
## 10 0.142  4.5             5
## 11 0.272 11.4             5
## 12 0.157  7.4             5
## 13 0.247  8.5             5
## 14 0.281  3.4             5
## 15 0.315  8.4             5
## 16 0.162  5.2             5
## 17 0.215  0.8             5
## 18 0.145  6.3             5
## 19 0.229  4.9             5
## 20 0.170  7.0             5
## 21 0.083 -3.8             5
## 22 0.232  6.9             5
## 23 0.199  2.9             5
## 24 0.105  5.9             5
## 25 0.232 13.3             5
## 26 0.123  3.8             5
## 27 0.154  2.2             5
## 28 0.185  2.9             5
## 29 0.196  5.2             5
## 30 0.133  4.6             5
## 31 0.251 -3.7             5
```

Sorting on Points Produced, Cam Mack is eighth out of the 31 guards in the Big Ten who land in Cluster 5. 

It's early goings, but watch this player. He's fun to watch and the stats back it up. 
