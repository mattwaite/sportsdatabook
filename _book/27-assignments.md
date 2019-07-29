# Assignments

This is a collection of assignments I've used in my Sports Data Analysis and Visualization course at the University of Nebraska-Lincoln. The overriding philosophy is to have students do lots of small assignments that directly apply what they learned, and often pulling from other assignments. Each small assignment is just a few points each -- I make them 5 points each and make the grading a yes/no decision on 5 different questions -- so a bad grade on one doesn't matter. Then, twice during the semester, I have them create blog posts with visualizations on a topic of their choosing. The topic must have a point of view -- Nebraska's woes on third down are why the team is struggling, for example -- and must be backed up with data. They have to write a completely documented R Notebook explaining what they did and why; they have to write a publicly facing blog post for a general audience and that post has to have at least three graphs backing up their point; and they have to give a lightning talk (no more than five minutes) in class about what they have found. Those two assignments are typically worth 50 percent of the course grade. 


**Chapter 1**

Create an R notebook (which you should have done if you were following along). In it, delete all the generated text from it, so you have a blank document. Then, write a sentence in the document telling me what the last thing you did in Swirl was. Then add a code block (see above about inserting) and add two numbers together. Any two numbers. Run that code block. Save the file and submit the .Rmd file created when you save it. 

That's it. Simple.

**Chapter 2**

**Chapter 3**

We're going to put it all together now. We're going to calculate the mean and median salaries of departments at each campus using the salary data. 

Answer these questions:

1. What are the mean and median salaries of each department on each campus? And how many employees are on each department?
2. What are the median salaries of the largest departments at each campus? And how does that compare to the average salary for that department?
3. What department has the highest mean salary? How does that compare with the median?

To do this, you'll need to [download the salary data data](https://www.dropbox.com/s/xts9xsim3lpg7qu/nusalaries1819.csv?dl=0).

Rubric

1. Did you read the data into a dataframe? 
2. Did you use group by syntax correctly? 
3. Did you use summarize syntax correctly?
4. Did you use Markdown comments to explain your steps? 


**Chapter 4**

Read the Wall Street Journal story about declining attendance -- in Files in Canvas called WSJEmptySeats.pdf. Look at the walkthrough and be ready to talk about similarities and differences on Monday. 

Calculate the percent change in an rushing offense category of your choosing [in this dataset](https://www.dropbox.com/s/bxqmzntkwhqn24e/rushingoffense.csv?dl=0). Do not pick Games. Look at something else. Who gained the most in your category? Who lost the most? Explain your steps, and write a paragraph on what you found. 

#### Rubric

1. Did you import the data correctly?
2. Did you mutate the data correctly? Did you do it in one step?
3. Did you sort the data correctly?
4. Did you explain each step using Markdown?


**Chapter 5**

### Assignment

Let's have some more fun with the [salary database](https://www.dropbox.com/s/xts9xsim3lpg7qu/nusalaries1819.csv?dl=0) is out! Time to use filters, selects and top_n.

For the first question, [use this dataset](https://www.dropbox.com/s/iodsuouf39blbbz/coaches.csv?dl=0) of just coach salaries. The second two questions use the salaries database you already used.

1. What is the average and median salaries for coaches at UNL, UNK and UNO?
2. Who are the top 10 highest paid employees at UNL (using top_n)?
3. What is my salary?

### If you're curious how I got the coaches salaries separated out

First, we import the data. 


```r
salaries <- read_csv("../../Data/nusalaries1819.csv")
```

To filter out positions with the word Coach in it, we're going to have to use a new library that comes with the tidyverse, meaning you have it installed already. It's called StringR and it works with text. 


```r
library(stringr)
```

We're going to use a function in StringR called str_detect, which does what you think it does -- it detects if a set of characters are in a piece of data. So in this case, we want to find all the coaches, so we're going to look for the word Coach. But, when I do that, I get some people who have coach in their title but aren't coaches. 


```r
salaries %>% filter(str_detect(Position, 'Coach'))
```
I don't know about you, but's been a while since I watched a team headed by something called an Early Childhood Coach. Or a Career Coach. So, we need to filter them out. But how do we know which ones to filter? Let's use group by to get us a list of departments. That will be the giveaway -- there aren't sports coaches in the College of Arts and Sciences.


```r
salaries %>% filter(str_detect(Position, 'Coach')) %>% group_by(Department) %>% summarize(total=n())
```

From that, we can build a list of the non sports related departments. 


```r
noncoach = c("Academic & Career Development Center", "College of Arts & Sciences", "College of Business", "First Year Exp & Transition Programs", "NE Ctr  Rsrch on Youth,Fam & School", "Program in English Second Language")
```

And we can filter them out by putting a ! in front of the logical statement, which turns it into a negative. So here, we have Department NOT IN our list of non sports departments. 


```r
salaries %>% filter(str_detect(Position, 'Coach')) %>% filter(!Department %in% noncoach)
```

Let's do ourselves a favor and create a new data frame from this and use that instead:


```r
coaches <- salaries %>% filter(str_detect(Position, 'Coach')) %>% filter(!Department %in% noncoach)
```


**Chapter 6**

### Assignment

* Read [A Layered Grammar of Graphics](https://byrneslab.net/classes/biol607/readings/wickham_layered-grammar.pdf) by Hadley Wickham. 
* Watch Wickham, who created the libraries we are using, [work through a data project](https://www.youtube.com/watch?v=go5Au01Jrvs). 

**Chapter 7**

**Chapter 8**

### Assignment

The fun of this is that you can test all kinds of theories. Given what we have in our dataset, what do you think predicts Nebraska's win total? Rebounds? Rebound differential? Fouls? Three point shooting? Total up every team's season performance, produce a scatterplot and a linear model and evaluate. Does it? What's your R-squared? What's your P-value? Create a model -- y = mx + b -- and see how Nebraska is performing relative to expectations. 

##### Rubric

1. Did you import the data correctly?
2. Did you summarize it correctly?
3. Did you produce a scatterplot?
4. Did you produce a linear model?
5. Did you apply the model?
6. Did you interpret your results?
7. Did you comment your code in markdown?


**Chapter 9**

#### Assignment 

You have been hired by Fred Hoiberg to build a team. He's interested in this model, but wants more.

There are more predictors to be added to our model. You are to find two. Two that contribute to the predictive quality of the model without largely overlapping another predictor.

In your notebook, report the adjusted r-squared you achieved. 

You are to generate a new set of coefficients, a new formula and a new set of numbers of what a conference champion would expect in terms of differential. I've done a lot of work for you. Continue it. Add two more predictors and complete the prediction. And compare that to Nebraska of this season.

Turn in your notebook with these answers and comments to the code you added, making sure to add WHY you are doing things. Why did you select those two variables.






**Chapter 10**

**Chapter 11**

## Assignment

Refine the composite Z Score I started here. Add two more elements to it. What else do you think is important to the success of a basketball team? I've got shooting, rebounds and the opponents shooting. What else would you add? 

In an R Notebook, make your case for the two elements you are adding. Then, follow my steps here until you get to the `teamquality` dataframe step, where you'll need to add the fields you are going to add to the composite. Then you'll need to add your fields to the `teamtotals` dataframe. Then you'll need to adjust `teamzscore`.  

Finally, look at your ranking of Big Ten teams and compare it to mine. Did adding more elements to the composite change anything? Explain the differences in your notebook. Which one do you think is more accurate? I won't be offended if you say yours, but why do you feel that way? 

[The data you'll need is here](https://www.dropbox.com/s/k6s758v5gwy7n4z/logs.csv?dl=0). 

#### Rubric

1. Did you import the data correctly?
2. Did you mutate the data correctly? 
3. Did you sort the data correctly?
4. Did you explain each step using Markdown?



**Chapter 12**

### Assignment

[Take this same attendance data](https://www.dropbox.com/s/m52dkdon3zs3ssq/attendance.csv?dl=0). I want you to produce a bar chart of the top 10 schools by percent change in attendance between 2017-2018 and 2013-2014. I want you to change the title and the labels and I want you to apply a theme different from the ones I used above. You can find [more themes in the ggplot documentation](https://ggplot2.tidyverse.org/reference/ggtheme.html).

#### Rubric
1. Did you import the data correctly?
2. Did you manipulate the data correctly?
3. Did you chart the data?
4. Did you explain your steps in Markdown comments?

**Chapter 13**

### Assignment

I want you to make this same chart, except I want you to make the weight the percentage of the total number of graduates that gender represents. You'll be mutating a new field to create that percentage. You'll then chart it with the fill. The end result should be a stacked bar chart allowing you to compare genders between universities. 

#### Rubric

1. Did you import the data correctly?
2. Did you mutate the data correctly?
3. Did you save that new data to a new data frame?
4. Did you chart it correctly with fill?


**Chapter 14**

### Assignment

Compare Nebraska and Michgan using a Waffle chart and another metric than what I've done above for the game last night.

[Here's the library's documentation](https://github.com/hrbrmstr/waffle).
[Here's the stats from the game](https://www.sports-reference.com/cbb/boxscores/2019-02-28-19-michigan.html).

Turn in your notebook with your waffle chart. It must contain these two things:

* Your waffle chart
* A written narrative of what it says. What does your waffle chart say about how that game turned out?

**Chapter 15**

### Assignment

* How does Nebraska's shooting percentage compare to the Big Ten? Put the Big Ten on the same chart as Nebraska, you'll need two dataframes, two geoms and with your Big Ten dataframe, you need to use `group` in the aesthetic. 

* After working on this chart, your boss comes in and says they don't care about field goal percentage anymore. They just care about three-point shooting because they read on some blog that three-point shooting was all the rage. Change what you need to change to make your line chart now about how the season has gone behind the three-point line. How does Nebraska compare to the rest of the Big Ten?

#### Rubric

1. Did you gather the data correctly?
2. Did you import it into R Notebook correctly?
3. Did you create the data frames needed to chart correctly?
4. Did you chart both correctly?

**Chapter 16**


### Assignment

Re-make this, but with rebounding. I want you to visualize the differential between our rebounds and their rebounds, and then plot the step chart showing over the course of the season. Highlight Nebraska. Highlight the top team. Add annotation layers to label both of them. 

#### Rubric

1. Did you import the data correctly?
2. Did you mutate the data correctly? Did you do it in one step?
3. Did you chart the data correctly?
4. Did you annotate your data?
5. Did you explain each step using Markdown?


**Chapter 17**

#### Assignment

You've been hired by Fred Hoiberg to tell him how to win the Big Ten. He's not impressed with that I came up with. So what you need to do is look for a *composite* measure that produces a meaningful ridgeplot. What that means is you're going to mutate `wintotalgroupinglogs` one more time. Is the differential between rebounding meaningful instead of just the total? Or assists? Or something else? Your call. Your goal is to produce a ridgeplot that tells The Mayor he needs to focus on doing X better than the opponent to win a Big Ten title.

##### Rubric

1. Did you mutate the data correctly?
2. Did you produce a ridgeplot?
3. Does it show a difference between top teams and the rest?


**Chapter 18**


#### Assignment

You've been hired by Fred Hoiberg to tell him how to win the Big Ten. He's not impressed with that I came up with. So what else could you look at with lollipop charts? Your call. Your goal is to produce a lollipop chart that tells The Mayor he needs to focus on the gap between X and Y if he wants to win a Big Ten title.

##### Rubric

1. Did you manipulate the data correctly?
2. Did you produce a lollipop chart?
3. Does it show a difference?


**Chapter 19**


### Assignment

The fun of this is that you can test all kinds of theories. Given what we have in our dataset, what do you think predicts Nebraska's win total? Rebounds? Rebound differential? Fouls? Three point shooting? Total up every team's season performance, produce a scatterplot and a linear model and evaluate. Does it? What's your R-squared? What's your P-value? Create a model -- y = mx + b -- and see how Nebraska is performing relative to expectations. 

##### Rubric

1. Did you import the data correctly?
2. Did you summarize it correctly?
3. Did you produce a scatterplot?
4. Did you produce a linear model?
5. Did you apply the model?
6. Did you interpret your results?
7. Did you comment your code in markdown?


**Chapter 20**

#### Assignment

How else would you look at teams going into the Big 10 Tournament using facet wraps? In class, create one using the log data we've used (if you want the updated version, [download it again](https://www.dropbox.com/s/0lpvstsjziz5k6p/logs.csv?dl=0)). You can just lightly comment your code. I'm more curious for you to try it. 




**Chapter 21**


### Assignment

We now have [season logs](https://www.dropbox.com/s/0lpvstsjziz5k6p/logs.csv?dl=0) for every college basketball game played up to the NCAA tournament.

Create a dataframe that shows the 10 best or 10 worst at something. Or rank the Big Ten. Your choice. Then use formattable to show in both a table and visually how the best were different from the worst. 

Export it to a PNG using the example above. Then, in Illustrator, add a headline, chatter, source and credit lines. Turn in the PNG file you export from Illustrator.


**Chapter 22**

#### Assignment

I am a huge Premiere League fan, so I want data on the league. [For now, I just want teams](https://fbref.com/en/comps/9/stats/Premier-League-Stats). Scrape the team data at the top, but before you do, look at the header. Is it one row? Does that make it standard? Nope. So what now? 

##### Rubric

1. Did you scrape the page?
2. Did you finish with a clean dataset?


**Chapter 23**

**Chapter 24**

**Chapter 25**

**Chapter 26**

**Chapter 27**
