# Annotations

Some of the best sports data visualizations start with a provocative question. At a college just under three hours from Kansas City, my classes are lousy with Chiefs fans. So the first day of classes in the spring of 2019, I asked them: Are the Chief's Screwed in the Playoffs? The answer ultimately was yes, and how I was able to make that argument before a playoff game had even been played is a good example of how labeling and annotations can make a chart much better. 

Going to add a new library to the mix called `ggrepel`. You'll need to install it in the console with `install.packages("ggrepel")`. 


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
library(ggrepel)
```

```
## Warning: package 'ggrepel' was built under R version 3.5.2
```

Now we'll grab the data and join that data together using the Team name as the common element.


```r
offense <- read_csv("data/nfloffense.csv")
```

```
## Parsed with column specification:
## cols(
##   .default = col_double(),
##   Team = col_character()
## )
```

```
## See spec(...) for full column specifications.
```

```r
defense <- read_csv("data/nfldefense.csv")
```

```
## Parsed with column specification:
## cols(
##   .default = col_double(),
##   Team = col_character()
## )
## See spec(...) for full column specifications.
```

```r
total <- offense %>% left_join(defense, by="Team")

head(total)
```

```
## # A tibble: 6 x 52
##   Team      G PointsFor OffYards OffPlays OffYardsPerPlay OffensiveTurnov…
##   <chr> <dbl>     <dbl>    <dbl>    <dbl>           <dbl>            <dbl>
## 1 Kans…    16       565     6810      996             6.8               18
## 2 Los …    16       527     6738     1060             6.4               19
## 3 New …    16       504     6067     1010             6                 16
## 4 New …    16       436     6295     1073             5.9               18
## 5 Indi…    16       433     6179     1070             5.8               24
## 6 Pitt…    16       428     6453     1058             6.1               26
## # … with 45 more variables: FumblesLost <dbl>, OffFirstDowns <dbl>,
## #   OffPassingComp <dbl>, OffPassingAtt <dbl>, OffPassingYards <dbl>,
## #   OffensivePassingTD <dbl>, OffPassingINT <dbl>,
## #   OffensivePassingYardsPerAtt <dbl>, OffensivePassingFirstDowns <dbl>,
## #   OffRushingAtt <dbl>, OffRushingYards <dbl>, OffRushingTD <dbl>,
## #   RushingYardsPerAtt <dbl>, RushingFirstDowns <dbl>,
## #   OffensivePenalties <dbl>, OffPenaltyYards <dbl>,
## #   OffFirstFromPenalties <dbl>, OffScoringPct <dbl>,
## #   OffensiveTurnoverPct <dbl>, OffensiveExpectedPoints <dbl>,
## #   PointsAllowed <dbl>, YdsAllowed <dbl>, PlaysFaced <dbl>,
## #   DefYardPerPlay <dbl>, Takeaways <dbl>, DefFumblesLost <dbl>,
## #   FirstDownsAllowed <dbl>, PassingCompsAllowed <dbl>,
## #   PassingAttFaced <dbl>, PassingYdsAllowed <dbl>,
## #   PassingTDAllowed <dbl>, DefPassingINT <dbl>,
## #   PassingYardsPerPlayAllowed <dbl>, PassingFirstDownsAllowed <dbl>,
## #   RushingAttFaced <dbl>, RushingYdsAllowed <dbl>,
## #   RushingTDAllowed <dbl>, RushingYardsPerAttAllowed <dbl>,
## #   RushingFirstDownsAllowed <dbl>, DefPenalties <dbl>,
## #   DefPenaltyYards <dbl>, DefFirstDownByPenalties <dbl>,
## #   OffensiveScoringPctAllowed <dbl>, DefTurnoverPercentage <dbl>,
## #   DefExpectedPoints <dbl>
```

I'm going to set up a point chart that places team on two-axes -- yards per play on offense on the x axis, and yards per play on defense. 

To build the annotations, I want the league average for offensive yards per play and defensive yards per play. We're going to use those as a proxy for quality. If your team averages more yards per play on offense, that's good. If they average fewer yards per play on defense, that too is good. So that sets up a situation where we have four corners, anchored by good at both and bad at both. The averages will create lines to divide those four corners up. 


```r
league_averages <- total %>% summarise(AvgOffYardsPer = mean(OffYardsPerPlay), AvgDefYardsPer = mean(DefYardPerPlay))

league_averages
```

```
## # A tibble: 1 x 2
##   AvgOffYardsPer AvgDefYardsPer
##            <dbl>          <dbl>
## 1           5.59           5.59
```

I also want to highlight playoff teams and, of course, the Chiefs, since that was my question. Are they screwed. First, we filter them from our total list.


```r
playoff_teams <- c("Kansas City Chiefs", "New England Patriots", "Los Angeles Chargers", "Indianapolis Colts", "New Orleans Saints", "Los Angeles Rams", "Chicago Bears", "Dallas Cowboys", "Philadelphia Eagles")

playoffs <- total %>% filter(Team %in% playoff_teams)

chiefs <- total %>% filter(Team == "Kansas City Chiefs")
```

Now we create the plot. We have three geom_points, starting with everyone, then playoff teams, then the Chiefs. I alter the colors on each to separate them. Next, I add a geom_hline to add the horizontal line of my defensive average and a geom_vline for my offensive average. Next, I want to add some text annotations, labeling two corners of my chart (the other two, in my opinion, become obvious). Then, I want to label all the playoff teams. I use `geom_text_repel` to do that -- it's using the ggrepel library to push the text away from the dots, respective of other labels and other dots. It means you don't have to move them around so you can read them, or so they don't cover up the dots. 

The rest is just adding labels and messing with the theme. 


```r
ggplot() + 
  geom_point(data=total, aes(x=OffYardsPerPlay, y=DefYardPerPlay), color="light grey") +
  geom_point(data=playoffs, aes(x=OffYardsPerPlay, y=DefYardPerPlay)) +
  geom_point(data=chiefs, aes(x=OffYardsPerPlay, y=DefYardPerPlay), color="red") +
  geom_hline(yintercept=5.59375, color="dark grey") + 
  geom_vline(xintercept=5.590625, color="dark grey") + 
  geom_text(aes(x=6.2, y=5, label="Good Offense, Good Defense"), color="light blue") +
  geom_text(aes(x=5, y=6, label="Bad Defense, Bad Offense"), color="light blue") +
  geom_text_repel(data=playoffs, aes(x=OffYardsPerPlay, y=DefYardPerPlay, label=Team)) +
  labs(x="Offensive Yards Per Play", y="Defensive Points Per Play", title="Are the Chiefs screwed in the playoffs?", subtitle="Their offense is great. Their defense? Not so much", caption="Source: Sports-Reference.com | By Matt Waite") +
  theme_minimal() + 
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 10),
    axis.text = element_text(size = 7),
    axis.ticks = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank()
  )
```

![](25-annotations_files/figure-epub3/unnamed-chunk-5-1.png)<!-- -->
