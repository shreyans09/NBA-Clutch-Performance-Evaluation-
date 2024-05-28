library(shiny)
library(tidyverse)
library(hoopR)  
library(tidymodels)
library(shinythemes)

filter_choices <- c("Name", "Season", "Team", "Clutch", "PA.PER.MIN", "MIN",
                    "PTS", "AST", "OREB", "DREB", "BLK", "STL", "TOV", "FG_PCT")

year <- c("1996-97", "1997-98", "1998-99", "1999-00", "2000-01", "2001-02", "2002-03", "2003-04", "2004-05", "2005-06", "2006-07", "2007-08", "2008-09", "2009-10", "2010-11", "2011-12", "2012-13", "2013-14", "2014-15", "2015-16", "2016-17", "2017-18", "2018-19", "2019-20", "2020-21", "2021-22", "2022-23", "2023-24", "All")

excluded <- c("GROUP_SET", "PLAYER_NAME", "NICKNAME", "TEAM_ABBREVIATION")

clutch1 <- function(year) {
  
  d2 <- read.csv(paste("data/_", gsub(pattern = "-.*", replacement = "", x = year), ".csv", sep = ""))
  
  weights <- lm(W_PCT ~ FG_PCT + PTS + PF + BLK + STL + TOV + AST + DREB + OREB, data = d2) |> 
    tidy() |> 
    slice(2:10) |> 
    select(estimate) |>
    data.matrix()
  
  final <- d2 |> 
    select(FG_PCT, PTS, PF, BLK, STL, TOV, AST, DREB, OREB) |> 
    data.matrix() %*% weights |>
    as.data.frame() |>
    cbind(d2) |> 
    rename(clutch_score = estimate)
  
  return(final)
}

points.added.leaderboard = function(year){
  
  if(year == "All"){
    ret = NULL
    for(i in 1996:2023){
      cur = points.added.leaderboard(i)
      
      ret = rbind(ret, cur)
    }
    ret = ret %>% select(Season, PLAYER_ID, PA.PER.MIN)
    
    return(ret)
    
  }
  
  file_path = paste("data/_", gsub(pattern = "-.*", replacement = "", x = year), ".csv", sep = "")
  season_totals <- read.csv(file_path)
  season_totals <- season_totals |> 
    mutate(Season = gsub(pattern = "-.*", replacement = "", x = year)) |> 
    mutate(Season = as.numeric(Season))
  
  season_ratings = read.csv("data/per_possession_data.csv") %>% 
    filter(Season == gsub(pattern = "-.*", replacement = "", x = year))
  
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
  
  season_totals = season_totals %>% 
    select(Season, PLAYER_ID, PA.PER.MIN) |> 
    mutate(PLAYER_ID = as.numeric(PLAYER_ID))
  
  return(season_totals)
}

ui <- fluidPage(theme = shinytheme("darkly"),
                
                titlePanel("Clutch Players"),
                
                sidebarLayout(
                  sidebarPanel(
                    selectInput("filter", "Filter Data",
                                filter_choices),
                    selectInput("year", "Choose Year",
                                year),
                    numericInput("minutes", "Choose Minute Minimum", 0)
                  ),
                  mainPanel(
                    tableOutput("player_clutch")
                  )
                )
)

server <- function(input, output) {
  
  output$player_clutch <- renderTable({
    
    if(input$year == "All"){
      final_list <- lapply(1996:2023, function(i) {
        current <- clutch1(i) |> 
          mutate(Season = i)
        return(current)
      })
      final <- bind_rows(final_list)
    } else {
      final <- clutch1(input$year) |> 
        mutate(Season = gsub(pattern = "-.*", replacement = "", x = input$year))
    }
    
    leaderboard_data <- points.added.leaderboard(gsub(pattern = "-.*", replacement = "", x = input$year))
    
    final <- data.frame(final) %>%
      select(Season, MIN, PLAYER_ID, PLAYER_NAME, clutch_score, TEAM_ABBREVIATION, W, L, FG_PCT,
             PTS, PF, BLK, STL, TOV, AST, DREB, OREB) %>%
      mutate(Season = as.numeric(Season)) |> 
      rename(Team = TEAM_ABBREVIATION,
             Name = PLAYER_NAME,
             Clutch = clutch_score) %>%
      mutate(Clutch = Clutch * 100) %>%
      left_join(leaderboard_data, by = c("PLAYER_ID", "Season")) |> 
      select(Name, Season, Team, Clutch, PA.PER.MIN, MIN, 
             PTS, AST, OREB, DREB, BLK, STL, TOV, FG_PCT) |> 
      mutate(Season = as.integer(Season))
    
    final |> 
      filter(MIN > input$minutes) %>%
      arrange(desc(!!sym(input$filter)))
    
  })
  
}

shinyApp(ui = ui, server = server)
