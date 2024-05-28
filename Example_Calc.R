totals = data.frame(nba_leaguedashplayerclutch(season = year_to_season(2023), per_mode = "Totals"))

## Example weight calculation 
## weights taken from 2023-24 league averages 
## of basketball reference
ppp = 1.157
orb = 0.244
drb = 1 - orb
ppFGM = (42.6*2 + 12.9)/42.6

PA_2FGM = 2 - ppp
PA_3FGM = 3 - ppp
PA_FTM = 1 - (ppp*0.44)
PA_FG.miss = -drb*ppp
PA_FT.miss = -0.44*ppp
PA_assist = ppFGM - ppp
PA_drb = orb*ppp
PA_orb = drb*ppp
PA_stls = ppp
PA_blk = ppp*drb
PA_TO = -ppp

colnames(totals) <- sub("LeagueDashPlayerClutch.", "", colnames(totals))


totals <- totals[, -c(1, 4, 6)]

totals <- totals %>%
  mutate_all(~ifelse(is.na(as.numeric(.)), ., as.numeric(.))) %>%
  mutate_at(vars(2), as.character)




totals = totals %>% mutate(totalPA = PA_2FGM*(FGM-FG3M) +
                    PA_3FGM*FG3M + 
                    PA_FTM*FTM + 
                    PA_FG.miss*(FGA-FGM) + 
                    PA_FT.miss*(FTA - FTM) +
                    PA_assist*AST + 
                    PA_drb*DREB +
                    PA_orb*OREB + 
                    PA_stls*STL +
                    PA_blk*BLK +
                    PA_TO*TOV)

clutch = totals %>% select(PLAYER_NAME, TEAM_ID, totalPA)

