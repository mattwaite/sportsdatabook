# Tables

But not a table. A table with features. 

Sometimes, the best way to show your data is with a table -- simple rows and columns. It allows a reader to compare whatever they want to compare a little easier than a graph where you've chosen what to highlight. R has a neat package called `formattable` and you'll install it like anything else with `install.packages('formattable')`. 

So what does it do? Let's gather our libraries and [get some data](https://unl.box.com/s/g3eeuogx8bog72ig28enuakhpdlbn394). 


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
library(formattable)
```



```r
offense <- read_csv("data/offensechange.csv")
```

```
## Parsed with column specification:
## cols(
##   Year = col_double(),
##   Name = col_character(),
##   G = col_double(),
##   `Rush Yards` = col_double(),
##   `Pass Yards` = col_double(),
##   Plays = col_double(),
##   `Total Yards` = col_double(),
##   `Yards/Play` = col_double(),
##   `Yards/G` = col_double()
## )
```


Let's ask this question: Which college football team saw the greatest improvement in yards per game last regular season? The simplest way to calculate that is by percent change. 


```r
changeTotalOffense <- offense %>%
  select(Name, Year, `Yards/G`) %>% 
  spread(Year, `Yards/G`) %>% 
  mutate(Change=(`2019`-`2018`)/`2018`) %>% 
  arrange(desc(Change)) %>% 
  top_n(20)
```

```
## Selecting by Change
```
We've output tables to the screen a thousand times in this class with `head`, but formattable makes them look good with very little code. 


```r
formattable(changeTotalOffense)
```


<table class="table table-condensed">
 <thead>
  <tr>
   <th style="text-align:right;"> Name </th>
   <th style="text-align:right;"> 2018 </th>
   <th style="text-align:right;"> 2019 </th>
   <th style="text-align:right;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> Central Michigan </td>
   <td style="text-align:right;"> 254.7 </td>
   <td style="text-align:right;"> 433.6 </td>
   <td style="text-align:right;"> 0.7023950 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> LSU </td>
   <td style="text-align:right;"> 402.1 </td>
   <td style="text-align:right;"> 564.1 </td>
   <td style="text-align:right;"> 0.4028849 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> UTSA </td>
   <td style="text-align:right;"> 247.1 </td>
   <td style="text-align:right;"> 344.9 </td>
   <td style="text-align:right;"> 0.3957912 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> San Jose State </td>
   <td style="text-align:right;"> 323.7 </td>
   <td style="text-align:right;"> 427.4 </td>
   <td style="text-align:right;"> 0.3203584 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Navy </td>
   <td style="text-align:right;"> 349.3 </td>
   <td style="text-align:right;"> 455.8 </td>
   <td style="text-align:right;"> 0.3048955 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Louisville </td>
   <td style="text-align:right;"> 352.6 </td>
   <td style="text-align:right;"> 447.3 </td>
   <td style="text-align:right;"> 0.2685763 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> SMU </td>
   <td style="text-align:right;"> 387.2 </td>
   <td style="text-align:right;"> 489.8 </td>
   <td style="text-align:right;"> 0.2649793 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> BYU </td>
   <td style="text-align:right;"> 364.9 </td>
   <td style="text-align:right;"> 443.8 </td>
   <td style="text-align:right;"> 0.2162236 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> New Mexico </td>
   <td style="text-align:right;"> 330.0 </td>
   <td style="text-align:right;"> 400.3 </td>
   <td style="text-align:right;"> 0.2130303 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Charlotte </td>
   <td style="text-align:right;"> 343.1 </td>
   <td style="text-align:right;"> 411.8 </td>
   <td style="text-align:right;"> 0.2002332 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Iowa State </td>
   <td style="text-align:right;"> 371.0 </td>
   <td style="text-align:right;"> 444.3 </td>
   <td style="text-align:right;"> 0.1975741 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> USC </td>
   <td style="text-align:right;"> 382.6 </td>
   <td style="text-align:right;"> 454.0 </td>
   <td style="text-align:right;"> 0.1866179 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Troy </td>
   <td style="text-align:right;"> 389.4 </td>
   <td style="text-align:right;"> 456.3 </td>
   <td style="text-align:right;"> 0.1718028 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Louisiana-Lafayette </td>
   <td style="text-align:right;"> 424.3 </td>
   <td style="text-align:right;"> 494.1 </td>
   <td style="text-align:right;"> 0.1645062 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Georgia State </td>
   <td style="text-align:right;"> 378.2 </td>
   <td style="text-align:right;"> 439.8 </td>
   <td style="text-align:right;"> 0.1628768 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Louisiana Tech </td>
   <td style="text-align:right;"> 379.3 </td>
   <td style="text-align:right;"> 436.8 </td>
   <td style="text-align:right;"> 0.1515950 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Minnesota </td>
   <td style="text-align:right;"> 379.6 </td>
   <td style="text-align:right;"> 432.0 </td>
   <td style="text-align:right;"> 0.1380400 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Ball State </td>
   <td style="text-align:right;"> 408.6 </td>
   <td style="text-align:right;"> 463.0 </td>
   <td style="text-align:right;"> 0.1331375 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Texas </td>
   <td style="text-align:right;"> 411.6 </td>
   <td style="text-align:right;"> 465.8 </td>
   <td style="text-align:right;"> 0.1316812 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Florida State </td>
   <td style="text-align:right;"> 361.2 </td>
   <td style="text-align:right;"> 408.3 </td>
   <td style="text-align:right;"> 0.1303987 </td>
  </tr>
</tbody>
</table>

So there you have it. Central Michigan improved the most (but look at who came in second!). First thing I don't like about formattable tables -- the right alignment. Let's fix that. 


```r
formattable(changeTotalOffense, align="l")
```


<table class="table table-condensed">
 <thead>
  <tr>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:left;"> 2018 </th>
   <th style="text-align:left;"> 2019 </th>
   <th style="text-align:left;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Central Michigan </td>
   <td style="text-align:left;"> 254.7 </td>
   <td style="text-align:left;"> 433.6 </td>
   <td style="text-align:left;"> 0.7023950 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LSU </td>
   <td style="text-align:left;"> 402.1 </td>
   <td style="text-align:left;"> 564.1 </td>
   <td style="text-align:left;"> 0.4028849 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UTSA </td>
   <td style="text-align:left;"> 247.1 </td>
   <td style="text-align:left;"> 344.9 </td>
   <td style="text-align:left;"> 0.3957912 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> San Jose State </td>
   <td style="text-align:left;"> 323.7 </td>
   <td style="text-align:left;"> 427.4 </td>
   <td style="text-align:left;"> 0.3203584 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Navy </td>
   <td style="text-align:left;"> 349.3 </td>
   <td style="text-align:left;"> 455.8 </td>
   <td style="text-align:left;"> 0.3048955 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisville </td>
   <td style="text-align:left;"> 352.6 </td>
   <td style="text-align:left;"> 447.3 </td>
   <td style="text-align:left;"> 0.2685763 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SMU </td>
   <td style="text-align:left;"> 387.2 </td>
   <td style="text-align:left;"> 489.8 </td>
   <td style="text-align:left;"> 0.2649793 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BYU </td>
   <td style="text-align:left;"> 364.9 </td>
   <td style="text-align:left;"> 443.8 </td>
   <td style="text-align:left;"> 0.2162236 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> New Mexico </td>
   <td style="text-align:left;"> 330.0 </td>
   <td style="text-align:left;"> 400.3 </td>
   <td style="text-align:left;"> 0.2130303 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Charlotte </td>
   <td style="text-align:left;"> 343.1 </td>
   <td style="text-align:left;"> 411.8 </td>
   <td style="text-align:left;"> 0.2002332 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iowa State </td>
   <td style="text-align:left;"> 371.0 </td>
   <td style="text-align:left;"> 444.3 </td>
   <td style="text-align:left;"> 0.1975741 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> USC </td>
   <td style="text-align:left;"> 382.6 </td>
   <td style="text-align:left;"> 454.0 </td>
   <td style="text-align:left;"> 0.1866179 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Troy </td>
   <td style="text-align:left;"> 389.4 </td>
   <td style="text-align:left;"> 456.3 </td>
   <td style="text-align:left;"> 0.1718028 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisiana-Lafayette </td>
   <td style="text-align:left;"> 424.3 </td>
   <td style="text-align:left;"> 494.1 </td>
   <td style="text-align:left;"> 0.1645062 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Georgia State </td>
   <td style="text-align:left;"> 378.2 </td>
   <td style="text-align:left;"> 439.8 </td>
   <td style="text-align:left;"> 0.1628768 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisiana Tech </td>
   <td style="text-align:left;"> 379.3 </td>
   <td style="text-align:left;"> 436.8 </td>
   <td style="text-align:left;"> 0.1515950 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Minnesota </td>
   <td style="text-align:left;"> 379.6 </td>
   <td style="text-align:left;"> 432.0 </td>
   <td style="text-align:left;"> 0.1380400 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ball State </td>
   <td style="text-align:left;"> 408.6 </td>
   <td style="text-align:left;"> 463.0 </td>
   <td style="text-align:left;"> 0.1331375 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Texas </td>
   <td style="text-align:left;"> 411.6 </td>
   <td style="text-align:left;"> 465.8 </td>
   <td style="text-align:left;"> 0.1316812 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Florida State </td>
   <td style="text-align:left;"> 361.2 </td>
   <td style="text-align:left;"> 408.3 </td>
   <td style="text-align:left;"> 0.1303987 </td>
  </tr>
</tbody>
</table>

Next? I forgot to multiply by 100. No matter. Formattable can fix that for us. 


```r
formattable(
  changeTotalOffense, 
  align="l",
  list(
    `Change` = percent)
  )
```


<table class="table table-condensed">
 <thead>
  <tr>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:left;"> 2018 </th>
   <th style="text-align:left;"> 2019 </th>
   <th style="text-align:left;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Central Michigan </td>
   <td style="text-align:left;"> 254.7 </td>
   <td style="text-align:left;"> 433.6 </td>
   <td style="text-align:left;"> 70.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LSU </td>
   <td style="text-align:left;"> 402.1 </td>
   <td style="text-align:left;"> 564.1 </td>
   <td style="text-align:left;"> 40.29% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UTSA </td>
   <td style="text-align:left;"> 247.1 </td>
   <td style="text-align:left;"> 344.9 </td>
   <td style="text-align:left;"> 39.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> San Jose State </td>
   <td style="text-align:left;"> 323.7 </td>
   <td style="text-align:left;"> 427.4 </td>
   <td style="text-align:left;"> 32.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Navy </td>
   <td style="text-align:left;"> 349.3 </td>
   <td style="text-align:left;"> 455.8 </td>
   <td style="text-align:left;"> 30.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisville </td>
   <td style="text-align:left;"> 352.6 </td>
   <td style="text-align:left;"> 447.3 </td>
   <td style="text-align:left;"> 26.86% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SMU </td>
   <td style="text-align:left;"> 387.2 </td>
   <td style="text-align:left;"> 489.8 </td>
   <td style="text-align:left;"> 26.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BYU </td>
   <td style="text-align:left;"> 364.9 </td>
   <td style="text-align:left;"> 443.8 </td>
   <td style="text-align:left;"> 21.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> New Mexico </td>
   <td style="text-align:left;"> 330.0 </td>
   <td style="text-align:left;"> 400.3 </td>
   <td style="text-align:left;"> 21.30% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Charlotte </td>
   <td style="text-align:left;"> 343.1 </td>
   <td style="text-align:left;"> 411.8 </td>
   <td style="text-align:left;"> 20.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iowa State </td>
   <td style="text-align:left;"> 371.0 </td>
   <td style="text-align:left;"> 444.3 </td>
   <td style="text-align:left;"> 19.76% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> USC </td>
   <td style="text-align:left;"> 382.6 </td>
   <td style="text-align:left;"> 454.0 </td>
   <td style="text-align:left;"> 18.66% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Troy </td>
   <td style="text-align:left;"> 389.4 </td>
   <td style="text-align:left;"> 456.3 </td>
   <td style="text-align:left;"> 17.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisiana-Lafayette </td>
   <td style="text-align:left;"> 424.3 </td>
   <td style="text-align:left;"> 494.1 </td>
   <td style="text-align:left;"> 16.45% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Georgia State </td>
   <td style="text-align:left;"> 378.2 </td>
   <td style="text-align:left;"> 439.8 </td>
   <td style="text-align:left;"> 16.29% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisiana Tech </td>
   <td style="text-align:left;"> 379.3 </td>
   <td style="text-align:left;"> 436.8 </td>
   <td style="text-align:left;"> 15.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Minnesota </td>
   <td style="text-align:left;"> 379.6 </td>
   <td style="text-align:left;"> 432.0 </td>
   <td style="text-align:left;"> 13.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ball State </td>
   <td style="text-align:left;"> 408.6 </td>
   <td style="text-align:left;"> 463.0 </td>
   <td style="text-align:left;"> 13.31% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Texas </td>
   <td style="text-align:left;"> 411.6 </td>
   <td style="text-align:left;"> 465.8 </td>
   <td style="text-align:left;"> 13.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Florida State </td>
   <td style="text-align:left;"> 361.2 </td>
   <td style="text-align:left;"> 408.3 </td>
   <td style="text-align:left;"> 13.04% </td>
  </tr>
</tbody>
</table>

Something else not great? I can't really see the magnitude of the 2019 column. A team could improve a lot, but still not gain that many yards. Formattable has embeddable bar charts in the table. They look like this. 


```r
formattable(
  changeTotalOffense, 
  align="l",
  list(
    `2019` = color_bar("#FA614B"), 
    `Change` = percent)
  )
```


<table class="table table-condensed">
 <thead>
  <tr>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:left;"> 2018 </th>
   <th style="text-align:left;"> 2019 </th>
   <th style="text-align:left;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Central Michigan </td>
   <td style="text-align:left;"> 254.7 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 76.87%">433.6</span> </td>
   <td style="text-align:left;"> 70.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> LSU </td>
   <td style="text-align:left;"> 402.1 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 100.00%">564.1</span> </td>
   <td style="text-align:left;"> 40.29% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UTSA </td>
   <td style="text-align:left;"> 247.1 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 61.14%">344.9</span> </td>
   <td style="text-align:left;"> 39.58% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> San Jose State </td>
   <td style="text-align:left;"> 323.7 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 75.77%">427.4</span> </td>
   <td style="text-align:left;"> 32.04% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Navy </td>
   <td style="text-align:left;"> 349.3 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 80.80%">455.8</span> </td>
   <td style="text-align:left;"> 30.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisville </td>
   <td style="text-align:left;"> 352.6 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 79.29%">447.3</span> </td>
   <td style="text-align:left;"> 26.86% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SMU </td>
   <td style="text-align:left;"> 387.2 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 86.83%">489.8</span> </td>
   <td style="text-align:left;"> 26.50% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> BYU </td>
   <td style="text-align:left;"> 364.9 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 78.67%">443.8</span> </td>
   <td style="text-align:left;"> 21.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> New Mexico </td>
   <td style="text-align:left;"> 330.0 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 70.96%">400.3</span> </td>
   <td style="text-align:left;"> 21.30% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Charlotte </td>
   <td style="text-align:left;"> 343.1 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 73.00%">411.8</span> </td>
   <td style="text-align:left;"> 20.02% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iowa State </td>
   <td style="text-align:left;"> 371.0 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 78.76%">444.3</span> </td>
   <td style="text-align:left;"> 19.76% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> USC </td>
   <td style="text-align:left;"> 382.6 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 80.48%">454.0</span> </td>
   <td style="text-align:left;"> 18.66% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Troy </td>
   <td style="text-align:left;"> 389.4 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 80.89%">456.3</span> </td>
   <td style="text-align:left;"> 17.18% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisiana-Lafayette </td>
   <td style="text-align:left;"> 424.3 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 87.59%">494.1</span> </td>
   <td style="text-align:left;"> 16.45% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Georgia State </td>
   <td style="text-align:left;"> 378.2 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 77.96%">439.8</span> </td>
   <td style="text-align:left;"> 16.29% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisiana Tech </td>
   <td style="text-align:left;"> 379.3 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 77.43%">436.8</span> </td>
   <td style="text-align:left;"> 15.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Minnesota </td>
   <td style="text-align:left;"> 379.6 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 76.58%">432.0</span> </td>
   <td style="text-align:left;"> 13.80% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ball State </td>
   <td style="text-align:left;"> 408.6 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 82.08%">463.0</span> </td>
   <td style="text-align:left;"> 13.31% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Texas </td>
   <td style="text-align:left;"> 411.6 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 82.57%">465.8</span> </td>
   <td style="text-align:left;"> 13.17% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Florida State </td>
   <td style="text-align:left;"> 361.2 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 72.38%">408.3</span> </td>
   <td style="text-align:left;"> 13.04% </td>
  </tr>
</tbody>
</table>
That gives me some more to mess with. 

One thing you can do is set the bar widths to make them relative to each other, using a different function called a `normalize_bar`.

```r
formattable(
  changeTotalOffense, 
  align="r",
  list(
    `2019` = normalize_bar("#FA614B"), 
    `2018` = normalize_bar("#FA614B"), 
    `Change` = percent)
  )
```


<table class="table table-condensed">
 <thead>
  <tr>
   <th style="text-align:right;"> Name </th>
   <th style="text-align:right;"> 2018 </th>
   <th style="text-align:right;"> 2019 </th>
   <th style="text-align:right;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> Central Michigan </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 4.29%">254.7</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 40.47%">433.6</span> </td>
   <td style="text-align:right;"> 70.24% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> LSU </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 87.47%">402.1</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 100.00%">564.1</span> </td>
   <td style="text-align:right;"> 40.29% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> UTSA </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 0.00%">247.1</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 0.00%">344.9</span> </td>
   <td style="text-align:right;"> 39.58% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> San Jose State </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 43.23%">323.7</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 37.64%">427.4</span> </td>
   <td style="text-align:right;"> 32.04% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Navy </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 57.67%">349.3</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 50.59%">455.8</span> </td>
   <td style="text-align:right;"> 30.49% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Louisville </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 59.54%">352.6</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 46.72%">447.3</span> </td>
   <td style="text-align:right;"> 26.86% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> SMU </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 79.06%">387.2</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 66.10%">489.8</span> </td>
   <td style="text-align:right;"> 26.50% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> BYU </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 66.48%">364.9</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 45.12%">443.8</span> </td>
   <td style="text-align:right;"> 21.62% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> New Mexico </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 46.78%">330.0</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 25.27%">400.3</span> </td>
   <td style="text-align:right;"> 21.30% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Charlotte </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 54.18%">343.1</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 30.52%">411.8</span> </td>
   <td style="text-align:right;"> 20.02% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Iowa State </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 69.92%">371.0</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 45.35%">444.3</span> </td>
   <td style="text-align:right;"> 19.76% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> USC </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 76.47%">382.6</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 49.77%">454.0</span> </td>
   <td style="text-align:right;"> 18.66% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Troy </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 80.30%">389.4</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 50.82%">456.3</span> </td>
   <td style="text-align:right;"> 17.18% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Louisiana-Lafayette </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 100.00%">424.3</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 68.07%">494.1</span> </td>
   <td style="text-align:right;"> 16.45% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Georgia State </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 73.98%">378.2</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 43.29%">439.8</span> </td>
   <td style="text-align:right;"> 16.29% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Louisiana Tech </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 74.60%">379.3</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 41.93%">436.8</span> </td>
   <td style="text-align:right;"> 15.16% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Minnesota </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 74.77%">379.6</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 39.74%">432.0</span> </td>
   <td style="text-align:right;"> 13.80% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Ball State </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 91.14%">408.6</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 53.88%">463.0</span> </td>
   <td style="text-align:right;"> 13.31% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Texas </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 92.83%">411.6</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 55.16%">465.8</span> </td>
   <td style="text-align:right;"> 13.17% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Florida State </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 64.39%">361.2</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 28.92%">408.3</span> </td>
   <td style="text-align:right;"> 13.04% </td>
  </tr>
</tbody>
</table>

Note: bookdown is formatting this weird. Your numbers won't look like this.

Another way to deal with this -- color tiles. Change the rectangle that houses the data to a color indicating the intensity of it.


```r
formattable(
  changeTotalOffense, 
  align="r",
  list(
     area(col = 2:3) ~ color_tile("#FFF6F4", "#FA614B"),
    `Change` = percent)
  )
```


<table class="table table-condensed">
 <thead>
  <tr>
   <th style="text-align:right;"> Name </th>
   <th style="text-align:right;"> 2018 </th>
   <th style="text-align:right;"> 2019 </th>
   <th style="text-align:right;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> Central Michigan </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fef2ef">254.7</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fc9e90">433.6</span> </td>
   <td style="text-align:right;"> 70.24% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> LSU </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcada1">402.1</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fa614b">564.1</span> </td>
   <td style="text-align:right;"> 40.29% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> UTSA </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fff6f4">247.1</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc8bf">344.9</span> </td>
   <td style="text-align:right;"> 39.58% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> San Jose State </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdd1cb">323.7</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fca193">427.4</span> </td>
   <td style="text-align:right;"> 32.04% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Navy </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc5bd">349.3</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9384">455.8</span> </td>
   <td style="text-align:right;"> 30.49% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Louisville </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc4bb">352.6</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9789">447.3</span> </td>
   <td style="text-align:right;"> 26.86% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> SMU </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcb4a9">387.2</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb8372">489.8</span> </td>
   <td style="text-align:right;"> 26.50% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> BYU </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdbeb5">364.9</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb998b">443.8</span> </td>
   <td style="text-align:right;"> 21.62% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> New Mexico </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdcfc7">330.0</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcada2">400.3</span> </td>
   <td style="text-align:right;"> 21.30% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Charlotte </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc8c0">343.1</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fca89c">411.8</span> </td>
   <td style="text-align:right;"> 20.02% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Iowa State </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdbbb1">371.0</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb998a">444.3</span> </td>
   <td style="text-align:right;"> 19.76% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> USC </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcb6ab">382.6</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9485">454.0</span> </td>
   <td style="text-align:right;"> 18.66% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Troy </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcb3a8">389.4</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9384">456.3</span> </td>
   <td style="text-align:right;"> 17.18% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Louisiana-Lafayette </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fca295">424.3</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb8170">494.1</span> </td>
   <td style="text-align:right;"> 16.45% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Georgia State </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcb8ae">378.2</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9b8d">439.8</span> </td>
   <td style="text-align:right;"> 16.29% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Louisiana Tech </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcb7ad">379.3</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fc9c8e">436.8</span> </td>
   <td style="text-align:right;"> 15.16% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Minnesota </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcb7ad">379.6</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fc9f91">432.0</span> </td>
   <td style="text-align:right;"> 13.80% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Ball State </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcaa9d">408.6</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9080">463.0</span> </td>
   <td style="text-align:right;"> 13.31% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Texas </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fca89c">411.6</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb8f7f">465.8</span> </td>
   <td style="text-align:right;"> 13.17% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Florida State </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc0b7">361.2</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcaa9e">408.3</span> </td>
   <td style="text-align:right;"> 13.04% </td>
  </tr>
</tbody>
</table>

### Exporting tables

The first thing you need to do is install some libraries -- do this in the console, not in an R Studio code block because htmltools get's a little weird. 

```
install.packages("htmltools")
install.packages("webshot")

webshot::install_phantomjs()
```

Now, copy, paste and run this code block entirely. Don't change anything. 


```r
library("htmltools")
```

```
## Warning: package 'htmltools' was built under R version 3.5.2
```

```r
library("webshot")    
```

```
## Warning: package 'webshot' was built under R version 3.5.2
```

```r
export_formattable <- function(f, file, width = "100%", height = NULL, 
                               background = "white", delay = 0.2)
    {
      w <- as.htmlwidget(f, width = width, height = height)
      path <- html_print(w, background = background, viewer = NULL)
      url <- paste0("file:///", gsub("\\\\", "/", normalizePath(path)))
      webshot(url,
              file = file,
              selector = ".formattable_widget",
              delay = delay)
    }
```

Now, save your formattable table to an object using the `<-` assignment operator. 

After you've done that, you can call the function you ran in the previous block to export as a png file. In my case, I created an object called table, which is populated with my formattable table. Then, in export_formattable, I pass in that `table` object and give it a name. 


```r
table <- formattable(
  changeTotalOffense, 
  align="r",
  list(
     area(col = 2:3) ~ color_tile("#FFF6F4", "#FA614B"),
    `Change` = percent)
  )

export_formattable(table,"table.png")
```

![](21-tables_files/figure-epub3/unnamed-chunk-11-1.png)<!-- -->

For now, pngs are what you need to export. There is a way to export PDFs, but they lose all the formatting when you do that, which is kind of pointless. 
