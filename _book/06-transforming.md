# Transforming data

Sometimes long data needs to be wide, and sometimes wide data needs to be long. I'll explain.

You are soon going to discover that long before you can visualize data, you need to have it in a form that the visualization library can deal with. One of the ways that isn't immediately obvious is how your data is cast. Most of the data you will encounter will be wide -- each row will represent a single entity with multiple measures for that entity. So think of states. Your row of your dataset could have population, average life expectancy and other demographic data. 

But what if your visualization library needs one row for each measure? That's where recasting your data comes in. We can use a library called `tidyr` to `gather` or `spread` the data, depending on what we need.

We'll use a [dataset of college basketball games](https://unl.box.com/s/a8m91bro10t89watsyo13yjegb1fy009). First we need some libraries. 


```r
library(tidyverse)
```

```
## ── Attaching packages ───────────────
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
## ── Conflicts ────────────────────────
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

Now we'll grab the data. 


```r
logs <- read_csv('data/logs19.csv')
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

Last season, the Nebraska basketball team came out of the gates on fire. Their first 10 games were blistering. Their last 10? Not so much. But how can we compare a team's first 10 games with their last 10 games? If you look, each game in the dataset is numbered, so getting the first 10 wouldn't be hard. But what about the last five, when every team plays a different number of games? 

To find that, we need to add some data to our table. And that is the maxiumum number of games a team played. So we'll create a new dataframe where we'll group our teams by team name and get the max game number for each team. Then, we'll use something called a join, where we'll connect the max games to the logs data using the common team name to connect them. 



```r
max <- logs %>% group_by(Team) %>% summarise(max_games = max(Game))
```


```r
logs <- logs %>% left_join(max)
```

```
## Joining, by = "Team"
```

Now let's just get Nebraska. 


```r
nebraska <- logs %>% filter(Team == "Nebraska Cornhuskers")

head(nebraska)
```

```
## # A tibble: 6 x 45
##      X1  Game Date       HomeAway Opponent W_L   TeamScore OpponentScore
##   <dbl> <dbl> <date>     <chr>    <chr>    <chr>     <dbl>         <dbl>
## 1  6449     1 2018-11-06 <NA>     Mississ… W           106            37
## 2  6450     2 2018-11-11 <NA>     Southea… W            87            35
## 3  6451     3 2018-11-14 <NA>     Seton H… W            80            57
## 4  6452     4 2018-11-19 N        Missour… W            85            62
## 5  6453     5 2018-11-20 N        Texas T… L            52            70
## 6  6454     6 2018-11-24 <NA>     Western… W            73            49
## # … with 37 more variables: TeamFG <dbl>, TeamFGA <dbl>, TeamFGPCT <dbl>,
## #   Team3P <dbl>, Team3PA <dbl>, Team3PPCT <dbl>, TeamFT <dbl>,
## #   TeamFTA <dbl>, TeamFTPCT <dbl>, TeamOffRebounds <dbl>,
## #   TeamTotalRebounds <dbl>, TeamAssists <dbl>, TeamSteals <dbl>,
## #   TeamBlocks <dbl>, TeamTurnovers <dbl>, TeamPersonalFouls <dbl>,
## #   Blank <lgl>, OpponentFG <dbl>, OpponentFGA <dbl>, OpponentFGPCT <dbl>,
## #   Opponent3P <dbl>, Opponent3PA <dbl>, Opponent3PPCT <dbl>,
## #   OpponentFT <dbl>, OpponentFTA <dbl>, OpponentFTPCT <dbl>,
## #   OpponentOffRebounds <dbl>, OpponentTotalRebounds <dbl>,
## #   OpponentAssists <dbl>, OpponentSteals <dbl>, OpponentBlocks <dbl>,
## #   OpponentTurnovers <dbl>, OpponentPersonalFouls <dbl>, Team <chr>,
## #   Conference <chr>, season <chr>, max_games <dbl>
```

What we have here is long data. One row, one game. But what if we wanted to calculate the percent change in two variables? Say we wanted to see what the difference in shooting percentage has been between the first 10 games and the last ten Or the percent change in that? To get that, we'd need two fields next to each other so we could mutate our dataframe to calculate that, right? You'll see the problem we have right away. 


```r
nebraska %>% 
  mutate(grouping = case_when(
    Game <=10 ~ "First 10",
    Game >= (max_games - 10) ~ "Last 10")
    ) %>%
  group_by(Team, grouping) %>%
  summarise(
    shootingPCT = mean(TeamFGPCT)
  )
```

```
## # A tibble: 3 x 3
## # Groups:   Team [1]
##   Team                 grouping shootingPCT
##   <chr>                <chr>          <dbl>
## 1 Nebraska Cornhuskers First 10       0.479
## 2 Nebraska Cornhuskers Last 10        0.422
## 3 Nebraska Cornhuskers <NA>           0.404
```
How do you write a mutate step to calulate the percent change when they're stacked on top of each other like that? Answer: You don't. You have to move the data around. 

To take long data and make it wide, we need to `spread` the data. That's the new verb. To spread the data, we tell spread what the new columns will be and what the data values that will go with them. Spread does the rest. 

So I'm going to take that same code and add spread to the bottom. I want the new columns to be my `grouping` and the data to be the `shootingPCT`.


```r
nebraska %>% 
  mutate(grouping = case_when(
    Game <=10 ~ "First 10",
    Game >= (max_games - 10) ~ "Last 10")
    ) %>%
  group_by(Team, grouping) %>%
  summarise(
    shootingPCT = mean(TeamFGPCT)
  ) %>% 
  spread(grouping, shootingPCT) 
```

```
## # A tibble: 1 x 4
## # Groups:   Team [1]
##   Team                 `First 10` `Last 10` `<NA>`
##   <chr>                     <dbl>     <dbl>  <dbl>
## 1 Nebraska Cornhuskers      0.479     0.422  0.404
```

And now, with it spread out, I can chain another mutate step onto it, adding my difference and my percent change. 


```r
nebraska %>% 
  mutate(grouping = case_when(
    Game <=10 ~ "First 10",
    Game >= (max_games - 10) ~ "Last 10")
    ) %>%
  group_by(Team, grouping) %>%
  summarise(
    shootingPCT = mean(TeamFGPCT)
  ) %>% 
  spread(grouping, shootingPCT) %>%
  mutate(
    change = ((`Last 10`-`First 10`)/`First 10`)*100,
    difference = (`First 10` - `Last 10`)*100
    )
```

```
## # A tibble: 1 x 6
## # Groups:   Team [1]
##   Team                 `First 10` `Last 10` `<NA>` change difference
##   <chr>                     <dbl>     <dbl>  <dbl>  <dbl>      <dbl>
## 1 Nebraska Cornhuskers      0.479     0.422  0.404  -12.0       5.73
```
So, over Nebraska's first 10 games, they shot almost 48 percent, where over the last ten horrid games they're shooting 42 percent. That's an 5.7 percentage point different or a nearly 12 percent drop from those first 10 games. 

We can't shoot the ball anymore.

How bad is that nationally? Just run the same code, but instead of Nebraska, use the logs dataframe.


```r
logs %>% 
  mutate(grouping = case_when(
    Game <=10 ~ "First 10",
    Game >= (max_games - 10) ~ "Last 10")
    ) %>%
  group_by(Team, grouping) %>%
  summarise(
    shootingPCT = mean(TeamFGPCT)
  ) %>% 
  spread(grouping, shootingPCT) %>%
  mutate(
    change = ((`Last 10`-`First 10`)/`First 10`)*100,
    difference = (`First 10` - `Last 10`)*100
    ) %>% arrange(change)
```

```
## # A tibble: 353 x 6
## # Groups:   Team [353]
##    Team                    `First 10` `Last 10` `<NA>` change difference
##    <chr>                        <dbl>     <dbl>  <dbl>  <dbl>      <dbl>
##  1 North Texas Mean Green       0.484     0.391  0.439  -19.2       9.29
##  2 Miami (OH) RedHawks          0.465     0.379  0.424  -18.6       8.66
##  3 NC State Wolfpack            0.515     0.423  0.437  -18.0       9.29
##  4 Ohio State Buckeyes          0.477     0.392  0.441  -17.9       8.57
##  5 Vanderbilt Commodores        0.459     0.379  0.423  -17.5       8.02
##  6 Pacific Tigers               0.467     0.385  0.417  -17.4       8.13
##  7 Indiana Hoosiers             0.515     0.427  0.447  -17.2       8.89
##  8 UNC Greensboro Spartans      0.510     0.422  0.442  -17.2       8.78
##  9 Cincinnati Bearcats          0.474     0.394  0.432  -16.8       7.94
## 10 Seattle Redhawks             0.481     0.401  0.431  -16.6       8.00
## # … with 343 more rows
```

In all of college basketball, Nebraska had the 40th biggest drop in shooting percentage from their first 10 games to their last 10 games. 

And that's a tiny portion of why Tim Miles is no longer the coach.

## Making wide data long

We can reverse this process as well. If we get data that's wide and we want to make it long, we use `gather`. So first, since my data is already long, let me fake a wide dataset using what I just did. 


```r
gatherdata <- nebraska %>% 
  mutate(grouping = case_when(
    Game <=10 ~ "First 10",
    Game >= (max_games - 5) ~ "Last 5")
    ) %>%
  group_by(Team, grouping) %>%
  summarise(
    shootingPCT = mean(TeamFGPCT)
  ) %>% 
  spread(grouping, shootingPCT)
```


```r
head(gatherdata)
```

```
## # A tibble: 1 x 4
## # Groups:   Team [1]
##   Team                 `First 10` `Last 5` `<NA>`
##   <chr>                     <dbl>    <dbl>  <dbl>
## 1 Nebraska Cornhuskers      0.479    0.444  0.402
```

Oh drat, I have wide data and for a visualization project, I need long data. Whatever will I do? This might seem silly, but two assignments from now, you're going to need long data from wide and wide data from long, so it's good to know. 

Gather, unfortunately, isn't as easy as spread. It can take some fiddling to get right. There's a ton of examples online if you Google for them, but here's what you do: You tell `gather` what the new column of data you are creating out of the field names first -- this is called the key -- and you then tell it what the value field is going to be called, which is usually a number. Have more than one thing to name your stuff with? After your key value pair, add it with a negative sign in front of it. 


```r
gatherdata %>% gather(grouping, shootingPCT, -Team)
```

```
## # A tibble: 3 x 3
## # Groups:   Team [1]
##   Team                 grouping shootingPCT
##   <chr>                <chr>          <dbl>
## 1 Nebraska Cornhuskers First 10       0.479
## 2 Nebraska Cornhuskers Last 5         0.444
## 3 Nebraska Cornhuskers <NA>           0.402
```

And just like that, we're back where we started. 

## Why this matters

This matters because certain visualization types need wide or long data. A significant hurdle you will face for the rest of the semester is getting the data in the right format for what you want to do. 

So let me walk you through an example using this data. If I asked you to describe Nebraska's shooting performance over the season, we can do that by what we just did -- grouping them into the first 10 games when people actually talked about this team in the Sweet 16 and the last five when we aren't going to get an NIT bid. We can look at that shooting percentage, how it has changed, and that work makes for a perfect paragraph to write out. So to do that, you need wide data. 

But to visualize it, you need long. 

First, let's load our charting library, `ggplot2` which you're going to learn a lot more about soon.


```r
library(ggplot2)
```

Now I'm going to use that data and put the date of the game on the x axis, the shooting percentage on the y axis and then, for giggles, I'm going to add a best fit line that describes our season using a simple regression and the equation of a line. 


```r
ggplot(nebraska, aes(x=Date, y=TeamFGPCT)) + 
  geom_smooth(method='lm', se=FALSE, color="grey") + 
  geom_line() + 
  annotate("text", x=(as.Date("2018-12-08")), y=0.545, label="vs Creighton") + 
  annotate("text", x=(as.Date("2019-01-10")), y=0.502, label="vs Penn State") + 
  geom_point(aes(color = W_L)) + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x="Date", y="FG percentage", title="Nebraska's season, visualized", subtitle="As the season goes by, the Huskers are getting worse at shooting the ball.", caption="Source: NCAA | By Matt Waite", color = "Outcome") +
  theme_minimal() + 
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 10),
    axis.title.y = element_blank(),
    axis.text = element_text(size = 7),
    axis.ticks = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position="bottom"
  )
```

![](06-transforming_files/figure-epub3/unnamed-chunk-14-1.png)<!-- -->
Oy. There it is. There's our season.

So I can tell you now, using wide data, that Nebraska's shooting performance over the last ten games is down 12 percent from the first 10 games. And using long data, I can show you the story of the season, but without any specific stats to back it up. 

