# Waffle charts

Pie charts are the devil. They should be an instant F in any data visualization class. I'll give you an example of why.

What's the racial breakdown of journalism majors at UNL?

Here it is in a pie chart:


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
enrollment <- read.csv("~/Dropbox/JOUR407-Data-Visualization/Data/collegeenrollment.csv")

jour <- filter(enrollment, MajorName == "Journalism")

jdf <- jour %>% 
group_by(Race) %>%
summarise(
       total=sum(Count)) %>%
select(Race, total) %>% 
filter(total != 0)

ggplot(jdf, aes(x="", y=total, fill=Race)) + geom_bar(width = 1, stat = "identity") + coord_polar("y", start=0)
```

![](14-wafflecharts_files/figure-epub3/unnamed-chunk-1-1.png)<!-- -->
You can see, it's pretty white. But ... what about beyond that? How carefully can you evaluate angles and area?

Not well.

So let's introduce a better way: The Waffle Chart. Some call it a square pie chart. I personally hate that. Waffles it is. 

First, install the library in the console: 

`install.packages('waffle')`

Now load it: 


```r
library(waffle)
```

Let's look at the debacle in Ann Arbor with Nebraska basketball. [Here's the box score](https://www.sports-reference.com/cbb/boxscores/2019-02-28-19-michigan.html), which we'll use for this walkthrough. 

The easiest way to do waffle charts is to make vectors of your data and plug them in. To make a vector, we use the `c` or concatenate function, something we've done before. 

So let's look at ... shooting. We shot like crap that night, they didn't. 


```r
nu <- c("Made"=23, "Missed"=44)
mi <- c("Made"=30, "Missed"=24)
```

So what does the breakdown of the night look like?

The waffle library can break this down in a way that's easier on the eyes than a pie chart. We call the library, add the data, specify the number of rows, give it a title and an x value label, and to clean up a quirk of the library, we've got to specify colors. 


```r
waffle(nu, rows = 5, title="Nebraska's shooting night", xlab="1 square = 1 shot", colors = c("black", "red"))
```

![](14-wafflecharts_files/figure-epub3/unnamed-chunk-4-1.png)<!-- -->

Or, we could make this two teams in the same chart.


```r
game <- c("Nebraska"=23, "Michigan"=30)
```


```r
waffle(game, rows = 5, title="Nebraska vs Michigan: made shots", xlab="1 square = 1 shot", colors = c("red", "dark blue"))
```

![](14-wafflecharts_files/figure-epub3/unnamed-chunk-6-1.png)<!-- -->

## Waffle Irons

So what does it look like if we compare the two teams. Do do that -- and I am not making this up -- you have to create a waffle iron. Get it? Waffle charts? Iron? 


```r
iron(
 waffle(nu, rows = 5, title="Nebraska's night shooting", xlab="1 square = 1 shot", colors = c("black", "red")),
 waffle(mi, rows = 5, title="Michigan's night shooting", xlab="1 square = 1 shot", colors = c("dark blue", "yellow"))
)
```

![](14-wafflecharts_files/figure-epub3/unnamed-chunk-7-1.png)<!-- -->

What do you notice about this chart? Notice how the squares aren't the same size? Well, Michigan only took 54 shots. We took 67. So the squares aren't the same size because the numbers aren't the same. We can fix that by adding an unnamed padding number so the number of shots add up to the same thing. Let's make the total for everyone be 70. So to do that, we need to add a padding of 3 to Nebraska and a padding of 16 to Michigan. REMEMBER: Don't name it or it'll show up in the legend.


```r
nu <- c("Made"=23, "Missed"=44, 3)
mi <- c("Made"=30, "Missed"=24, 16)
```

Now, in our waffle iron, if we don't give that padding a color, we'll get an error. So we need to make it white. Which, given our white background, means it will disappear.


```r
iron(
 waffle(nu, rows = 5, title="Nebraska's night shooting", colors = c("black", "red", "white")),
 waffle(mi, rows = 5, title="Michigan's night shooting", xlab="1 square = 1 shot", colors = c("dark blue", "yellow", "white"))
)
```

![](14-wafflecharts_files/figure-epub3/unnamed-chunk-9-1.png)<!-- -->


