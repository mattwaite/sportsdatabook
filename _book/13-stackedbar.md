# Stacked bar charts

One of the elements of data visualization excellence, accoring to Tufte, is inviting comparison. Often that comes in showing what proportion a thing is in relation to the whole thing. With bar charts, if we have information about the parts of the whole, we can stack them on top of each other to compare them. And it's a simple change to what we've already done. 


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
We're going to use a dataset of graduation rates by gender by school in the NCAA. [You can get it here](https://unl.box.com/s/3nw1eokvs9zfdjyzvjaj3xdq01rm8sym). 


```r
grads <- read_csv('data/grads.csv')
```

```
## Parsed with column specification:
## cols(
##   `Institution name` = col_character(),
##   `Primary Conference in Actual Year` = col_character(),
##   `Cohort year` = col_double(),
##   Gender = col_character(),
##   `Number of completers` = col_double(),
##   Total = col_double()
## )
```
What we have here is the name of the school, the conference, the cohort of when they started school, the gender, the number of that gender that graduated and the total number of graduates in that cohort. 

Let's pretend for a moment we're looking at the graduation rates of men and women in the Big 10 Conference and we want to chart that. First, let's work on our data. We need to filter the "Big Ten Conference" school, and we want the latest year, which is 2009. So we'll create a dataframe called `BIG09` and populate it. 


```r
BIG09 <- grads %>% filter(`Primary Conference in Actual Year`=="Big Ten Conference") %>% filter(`Cohort year` == 2009)
```


```r
head(BIG09)
```

```
## # A tibble: 6 x 6
##   `Institution na… `Primary Confer… `Cohort year` Gender `Number of comp…
##   <chr>            <chr>                    <dbl> <chr>             <dbl>
## 1 University of I… Big Ten Confere…          2009 Men                2973
## 2 University of I… Big Ten Confere…          2009 Women              2967
## 3 Northwestern Un… Big Ten Confere…          2009 Men                 963
## 4 Northwestern Un… Big Ten Confere…          2009 Women              1011
## 5 Indiana Univers… Big Ten Confere…          2009 Men                2667
## 6 Indiana Univers… Big Ten Confere…          2009 Women              2959
## # … with 1 more variable: Total <dbl>
```

Building on what we learned in the last chapter, we know we can turn this into a bar chart with an x value, a weight and a geom_bar. What're going to add is a `fill`. The `fill` will stack bars on each other based on which element it is. In this case, we can fill the bar by Gender, which means it will stack the number of male graduates on top of the number of female graduates and we can see how they compare. 


```r
ggplot(BIG09, aes(x=reorder(`Institution name`, -Total), weight=`Number of completers`, fill=Gender)) + geom_bar() + coord_flip()
```

![](13-stackedbar_files/figure-epub3/unnamed-chunk-5-1.png)<!-- -->

What's the problem with this chart? 

Let me ask a different question -- which schools have larger differences in male and female graduation rates? Can you compare Illnois to Northwestern? Not really. We've charted the total numbers. We need the percentage of the whole. 

> **YOUR TURN**: Using what you know -- hint: mutate -- how could you chart this using percents of the whole instead of counts? 
