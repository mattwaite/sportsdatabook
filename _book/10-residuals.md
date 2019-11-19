# Residuals

When looking at a linear model of your data, there's a measure you need to be aware of called residuals. The residual is the distance between what the model predicted and what the real outcome is. So if your model predicted a team would score 38 points per game given their third down conversion percentage, and they score 45, then your residual is 7. If they had scored 31, then their residual would be -7. 

Residuals can tell you severals things, but most importantly is if a linear model the right model for your data. If the residuals appear to be random, then a linear model is appropriate. If they have a pattern, it means something else is going on in your data and a linear model isn't appropriate. 

Residuals can also tell you who is underperforming and overperforming the model. Let's take a look at an example we've used regularly this semester -- third down conversion percentage and penalties. 

Let's first attach libraries and use rvest to get some data. Note: In the rvest steps, I rename the first column because it's blank on the page and then I merge scoring offense to two different tables -- third downs and penalties. 


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
offense <- read_csv("data/correlations.csv")
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

First, let's build a linear model and save it as a new dataframe called `fit`. 


```r
fit <- lm(`OffPointsG` ~ `OffConversionPct`, data = offense)
summary(fit)
```

```
## 
## Call:
## lm(formula = OffPointsG ~ OffConversionPct, data = offense)
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

We've seen this output before, but let's review because if you are using scatterplots to make a point, you should do this. First, note the Min and Max residual at the top. A team has underperformed the model by 11.4 points, and a team has overperformed it by 13.5. The median residual, where half are above and half are below, is just slightly under the fit line. Close here is good. 

Next: Look at the Adjusted R-squared value. What that says is that 44 percent of a team's scoring output can be predicted by their third down conversion percentage. This is just one year, so that's a little low. If we did this with more years, that would go up. 

Last: Look at the p-value. We are looking for a p-value smaller than .05. At .05, we can say that our correlation didn't happen at random. And, in this case, it REALLY didn't happen at random. 

What we want to do now is look at those residuals. We can add them to our dataframe like this:


```r
offense$predicted <- predict(fit)
offense$residuals <- residuals(fit)
```

Now we can sort our data by those residuals. Sorting in descending order gives us the teams that are overperforming the model.


```r
offense %>% arrange(desc(residuals))
```

```
## # A tibble: 130 x 14
##    Name  OffPoints OffPointsG DefPoints DefPointsG  Pen. Yards `Pen./G`
##    <chr>     <dbl>      <dbl>     <dbl>      <dbl> <dbl> <dbl>    <dbl>
##  1 Tole…       525       40.4       397       30.5    99   931      7.6
##  2 Utah…       618       47.5       289       22.2   101   916      7.8
##  3 Syra…       523       40.2       351       27      94   768      7.2
##  4 Okla…       677       48.4       466       33.3    86   855      6.1
##  5 Clem…       664       44.3       197       13.1    73   674      4.9
##  6 Hous…       571       43.9       483       37.2    87   683      6.7
##  7 Miss…       407       33.9       434       36.2    88   802      7.3
##  8 Neva…       404       31.1       350       26.9    77   738      5.9
##  9 Bost…       384       32         308       25.7    75   590      6.3
## 10 West…       483       40.3       326       27.2    85   800      7.1
## # … with 120 more rows, and 6 more variables: OffConversions <dbl>,
## #   OffConversionPct <dbl>, DefConversions <dbl>, DefConversionPct <dbl>,
## #   predicted <dbl>, residuals <dbl>
```
So looking at this table, what you see here are the teams who scored more than their third down conversion percentage would indicate. Some of those teams were just lucky. Some of those teams were really good at long touchdown plays that didn't need a lot of third downs to get down the field. But these are your overperformers. 

But, before we can bestow any validity on it, we need to see if this linear model is appropriate. We've done that some looking at our p-values and R-squared values. But one more check is to look at the residuals themselves. We do that by plotting the residuals with the predictor. We'll get into plotting soon, but for now just seeing it is enough.

![](10-residuals_files/figure-epub3/unnamed-chunk-6-1.png)<!-- -->

The lack of a shape here -- the seemingly random nature -- is a good sign that a linear model works for our data. If there was a pattern, that would indicate something else was going on in our data and we needed a different model.

Another way to view your residuals is by connecting the predicted value with the actual value.

![](10-residuals_files/figure-epub3/unnamed-chunk-7-1.png)<!-- -->

The blue line here separates underperformers from overperformers.

## Penalties

Now let's look at it where it doesn't work: Penalties. 


```r
penalties <- offense
```



```r
pfit <- lm(OffPointsG ~ Yards, data = penalties)
summary(pfit)
```

```
## 
## Call:
## lm(formula = OffPointsG ~ Yards, data = penalties)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -16.5381  -4.5779  -0.5204   4.2418  17.0543 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 20.897213   2.819227   7.412 1.49e-11 ***
## Yards        0.012220   0.003966   3.082  0.00252 ** 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 6.61 on 128 degrees of freedom
## Multiple R-squared:  0.06907,	Adjusted R-squared:  0.06179 
## F-statistic: 9.496 on 1 and 128 DF,  p-value: 0.002521
```

So from top to bottom:

* Our min and max go from -16.5 to positive 17.1
* Our adjusted R-squared is ... .06. Not much at all. 
* Our p-value is ... .002, which is less than than .05. 

So what we can say about this model is that it's statistically significant but utterly meaningless. Normally, we'd stop right here -- why bother going forward with a predictive model that isn't predictive? But let's do it anyway. 


```r
penalties$predicted <- predict(pfit)
penalties$residuals <- residuals(pfit)
```


```r
penalties %>% arrange(desc(residuals))
```

```
## # A tibble: 130 x 14
##    Name  OffPoints OffPointsG DefPoints DefPointsG  Pen. Yards `Pen./G`
##    <chr>     <dbl>      <dbl>     <dbl>      <dbl> <dbl> <dbl>    <dbl>
##  1 Okla…       677       48.4       466       33.3    86   855      6.1
##  2 Utah…       618       47.5       289       22.2   101   916      7.8
##  3 Clem…       664       44.3       197       13.1    73   674      4.9
##  4 Alab…       684       45.6       271       18.1    87   796      5.8
##  5 Hous…       571       43.9       483       37.2    87   683      6.7
##  6 UCF         562       43.2       295       22.7    97   848      7.5
##  7 Memp…       601       42.9       447       31.9   101   833      7.2
##  8 Ohio        521       40.1       320       24.6    64   652      4.9
##  9 Syra…       523       40.2       351       27      94   768      7.2
## 10 West…       483       40.3       326       27.2    85   800      7.1
## # … with 120 more rows, and 6 more variables: OffConversions <dbl>,
## #   OffConversionPct <dbl>, DefConversions <dbl>, DefConversionPct <dbl>,
## #   predicted <dbl>, residuals <dbl>
```

So our model says Oklahoma *should* only be scoring 31.3 points per game given how many penalty yards per game, but they're really scoring 48.4. Oy. What happens if we plot those residuals? 

![](10-residuals_files/figure-epub3/unnamed-chunk-12-1.png)<!-- -->

Well ... it actually says that a linear model is appropriate. Which an important lesson -- just because your residual plot says a linear model works here, that doesn't say your linear model is good. There are other measures for that, and you need to use them. 

Here's the segment plot of residuals -- you'll see some really long lines. That's a bad sign. 

![](10-residuals_files/figure-epub3/unnamed-chunk-13-1.png)<!-- -->

