# Assignments

This is a collection of assignments I've used in my Sports Data Analysis and Visualization course at the University of Nebraska-Lincoln. The overriding philosophy is to have students do lots of small assignments that directly apply what they learned, and often pulling from other assignments. Each small assignment is just a few points each -- I make them 5 points each and make the grading a yes/no decision on 5 different questions -- so a bad grade on one doesn't matter. Then, twice during the semester, I have them create blog posts with visualizations on a topic of their choosing. The topic must have a point of view -- Nebraska's woes on third down are why the team is struggling, for example -- and must be backed up with data. They have to write a completely documented R Notebook explaining what they did and why; they have to write a publicly facing blog post for a general audience and that post has to have at least three graphs backing up their point; and they have to give a lightning talk (no more than five minutes) in class about what they have found. Those two assignments are typically worth 50 percent of the course grade. 

I think rubrics are crap, but I give students these questions as a guide to what I'm expecting:

1. Did you read the data into a dataframe? 
2. Did you use the skill discussed in the chapter correctly? 
3. Did you answer all the questions posed by the assignment?
4. Did you use Markdown comments to explain your steps, what you did and why? 

**Chapter 1: Intro**

* Install [Slack](https://slack.com/get) on your computer and your phone.
* If on a Mac, [install the Command Line Tools](http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/).
* Install [R for your computer](https://rweb.crmda.ku.edu/cran/).
* Install [R Studio Desktop for your computer](https://www.rstudio.com/products/rstudio/download/#download) ONLY AFTER YOU HAVE INSTALLED R

**Chapter 2: Basics**

Part 1:

In the console, type `install.packages("swirl")`

Then `library("swirl")`

Then `swirl()`

Follow instructions on the screen. Each time you are asked if which one you want, you want the first one. The basics, the beginning, the first parts. All the first ones. Then just follow the instructions on the screen.

Part 2:

Create an R notebook (which you should have done if you were following along). In it, delete all the generated text from it, so you have a blank document. Then, write a sentence in the document telling me what the last thing you did in Swirl was. Then add a code block (see about inserting code in the chapter) and add two numbers together. Any two numbers. Run that code block. Save the file and submit the .Rmd file created when you save it to Canvas. That's it. Simple.

**Chapter 3: Data, structures and types**

Using what you learned in the chapter, fetch [the list of the Big Ten's leading tacklers](http://www.cfbstats.com/2018/leader/827/player/split01/category19/sort01.html). Submit the CSV file to Canvas. In the comments, label each field type. What are they? Dates? Characters? Numeric?

**Chapter 4: Aggregates**

Import [this dataset of every college basketball game in the 2018-19 season](https://unl.box.com/s/a8m91bro10t89watsyo13yjegb1fy009). Using what you learned in the chapter, answer the following questions:

1. What team shot the most shots? 
2. What team averaged the most shots?
3. What team had the highest median number of shots? 
4. How much difference is there between the top average shots team and the top median shots team? Why do you think that is?

**Chapter 5: Mutating Data**

Import [this dataset of every college basketball game in the 2018-19 season](https://unl.box.com/s/a8m91bro10t89watsyo13yjegb1fy009). Using what you learned in the chapter, mutate a new variable: differential. Differential is the difference between the team score and the opponent score. A positive number means the team in question won. A negative number means the team in question lost. After creating the differential, average them together and sort them in descending order. Which team had the highest average point differential in college basketball? In other words, which team consistently won by the largest margins?

**Chapter 6: Filters and selections**

Import the data of [every college basketball player's season stats in 2018-19 season](https://unl.box.com/s/s1wzw61u9ia50qmirfhuvprgpmmah9rj). Using this data, let's get closer to a real answer to where the cutoff for true shooting season should be from the chapter. First, find the median number of shots attempted in the season, then set the cutoff filter for who had the best true shooting percentage using that number. 

**Chapter 7: Transforming data**

Import this dataset of [college football attendance data from 2013-2018](https://unl.box.com/s/fs3rj0dns1xh2y1dx0c2yc0adh4u3zsy). This data is long data -- one team, one year, one row. We need it to be wide data. Hint: it'll be much easier if you select only the columns you need to make it wide instead of using them all. Submit your notebook.  

**Chapter 8: Simulations**

On Feb. 6, Nebraska's basketball team had a nightmare night shooting the ball. They attempted 57 shots ... and made only 12. The team shot .429 on the season. Simulate 1000 games of them taking 57 shots using their season long .429 as the probability that they'll make a shot. How many times do they make just 12?

**Chapter 9: Correlations and regressions**

Do the same thing described in the chapter, but for defense. Report your R-squared number, your p-value, what those mean and from that, how close does it come to predicting the Iowa Nebraska game?

**Chapter 10: Multiple regression**

You have been hired by Fred Hoiberg to build a team. He's interested in the model started in the chapter, but wants more.

There are more predictors to be added to our model. You are to find two. Two that contribute to the predictive quality of the model without largely overlapping another predictor.

In your notebook, report the adjusted r-squared you achieved. 

You are to generate a new set of coefficients, a new formula and a new set of numbers of what a conference champion would expect in terms of differential. I've done a lot of work for you. Continue it. Add two more predictors and complete the prediction. And compare that to Nebraska of this season.

Turn in your notebook with these answers and comments to the code you added, making sure to add WHY you are doing things. Why did you select those two variables.

**Chapter 11: Residuals**

Using the same data from the chapter, model defensive third down percentage and defensive points allowed. Which teams are overperforming that model given the residual analysis? 

**Chapter 12: Z scores**

Refine the composite Z Score I started in the chapter. Add two more elements to it. What else do you think is important to the success of a basketball team? I've got shooting, rebounds and the opponents shooting. What else would you add? 

In an R Notebook, make your case for the two elements you are adding -- what is your logic? Why these two?. Then, follow my steps here until you get to the `teamquality` dataframe step, where you'll need to add the fields you are going to add to the composite. Then you'll need to add your fields to the `teamtotals` dataframe. Then you'll need to adjust `teamzscore`.  

Finally, look at your ranking of Big Ten teams and compare it to mine. Did adding more elements to the composite change anything? Explain the differences in your notebook. Which one do you think is more accurate? I won't be offended if you say yours, but why do you feel that way? 

**Chapter 13: Intro to ggplot**

[Take this same attendance data](https://unl.box.com/s/hvxmnxhr41x4ikgt3vk38aczcbrf97pn). I want you to produce a bar chart of the top 10 schools by percent change in attendance between 2018 and 2013. I want you to change the title and the labels and I want you to apply a theme different from the ones I used above. You can find [more themes in the ggplot documentation](https://ggplot2.tidyverse.org/reference/ggtheme.html).

**Chapter 14: Stacked bar charts**

I want you to make this same chart, except I want you to make the weight the percentage of the total number of graduates that gender represents. You'll be mutating a new field to create that percentage. You'll then chart it with the fill. The end result should be a stacked bar chart allowing you to compare genders between universities. Answer the following question: Which schools have the largest gender imbalances?

**Chapter 15: Waffle charts**

Compare Nebraska and Michgan's night on the basketball court using a Waffle chart and another metric than what I've done above for the game.

[Here's the library's documentation](https://github.com/hrbrmstr/waffle).
[Here's the stats from the game](https://www.sports-reference.com/cbb/boxscores/2019-02-28-19-michigan.html).

Turn in your notebook with your waffle chart. It must contain these two things:

* Your waffle chart
* A written narrative of what it says. What does your waffle chart say about how that game turned out?

**Chapter 16: Line Charts**

Import [this dataset of every college basketball game in the 2018-19 season](https://unl.box.com/s/a8m91bro10t89watsyo13yjegb1fy009).

* How does Nebraska's shooting percentage compare to the Big Ten over the season? Put the Big Ten on the same chart as Nebraska, you'll need two dataframes, two geoms and with your Big Ten dataframe, you need to use `group` in the aesthetic. 

* After working on this chart, your boss comes in and says they don't care about field goal percentage anymore. They just care about three-point shooting because they read on some blog that three-point shooting was all the rage. Change what you need to change to make your line chart now about how the season has gone behind the three-point line. How does Nebraska compare to the rest of the Big Ten?

**Chapter 17: Step charts**

Re-make the chart in the chapter, but with rebounding. I want you to visualize the differential between our rebounds and their rebounds, and then plot the step chart showing over the course of the season. Highlight Nebraska. Highlight the top team. Add annotation layers to label both of them. 

**Chapter 18: Ridge charts**

You've been hired by Fred Hoiberg to tell him how to win the Big Ten. He's not impressed with that I came up with. So what you need to do is look for a *composite* measure that produces a meaningful ridgeplot. What that means is you're going to mutate `wintotalgroupinglogs` one more time. Is the differential between rebounding meaningful instead of just the total? Or assists? Or something else? Your call. Your goal is to produce a ridgeplot that tells The Mayor he needs to focus on doing X better than the opponent to win a Big Ten title.

**Chapter 19: Lollipop charts**

You've been hired by Fred Hoiberg to tell him how to win the Big Ten. He's not impressed with that I came up with. So what else could you look at with lollipop charts? Your call. Your goal is to produce a lollipop chart that tells The Mayor he needs to focus on the gap between X and Y if he wants to win a Big Ten title.

**Chapter 20: Scatterplot**

Using the data from the walkthrough, model and graph two other elements of Nebraska's season versus wins. How much does your choices of metrics predict the season? What do the scatterplots of what you chose look like? What do the linear models say (r-squared, p-values)? How predictive are they, i.e. using y=mx+b, how close to Nebraska's win total do your models get to?

**Chapter 21: Facet Wraps**

Which Big Ten teams were good a shooting three point shots? Which teams weren't? Using a facet grid, chart each teams three point shooting season against the league average.

**Chapter 22**

Import [this dataset of every college basketball game in the 2018-19 season](https://unl.box.com/s/a8m91bro10t89watsyo13yjegb1fy009).

Create a dataframe that shows the 10 best or 10 worst at something. Or rank the Big Ten. Your choice. Then use formattable to show in both a table and visually how the best were different from the worst. 

Export it to a PNG using the example above. Then, in Illustrator, add a headline, chatter, source and credit lines. Turn in the PNG file you export from Illustrator.

**New Chapter**

Import [this dataset of every college basketball game in the 2018-19 season](https://unl.box.com/s/a8m91bro10t89watsyo13yjegb1fy009). Create a bubble chart looking at two stats to make your scatterplot and a third making the size of your bubble. Make the color the conference name. 

I want to see your bubble chart, but more importantly, I want you to discuss if what you came up with makes an effective bubble chart. Does it tell a story? Does the size of the bubble enhance understanding? No is an acceptable answer. But explain why it did or didn't work. 

**New Chapter**

Your turn: Let's evaluate the second part of the quote from the chapter: November basketball tells you where you are. 

We've looked at wins. What else could you look at over the course of the season that tells you where you are? Pick a metric. Explain your choice. Make a circular bar chart. Evaluate the result. What does it say?


**Chapter 23: Rvest**

I am a huge Premiere League fan, so I want data on the league. [For now, I just want teams](https://fbref.com/en/comps/9/stats/Premier-League-Stats). Scrape the team data at the top, but before you do, look at the header. Is it one row? Does that make it standard? Nope. So what now?

**Chapter 24: Advanced Rvest**

I don't usually assign an advanced rvest assignment because I don't want to turn 30 students loose on some poor provider's servers. 

**Note:** There are no assignments for annotations and finishing touches. In my classes, I have students present two major visual stories where they have to incorporate the elements of those assignments as part of their grade. 

**Chapter 30: Plotly**

First, create a simple ggplot like we did above exploring WRAA -- [weighted runs above average](http://m.mlb.com/glossary/advanced-stats/weighted-runs-above-average) -- as your x value and and plate appearances (PA) as your y variable.

Next, create a plotly visualization using the same two variables. Alter the hover elements to show relevant data. If you leave it the same from the chapter, you lose points. 

Export your plotly visualization to plotly's website. Include a link of your viz in your notebook. In your notebook, discuss the relative advantages and disadvantages of this interactive plot versus the static plots we've been doing. 

