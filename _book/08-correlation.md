# Correlations and regression

Throughout sports, you will find no shortage of opinions. From people yelling at their TV screens to an entire industry of people paid to have opinions, there are no shortage of reasons why this team sucks and that player is great. They may have their reasons, but a better question is, does that reason really matter? 

Can we put some numbers behind that? Can we prove it or not? 

This is what we're going to start to answer. And we'll do it with correlations and regressions.

First, we need libraries and [data](https://unl.box.com/s/zlxoptqixkt98gubk3i6316qun99l49r).


```r
library(tidyverse)
```

```
## ── Attaching packages ── tidyverse 1.2.1 ──
```

```
## ✔ ggplot2 3.2.0     ✔ purrr   0.3.2
## ✔ tibble  2.1.3     ✔ dplyr   0.8.3
## ✔ tidyr   0.8.3     ✔ stringr 1.4.0
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
correlations <- read_csv("data/correlations.csv")
```

```
## Parsed with column specification:
## cols(
##   Name = col_character(),
##   OffPoints = col_double(),
##   OffPointsG = col_double(),
##   DefPoints = col_double(),
##   DefPointsG = col_double(),
##   Pen. = col_double(),
##   Yards = col_double(),
##   `Pen./G` = col_double(),
##   OffConversions = col_double(),
##   OffConversionPct = col_double(),
##   DefConversions = col_double(),
##   DefConversionPct = col_double()
## )
```

To do this, we need all FBS college football teams and their season stats from last year. How much, over the course of a season, does a thing matter? That's the question you're going to answer. 

In our case, we want to know how much does a team's accumulated penalties influence the number of points they score in a season? How much difference can we explain in points with penalties? 

We're going to use two different methods here and they're closely related. Correlations -- specifically the Pearson Correlation Coefficient -- is a measure of how related two numbers are in a linear fashion. In other words -- if our X value goes up one, what happens to Y? If it also goes up 1, that's a perfect correlation. X goes up 1, Y goes up 1. Every time. Correlation coefficients are a number between 0 and 1, with zero being no correlation and 1 being perfect correlation **if our data is linear**. We'll soon go over scatterplots to visually determine if our data is linear, but for now, we have a hypothesis: More penalties are bad. Penalties hurt. So if a team gets lots of them, they should have worse outcomes than teams that get few of them. That is an argument for a linear relationship between them. 

But is there one?

We're going create a new dataframe called newcorrelations that takes our data that we imported and adds a column called `differential` because we don't have separate offense and defense penalties, and then we'll use correlations to see how related those two things are.


```r
newcorrelations <- correlations %>% 
  mutate(differential = OffPoints - DefPoints)
```

In R, there is a `cor` function, and beacuse it's base R, we have to use a different method of referencing fields that we've not used to this point. It involves the name of the data frame plus a `$` then the name of the field. So we want to see if `differential` is correlated with `Yards`, which is the yards of penalties a team gets in a game. We do that by referenceing `newcorrelation$differential` and `newcorrelation$Yards`. The number we get back is the correlation coefficient.


```r
cor(newcorrelations$differential, newcorrelations$Yards, method="pearson")
```

```
## [1] 0.2008676
```

So on a scale of 0 to 1, penalty yards and wether or not the team scores more points than it give up are at .2. You could say they're 20 percent related. Another way to say it? They're 80 percent not related.

What about the number of penalties instead of the yards?


```r
cor(newcorrelations$differential, newcorrelations$`Pen.`, method="pearson")
```

```
## [1] 0.1534557
```

Even less related. What about looking at the average? Penalty yards per game?


```r
cor(newcorrelations$differential, newcorrelations$`Pen./G`, method="pearson")
```

```
## [1] -0.03305037
```

Not only is it less related, but the relationship is inverted. 

So wait, what does that mean? 

It means that the number of penalty yards and penalties is actually positively related to differential. Put another way, teams that have more penalties and penalty yards tend to have better outcomes. The average is barely -- 3 percent -- negatively correlated, meaning that teams with higher averages score fewer points.

What? That makes no sense. How can that be? 

Enter regression. Regression is how we try to fit our data into a line that explains the relationship the best. Regressions will help us predict things as well -- if we have a team that has so many penalties, what kind of point differential could we expect, given every FBS team? So regressions are about prediction, correlations are about description. Correlations describe a relationship. Regressions help us predict what that relationship means. 

Another thing regressions do is give us some other tools to evaluate if the relationship is real or not.

Here's an example of using linear modeling to look at yards. Think of the `~` character as saying "is predicted by". The output looks like a lot, but what we need is a small part of it.


```r
fit <- lm(differential ~ Yards, data = newcorrelations)
summary(fit)
```

```
## 
## Call:
## lm(formula = differential ~ Yards, data = newcorrelations)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -351.02  -93.49    2.67  107.88  444.42 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)  
## (Intercept) -108.73848   59.70868  -1.821   0.0709 .
## Yards          0.19484    0.08399   2.320   0.0219 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 140 on 128 degrees of freedom
## Multiple R-squared:  0.04035,	Adjusted R-squared:  0.03285 
## F-statistic: 5.382 on 1 and 128 DF,  p-value: 0.02193
```

There's three things we need here: 

1. First we want to look at the p-value. It's at the bottom right corner of the output. In the case of Yards, the p-value is .02193. The threshold we're looking for here is .05. If it's less than .05, then the relationship is considered to be *statistically significant*. Significance here does not mean it's a big deal. It means it's not random. That's it. Just that. Not random. So in our case, the relationship between penalty yards and a team's aggregate point differential are not random. It's a real relationship.
2. Second, we look at the Adjusted R-squared value. It's right above the p-value. Adjusted R-squared is a measure of how much of the difference between teams aggregate point values can be explained by penalty yards. Our correlation coefficient said they're 20 percent related to each other, but penalty yard's ability to explain the difference between teams? About 3.3 percent. That's ... not much. It's really nothing.
3. The third thing we can look at, and we only bother if the first two are meaningful, is the coefficients. In the middle, you can see the (Intercept) is -108.73848 and the Yards coefficient is .19484. Remember high school algebra? Remember learning the equation of a line? Remember swearing that learning `y=mx+b` is stupid because you'll never need it again? Surprise. It's useful again. In this case, we could try to predict a team's aggregate score in a season -- will they score more than they give up -- by using `y=mx+b`. In this case, y is the aggregate score, m is .19484 and b is -108.73848. So we would multiply a teams total penalty yards by .19484 and then subtract 108.73848 from it. The result would tell you what the total aggregate score in the season would be. Chance that your even close with this? About 3 percent. 

You can see the problem in a graph. On the X axis is penalty yards, on the y is aggregate score. If these elements had a strong relationship, we'd see a clear pattern moving from right to left, sloping down. Onn the left would be the teams with lots of penalty yards and a negative point differential. On right would be teams with low penalty yards and high point differentials. Do you see that below?

<img src="08-correlation_files/figure-html/unnamed-chunk-8-1.png" width="672" />

> **Your turn**: Try it with the other penalty measures. Total penalties and penalty yards per game. Does anything change? Do either of these meet the .05 threshold for randomness? Are either of these any more predictive?

## A more predictive example

So we've firmly established that penalties aren't predictive. But what is? One measure I've found to  be highly predictive of a team's success is how well do they do on third down. It's simple really: Succeed on third down, you get to stay on offense. Fail on third down, you are punting (most likely) or settling for a field goal. Either way, you're scoring less than you would by scoring touchdowns. How related are points per game and third down conversion percentage?


```r
cor(newcorrelations$OffPointsG, newcorrelations$OffConversionPct, method="pearson")
```

```
## [1] 0.6658862
```

Answer: 67 percent. More than three times more related than penalty yards. But how meaningful is that relationship and how predictive is it?


```r
third <- lm(OffPointsG ~ OffConversionPct, data = newcorrelations)
summary(third)
```

```
## 
## Call:
## lm(formula = OffPointsG ~ OffConversionPct, data = newcorrelations)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -11.3861  -3.5411  -0.5885   2.9011  13.5188 
## 
## Coefficients:
##                  Estimate Std. Error t value Pr(>|t|)    
## (Intercept)      -4.74024    3.41041   -1.39    0.167    
## OffConversionPct  0.85625    0.08479   10.10   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 5.111 on 128 degrees of freedom
## Multiple R-squared:  0.4434,	Adjusted R-squared:  0.4391 
## F-statistic:   102 on 1 and 128 DF,  p-value: < 2.2e-16
```

First we check p-value. See that e-16? That means scientific notation. That means our number is 2.2 times 10 to the -16 power. So -.000000000000000022. That's sixteen zeros between the decimal and 22. Is that less than .05? Uh, yeah. So this is really, really, really not random. But anyone who has watched a game of football knows this is true. It makes intuitive sense. 

Second, Adjusted R-squared: .4391. So we can predict 44 percent of the difference in the total offensive points per game a team scores by simply looking at their third down conversion percentage. 
Third, the coefficients: In this case, our `y=mx+b` formula looks like `y = .85625x-4.74024`. So if we were applying this, let's look at Nebraska's 31-28 loss to Iowa on Black Friday in 2018. Nebraska was 6-15 on third down in that game, or 40 percent (Iowa was 7 of 13 or 54 percent). Given those numbers, our formula predicts Nebraska should have scored how many points? 


```r
(0.85625 * 40) - 4.74024 
```

```
## [1] 29.50976
```
That's really close to the 28 they did score. And Iowa?

```r
(0.85625 * 54) - 4.74024 
```

```
## [1] 41.49726
```
By our model, Iowa should have scored 10 more points than they did. But they didn't. Why, besides Iowa is terrible and deserves punishment from the football gods for being Iowa? Remember our model can only explain 44 percent of the points. There's more to football than one metric. 
