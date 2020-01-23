# Intro to rvest

All the way back in Chapter 2, we used Google Sheets and importHTML to get our own data out of a website. For me, that's a lot of pointing and clicking and copying and pasting. R has a library that can automate the harvesting of data from HTML on the internet. It's called `rvest`. 

Let's grab [a simple, basic HTML table from College Football Stats](http://www.cfbstats.com/2019/leader/national/team/offense/split01/category09/sort01.html). This is scoring offense for 2019. There's nothing particularly strange about this table -- it's simply formatted and easy to scrape. 

First we'll need some libraries. We're going to use a library called `rvest`, which you can get by running `install.packages('rvest')` in the console. 


```r
library(rvest)
```

```
## Warning: package 'rvest' was built under R version 3.5.2
```

```
## Loading required package: xml2
```

```
## Warning: package 'xml2' was built under R version 3.5.2
```

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
## x dplyr::filter()         masks stats::filter()
## x readr::guess_encoding() masks rvest::guess_encoding()
## x dplyr::lag()            masks stats::lag()
## x purrr::pluck()          masks rvest::pluck()
```

The rvest package has functions that make fetching, reading and parsing HTML simple. The first thing we need to do is specify a url that we're going to scrape.


```r
scoringoffenseurl <- "http://www.cfbstats.com/2019/leader/national/team/offense/split01/category09/sort01.html"
```

Now, the most difficult part of scraping data from any website is knowing what exact HTML tag you need to grab. In this case, we want a `<table>` tag that has all of our data table in it. But how do you tell R which one that is? Well, it's easy, once you know what to do. But it's not simple. So I've made a short video to show you how to find it. 

<iframe width="560" height="315" src="https://www.youtube.com/embed/kYkSE3zWa9Y" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

When you have simple tables, the code is very simple. You create a variable to receive the data, then pass it the url, read the html that was fetched, find the node you need using your XPath value you just copied and you tell rvest that it's a table. 


```r
scoringoffense <- scoringoffenseurl %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="content"]/div[2]/table') %>%
  html_table()
```

What we get from this is ... not a dataframe. It's a list with one element in it, which just so happens to be our dataframe. When you get this, the solution is simple: just overwrite the variable you created with the first list element.


```r
scoringoffense <- scoringoffense[[1]]
```

And what do we have? 


```r
head(scoringoffense)
```

```
##           Name  G TD FG 1XP 2XP Safety Points Points/G
## 1 1        LSU 15 95 21  89   1      1    726     48.4
## 2 2    Alabama 13 83 12  80   0      0    614     47.2
## 3 3 Ohio State 14 88 13  87   0      1    656     46.9
## 4 4    Clemson 15 88 14  85   2      0    659     43.9
## 5 5        UCF 13 74 15  71   1      1    564     43.4
## 6 6   Oklahoma 14 76 19  75   1      0    590     42.1
```

We have data, ready for analysis. 

## A slightly more complicated example

What if we want more than one year in our dataframe?

This is a common problem. What if we want to look at every scoring offense going back several years? The website has them going back to 2009. How can we combine them? 

First, we should note, that the data does not have anything in it to indicate what year it comes from. So we're going to have to add that. And we're going to have to figure out a way to stack two dataframes on top of each other. 

So let's grab 2018.


```r
scoringoffenseurl18 <- "http://www.cfbstats.com/2018/leader/national/team/offense/split01/category09/sort01.html"

scoringoffense18 <- scoringoffenseurl18 %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="content"]/div[2]/table') %>%
  html_table()

scoringoffense18 <- scoringoffense18[[1]]
```

First, how are we going to know, in the data, which year our data is from? We can use mutate.


```r
scoringoffense19 <- scoringoffense %>% mutate(YEAR = 2019)
```

```
## Error: Column 1 must be named.
## Use .name_repair to specify repair.
```

Uh oh. Error. What does it say? Column 1 must be named. If you look at our data in the environment tab in the upper right corner, you'll see that indeed, the first column has no name. It's the FBS rank of each team. So we can fix that and mutate in the same step. We'll do that using `rename` and since the field doesn't have a name to rename it, we'll use a position argument. We'll say rename column 1 as Rank. 


```r
scoringoffense19 <- scoringoffense %>% rename(Rank = 1) %>% mutate(YEAR = 2019)
scoringoffense18 <- scoringoffense18 %>% rename(Rank = 1) %>% mutate(YEAR = 2018)
```

And now, to combine the two tables together length-wise -- we need to make long data -- we'll use a base R function called `rbind`. The good thing is rbind is simple. The bad part is it can only do two tables at a time, so if you have more than that, you'll need to do it in steps.


```r
combined <- rbind(scoringoffense19, scoringoffense18)
```

Note in the environment tab we now have a data frame called combined that has 260 observations -- which just so happens to be what 130 from 2019 and 130 from 2018 add up to. 


```r
head(combined)
```

```
##   Rank       Name  G TD FG 1XP 2XP Safety Points Points/G YEAR
## 1    1        LSU 15 95 21  89   1      1    726     48.4 2019
## 2    2    Alabama 13 83 12  80   0      0    614     47.2 2019
## 3    3 Ohio State 14 88 13  87   0      1    656     46.9 2019
## 4    4    Clemson 15 88 14  85   2      0    659     43.9 2019
## 5    5        UCF 13 74 15  71   1      1    564     43.4 2019
## 6    6   Oklahoma 14 76 19  75   1      0    590     42.1 2019
```

## An even more complicated example

What do you do when the table has non-standard headers? 

Unfortunately, non-standard means there's no one way to do it -- it's going to depend on the table and the headers. But here's one idea: Don't try to make it work. 

I'll explain.

Let's try to get [season team stats from Sports Reference](https://www.sports-reference.com/cbb/seasons/2019-school-stats.html). If you look at that page, you'll see the problem right away -- the headers span two rows, and they repeat. That's going to be all kinds of no good. You can't import that. Dataframes must have names all in one row. If you have two-line headers, you have a problem you have to fix before you can do anything else with it.

First we'll grab the page.

```r
url <- "https://www.sports-reference.com/cbb/seasons/2019-school-stats.html"
```

Now, similar to our example above, we'll read the html, use XPath to find the table, and then read that table with a directive passed to it setting the header to FALSE. That tells rvest that there isn't a header row. Just import it as data. 


```r
stats <- url %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="basic_school_stats"]') %>%
  html_table(header=FALSE)
```

What we get back is a list of one element (similar to above). So let's pop it out into a data frame.


```r
stats <- stats[[1]]
```

And we'll take a look at what we have. 


```r
head(stats)
```

```
##   X1                     X2      X3      X4      X5      X6      X7      X8
## 1                           Overall Overall Overall Overall Overall Overall
## 2 Rk                 School       G       W       L    W-L%     SRS     SOS
## 3  1 Abilene Christian NCAA      34      27       7    .794   -1.91   -7.34
## 4  2              Air Force      32      14      18    .438   -4.28    0.24
## 5  3                  Akron      33      17      16    .515    4.86    1.09
## 6  4            Alabama A&M      32       5      27    .156  -19.23   -8.38
##      X9   X10  X11  X12  X13  X14    X15    X16 X17           X18           X19
## 1 Conf. Conf. Home Home Away Away Points Points  NA School Totals School Totals
## 2     W     L    W    L    W    L    Tm.   Opp.  NA            MP            FG
## 3    14     4   13    2   10    4   2502   2161  NA          1370           897
## 4     8    10    9    6    3    9   2179   2294  NA          1300           802
## 5     8    10   14    3    1   10   2271   2107  NA          1325           797
## 6     4    14    4    7    0   18   1938   2285  NA          1295           736
##             X20           X21           X22           X23           X24
## 1 School Totals School Totals School Totals School Totals School Totals
## 2           FGA           FG%            3P           3PA           3P%
## 3          1911          .469           251           660          .380
## 4          1776          .452           234           711          .329
## 5          1948          .409           297           929          .320
## 6          1809          .407           182           578          .315
##             X25           X26           X27           X28           X29
## 1 School Totals School Totals School Totals School Totals School Totals
## 2            FT           FTA           FT%           ORB           TRB
## 3           457           642          .712           325          1110
## 4           341           503          .678           253          1077
## 5           380           539          .705           312          1204
## 6           284           453          .627           314          1032
##             X30           X31           X32           X33           X34
## 1 School Totals School Totals School Totals School Totals School Totals
## 2           AST           STL           BLK           TOV            PF
## 3           525           297            93           407           635
## 4           434           154            57           423           543
## 5           399           185           106           388           569
## 6           385           234            50           487           587
```

So, that's not ideal. We have headers and data mixed together, and our columns are named X1 to X34. Also note: They're all character fields. Because the headers are interspersed with data, it all gets called character data. So we've got to first rename each field. 


```r
stats <- stats %>% rename(Rank=X1, School=X2, Games=X3, OverallWins=X4, OverallLosses=X5, WinPct=X6, OverallSRS=X7, OverallSOS=X8, ConferenceWins=X9, ConferenceLosses=X10, HomeWins=X11, HomeLosses=X12, AwayWins=X13, AwayLosses=X14, ForPoints=X15, OppPoints=X16, Blank=X17, Minutes=X18, FieldGoalsMade=X19, FieldGoalsAttempted=X20, FieldGoalPCT=X21, ThreePointMade=X22, ThreePointAttempts=X23, ThreePointPct=X24, FreeThrowsMade=X25, FreeThrowsAttempted=X26, FreeThrowPCT=X27, OffensiveRebounds=X28, TotalRebounds=X29, Assists=X30, Steals=X31, Blocks=X32, Turnovers=X33, PersonalFouls=X34)
```

Now we have to get rid of those headers interspersed in the data. We can do that with filter that say keep all the stuff that isn't this.


```r
stats <- stats %>% filter(Rank != "Rk" & Games != "Overall") 
```

And finally, we need to change the file type of all the fields that need it. We're going to use a clever little trick, which goes like this: We're going to use `mutate_at`, which means mutate these fields. The pattern for `mutate_at` is `mutate_at` these variables and do this thing to them. But instead of specifying which of 33 variables we're going to mutate, we're going to specify the one we don't want to change, which is the name of the school. And we just want to convert them to numeric. Here's what it looks like:


```r
stats %>% mutate_at(vars(-School), as.numeric)
```

```
##     Rank                      School Games OverallWins OverallLosses WinPct
## 1      1      Abilene Christian NCAA    34          27             7  0.794
## 2      2                   Air Force    32          14            18  0.438
## 3      3                       Akron    33          17            16  0.515
## 4      4                 Alabama A&M    32           5            27  0.156
## 5      5          Alabama-Birmingham    35          20            15  0.571
## 6      6               Alabama State    31          12            19  0.387
## 7      7                     Alabama    34          18            16  0.529
## 8      8                 Albany (NY)    32          12            20  0.375
## 9      9                Alcorn State    31          10            21  0.323
## 10    10                    American    30          15            15  0.500
## 11    11           Appalachian State    32          11            21  0.344
## 12    12          Arizona State NCAA    34          23            11  0.676
## 13    13                     Arizona    32          17            15  0.531
## 14    14                 Little Rock    31          10            21  0.323
## 15    15         Arkansas-Pine Bluff    32          13            19  0.406
## 16    16              Arkansas State    32          13            19  0.406
## 17    17                    Arkansas    34          18            16  0.529
## 18    18                        Army    32          13            19  0.406
## 19    19                 Auburn NCAA    40          30            10  0.750
## 20    20                 Austin Peay    33          22            11  0.667
## 21    21                  Ball State    33          16            17  0.485
## 22    22                 Baylor NCAA    34          20            14  0.588
## 23    23                Belmont NCAA    33          27             6  0.818
## 24    24             Bethune-Cookman    31          14            17  0.452
## 25    25                  Binghamton    33          10            23  0.303
## 26    26                 Boise State    33          13            20  0.394
## 27    27              Boston College    31          14            17  0.452
## 28    28           Boston University    33          15            18  0.455
## 29    29         Bowling Green State    34          22            12  0.647
## 30    30                Bradley NCAA    35          20            15  0.571
## 31    31               Brigham Young    32          19            13  0.594
## 32    32                       Brown    32          20            12  0.625
## 33    33                      Bryant    30          10            20  0.333
## 34    34                    Bucknell    33          21            12  0.636
## 35    35                Buffalo NCAA    36          32             4  0.889
## 36    36                      Butler    33          16            17  0.485
## 37    37                    Cal Poly    29           6            23  0.207
## 38    38       Cal State Bakersfield    34          18            16  0.529
## 39    39         Cal State Fullerton    34          16            18  0.471
## 40    40        Cal State Northridge    34          13            21  0.382
## 41    41          California Baptist    31          16            15  0.516
## 42    42                    UC-Davis    31          11            20  0.355
## 43    43              UC-Irvine NCAA    37          31             6  0.838
## 44    44                UC-Riverside    33          10            23  0.303
## 45    45            UC-Santa Barbara    32          22            10  0.688
## 46    46    University of California    31           8            23  0.258
## 47    47                    Campbell    33          20            13  0.606
## 48    48                    Canisius    32          15            17  0.469
## 49    49            Central Arkansas    33          14            19  0.424
## 50    50   Central Connecticut State    31          11            20  0.355
## 51    51        Central Florida NCAA    33          24             9  0.727
## 52    52            Central Michigan    35          23            12  0.657
## 53    53         Charleston Southern    34          18            16  0.529
## 54    54                   Charlotte    29           8            21  0.276
## 55    55                 Chattanooga    32          12            20  0.375
## 56    56               Chicago State    32           3            29  0.094
## 57    57             Cincinnati NCAA    35          28             7  0.800
## 58    58                     Citadel    30          12            18  0.400
## 59    59                     Clemson    34          20            14  0.588
## 60    60             Cleveland State    31          10            21  0.323
## 61    61            Coastal Carolina    34          17            17  0.500
## 62    62                Colgate NCAA    35          24            11  0.686
## 63    63       College of Charleston    33          24             9  0.727
## 64    64              Colorado State    32          12            20  0.375
## 65    65                    Colorado    36          23            13  0.639
## 66    66                    Columbia    28          10            18  0.357
## 67    67                 Connecticut    33          16            17  0.485
## 68    68                Coppin State    33           8            25  0.242
## 69    69                     Cornell    31          15            16  0.484
## 70    70                   Creighton    35          20            15  0.571
## 71    71                   Dartmouth    30          11            19  0.367
## 72    72                    Davidson    34          24            10  0.706
## 73    73                      Dayton    33          21            12  0.636
## 74    74              Delaware State    31           6            25  0.194
## 75    75                    Delaware    33          17            16  0.515
## 76    76                      Denver    30           8            22  0.267
## 77    77                      DePaul    36          19            17  0.528
## 78    78               Detroit Mercy    31          11            20  0.355
## 79    79                       Drake    34          24            10  0.706
## 80    80                      Drexel    32          13            19  0.406
## 81    81                   Duke NCAA    38          32             6  0.842
## 82    82                    Duquesne    32          19            13  0.594
## 83    83               East Carolina    31          10            21  0.323
## 84    84        East Tennessee State    34          24            10  0.706
## 85    85            Eastern Illinois    32          14            18  0.438
## 86    86            Eastern Kentucky    31          13            18  0.419
## 87    87            Eastern Michigan    32          15            17  0.469
## 88    88          Eastern Washington    34          16            18  0.471
## 89    89                        Elon    32          11            21  0.344
## 90    90                  Evansville    32          11            21  0.344
## 91    91                   Fairfield    31           9            22  0.290
## 92    92    Fairleigh Dickinson NCAA    35          21            14  0.600
## 93    93                 Florida A&M    31          12            19  0.387
## 94    94            Florida Atlantic    33          17            16  0.515
## 95    95          Florida Gulf Coast    32          14            18  0.438
## 96    96       Florida International    34          20            14  0.588
## 97    97          Florida State NCAA    37          29             8  0.784
## 98    98                Florida NCAA    36          20            16  0.556
## 99    99                     Fordham    32          12            20  0.375
## 100  100                Fresno State    32          23             9  0.719
## 101  101                      Furman    33          25             8  0.758
## 102  102           Gardner-Webb NCAA    35          23            12  0.657
## 103  103                George Mason    33          18            15  0.545
## 104  104           George Washington    33           9            24  0.273
## 105  105                  Georgetown    33          19            14  0.576
## 106  106            Georgia Southern    33          21            12  0.636
## 107  107          Georgia State NCAA    34          24            10  0.706
## 108  108                Georgia Tech    32          14            18  0.438
## 109  109                     Georgia    32          11            21  0.344
## 110  110                Gonzaga NCAA    37          33             4  0.892
## 111  111                   Grambling    34          17            17  0.500
## 112  112                Grand Canyon    34          20            14  0.588
## 113  113                   Green Bay    38          21            17  0.553
## 114  114                     Hampton    35          18            17  0.514
## 115  115                    Hartford    33          18            15  0.545
## 116  116                     Harvard    31          19            12  0.613
## 117  117                      Hawaii    31          18            13  0.581
## 118  118                  High Point    31          16            15  0.516
## 119  119                     Hofstra    35          27             8  0.771
## 120  120                  Holy Cross    33          16            17  0.485
## 121  121             Houston Baptist    30          12            18  0.400
## 122  122                Houston NCAA    37          33             4  0.892
## 123  123                      Howard    34          17            17  0.500
## 124  124                 Idaho State    30          11            19  0.367
## 125  125                       Idaho    32           5            27  0.156
## 126  126            Illinois-Chicago    32          16            16  0.500
## 127  127              Illinois State    33          17            16  0.515
## 128  128                    Illinois    33          12            21  0.364
## 129  129              Incarnate Word    31           6            25  0.194
## 130  130               Indiana State    31          15            16  0.484
## 131  131                     Indiana    35          19            16  0.543
## 132  132                   Iona NCAA    33          17            16  0.515
## 133  133             Iowa State NCAA    35          23            12  0.657
## 134  134                   Iowa NCAA    35          23            12  0.657
## 135  135           Purdue-Fort Wayne    33          18            15  0.545
## 136  136                       IUPUI    33          16            17  0.485
## 137  137               Jackson State    32          13            19  0.406
## 138  138          Jacksonville State    33          24             9  0.727
## 139  139                Jacksonville    32          12            20  0.375
## 140  140               James Madison    33          14            19  0.424
## 141  141           Kansas State NCAA    34          25             9  0.735
## 142  142                 Kansas NCAA    36          26            10  0.722
## 143  143              Kennesaw State    32           6            26  0.188
## 144  144                  Kent State    33          22            11  0.667
## 145  145               Kentucky NCAA    37          30             7  0.811
## 146  146                    La Salle    31          10            21  0.323
## 147  147                   Lafayette    30          10            20  0.333
## 148  148                       Lamar    33          20            13  0.606
## 149  149                      Lehigh    31          20            11  0.645
## 150  150                Liberty NCAA    36          29             7  0.806
## 151  151                    Lipscomb    37          29             8  0.784
## 152  152        Cal State Long Beach    34          15            19  0.441
## 153  153      Long Island University    32          16            16  0.500
## 154  154                    Longwood    34          16            18  0.471
## 155  155                   Louisiana    32          19            13  0.594
## 156  156            Louisiana-Monroe    35          19            16  0.543
## 157  157        Louisiana State NCAA    35          28             7  0.800
## 158  158              Louisiana Tech    33          20            13  0.606
## 159  159             Louisville NCAA    34          20            14  0.588
## 160  160                 Loyola (IL)    34          20            14  0.588
## 161  161            Loyola Marymount    34          22            12  0.647
## 162  162                 Loyola (MD)    32          11            21  0.344
## 163  163                       Maine    32           5            27  0.156
## 164  164                   Manhattan    32          11            21  0.344
## 165  165                      Marist    31          12            19  0.387
## 166  166              Marquette NCAA    34          24            10  0.706
## 167  167                    Marshall    37          23            14  0.622
## 168  168   Maryland-Baltimore County    34          21            13  0.618
## 169  169      Maryland-Eastern Shore    32           7            25  0.219
## 170  170               Maryland NCAA    34          23            11  0.676
## 171  171        Massachusetts-Lowell    32          15            17  0.469
## 172  172               Massachusetts    32          11            21  0.344
## 173  173               McNeese State    31           9            22  0.290
## 174  174                     Memphis    36          22            14  0.611
## 175  175                      Mercer    31          11            20  0.355
## 176  176                  Miami (FL)    32          14            18  0.438
## 177  177                  Miami (OH)    32          15            17  0.469
## 178  178         Michigan State NCAA    39          32             7  0.821
## 179  179               Michigan NCAA    37          30             7  0.811
## 180  180            Middle Tennessee    32          11            21  0.344
## 181  181                   Milwaukee    31           9            22  0.290
## 182  182              Minnesota NCAA    36          22            14  0.611
## 183  183      Mississippi State NCAA    34          23            11  0.676
## 184  184    Mississippi Valley State    32           6            26  0.188
## 185  185            Mississippi NCAA    33          20            13  0.606
## 186  186        Missouri-Kansas City    32          11            21  0.344
## 187  187              Missouri State    32          16            16  0.500
## 188  188                    Missouri    32          15            17  0.469
## 189  189                    Monmouth    35          14            21  0.400
## 190  190               Montana State    32          15            17  0.469
## 191  191                Montana NCAA    35          26             9  0.743
## 192  192              Morehead State    33          13            20  0.394
## 193  193                Morgan State    30           9            21  0.300
## 194  194            Mount St. Mary's    31           9            22  0.290
## 195  195           Murray State NCAA    33          28             5  0.848
## 196  196                        Navy    31          12            19  0.387
## 197  197                       Omaha    32          21            11  0.656
## 198  198                    Nebraska    36          19            17  0.528
## 199  199            Nevada-Las Vegas    31          17            14  0.548
## 200  200                 Nevada NCAA    34          29             5  0.853
## 201  201               New Hampshire    29           5            24  0.172
## 202  202       New Mexico State NCAA    35          30             5  0.857
## 203  203                  New Mexico    32          14            18  0.438
## 204  204                 New Orleans    33          19            14  0.576
## 205  205                     Niagara    32          13            19  0.406
## 206  206              Nicholls State    31          14            17  0.452
## 207  207                        NJIT    35          22            13  0.629
## 208  208               Norfolk State    36          22            14  0.611
## 209  209               North Alabama    32          10            22  0.313
## 210  210    North Carolina-Asheville    31           4            27  0.129
## 211  211          North Carolina A&T    32          19            13  0.594
## 212  212 North Carolina Central NCAA    34          18            16  0.529
## 213  213   North Carolina-Greensboro    36          29             7  0.806
## 214  214        North Carolina State    36          24            12  0.667
## 215  215   North Carolina-Wilmington    33          10            23  0.303
## 216  216         North Carolina NCAA    36          29             7  0.806
## 217  217     North Dakota State NCAA    35          19            16  0.543
## 218  218                North Dakota    30          12            18  0.400
## 219  219               North Florida    33          16            17  0.485
## 220  220                 North Texas    33          21            12  0.636
## 221  221           Northeastern NCAA    34          23            11  0.676
## 222  222            Northern Arizona    31          10            21  0.323
## 223  223           Northern Colorado    32          21            11  0.656
## 224  224           Northern Illinois    34          17            17  0.500
## 225  225               Northern Iowa    34          16            18  0.471
## 226  226      Northern Kentucky NCAA    35          26             9  0.743
## 227  227          Northwestern State    31          11            20  0.355
## 228  228                Northwestern    32          13            19  0.406
## 229  229                  Notre Dame    33          14            19  0.424
## 230  230                     Oakland    33          16            17  0.485
## 231  231             Ohio State NCAA    35          20            15  0.571
## 232  232                        Ohio    31          14            17  0.452
## 233  233              Oklahoma State    32          12            20  0.375
## 234  234               Oklahoma NCAA    34          20            14  0.588
## 235  235           Old Dominion NCAA    35          26             9  0.743
## 236  236                Oral Roberts    32          11            21  0.344
## 237  237                Oregon State    31          18            13  0.581
## 238  238                 Oregon NCAA    38          25            13  0.658
## 239  239                     Pacific    32          14            18  0.438
## 240  240                  Penn State    32          14            18  0.438
## 241  241                Pennsylvania    31          19            12  0.613
## 242  242                  Pepperdine    34          16            18  0.471
## 243  243                  Pittsburgh    33          14            19  0.424
## 244  244              Portland State    32          16            16  0.500
## 245  245                    Portland    32           7            25  0.219
## 246  246           Prairie View NCAA    35          22            13  0.629
## 247  247                Presbyterian    36          20            16  0.556
## 248  248                   Princeton    28          16            12  0.571
## 249  249                  Providence    34          18            16  0.529
## 250  250                 Purdue NCAA    36          26            10  0.722
## 251  251                  Quinnipiac    31          16            15  0.516
## 252  252                     Radford    33          22            11  0.667
## 253  253                Rhode Island    33          18            15  0.545
## 254  254                        Rice    32          13            19  0.406
## 255  255                    Richmond    33          13            20  0.394
## 256  256                       Rider    31          16            15  0.516
## 257  257               Robert Morris    35          18            17  0.514
## 258  258                     Rutgers    31          14            17  0.452
## 259  259            Sacramento State    31          15            16  0.484
## 260  260                Sacred Heart    32          15            17  0.469
## 261  261          Saint Francis (PA)    33          18            15  0.545
## 262  262              Saint Joseph's    33          14            19  0.424
## 263  263            Saint Louis NCAA    36          23            13  0.639
## 264  264      Saint Mary's (CA) NCAA    34          22            12  0.647
## 265  265               Saint Peter's    32          10            22  0.313
## 266  266           Sam Houston State    33          21            12  0.636
## 267  267                     Samford    33          17            16  0.515
## 268  268             San Diego State    34          21            13  0.618
## 269  269                   San Diego    36          21            15  0.583
## 270  270               San Francisco    31          21            10  0.677
## 271  271              San Jose State    31           4            27  0.129
## 272  272                 Santa Clara    31          16            15  0.516
## 273  273              Savannah State    31          11            20  0.355
## 274  274                     Seattle    33          18            15  0.545
## 275  275             Seton Hall NCAA    34          20            14  0.588
## 276  276                       Siena    33          17            16  0.515
## 277  277               South Alabama    34          17            17  0.500
## 278  278        South Carolina State    34           8            26  0.235
## 279  279      South Carolina Upstate    32           6            26  0.188
## 280  280              South Carolina    32          16            16  0.500
## 281  281          South Dakota State    33          24             9  0.727
## 282  282                South Dakota    30          13            17  0.433
## 283  283               South Florida    38          24            14  0.632
## 284  284    Southeast Missouri State    31          10            21  0.323
## 285  285      Southeastern Louisiana    33          17            16  0.515
## 286  286         Southern California    33          16            17  0.485
## 287  287            SIU Edwardsville    31          10            21  0.323
## 288  288           Southern Illinois    32          17            15  0.531
## 289  289          Southern Methodist    32          15            17  0.469
## 290  290        Southern Mississippi    33          20            13  0.606
## 291  291               Southern Utah    34          17            17  0.500
## 292  292                    Southern    32           7            25  0.219
## 293  293             St. Bonaventure    34          18            16  0.529
## 294  294            St. Francis (NY)    33          17            16  0.515
## 295  295        St. John's (NY) NCAA    34          21            13  0.618
## 296  296                    Stanford    31          15            16  0.484
## 297  297           Stephen F. Austin    30          14            16  0.467
## 298  298                     Stetson    31           7            24  0.226
## 299  299                 Stony Brook    33          24             9  0.727
## 300  300               Syracuse NCAA    34          20            14  0.588
## 301  301                 Temple NCAA    33          23            10  0.697
## 302  302            Tennessee-Martin    31          12            19  0.387
## 303  303             Tennessee State    30           9            21  0.300
## 304  304              Tennessee Tech    31           8            23  0.258
## 305  305              Tennessee NCAA    37          31             6  0.838
## 306  306    Texas A&M-Corpus Christi    32          14            18  0.438
## 307  307                   Texas A&M    32          14            18  0.438
## 308  308             Texas-Arlington    33          17            16  0.515
## 309  309             Texas Christian    37          23            14  0.622
## 310  310               Texas-El Paso    29           8            21  0.276
## 311  311     Texas-Rio Grande Valley    37          20            17  0.541
## 312  312           Texas-San Antonio    32          17            15  0.531
## 313  313              Texas Southern    38          24            14  0.632
## 314  314                 Texas State    34          24            10  0.706
## 315  315             Texas Tech NCAA    38          31             7  0.816
## 316  316                       Texas    37          21            16  0.568
## 317  317                      Toledo    33          25             8  0.758
## 318  318                      Towson    32          10            22  0.313
## 319  319                        Troy    30          12            18  0.400
## 320  320                      Tulane    31           4            27  0.129
## 321  321                       Tulsa    32          18            14  0.563
## 322  322                        UCLA    33          17            16  0.515
## 323  323             Utah State NCAA    35          28             7  0.800
## 324  324                 Utah Valley    35          25            10  0.714
## 325  325                        Utah    31          17            14  0.548
## 326  326                  Valparaiso    33          15            18  0.455
## 327  327                  Vanderbilt    32           9            23  0.281
## 328  328                Vermont NCAA    34          27             7  0.794
## 329  329              Villanova NCAA    36          26            10  0.722
## 330  330  Virginia Commonwealth NCAA    33          25             8  0.758
## 331  331                         VMI    32          11            21  0.344
## 332  332          Virginia Tech NCAA    35          26             9  0.743
## 333  333               Virginia NCAA    38          35             3  0.921
## 334  334                      Wagner    30          13            17  0.433
## 335  335                 Wake Forest    31          11            20  0.355
## 336  336            Washington State    32          11            21  0.344
## 337  337             Washington NCAA    36          27             9  0.750
## 338  338                 Weber State    33          18            15  0.545
## 339  339               West Virginia    36          15            21  0.417
## 340  340            Western Carolina    32           7            25  0.219
## 341  341            Western Illinois    31          10            21  0.323
## 342  342            Western Kentucky    34          20            14  0.588
## 343  343            Western Michigan    32           8            24  0.250
## 344  344               Wichita State    37          22            15  0.595
## 345  345              William & Mary    31          14            17  0.452
## 346  346                    Winthrop    30          18            12  0.600
## 347  347              Wisconsin NCAA    34          23            11  0.676
## 348  348                Wofford NCAA    35          30             5  0.857
## 349  349                Wright State    35          21            14  0.600
## 350  350                     Wyoming    32           8            24  0.250
## 351  351                      Xavier    35          19            16  0.543
## 352  352                   Yale NCAA    30          22             8  0.733
## 353  353            Youngstown State    32          12            20  0.375
##     OverallSRS OverallSOS ConferenceWins ConferenceLosses HomeWins HomeLosses
## 1        -1.91      -7.34             14                4       13          2
## 2        -4.28       0.24              8               10        9          6
## 3         4.86       1.09              8               10       14          3
## 4       -19.23      -8.38              4               14        4          7
## 5         0.36      -1.52             10                8       11          5
## 6       -15.60      -7.84              9                9        8          3
## 7         9.45       9.01              8               10       10          6
## 8        -9.38      -6.70              7                9        6          8
## 9       -22.08      -8.97              6               12       10          3
## 10       -4.19      -7.23              9                9        8          7
## 11       -3.73       0.10              6               12        9          5
## 12       10.28       6.04             12                6       13          3
## 13        8.32       6.32              8               10       12          5
## 14       -4.87      -2.07              5               13        7          9
## 15      -14.43      -8.18             10                8        8          2
## 16       -7.10      -1.23              7               11       10          4
## 17       11.75       8.78              8               10       12          6
## 18       -7.57      -4.73              8               10       10          4
## 19       20.84      10.92             11                7       15          2
## 20        0.59      -4.41             13                5       10          2
## 21        3.39       1.21              6               12        7          7
## 22       13.38       9.26             10                8       13          5
## 23        9.12      -2.60             16                2       13          1
## 24      -11.98      -9.74              9                7       11          4
## 25      -13.92      -4.69              5               11        5         11
## 26        3.61       1.08              7               11        8          7
## 27        5.83       7.76              5               13       10          8
## 28       -6.61      -5.39              7               11        7          7
## 29        4.24       0.86             12                6       14          2
## 30       -0.08      -0.90              9                9       10          6
## 31        6.15       3.31             11                5       13          3
## 32       -0.62      -3.29              7                7       13          3
## 33      -15.19      -7.66              7               11        8          6
## 34        0.59      -2.93             13                5       12          3
## 35       15.56       2.62             16                2       14          0
## 36        9.22       8.10              7               11       12          4
## 37      -13.95      -3.54              2               14        4          8
## 38       -5.12      -2.63              7                9        9          4
## 39       -3.29      -1.14             10                6        9          4
## 40       -6.54      -3.39              7                9        7          9
## 41       -3.89      -4.12              7                9        8          7
## 42       -6.26      -1.50              7                9        7          6
## 43        5.70      -2.30             15                1       12          2
## 44      -11.12      -3.19              4               12        7          7
## 45       -1.62      -5.55             10                6       12          3
## 46       -3.16       5.42              3               15        7          9
## 47       -3.62      -4.39             12                4       12          4
## 48       -8.79      -4.85             11                7        5          8
## 49      -11.37      -4.81              8               10        8          5
## 50      -14.02      -6.71              5               13        5          7
## 51       13.37       5.58             13                5       15          2
## 52        2.79      -0.34             10                8       13          4
## 53       -2.43      -4.19              9                7       12          4
## 54       -8.34      -0.89              5               13        5          9
## 55       -7.87      -0.76              7               11        8          6
## 56      -24.83       0.67              0               16        3          8
## 57       14.53       5.50             14                4       16          2
## 58       -7.94       0.03              4               14        8          7
## 59       13.85       8.99              9                9       14          5
## 60       -7.96      -1.52              5               13        8          9
## 61       -0.50      -1.94              9                9       10          4
## 62        1.23      -3.83             13                5       15          1
## 63        2.36      -2.95             12                6       13          2
## 64       -0.11       1.41              7               11        8          9
## 65        9.68       3.60             10                8       15          2
## 66       -5.18      -2.14              5                9        5          7
## 67        6.81       4.32              6               12       13          5
## 68      -18.90      -7.11              7                9        3          7
## 69       -6.12      -2.02              7                7        9          4
## 70       12.00       8.59              9                9       13          6
## 71       -5.75      -3.00              2               12        8          6
## 72        6.38       1.96             14                4       14          2
## 73        9.67       2.91             13                5       13          4
## 74      -26.82     -10.13              2               14        3          9
## 75       -7.91      -4.82              8               10        9          7
## 76      -11.84      -2.97              3               13        6          7
## 77        6.00       4.05              7               11       16          7
## 78       -6.33      -0.36              8               10        6          6
## 79        2.52      -0.66             12                6       13          2
## 80       -7.02      -2.93              7               11        9          7
## 81       26.90      11.98             14                4       15          2
## 82        0.53      -0.63             10                8       14          4
## 83       -5.49       1.31              3               15        8          9
## 84        5.21      -1.79             13                5       13          3
## 85      -11.81      -5.01              7               11        7          6
## 86       -7.40      -2.47              6               12        9          5
## 87        0.40       4.43              9                9       11          7
## 88       -6.77      -4.17             12                8        9          4
## 89      -11.53      -3.56              7               11        5         11
## 90       -3.84       0.13              5               13        9          7
## 91      -10.20      -7.14              6               12        5          7
## 92       -6.09      -7.24             12                6       13          4
## 93      -13.57      -8.09              9                7        6          3
## 94       -1.42      -1.76              8               10        9          5
## 95       -5.11      -1.48              9                7       10          4
## 96       -4.55      -1.45             10                8       12          4
## 97       17.99      10.26             13                5       15          1
## 98       15.42      11.22              9                9        9          6
## 99       -5.02      -2.40              3               15        9         10
## 100       8.99       0.67             13                5       13          4
## 101       7.46      -1.50             13                5       13          3
## 102      -2.61      -4.43             11                6       13          0
## 103       0.84       0.08             11                7       11          6
## 104      -6.65       1.20              4               14        6         11
## 105       6.80       5.31              9                9       13          6
## 106       3.75       0.13             12                6       10          4
## 107       2.44       0.65             13                5       13          1
## 108       6.93       8.15              6               12       11          7
## 109       5.31       8.12              2               16        8          9
## 110      27.79       5.01             16                0       17          0
## 111      -9.73      -9.34             10                8       11          3
## 112       3.85      -1.49             10                6       12          2
## 113      -2.24      -0.36             10                8       15          3
## 114      -3.34      -5.06              9                7       12          3
## 115      -3.95      -4.89             10                6       10          4
## 116       1.86       0.66             10                4        9          2
## 117      -1.30      -3.61              9                7       12          5
## 118      -5.63      -4.39              9                7        9          4
## 119       4.68      -4.53             15                3       15          1
## 120      -6.43      -4.01              6               12        8          6
## 121      -9.36      -5.53              8               10        9          4
## 122      18.91       4.61             16                2       19          1
## 123     -12.30      -9.52             10                6        6          8
## 124     -13.17      -4.81              7               13        6          7
## 125     -18.74      -6.19              2               18        4         11
## 126      -3.15      -1.99             10                8       12          4
## 127      -2.06       0.25              9                9       12          4
## 128       8.95      11.53              7               13        9          6
## 129     -18.93      -5.11              1               17        5          9
## 130      -2.72       0.62              7               11        9          5
## 131      13.82      10.10              8               12       15          6
## 132      -4.78      -5.50             12                6        8          3
## 133      18.07       9.30              9                9       12          4
## 134      14.27       9.84             10               10       14          4
## 135      -3.47      -3.60              9                7       11          5
## 136      -2.72      -3.04              8               10       11          4
## 137     -14.60      -9.33             10                8        9          4
## 138       1.59      -5.47             15                3       11          1
## 139      -8.27      -4.74              5               11        5          8
## 140      -8.52      -4.07              6               12        8          6
## 141      15.39       9.18             14                4       13          2
## 142      18.35      12.79             12                6       16          0
## 143     -16.17      -1.04              3               13        6          8
## 144       1.26       0.61             11                7       14          3
## 145      21.43      10.29             15                3       17          1
## 146      -3.61       1.29              8               10        5          9
## 147     -11.17      -4.93              7               11        4         11
## 148      -5.94      -7.22             12                6       13          2
## 149      -2.34      -4.46             12                6       11          3
## 150       5.27      -3.88             14                2       16          1
## 151       9.21      -1.20             14                2       14          3
## 152      -4.57      -0.44              8                8        9          5
## 153      -8.99      -9.08              9                9        8          5
## 154      -8.43      -6.62              5               11       10          5
## 155      -2.07      -1.51             10                8       10          4
## 156       0.81      -1.96              9                9       14          3
## 157      16.50       9.16             16                2       15          2
## 158       0.95      -2.31              9                9       15          1
## 159      17.28      11.04             10                8       14          4
## 160       3.99      -0.16             12                6       13          4
## 161       2.93       0.90              8                8       12          4
## 162      -9.13      -4.60              7               11        7          5
## 163     -15.11      -4.21              3               13        3          9
## 164     -12.89      -7.32              8               10        4          9
## 165      -9.49      -7.53              7               11        4          7
## 166      14.78       6.96             12                6       16          3
## 167      -0.64      -0.61             11                7       16          3
## 168      -5.85      -5.85             11                5       13          4
## 169     -24.21      -7.91              5               11        5          7
## 170      16.01      10.09             13                7       15          3
## 171      -8.28      -6.95              7                9        8          5
## 172      -3.02      -0.18              4               14        9          8
## 173     -14.41      -6.15              5               13        7          8
## 174      10.70       5.09             11                7       17          2
## 175      -2.86      -0.24              6               12        9          6
## 176       9.39       8.70              5               13       11          5
## 177       0.77       2.31              7               11       10          5
## 178      24.93      12.34             16                4       15          1
## 179      21.82      10.55             15                5       17          1
## 180      -6.09       1.44              8               10        9          5
## 181      -8.90      -2.50              4               14        6          8
## 182      12.52      11.27              9               11       14          3
## 183      15.96       9.07             10                8       14          3
## 184     -22.47      -6.99              4               14        6          6
## 185      12.32       8.13             10                8       11          5
## 186      -6.61      -1.55              6               10        8          5
## 187      -1.20      -1.03             10                8       11          4
## 188       8.60       9.16              5               13        9          7
## 189     -10.66      -4.83             10                8        6          6
## 190      -7.91      -5.81             11                9        9          4
## 191       1.50      -5.05             16                4       12          2
## 192      -7.73      -1.76              8               10        7          7
## 193     -15.98     -10.70              4               12        6          7
## 194     -14.57      -6.02              6               12        4          9
## 195       8.96      -3.11             16                2       15          1
## 196     -10.09      -4.00              8               10        8          6
## 197      -2.32      -3.39             13                3       10          2
## 198      14.85      11.31              6               14       13          5
## 199       1.58       0.48             11                7       10          6
## 200      16.00       2.68             15                3       15          0
## 201     -18.66      -6.03              3               13        4         10
## 202      10.05      -2.38             15                1       16          1
## 203      -0.55       1.61              7               11        9          7
## 204      -8.88      -6.47             12                6       12          4
## 205     -11.33      -7.77              6               12        8          8
## 206     -11.87      -6.98              7               11        9          4
## 207      -3.63      -4.74              8                8       11          5
## 208      -8.04      -8.74             14                2       11          2
## 209     -11.00      -1.69              7                9        8          4
## 210     -19.81      -2.35              2               14        3         10
## 211     -11.24      -9.88             13                3       11          2
## 212     -11.53     -11.24             10                6       10          2
## 213       4.08      -0.90             15                3       15          2
## 214      14.94       6.22              9                9       17          5
## 215      -8.10      -2.04              5               13        5          9
## 216      23.94      11.35             16                2       14          2
## 217      -4.01      -2.07              9                7       10          3
## 218      -8.78      -3.55              6               10        8          6
## 219      -3.47      -0.70              9                7       10          3
## 220      -0.25      -3.48              8               10       12          4
## 221       3.95      -0.70             14                4       11          2
## 222     -10.75      -6.23              8               12        5          7
## 223      -3.92      -6.76             15                5       10          3
## 224       2.58       1.11              8               10       10          6
## 225      -1.54       0.62              9                9        9          5
## 226       4.67      -2.39             13                5       17          1
## 227     -17.06      -5.99              6               12        8          7
## 228       9.97       9.16              4               16       10          8
## 229       7.97       8.28              3               15       11          8
## 230      -2.27      -1.48             11                7       10          6
## 231      13.89      11.00              8               12       12          6
## 232      -1.84       3.16              6               12       11          5
## 233       8.09      11.53              5               13        8          7
## 234      15.30      12.21              7               11       11          4
## 235       3.74      -1.18             13                5       14          2
## 236      -9.34      -1.91              7                9        7          6
## 237       7.84       4.29             10                8       10          5
## 238      13.95       6.13             10                8       13          4
## 239      -2.46       1.97              4               12        9          7
## 240      12.55      11.51              7               13        9          6
## 241       2.04      -0.76              7                7       10          4
## 242       0.90       0.63              6               10        9          5
## 243       7.88       6.69              3               15       11          7
## 244      -8.95      -5.78             11                9       12          4
## 245     -10.80       0.51              0               16        6         11
## 246      -7.29      -9.17             17                1       11          0
## 247      -3.56      -5.35              9                7       12          3
## 248      -3.43      -0.89              8                6        7          5
## 249       8.29       6.71              7               11       11          7
## 250      21.40      11.99             16                4       15          0
## 251      -6.78      -8.03             11                7        7          7
## 252       1.28      -1.95             12                4       11          3
## 253       2.83       1.19              9                9        9          5
## 254      -6.56      -2.06              8               10        9          7
## 255      -1.37      -0.79              6               12        7         10
## 256      -4.96      -6.51             11                7        9          3
## 257      -9.41      -7.62             11                7       13          4
## 258       8.89       9.76              7               13       10          7
## 259      -8.78      -6.78              8               12        9          5
## 260      -7.88      -8.11             11                7       10          3
## 261      -8.74      -6.16             12                6       12          4
## 262      -0.43       1.66              6               12       10          5
## 263       5.06       2.23             10                8       15          2
## 264      12.58       4.40             11                5       14          3
## 265     -12.15      -6.40              6               12        7          7
## 266      -3.17      -5.84             16                2       12          2
## 267       0.69      -2.03              6               12       11          6
## 268       5.29       2.47             11                7       14          3
## 269       6.12       3.61              7                9       12          4
## 270       8.56       1.13              9                7       13          3
## 271     -16.37       0.59              1               17        4         11
## 272      -1.91       0.92              8                8       11          6
## 273     -20.51      -9.04              8                8        6          5
## 274      -1.47      -3.85              6               10       12          6
## 275      10.25       8.34              9                9       11          4
## 276      -7.90      -6.47             11                7        7          7
## 277      -4.46      -2.71              8               10       13          6
## 278     -16.86      -8.30              5               11        5          6
## 279     -15.30      -4.27              1               16        5          9
## 280       8.34       9.63             11                7       11          6
## 281       5.92      -4.74             14                2       14          1
## 282      -5.52      -3.06              7                9        8          6
## 283       5.96       1.69              8               10       18          5
## 284     -11.32      -4.39              5               13        6          8
## 285      -7.59      -6.30             12                6        9          5
## 286       8.23       4.96              8               10       12          5
## 287     -14.47      -5.06              6               12        7          8
## 288       1.39      -0.17             10                8        9          6
## 289       5.81       4.12              6               12       10          8
## 290       2.58      -0.83             11                7       11          3
## 291      -8.91      -6.22              9               11       11          4
## 292     -16.79      -7.37              6               12        6          5
## 293       3.34       0.25             12                6        9          5
## 294     -10.19      -8.45              9                9       11          3
## 295       7.88       5.50              8               10       11          4
## 296       6.03       5.13              8               10       10          4
## 297     -10.99      -5.92              7               11       10          6
## 298     -15.01      -3.46              3               13        7          8
## 299      -2.10      -6.48             12                4       10          4
## 300      13.73      10.09             10                8       13          6
## 301       8.17       4.93             13                5       13          2
## 302     -10.94      -4.32              6               12       10          4
## 303     -11.62      -3.15              6               12        6          7
## 304     -14.76      -3.00              4               14        5         10
## 305      21.55      10.16             15                3       18          0
## 306      -9.11      -5.68              9                9        9          7
## 307       7.21       8.59              6               12        9          8
## 308      -0.50       0.84             12                6        9          5
## 309      13.81       9.60              7               11       15          5
## 310      -8.23      -1.71              3               15        8          8
## 311      -2.04      -1.61              9                7       11          9
## 312       0.69       0.05             11                7       11          4
## 313      -5.55      -6.99             14                4       10          2
## 314       1.54      -3.00             12                6       11          4
## 315      22.79       9.53             14                4       17          1
## 316      16.06      11.46              8               10       15          6
## 317       8.21       0.71             13                5       14          2
## 318      -8.44      -3.57              6               12        5          8
## 319      -6.12      -1.01              5               13        8          8
## 320      -6.72       3.63              0               18        3         12
## 321       4.65       3.86              8               10       14          3
## 322       7.17       6.78              9                9       13          5
## 323      11.98       0.89             15                3       14          1
## 324       3.00      -2.30             12                4       14          1
## 325       6.13       5.10             11                7       10          5
## 326      -3.38      -1.00              7               11        8          7
## 327       3.57       7.79              0               18        8         10
## 328       4.88      -4.18             14                2       16          2
## 329      14.33       7.97             13                5       13          2
## 330      11.96       2.87             16                2       16          1
## 331     -10.50       0.09              4               14        8          7
## 332      19.28       7.79             12                6       14          2
## 333      25.46      10.15             16                2       15          1
## 334     -12.99      -7.63              8               10        7          7
## 335       1.21       8.47              4               14        8          8
## 336      -1.67       2.20              4               14        9          7
## 337      12.01       7.01             15                3       15          1
## 338      -4.37      -6.12             11                9       10          5
## 339       6.94      10.57              4               14       11          7
## 340      -9.28       0.34              4               14        4          8
## 341     -10.04      -5.18              4               12        7          6
## 342       3.14       0.96             11                7       10          4
## 343      -6.26       1.48              2               16        5          9
## 344       7.72       5.91             10                8       10          4
## 345      -4.78      -2.08             10                8        9          5
## 346      -2.89      -3.74             10                6       11          3
## 347      17.90      11.01             14                6       12          3
## 348      13.92       0.80             18                0       15          1
## 349       3.29      -0.89             13                5       15          2
## 350      -9.75       0.19              4               14        6         10
## 351       9.61       8.06              9                9       13          5
## 352       5.52      -1.24             10                4       11          2
## 353      -7.78      -2.05              8               10        6          7
##     AwayWins AwayLosses ForPoints OppPoints Blank Minutes FieldGoalsMade
## 1         10          4      2502      2161    NA    1370            897
## 2          3          9      2179      2294    NA    1300            802
## 3          1         10      2271      2107    NA    1325            797
## 4          0         18      1938      2285    NA    1295            736
## 5          6          6      2470      2370    NA    1410            906
## 6          3         13      2086      2235    NA    1250            712
## 7          4          8      2448      2433    NA    1365            856
## 8          6         10      2150      2216    NA    1300            728
## 9          0         17      1995      2194    NA    1245            709
## 10         6          8      2161      2070    NA    1220            780
## 11         2         12      2557      2539    NA    1290            880
## 12         6          5      2638      2494    NA    1380            899
## 13         4          7      2269      2205    NA    1290            794
## 14         3         12      2301      2353    NA    1250            817
## 15         4         17      2108      2269    NA    1300            719
## 16         2         13      2359      2475    NA    1310            796
## 17         5          8      2559      2458    NA    1370            893
## 18         3         13      2268      2305    NA    1280            837
## 19         4          6      3188      2750    NA    1615           1097
## 20         8          7      2712      2413    NA    1335            973
## 21         8          7      2478      2362    NA    1340            889
## 22         5          6      2442      2302    NA    1365            869
## 23        12          3      2868      2439    NA    1330           1042
## 24         3         12      2290      2245    NA    1250            833
## 25         5         12      2152      2376    NA    1320            793
## 26         3         10      2364      2263    NA    1330            845
## 27         2          8      2196      2256    NA    1260            768
## 28         8         10      2385      2387    NA    1325            922
## 29         5          8      2668      2496    NA    1370            945
## 30         5          8      2329      2285    NA    1405            812
## 31         5          8      2527      2436    NA    1295            878
## 32         7          9      2355      2204    NA    1290            805
## 33         2         13      2088      2314    NA    1200            709
## 34         7          8      2534      2418    NA    1325            867
## 35        12          3      3037      2550    NA    1445           1083
## 36         2         10      2374      2337    NA    1330            861
## 37         1         14      1930      2183    NA    1185            706
## 38         7         10      2412      2412    NA    1375            887
## 39         4         11      2437      2414    NA    1385            868
## 40         4         11      2601      2701    NA    1375            968
## 41         8          6      2403      2241    NA    1260            831
## 42         3         12      2038      2128    NA    1260            735
## 43        13          2      2675      2353    NA    1500            987
## 44         2         14      2153      2279    NA    1325            792
## 45         7          6      2350      2114    NA    1290            825
## 46         1         10      2121      2387    NA    1245            739
## 47         5          8      2495      2328    NA    1325            867
## 48         9          5      2250      2376    NA    1295            798
## 49         5         13      2383      2498    NA    1330            810
## 50         5         12      2205      2367    NA    1260            754
## 51         5          5      2385      2128    NA    1325            819
## 52         7          6      2896      2690    NA    1425            991
## 53         4         11      2574      2369    NA    1370            926
## 54         3          9      1776      1992    NA    1160            598
## 55         4         11      2268      2376    NA    1285            833
## 56         0         19      1970      2710    NA    1280            718
## 57         7          4      2510      2194    NA    1410            872
## 58         4         10      2553      2584    NA    1210            899
## 59         4          6      2339      2174    NA    1360            833
## 60         2         12      2300      2437    NA    1250            799
## 61         6         11      2641      2520    NA    1370            899
## 62         9          9      2648      2458    NA    1415            955
## 63         8          5      2453      2265    NA    1330            878
## 64         3          8      2393      2406    NA    1285            866
## 65         5          9      2648      2429    NA    1445            924
## 66         4          9      2059      2052    NA    1160            778
## 67         1          8      2436      2354    NA    1325            874
## 68         4         16      2118      2507    NA    1330            710
## 69         6         12      2149      2211    NA    1260            754
## 70         4          8      2727      2561    NA    1420            980
## 71         2         12      2160      2116    NA    1210            791
## 72         7          5      2409      2229    NA    1365            852
## 73         7          4      2406      2183    NA    1335            902
## 74         2         15      1956      2371    NA    1240            695
## 75         7          8      2352      2380    NA    1360            830
## 76         1         14      2086      2319    NA    1205            755
## 77         3          9      2821      2751    NA    1450           1009
## 78         4         14      2279      2464    NA    1240            784
## 79         7          6      2563      2387    NA    1385            908
## 80         3         11      2425      2475    NA    1280            874
## 81         7          2      3143      2576    NA    1525           1157
## 82         4          6      2351      2314    NA    1295            810
## 83         1         11      2088      2299    NA    1255            749
## 84         8          6      2707      2371    NA    1375           1004
## 85         5         10      2299      2457    NA    1310            826
## 86         3         11      2562      2577    NA    1265            902
## 87         4         10      2203      2213    NA    1295            818
## 88         4         13      2460      2527    NA    1380            876
## 89         6          7      2266      2445    NA    1290            812
## 90         2         13      2234      2317    NA    1295            747
## 91         3         13      2072      2167    NA    1240            761
## 92         7          9      2620      2515    NA    1420            921
## 93         6         14      1927      2057    NA    1245            719
## 94         6          9      2322      2243    NA    1335            809
## 95         4         10      2280      2360    NA    1280            809
## 96         6          9      2798      2734    NA    1360            986
## 97         6          4      2771      2485    NA    1500            960
## 98         5          6      2440      2289    NA    1455            857
## 99         3          8      2108      2141    NA    1295            759
## 100        7          3      2448      2162    NA    1285            847
## 101       11          4      2562      2182    NA    1340            930
## 102        8          9      2718      2468    NA    1430            955
## 103        6          6      2314      2289    NA    1330            825
## 104        2         10      2097      2356    NA    1340            745
## 105        5          6      2625      2576    NA    1355            894
## 106        7          7      2726      2489    NA    1330           1012
## 107        7          7      2598      2491    NA    1360            903
## 108        3          9      2091      2130    NA    1285            755
## 109        2          9      2274      2364    NA    1280            776
## 110        9          1      3243      2400    NA    1480           1177
## 111        6         12      2426      2336    NA    1370            834
## 112        5          8      2560      2353    NA    1370            907
## 113        5         13      3090      3036    NA    1535           1106
## 114        6         12      2847      2669    NA    1430            966
## 115        8          9      2477      2407    NA    1345            848
## 116        8          9      2222      2174    NA    1265            787
## 117        4          5      2241      2131    NA    1250            788
## 118        5          8      2115      2105    NA    1255            763
## 119       10          6      2919      2553    NA    1440            998
## 120        6         11      2216      2296    NA    1335            848
## 121        3         13      2465      2484    NA    1225            865
## 122       10          1      2787      2258    NA    1480            982
## 123        9          8      2684      2661    NA    1370            937
## 124        5         11      2198      2369    NA    1200            779
## 125        1         13      2174      2460    NA    1285            778
## 126        4         12      2391      2385    NA    1295            865
## 127        2         10      2257      2314    NA    1330            813
## 128        1          9      2398      2483    NA    1335            862
## 129        0         14      2044      2355    NA    1255            711
## 130        4          9      2146      2218    NA    1250            757
## 131        3          9      2504      2374    NA    1420            919
## 132        5          9      2532      2508    NA    1320            857
## 133        5          6      2692      2385    NA    1400            974
## 134        4          6      2740      2585    NA    1415            914
## 135        6          9      2728      2556    NA    1330            991
## 136        3         13      2507      2429    NA    1320            891
## 137        3         14      1974      2107    NA    1285            717
## 138       10          7      2574      2283    NA    1345            953
## 139        6         11      2385      2402    NA    1285            889
## 140        4         11      2322      2409    NA    1350            821
## 141        7          5      2236      2025    NA    1360            806
## 142        3          8      2725      2525    NA    1455            989
## 143        0         15      2030      2455    NA    1285            742
## 144        8          7      2481      2417    NA    1330            878
## 145        8          2      2806      2394    NA    1490            978
## 146        3          8      2091      2243    NA    1240            719
## 147        6          9      2209      2349    NA    1220            802
## 148        6         10      2597      2322    NA    1340            902
## 149        9          8      2479      2413    NA    1250            856
## 150       11          3      2654      2209    NA    1440            963
## 151       14          4      3076      2597    NA    1480           1071
## 152        4         12      2545      2584    NA    1375            877
## 153        7          9      2373      2337    NA    1285            822
## 154        5         12      2407      2408    NA    1375            803
## 155        7          7      2612      2575    NA    1290            901
## 156        4         12      2773      2637    NA    1425            922
## 157        9          1      2815      2558    NA    1435            988
## 158        4         10      2386      2235    NA    1335            840
## 159        5          6      2536      2324    NA    1380            854
## 160        5          7      2231      2066    NA    1360            831
## 161        8          7      2278      2125    NA    1360            817
## 162        3         16      2332      2477    NA    1295            842
## 163        2         18      1988      2271    NA    1310            747
## 164        4         11      1833      2011    NA    1285            651
## 165        6         11      2086      2147    NA    1250            739
## 166        6          4      2629      2363    NA    1375            893
## 167        6         10      2978      2979    NA    1495           1047
## 168        6          8      2296      2177    NA    1400            820
## 169        2         17      1833      2291    NA    1285            666
## 170        6          5      2429      2228    NA    1360            858
## 171        5         12      2456      2420    NA    1290            875
## 172        1         11      2263      2354    NA    1290            808
## 173        2         14      2149      2303    NA    1245            760
## 174        3          8      2882      2680    NA    1450           1013
## 175        2         12      2248      2246    NA    1245            787
## 176        0         10      2297      2275    NA    1285            805
## 177        4         10      2267      2233    NA    1285            777
## 178        8          4      3025      2534    NA    1570           1071
## 179        7          4      2575      2158    NA    1480            941
## 180        2         11      2141      2313    NA    1280            778
## 181        3         12      2146      2315    NA    1245            765
## 182        2          9      2543      2498    NA    1445            887
## 183        5          5      2628      2394    NA    1370            936
## 184        0         20      2058      2498    NA    1285            730
## 185        6          5      2485      2347    NA    1325            876
## 186        3         13      2220      2341    NA    1290            774
## 187        5          9      2206      2157    NA    1285            774
## 188        2          8      2150      2168    NA    1290            758
## 189        5         11      2286      2490    NA    1420            794
## 190        4         12      2502      2552    NA    1280            858
## 191        9          5      2665      2397    NA    1405            975
## 192        4         11      2431      2543    NA    1335            855
## 193        2         13      2161      2304    NA    1210            758
## 194        5         13      2092      2286    NA    1240            733
## 195       10          3      2727      2255    NA    1320            988
## 196        4         13      2061      2250    NA    1240            732
## 197        9          8      2523      2454    NA    1290            950
## 198        2         10      2586      2421    NA    1445            916
## 199        6          5      2276      2242    NA    1250            791
## 200        9          3      2723      2270    NA    1360            924
## 201        1         14      1742      1990    NA    1160            623
## 202       10          1      2734      2259    NA    1405            962
## 203        4          9      2443      2454    NA    1280            814
## 204        5          9      2384      2325    NA    1345            862
## 205        5         10      2318      2432    NA    1285            795
## 206        3         13      2260      2302    NA    1250            807
## 207       11          8      2472      2401    NA    1410            849
## 208        9          8      2652      2503    NA    1460            900
## 209        2         18      2145      2358    NA    1285            744
## 210        1         15      1857      2313    NA    1245            655
## 211        7         10      2241      2209    NA    1290            825
## 212        4         12      2429      2266    NA    1365            874
## 213       11          4      2738      2443    NA    1445            997
## 214        4          6      2882      2568    NA    1450           1061
## 215        2         12      2515      2670    NA    1335            880
## 216       11          1      3089      2636    NA    1445           1118
## 217        4          9      2556      2541    NA    1410            874
## 218        4         11      2220      2196    NA    1200            822
## 219        5         13      2485      2531    NA    1325            902
## 220        6          7      2302      2077    NA    1325            831
## 221        8          6      2564      2406    NA    1385            880
## 222        5         13      2262      2402    NA    1250            785
## 223       11          5      2450      2229    NA    1295            849
## 224        5          9      2506      2413    NA    1375            940
## 225        3          9      2215      2230    NA    1360            769
## 226        7          7      2747      2410    NA    1410            979
## 227        3         13      2051      2280    NA    1250            725
## 228        1          9      2108      2082    NA    1290            735
## 229        1          9      2266      2276    NA    1320            776
## 230        6         10      2534      2515    NA    1325            864
## 231        4          7      2419      2318    NA    1405            839
## 232        3         10      2174      2288    NA    1255            803
## 233        2         10      2178      2288    NA    1285            760
## 234        5          7      2423      2318    NA    1365            883
## 235        8          4      2300      2128    NA    1400            823
## 236        3         13      2314      2483    NA    1285            854
## 237        6          5      2275      2165    NA    1250            800
## 238        5          7      2661      2364    NA    1530            958
## 239        5         10      2138      2241    NA    1290            710
## 240        3          9      2229      2196    NA    1295            791
## 241        8          5      2250      2117    NA    1265            821
## 242        2         11      2572      2529    NA    1370            865
## 243        0         11      2306      2267    NA    1330            769
## 244        3         10      2475      2404    NA    1290            856
## 245        1         12      2078      2389    NA    1290            707
## 246        9         12      2627      2547    NA    1400            903
## 247        8         12      2817      2610    NA    1445            966
## 248        8          6      1948      1951    NA    1135            685
## 249        5          6      2428      2374    NA    1385            835
## 250        6          6      2760      2421    NA    1460            967
## 251        9          6      2294      2255    NA    1270            739
## 252        9          7      2440      2247    NA    1330            893
## 253        5          7      2293      2239    NA    1335            821
## 254        4         11      2367      2481    NA    1305            795
## 255        4          7      2314      2333    NA    1320            849
## 256        6         10      2381      2333    NA    1245            847
## 257        5         13      2448      2403    NA    1420            861
## 258        4          9      2105      2132    NA    1250            771
## 259        4         10      2197      2155    NA    1250            806
## 260        4         13      2558      2509    NA    1285            885
## 261        6         11      2517      2510    NA    1320            885
## 262        2         11      2328      2397    NA    1325            793
## 263        4          8      2399      2297    NA    1440            855
## 264        5          5      2463      2185    NA    1365            899
## 265        2         14      2012      2196    NA    1305            707
## 266        8          9      2476      2307    NA    1345            889
## 267        5          9      2583      2487    NA    1355            921
## 268        4          7      2437      2291    NA    1360            845
## 269        5          9      2591      2455    NA    1460            914
## 270        6          5      2358      2101    NA    1250            864
## 271        0         12      2042      2534    NA    1250            713
## 272        4          6      2115      2172    NA    1255            735
## 273        4         14      2360      2694    NA    1245            825
## 274        4          8      2420      2283    NA    1330            852
## 275        3          8      2508      2443    NA    1375            888
## 276        8          7      2131      2178    NA    1345            772
## 277        3         10      2478      2465    NA    1375            867
## 278        2         19      2388      2593    NA    1375            811
## 279        1         15      2169      2395    NA    1290            775
## 280        4          8      2327      2316    NA    1285            806
## 281        7          6      2789      2425    NA    1320            984
## 282        4          8      2118      2136    NA    1205            729
## 283        5          7      2752      2553    NA    1555            911
## 284        2         13      2216      2378    NA    1265            796
## 285        7          9      2224      2228    NA    1320            765
## 286        2          9      2518      2410    NA    1340            937
## 287        2         11      2265      2520    NA    1280            794
## 288        7          7      2194      2144    NA    1280            802
## 289        3          7      2303      2249    NA    1280            833
## 290        7          7      2392      2160    NA    1330            899
## 291        4         12      2573      2566    NA    1380            881
## 292        1         18      2077      2360    NA    1285            752
## 293        6          7      2250      2145    NA    1385            821
## 294        6         12      2345      2320    NA    1325            841
## 295        4          7      2623      2542    NA    1375            944
## 296        4          9      2255      2227    NA    1245            808
## 297        3          9      2105      2161    NA    1210            745
## 298        0         16      2151      2429    NA    1245            794
## 299       13          4      2364      2188    NA    1335            815
## 300        6          4      2370      2246    NA    1365            808
## 301        8          5      2465      2358    NA    1340            873
## 302        1         14      2356      2486    NA    1250            854
## 303        3         14      2182      2332    NA    1210            751
## 304        3         13      2104      2350    NA    1250            742
## 305        7          3      3035      2580    NA    1505           1106
## 306        5          9      2126      2124    NA    1290            774
## 307        3          7      2253      2297    NA    1280            806
## 308        7         10      2284      2303    NA    1345            781
## 309        3          7      2730      2574    NA    1500            990
## 310        0         13      1859      2001    NA    1170            639
## 311        8          7      2634      2623    NA    1490            895
## 312        5          7      2481      2407    NA    1295            896
## 313       13         11      3102      3008    NA    1550           1083
## 314       10          5      2470      2204    NA    1370            876
## 315        6          3      2765      2261    NA    1530            990
## 316        2          8      2628      2458    NA    1495            929
## 317        8          5      2537      2256    NA    1330            901
## 318        4          8      2170      2294    NA    1310            810
## 319        4         10      2179      2242    NA    1210            773
## 320        0         11      2082      2403    NA    1240            733
## 321        3          8      2296      2271    NA    1290            776
## 322        3          7      2580      2567    NA    1335            919
## 323        9          4      2753      2349    NA    1410            959
## 324        8          8      2697      2474    NA    1400            930
## 325        6          5      2343      2311    NA    1245            805
## 326        5          8      2205      2187    NA    1335            802
## 327        1         10      2180      2315    NA    1285            736
## 328       11          4      2508      2143    NA    1370            864
## 329        5          6      2654      2425    NA    1455            884
## 330        8          4      2344      2044    NA    1330            820
## 331        2         13      2433      2617    NA    1290            843
## 332        5          5      2574      2172    NA    1410            893
## 333       10          1      2714      2132    NA    1535            974
## 334        6         10      1974      2044    NA    1205            655
## 335        1         10      2119      2344    NA    1250            714
## 336        2          8      2393      2517    NA    1280            833
## 337        7          4      2511      2331    NA    1445            883
## 338        5          7      2617      2454    NA    1330            920
## 339        0         10      2655      2786    NA    1460            901
## 340        3         14      2304      2563    NA    1295            792
## 341        2         14      2198      2272    NA    1245            818
## 342        6          8      2429      2355    NA    1380            853
## 343        2         14      2246      2439    NA    1300            774
## 344        7          7      2609      2542    NA    1485            929
## 345        5         11      2321      2385    NA    1265            841
## 346        7          8      2499      2358    NA    1210            855
## 347        8          5      2333      2099    NA    1385            874
## 348       11          3      2879      2295    NA    1410           1044
## 349        5          8      2561      2365    NA    1405            885
## 350        1         11      2105      2411    NA    1285            690
## 351        4          8      2526      2472    NA    1420            922
## 352        8          5      2427      2202    NA    1215            893
## 353        5         11      2415      2526    NA    1305            879
##     FieldGoalsAttempted FieldGoalPCT ThreePointMade ThreePointAttempts
## 1                  1911        0.469            251                660
## 2                  1776        0.452            234                711
## 3                  1948        0.409            297                929
## 4                  1809        0.407            182                578
## 5                  2003        0.452            234                694
## 6                  1764        0.404            216                673
## 7                  1945        0.440            244                718
## 8                  1750        0.416            274                790
## 9                  1721        0.412            211                646
## 10                 1645        0.474            190                584
## 11                 1938        0.454            292                814
## 12                 2012        0.447            240                714
## 13                 1861        0.427            235                699
## 14                 1687        0.484            206                582
## 15                 1685        0.427            194                574
## 16                 1904        0.418            237                709
## 17                 2004        0.446            259                751
## 18                 1956        0.428            272                863
## 19                 2439        0.450            454               1204
## 20                 2060        0.472            268                702
## 21                 1892        0.470            202                621
## 22                 1966        0.442            274                803
## 23                 2094        0.498            343                922
## 24                 1899        0.439            204                635
## 25                 1842        0.431            275                788
## 26                 1801        0.469            252                715
## 27                 1808        0.425            218                687
## 28                 1922        0.480            221                639
## 29                 2134        0.443            272                762
## 30                 1874        0.433            240                653
## 31                 1878        0.468            226                684
## 32                 1818        0.443            255                745
## 33                 1680        0.422            230                708
## 34                 1928        0.450            311                885
## 35                 2344        0.462            344               1022
## 36                 1934        0.445            292                827
## 37                 1715        0.412            225                687
## 38                 2092        0.424            221                683
## 39                 1911        0.454            187                589
## 40                 2103        0.460            234                648
## 41                 1859        0.447            287                800
## 42                 1673        0.439            203                619
## 43                 2159        0.457            252                701
## 44                 1787        0.443            279                743
## 45                 1819        0.454            204                594
## 46                 1735        0.426            207                592
## 47                 1906        0.455            313                912
## 48                 1834        0.435            256                791
## 49                 1903        0.426            276                784
## 50                 1821        0.414            201                612
## 51                 1763        0.465            229                628
## 52                 2177        0.455            305                822
## 53                 2156        0.429            324                945
## 54                 1442        0.415            191                615
## 55                 1881        0.443            290                795
## 56                 1752        0.410            141                471
## 57                 2018        0.432            232                673
## 58                 2011        0.447            370               1076
## 59                 1857        0.449            217                661
## 60                 1834        0.436            303                820
## 61                 1986        0.453            284                766
## 62                 1995        0.479            320                815
## 63                 1818        0.483            227                667
## 64                 1818        0.476            259                722
## 65                 2036        0.454            230                711
## 66                 1720        0.452            237                655
## 67                 1959        0.446            252                732
## 68                 1827        0.389            240                841
## 69                 1705        0.442            243                731
## 70                 2044        0.479            372                961
## 71                 1750        0.452            264                721
## 72                 1893        0.450            312                882
## 73                 1789        0.504            205                617
## 74                 1963        0.354            234                789
## 75                 1808        0.459            282                746
## 76                 1723        0.438            227                622
## 77                 2143        0.471            241                703
## 78                 1874        0.418            294                825
## 79                 1943        0.467            279                773
## 80                 1900        0.460            237                669
## 81                 2418        0.478            278                903
## 82                 1894        0.428            271                841
## 83                 1791        0.418            155                545
## 84                 2067        0.486            274                758
## 85                 1912        0.432            272                735
## 86                 2125        0.424            272                832
## 87                 1823        0.449            187                634
## 88                 2040        0.429            310                886
## 89                 1862        0.436            335                943
## 90                 1776        0.421            264                776
## 91                 1755        0.434            259                740
## 92                 1939        0.475            269                672
## 93                 1640        0.438            180                489
## 94                 1971        0.410            290                895
## 95                 1787        0.453            269                724
## 96                 2239        0.440            279                923
## 97                 2171        0.442            272                819
## 98                 2015        0.425            291                872
## 99                 1890        0.402            276                831
## 100                1866        0.454            342                897
## 101                1962        0.474            338                935
## 102                1962        0.487            281                719
## 103                1855        0.445            210                637
## 104                1842        0.404            196                631
## 105                2017        0.443            269                757
## 106                2028        0.499            204                632
## 107                1968        0.459            330                859
## 108                1714        0.440            176                573
## 109                1761        0.441            210                653
## 110                2239        0.526            287                790
## 111                1846        0.452            223                553
## 112                2006        0.452            257                777
## 113                2413        0.458            303                879
## 114                2236        0.432            291                844
## 115                1862        0.455            322                846
## 116                1711        0.460            260                722
## 117                1746        0.451            266                751
## 118                1719        0.444            180                583
## 119                2055        0.486            308                800
## 120                1834        0.462            237                670
## 121                1896        0.456            200                588
## 122                2203        0.446            333                939
## 123                2163        0.433            244                669
## 124                1742        0.447            274                752
## 125                1764        0.441            251                678
## 126                1883        0.459            303                856
## 127                1887        0.431            244                734
## 128                2001        0.431            259                751
## 129                1527        0.466            174                508
## 130                1719        0.440            178                491
## 131                2009        0.457            211                676
## 132                1897        0.452            297                845
## 133                2047        0.476            294                811
## 134                2006        0.456            285                782
## 135                2059        0.481            360                949
## 136                1969        0.453            234                695
## 137                1774        0.404            155                554
## 138                2063        0.462            200                634
## 139                1953        0.455            213                645
## 140                1859        0.442            243                670
## 141                1878        0.429            241                721
## 142                2128        0.465            260                743
## 143                1945        0.381            136                438
## 144                2032        0.432            261                775
## 145                2050        0.477            215                607
## 146                1798        0.400            259                783
## 147                1786        0.449            280                736
## 148                1976        0.456            228                664
## 149                1775        0.482            287                679
## 150                1977        0.487            322                873
## 151                2230        0.480            327                876
## 152                2031        0.432            217                630
## 153                1880        0.437            277                813
## 154                1875        0.428            333                939
## 155                2026        0.445            283                821
## 156                2029        0.454            353                891
## 157                2162        0.457            236                740
## 158                1928        0.436            253                756
## 159                1967        0.434            294                860
## 160                1687        0.493            206                563
## 161                1800        0.454            163                510
## 162                1836        0.459            210                616
## 163                1728        0.432            201                647
## 164                1608        0.405            219                661
## 165                1647        0.449            245                675
## 166                1969        0.454            319                822
## 167                2367        0.442            362               1058
## 168                1893        0.433            261                807
## 169                1705        0.391            172                610
## 170                1909        0.449            247                707
## 171                1852        0.472            246                721
## 172                1831        0.441            256                732
## 173                1676        0.453            168                548
## 174                2238        0.453            260                807
## 175                1746        0.451            228                663
## 176                1851        0.435            268                805
## 177                1847        0.421            269                832
## 178                2230        0.480            319                844
## 179                2102        0.448            287                839
## 180                1858        0.419            212                650
## 181                1820        0.420            237                692
## 182                2039        0.435            191                603
## 183                1982        0.472            292                774
## 184                1923        0.380            172                554
## 185                1906        0.460            272                760
## 186                1794        0.431            259                728
## 187                1714        0.452            224                649
## 188                1764        0.430            264                727
## 189                1915        0.415            168                565
## 190                1882        0.456            306                818
## 191                1983        0.492            287                763
## 192                1993        0.429            260                762
## 193                1920        0.395            168                521
## 194                1755        0.418            223                723
## 195                2007        0.492            258                731
## 196                1785        0.410            208                656
## 197                1998        0.475            282                719
## 198                2133        0.429            270                800
## 199                1852        0.427            251                745
## 200                1999        0.462            297                855
## 201                1656        0.376            261                787
## 202                2092        0.460            326                977
## 203                1927        0.422            292                844
## 204                1941        0.444            189                566
## 205                1887        0.421            265                738
## 206                1914        0.422            324                883
## 207                1913        0.444            246                713
## 208                2079        0.433            282                770
## 209                1914        0.389            240                805
## 210                1627        0.403            223                687
## 211                1797        0.459            227                649
## 212                1922        0.455            221                693
## 213                2184        0.457            280                818
## 214                2319        0.458            292                830
## 215                1986        0.443            260                744
## 216                2410        0.464            312                862
## 217                1926        0.454            332                910
## 218                1771        0.464            241                647
## 219                2014        0.448            308                897
## 220                1910        0.435            284                838
## 221                1848        0.476            328                858
## 222                1819        0.432            259                749
## 223                1837        0.462            307                849
## 224                1995        0.471            229                642
## 225                1847        0.416            276                792
## 226                2047        0.478            306                844
## 227                1790        0.405            190                646
## 228                1827        0.402            233                744
## 229                1973        0.393            272                863
## 230                1859        0.465            314                816
## 231                1931        0.434            264                774
## 232                1838        0.437            187                633
## 233                1796        0.423            280                753
## 234                1975        0.447            226                654
## 235                2026        0.406            264                756
## 236                1874        0.456            266                734
## 237                1728        0.463            203                633
## 238                2126        0.451            295                840
## 239                1681        0.422            198                566
## 240                1898        0.417            222                693
## 241                1810        0.454            282                803
## 242                1949        0.444            313                819
## 243                1841        0.418            225                680
## 244                2017        0.424            238                769
## 245                1708        0.414            216                664
## 246                2061        0.438            225                703
## 247                2150        0.449            394               1034
## 248                1666        0.411            207                679
## 249                1973        0.423            225                690
## 250                2145        0.451            365                977
## 251                1730        0.427            348                923
## 252                1938        0.461            285                751
## 253                1914        0.429            172                615
## 254                1867        0.426            277                797
## 255                1800        0.472            251                723
## 256                1893        0.447            222                651
## 257                1991        0.432            280                789
## 258                1842        0.419            191                612
## 259                1800        0.448            175                527
## 260                1926        0.460            243                681
## 261                2035        0.435            254                724
## 262                1943        0.408            280                869
## 263                2052        0.417            205                675
## 264                1905        0.472            253                670
## 265                1639        0.431            184                567
## 266                2011        0.442            308                840
## 267                1951        0.472            254                687
## 268                1940        0.436            261                721
## 269                2002        0.457            284                808
## 270                1851        0.467            258                727
## 271                1765        0.404            210                641
## 272                1653        0.445            239                663
## 273                2080        0.397            351               1199
## 274                1945        0.438            238                642
## 275                2021        0.439            240                741
## 276                1779        0.434            288                849
## 277                1883        0.460            285                761
## 278                1891        0.429            193                582
## 279                1872        0.414            269                817
## 280                1907        0.423            242                662
## 281                1965        0.501            327                802
## 282                1664        0.438            227                666
## 283                2120        0.430            272                819
## 284                1809        0.440            266                719
## 285                1735        0.441            235                696
## 286                2039        0.460            281                735
## 287                1898        0.418            201                665
## 288                1720        0.466            213                570
## 289                1884        0.442            263                772
## 290                1929        0.466            275                712
## 291                1997        0.441            272                799
## 292                1710        0.440            180                544
## 293                1914        0.429            208                635
## 294                1989        0.423            270                806
## 295                2100        0.450            289                809
## 296                1783        0.453            207                653
## 297                1696        0.439            201                588
## 298                1962        0.405            215                684
## 299                1937        0.421            233                715
## 300                1907        0.424            274                824
## 301                1998        0.437            247                748
## 302                1915        0.446            250                726
## 303                1739        0.432            240                716
## 304                1784        0.416            213                620
## 305                2231        0.496            262                714
## 306                1803        0.429            202                621
## 307                1842        0.438            204                663
## 308                1908        0.409            234                773
## 309                2168        0.457            281                813
## 310                1592        0.401            199                620
## 311                2139        0.418            203                636
## 312                2068        0.433            294                855
## 313                2379        0.455            276                852
## 314                1971        0.444            244                744
## 315                2110        0.469            277                759
## 316                2146        0.433            325                934
## 317                1990        0.453            325                859
## 318                1860        0.435            180                550
## 319                1719        0.450            236                704
## 320                1783        0.411            213                670
## 321                1732        0.448            222                652
## 322                2012        0.457            256                721
## 323                2038        0.471            274                772
## 324                1929        0.482            283                740
## 325                1735        0.464            298                806
## 326                1783        0.450            185                585
## 327                1750        0.421            230                739
## 328                1887        0.458            273                761
## 329                2019        0.438            380               1081
## 330                1872        0.438            235                771
## 331                1974        0.427            323                899
## 332                1900        0.470            327                831
## 333                2056        0.474            321                813
## 334                1696        0.386            236                773
## 335                1812        0.394            197                640
## 336                1861        0.448            301                828
## 337                1956        0.451            273                780
## 338                1934        0.476            249                684
## 339                2181        0.413            269                852
## 340                1744        0.454            296                800
## 341                1860        0.440            241                626
## 342                1910        0.447            199                608
## 343                1822        0.425            228                723
## 344                2277        0.408            276                890
## 345                1773        0.474            254                735
## 346                1878        0.455            372                997
## 347                1945        0.449            241                672
## 348                2132        0.490            385                929
## 349                2028        0.436            281                818
## 350                1656        0.417            248                720
## 351                1977        0.466            245                740
## 352                1812        0.493            230                634
## 353                2057        0.427            303                891
##     ThreePointPct FreeThrowsMade FreeThrowsAttempted FreeThrowPCT
## 1           0.380            457                 642        0.712
## 2           0.329            341                 503        0.678
## 3           0.320            380                 539        0.705
## 4           0.315            284                 453        0.627
## 5           0.337            424                 630        0.673
## 6           0.321            446                 684        0.652
## 7           0.340            492                 739        0.666
## 8           0.347            420                 564        0.745
## 9           0.327            366                 543        0.674
## 10          0.325            411                 589        0.698
## 11          0.359            505                 706        0.715
## 12          0.336            600                 882        0.680
## 13          0.336            446                 620        0.719
## 14          0.354            461                 703        0.656
## 15          0.338            476                 702        0.678
## 16          0.334            530                 721        0.735
## 17          0.345            514                 769        0.668
## 18          0.315            322                 471        0.684
## 19          0.377            540                 760        0.711
## 20          0.382            498                 705        0.706
## 21          0.325            498                 709        0.702
## 22          0.341            430                 635        0.677
## 23          0.372            441                 598        0.737
## 24          0.321            420                 689        0.610
## 25          0.349            291                 452        0.644
## 26          0.352            422                 584        0.723
## 27          0.317            442                 633        0.698
## 28          0.346            320                 468        0.684
## 29          0.357            506                 755        0.670
## 30          0.368            465                 672        0.692
## 31          0.330            545                 750        0.727
## 32          0.342            490                 685        0.715
## 33          0.325            440                 618        0.712
## 34          0.351            489                 653        0.749
## 35          0.337            527                 767        0.687
## 36          0.353            360                 488        0.738
## 37          0.328            293                 452        0.648
## 38          0.324            417                 620        0.673
## 39          0.317            514                 726        0.708
## 40          0.361            431                 676        0.638
## 41          0.359            454                 576        0.788
## 42          0.328            365                 515        0.709
## 43          0.359            449                 640        0.702
## 44          0.376            290                 424        0.684
## 45          0.343            496                 693        0.716
## 46          0.350            436                 603        0.723
## 47          0.343            448                 590        0.759
## 48          0.324            398                 575        0.692
## 49          0.352            487                 667        0.730
## 50          0.328            496                 634        0.782
## 51          0.365            518                 798        0.649
## 52          0.371            609                 908        0.671
## 53          0.343            398                 588        0.677
## 54          0.311            389                 524        0.742
## 55          0.365            312                 457        0.683
## 56          0.299            393                 581        0.676
## 57          0.345            534                 758        0.704
## 58          0.344            385                 523        0.736
## 59          0.328            456                 623        0.732
## 60          0.370            399                 585        0.682
## 61          0.371            559                 778        0.719
## 62          0.393            418                 563        0.742
## 63          0.340            470                 615        0.764
## 64          0.359            402                 579        0.694
## 65          0.323            570                 757        0.753
## 66          0.362            266                 377        0.706
## 67          0.344            436                 641        0.680
## 68          0.285            458                 689        0.665
## 69          0.332            398                 551        0.722
## 70          0.387            395                 582        0.679
## 71          0.366            314                 436        0.720
## 72          0.354            393                 525        0.749
## 73          0.332            397                 575        0.690
## 74          0.297            332                 489        0.679
## 75          0.378            410                 564        0.727
## 76          0.365            349                 460        0.759
## 77          0.343            562                 773        0.727
## 78          0.356            417                 581        0.718
## 79          0.361            468                 618        0.757
## 80          0.354            440                 584        0.753
## 81          0.308            551                 803        0.686
## 82          0.322            460                 663        0.694
## 83          0.284            435                 638        0.682
## 84          0.361            425                 634        0.670
## 85          0.370            375                 545        0.688
## 86          0.327            486                 683        0.712
## 87          0.295            380                 604        0.629
## 88          0.350            398                 546        0.729
## 89          0.355            307                 443        0.693
## 90          0.340            476                 660        0.721
## 91          0.350            291                 420        0.693
## 92          0.400            509                 702        0.725
## 93          0.368            309                 503        0.614
## 94          0.324            414                 551        0.751
## 95          0.372            393                 588        0.668
## 96          0.302            547                 855        0.640
## 97          0.332            579                 778        0.744
## 98          0.334            435                 603        0.721
## 99          0.332            314                 462        0.680
## 100         0.381            412                 572        0.720
## 101         0.361            364                 508        0.717
## 102         0.391            527                 741        0.711
## 103         0.330            454                 634        0.716
## 104         0.311            411                 600        0.685
## 105         0.355            568                 771        0.737
## 106         0.323            498                 720        0.692
## 107         0.384            462                 694        0.666
## 108         0.307            405                 588        0.689
## 109         0.322            512                 726        0.705
## 110         0.363            602                 791        0.761
## 111         0.403            535                 781        0.685
## 112         0.331            487                 666        0.731
## 113         0.345            575                 818        0.703
## 114         0.345            622                 790        0.787
## 115         0.381            459                 619        0.742
## 116         0.360            388                 538        0.721
## 117         0.354            399                 576        0.693
## 118         0.309            409                 605        0.676
## 119         0.385            615                 767        0.802
## 120         0.354            283                 424        0.667
## 121         0.340            535                 793        0.675
## 122         0.355            490                 697        0.703
## 123         0.365            566                 780        0.726
## 124         0.364            366                 498        0.735
## 125         0.370            367                 507        0.724
## 126         0.354            358                 525        0.682
## 127         0.332            387                 540        0.717
## 128         0.345            415                 591        0.702
## 129         0.343            448                 553        0.810
## 130         0.363            454                 621        0.731
## 131         0.312            455                 695        0.655
## 132         0.351            521                 699        0.745
## 133         0.363            450                 615        0.732
## 134         0.364            627                 849        0.739
## 135         0.379            386                 557        0.693
## 136         0.337            491                 699        0.702
## 137         0.280            385                 607        0.634
## 138         0.315            468                 630        0.743
## 139         0.330            394                 582        0.677
## 140         0.363            437                 607        0.720
## 141         0.334            383                 574        0.667
## 142         0.350            487                 691        0.705
## 143         0.311            410                 590        0.695
## 144         0.337            464                 641        0.724
## 145         0.354            635                 859        0.739
## 146         0.331            394                 512        0.770
## 147         0.380            325                 437        0.744
## 148         0.343            565                 823        0.687
## 149         0.423            480                 620        0.774
## 150         0.369            406                 524        0.775
## 151         0.373            607                 801        0.758
## 152         0.344            574                 831        0.691
## 153         0.341            452                 643        0.703
## 154         0.355            468                 639        0.732
## 155         0.345            527                 710        0.742
## 156         0.396            576                 737        0.782
## 157         0.319            603                 802        0.752
## 158         0.335            453                 690        0.657
## 159         0.342            534                 687        0.777
## 160         0.366            363                 545        0.666
## 161         0.320            481                 645        0.746
## 162         0.341            438                 617        0.710
## 163         0.311            293                 452        0.648
## 164         0.331            312                 534        0.584
## 165         0.363            363                 530        0.685
## 166         0.388            524                 692        0.757
## 167         0.342            522                 723        0.722
## 168         0.323            395                 573        0.689
## 169         0.282            329                 489        0.673
## 170         0.349            466                 627        0.743
## 171         0.341            460                 639        0.720
## 172         0.350            391                 574        0.681
## 173         0.307            461                 647        0.713
## 174         0.322            596                 835        0.714
## 175         0.344            446                 648        0.688
## 176         0.333            419                 570        0.735
## 177         0.323            444                 626        0.709
## 178         0.378            564                 749        0.753
## 179         0.342            406                 579        0.701
## 180         0.326            373                 551        0.677
## 181         0.342            379                 508        0.746
## 182         0.317            578                 848        0.682
## 183         0.377            464                 647        0.717
## 184         0.310            426                 647        0.658
## 185         0.358            461                 589        0.783
## 186         0.356            413                 590        0.700
## 187         0.345            434                 627        0.692
## 188         0.363            370                 526        0.703
## 189         0.297            530                 773        0.686
## 190         0.374            480                 651        0.737
## 191         0.376            428                 621        0.689
## 192         0.341            461                 654        0.705
## 193         0.322            477                 669        0.713
## 194         0.308            403                 594        0.678
## 195         0.353            493                 673        0.733
## 196         0.317            389                 544        0.715
## 197         0.392            341                 473        0.721
## 198         0.338            484                 694        0.697
## 199         0.337            443                 647        0.685
## 200         0.347            578                 816        0.708
## 201         0.332            235                 385        0.610
## 202         0.334            484                 714        0.678
## 203         0.346            523                 745        0.702
## 204         0.334            471                 681        0.692
## 205         0.359            463                 629        0.736
## 206         0.367            322                 418        0.770
## 207         0.345            528                 732        0.721
## 208         0.366            570                 803        0.710
## 209         0.298            417                 619        0.674
## 210         0.325            324                 437        0.741
## 211         0.350            364                 548        0.664
## 212         0.319            460                 641        0.718
## 213         0.342            464                 666        0.697
## 214         0.352            468                 661        0.708
## 215         0.349            493                 673        0.733
## 216         0.362            541                 728        0.743
## 217         0.365            476                 613        0.777
## 218         0.372            335                 482        0.695
## 219         0.343            373                 539        0.692
## 220         0.339            356                 532        0.669
## 221         0.382            476                 634        0.751
## 222         0.346            433                 614        0.705
## 223         0.362            445                 633        0.703
## 224         0.357            397                 543        0.731
## 225         0.348            401                 537        0.747
## 226         0.363            483                 725        0.666
## 227         0.294            411                 604        0.680
## 228         0.313            405                 551        0.735
## 229         0.315            442                 594        0.744
## 230         0.385            492                 663        0.742
## 231         0.341            477                 650        0.734
## 232         0.295            381                 602        0.633
## 233         0.372            378                 549        0.689
## 234         0.346            431                 618        0.697
## 235         0.349            388                 585        0.663
## 236         0.362            340                 492        0.691
## 237         0.321            472                 636        0.742
## 238         0.351            450                 624        0.721
## 239         0.350            520                 698        0.745
## 240         0.320            425                 613        0.693
## 241         0.351            326                 511        0.638
## 242         0.382            529                 696        0.760
## 243         0.331            543                 779        0.697
## 244         0.309            525                 748        0.702
## 245         0.325            448                 668        0.671
## 246         0.320            596                 875        0.681
## 247         0.381            491                 674        0.728
## 248         0.305            371                 502        0.739
## 249         0.326            533                 771        0.691
## 250         0.374            461                 641        0.719
## 251         0.377            468                 646        0.724
## 252         0.379            369                 515        0.717
## 253         0.280            479                 704        0.680
## 254         0.348            500                 729        0.686
## 255         0.347            365                 552        0.661
## 256         0.341            465                 755        0.616
## 257         0.355            446                 638        0.699
## 258         0.312            372                 584        0.637
## 259         0.332            410                 592        0.693
## 260         0.357            545                 722        0.755
## 261         0.351            493                 698        0.706
## 262         0.322            462                 615        0.751
## 263         0.304            484                 809        0.598
## 264         0.378            412                 555        0.742
## 265         0.325            414                 570        0.726
## 266         0.367            390                 518        0.753
## 267         0.370            487                 666        0.731
## 268         0.362            486                 679        0.716
## 269         0.351            479                 641        0.747
## 270         0.355            372                 568        0.655
## 271         0.328            406                 620        0.655
## 272         0.360            406                 567        0.716
## 273         0.293            359                 531        0.676
## 274         0.371            478                 668        0.716
## 275         0.324            492                 697        0.706
## 276         0.339            299                 440        0.680
## 277         0.375            459                 669        0.686
## 278         0.332            573                 772        0.742
## 279         0.329            350                 492        0.711
## 280         0.366            473                 694        0.682
## 281         0.408            494                 635        0.778
## 282         0.341            433                 585        0.740
## 283         0.332            658                1018        0.646
## 284         0.370            358                 519        0.690
## 285         0.338            459                 640        0.717
## 286         0.382            363                 563        0.645
## 287         0.302            476                 677        0.703
## 288         0.374            377                 550        0.685
## 289         0.341            374                 523        0.715
## 290         0.386            321                 489        0.656
## 291         0.340            539                 757        0.712
## 292         0.331            393                 588        0.668
## 293         0.328            400                 539        0.742
## 294         0.335            393                 580        0.678
## 295         0.357            446                 620        0.719
## 296         0.317            432                 643        0.672
## 297         0.342            414                 607        0.682
## 298         0.314            348                 503        0.692
## 299         0.326            501                 695        0.721
## 300         0.333            480                 701        0.685
## 301         0.330            472                 649        0.727
## 302         0.344            398                 528        0.754
## 303         0.335            440                 628        0.701
## 304         0.344            407                 645        0.631
## 305         0.367            561                 744        0.754
## 306         0.325            376                 541        0.695
## 307         0.308            437                 631        0.693
## 308         0.303            488                 659        0.741
## 309         0.346            469                 688        0.682
## 310         0.321            382                 578        0.661
## 311         0.319            641                 923        0.694
## 312         0.344            395                 536        0.737
## 313         0.324            660                 988        0.668
## 314         0.328            474                 694        0.683
## 315         0.365            508                 694        0.732
## 316         0.348            445                 637        0.699
## 317         0.378            410                 531        0.772
## 318         0.327            370                 532        0.695
## 319         0.335            397                 550        0.722
## 320         0.318            403                 585        0.689
## 321         0.340            522                 751        0.695
## 322         0.355            486                 768        0.633
## 323         0.355            559                 747        0.748
## 324         0.382            554                 764        0.725
## 325         0.370            435                 616        0.706
## 326         0.316            416                 595        0.699
## 327         0.311            478                 710        0.673
## 328         0.359            507                 678        0.748
## 329         0.352            506                 695        0.728
## 330         0.305            469                 669        0.701
## 331         0.359            424                 581        0.730
## 332         0.394            461                 606        0.761
## 333         0.395            445                 598        0.744
## 334         0.305            428                 575        0.744
## 335         0.308            494                 681        0.725
## 336         0.364            426                 564        0.755
## 337         0.350            472                 679        0.695
## 338         0.364            528                 708        0.746
## 339         0.316            584                 849        0.688
## 340         0.370            424                 628        0.675
## 341         0.385            321                 440        0.730
## 342         0.327            524                 724        0.724
## 343         0.315            470                 680        0.691
## 344         0.310            475                 655        0.725
## 345         0.346            385                 576        0.668
## 346         0.373            417                 565        0.738
## 347         0.359            344                 531        0.648
## 348         0.414            406                 577        0.704
## 349         0.344            510                 692        0.737
## 350         0.344            477                 660        0.723
## 351         0.331            437                 644        0.679
## 352         0.363            411                 557        0.738
## 353         0.340            354                 505        0.701
##     OffensiveRebounds TotalRebounds Assists Steals Blocks Turnovers
## 1                 325          1110     525    297     93       407
## 2                 253          1077     434    154     57       423
## 3                 312          1204     399    185    106       388
## 4                 314          1032     385    234     50       487
## 5                 367          1279     401    218     82       399
## 6                 365          1094     313    203    102       451
## 7                 384          1285     418    157    160       465
## 8                 294          1081     402    195     78       454
## 9                 334          1079     391    229    107       492
## 10                251          1014     402    221    131       386
## 11                310          1127     406    171     90       418
## 12                399          1351     459    213    109       466
## 13                324          1115     398    165     73       370
## 14                244          1060     443    169     87       503
## 15                317          1063     365    216    109       478
## 16                403          1211     363    183    139       448
## 17                345          1152     543    276    172       450
## 18                259          1125     499    198     50       376
## 19                457          1369     572    369    190       466
## 20                397          1215     454    252    110       392
## 21                308          1243     426    217    118       480
## 22                450          1281     473    209    159       446
## 23                286          1275     645    220    125       376
## 24                415          1274     444    234    108       501
## 25                244          1060     324    183    152       409
## 26                242          1016     398    200     68       379
## 27                331          1139     382    159    103       378
## 28                311          1091     447    199     73       425
## 29                408          1396     427    227     90       412
## 30                313          1195     423    186    132       440
## 31                263          1118     482    203    107       354
## 32                261          1157     418    241    123       458
## 33                285           969     319    158     79       383
## 34                286          1154     519    173    116       409
## 35                452          1470     599    263    140       433
## 36                288          1058     434    193     62       359
## 37                284           975     301    147     99       334
## 38                486          1272     379    218    105       439
## 39                277          1224     407    200    118       450
## 40                352          1214     512    225    154       410
## 41                306          1171     345    148     85       379
## 42                218           929     375    196     71       412
## 43                429          1471     479    210    153       441
## 44                286          1051     425    164     60       425
## 45                379          1204     431    159    106       355
## 46                249           900     338    227     99       352
## 47                266          1050     482    218    104       337
## 48                300          1026     466    204    108       412
## 49                299          1164     463    202    120       478
## 50                332          1107     353    172    110       427
## 51                315          1215     439    189    150       393
## 52                419          1321     467    267    107       425
## 53                407          1277     487    263    110       441
## 54                199           892     288    138    101       418
## 55                278          1095     418    139     79       409
## 56                252           995     376    193     72       512
## 57                442          1264     466    214    155       365
## 58                322          1107     462    201    110       386
## 59                309          1204     410    223    154       450
## 60                303          1093     460    174     97       412
## 61                376          1256     451    214     78       472
## 62                322          1240     541    213    121       456
## 63                260          1060     387    216     76       347
## 64                256          1080     472    199     76       372
## 65                363          1352     478    181    107       479
## 66                255           985     443    218     78       366
## 67                380          1167     422    200    145       427
## 68                314          1218     326    169    115       555
## 69                191          1015     453    181    107       414
## 70                288          1196     561    237     92       464
## 71                246          1020     426    158    100       361
## 72                264          1185     499    175     82       378
## 73                261          1145     541    164     81       414
## 74                378          1144     333    214     66       435
## 75                254          1083     425    149     78       378
## 76                275          1041     354    142     78       408
## 77                396          1347     513    227    117       488
## 78                336          1019     319    238     77       355
## 79                279          1214     518    180    130       449
## 80                312          1126     464    144     62       377
## 81                495          1567     606    346    257       488
## 82                379          1133     442    250    151       451
## 83                317          1061     382    224    110       416
## 84                442          1351     534    252    135       483
## 85                347          1147     434    200    120       427
## 86                362          1167     458    317    101       447
## 87                400          1155     369    237    143       442
## 88                299          1192     467    200    101       401
## 89                265          1082     468    135     62       413
## 90                215          1095     394    185     89       416
## 91                273           968     401    202     63       436
## 92                323          1155     486    261    132       477
## 93                288           991     355    226    111       499
## 94                366          1296     419    184     93       485
## 95                272          1064     449    219    133       479
## 96                367          1217     491    359    153       477
## 97                418          1391     475    266    161       492
## 98                375          1201     437    257    131       420
## 99                305          1082     360    188    108       345
## 100               300          1137     457    228    111       400
## 101               326          1171     524    288    137       407
## 102               271          1190     502    238    101       407
## 103               323          1166     399    204     97       428
## 104               274          1116     375    170     96       413
## 105               350          1299     542    198    131       443
## 106               320          1190     403    255    132       451
## 107               273          1110     415    269    158       391
## 108               262          1074     433    221    166       459
## 109               357          1215     423    185    163       506
## 110               354          1443     668    278    204       394
## 111               307          1287     420    193    147       536
## 112               350          1238     478    207     75       411
## 113               376          1406     578    291    154       500
## 114               363          1370     487    215    121       379
## 115               278          1050     462    228     69       401
## 116               288          1119     369    174    123       491
## 117               278          1054     478    156     66       368
## 118               363          1183     404    170     91       406
## 119               305          1170     492    228    122       342
## 120               220           916     513    241    127       350
## 121               409          1142     449    234     54       442
## 122               448          1502     548    240    161       410
## 123               396          1253     463    198    144       427
## 124               275           975     383    154     88       360
## 125               258          1061     399    130     53       433
## 126               271          1106     478    210    124       457
## 127               298          1139     421    162    106       417
## 128               351          1091     446    245     86       435
## 129               204           845     354    184     53       504
## 130               250          1007     342    207     73       402
## 131               341          1272     469    226    154       433
## 132               283          1152     432    223     90       406
## 133               327          1230     527    247    160       379
## 134               357          1246     542    211    112       427
## 135               271          1140     525    247    158       395
## 136               403          1233     471    228    103       462
## 137               331          1125     359    209    124       436
## 138               400          1310     451    245    138       440
## 139               330          1163     457    213    166       463
## 140               345          1123     403    211    101       420
## 141               325          1137     464    256     76       385
## 142               374          1376     478    243    139       472
## 143               372          1163     362    185    106       437
## 144               412          1185     430    226    119       378
## 145               427          1428     501    220    176       466
## 146               328          1060     391    230     98       435
## 147               233          1004     419    158    126       402
## 148               446          1282     481    283     97       473
## 149               232          1105     471    171     71       418
## 150               270          1174     532    223     96       395
## 151               329          1378     654    268    108       489
## 152               377          1263     399    219    105       479
## 153               321          1196     430    218    157       471
## 154               284          1194     401    210     71       477
## 155               364          1142     487    226    125       423
## 156               317          1176     498    206     78       398
## 157               460          1355     452    308    148       452
## 158               368          1204     440    190    115       386
## 159               345          1297     458    149     99       412
## 160               190          1013     468    220     78       407
## 161               314          1098     460    250    102       425
## 162               292           997     448    278     73       444
## 163               280          1015     471    239     94       460
## 164               326          1026     360    221     78       487
## 165               241           967     377    172     53       387
## 166               331          1292     456    168    145       467
## 167               319          1260     527    334    170       453
## 168               296          1145     453    268     83       428
## 169               264           989     361    186     70       431
## 170               378          1336     447    148    163       437
## 171               293          1115     500    181     85       447
## 172               342          1123     468    154     93       445
## 173               310          1054     429    147     97       450
## 174               436          1358     553    288    144       538
## 175               307          1057     393    207     80       407
## 176               291          1061     413    212    100       372
## 177               353          1190     349    194     87       413
## 178               414          1579     715    201    205       493
## 179               299          1307     512    225    149       334
## 180               382          1228     352    190     85       512
## 181               288          1094     356    145     94       382
## 182               402          1314     523    175    140       418
## 183               393          1215     481    274    172       451
## 184               378          1165     361    176     70       415
## 185               322          1128     475    235    118       416
## 186               261           966     351    233     90       391
## 187               270          1000     354    221    127       385
## 188               345          1130     354    149     53       448
## 189               360          1224     379    237    101       502
## 190               292          1083     491    169     46       394
## 191               293          1176     510    229    106       416
## 192               357          1177     440    186    137       402
## 193               397          1078     362    230     48       401
## 194               293          1036     354    146    107       410
## 195               351          1247     591    249    149       401
## 196               359          1160     399    167     58       437
## 197               273          1047     409    180     61       304
## 198               379          1278     466    260    151       345
## 199               408          1204     401    184    115       401
## 200               325          1274     498    211    134       352
## 201               260           986     325    116     53       356
## 202               445          1343     514    197     91       419
## 203               351          1199     446    220    107       455
## 204               393          1166     497    285    134       517
## 205               315          1143     343    128    127       390
## 206               280          1041     428    208    128       386
## 207               250          1178     376    223     94       421
## 208               366          1318     457    219    154       523
## 209               351          1170     334    209     74       435
## 210               298           931     331    196     86       456
## 211               291          1059     452    215    108       417
## 212               399          1265     526    207     93       515
## 213               399          1251     453    315    140       423
## 214               486          1390     539    257    138       449
## 215               387          1221     495    150     68       436
## 216               477          1589     678    252    120       473
## 217               229          1105     402    160     87       368
## 218               233          1009     398    171     87       380
## 219               363          1252     520    212    165       536
## 220               368          1244     428    210     88       443
## 221               237          1075     480    211     74       381
## 222               290          1055     381    196     65       372
## 223               309          1128     422    176    101       398
## 224               304          1179     374    188     75       404
## 225               262          1115     370    165     75       393
## 226               364          1298     592    218    139       441
## 227               352          1103     340    192    138       496
## 228               278          1086     451    176    134       349
## 229               370          1208     423    179    148       306
## 230               275          1063     580    191     99       426
## 231               328          1215     494    206     85       438
## 232               332          1152     451    200    115       448
## 233               295          1093     422    183    139       386
## 234               305          1263     430    203    102       401
## 235               418          1365     439    197    160       408
## 236               335          1147     434    152    107       447
## 237               310          1091     465    185    164       384
## 238               361          1307     501    290    162       442
## 239               285          1039     325    199     46       423
## 240               382          1174     389    245    122       399
## 241               270          1101     465    210     76       395
## 242               290          1085     479    229     95       432
## 243               383          1211     387    227    126       448
## 244               491          1282     434    264    130       449
## 245               233          1032     369    175    123       425
## 246               392          1151     445    309     55       445
## 247               324          1248     565    214     69       358
## 248               272          1016     295    168     72       354
## 249               399          1241     491    253    136       445
## 250               421          1341     518    220    143       381
## 251               311          1111     393    159     62       415
## 252               335          1170     467    196    101       358
## 253               375          1194     401    235    129       405
## 254               316          1221     425    171    104       438
## 255               196           957     519    249    101       336
## 256               363          1144     450    282    101       415
## 257               373          1178     487    257     92       507
## 258               391          1210     390    201    124       408
## 259               308          1050     431    239    104       404
## 260               354          1231     471    170    133       465
## 261               430          1246     413    221     94       402
## 262               258          1145     397    186    110       305
## 263               492          1428     460    254    145       464
## 264               329          1180     341    201     87       355
## 265               293          1032     301    172    177       488
## 266               369          1191     555    242     94       413
## 267               316          1225     461    238    127       463
## 268               346          1228     487    197    113       424
## 269               290          1238     516    204    112       466
## 270               340          1138     439    188    105       321
## 271               323          1130     423    131     52       484
## 272               242          1026     416    146    111       433
## 273               383          1188     462    234     96       478
## 274               336          1221     386    141    118       403
## 275               361          1213     459    235    132       423
## 276               248           973     415    190     93       321
## 277               288          1094     471    201    141       456
## 278               376          1137     386    167     60       493
## 279               305          1051     434    207     94       440
## 280               383          1160     413    202    140       433
## 281               251          1259     489    202     65       388
## 282               219           942     382    165     68       324
## 283               496          1483     521    306    124       604
## 284               284          1081     402    182     75       447
## 285               346          1117     452    215     80       536
## 286               324          1188     536    202    117       392
## 287               351          1079     382    198     70       438
## 288               289          1081     438    212    129       447
## 289               365          1135     441    189    123       350
## 290               274          1178     553    253    110       345
## 291               282          1250     426    199    114       466
## 292               313           980     372    216     86       511
## 293               333          1183     417    199    164       421
## 294               346          1191     387    194    136       413
## 295               264          1120     472    302    111       357
## 296               322          1147     392    186    147       467
## 297               313          1008     348    192    113       442
## 298               359          1110     418    210     94       394
## 299               410          1348     372    209    142       478
## 300               363          1174     408    278    162       423
## 301               316          1136     476    284     73       368
## 302               351          1062     441    223     88       418
## 303               317          1032     342    219     78       497
## 304               330          1122     389    226    134       517
## 305               379          1391     660    221    199       412
## 306               349          1158     423    197     90       456
## 307               372          1195     376    215    142       444
## 308               372          1235     421    211     97       467
## 309               395          1347     598    255    162       499
## 310               285          1070     307    135     84       466
## 311               358          1215     503    345    105       471
## 312               323          1216     420    213     82       402
## 313               467          1503     591    309    114       589
## 314               409          1291     493    234     84       455
## 315               315          1297     518    278    186       457
## 316               358          1264     486    227    152       401
## 317               327          1281     538    170    152       402
## 318               389          1184     319    154     94       390
## 319               277          1021     392    171    135       408
## 320               298          1131     444    147    109       467
## 321               239          1119     430    176     76       404
## 322               380          1361     472    194    136       467
## 323               377          1405     598    215    147       449
## 324               318          1271     484    201     89       487
## 325               317          1096     440    144     80       409
## 326               294          1115     431    202    101       439
## 327               325          1139     371    154    126       454
## 328               304          1194     399    188    136       377
## 329               368          1253     503    194    106       388
## 330               358          1208     450    263    148       458
## 331               280          1110     442    217     61       390
## 332               310          1142     531    236     78       392
## 333               342          1326     544    211    149       342
## 334               378          1095     351    184    108       414
## 335               399          1174     329    150     77       417
## 336               276          1076     478    169     89       440
## 337               334          1129     419    323    206       479
## 338               220          1177     383    179    140       382
## 339               519          1425     488    223    126       557
## 340               303          1135     389    135     53       577
## 341               254          1100     319    165    132       353
## 342               338          1256     417    235    174       466
## 343               345          1197     374    147     78       490
## 344               452          1417     499    174    135       446
## 345               251          1057     529    158    146       390
## 346               330          1232     460    134     83       456
## 347               283          1197     430    177    140       327
## 348               365          1232     528    233    105       377
## 349               382          1229     484    214     72       402
## 350               167           983     331    176     88       450
## 351               371          1281     519    190    128       450
## 352               259          1157     503    177    131       392
## 353               418          1207     449    210    115       423
##     PersonalFouls
## 1             635
## 2             543
## 3             569
## 4             587
## 5             578
## 6             565
## 7             572
## 8             566
## 9             548
## 10            520
## 11            585
## 12            675
## 13            594
## 14            622
## 15            629
## 16            684
## 17            693
## 18            544
## 19            731
## 20            596
## 21            579
## 22            636
## 23            509
## 24            610
## 25            474
## 26            570
## 27            509
## 28            578
## 29            596
## 30            617
## 31            625
## 32            600
## 33            575
## 34            627
## 35            659
## 36            593
## 37            544
## 38            747
## 39            639
## 40            641
## 41            623
## 42            596
## 43            673
## 44            562
## 45            558
## 46            574
## 47            522
## 48            627
## 49            611
## 50            597
## 51            554
## 52            593
## 53            571
## 54            490
## 55            553
## 56            625
## 57            563
## 58            528
## 59            552
## 60            551
## 61            691
## 62            547
## 63            486
## 64            522
## 65            616
## 66            539
## 67            643
## 68            620
## 69            492
## 70            580
## 71            468
## 72            539
## 73            463
## 74            589
## 75            523
## 76            506
## 77            630
## 78            528
## 79            568
## 80            542
## 81            595
## 82            580
## 83            622
## 84            603
## 85            569
## 86            661
## 87            529
## 88            632
## 89            539
## 90            602
## 91            612
## 92            578
## 93            580
## 94            575
## 95            514
## 96            655
## 97            705
## 98            614
## 99            559
## 100           592
## 101           481
## 102           561
## 103           563
## 104           526
## 105           581
## 106           590
## 107           583
## 108           560
## 109           565
## 110           603
## 111           699
## 112           598
## 113           730
## 114           649
## 115           556
## 116           554
## 117           556
## 118           502
## 119           526
## 120           482
## 121           593
## 122           705
## 123           652
## 124           497
## 125           582
## 126           684
## 127           577
## 128           700
## 129           592
## 130           586
## 131           596
## 132           564
## 133           517
## 134           565
## 135           495
## 136           578
## 137           643
## 138           553
## 139           523
## 140           612
## 141           550
## 142           610
## 143           525
## 144           601
## 145           600
## 146           630
## 147           515
## 148           622
## 149           571
## 150           543
## 151           633
## 152           620
## 153           610
## 154           624
## 155           612
## 156           545
## 157           634
## 158           535
## 159           591
## 160           471
## 161           602
## 162           573
## 163           566
## 164           672
## 165           583
## 166           635
## 167           664
## 168           578
## 169           575
## 170           526
## 171           589
## 172           643
## 173           467
## 174           739
## 175           557
## 176           465
## 177           581
## 178           647
## 179           514
## 180           583
## 181           579
## 182           578
## 183           586
## 184           570
## 185           603
## 186           647
## 187           540
## 188           625
## 189           698
## 190           567
## 191           655
## 192           561
## 193           614
## 194           576
## 195           527
## 196           534
## 197           486
## 198           580
## 199           556
## 200           584
## 201           533
## 202           632
## 203           627
## 204           631
## 205           511
## 206           587
## 207           582
## 208           763
## 209           614
## 210           533
## 211           514
## 212           610
## 213           631
## 214           691
## 215           585
## 216           611
## 217           523
## 218           485
## 219           573
## 220           589
## 221           539
## 222           537
## 223           538
## 224           653
## 225           554
## 226           664
## 227           578
## 228           583
## 229           455
## 230           534
## 231           623
## 232           504
## 233           516
## 234           527
## 235           580
## 236           575
## 237           536
## 238           665
## 239           630
## 240           597
## 241           500
## 242           639
## 243           611
## 244           681
## 245           588
## 246           758
## 247           617
## 248           459
## 249           600
## 250           625
## 251           524
## 252           528
## 253           582
## 254           568
## 255           488
## 256           591
## 257           683
## 258           566
## 259           566
## 260           572
## 261           598
## 262           497
## 263           634
## 264           572
## 265           614
## 266           659
## 267           560
## 268           638
## 269           667
## 270           543
## 271           539
## 272           597
## 273           564
## 274           657
## 275           638
## 276           462
## 277           649
## 278           670
## 279           621
## 280           623
## 281           557
## 282           527
## 283           790
## 284           615
## 285           602
## 286           590
## 287           612
## 288           474
## 289           515
## 290           507
## 291           696
## 292           716
## 293           553
## 294           635
## 295           650
## 296           586
## 297           579
## 298           536
## 299           631
## 300           588
## 301           581
## 302           490
## 303           735
## 304           554
## 305           654
## 306           610
## 307           521
## 308           630
## 309           586
## 310           551
## 311           763
## 312           581
## 313           679
## 314           667
## 315           663
## 316           627
## 317           517
## 318           561
## 319           523
## 320           535
## 321           529
## 322           563
## 323           649
## 324           612
## 325           548
## 326           546
## 327           568
## 328           568
## 329           580
## 330           650
## 331           541
## 332           532
## 333           542
## 334           639
## 335           555
## 336           554
## 337           653
## 338           609
## 339           707
## 340           671
## 341           487
## 342           528
## 343           564
## 344           705
## 345           516
## 346           535
## 347           511
## 348           589
## 349           545
## 350           588
## 351           550
## 352           510
## 353           656
```

And just like that, we have a method for getting up to the minute season stats for every team in Division I. 
