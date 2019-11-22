# Tables

But not a table. A table with features. 

Sometimes, the best way to show your data is with a table. R has a neat package called `formattable` and you'll install it like anything else with `install.packages('formattable')`. 

So what does it do? Let's gather our libraries and [get some data](https://unl.box.com/s/g3eeuogx8bog72ig28enuakhpdlbn394). 


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

```r
library(formattable)
```



```r
offense <- read_csv("data/offensechange.csv")
```

```
## Parsed with column specification:
## cols(
##   Rank = col_double(),
##   Name = col_character(),
##   G = col_double(),
##   `Rush Yards` = col_double(),
##   `Pass Yards` = col_double(),
##   Plays = col_double(),
##   `Total Yards` = col_double(),
##   `Yards/Play` = col_double(),
##   `Yards/G` = col_double(),
##   Year = col_double()
## )
```


Let's ask this question: Which college football team saw the greatest improvement in yards per game last regular season? The simplest way to calculate that is by percent change. 


```r
changeTotalOffense <- offense %>%
  select(Name, Year, `Yards/G`) %>% 
  spread(Year, `Yards/G`) %>% 
  mutate(Change=(`2018`-`2017`)/`2017`) %>% 
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
   <th style="text-align:right;"> 2017 </th>
   <th style="text-align:right;"> 2018 </th>
   <th style="text-align:right;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> Illinois </td>
   <td style="text-align:right;"> 280.4 </td>
   <td style="text-align:right;"> 408.7 </td>
   <td style="text-align:right;"> 0.4575606 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Kent State </td>
   <td style="text-align:right;"> 275.2 </td>
   <td style="text-align:right;"> 383.6 </td>
   <td style="text-align:right;"> 0.3938953 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> UTEP </td>
   <td style="text-align:right;"> 230.5 </td>
   <td style="text-align:right;"> 307.7 </td>
   <td style="text-align:right;"> 0.3349241 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Cincinnati </td>
   <td style="text-align:right;"> 351.8 </td>
   <td style="text-align:right;"> 458.5 </td>
   <td style="text-align:right;"> 0.3032973 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Old Dominion </td>
   <td style="text-align:right;"> 332.3 </td>
   <td style="text-align:right;"> 427.8 </td>
   <td style="text-align:right;"> 0.2873909 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Florida </td>
   <td style="text-align:right;"> 335.9 </td>
   <td style="text-align:right;"> 426.7 </td>
   <td style="text-align:right;"> 0.2703185 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> South Carolina </td>
   <td style="text-align:right;"> 337.1 </td>
   <td style="text-align:right;"> 425.6 </td>
   <td style="text-align:right;"> 0.2625334 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Utah State </td>
   <td style="text-align:right;"> 397.4 </td>
   <td style="text-align:right;"> 497.4 </td>
   <td style="text-align:right;"> 0.2516356 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Minnesota </td>
   <td style="text-align:right;"> 308.5 </td>
   <td style="text-align:right;"> 379.6 </td>
   <td style="text-align:right;"> 0.2304700 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Clemson </td>
   <td style="text-align:right;"> 429.6 </td>
   <td style="text-align:right;"> 527.2 </td>
   <td style="text-align:right;"> 0.2271881 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Ball State </td>
   <td style="text-align:right;"> 335.2 </td>
   <td style="text-align:right;"> 408.6 </td>
   <td style="text-align:right;"> 0.2189737 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Oregon State </td>
   <td style="text-align:right;"> 333.8 </td>
   <td style="text-align:right;"> 404.8 </td>
   <td style="text-align:right;"> 0.2127022 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Michigan </td>
   <td style="text-align:right;"> 348.9 </td>
   <td style="text-align:right;"> 419.5 </td>
   <td style="text-align:right;"> 0.2023502 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Houston </td>
   <td style="text-align:right;"> 428.2 </td>
   <td style="text-align:right;"> 512.5 </td>
   <td style="text-align:right;"> 0.1968706 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> North Carolina </td>
   <td style="text-align:right;"> 369.6 </td>
   <td style="text-align:right;"> 442.1 </td>
   <td style="text-align:right;"> 0.1961580 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Nebraska </td>
   <td style="text-align:right;"> 385.0 </td>
   <td style="text-align:right;"> 456.2 </td>
   <td style="text-align:right;"> 0.1849351 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Alabama </td>
   <td style="text-align:right;"> 444.1 </td>
   <td style="text-align:right;"> 522.0 </td>
   <td style="text-align:right;"> 0.1754109 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Vanderbilt </td>
   <td style="text-align:right;"> 350.8 </td>
   <td style="text-align:right;"> 411.2 </td>
   <td style="text-align:right;"> 0.1721779 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Texas A&M </td>
   <td style="text-align:right;"> 406.8 </td>
   <td style="text-align:right;"> 471.6 </td>
   <td style="text-align:right;"> 0.1592920 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Wyoming </td>
   <td style="text-align:right;"> 286.0 </td>
   <td style="text-align:right;"> 330.8 </td>
   <td style="text-align:right;"> 0.1566434 </td>
  </tr>
</tbody>
</table>

So there you have it. Illinois improved the most. Because Nebraska gave them a quarterback, but I digress. First thing I don't like about formattable tables -- the right alignment. Let's fix that. 


```r
formattable(changeTotalOffense, align="l")
```


<table class="table table-condensed">
 <thead>
  <tr>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:left;"> 2017 </th>
   <th style="text-align:left;"> 2018 </th>
   <th style="text-align:left;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Illinois </td>
   <td style="text-align:left;"> 280.4 </td>
   <td style="text-align:left;"> 408.7 </td>
   <td style="text-align:left;"> 0.4575606 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kent State </td>
   <td style="text-align:left;"> 275.2 </td>
   <td style="text-align:left;"> 383.6 </td>
   <td style="text-align:left;"> 0.3938953 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UTEP </td>
   <td style="text-align:left;"> 230.5 </td>
   <td style="text-align:left;"> 307.7 </td>
   <td style="text-align:left;"> 0.3349241 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cincinnati </td>
   <td style="text-align:left;"> 351.8 </td>
   <td style="text-align:left;"> 458.5 </td>
   <td style="text-align:left;"> 0.3032973 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Old Dominion </td>
   <td style="text-align:left;"> 332.3 </td>
   <td style="text-align:left;"> 427.8 </td>
   <td style="text-align:left;"> 0.2873909 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Florida </td>
   <td style="text-align:left;"> 335.9 </td>
   <td style="text-align:left;"> 426.7 </td>
   <td style="text-align:left;"> 0.2703185 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> South Carolina </td>
   <td style="text-align:left;"> 337.1 </td>
   <td style="text-align:left;"> 425.6 </td>
   <td style="text-align:left;"> 0.2625334 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Utah State </td>
   <td style="text-align:left;"> 397.4 </td>
   <td style="text-align:left;"> 497.4 </td>
   <td style="text-align:left;"> 0.2516356 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Minnesota </td>
   <td style="text-align:left;"> 308.5 </td>
   <td style="text-align:left;"> 379.6 </td>
   <td style="text-align:left;"> 0.2304700 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Clemson </td>
   <td style="text-align:left;"> 429.6 </td>
   <td style="text-align:left;"> 527.2 </td>
   <td style="text-align:left;"> 0.2271881 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ball State </td>
   <td style="text-align:left;"> 335.2 </td>
   <td style="text-align:left;"> 408.6 </td>
   <td style="text-align:left;"> 0.2189737 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Oregon State </td>
   <td style="text-align:left;"> 333.8 </td>
   <td style="text-align:left;"> 404.8 </td>
   <td style="text-align:left;"> 0.2127022 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Michigan </td>
   <td style="text-align:left;"> 348.9 </td>
   <td style="text-align:left;"> 419.5 </td>
   <td style="text-align:left;"> 0.2023502 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Houston </td>
   <td style="text-align:left;"> 428.2 </td>
   <td style="text-align:left;"> 512.5 </td>
   <td style="text-align:left;"> 0.1968706 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> North Carolina </td>
   <td style="text-align:left;"> 369.6 </td>
   <td style="text-align:left;"> 442.1 </td>
   <td style="text-align:left;"> 0.1961580 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nebraska </td>
   <td style="text-align:left;"> 385.0 </td>
   <td style="text-align:left;"> 456.2 </td>
   <td style="text-align:left;"> 0.1849351 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alabama </td>
   <td style="text-align:left;"> 444.1 </td>
   <td style="text-align:left;"> 522.0 </td>
   <td style="text-align:left;"> 0.1754109 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Vanderbilt </td>
   <td style="text-align:left;"> 350.8 </td>
   <td style="text-align:left;"> 411.2 </td>
   <td style="text-align:left;"> 0.1721779 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Texas A&M </td>
   <td style="text-align:left;"> 406.8 </td>
   <td style="text-align:left;"> 471.6 </td>
   <td style="text-align:left;"> 0.1592920 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wyoming </td>
   <td style="text-align:left;"> 286.0 </td>
   <td style="text-align:left;"> 330.8 </td>
   <td style="text-align:left;"> 0.1566434 </td>
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
   <th style="text-align:left;"> 2017 </th>
   <th style="text-align:left;"> 2018 </th>
   <th style="text-align:left;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Illinois </td>
   <td style="text-align:left;"> 280.4 </td>
   <td style="text-align:left;"> 408.7 </td>
   <td style="text-align:left;"> 45.76% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kent State </td>
   <td style="text-align:left;"> 275.2 </td>
   <td style="text-align:left;"> 383.6 </td>
   <td style="text-align:left;"> 39.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UTEP </td>
   <td style="text-align:left;"> 230.5 </td>
   <td style="text-align:left;"> 307.7 </td>
   <td style="text-align:left;"> 33.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cincinnati </td>
   <td style="text-align:left;"> 351.8 </td>
   <td style="text-align:left;"> 458.5 </td>
   <td style="text-align:left;"> 30.33% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Old Dominion </td>
   <td style="text-align:left;"> 332.3 </td>
   <td style="text-align:left;"> 427.8 </td>
   <td style="text-align:left;"> 28.74% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Florida </td>
   <td style="text-align:left;"> 335.9 </td>
   <td style="text-align:left;"> 426.7 </td>
   <td style="text-align:left;"> 27.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> South Carolina </td>
   <td style="text-align:left;"> 337.1 </td>
   <td style="text-align:left;"> 425.6 </td>
   <td style="text-align:left;"> 26.25% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Utah State </td>
   <td style="text-align:left;"> 397.4 </td>
   <td style="text-align:left;"> 497.4 </td>
   <td style="text-align:left;"> 25.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Minnesota </td>
   <td style="text-align:left;"> 308.5 </td>
   <td style="text-align:left;"> 379.6 </td>
   <td style="text-align:left;"> 23.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Clemson </td>
   <td style="text-align:left;"> 429.6 </td>
   <td style="text-align:left;"> 527.2 </td>
   <td style="text-align:left;"> 22.72% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ball State </td>
   <td style="text-align:left;"> 335.2 </td>
   <td style="text-align:left;"> 408.6 </td>
   <td style="text-align:left;"> 21.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Oregon State </td>
   <td style="text-align:left;"> 333.8 </td>
   <td style="text-align:left;"> 404.8 </td>
   <td style="text-align:left;"> 21.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Michigan </td>
   <td style="text-align:left;"> 348.9 </td>
   <td style="text-align:left;"> 419.5 </td>
   <td style="text-align:left;"> 20.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Houston </td>
   <td style="text-align:left;"> 428.2 </td>
   <td style="text-align:left;"> 512.5 </td>
   <td style="text-align:left;"> 19.69% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> North Carolina </td>
   <td style="text-align:left;"> 369.6 </td>
   <td style="text-align:left;"> 442.1 </td>
   <td style="text-align:left;"> 19.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nebraska </td>
   <td style="text-align:left;"> 385.0 </td>
   <td style="text-align:left;"> 456.2 </td>
   <td style="text-align:left;"> 18.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alabama </td>
   <td style="text-align:left;"> 444.1 </td>
   <td style="text-align:left;"> 522.0 </td>
   <td style="text-align:left;"> 17.54% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Vanderbilt </td>
   <td style="text-align:left;"> 350.8 </td>
   <td style="text-align:left;"> 411.2 </td>
   <td style="text-align:left;"> 17.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Texas A&M </td>
   <td style="text-align:left;"> 406.8 </td>
   <td style="text-align:left;"> 471.6 </td>
   <td style="text-align:left;"> 15.93% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wyoming </td>
   <td style="text-align:left;"> 286.0 </td>
   <td style="text-align:left;"> 330.8 </td>
   <td style="text-align:left;"> 15.66% </td>
  </tr>
</tbody>
</table>

Something else not great? I can't really see the magnitude of the 2018 column. A team could improve a lot, but still not gain that many yards (ahem, UTEP). Formattable has embeddable bar charts in the table. They look like this. 


```r
formattable(
  changeTotalOffense, 
  align="l",
  list(
    `2018` = color_bar("#FA614B"), 
    `Change` = percent)
  )
```


<table class="table table-condensed">
 <thead>
  <tr>
   <th style="text-align:left;"> Name </th>
   <th style="text-align:left;"> 2017 </th>
   <th style="text-align:left;"> 2018 </th>
   <th style="text-align:left;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Illinois </td>
   <td style="text-align:left;"> 280.4 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 77.52%">408.7</span> </td>
   <td style="text-align:left;"> 45.76% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kent State </td>
   <td style="text-align:left;"> 275.2 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 72.76%">383.6</span> </td>
   <td style="text-align:left;"> 39.39% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> UTEP </td>
   <td style="text-align:left;"> 230.5 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 58.36%">307.7</span> </td>
   <td style="text-align:left;"> 33.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cincinnati </td>
   <td style="text-align:left;"> 351.8 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 86.97%">458.5</span> </td>
   <td style="text-align:left;"> 30.33% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Old Dominion </td>
   <td style="text-align:left;"> 332.3 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 81.15%">427.8</span> </td>
   <td style="text-align:left;"> 28.74% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Florida </td>
   <td style="text-align:left;"> 335.9 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 80.94%">426.7</span> </td>
   <td style="text-align:left;"> 27.03% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> South Carolina </td>
   <td style="text-align:left;"> 337.1 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 80.73%">425.6</span> </td>
   <td style="text-align:left;"> 26.25% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Utah State </td>
   <td style="text-align:left;"> 397.4 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 94.35%">497.4</span> </td>
   <td style="text-align:left;"> 25.16% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Minnesota </td>
   <td style="text-align:left;"> 308.5 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 72.00%">379.6</span> </td>
   <td style="text-align:left;"> 23.05% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Clemson </td>
   <td style="text-align:left;"> 429.6 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 100.00%">527.2</span> </td>
   <td style="text-align:left;"> 22.72% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ball State </td>
   <td style="text-align:left;"> 335.2 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 77.50%">408.6</span> </td>
   <td style="text-align:left;"> 21.90% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Oregon State </td>
   <td style="text-align:left;"> 333.8 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 76.78%">404.8</span> </td>
   <td style="text-align:left;"> 21.27% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Michigan </td>
   <td style="text-align:left;"> 348.9 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 79.57%">419.5</span> </td>
   <td style="text-align:left;"> 20.24% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Houston </td>
   <td style="text-align:left;"> 428.2 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 97.21%">512.5</span> </td>
   <td style="text-align:left;"> 19.69% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> North Carolina </td>
   <td style="text-align:left;"> 369.6 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 83.86%">442.1</span> </td>
   <td style="text-align:left;"> 19.62% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nebraska </td>
   <td style="text-align:left;"> 385.0 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 86.53%">456.2</span> </td>
   <td style="text-align:left;"> 18.49% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alabama </td>
   <td style="text-align:left;"> 444.1 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 99.01%">522.0</span> </td>
   <td style="text-align:left;"> 17.54% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Vanderbilt </td>
   <td style="text-align:left;"> 350.8 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 78.00%">411.2</span> </td>
   <td style="text-align:left;"> 17.22% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Texas A&M </td>
   <td style="text-align:left;"> 406.8 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 89.45%">471.6</span> </td>
   <td style="text-align:left;"> 15.93% </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wyoming </td>
   <td style="text-align:left;"> 286.0 </td>
   <td style="text-align:left;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 62.75%">330.8</span> </td>
   <td style="text-align:left;"> 15.66% </td>
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
    `2018` = normalize_bar("#FA614B"), 
    `2017` = normalize_bar("#FA614B"), 
    `Change` = percent)
  )
```


<table class="table table-condensed">
 <thead>
  <tr>
   <th style="text-align:right;"> Name </th>
   <th style="text-align:right;"> 2017 </th>
   <th style="text-align:right;"> 2018 </th>
   <th style="text-align:right;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> Illinois </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 23.36%">280.4</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 46.01%">408.7</span> </td>
   <td style="text-align:right;"> 45.76% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Kent State </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 20.93%">275.2</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 34.58%">383.6</span> </td>
   <td style="text-align:right;"> 39.39% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> UTEP </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 0.00%">230.5</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 0.00%">307.7</span> </td>
   <td style="text-align:right;"> 33.49% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Cincinnati </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 56.79%">351.8</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 68.70%">458.5</span> </td>
   <td style="text-align:right;"> 30.33% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Old Dominion </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 47.66%">332.3</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 54.72%">427.8</span> </td>
   <td style="text-align:right;"> 28.74% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Florida </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 49.34%">335.9</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 54.21%">426.7</span> </td>
   <td style="text-align:right;"> 27.03% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> South Carolina </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 49.91%">337.1</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 53.71%">425.6</span> </td>
   <td style="text-align:right;"> 26.25% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Utah State </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 78.14%">397.4</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 86.42%">497.4</span> </td>
   <td style="text-align:right;"> 25.16% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Minnesota </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 36.52%">308.5</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 32.76%">379.6</span> </td>
   <td style="text-align:right;"> 23.05% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Clemson </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 93.21%">429.6</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 100.00%">527.2</span> </td>
   <td style="text-align:right;"> 22.72% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Ball State </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 49.02%">335.2</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 45.97%">408.6</span> </td>
   <td style="text-align:right;"> 21.90% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Oregon State </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 48.36%">333.8</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 44.24%">404.8</span> </td>
   <td style="text-align:right;"> 21.27% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Michigan </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 55.43%">348.9</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 50.93%">419.5</span> </td>
   <td style="text-align:right;"> 20.24% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Houston </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 92.56%">428.2</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 93.30%">512.5</span> </td>
   <td style="text-align:right;"> 19.69% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> North Carolina </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 65.12%">369.6</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 61.23%">442.1</span> </td>
   <td style="text-align:right;"> 19.62% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Nebraska </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 72.33%">385.0</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 67.65%">456.2</span> </td>
   <td style="text-align:right;"> 18.49% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Alabama </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 100.00%">444.1</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 97.63%">522.0</span> </td>
   <td style="text-align:right;"> 17.54% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Vanderbilt </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 56.32%">350.8</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 47.15%">411.2</span> </td>
   <td style="text-align:right;"> 17.22% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Texas A&M </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 82.54%">406.8</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 74.67%">471.6</span> </td>
   <td style="text-align:right;"> 15.93% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Wyoming </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 25.98%">286.0</span> </td>
   <td style="text-align:right;"> <span style="display: inline-block; direction: rtl; border-radius: 4px; padding-right: 2px; background-color: #FA614B; width: 10.52%">330.8</span> </td>
   <td style="text-align:right;"> 15.66% </td>
  </tr>
</tbody>
</table>

Note: bookdown is formatting this weird. Your numbers won't look like this.

Another way to deal with this -- color tiles. Change the rectangle that houses the data to a color indicating the intensity of it. Again, UTEP stands out.


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
   <th style="text-align:right;"> 2017 </th>
   <th style="text-align:right;"> 2018 </th>
   <th style="text-align:right;"> Change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> Illinois </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fedcd7">280.4</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9c8e">408.7</span> </td>
   <td style="text-align:right;"> 45.76% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Kent State </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fedfda">275.2</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fca99c">383.6</span> </td>
   <td style="text-align:right;"> 39.39% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> UTEP </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fff6f4">230.5</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdcfc8">307.7</span> </td>
   <td style="text-align:right;"> 33.49% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Cincinnati </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcb9ae">351.8</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb8372">458.5</span> </td>
   <td style="text-align:right;"> 30.33% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Old Dominion </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc2ba">332.3</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9283">427.8</span> </td>
   <td style="text-align:right;"> 28.74% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Florida </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc1b7">335.9</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9384">426.7</span> </td>
   <td style="text-align:right;"> 27.03% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> South Carolina </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc0b7">337.1</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9484">425.6</span> </td>
   <td style="text-align:right;"> 26.25% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Utah State </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fca294">397.4</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fa6f5b">497.4</span> </td>
   <td style="text-align:right;"> 25.16% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Minnesota </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdcec7">308.5</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcab9f">379.6</span> </td>
   <td style="text-align:right;"> 23.05% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Clemson </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9282">429.6</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fa614b">527.2</span> </td>
   <td style="text-align:right;"> 22.72% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Ball State </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc1b8">335.2</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9c8e">408.6</span> </td>
   <td style="text-align:right;"> 21.90% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Oregon State </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc2b9">333.8</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fc9e90">404.8</span> </td>
   <td style="text-align:right;"> 21.27% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Michigan </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdbab0">348.9</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9788">419.5</span> </td>
   <td style="text-align:right;"> 20.24% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Houston </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9283">428.2</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fa6853">512.5</span> </td>
   <td style="text-align:right;"> 19.69% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> North Carolina </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcb0a4">369.6</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb8b7b">442.1</span> </td>
   <td style="text-align:right;"> 19.62% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Nebraska </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fca89b">385.0</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb8473">456.2</span> </td>
   <td style="text-align:right;"> 18.49% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Alabama </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb8a7a">444.1</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fa634d">522.0</span> </td>
   <td style="text-align:right;"> 17.54% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Vanderbilt </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fcb9af">350.8</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fb9b8d">411.2</span> </td>
   <td style="text-align:right;"> 17.22% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Texas A&M </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fc9d8f">406.8</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fa7c6a">471.6</span> </td>
   <td style="text-align:right;"> 15.93% </td>
  </tr>
  <tr>
   <td style="text-align:right;"> Wyoming </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fedad4">286.0</span> </td>
   <td style="text-align:right;"> <span style="display: block; padding: 0 4px; border-radius: 4px; background-color: #fdc3ba">330.8</span> </td>
   <td style="text-align:right;"> 15.66% </td>
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
