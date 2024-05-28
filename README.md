# Clutch Performance Analysis

## Motivation, Data, and Challenges

## Methodology 1

Our first method quantifies the "importance" of each box score statistic using a points-added approach. It relies upon the the leage-wide points per posession for a given season to estimate the impact of clutch actions. If we say the leage-wide points per possession for a given season was **PPP**, we calculate total points added in the clutch as follows...

#### Clear Ends to Possession
The values below are the easiest to calculate. When a box score stat represents a clear end to the possession, we can simply calculate the difference between how many points the possession ended in and what the league-wide expectation was. With respect to assists, we can estimate the points scored on the possession using that season's ratio of 2pt FGMs to 3pt FGMs (or points per FGM). 
- **Points Added From 2pt FGM** = 2 - **PPP**
- **Points Added From 3pt FGM** = 3 - **PPP**
- **Points Added From Assits** = **Points Per FGM** - **PP**
- **Points Added From Steal** = **PPP**
- **Points Added From Turnover** = -**PPP**

#### Rebounds
We can quantify the value of a defensive rebound by viewing it as taking away the opponent's chance to regain possession. There is an **ORB%** chance that the opponent would get another posession, which are expected points a defensive rebound takes away. Similarly, the value of an offensive rebound can be quantified by viewing it as a possession extension. There is a **DRB%** chance the opponent will end the possession after a missed shot, which is value an offensive rebound adds back. For rebounding rates, we will use the league-wide rates for a given season.
- **Points Added From DRB** = **ORB%** * **PPP**
- **Points Added From ORB** = **DRB%** * **PPP**

#### Unclear Ends to Possession
After a missed field goal, the offensive team can still regain possession with an offensive rebound. Similarly, a blocked shot does not gaurantee the offensive team will score 0 points on the possession. When the end to a possession is unclear, we can use rebounding rate to estimate the likelihood (and impact) of different outcomes. 
- **Points Added From FG Miss** = -**DRB%** * **PPP**
- **Points Added From Block** = **DRB%** * **PPP**

#### Free Throws
Free throws are the most difficult box score stat to quantify impact for, as it is unclear what an individual free throw attempt says about the overall outcome of the possession. Here we rely on the formula for True Shooting Percentage for help, which weights a FTA as 0.44% of a FGA. Here we ignore the potential for offensive rebounds because they are so uncommon.  
- **Points Added FTM** = 1 - 0.44**PPP**
- **Points Added FT Miss** = -0.44**PPP**

#### Drawbacks

This weighted-points-added system for box score stats has many drawbacks. First of all, it does nothing to evaluate contributions missing from the box score, particularly defense. It is also an oversimplification of the impact of rebounds and how rebounding rates impact other plays. Finally, this metric favors players who fill up the box score in more ways than just scoring, which may conflict with some people's definition of clutch. One might see it as more a "Crunch Time MVP" than a "Clutch Player of the Year". 

## Methodology 2

Our second method seeks to evaluate player performance in clutch time by evaluating each statistical contribution's correlation with the win percentage of a player. This is accomplished by fitting a linear model to assign weights to each statistic. The linear model that was fit models win percentage using players' field goal percentage, points scored, personal fouls, blocks, steals, turnovers, assists, defensive rebounds, and offensive rebounds. The weights that are calculated take into account only players from the given year, and thus vary from year to year as scoring and other statistics fluctuate. Once the weights are calculated, a final clutch statistic for each player is created by multiplying the data in matrix form with the vector of weights.

## RShiny App

A link to our RShiny application that allows for comparison between players using these calculations can be found here: https://logan-godfrey.shinyapps.io/compare_stats/

