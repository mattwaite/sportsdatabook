# Scatterplots

In several chapters of this book, we've been fixated on the Nebraska basketball team's shooting percentage, which took a nose dive during the season and ultimately doomed Tim Miles job. The question is ... does it matter?

This is what we're going to start to answer today. And we'll do it with scatterplots and correlations.

First, we need libraries and [data](https://unl.box.com/s/a8m91bro10t89watsyo13yjegb1fy009).


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

To do this, we need all teams and their season stats. How much, over the course of a season, does a thing matter? That's the question you're going to answer. 

In our case, we want to know how much does shooting percentage influence wins? How much different can we explain in wins with shooting percentage? We're going to total up the number of wins each team has and their season shooting percentage in one swoop.

Let's borrow from our ridgecharts work to get the correct wins and losses totals for each team. 


```r
winlosslogs <- logs %>% mutate(winloss = case_when(
  grepl("W", W_L) ~ 1, 
  grepl("L", W_L) ~ 0)
)
```

Now we can get a dataframe together that gives us the total wins for each team, and the total shots taken and made, which let's us calculate a season shooting percentage. 


```r
winlosslogs %>% 
  group_by(Team) %>%
  summarise(
    wins = sum(winloss),
    totalFGAttempts = sum(TeamFGA),
    totalFG = sum(TeamFG)
  ) %>%
  mutate(fgpct = totalFG/totalFGAttempts) -> fgmodel
```

Now let's look at the scatterplot. With a scatterplot, we put what predicts the thing on the X axis, and the thing being predicted on the Y axis. In this case, X is our shooting percentage, y is our wins.


```r
ggplot(fgmodel, aes(x=fgpct, y=wins)) + geom_point()
```

![](19-scatterplots_files/figure-epub3/unnamed-chunk-5-1.png)<!-- -->

Let's talk about this. It seems that the data slopes up to the right. That would indicate a positive correlation between shooting percentage and wins. And that makes sense, no? You'd expect teams that shoot the ball well to win. But can we get a better sense of this? Yes, by adding another geom -- `geom_smooth`.


```r
ggplot(fgmodel, aes(x=fgpct, y=wins)) + geom_point() + geom_smooth(method=lm, se=TRUE)
```

![](19-scatterplots_files/figure-epub3/unnamed-chunk-6-1.png)<!-- -->

But ... how strong a relationship is this? How much can shooting percentage explain wins? Can we put some numbers to this?

Of course we can. We can apply a linear model to this -- remember Chapter 8? We're going to create an object called fit, and then we're going to put into that object a linear model -- `lm` -- and the way to read this is "wins are predicted by field goal percentage". Then we just want the summary of that model.


```r
fit <- lm(wins ~ fgpct, data = fgmodel)
summary(fit)
```

```
## 
## Call:
## lm(formula = wins ~ fgpct, data = fgmodel)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -14.3536  -3.4523  -0.1125   3.3834  15.4318 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  -49.217      4.845  -10.16   <2e-16 ***
## fgpct        149.416     10.915   13.69   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 5.035 on 351 degrees of freedom
## Multiple R-squared:  0.348,	Adjusted R-squared:  0.3462 
## F-statistic: 187.4 on 1 and 351 DF,  p-value: < 2.2e-16
```

Remember from Chapter 8: There's just a few things you really need.

The first thing: R-squared. In this case, the Adjusted R-squared value is .3462, which we can interpret as shooting percentage predicts about 35 percent of the variance in wins. Which sounds not great, but in social science, that's huge. That's great. A psychology major would murder for that R-squared.

Second: The P-value. We want anything less than .05. If it's above .05, the change between them is not statistically significant -- it's probably explained by random chance. In our case, we have 2.2e-16, which is to say 2.2 with 16 zeros in front of it, or .000000000000000022. Is that less than .05? Yes. Yes it is. So this is not random. Again, we would expect this, so it's a good logic test.

Third: The coefficient. In this case, the coefficient for fgpct is 149.416. Since I didn't convert percentages to decimals, what this says is that for every perentage point improvement in shooting percentage, we can expect the team to win 1.49 more games plus or minus some error. 

And we can use this to predict a team's wins: remember your algebra and y = mx + b. In this case, y is the wins, m is the coefficient, x is the shooting percentage and b is the intercept. 

So can plug these together: Expected wins = 149.416 * shooting percentage - 49.217

Let's use Nebraska as an example. They shot about .43 on the season (.4294421 to be exact). 

y = 149.416 * .4294421 - 49.217 or 14.95 wins. How many wins did Nebraska have? 19. 

What does that mean? It means that as disappointing a season as it was, Nebraska actually OVERPERFORMED it's season shooting percentage. They shouldn't have won as many games as they did. 
