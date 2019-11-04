# Multiple regression

Last chapter, we looked at correlations and linear regression to predict how one element of a game would predict the score. But we know that a single variable, in all but the rarest instances, are not going to be that predictive. We need more than one. Enter multiple regression. Multiple regression lets us add -- wait for it -- mulitiple predictors to our equation to help us get a better 

That presents it's own problems. So let's get our libraries and our data, this time of [every college basketball game since the 2014-15 season](https://unl.box.com/s/u9407jj007fxtnu1vbkybdawaqg6j3fw) loaded up. 


```r
library(tidyverse)
```

```
## ── Attaching packages ── tidyverse 1.2.1 ──
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
## ── Conflicts ───── tidyverse_conflicts() ──
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```


```r
logs <- read_csv("data/logs1519.csv")
```

```
## Warning: Missing column names filled in: 'X1' [1]
```

```
## Parsed with column specification:
## cols(
##   .default = col_double(),
##   Date = col_date(format = ""),
##   HomeAway = col_character(),
##   Opponent = col_character(),
##   W_L = col_character(),
##   Blank = col_logical(),
##   Team = col_character(),
##   Conference = col_character(),
##   season = col_character()
## )
```

```
## See spec(...) for full column specifications.
```

So one way to show how successful a basketball team was for a game is to show the differential between the team's score and the opponnent's score. Score a lot more than the opponent = good, score a lot less than the opponent = bad. And, relatively speaking, the more the better. So let's create that differential.


```r
logs <- logs %>% mutate(Differential = TeamScore - OpponentScore)
```

The linear model code we used before is pretty straight forward. Its `field` is predicted by `field`. Here's a simple linear model that looks at predicting a team's point differential by looking at their offensive shooting percentage. 


```r
shooting <- lm(TeamFGPCT ~ Differential, data=logs)
summary(shooting)
```

```
## 
## Call:
## lm(formula = TeamFGPCT ~ Differential, data = logs)
## 
## Residuals:
##       Min        1Q    Median        3Q       Max 
## -0.260485 -0.040230 -0.001096  0.039038  0.267457 
## 
## Coefficients:
##               Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  4.399e-01  2.487e-04  1768.4   <2e-16 ***
## Differential 2.776e-03  1.519e-05   182.8   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.05949 on 57514 degrees of freedom
##   (4 observations deleted due to missingness)
## Multiple R-squared:  0.3675,	Adjusted R-squared:  0.3674 
## F-statistic: 3.341e+04 on 1 and 57514 DF,  p-value: < 2.2e-16
```

Remember: There's a lot here, but only some of it we care about. What is the Adjusted R-squared value? What's the p-value and is it less than .05? In this case, we can predict 37 percent of the difference in differential with how well a team shoots the ball. 

To add more predictors to this mix, we merely add them. But it's not that simple, as you'll see in a moment. So first, let's look at adding how well the other team shot to our prediction model:


```r
model1 <- lm(Differential ~ TeamFGPCT + OpponentFGPCT, data=logs)
summary(model1)
```

```
## 
## Call:
## lm(formula = Differential ~ TeamFGPCT + OpponentFGPCT, data = logs)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -49.591  -6.185  -0.198   5.938  68.344 
## 
## Coefficients:
##                Estimate Std. Error  t value Pr(>|t|)    
## (Intercept)      1.1195     0.3483    3.214  0.00131 ** 
## TeamFGPCT      118.5211     0.5279  224.518  < 2e-16 ***
## OpponentFGPCT -119.9369     0.5252 -228.372  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 9.407 on 57513 degrees of freedom
##   (4 observations deleted due to missingness)
## Multiple R-squared:  0.6683,	Adjusted R-squared:  0.6683 
## F-statistic: 5.793e+04 on 2 and 57513 DF,  p-value: < 2.2e-16
```

First things first: What is the adjusted R-squared?

Second: what is the p-value and is it less than .05? 

Third: Compare the residual standard error. We went from .05949 to 9.4. The meaning of this is both really opaque and also simple -- we added a lot of error to our model by adding more measures -- 158 times more. Residual standard error is the total distance between what our model would predict and what we actually have in the data. So lots of residual error means the distance between reality and our model is wider. So the width of our predictive range in this example grew pretty dramatically, but so did the amount of the difference we could predict. It's a trade off. 

One of the more difficult things to understand about multiple regression is the issue of multicollinearity. What that means is that there is significant correlation overlap between two variables -- the two are related to each other as well as to the target output -- and all you are doing by adding both of them is adding error with no real value to the R-squared. In pure statistics, we don't want any multicollinearity at all. Violating that assumption limits the applicability of what you are doing. So if we have some multicollinearity, it limits our scope of application to college basketball. We can't say this will work for every basketball league and level everywhere. What we need to do is see how correlated each value is to each other and throw out ones that are highly co-correlated.

So to find those, we have to create a correlation matrix that shows us how each value is correlated to our outcome variable, but also with each other. We can do that in the `Hmisc` library. We install that in the console with `install.packages("Hmisc")`


```r
library(Hmisc)
```

```
## Warning: package 'Hmisc' was built under R version 3.5.2
```

```
## Loading required package: lattice
```

```
## Loading required package: survival
```

```
## Warning: package 'survival' was built under R version 3.5.2
```

```
## Loading required package: Formula
```

```
## 
## Attaching package: 'Hmisc'
```

```
## The following objects are masked from 'package:dplyr':
## 
##     src, summarize
```

```
## The following objects are masked from 'package:base':
## 
##     format.pval, units
```

We can pass in every numeric value to the Hmisc library and get a correlation matrix out of it, but since we have a large number of values -- and many of them character values -- we should strip that down and reorder them. So that's what I'm doing here. I'm saying give me differential first, and then columns 9-24, and then 26-41. Why the skip? There's a blank column in the middle of the data -- a remnant of the scraper I used. 


```r
simplelogs <- logs %>% select(Differential, 9:24, 26:41)
```

Before we proceed, what we're looking to do is follow the Differential column down, looking for correlation values near 1 or -1. Correlations go from -1, meaning perfect negative correlation, to 0, meaning no correlation, to 1, meaning perfect positive correlation. So we're looking for numbers near 1 or -1 for their predictive value. BUT: We then need to see if that value is also highly correlated with something else. If it is, we have a decision to make.

We get our correlation matrix like this:


```r
cormatrix <- rcorr(as.matrix(simplelogs))

cormatrix$r
```

```
##                       Differential       TeamFG      TeamFGA    TeamFGPCT
## Differential           1.000000000  0.584766682  0.107389235  0.606178206
## TeamFG                 0.584766682  1.000000000  0.563220974  0.751715176
## TeamFGA                0.107389235  0.563220974  1.000000000 -0.109620267
## TeamFGPCT              0.606178206  0.751715176 -0.109620267  1.000000000
## Team3P                 0.318300418  0.408787900  0.213352219  0.322872202
## Team3PA                0.056680627  0.179527313  0.426011924 -0.119421368
## Team3PPCT              0.367934059  0.380235821 -0.101463821  0.545986963
## TeamFT                 0.238182740 -0.022308582 -0.137853824  0.084649669
## TeamFTA                0.206075949 -0.027927391 -0.129851346  0.070632302
## TeamFTPCT              0.138833800  0.016247282 -0.044394472  0.056887587
## TeamOffRebounds        0.136095147  0.161626257  0.545231683 -0.234244567
## TeamTotalRebounds      0.470722398  0.328460524  0.470719037  0.018581908
## TeamAssists            0.540398009  0.664057724  0.284659104  0.566152928
## TeamSteals             0.277670288  0.210221346  0.208743124  0.080191710
## TeamBlocks             0.257608076  0.140856644  0.074555286  0.107327505
## TeamTurnovers         -0.180578328 -0.143210529 -0.223971265  0.001901048
## TeamPersonalFouls     -0.194427271 -0.014722266  0.107325560 -0.094653222
## OpponentFG            -0.538515115  0.144061400  0.256737262 -0.020183466
## OpponentFGA            0.001768386  0.302143806  0.301593528  0.126415534
## OpponentFGPCT         -0.614427717 -0.058571888  0.068034775 -0.114791403
## Opponent3P            -0.283754971  0.131517138  0.135290090  0.053105214
## Opponent3PA            0.013910296  0.191131927  0.138445785  0.118723805
## Opponent3PPCT         -0.382427841  0.008026622  0.057261756 -0.031370545
## OpponentFT            -0.269300868  0.019511923  0.157025930 -0.091558712
## OpponentFTA           -0.226064714  0.012937366  0.159529646 -0.101685664
## OpponentFTPCT         -0.175223632  0.007923359  0.023732217 -0.006190565
## OpponentOffRebounds   -0.089347536 -0.036316958  0.002848058 -0.042399744
## OpponentTotalRebounds -0.420010794 -0.225202127  0.316139528 -0.512983306
## OpponentAssists       -0.491676030  0.004558539  0.149320067 -0.106252682
## OpponentSteals        -0.187754380 -0.102436608 -0.131734964 -0.021724636
## OpponentBlocks        -0.262252627 -0.160469663  0.218483865 -0.356255034
## OpponentTurnovers      0.274326954  0.155293275  0.198127970  0.024254833
## OpponentPersonalFouls  0.169025733 -0.023116620 -0.107189301  0.060150658
##                             Team3P     Team3PA     Team3PPCT       TeamFT
## Differential           0.318300418  0.05668063  0.3679340589  0.238182740
## TeamFG                 0.408787900  0.17952731  0.3802358207 -0.022308582
## TeamFGA                0.213352219  0.42601192 -0.1014638212 -0.137853824
## TeamFGPCT              0.322872202 -0.11942137  0.5459869634  0.084649669
## Team3P                 1.000000000  0.70114773  0.7073663404 -0.106344056
## Team3PA                0.701147726  1.00000000  0.0407645751 -0.160515313
## Team3PPCT              0.707366340  0.04076458  1.0000000000  0.005129556
## TeamFT                -0.106344056 -0.16051531  0.0051295561  1.000000000
## TeamFTA               -0.137499074 -0.18150913 -0.0180696209  0.927525817
## TeamFTPCT              0.048777304  0.01119250  0.0553684315  0.387017653
## TeamOffRebounds       -0.062026229  0.12484929 -0.1968568361  0.087168289
## TeamTotalRebounds      0.038344971  0.12095682 -0.0628970009  0.190691619
## TeamAssists            0.519530086  0.28786139  0.4326950943 -0.016343370
## TeamSteals             0.016545254  0.04598400 -0.0246657289  0.088535320
## TeamBlocks             0.004747719 -0.02895321  0.0294277389  0.092392379
## TeamTurnovers         -0.088374940 -0.10883919 -0.0209433827  0.051609207
## TeamPersonalFouls     -0.024028303  0.02499520 -0.0498165852  0.217846416
## OpponentFG             0.123800594  0.15638030  0.0296913406  0.057853338
## OpponentFGA            0.148931744  0.13062824  0.0812237901  0.193116094
## OpponentFGPCT          0.029908235  0.08057726 -0.0264843759 -0.075399282
## Opponent3P             0.079455775  0.07482590  0.0402012413  0.024228311
## Opponent3PA            0.085704376  0.05927299  0.0601150176  0.079894905
## Opponent3PPCT          0.029666235  0.04634676  0.0005076038 -0.035478488
## OpponentFT             0.009796521  0.06316300 -0.0390873639  0.161311559
## OpponentFTA           -0.002503282  0.05474884 -0.0480732723  0.183801456
## OpponentFTPCT          0.022780414  0.02587876  0.0086512859 -0.015688533
## OpponentOffRebounds   -0.007870292 -0.01895081  0.0086776821  0.064938518
## OpponentTotalRebounds -0.062384273  0.20289676 -0.2638845414 -0.064969878
## OpponentAssists        0.029413582  0.08254506 -0.0320289494 -0.057730062
## OpponentSteals        -0.053878305 -0.05298037 -0.0251316716 -0.001883349
## OpponentBlocks        -0.111782062 -0.05804217 -0.0965607977 -0.065055523
## OpponentTurnovers      0.009284106  0.06383515 -0.0488449748  0.136922084
## OpponentPersonalFouls -0.127197007 -0.15536393 -0.0268876881  0.793539202
##                            TeamFTA    TeamFTPCT TeamOffRebounds
## Differential           0.206075949  0.138833800    0.1360951470
## TeamFG                -0.027927391  0.016247282    0.1616262575
## TeamFGA               -0.129851346 -0.044394472    0.5452316831
## TeamFGPCT              0.070632302  0.056887587   -0.2342445674
## Team3P                -0.137499074  0.048777304   -0.0620262290
## Team3PA               -0.181509133  0.011192503    0.1248492948
## Team3PPCT             -0.018069621  0.055368431   -0.1968568361
## TeamFT                 0.927525817  0.387017653    0.0871682888
## TeamFTA                1.000000000  0.053233778    0.1415933172
## TeamFTPCT              0.053233778  1.000000000   -0.0948040467
## TeamOffRebounds        0.141593317 -0.094804047    1.0000000000
## TeamTotalRebounds      0.231278690 -0.037356471    0.6373027887
## TeamAssists           -0.028289202  0.025948025    0.0509277222
## TeamSteals             0.111199125 -0.025969502    0.1195581042
## TeamBlocks             0.104112579 -0.001425412    0.1060163877
## TeamTurnovers          0.072070652 -0.034614485    0.0371728710
## TeamPersonalFouls      0.250787085 -0.025827923    0.0542337992
## OpponentFG             0.043602296  0.036986356   -0.0464694335
## OpponentFGA            0.193466766  0.040334507    0.0242353640
## OpponentFGPCT         -0.091897172  0.012864509   -0.0688833747
## Opponent3P             0.009600704  0.031763685   -0.0063710321
## Opponent3PA            0.071193179  0.032554796    0.0003753868
## Opponent3PPCT         -0.047136861  0.013996880   -0.0056578317
## OpponentFT             0.180010001 -0.009352580    0.0434399899
## OpponentFTA            0.213209437 -0.025707797    0.0584669041
## OpponentFTPCT         -0.032862991  0.028078614   -0.0319032781
## OpponentOffRebounds    0.077003661 -0.016936223   -0.0143325753
## OpponentTotalRebounds  0.004736343 -0.177541483   -0.0603891339
## OpponentAssists       -0.063875391 -0.007401206   -0.0386521955
## OpponentSteals         0.006758108 -0.022033431    0.0326977763
## OpponentBlocks        -0.053973588 -0.041175463    0.1571812909
## OpponentTurnovers      0.169704736 -0.035463921    0.1154717115
## OpponentPersonalFouls  0.866395092  0.018757079    0.1240631120
##                       TeamTotalRebounds   TeamAssists   TeamSteals
## Differential                0.470722398  0.5403980088  0.277670288
## TeamFG                      0.328460524  0.6640577242  0.210221346
## TeamFGA                     0.470719037  0.2846591045  0.208743124
## TeamFGPCT                   0.018581908  0.5661529279  0.080191710
## Team3P                      0.038344971  0.5195300862  0.016545254
## Team3PA                     0.120956819  0.2878613903  0.045984003
## Team3PPCT                  -0.062897001  0.4326950943 -0.024665729
## TeamFT                      0.190691619 -0.0163433697  0.088535320
## TeamFTA                     0.231278690 -0.0282892019  0.111199125
## TeamFTPCT                  -0.037356471  0.0259480253 -0.025969502
## TeamOffRebounds             0.637302789  0.0509277222  0.119558104
## TeamTotalRebounds           1.000000000  0.2321524530  0.027446991
## TeamAssists                 0.232152453  1.0000000000  0.164837110
## TeamSteals                  0.027446991  0.1648371104  1.000000000
## TeamBlocks                  0.265518873  0.1447645615  0.065539758
## TeamTurnovers               0.109155292 -0.0789200586  0.078278779
## TeamPersonalFouls          -0.007423332 -0.1050900267  0.005151965
## OpponentFG                 -0.229331788 -0.0022308763 -0.138728115
## OpponentFGA                 0.360268614  0.1863368268 -0.120696505
## OpponentFGPCT              -0.530432484 -0.1397140493 -0.068951590
## Opponent3P                 -0.053371243  0.0354785684 -0.062074442
## Opponent3PA                 0.232049186  0.1116023406 -0.039184667
## Opponent3PPCT              -0.273572339 -0.0502063543 -0.047114732
## OpponentFT                 -0.095266106 -0.0835716395 -0.034152581
## OpponentFTA                -0.022971823 -0.0841605708 -0.022178476
## OpponentFTPCT              -0.194279344 -0.0278263543 -0.041125993
## OpponentOffRebounds        -0.052416263 -0.0333847454  0.016707012
## OpponentTotalRebounds      -0.059965631 -0.2225952122  0.035155522
## OpponentAssists            -0.218597433  0.0006884142 -0.053327136
## OpponentSteals              0.066119486 -0.0288668673  0.055697260
## OpponentBlocks              0.013924890 -0.1657235463 -0.002230784
## OpponentTurnovers          -0.034355689  0.1314533533  0.730885169
## OpponentPersonalFouls       0.189144014 -0.0267820830  0.071442012
##                         TeamBlocks TeamTurnovers TeamPersonalFouls
## Differential           0.257608076  -0.180578328      -0.194427271
## TeamFG                 0.140856644  -0.143210529      -0.014722266
## TeamFGA                0.074555286  -0.223971265       0.107325560
## TeamFGPCT              0.107327505   0.001901048      -0.094653222
## Team3P                 0.004747719  -0.088374940      -0.024028303
## Team3PA               -0.028953212  -0.108839191       0.024995197
## Team3PPCT              0.029427739  -0.020943383      -0.049816585
## TeamFT                 0.092392379   0.051609207       0.217846416
## TeamFTA                0.104112579   0.072070652       0.250787085
## TeamFTPCT             -0.001425412  -0.034614485      -0.025827923
## TeamOffRebounds        0.106016388   0.037172871       0.054233799
## TeamTotalRebounds      0.265518873   0.109155292      -0.007423332
## TeamAssists            0.144764562  -0.078920059      -0.105090027
## TeamSteals             0.065539758   0.078278779       0.005151965
## TeamBlocks             1.000000000   0.032775757      -0.054105029
## TeamTurnovers          0.032775757   1.000000000       0.220285924
## TeamPersonalFouls     -0.054105029   0.220285924       1.000000000
## OpponentFG            -0.143969401   0.081879049      -0.015422966
## OpponentFGA            0.257245080   0.155947902      -0.122639976
## OpponentFGPCT         -0.353110391  -0.023017156       0.078411084
## Opponent3P            -0.103465578  -0.018088322      -0.126817358
## Opponent3PA           -0.042234814   0.041669476      -0.167647391
## Opponent3PPCT         -0.099440199  -0.063187150      -0.015909552
## OpponentFT            -0.070920662   0.123594852       0.793147614
## OpponentFTA           -0.056095076   0.154110278       0.865844664
## OpponentFTPCT         -0.052504157  -0.034267574       0.026877590
## OpponentOffRebounds    0.178200671   0.074131214       0.122282037
## OpponentTotalRebounds  0.037788375  -0.106168146       0.195017438
## OpponentAssists       -0.151146052   0.072644677      -0.022619097
## OpponentSteals         0.028453380   0.709987911       0.064446997
## OpponentBlocks        -0.038978593   0.006463872       0.087211248
## OpponentTurnovers      0.031375703   0.188537020       0.101693555
## OpponentPersonalFouls  0.080582762   0.131539040       0.322258517
##                         OpponentFG  OpponentFGA OpponentFGPCT   Opponent3P
## Differential          -0.538515115  0.001768386  -0.614427717 -0.283754971
## TeamFG                 0.144061400  0.302143806  -0.058571888  0.131517138
## TeamFGA                0.256737262  0.301593528   0.068034775  0.135290090
## TeamFGPCT             -0.020183466  0.126415534  -0.114791403  0.053105214
## Team3P                 0.123800594  0.148931744   0.029908235  0.079455775
## Team3PA                0.156380301  0.130628244   0.080577258  0.074825900
## Team3PPCT              0.029691341  0.081223790  -0.026484376  0.040201241
## TeamFT                 0.057853338  0.193116094  -0.075399282  0.024228311
## TeamFTA                0.043602296  0.193466766  -0.091897172  0.009600704
## TeamFTPCT              0.036986356  0.040334507   0.012864509  0.031763685
## TeamOffRebounds       -0.046469434  0.024235364  -0.068883375 -0.006371032
## TeamTotalRebounds     -0.229331788  0.360268614  -0.530432484 -0.053371243
## TeamAssists           -0.002230876  0.186336827  -0.139714049  0.035478568
## TeamSteals            -0.138728115 -0.120696505  -0.068951590 -0.062074442
## TeamBlocks            -0.143969401  0.257245080  -0.353110391 -0.103465578
## TeamTurnovers          0.081879049  0.155947902  -0.023017156 -0.018088322
## TeamPersonalFouls     -0.015422966 -0.122639976   0.078411084 -0.126817358
## OpponentFG             1.000000000  0.515517123   0.754791141  0.399027442
## OpponentFGA            0.515517123  1.000000000  -0.161220379  0.193563166
## OpponentFGPCT          0.754791141 -0.161220379   1.000000000  0.312295571
## Opponent3P             0.399027442  0.193563166   0.312295571  1.000000000
## Opponent3PA            0.144074778  0.418730422  -0.149367436  0.691451820
## Opponent3PPCT          0.395540055 -0.118020866   0.552279238  0.709404126
## OpponentFT            -0.013421944 -0.156152803   0.106226566 -0.106344743
## OpponentFTA           -0.027151720 -0.151706668   0.086625216 -0.140194309
## OpponentFTPCT          0.037049836 -0.043324702   0.076650746  0.053774302
## OpponentOffRebounds    0.120715447  0.519792207  -0.251623986 -0.085432899
## OpponentTotalRebounds  0.275438081  0.424276325  -0.005789348  0.005903551
## OpponentAssists        0.638304131  0.231851475   0.553535793  0.513869716
## OpponentSteals         0.140823916  0.165329579   0.036468797 -0.011661373
## OpponentBlocks         0.129076992  0.045565883   0.111935521 -0.004746412
## OpponentTurnovers     -0.183558009 -0.215633733  -0.048082678 -0.095218199
## OpponentPersonalFouls  0.015334210  0.136789046  -0.081776664 -0.011247805
##                         Opponent3PA Opponent3PPCT   OpponentFT
## Differential           0.0139102958 -0.3824278411 -0.269300868
## TeamFG                 0.1911319274  0.0080266219  0.019511923
## TeamFGA                0.1384457845  0.0572617563  0.157025930
## TeamFGPCT              0.1187238045 -0.0313705446 -0.091558712
## Team3P                 0.0857043764  0.0296662353  0.009796521
## Team3PA                0.0592729911  0.0463467602  0.063163000
## Team3PPCT              0.0601150176  0.0005076038 -0.039087364
## TeamFT                 0.0798949051 -0.0354784876  0.161311559
## TeamFTA                0.0711931792 -0.0471368607  0.180010001
## TeamFTPCT              0.0325547961  0.0139968801 -0.009352580
## TeamOffRebounds        0.0003753868 -0.0056578317  0.043439990
## TeamTotalRebounds      0.2320491861 -0.2735723395 -0.095266106
## TeamAssists            0.1116023406 -0.0502063543 -0.083571639
## TeamSteals            -0.0391846669 -0.0471147320 -0.034152581
## TeamBlocks            -0.0422348142 -0.0994401990 -0.070920662
## TeamTurnovers          0.0416694763 -0.0631871498  0.123594852
## TeamPersonalFouls     -0.1676473908 -0.0159095518  0.793147614
## OpponentFG             0.1440747785  0.3955400546 -0.013421944
## OpponentFGA            0.4187304220 -0.1180208656 -0.156152803
## OpponentFGPCT         -0.1493674362  0.5522792378  0.106226566
## Opponent3P             0.6914518201  0.7094041257 -0.106344743
## Opponent3PA            1.0000000000  0.0303822862 -0.174340043
## Opponent3PPCT          0.0303822862  1.0000000000  0.016928291
## OpponentFT            -0.1743400433  0.0169282910  1.000000000
## OpponentFTA           -0.1972872368 -0.0080249496  0.928286066
## OpponentFTPCT          0.0101886734  0.0623587723  0.393203255
## OpponentOffRebounds    0.0978389488 -0.2013096986  0.086671729
## OpponentTotalRebounds  0.0810576009 -0.0680836101  0.197591588
## OpponentAssists        0.2641728450  0.4428640799 -0.012378006
## OpponentSteals         0.0214481397 -0.0383569868  0.077614062
## OpponentBlocks        -0.0495426307  0.0354134646  0.101422181
## OpponentTurnovers     -0.0944428800 -0.0421344973  0.015778567
## OpponentPersonalFouls  0.0396475169 -0.0466461289  0.215609923
##                        OpponentFTA OpponentFTPCT OpponentOffRebounds
## Differential          -0.226064714  -0.175223632        -0.089347536
## TeamFG                 0.012937366   0.007923359        -0.036316958
## TeamFGA                0.159529646   0.023732217         0.002848058
## TeamFGPCT             -0.101685664  -0.006190565        -0.042399744
## Team3P                -0.002503282   0.022780414        -0.007870292
## Team3PA                0.054748838   0.025878762        -0.018950808
## Team3PPCT             -0.048073272   0.008651286         0.008677682
## TeamFT                 0.183801456  -0.015688533         0.064938518
## TeamFTA                0.213209437  -0.032862991         0.077003661
## TeamFTPCT             -0.025707797   0.028078614        -0.016936223
## TeamOffRebounds        0.058466904  -0.031903278        -0.014332575
## TeamTotalRebounds     -0.022971823  -0.194279344        -0.052416263
## TeamAssists           -0.084160571  -0.027826354        -0.033384745
## TeamSteals            -0.022178476  -0.041125993         0.016707012
## TeamBlocks            -0.056095076  -0.052504157         0.178200671
## TeamTurnovers          0.154110278  -0.034267574         0.074131214
## TeamPersonalFouls      0.865844664   0.026877590         0.122282037
## OpponentFG            -0.027151720   0.037049836         0.120715447
## OpponentFGA           -0.151706668  -0.043324702         0.519792207
## OpponentFGPCT          0.086625216   0.076650746        -0.251623986
## Opponent3P            -0.140194309   0.053774302        -0.085432899
## Opponent3PA           -0.197287237   0.010188673         0.097838949
## Opponent3PPCT         -0.008024950   0.062358772        -0.201309699
## OpponentFT             0.928286066   0.393203255         0.086671729
## OpponentFTA            1.000000000   0.063446167         0.136423744
## OpponentFTPCT          0.063446167   1.000000000        -0.082982260
## OpponentOffRebounds    0.136423744  -0.082982260         1.000000000
## OpponentTotalRebounds  0.232447345  -0.021281750         0.622115242
## OpponentAssists       -0.031205800   0.041793598         0.009549774
## OpponentSteals         0.097206119  -0.022196700         0.081573888
## OpponentBlocks         0.110063752   0.008946765         0.096186044
## OpponentTurnovers      0.038679394  -0.052040732         0.017562976
## OpponentPersonalFouls  0.251289640  -0.029978048         0.071468553
##                       OpponentTotalRebounds OpponentAssists OpponentSteals
## Differential                   -0.420010794   -0.4916760300   -0.187754380
## TeamFG                         -0.225202127    0.0045585394   -0.102436608
## TeamFGA                         0.316139528    0.1493200670   -0.131734964
## TeamFGPCT                      -0.512983306   -0.1062526818   -0.021724636
## Team3P                         -0.062384273    0.0294135821   -0.053878305
## Team3PA                         0.202896760    0.0825450568   -0.052980367
## Team3PPCT                      -0.263884541   -0.0320289494   -0.025131672
## TeamFT                         -0.064969878   -0.0577300621   -0.001883349
## TeamFTA                         0.004736343   -0.0638753907    0.006758108
## TeamFTPCT                      -0.177541483   -0.0074012062   -0.022033431
## TeamOffRebounds                -0.060389134   -0.0386521955    0.032697776
## TeamTotalRebounds              -0.059965631   -0.2185974327    0.066119486
## TeamAssists                    -0.222595212    0.0006884142   -0.028866867
## TeamSteals                      0.035155522   -0.0533271359    0.055697260
## TeamBlocks                      0.037788375   -0.1511460518    0.028453380
## TeamTurnovers                  -0.106168146    0.0726446766    0.709987911
## TeamPersonalFouls               0.195017438   -0.0226190966    0.064446997
## OpponentFG                      0.275438081    0.6383041307    0.140823916
## OpponentFGA                     0.424276325    0.2318514751    0.165329579
## OpponentFGPCT                  -0.005789348    0.5535357935    0.036468797
## Opponent3P                      0.005903551    0.5138697156   -0.011661373
## Opponent3PA                     0.081057601    0.2641728450    0.021448140
## Opponent3PPCT                  -0.068083610    0.4428640799   -0.038356987
## OpponentFT                      0.197591588   -0.0123780062    0.077614062
## OpponentFTA                     0.232447345   -0.0312058003    0.097206119
## OpponentFTPCT                  -0.021281750    0.0417935976   -0.022196700
## OpponentOffRebounds             0.622115242    0.0095497736    0.081573888
## OpponentTotalRebounds           1.000000000    0.1792668711   -0.038673692
## OpponentAssists                 0.179266871    1.0000000000    0.106822346
## OpponentSteals                 -0.038673692    0.1068223463    1.000000000
## OpponentBlocks                  0.258597044    0.1337215898    0.044367220
## OpponentTurnovers               0.073936193   -0.1060361856    0.074067854
## OpponentPersonalFouls           0.020500608   -0.0849725350    0.030766974
##                       OpponentBlocks OpponentTurnovers
## Differential           -0.2622526274      0.2743269542
## TeamFG                 -0.1604696630      0.1552932747
## TeamFGA                 0.2184838647      0.1981279705
## TeamFGPCT              -0.3562550337      0.0242548332
## Team3P                 -0.1117820624      0.0092841059
## Team3PA                -0.0580421730      0.0638351465
## Team3PPCT              -0.0965607977     -0.0488449748
## TeamFT                 -0.0650555225      0.1369220844
## TeamFTA                -0.0539735876      0.1697047361
## TeamFTPCT              -0.0411754626     -0.0354639208
## TeamOffRebounds         0.1571812909      0.1154717115
## TeamTotalRebounds       0.0139248895     -0.0343556886
## TeamAssists            -0.1657235463      0.1314533533
## TeamSteals             -0.0022307839      0.7308851693
## TeamBlocks             -0.0389785933      0.0313757033
## TeamTurnovers           0.0064638717      0.1885370196
## TeamPersonalFouls       0.0872112484      0.1016935547
## OpponentFG              0.1290769921     -0.1835580089
## OpponentFGA             0.0455658832     -0.2156337333
## OpponentFGPCT           0.1119355214     -0.0480826780
## Opponent3P             -0.0047464115     -0.0952181989
## Opponent3PA            -0.0495426307     -0.0944428800
## Opponent3PPCT           0.0354134646     -0.0421344973
## OpponentFT              0.1014221807      0.0157785673
## OpponentFTA             0.1100637520      0.0386793945
## OpponentFTPCT           0.0089467648     -0.0520407316
## OpponentOffRebounds     0.0961860439      0.0175629757
## OpponentTotalRebounds   0.2585970440      0.0739361927
## OpponentAssists         0.1337215898     -0.1060361856
## OpponentSteals          0.0443672204      0.0740678539
## OpponentBlocks          1.0000000000      0.0001223389
## OpponentTurnovers       0.0001223389      1.0000000000
## OpponentPersonalFouls  -0.0514541037      0.2252310703
##                       OpponentPersonalFouls
## Differential                     0.16902573
## TeamFG                          -0.02311662
## TeamFGA                         -0.10718930
## TeamFGPCT                        0.06015066
## Team3P                          -0.12719701
## Team3PA                         -0.15536393
## Team3PPCT                       -0.02688769
## TeamFT                           0.79353920
## TeamFTA                          0.86639509
## TeamFTPCT                        0.01875708
## TeamOffRebounds                  0.12406311
## TeamTotalRebounds                0.18914401
## TeamAssists                     -0.02678208
## TeamSteals                       0.07144201
## TeamBlocks                       0.08058276
## TeamTurnovers                    0.13153904
## TeamPersonalFouls                0.32225852
## OpponentFG                       0.01533421
## OpponentFGA                      0.13678905
## OpponentFGPCT                   -0.08177666
## Opponent3P                      -0.01124781
## Opponent3PA                      0.03964752
## Opponent3PPCT                   -0.04664613
## OpponentFT                       0.21560992
## OpponentFTA                      0.25128964
## OpponentFTPCT                   -0.02997805
## OpponentOffRebounds              0.07146855
## OpponentTotalRebounds            0.02050061
## OpponentAssists                 -0.08497254
## OpponentSteals                   0.03076697
## OpponentBlocks                  -0.05145410
## OpponentTurnovers                0.22523107
## OpponentPersonalFouls            1.00000000
```

Notice right away -- TeamFG is highly correlated. But it's also highly correlated with TeamFGPCT. And that makes sense. A team that doesn't shoot many shots is not going to have a high score differential. But the number of shots taken and the field goal percentage are also highly related. So including both of these measures would be pointless -- they would add error without adding much in the way of predictive power. 

> **Your turn**: What else do you see? What other values have predictive power and aren't co-correlated? 

We can add more just by simply adding them. 


```r
model2 <- lm(Differential ~ TeamFGPCT + OpponentFGPCT + TeamTotalRebounds + OpponentTotalRebounds, data=logs)
summary(model2)
```

```
## 
## Call:
## lm(formula = Differential ~ TeamFGPCT + OpponentFGPCT + TeamTotalRebounds + 
##     OpponentTotalRebounds, data = logs)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -44.813  -5.586  -0.109   5.453  60.831 
## 
## Coefficients:
##                         Estimate Std. Error  t value Pr(>|t|)    
## (Intercept)            -3.655461   0.606119   -6.031 1.64e-09 ***
## TeamFGPCT             100.880013   0.560363  180.026  < 2e-16 ***
## OpponentFGPCT         -97.563291   0.565004 -172.677  < 2e-16 ***
## TeamTotalRebounds       0.516176   0.006239   82.729  < 2e-16 ***
## OpponentTotalRebounds  -0.436402   0.006448  -67.679  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 8.501 on 57511 degrees of freedom
##   (4 observations deleted due to missingness)
## Multiple R-squared:  0.7291,	Adjusted R-squared:  0.7291 
## F-statistic: 3.87e+04 on 4 and 57511 DF,  p-value: < 2.2e-16
```

Go down the list:

What is the Adjusted R-squared now? 
What is the p-value and is it less than .05?
What is the Residual standard error? 

The final thing we can do with this is predict things. Look at our coefficients table. See the Estimates? We can build a formula from that, same as we did with linear regressions.

```
Differential = (TeamFGPCT*100.880013) + (OpponentFGPCT*-97.563291) + (TeamTotalRebounds*0.516176) + (OpponentTotalRebounds*-0.436402) - 3.655461
```

How does this apply in the real world? Let's pretend for a minute that you are Fred Hoiberg, and you  have just been hired as Nebraska's Mens Basketball Coach. Your job is to win conference titles and go deep into the NCAA tournament. To do that, we need to know what attributes of a team should we emphasize. We can do that by looking at what previous Big Ten conference champions looked like.

So if our goal is to predict a conference champion team, we need to know what those teams did. Here's the regular season conference champions in this dataset. 


```r
logs %>% filter(Team == "Michigan State Spartans" & season == "2018-2019" | Team == "Michigan State Spartans" & season == "2017-2018" | Team == "Purdue Boilermakers" & season == "2016-2017" | Team == "Indiana Hoosiers" & season == "2015-2016" | Team == "Wisconsin Badgers" & season == "2014-2015") %>% summarise(avgfgpct = mean(TeamFGPCT), avgoppfgpct=mean(OpponentFGPCT), avgtotrebound = mean(TeamTotalRebounds), avgopptotrebound=mean(OpponentTotalRebounds))
```

```
## # A tibble: 1 x 4
##   avgfgpct avgoppfgpct avgtotrebound avgopptotrebound
##      <dbl>       <dbl>         <dbl>            <dbl>
## 1    0.489       0.409          35.3             27.2
```

Now it's just plug and chug. 


```r
(0.4886133*100.880013) + (0.4090221*-97.563291) + (35.29834*0.516176) + (27.20994*-0.436402) - 3.655461
```

```
## [1] 12.076
```

So a team with those numbers is going to average scoring 12 more points per game than their opponent.

How does that compare to Nebraska of this past season? The last of the Tim Miles era? 


```r
logs %>% filter(Team == "Nebraska Cornhuskers" & season == "2018-2019") %>% summarise(avgfgpct = mean(TeamFGPCT), avgoppfgpct=mean(OpponentFGPCT), avgtotrebound = mean(TeamTotalRebounds), avgopptotrebound=mean(OpponentTotalRebounds))
```

```
## # A tibble: 1 x 4
##   avgfgpct avgoppfgpct avgtotrebound avgopptotrebound
##      <dbl>       <dbl>         <dbl>            <dbl>
## 1    0.431       0.423          32.5             34.9
```


```r
(0.4305833*100.880013) + (0.4226667*-97.563291) + (32.5*0.516176) + (34.94444*-0.436402) - 3.655461
```

```
## [1] 0.07093015
```

By this model, it predicted we would outscore our opponent by .07 points over the season. So we'd win slightly more than we'd lose. Nebraska's overall record? 19-17. 
