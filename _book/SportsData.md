--- 
title: "Sports Data Analysis and Visualization"
subtitle: "R, the Tidyverse and data analysis for journalists and other storytellers."
author: "By Matt Waite"
bibliography:
- packages.bib
description: This book is the companion to the University of Nebraska-Lincoln's SPMC
  350 course in the College of Journalism and Mass Communications.
documentclass: book
link-citations: yes
site: bookdown::bookdown_site
biblio-style: apalike
github-repo: https://github.com/mattwaite/sportsdatabook
---
--- 
title: "Sports Data Analysis and Visualization"
subtitle: "R, the Tidyverse and data analysis for journalists and other storytellers."
author: "By Matt Waite"
bibliography:
- packages.bib
description: This book is the companion to the University of Nebraska-Lincoln's SPMC
  350 course in the College of Journalism and Mass Communications.
documentclass: book
link-citations: yes
site: bookdown::bookdown_site
biblio-style: apalike
github-repo: https://github.com/mattwaite/sportsdatabook
---

# Throwing cold water on hot takes

The 2018 season started out disasterously for the Nebraska Cornhuskers. The first game against a probably overmatched opponent? Called on account of an epic thunderstorm that plowed right over Memorial Stadium. The next game? Loss. The one following? Loss. The next four? All losses, after the fanbase was whipped into a hopeful frenzy by the hiring of Scott Frost, national title winning quarterback turned hot young coach come back home to save a mythical football program from the mediocrity it found itself mired in. 

All that excitement lay in tatters.

On sports talk radio, on the sports pages and across social media and cafe conversations, one topic kept coming up again and again to explain why the team was struggling: Penalties. The team was just committing too many of them. In fact, six games and no wins into the season, they were dead last in the FBS penalty yards.

Worse yet for this line of reasoning? Nebraska won game 7, against Minnesota, committing only six penalites for 43 yards, just about half their average over the season. Then they won game 8 against FCS patsy Bethune Cookman, committing only five penalties for 35 yards. That's a whopping 75 yards less than when they were losing. See? Cut the penalties, win games screamed the radio show callers. 

The problem? It's not true. Penalties might matter for a single drive. They may even throw a single game. But if you look at every top-level college football team since 2009, the number of penalty yards the team racks up means absolutely nothing to the total number of points they score. There's no relationship between them. Penalty yards have no discernable influence on points beyond just random noise. 

Put this another way: If you were Scott Frost, and a major college football program was paying you $5 million a year to make your team better, what should you focus on in practice? If you had growled at some press conference that you're going to work on penalties in practice until your team stops committing them, the results you'd get from all that wasted practice time would be impossible to separate from just random chance. You very well may reduce your penalty yards and still lose. 

How do I know this? Simple statistics. 

That's one of the three pillars of this book: Simple stats. The three pillars are:

1. Simple, easy to understand statistics ... 
2. ... extracted using simple code ...
3.  ... visualized simply to reveal new and interesting things in sports. 

Do you need to be a math whiz to read this book? No. I'm not one either. What we're going to look at is pretty basic, but that's also why it's so powerful. 

Do you need to be a computer science major to write code? Nope. I'm not one of those either. But anyone can think logically, and write simple code that is repeatable and replicable. 

Do you need to be an artist to create compelling visuals? I think you see where this is going. No. I can barely draw stick figures, but I've been paid to make graphics in my career. With a little graphic design know how, you can create publication worthy graphics with code. 

## Requirements and Conventions

This book is all in the R statistical language. To follow along, you'll do the following:

1. Install the R language on your computer. Go to the [R Project website](https://www.r-project.org/), click download R and select a mirror closest to your location. Then download the version for your computer. 
2. Install [R Studio Desktop](https://www.rstudio.com/products/rstudio/#Desktop). The free version is great. 

Going forward, you'll see passages like this:



```r
install.packages("tidyverse")
```

Don't do it now, but that is code that you'll need to run in your R Studio. When you see that, you'll know what to do.



<!--chapter:end:index.Rmd-->


# The very basics

Placeholder


## Adding libraries, part 1
## Adding libraries, part 2
## Notebooks

<!--chapter:end:01-intro.Rmd-->


# Data, structures and types

Placeholder


## Rows and columns
## A simple way to get data
## Cleaning the data

<!--chapter:end:02-data.Rmd-->


# Aggregates

Placeholder


## Basic data analysis: Group By and Count
## Other aggregates: Mean and median

<!--chapter:end:03-aggregates.Rmd-->


# Mutating data

Placeholder


## A more complex example

<!--chapter:end:04-mutating.Rmd-->


# Filters and selections

Placeholder


## Selecting data to make it easier to read
## Using conditional filters to set limits
## Top list

<!--chapter:end:05-filters.Rmd-->


# Transforming data

Placeholder


## Making wide data long
## Why this matters

<!--chapter:end:06-transforming.Rmd-->


# Simulations

Placeholder


## Cold streaks

<!--chapter:end:07-simulations.Rmd-->


# Correlations and regression

Placeholder


## A more predictive example

<!--chapter:end:08-correlation.Rmd-->


# Multiple regression

Placeholder



<!--chapter:end:09-multipleregression.Rmd-->


# Residuals

Placeholder


## Penalties

<!--chapter:end:10-residuals.Rmd-->


# Z scores

Placeholder


## Calculating a Z score in R

<!--chapter:end:11-zscores.Rmd-->


# Intro to ggplot

Placeholder


## Scales
## Styling
## One last trick: coord flip

<!--chapter:end:12-ggplot.Rmd-->


# Stacked bar charts

Placeholder



<!--chapter:end:13-stackedbar.Rmd-->


# Waffle charts

Placeholder


## Waffle Irons

<!--chapter:end:14-wafflecharts.Rmd-->


# Line charts

Placeholder


## This is too simple. 
## But what if I wanted to add a lot of lines. 

<!--chapter:end:15-linecharts.Rmd-->


# Step charts

Placeholder



<!--chapter:end:16-stepcharts.Rmd-->


# Ridge charts

Placeholder



<!--chapter:end:17-ridgecharts.Rmd-->


# Lollipop charts

Placeholder



<!--chapter:end:18-lollipopcharts.Rmd-->


# Scatterplots

Placeholder



<!--chapter:end:19-scatterplots.Rmd-->


# Facet wraps

Placeholder


## Facet grid vs facet wraps
## Other types

<!--chapter:end:20-facetwraps.Rmd-->


# Tables

Placeholder


### Exporting tables

<!--chapter:end:21-tables.Rmd-->


# Intro to rvest

Placeholder


## A slightly more complicated example
## An even more complicated example

<!--chapter:end:22-rvest.Rmd-->


# Advanced rvest

Placeholder


## One last bit

<!--chapter:end:23-advancedrvest.Rmd-->


# Annotations

Placeholder



<!--chapter:end:24-annotations.Rmd-->


# Finishing touches, part 1

Placeholder


## Graphics vs visual stories
## Getting ggplot closer to output

<!--chapter:end:25-finishingtouches1.Rmd-->


# Finishing Touches 2

Placeholder



<!--chapter:end:26-finishingtouches2.Rmd-->


# Assignments

Placeholder


#### Rubric
### Assignment
### If you're curious how I got the coaches salaries separated out
### Assignment
### Assignment
##### Rubric
#### Assignment 
## Assignment
#### Rubric
### Assignment
#### Rubric
### Assignment
#### Rubric
### Assignment
### Assignment
#### Rubric
### Assignment
#### Rubric
#### Assignment
##### Rubric
#### Assignment
##### Rubric
### Assignment
##### Rubric
#### Assignment
### Assignment
#### Assignment
##### Rubric

<!--chapter:end:27-assignments.Rmd-->


# Throwing cold water on hot takes

Placeholder


## Requirements and Conventions
## Adding libraries, part 1
## Adding libraries, part 2
## Notebooks
## Rows and columns
## A simple way to get data
## Cleaning the data
## Basic data analysis: Group By and Count
## Other aggregates: Mean and median
## A more complex example
## Selecting data to make it easier to read
## Using conditional filters to set limits
## Top list
## Making wide data long
## Why this matters
## Cold streaks
## A more predictive example
## Penalties
## Calculating a Z score in R
## Scales
## Styling
## One last trick: coord flip
## Waffle Irons
## This is too simple. 
## But what if I wanted to add a lot of lines. 
## Facet grid vs facet wraps
## Other types
### Exporting tables
## A slightly more complicated example
## An even more complicated example
## One last bit
## Graphics vs visual stories
## Getting ggplot closer to output
#### Rubric
### Assignment
### If you're curious how I got the coaches salaries separated out
### Assignment
### Assignment
##### Rubric
#### Assignment 
## Assignment
#### Rubric
### Assignment
#### Rubric
### Assignment
#### Rubric
### Assignment
### Assignment
#### Rubric
### Assignment
#### Rubric
#### Assignment
##### Rubric
#### Assignment
##### Rubric
### Assignment
##### Rubric
#### Assignment
### Assignment
#### Assignment
##### Rubric

<!--chapter:end:SportsData.Rmd-->

