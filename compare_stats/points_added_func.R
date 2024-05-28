

points.added.leaderboard = function(year = 2023, min.played = 0){
  
  if(year == "ALL"){
    ret = NULL
    for(i in 1996:2023){
      cur = points.added.leaderboard(i, min.played)
      
      ret = rbind(ret, cur)
    }
    ret = ret %>% select(Season, PLAYER_ID, PLAYER_NAME, 
                         TEAM_ABBREVIATION, MIN, TOTAL.PA, PA.PER.MIN, PTS, 
                         AST, REB, BLK, STL, TOV, FG_PCT, FG3_PCT, FT_PCT)
    
    return(ret)
    
  }
  
  
  if(!(year %in% 1996:2023)){
    return(data.frame())
  }
  
  file_path = paste("compare_stats/data/_", year, ".csv", sep = "")
  season_totals = read.csv(file_path) %>% filter(MIN > min.played)
  
  season_ratings = read.csv("compare_stats/data/per_possession_data.csv") %>% 
    filter(Season == year)
  
  ppp = season_ratings$ppp
  orb.pct = season_ratings$orb.pct
  drb.pct = 1 - orb.pct
  ppFGM = season_ratings$ppFGM
  
  PA_2FGM = 2 - ppp
  PA_3FGM = 3 - ppp
  PA_FTM = 1 - (ppp*0.44)
  PA_FG.miss = -drb.pct*ppp
  PA_FT.miss = -0.44*ppp
  PA_assist = ppFGM - ppp
  PA_drb = orb.pct*ppp
  PA_orb = drb.pct*ppp
  PA_stls = ppp
  PA_blk = ppp*drb.pct
  PA_TO = -ppp
  
  season_totals = season_totals %>% mutate(TOTAL.PA = PA_2FGM*(FGM-FG3M) +
                               PA_3FGM*FG3M + 
                               PA_FTM*FTM + 
                               PA_FG.miss*(FGA-FGM) + 
                               PA_FT.miss*(FTA - FTM) +
                               PA_assist*AST + 
                               PA_drb*DREB +
                               PA_orb*OREB + 
                               PA_stls*STL +
                               PA_blk*BLK +
                               PA_TO*TOV,
                               PA.PER.MIN = TOTAL.PA / MIN)
  
  season_totals = season_totals %>% mutate(Season = year)
  
  season_totals = season_totals %>% 
    select(Season, PLAYER_ID, PLAYER_NAME, TEAM_ABBREVIATION, MIN, TOTAL.PA, 
           PA.PER.MIN, PTS, AST, REB, BLK, STL, TOV, FG_PCT, FG3_PCT, FT_PCT)
  
  return(season_totals)
  
}
