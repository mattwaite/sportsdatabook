# Advanced rvest

With the chapter, we learned how to grab one table from one page. But what if you needed more than that? What if you needed hundreds of tables from hundreds of pages? What if you needed to combine one table on one page into a bigger table, but hundreds of times. There's a way to do this, it just takes patience, a lot of logic, a lot of debugging and, for me, a fair bit of swearing. 

So what we are after are game by game stats for each college basketball team in America. 

[We can see from this page](https://www.sports-reference.com/cbb/seasons/2019-school-stats.html) that each team is linked. If we follow each link, we get a ton of tables. But they aren't what we need. There's a link to gamelogs underneath the team names. 

So we can see from this that we've got some problems. 

1. The team name isn't in the table. Nor is the conference.
2. There's a date we'll have to deal with. 
3. Non-standard headers and a truly huge number of fields. 
4. And how do we get each one of those urls without having to copy them all into some horrible list? 

So let's start with that last question first and grab libraries we need.


```r
library(tidyverse)
```

```
## ── Attaching packages ─────────────────
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
## ── Conflicts ──────────────────────────
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

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

```
## 
## Attaching package: 'rvest'
```

```
## The following object is masked from 'package:purrr':
## 
##     pluck
```

```
## The following object is masked from 'package:readr':
## 
##     guess_encoding
```

```r
library(lubridate)
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following object is masked from 'package:base':
## 
##     date
```

First things first, we need to grab the url to each team from that first link.


```r
url <- "https://www.sports-reference.com/cbb/seasons/2019-school-stats.html"
```

But notice first, we don't want to grab the table. The table doesn't help us. We need to grab the only *link* in the table. So we can do that by using the table xpath node, then grabbing the anchor tags in the table, then get only the link out of them (instead of the linked text). 


```r
schools <- url %>%
  read_html() %>%
  html_nodes(xpath = '//*[@id="basic_school_stats"]') %>%
  html_nodes("a") %>%
  html_attr('href')
```

Notice we now have a list called schools with ... 353 elements. That's the number of teams in college basketball, so we're off to a good start. Here's what the fourth element is. 


```r
schools[4]
```

```
## [1] "/cbb/schools/alabama-am/2019.html"
```

So note, that's the relative path to Alabama A&M's team page. By relative path, I mean it doesn't have the root domain. So we need to add that to each request or we'll get no where. 

So that's a problem to note. 

Before we solve that, let's just make sure we can get one page and get what we need. 

We'll scrape Abilene Christian. 

To merge all this into one big table, we need to grab the team name and their conference and merge it into the table. But those values come from somewhere else. The scraping works just about the same, but instead of html_table you use html_text. 

So the first part of this is reading the html of the page so we don't do that for each element -- we just do it once so as to not overwhelm their servers. 

The second part is we're grabbing the team name based on it's location in the page. 

Third: The conference.

Fourth is the table itself, noting to ignore the headers. The last bit fixes the headers, removes the garbage header data from the table, converts the data to numbers, fixes the date and mutates a team and conference value. It looks like a lot, and it took a bit of twiddling to get it done, but it's no different from what you did for your last homework. 


```r
page <- read_html("https://www.sports-reference.com/cbb/schools/abilene-christian/2019-gamelogs.html")
  
team <- page %>%
  html_nodes(xpath = '//*[@id="meta"]/div[2]/h1/span[2]') %>%
  html_text()

conference <- page %>%
    html_nodes(xpath = '//*[@id="meta"]/div[2]/p[1]/a') %>%
    html_text()

table <- page %>%
  html_nodes(xpath = '//*[@id="sgl-basic"]') %>%
  html_table(header=FALSE)

table <- table[[1]] %>% rename(Game=X1, Date=X2, HomeAway=X3, Opponent=X4, W_L=X5, TeamScore=X6, OpponentScore=X7, TeamFG=X8, TeamFGA=X9, TeamFGPCT=X10, Team3P=X11, Team3PA=X12, Team3PPCT=X13, TeamFT=X14, TeamFTA=X15, TeamFTPCT=X16, TeamOffRebounds=X17, TeamTotalRebounds=X18, TeamAssists=X19, TeamSteals=X20, TeamBlocks=X21, TeamTurnovers=X22, TeamPersonalFouls=X23, Blank=X24, OpponentFG=X25, OpponentFGA=X26, OpponentFGPCT=X27, Opponent3P=X28, Opponent3PA=X29, Opponent3PPCT=X30, OpponentFT=X31, OpponentFTA=X32, OpponentFTPCT=X33, OpponentOffRebounds=X34, OpponentTotalRebounds=X35, OpponentAssists=X36, OpponentSteals=X37, OpponentBlocks=X38, OpponentTurnovers=X39, OpponentPersonalFouls=X40) %>% filter(Game != "") %>% filter(Game != "G") %>% mutate(Team=team) %>% mutate_at(vars(-Team, -Date, -Opponent, -HomeAway, -W_L), as.numeric) %>% mutate(Date = ymd(Date)) %>% mutate(Team=team, Conference=conference)
```

Now what we're left with is how do we do this for ALL the teams. We need to send 353 requests to their servers to get each page. And each url is not the one we have -- we need to alter it. 

First we have to add the root domain to each request. And, each request needs to go to /2019-gamelogs.html instead of /2019.html. If you look at the urls two the page we have and the page we need, that's all that changes. 

What we're going to use is what is known in programming as a loop. We can loop through a list and have it do something to each element in the loop. And once it's done, we can move on to the next thing. 

Think of it like a program that will go though a list of your classmates and ask each one of them for their year in school. It will start at one end of the list and move through asking each one "What year in school are you?" and will move on after getting an answer. 

Except we want to take a url, add something to it, alter it, then request it and grab a bunch of data from it. Once we're done doing all that, we'll take all that info and cram it into a bigger dataset and then move on to the next one. Here's what that looks like:


```r
uri <- "https://www.sports-reference.com"

logs <- tibble()

for (i in schools){
  log_url <- gsub("/2019.html","/2019-gamelogs.html", i)
  school_url <- paste(uri, log_url, sep="")  # creating the url to fetch
  
  page <- read_html(school_url)
  
  team <- page %>%
    html_nodes(xpath = '//*[@id="meta"]/div[2]/h1/span[2]') %>%
    html_text()
  
  conference <- page %>%
    html_nodes(xpath = '//*[@id="meta"]/div[2]/p[1]/a') %>%
    html_text()

  table <- page %>%
    html_nodes(xpath = '//*[@id="sgl-basic"]') %>%
    html_table(header=FALSE)

table <- table[[1]] %>% rename(Game=X1, Date=X2, HomeAway=X3, Opponent=X4, W_L=X5, TeamScore=X6, OpponentScore=X7, TeamFG=X8, TeamFGA=X9, TeamFGPCT=X10, Team3P=X11, Team3PA=X12, Team3PPCT=X13, TeamFT=X14, TeamFTA=X15, TeamFTPCT=X16, TeamOffRebounds=X17, TeamTotalRebounds=X18, TeamAssists=X19, TeamSteals=X20, TeamBlocks=X21, TeamTurnovers=X22, TeamPersonalFouls=X23, Blank=X24, OpponentFG=X25, OpponentFGA=X26, OpponentFGPCT=X27, Opponent3P=X28, Opponent3PA=X29, Opponent3PPCT=X30, OpponentFT=X31, OpponentFTA=X32, OpponentFTPCT=X33, OpponentOffRebounds=X34, OpponentTotalRebounds=X35, OpponentAssists=X36, OpponentSteals=X37, OpponentBlocks=X38, OpponentTurnovers=X39, OpponentPersonalFouls=X40) %>% filter(Game != "") %>% filter(Game != "G") %>% mutate(Team=team) %>% mutate_at(vars(-Team, -Date, -Opponent, -HomeAway, -W_L), as.numeric) %>% mutate(Date = ymd(Date)) %>% mutate(Team=team, Conference=conference)

  logs <- rbind(logs, table)  # binding them all together
  Sys.sleep(5)  # Sys.sleep(3) pauses the loop for 3s so as not to overwhelm website's server
}
```

The magic here is in `for (i in schools){`. What that says is for each iterator in schools -- for each school in schools -- do what follows each time. So we take the code we wrote for one school and use it for every school. 

This part:

```
  log_url <- gsub("/2019.html","/2019-gamelogs.html", i)
  school_url <- paste(uri, log_url, sep="")  # creating the url to fetch
  
  page <- read_html(school_url)
```

`log_url` is what changes our school page url to our logs url, and `school_url` is taking that log url and the root domain and merging them together to create the complete url. Then, page just reads that url we created. 

What follows that is taken straight from our example of just doing one.

The last bits are using rbind to take our data and mash it into a bigger table, over and over and over again until we have them all in a single table. Then, we tell our scraper to wait a few seconds because we don't want our script to machine gun requests at their server as fast as it can go. That's a guaranteed way to get them to block scrapers, and could knock them off the internet. Aggressive scrapers aren't cool. Don't do it. 

Lastly, we write it out to a csv file. 


```r
write.csv(logs, "logs.csv")
```

So with a little programming knowhow, a little bit of problem solving and the stubbornness not to quit on it, you can get a whole lot of data scattered all over the place with not a lot of code. 

## One last bit

Most tables that Sports Reference sites have are in plain vanilla HTML. But some of them -- particularly player based stuff -- are hidden with a little trick. The site puts the data in a comment -- where a browser will ignore it -- and then uses javascript to interpret the commented data. To a human on the page, it looks the same. To a browswer or a scraper, it's invisible. You'll get errors. How do you get around it? 

1. Scrape the comments.
2. Turn the comment into text. 
3. Then read that text as html. 
4. Proceed as normal. 


```r
h <- read_html('https://www.baseball-reference.com/leagues/MLB/2017-standard-pitching.shtml')

df <- h %>% html_nodes(xpath = '//comment()') %>%    # select comment nodes
    html_text() %>%    # extract comment text
    paste(collapse = '') %>%    # collapse to a single string
    read_html() %>%    # reparse to HTML
    html_node('table') %>%    # select the desired table
    html_table() 
```
