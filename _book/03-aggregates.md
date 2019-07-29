# Aggregates

R is a statistical programming language that is purpose built for data analysis.

Base R does a lot, but there are a mountain of external libraries that do things to make R better/easier/more fully featured. We already installed the tidyverse -- or you should have if you followed the instructions for the last assignment -- which isn't exactly a library, but a collection of libraries. Together, they make up the tidyverse. Individually, they are extraordinarily useful for what they do. We can load them all at once using the tidyverse name, or we can load them individually. Let's start with individually. 

The two libraries we are going to need for this assignement are `readr` and `dplyr`. The library `readr` reads different types of data in. For this assignment, we're going to read in csv data or Comma Separated Values data. That's data that has a comma between each column of data. 

Then we're going to use `dplyr` to analyze it. 

To use a library, you need to import it. Good practice -- one I'm going to insist on -- is that you put all your library steps at the top of your notebooks. 

That code looks like this:


```r
library(readr)
```

To load them both, you need to run that code twice:


```r
library(readr)
library(dplyr)
```

```
## Warning: package 'dplyr' was built under R version 3.5.2
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

You can keep doing that for as many libraries as you need. I've seen notebooks with 10 or more library imports.

## Basic data analysis: Group By and Count

The first thing we need to do is get some data to work with. We do that by reading it in. In our case, we're going to read data from a csv file -- a comma-separated values file.

The CSV file we're going to read from is a [Nebraska Game and Parks Commission dataset](https://www.dropbox.com/s/2l282ril6h78w8e/mountainlions.csv?dl=0) of confirmed mountain lion sightings in Nebraska. There are, on occasion, fierce debates about mountain lions and if they should be hunted in Nebraska. This dataset can tell us some interesting things about that debate. 

So step 1 is to import the data. The code looks *something* like this, but hold off copying it just yet:

`mountainlions <- read_csv("~/Documents/Data/mountainlions.csv")`

Let's unpack that.

The first part -- mountainlions -- is the name of your variable. A variable is just a name of a thing. In this case, our variable is a data frame, which is R's way of storing data. We can call this whatever we want. I always want to name data frames after what is in it. In this case, we're going to import a dataset of mountain lion sightings from the Nebraska Game and Parks Commission. Variable names, by convention are one word all lower case. You can end a variable with a number, but you can't start one with a number.

The <- bit is the variable assignment operator. It's how we know we're assigning something to a word. Think of the arrow as saying "Take everything on the right of this arrow and stuff it into the thing on the left." So we're creating an empty vessel called mountainlions and stuffing all this data into it. 

The `read_csv` bits are pretty obvious, except for one thing. What happens in the quote marks is the path to the data. In there, I have to tell R where it will find the data. The easiest thing to do, if you are confused about how to find your data, is to put your data in the same folder as as your notebook (you'll have to save that notebook first). If you do that, then you just need to put the name of the file in there (mountainlions.csv). In my case, I've got a folder called Documents in my home directory (that's the `~` part), and in there is a folder called Data that has the file called mountainlions.csv in it. Some people -- insane people -- leave the data in their downloads folder. The data path then would be `~/Downloads/nameofthedatafilehere.csv` on PC or Mac.

**What you put in there will be different from mine**. So your first task is to import the data.


```r
mountainlions <- read_csv("https://raw.githubusercontent.com/mattwaite/SPMC350-Sports-Data-Analysis-And-Visualization/master/Data/mountainlions.csv")
```

```
## Parsed with column specification:
## cols(
##   ID = col_double(),
##   `Cofirm Type` = col_character(),
##   COUNTY = col_character(),
##   Date = col_character()
## )
```

Now we can inspect the data we imported. What does it look like? To do that, we use `head(mountainlions)` to show the headers and the first six rows of data. If we wanted to see them all, we could just simply enter `mountainlions` and run it.

To get the number of records in our dataset, we run `nrow(mountainlions)`


```r
head(mountainlions)
```

```
## # A tibble: 6 x 4
##      ID `Cofirm Type` COUNTY       Date    
##   <dbl> <chr>         <chr>        <chr>   
## 1     1 Track         Dawes        9/14/91 
## 2     2 Mortality     Sioux        11/10/91
## 3     3 Mortality     Scotts Bluff 4/21/96 
## 4     4 Mortality     Sioux        5/9/99  
## 5     5 Mortality     Box Butte    9/29/99 
## 6     6 Track         Scotts Bluff 11/12/99
```

```r
nrow(mountainlions)
```

```
## [1] 393
```

So what if we wanted to know how many mountain lion sightings there were in each county? To do that by hand, we'd have to take each of the 393 records and sort them into a pile. We'd put them in groups and then count them.

`dplyr` has a group by function in it that does just this. A massive amount of data analysis involves grouping like things together at some point. So it's a good place to start.

So to do this, we'll take our dataset and we'll introduce a new operator: %>%. The best way to read that operator, in my opinion, is to interpret that as "and then do this." Here's the code:


```r
mountainlions %>%
  group_by(COUNTY) %>%
  summarise(
    total = n()
  )
```

```
## # A tibble: 42 x 2
##    COUNTY    total
##    <chr>     <int>
##  1 Banner        6
##  2 Blaine        3
##  3 Box Butte     4
##  4 Brown        15
##  5 Buffalo       3
##  6 Cedar         1
##  7 Cherry       30
##  8 Custer        8
##  9 Dakota        3
## 10 Dawes       111
## # … with 32 more rows
```

So let's walk through that. We start with our dataset -- `mountainlions` -- and then we tell it to group the data by a given field in the data. In this case, we wanted to group together all the counties, signified by the field name COUNTY, which you could get from looking at `head(mountainlions)`. After we group the data, we need to count them up. In dplyr, we use `summarize` [which can do more than just count things](http://dplyr.tidyverse.org/reference/summarise.html). Inside the parentheses in summarize, we set up the summaries we want. In this case, we just want a count of the counties: `count = n(),` says create a new field, called `total` and set it equal to `n()`, which might look weird, but it's common in stats. The number of things in a dataset? Statisticians call in n. There are n number of incidents in this dataset. So `n()` is a function that counts the number of things there are. 

And when we run that, we get a list of counties with a count next to them. But it's not in any order. So we'll add another And Then Do This %>% and use `arrange`. Arrange does what you think it does -- it arranges data in order. By default, it's in ascending order -- smallest to largest. But if we want to know the county with the most mountain lion sightings, we need to sort it in descending order. That looks like this:


```r
mountainlions %>%
  group_by(COUNTY) %>%
  summarise(
    count = n()
  ) %>% arrange(desc(count))
```

```
## # A tibble: 42 x 2
##    COUNTY       count
##    <chr>        <int>
##  1 Dawes          111
##  2 Sioux           52
##  3 Sheridan        35
##  4 Cherry          30
##  5 Scotts Bluff    26
##  6 Keya Paha       20
##  7 Brown           15
##  8 Rock            11
##  9 Lincoln         10
## 10 Custer           8
## # … with 32 more rows
```

We can, if we want, group by more than one thing. So how are these sightings being confirmed? To do that, we can group by County and "Cofirm Type", which is how the state misspelled Confirm. But note something in this example below:


```r
mountainlions %>%
  group_by(COUNTY, `Cofirm Type`) %>%
  summarise(
    count = n()
  ) %>% arrange(desc(count))
```

```
## # A tibble: 93 x 3
## # Groups:   COUNTY [42]
##    COUNTY       `Cofirm Type`      count
##    <chr>        <chr>              <int>
##  1 Dawes        Trail Camera Photo    41
##  2 Sioux        Trail Camera Photo    40
##  3 Dawes        Track                 19
##  4 Keya Paha    Trail Camera Photo    18
##  5 Cherry       Trail Camera Photo    17
##  6 Dawes        Mortality             17
##  7 Sheridan     Trail Camera Photo    16
##  8 Dawes        Photo                 13
##  9 Dawes        DNA                   11
## 10 Scotts Bluff Trail Camera Photo    11
## # … with 83 more rows
```

See it? When you have a field name that has two words, `readr` wraps it in backticks, which is next to the 1 key on your keyboard. You can figure out which fields have backticks around it by looking at the output of `readr`. Pay attention to that, because it's coming up again in the next section and will be a part of your homework.

## Other aggregates: Mean and median

In the last example, we grouped some data together and counted it up, but there's so much more you can do. You can do multiple measures in a single step as well.

Let's look at some salary data from UNL.

```r
salaries <- read_csv("https://raw.githubusercontent.com/mattwaite/SPMC350-Sports-Data-Analysis-And-Visualization/master/Data/nusalaries1819.csv")
```

```
## Parsed with column specification:
## cols(
##   Employee = col_character(),
##   Position = col_character(),
##   Campus = col_character(),
##   Department = col_character(),
##   `Budgeted Annual Salary` = col_number(),
##   `Salary from State Aided Funds` = col_number(),
##   `Salary from Other Funds` = col_number()
## )
```

```r
head(salaries)
```

```
## # A tibble: 6 x 7
##   Employee Position Campus Department `Budgeted Annua… `Salary from St…
##   <chr>    <chr>    <chr>  <chr>                 <dbl>            <dbl>
## 1 Abbey, … Associa… UNK    Kinesiolo…            61276            61276
## 2 Abbott,… Staff S… UNL    FM&P Faci…            37318               NA
## 3 Abboud,… Adminis… UNMC   Surgery-U…            76400            76400
## 4 Abdalla… Asst Pr… UNMC   Pathology…            74774            71884
## 5 Abdelka… Post-Do… UNMC   Surgery-T…            43516               NA
## 6 Abdel-M… Researc… UNL    Public Po…            58502               NA
## # … with 1 more variable: `Salary from Other Funds` <dbl>
```

In summarize, we can calculate any number of measures. Here, we'll use R's built in mean and median functions to calculate ... well, you get the idea.


```r
salaries %>%
  summarise(
    count = n(),
    mean_salary = mean(`Budgeted Annual Salary`),
    median_salary = median(`Budgeted Annual Salary`)
  )
```

```
## # A tibble: 1 x 3
##   count mean_salary median_salary
##   <int>       <dbl>         <dbl>
## 1 13039      62065.         51343
```
So there's 13,039 employees in the database, spread across four campuses plus the system office. The mean or average salary is about \$62,000, but the median salary is slightly more than \$51,000.

Why? 

Let's let sort help us. 

```r
salaries %>% arrange(desc(`Budgeted Annual Salary`))
```

```
## # A tibble: 13,039 x 7
##    Employee Position Campus Department `Budgeted Annua… `Salary from St…
##    <chr>    <chr>    <chr>  <chr>                 <dbl>            <dbl>
##  1 Frost, … Head Co… UNL    Athletics           5000000               NA
##  2 Miles, … Head Co… UNL    Athletics           2375000               NA
##  3 Moos, W… Athleti… UNL    Athletics           1000000               NA
##  4 Gold, J… Chancel… UNMC   Office of…           853338           853338
##  5 Chinand… Assista… UNL    Athletics            800000               NA
##  6 Walters… Assista… UNL    Athletics            700000               NA
##  7 Cook, J… Head Co… UNL    Athletics            675000               NA
##  8 William… Head Co… UNL    Athletics            626750               NA
##  9 Bounds,… Preside… UNCA   Office of…           540000           540000
## 10 Austin … Assista… UNL    Athletics            475000               NA
## # … with 13,029 more rows, and 1 more variable: `Salary from Other
## #   Funds` <dbl>
```

Oh, right. In this dataset, the university pays a football coach $5 million. Extremes influence averages, not medians, and now you have your answer.  

So when choosing a measure of the middle, you have to ask yourself -- could I have extremes? Because a median won't be sensitive to extremes. It will be the point at which half the numbers are above and half are below. The average or mean will be a measure of the middle, but if you have a bunch of low paid people and then one football coach, the average will be wildly skewed. Here, because there's so few highly paid football coaches compared to people who make a normal salary, the number is only slightly skewed in the grand scheme, but skewed nonetheless. 
