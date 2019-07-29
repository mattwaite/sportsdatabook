# Intro to rvest

All the way back in Chapter 2, we used Google Sheets and importHTML to get our own data out of a website. For me, that's a lot of pointing and clicking and copying and pasting. R has a library that can automate the harvesting of data from HTML on the internet. It's called `rvest`. 

Let's grab [a simple, basic HTML table from College Football Stats](http://www.cfbstats.com/2018/leader/national/team/offense/split01/category09/sort01.html). This is scoring offense for 2018. There's nothing particularly strange about this table -- it's simply formatted and easy to scrape. 

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

```r
library(tidyverse)
```

```
## ── Attaching packages ────────────────────────────────────────────────────────────── tidyverse 1.2.1 ──
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
## ── Conflicts ───────────────────────────────────────────────────────────────── tidyverse_conflicts() ──
## ✖ dplyr::filter()         masks stats::filter()
## ✖ readr::guess_encoding() masks rvest::guess_encoding()
## ✖ dplyr::lag()            masks stats::lag()
## ✖ purrr::pluck()          masks rvest::pluck()
```

The rvest package has functions that make fetching, reading and parsing HTML simple. The first thing we need to do is specify a url that we're going to scrape.


```r
scoringoffenseurl <- "http://www.cfbstats.com/2018/leader/national/team/offense/split01/category09/sort01.html"
```

Now, the most difficult part of scraping data from any website is knowing what exact HTML tag you need to grab. In this case, we want a `<table>` tag that has all of our data table in it. But how do you tell R which one that is? Well, it's easy, once you know what to do. But it's not simple. So I've made a short video to show you how to find it. 

![](https://youtu.be/kYkSE3zWa9Y)

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
## 1 1   Oklahoma 14 89 17  88   1      1    677     48.4
## 2 2 Utah State 13 79 22  78   0      0    618     47.5
## 3 3    Alabama 15 92 15  83   0      2    684     45.6
## 4 4    Clemson 15 90 12  88   0      0    664     44.3
## 5 5    Houston 13 78  8  75   2      0    571     43.9
## 6 6        UCF 13 75 12  74   1      0    562     43.2
```

We have data, ready for analysis. 

## A slightly more complicated example

What if we want more than one year in our dataframe?

This is a common problem. What if we want to look at every scoring offense going back several years? The website has them going back to 2009. How can we combine them? 

First, we should note, that the data does not have anything in it to indicate what year it comes from. So we're going to have to add that. And we're going to have to figure out a way to stack two dataframes on top of each other. 

So let's grab 2017.


```r
scoringoffenseurl17 <- "http://www.cfbstats.com/2017/leader/national/team/offense/split01/category09/sort01.html"

scoringoffense17 <- scoringoffenseurl17 %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="content"]/div[2]/table') %>%
  html_table()

scoringoffense17 <- scoringoffense17[[1]]
```

First, how are we going to know, in the data, which year our data is from? We can use mutate.


```r
scoringoffense18 <- scoringoffense %>% mutate(YEAR = 2018)
```

```
## Column 1 must be named.
## Use .name_repair to specify repair.
```

Uh oh. Error. What does it say? Column 1 must be named. If you look at our data in the environment tab in the upper right corner, you'll see that indeed, the first column has no name. It's the FBS rank of each team. So we can fix that and mutate in the same step. We'll do that using `rename` and since the field doesn't have a name to rename it, we'll use a position argument. We'll say rename column 1 as Rank. 


```r
scoringoffense18 <- scoringoffense %>% rename(Rank = 1) %>% mutate(YEAR = 2018)
scoringoffense17 <- scoringoffense17 %>% rename(Rank = 1) %>% mutate(YEAR = 2017)
```

And now, to combine the two tables together length-wise -- we need to make long data -- we'll use a base R function called `rbind`. The good thing is rbind is simple. The bad part is it can only do two tables at a time, so if you have more than that, you'll need to do it in steps.


```r
combined <- rbind(scoringoffense18, scoringoffense17)
```

Note in the environment tab we now have a data frame called combined that has 260 observations -- which just so happens to be what 130 from 2018 and 130 from 2017 add up to. 


```r
head(combined)
```

```
##   Rank       Name  G TD FG 1XP 2XP Safety Points Points/G YEAR
## 1    1   Oklahoma 14 89 17  88   1      1    677     48.4 2018
## 2    2 Utah State 13 79 22  78   0      0    618     47.5 2018
## 3    3    Alabama 15 92 15  83   0      2    684     45.6 2018
## 4    4    Clemson 15 90 12  88   0      0    664     44.3 2018
## 5    5    Houston 13 78  8  75   2      0    571     43.9 2018
## 6    6        UCF 13 75 12  74   1      0    562     43.2 2018
```

## An even more complicated example

What do you do when the table has non-standard headers? 

Unfortunately, non-standard means there's no one way to do it -- it's going to depend on the table and the headers. But here's one idea: Don't try to make it work. 

I'll explain.

Let's try to get [season team stats from Sports Reference](https://www.sports-reference.com/cbb/seasons/2019-school-stats.html). If you look at that page, you'll see the problem right away -- the headers span two rows, and they repeat. That's going to be all kinds of no good. 


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
##   X1                     X2      X3      X4      X5      X6      X7
## 1                           Overall Overall Overall Overall Overall
## 2 Rk                 School       G       W       L    W-L%     SRS
## 3  1 Abilene Christian NCAA      34      27       7    .794   -1.91
## 4  2              Air Force      32      14      18    .438   -4.28
## 5  3                  Akron      33      17      16    .515    4.86
## 6  4            Alabama A&M      32       5      27    .156  -19.23
##        X8    X9   X10  X11  X12  X13  X14    X15    X16 X17           X18
## 1 Overall Conf. Conf. Home Home Away Away Points Points  NA School Totals
## 2     SOS     W     L    W    L    W    L    Tm.   Opp.  NA            MP
## 3   -7.34    14     4   13    2   10    4   2502   2161  NA          1370
## 4    0.24     8    10    9    6    3    9   2179   2294  NA          1300
## 5    1.09     8    10   14    3    1   10   2271   2107  NA          1325
## 6   -8.38     4    14    4    7    0   18   1938   2285  NA          1295
##             X19           X20           X21           X22           X23
## 1 School Totals School Totals School Totals School Totals School Totals
## 2            FG           FGA           FG%            3P           3PA
## 3           897          1911          .469           251           660
## 4           802          1776          .452           234           711
## 5           797          1948          .409           297           929
## 6           736          1809          .407           182           578
##             X24           X25           X26           X27           X28
## 1 School Totals School Totals School Totals School Totals School Totals
## 2           3P%            FT           FTA           FT%           ORB
## 3          .380           457           642          .712           325
## 4          .329           341           503          .678           253
## 5          .320           380           539          .705           312
## 6          .315           284           453          .627           314
##             X29           X30           X31           X32           X33
## 1 School Totals School Totals School Totals School Totals School Totals
## 2           TRB           AST           STL           BLK           TOV
## 3          1110           525           297            93           407
## 4          1077           434           154            57           423
## 5          1204           399           185           106           388
## 6          1032           385           234            50           487
##             X34
## 1 School Totals
## 2            PF
## 3           635
## 4           543
## 5           569
## 6           587
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
##     Rank                      School Games OverallWins OverallLosses
## 1      1      Abilene Christian NCAA    34          27             7
## 2      2                   Air Force    32          14            18
## 3      3                       Akron    33          17            16
## 4      4                 Alabama A&M    32           5            27
## 5      5          Alabama-Birmingham    35          20            15
## 6      6               Alabama State    31          12            19
## 7      7                     Alabama    34          18            16
## 8      8                 Albany (NY)    32          12            20
## 9      9                Alcorn State    31          10            21
## 10    10                    American    30          15            15
## 11    11           Appalachian State    32          11            21
## 12    12          Arizona State NCAA    34          23            11
## 13    13                     Arizona    32          17            15
## 14    14                 Little Rock    31          10            21
## 15    15         Arkansas-Pine Bluff    32          13            19
## 16    16              Arkansas State    32          13            19
## 17    17                    Arkansas    34          18            16
## 18    18                        Army    32          13            19
## 19    19                 Auburn NCAA    40          30            10
## 20    20                 Austin Peay    33          22            11
## 21    21                  Ball State    33          16            17
## 22    22                 Baylor NCAA    34          20            14
## 23    23                Belmont NCAA    33          27             6
## 24    24             Bethune-Cookman    31          14            17
## 25    25                  Binghamton    33          10            23
## 26    26                 Boise State    33          13            20
## 27    27              Boston College    31          14            17
## 28    28           Boston University    33          15            18
## 29    29         Bowling Green State    34          22            12
## 30    30                Bradley NCAA    35          20            15
## 31    31               Brigham Young    32          19            13
## 32    32                       Brown    32          20            12
## 33    33                      Bryant    30          10            20
## 34    34                    Bucknell    33          21            12
## 35    35                Buffalo NCAA    36          32             4
## 36    36                      Butler    33          16            17
## 37    37                    Cal Poly    29           6            23
## 38    38       Cal State Bakersfield    34          18            16
## 39    39         Cal State Fullerton    34          16            18
## 40    40        Cal State Northridge    34          13            21
## 41    41          California Baptist    31          16            15
## 42    42                    UC-Davis    31          11            20
## 43    43              UC-Irvine NCAA    37          31             6
## 44    44                UC-Riverside    33          10            23
## 45    45            UC-Santa Barbara    32          22            10
## 46    46    University of California    31           8            23
## 47    47                    Campbell    33          20            13
## 48    48                    Canisius    32          15            17
## 49    49            Central Arkansas    33          14            19
## 50    50   Central Connecticut State    31          11            20
## 51    51        Central Florida NCAA    33          24             9
## 52    52            Central Michigan    35          23            12
## 53    53         Charleston Southern    34          18            16
## 54    54                   Charlotte    29           8            21
## 55    55                 Chattanooga    32          12            20
## 56    56               Chicago State    32           3            29
## 57    57             Cincinnati NCAA    35          28             7
## 58    58                     Citadel    30          12            18
## 59    59                     Clemson    34          20            14
## 60    60             Cleveland State    31          10            21
## 61    61            Coastal Carolina    34          17            17
## 62    62                Colgate NCAA    35          24            11
## 63    63       College of Charleston    33          24             9
## 64    64              Colorado State    32          12            20
## 65    65                    Colorado    36          23            13
## 66    66                    Columbia    28          10            18
## 67    67                 Connecticut    33          16            17
## 68    68                Coppin State    33           8            25
## 69    69                     Cornell    31          15            16
## 70    70                   Creighton    35          20            15
## 71    71                   Dartmouth    30          11            19
## 72    72                    Davidson    34          24            10
## 73    73                      Dayton    33          21            12
## 74    74              Delaware State    31           6            25
## 75    75                    Delaware    33          17            16
## 76    76                      Denver    30           8            22
## 77    77                      DePaul    36          19            17
## 78    78               Detroit Mercy    31          11            20
## 79    79                       Drake    34          24            10
## 80    80                      Drexel    32          13            19
## 81    81                   Duke NCAA    38          32             6
## 82    82                    Duquesne    32          19            13
## 83    83               East Carolina    31          10            21
## 84    84        East Tennessee State    34          24            10
## 85    85            Eastern Illinois    32          14            18
## 86    86            Eastern Kentucky    31          13            18
## 87    87            Eastern Michigan    32          15            17
## 88    88          Eastern Washington    34          16            18
## 89    89                        Elon    32          11            21
## 90    90                  Evansville    32          11            21
## 91    91                   Fairfield    31           9            22
## 92    92    Fairleigh Dickinson NCAA    35          21            14
## 93    93                 Florida A&M    31          12            19
## 94    94            Florida Atlantic    33          17            16
## 95    95          Florida Gulf Coast    32          14            18
## 96    96       Florida International    34          20            14
## 97    97          Florida State NCAA    37          29             8
## 98    98                Florida NCAA    36          20            16
## 99    99                     Fordham    32          12            20
## 100  100                Fresno State    32          23             9
## 101  101                      Furman    33          25             8
## 102  102           Gardner-Webb NCAA    35          23            12
## 103  103                George Mason    33          18            15
## 104  104           George Washington    33           9            24
## 105  105                  Georgetown    33          19            14
## 106  106            Georgia Southern    33          21            12
## 107  107          Georgia State NCAA    34          24            10
## 108  108                Georgia Tech    32          14            18
## 109  109                     Georgia    32          11            21
## 110  110                Gonzaga NCAA    37          33             4
## 111  111                   Grambling    34          17            17
## 112  112                Grand Canyon    34          20            14
## 113  113                   Green Bay    38          21            17
## 114  114                     Hampton    35          18            17
## 115  115                    Hartford    33          18            15
## 116  116                     Harvard    31          19            12
## 117  117                      Hawaii    31          18            13
## 118  118                  High Point    31          16            15
## 119  119                     Hofstra    35          27             8
## 120  120                  Holy Cross    33          16            17
## 121  121             Houston Baptist    30          12            18
## 122  122                Houston NCAA    37          33             4
## 123  123                      Howard    34          17            17
## 124  124                 Idaho State    30          11            19
## 125  125                       Idaho    32           5            27
## 126  126            Illinois-Chicago    32          16            16
## 127  127              Illinois State    33          17            16
## 128  128                    Illinois    33          12            21
## 129  129              Incarnate Word    31           6            25
## 130  130               Indiana State    31          15            16
## 131  131                     Indiana    35          19            16
## 132  132                   Iona NCAA    33          17            16
## 133  133             Iowa State NCAA    35          23            12
## 134  134                   Iowa NCAA    35          23            12
## 135  135           Purdue-Fort Wayne    33          18            15
## 136  136                       IUPUI    33          16            17
## 137  137               Jackson State    32          13            19
## 138  138          Jacksonville State    33          24             9
## 139  139                Jacksonville    32          12            20
## 140  140               James Madison    33          14            19
## 141  141           Kansas State NCAA    34          25             9
## 142  142                 Kansas NCAA    36          26            10
## 143  143              Kennesaw State    32           6            26
## 144  144                  Kent State    33          22            11
## 145  145               Kentucky NCAA    37          30             7
## 146  146                    La Salle    31          10            21
## 147  147                   Lafayette    30          10            20
## 148  148                       Lamar    33          20            13
## 149  149                      Lehigh    31          20            11
## 150  150                Liberty NCAA    36          29             7
## 151  151                    Lipscomb    37          29             8
## 152  152            Long Beach State    34          15            19
## 153  153      Long Island University    32          16            16
## 154  154                    Longwood    34          16            18
## 155  155                   Louisiana    32          19            13
## 156  156            Louisiana-Monroe    35          19            16
## 157  157        Louisiana State NCAA    35          28             7
## 158  158              Louisiana Tech    33          20            13
## 159  159             Louisville NCAA    34          20            14
## 160  160                 Loyola (IL)    34          20            14
## 161  161            Loyola Marymount    34          22            12
## 162  162                 Loyola (MD)    32          11            21
## 163  163                       Maine    32           5            27
## 164  164                   Manhattan    32          11            21
## 165  165                      Marist    31          12            19
## 166  166              Marquette NCAA    34          24            10
## 167  167                    Marshall    37          23            14
## 168  168   Maryland-Baltimore County    34          21            13
## 169  169      Maryland-Eastern Shore    32           7            25
## 170  170               Maryland NCAA    34          23            11
## 171  171        Massachusetts-Lowell    32          15            17
## 172  172               Massachusetts    32          11            21
## 173  173               McNeese State    31           9            22
## 174  174                     Memphis    36          22            14
## 175  175                      Mercer    31          11            20
## 176  176                  Miami (FL)    32          14            18
## 177  177                  Miami (OH)    32          15            17
## 178  178         Michigan State NCAA    39          32             7
## 179  179               Michigan NCAA    37          30             7
## 180  180            Middle Tennessee    32          11            21
## 181  181                   Milwaukee    31           9            22
## 182  182              Minnesota NCAA    36          22            14
## 183  183      Mississippi State NCAA    34          23            11
## 184  184    Mississippi Valley State    32           6            26
## 185  185            Mississippi NCAA    33          20            13
## 186  186        Missouri-Kansas City    32          11            21
## 187  187              Missouri State    32          16            16
## 188  188                    Missouri    32          15            17
## 189  189                    Monmouth    35          14            21
## 190  190               Montana State    32          15            17
## 191  191                Montana NCAA    35          26             9
## 192  192              Morehead State    33          13            20
## 193  193                Morgan State    30           9            21
## 194  194            Mount St. Mary's    31           9            22
## 195  195           Murray State NCAA    33          28             5
## 196  196                        Navy    31          12            19
## 197  197                       Omaha    32          21            11
## 198  198                    Nebraska    36          19            17
## 199  199            Nevada-Las Vegas    31          17            14
## 200  200                 Nevada NCAA    34          29             5
## 201  201               New Hampshire    29           5            24
## 202  202       New Mexico State NCAA    35          30             5
## 203  203                  New Mexico    32          14            18
## 204  204                 New Orleans    33          19            14
## 205  205                     Niagara    32          13            19
## 206  206              Nicholls State    31          14            17
## 207  207                        NJIT    35          22            13
## 208  208               Norfolk State    36          22            14
## 209  209               North Alabama    32          10            22
## 210  210    North Carolina-Asheville    31           4            27
## 211  211          North Carolina A&T    32          19            13
## 212  212 North Carolina Central NCAA    34          18            16
## 213  213   North Carolina-Greensboro    36          29             7
## 214  214        North Carolina State    36          24            12
## 215  215   North Carolina-Wilmington    33          10            23
## 216  216         North Carolina NCAA    36          29             7
## 217  217     North Dakota State NCAA    35          19            16
## 218  218                North Dakota    30          12            18
## 219  219               North Florida    33          16            17
## 220  220                 North Texas    33          21            12
## 221  221           Northeastern NCAA    34          23            11
## 222  222            Northern Arizona    31          10            21
## 223  223           Northern Colorado    32          21            11
## 224  224           Northern Illinois    34          17            17
## 225  225               Northern Iowa    34          16            18
## 226  226      Northern Kentucky NCAA    35          26             9
## 227  227          Northwestern State    31          11            20
## 228  228                Northwestern    32          13            19
## 229  229                  Notre Dame    33          14            19
## 230  230                     Oakland    33          16            17
## 231  231             Ohio State NCAA    35          20            15
## 232  232                        Ohio    31          14            17
## 233  233              Oklahoma State    32          12            20
## 234  234               Oklahoma NCAA    34          20            14
## 235  235           Old Dominion NCAA    35          26             9
## 236  236                Oral Roberts    32          11            21
## 237  237                Oregon State    31          18            13
## 238  238                 Oregon NCAA    38          25            13
## 239  239                     Pacific    32          14            18
## 240  240                  Penn State    32          14            18
## 241  241                Pennsylvania    31          19            12
## 242  242                  Pepperdine    34          16            18
## 243  243                  Pittsburgh    33          14            19
## 244  244              Portland State    32          16            16
## 245  245                    Portland    32           7            25
## 246  246           Prairie View NCAA    35          22            13
## 247  247                Presbyterian    36          20            16
## 248  248                   Princeton    28          16            12
## 249  249                  Providence    34          18            16
## 250  250                 Purdue NCAA    36          26            10
## 251  251                  Quinnipiac    31          16            15
## 252  252                     Radford    33          22            11
## 253  253                Rhode Island    33          18            15
## 254  254                        Rice    32          13            19
## 255  255                    Richmond    33          13            20
## 256  256                       Rider    31          16            15
## 257  257               Robert Morris    35          18            17
## 258  258                     Rutgers    31          14            17
## 259  259            Sacramento State    31          15            16
## 260  260                Sacred Heart    32          15            17
## 261  261          Saint Francis (PA)    33          18            15
## 262  262              Saint Joseph's    33          14            19
## 263  263            Saint Louis NCAA    36          23            13
## 264  264      Saint Mary's (CA) NCAA    34          22            12
## 265  265               Saint Peter's    32          10            22
## 266  266           Sam Houston State    33          21            12
## 267  267                     Samford    33          17            16
## 268  268             San Diego State    34          21            13
## 269  269                   San Diego    36          21            15
## 270  270               San Francisco    31          21            10
## 271  271              San Jose State    31           4            27
## 272  272                 Santa Clara    31          16            15
## 273  273              Savannah State    31          11            20
## 274  274                     Seattle    33          18            15
## 275  275             Seton Hall NCAA    34          20            14
## 276  276                       Siena    33          17            16
## 277  277               South Alabama    34          17            17
## 278  278        South Carolina State    34           8            26
## 279  279      South Carolina Upstate    32           6            26
## 280  280              South Carolina    32          16            16
## 281  281          South Dakota State    33          24             9
## 282  282                South Dakota    30          13            17
## 283  283               South Florida    38          24            14
## 284  284    Southeast Missouri State    31          10            21
## 285  285      Southeastern Louisiana    33          17            16
## 286  286         Southern California    33          16            17
## 287  287            SIU Edwardsville    31          10            21
## 288  288           Southern Illinois    32          17            15
## 289  289          Southern Methodist    32          15            17
## 290  290        Southern Mississippi    33          20            13
## 291  291               Southern Utah    34          17            17
## 292  292                    Southern    32           7            25
## 293  293             St. Bonaventure    34          18            16
## 294  294            St. Francis (NY)    33          17            16
## 295  295        St. John's (NY) NCAA    34          21            13
## 296  296                    Stanford    31          15            16
## 297  297           Stephen F. Austin    30          14            16
## 298  298                     Stetson    31           7            24
## 299  299                 Stony Brook    33          24             9
## 300  300               Syracuse NCAA    34          20            14
## 301  301                 Temple NCAA    33          23            10
## 302  302            Tennessee-Martin    31          12            19
## 303  303             Tennessee State    30           9            21
## 304  304              Tennessee Tech    31           8            23
## 305  305              Tennessee NCAA    37          31             6
## 306  306    Texas A&M-Corpus Christi    32          14            18
## 307  307                   Texas A&M    32          14            18
## 308  308             Texas-Arlington    33          17            16
## 309  309             Texas Christian    37          23            14
## 310  310               Texas-El Paso    29           8            21
## 311  311     Texas-Rio Grande Valley    37          20            17
## 312  312           Texas-San Antonio    32          17            15
## 313  313              Texas Southern    38          24            14
## 314  314                 Texas State    34          24            10
## 315  315             Texas Tech NCAA    38          31             7
## 316  316                       Texas    37          21            16
## 317  317                      Toledo    33          25             8
## 318  318                      Towson    32          10            22
## 319  319                        Troy    30          12            18
## 320  320                      Tulane    31           4            27
## 321  321                       Tulsa    32          18            14
## 322  322                        UCLA    33          17            16
## 323  323             Utah State NCAA    35          28             7
## 324  324                 Utah Valley    35          25            10
## 325  325                        Utah    31          17            14
## 326  326                  Valparaiso    33          15            18
## 327  327                  Vanderbilt    32           9            23
## 328  328                Vermont NCAA    34          27             7
## 329  329              Villanova NCAA    36          26            10
## 330  330  Virginia Commonwealth NCAA    33          25             8
## 331  331                         VMI    32          11            21
## 332  332          Virginia Tech NCAA    35          26             9
## 333  333               Virginia NCAA    38          35             3
## 334  334                      Wagner    30          13            17
## 335  335                 Wake Forest    31          11            20
## 336  336            Washington State    32          11            21
## 337  337             Washington NCAA    36          27             9
## 338  338                 Weber State    33          18            15
## 339  339               West Virginia    36          15            21
## 340  340            Western Carolina    32           7            25
## 341  341            Western Illinois    31          10            21
## 342  342            Western Kentucky    34          20            14
## 343  343            Western Michigan    32           8            24
## 344  344               Wichita State    37          22            15
## 345  345              William & Mary    31          14            17
## 346  346                    Winthrop    30          18            12
## 347  347              Wisconsin NCAA    34          23            11
## 348  348                Wofford NCAA    35          30             5
## 349  349                Wright State    35          21            14
## 350  350                     Wyoming    32           8            24
## 351  351                      Xavier    35          19            16
## 352  352                   Yale NCAA    30          22             8
## 353  353            Youngstown State    32          12            20
##     WinPct OverallSRS OverallSOS ConferenceWins ConferenceLosses HomeWins
## 1    0.794      -1.91      -7.34             14                4       13
## 2    0.438      -4.28       0.24              8               10        9
## 3    0.515       4.86       1.09              8               10       14
## 4    0.156     -19.23      -8.38              4               14        4
## 5    0.571       0.36      -1.52             10                8       11
## 6    0.387     -15.60      -7.84              9                9        8
## 7    0.529       9.45       9.01              8               10       10
## 8    0.375      -9.38      -6.70              7                9        6
## 9    0.323     -22.08      -8.97              6               12       10
## 10   0.500      -4.19      -7.23              9                9        8
## 11   0.344      -3.73       0.10              6               12        9
## 12   0.676      10.28       6.04             12                6       13
## 13   0.531       8.32       6.32              8               10       12
## 14   0.323      -4.87      -2.07              5               13        7
## 15   0.406     -14.43      -8.18             10                8        8
## 16   0.406      -7.10      -1.23              7               11       10
## 17   0.529      11.75       8.78              8               10       12
## 18   0.406      -7.57      -4.73              8               10       10
## 19   0.750      20.84      10.92             11                7       15
## 20   0.667       0.59      -4.41             13                5       10
## 21   0.485       3.39       1.21              6               12        7
## 22   0.588      13.38       9.26             10                8       13
## 23   0.818       9.12      -2.60             16                2       13
## 24   0.452     -11.98      -9.74              9                7       11
## 25   0.303     -13.92      -4.69              5               11        5
## 26   0.394       3.61       1.08              7               11        8
## 27   0.452       5.83       7.76              5               13       10
## 28   0.455      -6.61      -5.39              7               11        7
## 29   0.647       4.24       0.86             12                6       14
## 30   0.571      -0.08      -0.90              9                9       10
## 31   0.594       6.15       3.31             11                5       13
## 32   0.625      -0.62      -3.29              7                7       13
## 33   0.333     -15.19      -7.66              7               11        8
## 34   0.636       0.59      -2.93             13                5       12
## 35   0.889      15.56       2.62             16                2       14
## 36   0.485       9.22       8.10              7               11       12
## 37   0.207     -13.95      -3.54              2               14        4
## 38   0.529      -5.12      -2.63              7                9        9
## 39   0.471      -3.29      -1.14             10                6        9
## 40   0.382      -6.54      -3.39              7                9        7
## 41   0.516      -3.89      -4.12              7                9        8
## 42   0.355      -6.26      -1.50              7                9        7
## 43   0.838       5.70      -2.30             15                1       12
## 44   0.303     -11.12      -3.19              4               12        7
## 45   0.688      -1.62      -5.55             10                6       12
## 46   0.258      -3.16       5.42              3               15        7
## 47   0.606      -3.62      -4.39             12                4       12
## 48   0.469      -8.79      -4.85             11                7        5
## 49   0.424     -11.37      -4.81              8               10        8
## 50   0.355     -14.02      -6.71              5               13        5
## 51   0.727      13.37       5.58             13                5       15
## 52   0.657       2.79      -0.34             10                8       13
## 53   0.529      -2.43      -4.19              9                7       12
## 54   0.276      -8.34      -0.89              5               13        5
## 55   0.375      -7.87      -0.76              7               11        8
## 56   0.094     -24.83       0.67              0               16        3
## 57   0.800      14.53       5.50             14                4       16
## 58   0.400      -7.94       0.03              4               14        8
## 59   0.588      13.85       8.99              9                9       14
## 60   0.323      -7.96      -1.52              5               13        8
## 61   0.500      -0.50      -1.94              9                9       10
## 62   0.686       1.23      -3.83             13                5       15
## 63   0.727       2.36      -2.95             12                6       13
## 64   0.375      -0.11       1.41              7               11        8
## 65   0.639       9.68       3.60             10                8       15
## 66   0.357      -5.18      -2.14              5                9        5
## 67   0.485       6.81       4.32              6               12       13
## 68   0.242     -18.90      -7.11              7                9        3
## 69   0.484      -6.12      -2.02              7                7        9
## 70   0.571      12.00       8.59              9                9       13
## 71   0.367      -5.75      -3.00              2               12        8
## 72   0.706       6.38       1.96             14                4       14
## 73   0.636       9.67       2.91             13                5       13
## 74   0.194     -26.82     -10.13              2               14        3
## 75   0.515      -7.91      -4.82              8               10        9
## 76   0.267     -11.84      -2.97              3               13        6
## 77   0.528       6.00       4.05              7               11       16
## 78   0.355      -6.33      -0.36              8               10        6
## 79   0.706       2.52      -0.66             12                6       13
## 80   0.406      -7.02      -2.93              7               11        9
## 81   0.842      26.90      11.98             14                4       15
## 82   0.594       0.53      -0.63             10                8       14
## 83   0.323      -5.49       1.31              3               15        8
## 84   0.706       5.21      -1.79             13                5       13
## 85   0.438     -11.81      -5.01              7               11        7
## 86   0.419      -7.40      -2.47              6               12        9
## 87   0.469       0.40       4.43              9                9       11
## 88   0.471      -6.77      -4.17             12                8        9
## 89   0.344     -11.53      -3.56              7               11        5
## 90   0.344      -3.84       0.13              5               13        9
## 91   0.290     -10.20      -7.14              6               12        5
## 92   0.600      -6.09      -7.24             12                6       13
## 93   0.387     -13.57      -8.09              9                7        6
## 94   0.515      -1.42      -1.76              8               10        9
## 95   0.438      -5.11      -1.48              9                7       10
## 96   0.588      -4.55      -1.45             10                8       12
## 97   0.784      17.99      10.26             13                5       15
## 98   0.556      15.42      11.22              9                9        9
## 99   0.375      -5.02      -2.40              3               15        9
## 100  0.719       8.99       0.67             13                5       13
## 101  0.758       7.46      -1.50             13                5       13
## 102  0.657      -2.61      -4.43             11                6       13
## 103  0.545       0.84       0.08             11                7       11
## 104  0.273      -6.65       1.20              4               14        6
## 105  0.576       6.80       5.31              9                9       13
## 106  0.636       3.75       0.13             12                6       10
## 107  0.706       2.44       0.65             13                5       13
## 108  0.438       6.93       8.15              6               12       11
## 109  0.344       5.31       8.12              2               16        8
## 110  0.892      27.79       5.01             16                0       17
## 111  0.500      -9.73      -9.34             10                8       11
## 112  0.588       3.85      -1.49             10                6       12
## 113  0.553      -2.24      -0.36             10                8       15
## 114  0.514      -3.34      -5.06              9                7       12
## 115  0.545      -3.95      -4.89             10                6       10
## 116  0.613       1.86       0.66             10                4        9
## 117  0.581      -1.30      -3.61              9                7       12
## 118  0.516      -5.63      -4.39              9                7        9
## 119  0.771       4.68      -4.53             15                3       15
## 120  0.485      -6.43      -4.01              6               12        8
## 121  0.400      -9.36      -5.53              8               10        9
## 122  0.892      18.91       4.61             16                2       19
## 123  0.500     -12.30      -9.52             10                6        6
## 124  0.367     -13.17      -4.81              7               13        6
## 125  0.156     -18.74      -6.19              2               18        4
## 126  0.500      -3.15      -1.99             10                8       12
## 127  0.515      -2.06       0.25              9                9       12
## 128  0.364       8.95      11.53              7               13        9
## 129  0.194     -18.93      -5.11              1               17        5
## 130  0.484      -2.72       0.62              7               11        9
## 131  0.543      13.82      10.10              8               12       15
## 132  0.515      -4.78      -5.50             12                6        8
## 133  0.657      18.07       9.30              9                9       12
## 134  0.657      14.27       9.84             10               10       14
## 135  0.545      -3.47      -3.60              9                7       11
## 136  0.485      -2.72      -3.04              8               10       11
## 137  0.406     -14.60      -9.33             10                8        9
## 138  0.727       1.59      -5.47             15                3       11
## 139  0.375      -8.27      -4.74              5               11        5
## 140  0.424      -8.52      -4.07              6               12        8
## 141  0.735      15.39       9.18             14                4       13
## 142  0.722      18.35      12.79             12                6       16
## 143  0.188     -16.17      -1.04              3               13        6
## 144  0.667       1.26       0.61             11                7       14
## 145  0.811      21.43      10.29             15                3       17
## 146  0.323      -3.61       1.29              8               10        5
## 147  0.333     -11.17      -4.93              7               11        4
## 148  0.606      -5.94      -7.22             12                6       13
## 149  0.645      -2.34      -4.46             12                6       11
## 150  0.806       5.27      -3.88             14                2       16
## 151  0.784       9.21      -1.20             14                2       14
## 152  0.441      -4.57      -0.44              8                8        9
## 153  0.500      -8.99      -9.08              9                9        8
## 154  0.471      -8.43      -6.62              5               11       10
## 155  0.594      -2.07      -1.51             10                8       10
## 156  0.543       0.81      -1.96              9                9       14
## 157  0.800      16.50       9.16             16                2       15
## 158  0.606       0.95      -2.31              9                9       15
## 159  0.588      17.28      11.04             10                8       14
## 160  0.588       3.99      -0.16             12                6       13
## 161  0.647       2.93       0.90              8                8       12
## 162  0.344      -9.13      -4.60              7               11        7
## 163  0.156     -15.11      -4.21              3               13        3
## 164  0.344     -12.89      -7.32              8               10        4
## 165  0.387      -9.49      -7.53              7               11        4
## 166  0.706      14.78       6.96             12                6       16
## 167  0.622      -0.64      -0.61             11                7       16
## 168  0.618      -5.85      -5.85             11                5       13
## 169  0.219     -24.21      -7.91              5               11        5
## 170  0.676      16.01      10.09             13                7       15
## 171  0.469      -8.28      -6.95              7                9        8
## 172  0.344      -3.02      -0.18              4               14        9
## 173  0.290     -14.41      -6.15              5               13        7
## 174  0.611      10.70       5.09             11                7       17
## 175  0.355      -2.86      -0.24              6               12        9
## 176  0.438       9.39       8.70              5               13       11
## 177  0.469       0.77       2.31              7               11       10
## 178  0.821      24.93      12.34             16                4       15
## 179  0.811      21.82      10.55             15                5       17
## 180  0.344      -6.09       1.44              8               10        9
## 181  0.290      -8.90      -2.50              4               14        6
## 182  0.611      12.52      11.27              9               11       14
## 183  0.676      15.96       9.07             10                8       14
## 184  0.188     -22.47      -6.99              4               14        6
## 185  0.606      12.32       8.13             10                8       11
## 186  0.344      -6.61      -1.55              6               10        8
## 187  0.500      -1.20      -1.03             10                8       11
## 188  0.469       8.60       9.16              5               13        9
## 189  0.400     -10.66      -4.83             10                8        6
## 190  0.469      -7.91      -5.81             11                9        9
## 191  0.743       1.50      -5.05             16                4       12
## 192  0.394      -7.73      -1.76              8               10        7
## 193  0.300     -15.98     -10.70              4               12        6
## 194  0.290     -14.57      -6.02              6               12        4
## 195  0.848       8.96      -3.11             16                2       15
## 196  0.387     -10.09      -4.00              8               10        8
## 197  0.656      -2.32      -3.39             13                3       10
## 198  0.528      14.85      11.31              6               14       13
## 199  0.548       1.58       0.48             11                7       10
## 200  0.853      16.00       2.68             15                3       15
## 201  0.172     -18.66      -6.03              3               13        4
## 202  0.857      10.05      -2.38             15                1       16
## 203  0.438      -0.55       1.61              7               11        9
## 204  0.576      -8.88      -6.47             12                6       12
## 205  0.406     -11.33      -7.77              6               12        8
## 206  0.452     -11.87      -6.98              7               11        9
## 207  0.629      -3.63      -4.74              8                8       11
## 208  0.611      -8.04      -8.74             14                2       11
## 209  0.313     -11.00      -1.69              7                9        8
## 210  0.129     -19.81      -2.35              2               14        3
## 211  0.594     -11.24      -9.88             13                3       11
## 212  0.529     -11.53     -11.24             10                6       10
## 213  0.806       4.08      -0.90             15                3       15
## 214  0.667      14.94       6.22              9                9       17
## 215  0.303      -8.10      -2.04              5               13        5
## 216  0.806      23.94      11.35             16                2       14
## 217  0.543      -4.01      -2.07              9                7       10
## 218  0.400      -8.78      -3.55              6               10        8
## 219  0.485      -3.47      -0.70              9                7       10
## 220  0.636      -0.25      -3.48              8               10       12
## 221  0.676       3.95      -0.70             14                4       11
## 222  0.323     -10.75      -6.23              8               12        5
## 223  0.656      -3.92      -6.76             15                5       10
## 224  0.500       2.58       1.11              8               10       10
## 225  0.471      -1.54       0.62              9                9        9
## 226  0.743       4.67      -2.39             13                5       17
## 227  0.355     -17.06      -5.99              6               12        8
## 228  0.406       9.97       9.16              4               16       10
## 229  0.424       7.97       8.28              3               15       11
## 230  0.485      -2.27      -1.48             11                7       10
## 231  0.571      13.89      11.00              8               12       12
## 232  0.452      -1.84       3.16              6               12       11
## 233  0.375       8.09      11.53              5               13        8
## 234  0.588      15.30      12.21              7               11       11
## 235  0.743       3.74      -1.18             13                5       14
## 236  0.344      -9.34      -1.91              7                9        7
## 237  0.581       7.84       4.29             10                8       10
## 238  0.658      13.95       6.13             10                8       13
## 239  0.438      -2.46       1.97              4               12        9
## 240  0.438      12.55      11.51              7               13        9
## 241  0.613       2.04      -0.76              7                7       10
## 242  0.471       0.90       0.63              6               10        9
## 243  0.424       7.88       6.69              3               15       11
## 244  0.500      -8.95      -5.78             11                9       12
## 245  0.219     -10.80       0.51              0               16        6
## 246  0.629      -7.29      -9.17             17                1       11
## 247  0.556      -3.56      -5.35              9                7       12
## 248  0.571      -3.43      -0.89              8                6        7
## 249  0.529       8.29       6.71              7               11       11
## 250  0.722      21.40      11.99             16                4       15
## 251  0.516      -6.78      -8.03             11                7        7
## 252  0.667       1.28      -1.95             12                4       11
## 253  0.545       2.83       1.19              9                9        9
## 254  0.406      -6.56      -2.06              8               10        9
## 255  0.394      -1.37      -0.79              6               12        7
## 256  0.516      -4.96      -6.51             11                7        9
## 257  0.514      -9.41      -7.62             11                7       13
## 258  0.452       8.89       9.76              7               13       10
## 259  0.484      -8.78      -6.78              8               12        9
## 260  0.469      -7.88      -8.11             11                7       10
## 261  0.545      -8.74      -6.16             12                6       12
## 262  0.424      -0.43       1.66              6               12       10
## 263  0.639       5.06       2.23             10                8       15
## 264  0.647      12.58       4.40             11                5       14
## 265  0.313     -12.15      -6.40              6               12        7
## 266  0.636      -3.17      -5.84             16                2       12
## 267  0.515       0.69      -2.03              6               12       11
## 268  0.618       5.29       2.47             11                7       14
## 269  0.583       6.12       3.61              7                9       12
## 270  0.677       8.56       1.13              9                7       13
## 271  0.129     -16.37       0.59              1               17        4
## 272  0.516      -1.91       0.92              8                8       11
## 273  0.355     -20.51      -9.04              8                8        6
## 274  0.545      -1.47      -3.85              6               10       12
## 275  0.588      10.25       8.34              9                9       11
## 276  0.515      -7.90      -6.47             11                7        7
## 277  0.500      -4.46      -2.71              8               10       13
## 278  0.235     -16.86      -8.30              5               11        5
## 279  0.188     -15.30      -4.27              1               16        5
## 280  0.500       8.34       9.63             11                7       11
## 281  0.727       5.92      -4.74             14                2       14
## 282  0.433      -5.52      -3.06              7                9        8
## 283  0.632       5.96       1.69              8               10       18
## 284  0.323     -11.32      -4.39              5               13        6
## 285  0.515      -7.59      -6.30             12                6        9
## 286  0.485       8.23       4.96              8               10       12
## 287  0.323     -14.47      -5.06              6               12        7
## 288  0.531       1.39      -0.17             10                8        9
## 289  0.469       5.81       4.12              6               12       10
## 290  0.606       2.58      -0.83             11                7       11
## 291  0.500      -8.91      -6.22              9               11       11
## 292  0.219     -16.79      -7.37              6               12        6
## 293  0.529       3.34       0.25             12                6        9
## 294  0.515     -10.19      -8.45              9                9       11
## 295  0.618       7.88       5.50              8               10       11
## 296  0.484       6.03       5.13              8               10       10
## 297  0.467     -10.99      -5.92              7               11       10
## 298  0.226     -15.01      -3.46              3               13        7
## 299  0.727      -2.10      -6.48             12                4       10
## 300  0.588      13.73      10.09             10                8       13
## 301  0.697       8.17       4.93             13                5       13
## 302  0.387     -10.94      -4.32              6               12       10
## 303  0.300     -11.62      -3.15              6               12        6
## 304  0.258     -14.76      -3.00              4               14        5
## 305  0.838      21.55      10.16             15                3       18
## 306  0.438      -9.11      -5.68              9                9        9
## 307  0.438       7.21       8.59              6               12        9
## 308  0.515      -0.50       0.84             12                6        9
## 309  0.622      13.81       9.60              7               11       15
## 310  0.276      -8.23      -1.71              3               15        8
## 311  0.541      -2.04      -1.61              9                7       11
## 312  0.531       0.69       0.05             11                7       11
## 313  0.632      -5.55      -6.99             14                4       10
## 314  0.706       1.54      -3.00             12                6       11
## 315  0.816      22.79       9.53             14                4       17
## 316  0.568      16.06      11.46              8               10       15
## 317  0.758       8.21       0.71             13                5       14
## 318  0.313      -8.44      -3.57              6               12        5
## 319  0.400      -6.12      -1.01              5               13        8
## 320  0.129      -6.72       3.63              0               18        3
## 321  0.563       4.65       3.86              8               10       14
## 322  0.515       7.17       6.78              9                9       13
## 323  0.800      11.98       0.89             15                3       14
## 324  0.714       3.00      -2.30             12                4       14
## 325  0.548       6.13       5.10             11                7       10
## 326  0.455      -3.38      -1.00              7               11        8
## 327  0.281       3.57       7.79              0               18        8
## 328  0.794       4.88      -4.18             14                2       16
## 329  0.722      14.33       7.97             13                5       13
## 330  0.758      11.96       2.87             16                2       16
## 331  0.344     -10.50       0.09              4               14        8
## 332  0.743      19.28       7.79             12                6       14
## 333  0.921      25.46      10.15             16                2       15
## 334  0.433     -12.99      -7.63              8               10        7
## 335  0.355       1.21       8.47              4               14        8
## 336  0.344      -1.67       2.20              4               14        9
## 337  0.750      12.01       7.01             15                3       15
## 338  0.545      -4.37      -6.12             11                9       10
## 339  0.417       6.94      10.57              4               14       11
## 340  0.219      -9.28       0.34              4               14        4
## 341  0.323     -10.04      -5.18              4               12        7
## 342  0.588       3.14       0.96             11                7       10
## 343  0.250      -6.26       1.48              2               16        5
## 344  0.595       7.72       5.91             10                8       10
## 345  0.452      -4.78      -2.08             10                8        9
## 346  0.600      -2.89      -3.74             10                6       11
## 347  0.676      17.90      11.01             14                6       12
## 348  0.857      13.92       0.80             18                0       15
## 349  0.600       3.29      -0.89             13                5       15
## 350  0.250      -9.75       0.19              4               14        6
## 351  0.543       9.61       8.06              9                9       13
## 352  0.733       5.52      -1.24             10                4       11
## 353  0.375      -7.78      -2.05              8               10        6
##     HomeLosses AwayWins AwayLosses ForPoints OppPoints Blank Minutes
## 1            2       10          4      2502      2161    NA    1370
## 2            6        3          9      2179      2294    NA    1300
## 3            3        1         10      2271      2107    NA    1325
## 4            7        0         18      1938      2285    NA    1295
## 5            5        6          6      2470      2370    NA    1410
## 6            3        3         13      2086      2235    NA    1250
## 7            6        4          8      2448      2433    NA    1365
## 8            8        6         10      2150      2216    NA    1300
## 9            3        0         17      1995      2194    NA    1245
## 10           7        6          8      2161      2070    NA    1220
## 11           5        2         12      2557      2539    NA    1290
## 12           3        6          5      2638      2494    NA    1380
## 13           5        4          7      2269      2205    NA    1290
## 14           9        3         12      2301      2353    NA    1250
## 15           2        4         17      2108      2269    NA    1300
## 16           4        2         13      2359      2475    NA    1310
## 17           6        5          8      2559      2458    NA    1370
## 18           4        3         13      2268      2305    NA    1280
## 19           2        4          6      3188      2750    NA    1615
## 20           2        8          7      2712      2413    NA    1335
## 21           7        8          7      2478      2362    NA    1340
## 22           5        5          6      2442      2302    NA    1365
## 23           1       12          3      2868      2439    NA    1330
## 24           4        3         12      2290      2245    NA    1250
## 25          11        5         12      2152      2376    NA    1320
## 26           7        3         10      2364      2263    NA    1330
## 27           8        2          8      2196      2256    NA    1260
## 28           7        8         10      2385      2387    NA    1325
## 29           2        5          8      2668      2496    NA    1370
## 30           6        5          8      2329      2285    NA    1405
## 31           3        5          8      2527      2436    NA    1295
## 32           3        7          9      2355      2204    NA    1290
## 33           6        2         13      2088      2314    NA    1200
## 34           3        7          8      2534      2418    NA    1325
## 35           0       12          3      3037      2550    NA    1445
## 36           4        2         10      2374      2337    NA    1330
## 37           8        1         14      1930      2183    NA    1185
## 38           4        7         10      2412      2412    NA    1375
## 39           4        4         11      2437      2414    NA    1385
## 40           9        4         11      2601      2701    NA    1375
## 41           7        8          6      2403      2241    NA    1260
## 42           6        3         12      2038      2128    NA    1260
## 43           2       13          2      2675      2353    NA    1500
## 44           7        2         14      2153      2279    NA    1325
## 45           3        7          6      2350      2114    NA    1290
## 46           9        1         10      2121      2387    NA    1245
## 47           4        5          8      2495      2328    NA    1325
## 48           8        9          5      2250      2376    NA    1295
## 49           5        5         13      2383      2498    NA    1330
## 50           7        5         12      2205      2367    NA    1260
## 51           2        5          5      2385      2128    NA    1325
## 52           4        7          6      2896      2690    NA    1425
## 53           4        4         11      2574      2369    NA    1370
## 54           9        3          9      1776      1992    NA    1160
## 55           6        4         11      2268      2376    NA    1285
## 56           8        0         19      1970      2710    NA    1280
## 57           2        7          4      2510      2194    NA    1410
## 58           7        4         10      2553      2584    NA    1210
## 59           5        4          6      2339      2174    NA    1360
## 60           9        2         12      2300      2437    NA    1250
## 61           4        6         11      2641      2520    NA    1370
## 62           1        9          9      2648      2458    NA    1415
## 63           2        8          5      2453      2265    NA    1330
## 64           9        3          8      2393      2406    NA    1285
## 65           2        5          9      2648      2429    NA    1445
## 66           7        4          9      2059      2052    NA    1160
## 67           5        1          8      2436      2354    NA    1325
## 68           7        4         16      2118      2507    NA    1330
## 69           4        6         12      2149      2211    NA    1260
## 70           6        4          8      2727      2561    NA    1420
## 71           6        2         12      2160      2116    NA    1210
## 72           2        7          5      2409      2229    NA    1365
## 73           4        7          4      2406      2183    NA    1335
## 74           9        2         15      1956      2371    NA    1240
## 75           7        7          8      2352      2380    NA    1360
## 76           7        1         14      2086      2319    NA    1205
## 77           7        3          9      2821      2751    NA    1450
## 78           6        4         14      2279      2464    NA    1240
## 79           2        7          6      2563      2387    NA    1385
## 80           7        3         11      2425      2475    NA    1280
## 81           2        7          2      3143      2576    NA    1525
## 82           4        4          6      2351      2314    NA    1295
## 83           9        1         11      2088      2299    NA    1255
## 84           3        8          6      2707      2371    NA    1375
## 85           6        5         10      2299      2457    NA    1310
## 86           5        3         11      2562      2577    NA    1265
## 87           7        4         10      2203      2213    NA    1295
## 88           4        4         13      2460      2527    NA    1380
## 89          11        6          7      2266      2445    NA    1290
## 90           7        2         13      2234      2317    NA    1295
## 91           7        3         13      2072      2167    NA    1240
## 92           4        7          9      2620      2515    NA    1420
## 93           3        6         14      1927      2057    NA    1245
## 94           5        6          9      2322      2243    NA    1335
## 95           4        4         10      2280      2360    NA    1280
## 96           4        6          9      2798      2734    NA    1360
## 97           1        6          4      2771      2485    NA    1500
## 98           6        5          6      2440      2289    NA    1455
## 99          10        3          8      2108      2141    NA    1295
## 100          4        7          3      2448      2162    NA    1285
## 101          3       11          4      2562      2182    NA    1340
## 102          0        8          9      2718      2468    NA    1430
## 103          6        6          6      2314      2289    NA    1330
## 104         11        2         10      2097      2356    NA    1340
## 105          6        5          6      2625      2576    NA    1355
## 106          4        7          7      2726      2489    NA    1330
## 107          1        7          7      2598      2491    NA    1360
## 108          7        3          9      2091      2130    NA    1285
## 109          9        2          9      2274      2364    NA    1280
## 110          0        9          1      3243      2400    NA    1480
## 111          3        6         12      2426      2336    NA    1370
## 112          2        5          8      2560      2353    NA    1370
## 113          3        5         13      3090      3036    NA    1535
## 114          3        6         12      2847      2669    NA    1430
## 115          4        8          9      2477      2407    NA    1345
## 116          2        8          9      2222      2174    NA    1265
## 117          5        4          5      2241      2131    NA    1250
## 118          4        5          8      2115      2105    NA    1255
## 119          1       10          6      2919      2553    NA    1440
## 120          6        6         11      2216      2296    NA    1335
## 121          4        3         13      2465      2484    NA    1225
## 122          1       10          1      2787      2258    NA    1480
## 123          8        9          8      2684      2661    NA    1370
## 124          7        5         11      2198      2369    NA    1200
## 125         11        1         13      2174      2460    NA    1285
## 126          4        4         12      2391      2385    NA    1295
## 127          4        2         10      2257      2314    NA    1330
## 128          6        1          9      2398      2483    NA    1335
## 129          9        0         14      2044      2355    NA    1255
## 130          5        4          9      2146      2218    NA    1250
## 131          6        3          9      2504      2374    NA    1420
## 132          3        5          9      2532      2508    NA    1320
## 133          4        5          6      2692      2385    NA    1400
## 134          4        4          6      2740      2585    NA    1415
## 135          5        6          9      2728      2556    NA    1330
## 136          4        3         13      2507      2429    NA    1320
## 137          4        3         14      1974      2107    NA    1285
## 138          1       10          7      2574      2283    NA    1345
## 139          8        6         11      2385      2402    NA    1285
## 140          6        4         11      2322      2409    NA    1350
## 141          2        7          5      2236      2025    NA    1360
## 142          0        3          8      2725      2525    NA    1455
## 143          8        0         15      2030      2455    NA    1285
## 144          3        8          7      2481      2417    NA    1330
## 145          1        8          2      2806      2394    NA    1490
## 146          9        3          8      2091      2243    NA    1240
## 147         11        6          9      2209      2349    NA    1220
## 148          2        6         10      2597      2322    NA    1340
## 149          3        9          8      2479      2413    NA    1250
## 150          1       11          3      2654      2209    NA    1440
## 151          3       14          4      3076      2597    NA    1480
## 152          5        4         12      2545      2584    NA    1375
## 153          5        7          9      2373      2337    NA    1285
## 154          5        5         12      2407      2408    NA    1375
## 155          4        7          7      2612      2575    NA    1290
## 156          3        4         12      2773      2637    NA    1425
## 157          2        9          1      2815      2558    NA    1435
## 158          1        4         10      2386      2235    NA    1335
## 159          4        5          6      2536      2324    NA    1380
## 160          4        5          7      2231      2066    NA    1360
## 161          4        8          7      2278      2125    NA    1360
## 162          5        3         16      2332      2477    NA    1295
## 163          9        2         18      1988      2271    NA    1310
## 164          9        4         11      1833      2011    NA    1285
## 165          7        6         11      2086      2147    NA    1250
## 166          3        6          4      2629      2363    NA    1375
## 167          3        6         10      2978      2979    NA    1495
## 168          4        6          8      2296      2177    NA    1400
## 169          7        2         17      1833      2291    NA    1285
## 170          3        6          5      2429      2228    NA    1360
## 171          5        5         12      2456      2420    NA    1290
## 172          8        1         11      2263      2354    NA    1290
## 173          8        2         14      2149      2303    NA    1245
## 174          2        3          8      2882      2680    NA    1450
## 175          6        2         12      2248      2246    NA    1245
## 176          5        0         10      2297      2275    NA    1285
## 177          5        4         10      2267      2233    NA    1285
## 178          1        8          4      3025      2534    NA    1570
## 179          1        7          4      2575      2158    NA    1480
## 180          5        2         11      2141      2313    NA    1280
## 181          8        3         12      2146      2315    NA    1245
## 182          3        2          9      2543      2498    NA    1445
## 183          3        5          5      2628      2394    NA    1370
## 184          6        0         20      2058      2498    NA    1285
## 185          5        6          5      2485      2347    NA    1325
## 186          5        3         13      2220      2341    NA    1290
## 187          4        5          9      2206      2157    NA    1285
## 188          7        2          8      2150      2168    NA    1290
## 189          6        5         11      2286      2490    NA    1420
## 190          4        4         12      2502      2552    NA    1280
## 191          2        9          5      2665      2397    NA    1405
## 192          7        4         11      2431      2543    NA    1335
## 193          7        2         13      2161      2304    NA    1210
## 194          9        5         13      2092      2286    NA    1240
## 195          1       10          3      2727      2255    NA    1320
## 196          6        4         13      2061      2250    NA    1240
## 197          2        9          8      2523      2454    NA    1290
## 198          5        2         10      2586      2421    NA    1445
## 199          6        6          5      2276      2242    NA    1250
## 200          0        9          3      2723      2270    NA    1360
## 201         10        1         14      1742      1990    NA    1160
## 202          1       10          1      2734      2259    NA    1405
## 203          7        4          9      2443      2454    NA    1280
## 204          4        5          9      2384      2325    NA    1345
## 205          8        5         10      2318      2432    NA    1285
## 206          4        3         13      2260      2302    NA    1250
## 207          5       11          8      2472      2401    NA    1410
## 208          2        9          8      2652      2503    NA    1460
## 209          4        2         18      2145      2358    NA    1285
## 210         10        1         15      1857      2313    NA    1245
## 211          2        7         10      2241      2209    NA    1290
## 212          2        4         12      2429      2266    NA    1365
## 213          2       11          4      2738      2443    NA    1445
## 214          5        4          6      2882      2568    NA    1450
## 215          9        2         12      2515      2670    NA    1335
## 216          2       11          1      3089      2636    NA    1445
## 217          3        4          9      2556      2541    NA    1410
## 218          6        4         11      2220      2196    NA    1200
## 219          3        5         13      2485      2531    NA    1325
## 220          4        6          7      2302      2077    NA    1325
## 221          2        8          6      2564      2406    NA    1385
## 222          7        5         13      2262      2402    NA    1250
## 223          3       11          5      2450      2229    NA    1295
## 224          6        5          9      2506      2413    NA    1375
## 225          5        3          9      2215      2230    NA    1360
## 226          1        7          7      2747      2410    NA    1410
## 227          7        3         13      2051      2280    NA    1250
## 228          8        1          9      2108      2082    NA    1290
## 229          8        1          9      2266      2276    NA    1320
## 230          6        6         10      2534      2515    NA    1325
## 231          6        4          7      2419      2318    NA    1405
## 232          5        3         10      2174      2288    NA    1255
## 233          7        2         10      2178      2288    NA    1285
## 234          4        5          7      2423      2318    NA    1365
## 235          2        8          4      2300      2128    NA    1400
## 236          6        3         13      2314      2483    NA    1285
## 237          5        6          5      2275      2165    NA    1250
## 238          4        5          7      2661      2364    NA    1530
## 239          7        5         10      2138      2241    NA    1290
## 240          6        3          9      2229      2196    NA    1295
## 241          4        8          5      2250      2117    NA    1265
## 242          5        2         11      2572      2529    NA    1370
## 243          7        0         11      2306      2267    NA    1330
## 244          4        3         10      2475      2404    NA    1290
## 245         11        1         12      2078      2389    NA    1290
## 246          0        9         12      2627      2547    NA    1400
## 247          3        8         12      2817      2610    NA    1445
## 248          5        8          6      1948      1951    NA    1135
## 249          7        5          6      2428      2374    NA    1385
## 250          0        6          6      2760      2421    NA    1460
## 251          7        9          6      2294      2255    NA    1270
## 252          3        9          7      2440      2247    NA    1330
## 253          5        5          7      2293      2239    NA    1335
## 254          7        4         11      2367      2481    NA    1305
## 255         10        4          7      2314      2333    NA    1320
## 256          3        6         10      2381      2333    NA    1245
## 257          4        5         13      2448      2403    NA    1420
## 258          7        4          9      2105      2132    NA    1250
## 259          5        4         10      2197      2155    NA    1250
## 260          3        4         13      2558      2509    NA    1285
## 261          4        6         11      2517      2510    NA    1320
## 262          5        2         11      2328      2397    NA    1325
## 263          2        4          8      2399      2297    NA    1440
## 264          3        5          5      2463      2185    NA    1365
## 265          7        2         14      2012      2196    NA    1305
## 266          2        8          9      2476      2307    NA    1345
## 267          6        5          9      2583      2487    NA    1355
## 268          3        4          7      2437      2291    NA    1360
## 269          4        5          9      2591      2455    NA    1460
## 270          3        6          5      2358      2101    NA    1250
## 271         11        0         12      2042      2534    NA    1250
## 272          6        4          6      2115      2172    NA    1255
## 273          5        4         14      2360      2694    NA    1245
## 274          6        4          8      2420      2283    NA    1330
## 275          4        3          8      2508      2443    NA    1375
## 276          7        8          7      2131      2178    NA    1345
## 277          6        3         10      2478      2465    NA    1375
## 278          6        2         19      2388      2593    NA    1375
## 279          9        1         15      2169      2395    NA    1290
## 280          6        4          8      2327      2316    NA    1285
## 281          1        7          6      2789      2425    NA    1320
## 282          6        4          8      2118      2136    NA    1205
## 283          5        5          7      2752      2553    NA    1555
## 284          8        2         13      2216      2378    NA    1265
## 285          5        7          9      2224      2228    NA    1320
## 286          5        2          9      2518      2410    NA    1340
## 287          8        2         11      2265      2520    NA    1280
## 288          6        7          7      2194      2144    NA    1280
## 289          8        3          7      2303      2249    NA    1280
## 290          3        7          7      2392      2160    NA    1330
## 291          4        4         12      2573      2566    NA    1380
## 292          5        1         18      2077      2360    NA    1285
## 293          5        6          7      2250      2145    NA    1385
## 294          3        6         12      2345      2320    NA    1325
## 295          4        4          7      2623      2542    NA    1375
## 296          4        4          9      2255      2227    NA    1245
## 297          6        3          9      2105      2161    NA    1210
## 298          8        0         16      2151      2429    NA    1245
## 299          4       13          4      2364      2188    NA    1335
## 300          6        6          4      2370      2246    NA    1365
## 301          2        8          5      2465      2358    NA    1340
## 302          4        1         14      2356      2486    NA    1250
## 303          7        3         14      2182      2332    NA    1210
## 304         10        3         13      2104      2350    NA    1250
## 305          0        7          3      3035      2580    NA    1505
## 306          7        5          9      2126      2124    NA    1290
## 307          8        3          7      2253      2297    NA    1280
## 308          5        7         10      2284      2303    NA    1345
## 309          5        3          7      2730      2574    NA    1500
## 310          8        0         13      1859      2001    NA    1170
## 311          9        8          7      2634      2623    NA    1490
## 312          4        5          7      2481      2407    NA    1295
## 313          2       13         11      3102      3008    NA    1550
## 314          4       10          5      2470      2204    NA    1370
## 315          1        6          3      2765      2261    NA    1530
## 316          6        2          8      2628      2458    NA    1495
## 317          2        8          5      2537      2256    NA    1330
## 318          8        4          8      2170      2294    NA    1310
## 319          8        4         10      2179      2242    NA    1210
## 320         12        0         11      2082      2403    NA    1240
## 321          3        3          8      2296      2271    NA    1290
## 322          5        3          7      2580      2567    NA    1335
## 323          1        9          4      2753      2349    NA    1410
## 324          1        8          8      2697      2474    NA    1400
## 325          5        6          5      2343      2311    NA    1245
## 326          7        5          8      2205      2187    NA    1335
## 327         10        1         10      2180      2315    NA    1285
## 328          2       11          4      2508      2143    NA    1370
## 329          2        5          6      2654      2425    NA    1455
## 330          1        8          4      2344      2044    NA    1330
## 331          7        2         13      2433      2617    NA    1290
## 332          2        5          5      2574      2172    NA    1410
## 333          1       10          1      2714      2132    NA    1535
## 334          7        6         10      1974      2044    NA    1205
## 335          8        1         10      2119      2344    NA    1250
## 336          7        2          8      2393      2517    NA    1280
## 337          1        7          4      2511      2331    NA    1445
## 338          5        5          7      2617      2454    NA    1330
## 339          7        0         10      2655      2786    NA    1460
## 340          8        3         14      2304      2563    NA    1295
## 341          6        2         14      2198      2272    NA    1245
## 342          4        6          8      2429      2355    NA    1380
## 343          9        2         14      2246      2439    NA    1300
## 344          4        7          7      2609      2542    NA    1485
## 345          5        5         11      2321      2385    NA    1265
## 346          3        7          8      2499      2358    NA    1210
## 347          3        8          5      2333      2099    NA    1385
## 348          1       11          3      2879      2295    NA    1410
## 349          2        5          8      2561      2365    NA    1405
## 350         10        1         11      2105      2411    NA    1285
## 351          5        4          8      2526      2472    NA    1420
## 352          2        8          5      2427      2202    NA    1215
## 353          7        5         11      2415      2526    NA    1305
##     FieldGoalsMade FieldGoalsAttempted FieldGoalPCT ThreePointMade
## 1              897                1911        0.469            251
## 2              802                1776        0.452            234
## 3              797                1948        0.409            297
## 4              736                1809        0.407            182
## 5              906                2003        0.452            234
## 6              712                1764        0.404            216
## 7              856                1945        0.440            244
## 8              728                1750        0.416            274
## 9              709                1721        0.412            211
## 10             780                1645        0.474            190
## 11             880                1938        0.454            292
## 12             899                2012        0.447            240
## 13             794                1861        0.427            235
## 14             817                1687        0.484            206
## 15             719                1685        0.427            194
## 16             796                1904        0.418            237
## 17             893                2004        0.446            259
## 18             837                1956        0.428            272
## 19            1097                2439        0.450            454
## 20             973                2060        0.472            268
## 21             889                1892        0.470            202
## 22             869                1966        0.442            274
## 23            1042                2094        0.498            343
## 24             833                1899        0.439            204
## 25             793                1842        0.431            275
## 26             845                1801        0.469            252
## 27             768                1808        0.425            218
## 28             922                1922        0.480            221
## 29             945                2134        0.443            272
## 30             812                1874        0.433            240
## 31             878                1878        0.468            226
## 32             805                1818        0.443            255
## 33             709                1680        0.422            230
## 34             867                1928        0.450            311
## 35            1083                2344        0.462            344
## 36             861                1934        0.445            292
## 37             706                1715        0.412            225
## 38             887                2092        0.424            221
## 39             868                1911        0.454            187
## 40             968                2103        0.460            234
## 41             831                1859        0.447            287
## 42             735                1673        0.439            203
## 43             987                2159        0.457            252
## 44             792                1787        0.443            279
## 45             825                1819        0.454            204
## 46             739                1735        0.426            207
## 47             867                1906        0.455            313
## 48             798                1834        0.435            256
## 49             810                1903        0.426            276
## 50             754                1821        0.414            201
## 51             819                1763        0.465            229
## 52             991                2177        0.455            305
## 53             926                2156        0.429            324
## 54             598                1442        0.415            191
## 55             833                1881        0.443            290
## 56             718                1752        0.410            141
## 57             872                2018        0.432            232
## 58             899                2011        0.447            370
## 59             833                1857        0.449            217
## 60             799                1834        0.436            303
## 61             899                1986        0.453            284
## 62             955                1995        0.479            320
## 63             878                1818        0.483            227
## 64             866                1818        0.476            259
## 65             924                2036        0.454            230
## 66             778                1720        0.452            237
## 67             874                1959        0.446            252
## 68             710                1827        0.389            240
## 69             754                1705        0.442            243
## 70             980                2044        0.479            372
## 71             791                1750        0.452            264
## 72             852                1893        0.450            312
## 73             902                1789        0.504            205
## 74             695                1963        0.354            234
## 75             830                1808        0.459            282
## 76             755                1723        0.438            227
## 77            1009                2143        0.471            241
## 78             784                1874        0.418            294
## 79             908                1943        0.467            279
## 80             874                1900        0.460            237
## 81            1157                2418        0.478            278
## 82             810                1894        0.428            271
## 83             749                1791        0.418            155
## 84            1004                2067        0.486            274
## 85             826                1912        0.432            272
## 86             902                2125        0.424            272
## 87             818                1823        0.449            187
## 88             876                2040        0.429            310
## 89             812                1862        0.436            335
## 90             747                1776        0.421            264
## 91             761                1755        0.434            259
## 92             921                1939        0.475            269
## 93             719                1640        0.438            180
## 94             809                1971        0.410            290
## 95             809                1787        0.453            269
## 96             986                2239        0.440            279
## 97             960                2171        0.442            272
## 98             857                2015        0.425            291
## 99             759                1890        0.402            276
## 100            847                1866        0.454            342
## 101            930                1962        0.474            338
## 102            955                1962        0.487            281
## 103            825                1855        0.445            210
## 104            745                1842        0.404            196
## 105            894                2017        0.443            269
## 106           1012                2028        0.499            204
## 107            903                1968        0.459            330
## 108            755                1714        0.440            176
## 109            776                1761        0.441            210
## 110           1177                2239        0.526            287
## 111            834                1846        0.452            223
## 112            907                2006        0.452            257
## 113           1106                2413        0.458            303
## 114            966                2236        0.432            291
## 115            848                1862        0.455            322
## 116            787                1711        0.460            260
## 117            788                1746        0.451            266
## 118            763                1719        0.444            180
## 119            998                2055        0.486            308
## 120            848                1834        0.462            237
## 121            865                1896        0.456            200
## 122            982                2203        0.446            333
## 123            937                2163        0.433            244
## 124            779                1742        0.447            274
## 125            778                1764        0.441            251
## 126            865                1883        0.459            303
## 127            813                1887        0.431            244
## 128            862                2001        0.431            259
## 129            711                1527        0.466            174
## 130            757                1719        0.440            178
## 131            919                2009        0.457            211
## 132            857                1897        0.452            297
## 133            974                2047        0.476            294
## 134            914                2006        0.456            285
## 135            991                2059        0.481            360
## 136            891                1969        0.453            234
## 137            717                1774        0.404            155
## 138            953                2063        0.462            200
## 139            889                1953        0.455            213
## 140            821                1859        0.442            243
## 141            806                1878        0.429            241
## 142            989                2128        0.465            260
## 143            742                1945        0.381            136
## 144            878                2032        0.432            261
## 145            978                2050        0.477            215
## 146            719                1798        0.400            259
## 147            802                1786        0.449            280
## 148            902                1976        0.456            228
## 149            856                1775        0.482            287
## 150            963                1977        0.487            322
## 151           1071                2230        0.480            327
## 152            877                2031        0.432            217
## 153            822                1880        0.437            277
## 154            803                1875        0.428            333
## 155            901                2026        0.445            283
## 156            922                2029        0.454            353
## 157            988                2162        0.457            236
## 158            840                1928        0.436            253
## 159            854                1967        0.434            294
## 160            831                1687        0.493            206
## 161            817                1800        0.454            163
## 162            842                1836        0.459            210
## 163            747                1728        0.432            201
## 164            651                1608        0.405            219
## 165            739                1647        0.449            245
## 166            893                1969        0.454            319
## 167           1047                2367        0.442            362
## 168            820                1893        0.433            261
## 169            666                1705        0.391            172
## 170            858                1909        0.449            247
## 171            875                1852        0.472            246
## 172            808                1831        0.441            256
## 173            760                1676        0.453            168
## 174           1013                2238        0.453            260
## 175            787                1746        0.451            228
## 176            805                1851        0.435            268
## 177            777                1847        0.421            269
## 178           1071                2230        0.480            319
## 179            941                2102        0.448            287
## 180            778                1858        0.419            212
## 181            765                1820        0.420            237
## 182            887                2039        0.435            191
## 183            936                1982        0.472            292
## 184            730                1923        0.380            172
## 185            876                1906        0.460            272
## 186            774                1794        0.431            259
## 187            774                1714        0.452            224
## 188            758                1764        0.430            264
## 189            794                1915        0.415            168
## 190            858                1882        0.456            306
## 191            975                1983        0.492            287
## 192            855                1993        0.429            260
## 193            758                1920        0.395            168
## 194            733                1755        0.418            223
## 195            988                2007        0.492            258
## 196            732                1785        0.410            208
## 197            950                1998        0.475            282
## 198            916                2133        0.429            270
## 199            791                1852        0.427            251
## 200            924                1999        0.462            297
## 201            623                1656        0.376            261
## 202            962                2092        0.460            326
## 203            814                1927        0.422            292
## 204            862                1941        0.444            189
## 205            795                1887        0.421            265
## 206            807                1914        0.422            324
## 207            849                1913        0.444            246
## 208            900                2079        0.433            282
## 209            744                1914        0.389            240
## 210            655                1627        0.403            223
## 211            825                1797        0.459            227
## 212            874                1922        0.455            221
## 213            997                2184        0.457            280
## 214           1061                2319        0.458            292
## 215            880                1986        0.443            260
## 216           1118                2410        0.464            312
## 217            874                1926        0.454            332
## 218            822                1771        0.464            241
## 219            902                2014        0.448            308
## 220            831                1910        0.435            284
## 221            880                1848        0.476            328
## 222            785                1819        0.432            259
## 223            849                1837        0.462            307
## 224            940                1995        0.471            229
## 225            769                1847        0.416            276
## 226            979                2047        0.478            306
## 227            725                1790        0.405            190
## 228            735                1827        0.402            233
## 229            776                1973        0.393            272
## 230            864                1859        0.465            314
## 231            839                1931        0.434            264
## 232            803                1838        0.437            187
## 233            760                1796        0.423            280
## 234            883                1975        0.447            226
## 235            823                2026        0.406            264
## 236            854                1874        0.456            266
## 237            800                1728        0.463            203
## 238            958                2126        0.451            295
## 239            710                1681        0.422            198
## 240            791                1898        0.417            222
## 241            821                1810        0.454            282
## 242            865                1949        0.444            313
## 243            769                1841        0.418            225
## 244            856                2017        0.424            238
## 245            707                1708        0.414            216
## 246            903                2061        0.438            225
## 247            966                2150        0.449            394
## 248            685                1666        0.411            207
## 249            835                1973        0.423            225
## 250            967                2145        0.451            365
## 251            739                1730        0.427            348
## 252            893                1938        0.461            285
## 253            821                1914        0.429            172
## 254            795                1867        0.426            277
## 255            849                1800        0.472            251
## 256            847                1893        0.447            222
## 257            861                1991        0.432            280
## 258            771                1842        0.419            191
## 259            806                1800        0.448            175
## 260            885                1926        0.460            243
## 261            885                2035        0.435            254
## 262            793                1943        0.408            280
## 263            855                2052        0.417            205
## 264            899                1905        0.472            253
## 265            707                1639        0.431            184
## 266            889                2011        0.442            308
## 267            921                1951        0.472            254
## 268            845                1940        0.436            261
## 269            914                2002        0.457            284
## 270            864                1851        0.467            258
## 271            713                1765        0.404            210
## 272            735                1653        0.445            239
## 273            825                2080        0.397            351
## 274            852                1945        0.438            238
## 275            888                2021        0.439            240
## 276            772                1779        0.434            288
## 277            867                1883        0.460            285
## 278            811                1891        0.429            193
## 279            775                1872        0.414            269
## 280            806                1907        0.423            242
## 281            984                1965        0.501            327
## 282            729                1664        0.438            227
## 283            911                2120        0.430            272
## 284            796                1809        0.440            266
## 285            765                1735        0.441            235
## 286            937                2039        0.460            281
## 287            794                1898        0.418            201
## 288            802                1720        0.466            213
## 289            833                1884        0.442            263
## 290            899                1929        0.466            275
## 291            881                1997        0.441            272
## 292            752                1710        0.440            180
## 293            821                1914        0.429            208
## 294            841                1989        0.423            270
## 295            944                2100        0.450            289
## 296            808                1783        0.453            207
## 297            745                1696        0.439            201
## 298            794                1962        0.405            215
## 299            815                1937        0.421            233
## 300            808                1907        0.424            274
## 301            873                1998        0.437            247
## 302            854                1915        0.446            250
## 303            751                1739        0.432            240
## 304            742                1784        0.416            213
## 305           1106                2231        0.496            262
## 306            774                1803        0.429            202
## 307            806                1842        0.438            204
## 308            781                1908        0.409            234
## 309            990                2168        0.457            281
## 310            639                1592        0.401            199
## 311            895                2139        0.418            203
## 312            896                2068        0.433            294
## 313           1083                2379        0.455            276
## 314            876                1971        0.444            244
## 315            990                2110        0.469            277
## 316            929                2146        0.433            325
## 317            901                1990        0.453            325
## 318            810                1860        0.435            180
## 319            773                1719        0.450            236
## 320            733                1783        0.411            213
## 321            776                1732        0.448            222
## 322            919                2012        0.457            256
## 323            959                2038        0.471            274
## 324            930                1929        0.482            283
## 325            805                1735        0.464            298
## 326            802                1783        0.450            185
## 327            736                1750        0.421            230
## 328            864                1887        0.458            273
## 329            884                2019        0.438            380
## 330            820                1872        0.438            235
## 331            843                1974        0.427            323
## 332            893                1900        0.470            327
## 333            974                2056        0.474            321
## 334            655                1696        0.386            236
## 335            714                1812        0.394            197
## 336            833                1861        0.448            301
## 337            883                1956        0.451            273
## 338            920                1934        0.476            249
## 339            901                2181        0.413            269
## 340            792                1744        0.454            296
## 341            818                1860        0.440            241
## 342            853                1910        0.447            199
## 343            774                1822        0.425            228
## 344            929                2277        0.408            276
## 345            841                1773        0.474            254
## 346            855                1878        0.455            372
## 347            874                1945        0.449            241
## 348           1044                2132        0.490            385
## 349            885                2028        0.436            281
## 350            690                1656        0.417            248
## 351            922                1977        0.466            245
## 352            893                1812        0.493            230
## 353            879                2057        0.427            303
##     ThreePointAttempts ThreePointPct FreeThrowsMade FreeThrowsAttempted
## 1                  660         0.380            457                 642
## 2                  711         0.329            341                 503
## 3                  929         0.320            380                 539
## 4                  578         0.315            284                 453
## 5                  694         0.337            424                 630
## 6                  673         0.321            446                 684
## 7                  718         0.340            492                 739
## 8                  790         0.347            420                 564
## 9                  646         0.327            366                 543
## 10                 584         0.325            411                 589
## 11                 814         0.359            505                 706
## 12                 714         0.336            600                 882
## 13                 699         0.336            446                 620
## 14                 582         0.354            461                 703
## 15                 574         0.338            476                 702
## 16                 709         0.334            530                 721
## 17                 751         0.345            514                 769
## 18                 863         0.315            322                 471
## 19                1204         0.377            540                 760
## 20                 702         0.382            498                 705
## 21                 621         0.325            498                 709
## 22                 803         0.341            430                 635
## 23                 922         0.372            441                 598
## 24                 635         0.321            420                 689
## 25                 788         0.349            291                 452
## 26                 715         0.352            422                 584
## 27                 687         0.317            442                 633
## 28                 639         0.346            320                 468
## 29                 762         0.357            506                 755
## 30                 653         0.368            465                 672
## 31                 684         0.330            545                 750
## 32                 745         0.342            490                 685
## 33                 708         0.325            440                 618
## 34                 885         0.351            489                 653
## 35                1022         0.337            527                 767
## 36                 827         0.353            360                 488
## 37                 687         0.328            293                 452
## 38                 683         0.324            417                 620
## 39                 589         0.317            514                 726
## 40                 648         0.361            431                 676
## 41                 800         0.359            454                 576
## 42                 619         0.328            365                 515
## 43                 701         0.359            449                 640
## 44                 743         0.376            290                 424
## 45                 594         0.343            496                 693
## 46                 592         0.350            436                 603
## 47                 912         0.343            448                 590
## 48                 791         0.324            398                 575
## 49                 784         0.352            487                 667
## 50                 612         0.328            496                 634
## 51                 628         0.365            518                 798
## 52                 822         0.371            609                 908
## 53                 945         0.343            398                 588
## 54                 615         0.311            389                 524
## 55                 795         0.365            312                 457
## 56                 471         0.299            393                 581
## 57                 673         0.345            534                 758
## 58                1076         0.344            385                 523
## 59                 661         0.328            456                 623
## 60                 820         0.370            399                 585
## 61                 766         0.371            559                 778
## 62                 815         0.393            418                 563
## 63                 667         0.340            470                 615
## 64                 722         0.359            402                 579
## 65                 711         0.323            570                 757
## 66                 655         0.362            266                 377
## 67                 732         0.344            436                 641
## 68                 841         0.285            458                 689
## 69                 731         0.332            398                 551
## 70                 961         0.387            395                 582
## 71                 721         0.366            314                 436
## 72                 882         0.354            393                 525
## 73                 617         0.332            397                 575
## 74                 789         0.297            332                 489
## 75                 746         0.378            410                 564
## 76                 622         0.365            349                 460
## 77                 703         0.343            562                 773
## 78                 825         0.356            417                 581
## 79                 773         0.361            468                 618
## 80                 669         0.354            440                 584
## 81                 903         0.308            551                 803
## 82                 841         0.322            460                 663
## 83                 545         0.284            435                 638
## 84                 758         0.361            425                 634
## 85                 735         0.370            375                 545
## 86                 832         0.327            486                 683
## 87                 634         0.295            380                 604
## 88                 886         0.350            398                 546
## 89                 943         0.355            307                 443
## 90                 776         0.340            476                 660
## 91                 740         0.350            291                 420
## 92                 672         0.400            509                 702
## 93                 489         0.368            309                 503
## 94                 895         0.324            414                 551
## 95                 724         0.372            393                 588
## 96                 923         0.302            547                 855
## 97                 819         0.332            579                 778
## 98                 872         0.334            435                 603
## 99                 831         0.332            314                 462
## 100                897         0.381            412                 572
## 101                935         0.361            364                 508
## 102                719         0.391            527                 741
## 103                637         0.330            454                 634
## 104                631         0.311            411                 600
## 105                757         0.355            568                 771
## 106                632         0.323            498                 720
## 107                859         0.384            462                 694
## 108                573         0.307            405                 588
## 109                653         0.322            512                 726
## 110                790         0.363            602                 791
## 111                553         0.403            535                 781
## 112                777         0.331            487                 666
## 113                879         0.345            575                 818
## 114                844         0.345            622                 790
## 115                846         0.381            459                 619
## 116                722         0.360            388                 538
## 117                751         0.354            399                 576
## 118                583         0.309            409                 605
## 119                800         0.385            615                 767
## 120                670         0.354            283                 424
## 121                588         0.340            535                 793
## 122                939         0.355            490                 697
## 123                669         0.365            566                 780
## 124                752         0.364            366                 498
## 125                678         0.370            367                 507
## 126                856         0.354            358                 525
## 127                734         0.332            387                 540
## 128                751         0.345            415                 591
## 129                508         0.343            448                 553
## 130                491         0.363            454                 621
## 131                676         0.312            455                 695
## 132                845         0.351            521                 699
## 133                811         0.363            450                 615
## 134                782         0.364            627                 849
## 135                949         0.379            386                 557
## 136                695         0.337            491                 699
## 137                554         0.280            385                 607
## 138                634         0.315            468                 630
## 139                645         0.330            394                 582
## 140                670         0.363            437                 607
## 141                721         0.334            383                 574
## 142                743         0.350            487                 691
## 143                438         0.311            410                 590
## 144                775         0.337            464                 641
## 145                607         0.354            635                 859
## 146                783         0.331            394                 512
## 147                736         0.380            325                 437
## 148                664         0.343            565                 823
## 149                679         0.423            480                 620
## 150                873         0.369            406                 524
## 151                876         0.373            607                 801
## 152                630         0.344            574                 831
## 153                813         0.341            452                 643
## 154                939         0.355            468                 639
## 155                821         0.345            527                 710
## 156                891         0.396            576                 737
## 157                740         0.319            603                 802
## 158                756         0.335            453                 690
## 159                860         0.342            534                 687
## 160                563         0.366            363                 545
## 161                510         0.320            481                 645
## 162                616         0.341            438                 617
## 163                647         0.311            293                 452
## 164                661         0.331            312                 534
## 165                675         0.363            363                 530
## 166                822         0.388            524                 692
## 167               1058         0.342            522                 723
## 168                807         0.323            395                 573
## 169                610         0.282            329                 489
## 170                707         0.349            466                 627
## 171                721         0.341            460                 639
## 172                732         0.350            391                 574
## 173                548         0.307            461                 647
## 174                807         0.322            596                 835
## 175                663         0.344            446                 648
## 176                805         0.333            419                 570
## 177                832         0.323            444                 626
## 178                844         0.378            564                 749
## 179                839         0.342            406                 579
## 180                650         0.326            373                 551
## 181                692         0.342            379                 508
## 182                603         0.317            578                 848
## 183                774         0.377            464                 647
## 184                554         0.310            426                 647
## 185                760         0.358            461                 589
## 186                728         0.356            413                 590
## 187                649         0.345            434                 627
## 188                727         0.363            370                 526
## 189                565         0.297            530                 773
## 190                818         0.374            480                 651
## 191                763         0.376            428                 621
## 192                762         0.341            461                 654
## 193                521         0.322            477                 669
## 194                723         0.308            403                 594
## 195                731         0.353            493                 673
## 196                656         0.317            389                 544
## 197                719         0.392            341                 473
## 198                800         0.338            484                 694
## 199                745         0.337            443                 647
## 200                855         0.347            578                 816
## 201                787         0.332            235                 385
## 202                977         0.334            484                 714
## 203                844         0.346            523                 745
## 204                566         0.334            471                 681
## 205                738         0.359            463                 629
## 206                883         0.367            322                 418
## 207                713         0.345            528                 732
## 208                770         0.366            570                 803
## 209                805         0.298            417                 619
## 210                687         0.325            324                 437
## 211                649         0.350            364                 548
## 212                693         0.319            460                 641
## 213                818         0.342            464                 666
## 214                830         0.352            468                 661
## 215                744         0.349            493                 673
## 216                862         0.362            541                 728
## 217                910         0.365            476                 613
## 218                647         0.372            335                 482
## 219                897         0.343            373                 539
## 220                838         0.339            356                 532
## 221                858         0.382            476                 634
## 222                749         0.346            433                 614
## 223                849         0.362            445                 633
## 224                642         0.357            397                 543
## 225                792         0.348            401                 537
## 226                844         0.363            483                 725
## 227                646         0.294            411                 604
## 228                744         0.313            405                 551
## 229                863         0.315            442                 594
## 230                816         0.385            492                 663
## 231                774         0.341            477                 650
## 232                633         0.295            381                 602
## 233                753         0.372            378                 549
## 234                654         0.346            431                 618
## 235                756         0.349            388                 585
## 236                734         0.362            340                 492
## 237                633         0.321            472                 636
## 238                840         0.351            450                 624
## 239                566         0.350            520                 698
## 240                693         0.320            425                 613
## 241                803         0.351            326                 511
## 242                819         0.382            529                 696
## 243                680         0.331            543                 779
## 244                769         0.309            525                 748
## 245                664         0.325            448                 668
## 246                703         0.320            596                 875
## 247               1034         0.381            491                 674
## 248                679         0.305            371                 502
## 249                690         0.326            533                 771
## 250                977         0.374            461                 641
## 251                923         0.377            468                 646
## 252                751         0.379            369                 515
## 253                615         0.280            479                 704
## 254                797         0.348            500                 729
## 255                723         0.347            365                 552
## 256                651         0.341            465                 755
## 257                789         0.355            446                 638
## 258                612         0.312            372                 584
## 259                527         0.332            410                 592
## 260                681         0.357            545                 722
## 261                724         0.351            493                 698
## 262                869         0.322            462                 615
## 263                675         0.304            484                 809
## 264                670         0.378            412                 555
## 265                567         0.325            414                 570
## 266                840         0.367            390                 518
## 267                687         0.370            487                 666
## 268                721         0.362            486                 679
## 269                808         0.351            479                 641
## 270                727         0.355            372                 568
## 271                641         0.328            406                 620
## 272                663         0.360            406                 567
## 273               1199         0.293            359                 531
## 274                642         0.371            478                 668
## 275                741         0.324            492                 697
## 276                849         0.339            299                 440
## 277                761         0.375            459                 669
## 278                582         0.332            573                 772
## 279                817         0.329            350                 492
## 280                662         0.366            473                 694
## 281                802         0.408            494                 635
## 282                666         0.341            433                 585
## 283                819         0.332            658                1018
## 284                719         0.370            358                 519
## 285                696         0.338            459                 640
## 286                735         0.382            363                 563
## 287                665         0.302            476                 677
## 288                570         0.374            377                 550
## 289                772         0.341            374                 523
## 290                712         0.386            321                 489
## 291                799         0.340            539                 757
## 292                544         0.331            393                 588
## 293                635         0.328            400                 539
## 294                806         0.335            393                 580
## 295                809         0.357            446                 620
## 296                653         0.317            432                 643
## 297                588         0.342            414                 607
## 298                684         0.314            348                 503
## 299                715         0.326            501                 695
## 300                824         0.333            480                 701
## 301                748         0.330            472                 649
## 302                726         0.344            398                 528
## 303                716         0.335            440                 628
## 304                620         0.344            407                 645
## 305                714         0.367            561                 744
## 306                621         0.325            376                 541
## 307                663         0.308            437                 631
## 308                773         0.303            488                 659
## 309                813         0.346            469                 688
## 310                620         0.321            382                 578
## 311                636         0.319            641                 923
## 312                855         0.344            395                 536
## 313                852         0.324            660                 988
## 314                744         0.328            474                 694
## 315                759         0.365            508                 694
## 316                934         0.348            445                 637
## 317                859         0.378            410                 531
## 318                550         0.327            370                 532
## 319                704         0.335            397                 550
## 320                670         0.318            403                 585
## 321                652         0.340            522                 751
## 322                721         0.355            486                 768
## 323                772         0.355            559                 747
## 324                740         0.382            554                 764
## 325                806         0.370            435                 616
## 326                585         0.316            416                 595
## 327                739         0.311            478                 710
## 328                761         0.359            507                 678
## 329               1081         0.352            506                 695
## 330                771         0.305            469                 669
## 331                899         0.359            424                 581
## 332                831         0.394            461                 606
## 333                813         0.395            445                 598
## 334                773         0.305            428                 575
## 335                640         0.308            494                 681
## 336                828         0.364            426                 564
## 337                780         0.350            472                 679
## 338                684         0.364            528                 708
## 339                852         0.316            584                 849
## 340                800         0.370            424                 628
## 341                626         0.385            321                 440
## 342                608         0.327            524                 724
## 343                723         0.315            470                 680
## 344                890         0.310            475                 655
## 345                735         0.346            385                 576
## 346                997         0.373            417                 565
## 347                672         0.359            344                 531
## 348                929         0.414            406                 577
## 349                818         0.344            510                 692
## 350                720         0.344            477                 660
## 351                740         0.331            437                 644
## 352                634         0.363            411                 557
## 353                891         0.340            354                 505
##     FreeThrowPCT OffensiveRebounds TotalRebounds Assists Steals Blocks
## 1          0.712               325          1110     525    297     93
## 2          0.678               253          1077     434    154     57
## 3          0.705               312          1204     399    185    106
## 4          0.627               314          1032     385    234     50
## 5          0.673               367          1279     401    218     82
## 6          0.652               365          1094     313    203    102
## 7          0.666               384          1285     418    157    160
## 8          0.745               294          1081     402    195     78
## 9          0.674               334          1079     391    229    107
## 10         0.698               251          1014     402    221    131
## 11         0.715               310          1127     406    171     90
## 12         0.680               399          1351     459    213    109
## 13         0.719               324          1115     398    165     73
## 14         0.656               244          1060     443    169     87
## 15         0.678               317          1063     365    216    109
## 16         0.735               403          1211     363    183    139
## 17         0.668               345          1152     543    276    172
## 18         0.684               259          1125     499    198     50
## 19         0.711               457          1369     572    369    190
## 20         0.706               397          1215     454    252    110
## 21         0.702               308          1243     426    217    118
## 22         0.677               446          1281     473    209    159
## 23         0.737               286          1275     645    220    125
## 24         0.610               415          1274     444    234    108
## 25         0.644               244          1060     324    183    152
## 26         0.723               242          1016     398    200     68
## 27         0.698               331          1139     382    159    103
## 28         0.684               311          1091     447    199     73
## 29         0.670               408          1396     427    227     90
## 30         0.692               313          1195     423    186    132
## 31         0.727               263          1118     482    203    107
## 32         0.715               261          1157     418    241    123
## 33         0.712               285           969     319    158     79
## 34         0.749               286          1154     519    173    116
## 35         0.687               452          1470     599    263    140
## 36         0.738               288          1058     434    193     62
## 37         0.648               284           975     301    147     99
## 38         0.673               486          1272     379    218    105
## 39         0.708               277          1224     407    200    118
## 40         0.638               352          1214     512    225    154
## 41         0.788               306          1171     345    148     85
## 42         0.709               218           929     375    196     71
## 43         0.702               429          1471     479    210    153
## 44         0.684               281          1051     425    164     60
## 45         0.716               379          1204     431    159    106
## 46         0.723               249           900     338    227     99
## 47         0.759               266          1050     482    218    104
## 48         0.692               300          1026     466    204    108
## 49         0.730               299          1164     463    202    120
## 50         0.782               332          1107     353    172    110
## 51         0.649               315          1215     439    189    150
## 52         0.671               419          1321     467    267    107
## 53         0.677               407          1277     487    263    110
## 54         0.742               199           892     288    138    101
## 55         0.683               278          1095     418    139     79
## 56         0.676               249           995     376    193     72
## 57         0.704               442          1264     466    214    155
## 58         0.736               322          1107     462    201    110
## 59         0.732               309          1204     410    223    154
## 60         0.682               303          1093     460    174     97
## 61         0.719               376          1256     451    214     78
## 62         0.742               322          1240     541    213    121
## 63         0.764               260          1060     387    216     76
## 64         0.694               256          1080     472    199     76
## 65         0.753               363          1352     478    181    107
## 66         0.706               255           985     443    218     78
## 67         0.680               380          1167     422    200    145
## 68         0.665               314          1218     326    169    115
## 69         0.722               191          1015     453    181    107
## 70         0.679               288          1196     561    237     92
## 71         0.720               246          1020     426    158    100
## 72         0.749               264          1185     499    175     82
## 73         0.690               261          1145     541    164     81
## 74         0.679               378          1144     333    214     66
## 75         0.727               254          1083     425    149     78
## 76         0.759               275          1041     354    142     78
## 77         0.727               396          1347     513    227    117
## 78         0.718               336          1019     319    238     77
## 79         0.757               279          1214     518    180    130
## 80         0.753               312          1126     464    144     62
## 81         0.686               495          1567     606    346    257
## 82         0.694               379          1133     442    250    151
## 83         0.682               317          1061     382    224    110
## 84         0.670               442          1351     534    252    135
## 85         0.688               347          1147     434    200    120
## 86         0.712               362          1167     458    317    101
## 87         0.629               400          1155     369    237    143
## 88         0.729               299          1192     467    200    101
## 89         0.693               265          1082     468    135     62
## 90         0.721               215          1095     394    185     89
## 91         0.693               273           968     401    202     63
## 92         0.725               323          1155     486    261    132
## 93         0.614               288           991     355    226    111
## 94         0.751               366          1296     419    184     93
## 95         0.668               272          1064     449    219    133
## 96         0.640               367          1217     491    359    153
## 97         0.744               418          1391     475    266    161
## 98         0.721               375          1201     437    257    131
## 99         0.680               305          1082     360    188    108
## 100        0.720               300          1137     457    228    111
## 101        0.717               326          1171     524    288    137
## 102        0.711               271          1190     502    238    101
## 103        0.716               323          1166     399    204     97
## 104        0.685               274          1116     375    170     96
## 105        0.737               350          1299     542    198    131
## 106        0.692               316          1190     403    255    132
## 107        0.666               273          1110     415    269    158
## 108        0.689               262          1074     433    221    166
## 109        0.705               357          1215     423    185    163
## 110        0.761               354          1443     668    278    204
## 111        0.685               307          1287     420    193    147
## 112        0.731               350          1238     478    207     75
## 113        0.703               376          1406     578    291    154
## 114        0.787               363          1370     487    215    121
## 115        0.742               278          1050     462    228     69
## 116        0.721               288          1119     369    174    123
## 117        0.693               278          1054     478    156     66
## 118        0.676               363          1183     404    170     91
## 119        0.802               305          1170     492    228    122
## 120        0.667               220           916     513    241    127
## 121        0.675               409          1142     449    234     54
## 122        0.703               448          1502     548    240    161
## 123        0.726               396          1253     463    198    144
## 124        0.735               275           975     383    154     88
## 125        0.724               258          1061     399    130     53
## 126        0.682               271          1106     478    210    124
## 127        0.717               298          1139     421    162    106
## 128        0.702               351          1091     446    245     86
## 129        0.810               204           845     354    184     53
## 130        0.731               250          1007     342    207     73
## 131        0.655               341          1272     469    226    154
## 132        0.745               283          1152     432    223     90
## 133        0.732               327          1230     527    247    160
## 134        0.739               357          1246     542    211    112
## 135        0.693               271          1140     525    247    158
## 136        0.702               403          1233     471    228    103
## 137        0.634               331          1125     359    209    124
## 138        0.743               400          1310     451    245    138
## 139        0.677               330          1163     457    213    166
## 140        0.720               345          1123     403    211    101
## 141        0.667               320          1137     464    256     76
## 142        0.705               374          1376     478    243    139
## 143        0.695               372          1163     362    185    106
## 144        0.724               412          1185     430    226    119
## 145        0.739               427          1428     501    220    176
## 146        0.770               328          1060     391    230     98
## 147        0.744               233          1004     419    158    126
## 148        0.687               446          1282     481    283     97
## 149        0.774               232          1105     471    171     71
## 150        0.775               270          1174     532    223     96
## 151        0.758               329          1378     654    268    108
## 152        0.691               377          1263     399    219    105
## 153        0.703               321          1196     430    218    157
## 154        0.732               284          1194     401    210     71
## 155        0.742               363          1142     487    226    125
## 156        0.782               317          1176     498    206     78
## 157        0.752               460          1355     452    308    148
## 158        0.657               368          1204     440    190    115
## 159        0.777               345          1297     458    149     99
## 160        0.666               190          1013     468    220     78
## 161        0.746               314          1098     460    250    102
## 162        0.710               292           997     448    278     73
## 163        0.648               280          1015     471    239     94
## 164        0.584               326          1026     360    221     78
## 165        0.685               241           967     377    172     53
## 166        0.757               331          1292     456    168    145
## 167        0.722               319          1260     527    334    170
## 168        0.689               296          1145     453    268     83
## 169        0.673               264           989     361    186     70
## 170        0.743               378          1336     447    148    163
## 171        0.720               293          1115     500    181     85
## 172        0.681               342          1123     468    154     93
## 173        0.713               310          1054     429    147     97
## 174        0.714               436          1358     553    288    144
## 175        0.688               307          1057     393    207     80
## 176        0.735               291          1061     413    212    100
## 177        0.709               353          1190     349    194     87
## 178        0.753               414          1579     715    201    205
## 179        0.701               299          1307     512    225    149
## 180        0.677               382          1228     352    190     85
## 181        0.746               288          1094     356    145     94
## 182        0.682               402          1314     523    175    140
## 183        0.717               393          1215     481    274    172
## 184        0.658               378          1165     361    176     70
## 185        0.783               322          1128     475    235    118
## 186        0.700               261           966     351    233     90
## 187        0.692               270          1000     354    221    127
## 188        0.703               345          1130     354    149     53
## 189        0.686               360          1224     379    237    101
## 190        0.737               292          1083     491    169     46
## 191        0.689               293          1176     510    229    106
## 192        0.705               357          1177     440    186    137
## 193        0.713               397          1078     362    230     48
## 194        0.678               293          1036     354    146    107
## 195        0.733               351          1247     591    249    149
## 196        0.715               359          1160     399    167     58
## 197        0.721               273          1047     409    180     61
## 198        0.697               379          1278     466    260    151
## 199        0.685               408          1204     401    184    115
## 200        0.708               325          1274     498    211    134
## 201        0.610               260           986     325    116     53
## 202        0.678               445          1343     514    197     91
## 203        0.702               351          1199     446    220    107
## 204        0.692               393          1166     497    285    134
## 205        0.736               315          1143     343    128    127
## 206        0.770               280          1041     428    208    128
## 207        0.721               250          1178     376    223     94
## 208        0.710               366          1318     457    219    154
## 209        0.674               351          1170     334    209     74
## 210        0.741               298           931     331    196     86
## 211        0.664               291          1059     452    215    108
## 212        0.718               399          1265     526    207     93
## 213        0.697               399          1251     453    315    140
## 214        0.708               486          1390     539    257    138
## 215        0.733               387          1221     495    150     68
## 216        0.743               477          1589     678    252    120
## 217        0.777               229          1105     402    160     87
## 218        0.695               233          1009     398    171     87
## 219        0.692               363          1252     520    212    165
## 220        0.669               368          1244     428    210     88
## 221        0.751               237          1075     480    211     74
## 222        0.705               290          1055     381    196     65
## 223        0.703               309          1128     422    176    101
## 224        0.731               304          1179     374    188     75
## 225        0.747               262          1115     370    165     75
## 226        0.666               364          1298     592    218    139
## 227        0.680               352          1103     340    192    138
## 228        0.735               278          1086     451    176    134
## 229        0.744               370          1208     423    179    148
## 230        0.742               275          1063     580    191     99
## 231        0.734               328          1215     494    206     85
## 232        0.633               332          1152     451    200    115
## 233        0.689               295          1093     422    183    139
## 234        0.697               305          1263     430    203    102
## 235        0.663               418          1365     439    197    160
## 236        0.691               335          1147     434    152    107
## 237        0.742               310          1091     465    185    164
## 238        0.721               361          1307     501    290    162
## 239        0.745               285          1039     325    199     46
## 240        0.693               382          1174     389    245    122
## 241        0.638               270          1101     465    210     76
## 242        0.760               290          1085     479    229     95
## 243        0.697               383          1211     387    227    126
## 244        0.702               491          1282     434    264    130
## 245        0.671               233          1032     369    175    123
## 246        0.681               392          1151     445    309     55
## 247        0.728               324          1248     565    214     69
## 248        0.739               272          1016     295    168     72
## 249        0.691               399          1241     491    253    136
## 250        0.719               421          1341     518    220    143
## 251        0.724               311          1111     393    159     62
## 252        0.717               335          1170     467    196    101
## 253        0.680               375          1194     401    235    129
## 254        0.686               316          1221     425    171    104
## 255        0.661               196           957     519    249    101
## 256        0.616               363          1144     450    282    101
## 257        0.699               373          1178     487    257     92
## 258        0.637               391          1210     390    201    124
## 259        0.693               308          1050     431    239    104
## 260        0.755               354          1231     471    170    133
## 261        0.706               430          1246     413    221     94
## 262        0.751               258          1145     397    186    110
## 263        0.598               492          1428     460    254    145
## 264        0.742               329          1180     341    201     87
## 265        0.726               293          1032     301    172    177
## 266        0.753               369          1191     555    242     94
## 267        0.731               316          1225     461    238    127
## 268        0.716               346          1228     487    197    113
## 269        0.747               290          1238     516    204    112
## 270        0.655               340          1138     439    188    105
## 271        0.655               323          1130     423    131     52
## 272        0.716               242          1026     416    146    111
## 273        0.676               383          1188     462    234     96
## 274        0.716               336          1221     386    141    118
## 275        0.706               361          1213     459    235    132
## 276        0.680               248           973     415    190     93
## 277        0.686               288          1094     471    201    141
## 278        0.742               376          1137     386    167     60
## 279        0.711               305          1051     434    207     94
## 280        0.682               383          1160     413    202    140
## 281        0.778               251          1259     489    202     65
## 282        0.740               219           942     382    165     68
## 283        0.646               496          1483     521    306    124
## 284        0.690               284          1081     402    182     75
## 285        0.717               346          1117     452    215     80
## 286        0.645               324          1188     536    202    117
## 287        0.703               351          1079     382    198     70
## 288        0.685               289          1081     438    212    129
## 289        0.715               365          1135     441    189    123
## 290        0.656               274          1178     553    253    110
## 291        0.712               282          1250     426    199    114
## 292        0.668               313           980     372    216     86
## 293        0.742               333          1183     417    199    164
## 294        0.678               346          1191     387    194    136
## 295        0.719               264          1120     472    302    111
## 296        0.672               322          1147     392    186    147
## 297        0.682               313          1008     348    192    113
## 298        0.692               359          1110     418    210     94
## 299        0.721               410          1348     372    209    142
## 300        0.685               363          1174     408    278    162
## 301        0.727               316          1136     476    284     73
## 302        0.754               351          1062     441    223     88
## 303        0.701               317          1032     342    219     78
## 304        0.631               330          1122     389    226    134
## 305        0.754               379          1391     660    221    199
## 306        0.695               349          1158     423    197     90
## 307        0.693               372          1195     376    215    142
## 308        0.741               372          1235     421    211     97
## 309        0.682               395          1347     598    255    162
## 310        0.661               285          1070     307    135     84
## 311        0.694               358          1215     503    345    105
## 312        0.737               323          1216     420    213     82
## 313        0.668               467          1503     591    309    114
## 314        0.683               409          1291     493    234     84
## 315        0.732               315          1297     518    278    186
## 316        0.699               358          1264     486    227    152
## 317        0.772               327          1281     538    170    152
## 318        0.695               389          1184     319    154     94
## 319        0.722               277          1021     392    171    135
## 320        0.689               298          1131     444    147    109
## 321        0.695               239          1119     430    176     76
## 322        0.633               380          1361     472    194    136
## 323        0.748               377          1405     598    215    147
## 324        0.725               311          1271     484    201     89
## 325        0.706               317          1096     440    144     80
## 326        0.699               294          1115     431    202    101
## 327        0.673               325          1139     371    154    126
## 328        0.748               304          1194     399    188    136
## 329        0.728               368          1253     503    194    106
## 330        0.701               358          1208     450    263    148
## 331        0.730               280          1110     442    217     61
## 332        0.761               310          1142     531    236     78
## 333        0.744               342          1326     544    211    149
## 334        0.744               378          1095     351    184    108
## 335        0.725               399          1174     329    150     77
## 336        0.755               276          1076     478    169     89
## 337        0.695               334          1129     419    323    206
## 338        0.746               220          1177     383    179    140
## 339        0.688               519          1425     488    223    126
## 340        0.675               303          1135     389    135     53
## 341        0.730               254          1100     319    165    132
## 342        0.724               338          1256     417    235    174
## 343        0.691               345          1197     374    147     78
## 344        0.725               452          1417     499    174    135
## 345        0.668               251          1057     529    158    146
## 346        0.738               330          1232     460    134     83
## 347        0.648               283          1197     430    177    140
## 348        0.704               365          1232     528    233    105
## 349        0.737               382          1229     484    214     72
## 350        0.723               167           983     331    176     88
## 351        0.679               371          1281     519    190    128
## 352        0.738               259          1157     503    177    131
## 353        0.701               418          1207     449    210    115
##     Turnovers PersonalFouls
## 1         407           635
## 2         423           543
## 3         388           569
## 4         487           587
## 5         399           578
## 6         451           565
## 7         465           572
## 8         454           566
## 9         492           548
## 10        386           520
## 11        418           585
## 12        466           675
## 13        370           594
## 14        503           622
## 15        478           629
## 16        448           684
## 17        450           693
## 18        376           544
## 19        466           731
## 20        392           596
## 21        480           579
## 22        446           636
## 23        376           509
## 24        501           610
## 25        409           474
## 26        379           570
## 27        378           509
## 28        425           578
## 29        412           596
## 30        440           617
## 31        354           625
## 32        458           600
## 33        383           575
## 34        409           627
## 35        433           659
## 36        359           593
## 37        334           544
## 38        439           747
## 39        450           639
## 40        410           641
## 41        379           623
## 42        412           596
## 43        441           673
## 44        425           562
## 45        355           558
## 46        352           574
## 47        337           522
## 48        412           627
## 49        478           611
## 50        427           597
## 51        393           554
## 52        425           593
## 53        441           571
## 54        418           490
## 55        409           553
## 56        512           625
## 57        365           563
## 58        386           528
## 59        450           552
## 60        412           551
## 61        472           691
## 62        456           547
## 63        347           486
## 64        372           522
## 65        479           616
## 66        366           539
## 67        427           643
## 68        555           620
## 69        414           492
## 70        464           580
## 71        361           468
## 72        378           539
## 73        414           463
## 74        435           589
## 75        378           523
## 76        408           506
## 77        488           630
## 78        355           528
## 79        449           568
## 80        377           542
## 81        488           595
## 82        451           580
## 83        416           622
## 84        483           603
## 85        427           569
## 86        447           661
## 87        442           529
## 88        401           632
## 89        413           539
## 90        416           602
## 91        436           612
## 92        477           578
## 93        499           580
## 94        485           575
## 95        479           514
## 96        477           655
## 97        492           705
## 98        420           614
## 99        345           559
## 100       400           592
## 101       407           481
## 102       407           561
## 103       428           563
## 104       413           526
## 105       443           581
## 106       451           590
## 107       391           583
## 108       459           560
## 109       506           565
## 110       394           603
## 111       536           699
## 112       411           598
## 113       500           730
## 114       379           649
## 115       401           556
## 116       491           554
## 117       368           556
## 118       406           502
## 119       342           526
## 120       350           482
## 121       442           593
## 122       410           705
## 123       427           652
## 124       360           497
## 125       433           582
## 126       457           684
## 127       417           577
## 128       435           700
## 129       504           592
## 130       402           586
## 131       433           596
## 132       406           564
## 133       379           517
## 134       427           565
## 135       395           495
## 136       462           578
## 137       436           643
## 138       440           553
## 139       463           523
## 140       420           612
## 141       385           550
## 142       472           610
## 143       437           525
## 144       378           601
## 145       466           600
## 146       435           630
## 147       402           515
## 148       473           622
## 149       418           571
## 150       395           543
## 151       489           633
## 152       479           620
## 153       471           610
## 154       477           624
## 155       423           612
## 156       398           545
## 157       452           634
## 158       386           535
## 159       412           591
## 160       407           471
## 161       425           602
## 162       444           573
## 163       460           566
## 164       487           672
## 165       387           583
## 166       467           635
## 167       453           664
## 168       428           578
## 169       431           575
## 170       437           526
## 171       447           589
## 172       445           643
## 173       450           467
## 174       538           739
## 175       407           557
## 176       372           465
## 177       413           581
## 178       493           647
## 179       334           514
## 180       512           583
## 181       382           579
## 182       418           578
## 183       451           586
## 184       415           570
## 185       416           603
## 186       391           647
## 187       385           540
## 188       448           625
## 189       502           698
## 190       394           567
## 191       416           655
## 192       402           561
## 193       401           614
## 194       410           576
## 195       401           527
## 196       437           534
## 197       304           486
## 198       345           580
## 199       401           556
## 200       352           584
## 201       356           533
## 202       419           632
## 203       455           627
## 204       517           631
## 205       390           511
## 206       386           587
## 207       421           582
## 208       523           763
## 209       435           614
## 210       456           533
## 211       417           514
## 212       515           610
## 213       423           631
## 214       449           691
## 215       436           585
## 216       473           611
## 217       368           523
## 218       380           485
## 219       536           573
## 220       443           589
## 221       381           539
## 222       372           537
## 223       398           538
## 224       404           653
## 225       393           554
## 226       441           664
## 227       496           578
## 228       349           583
## 229       306           455
## 230       426           534
## 231       438           623
## 232       448           504
## 233       386           516
## 234       401           527
## 235       408           580
## 236       447           575
## 237       384           536
## 238       442           665
## 239       423           630
## 240       399           597
## 241       395           500
## 242       432           639
## 243       448           611
## 244       449           681
## 245       425           588
## 246       445           758
## 247       358           617
## 248       354           459
## 249       445           600
## 250       381           625
## 251       415           524
## 252       358           528
## 253       405           582
## 254       438           568
## 255       336           488
## 256       415           591
## 257       507           683
## 258       408           566
## 259       404           566
## 260       465           572
## 261       402           598
## 262       305           497
## 263       464           634
## 264       355           572
## 265       488           614
## 266       413           659
## 267       463           560
## 268       424           638
## 269       466           667
## 270       321           543
## 271       484           539
## 272       433           597
## 273       478           564
## 274       403           657
## 275       423           638
## 276       321           462
## 277       456           649
## 278       493           670
## 279       440           621
## 280       433           623
## 281       388           557
## 282       324           527
## 283       604           790
## 284       447           615
## 285       536           602
## 286       392           590
## 287       438           612
## 288       447           474
## 289       350           515
## 290       345           507
## 291       466           696
## 292       511           716
## 293       421           553
## 294       413           635
## 295       357           650
## 296       467           586
## 297       442           579
## 298       394           536
## 299       478           631
## 300       423           588
## 301       368           581
## 302       418           490
## 303       497           735
## 304       517           554
## 305       412           654
## 306       456           610
## 307       444           521
## 308       467           630
## 309       499           586
## 310       466           551
## 311       471           763
## 312       402           581
## 313       589           679
## 314       455           667
## 315       457           663
## 316       401           627
## 317       402           517
## 318       390           561
## 319       408           523
## 320       467           535
## 321       404           529
## 322       467           563
## 323       449           649
## 324       487           612
## 325       409           548
## 326       439           546
## 327       454           568
## 328       377           568
## 329       388           580
## 330       458           650
## 331       390           541
## 332       392           532
## 333       342           542
## 334       414           639
## 335       417           555
## 336       440           554
## 337       479           653
## 338       382           609
## 339       557           707
## 340       577           671
## 341       353           487
## 342       466           528
## 343       490           564
## 344       446           705
## 345       390           516
## 346       456           535
## 347       327           511
## 348       377           589
## 349       402           545
## 350       450           588
## 351       450           550
## 352       392           510
## 353       423           656
```

And just like that, we have a method for getting up to the minute season stats for every team in Division I. 
