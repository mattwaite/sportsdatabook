# Simulations

Two seasons ago, James Palmer Jr. shot 139 three point attempts and made 43 of them for a .309 shooting percentage last year. A few weeks into last season, he was 7 for 39 -- a paltry .179. Is something wrong or is this just bad luck? Let's simulate 39 attempts 1000 times with his season long shooting percentage and see if this could just be random chance or something else. 

We do this using a base R function called `rbinom` or binomial distribution -- another name for a normal distribution. So what that means is there's a normally distrubuted chance that James Palmer Jr. is going to shoot above and below his career three point shooting percentage. If we randomly assign values in that distribution 1000 times, how many times will it come up 7, like this example?  


```r
set.seed(1234)

simulations <- rbinom(n = 1000, size = 39, prob = .309)

hist(simulations)
```

<img src="07-simulations_files/figure-html/unnamed-chunk-1-1.png" width="672" />

```r
table(simulations)
```

```
## simulations
##   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20 
##   1   4   5  12  35  44  76 117 134 135 135  99  71  53  37  21  15   2 
##  21  22 
##   3   1
```

So what we see is given his season long shooting percentage, it's not out of the realm of randomness that with just 39 attempts for Palmer, he's only hit only 7. In 1000 simulations, it comes up 35 times. Is he below where he should be? Yes. Will he likely improve and soon? Yes. 

## Cold streaks

During the Western Illinois game, the team, shooting .329 on the season from behind the arc, went 0-15 in the second half. How strange is that? 


```r
set.seed(1234)

simulations <- rbinom(n = 1000, size = 15, prob = .329)

hist(simulations)
```

<img src="07-simulations_files/figure-html/unnamed-chunk-2-1.png" width="672" />

```r
table(simulations)
```

```
## simulations
##   0   1   2   3   4   5   6   7   8   9  10  11 
##   5  16  59 132 200 218 172  92  65  34   4   3
```
Short answer: Really weird. If you simulate 15 threes 1000 times, sometimes you'll see them miss all of them, but only a few times -- five times, in this case. Most of the time, the team won't go 0-15 even once. So going ice cold is not totally out of the realm of random chance, but it's highly unlikely.

