d1 <- reactive(nba_leaguedashplayerclutch(season = year_to_season(gsub(pattern = "-.*", replacement = "", x = input$year))) |> 
                 as.data.frame() |> 
                 rename_with(.cols = everything(), .fn = ~gsub(pattern = "LeagueDashPlayerClutch.", replacement = "", x = .)) |> 
                 mutate_if(is.character, as.numeric) |> 
                 select(-excluded))

d2 <- reactive(nba_leaguedashplayerclutch(season = year_to_season(gsub(pattern = "-.*", replacement = "", x = input$year))) |>
                 as.data.frame() |> 
                 rename_with(.cols = everything(), .fn = ~gsub(pattern = "LeagueDashPlayerClutch.", replacement = "", x = .)) |> 
                 mutate(PLAYER_ID = as.numeric(PLAYER_ID)) |>
                 select(PLAYER_ID, PLAYER_NAME, NICKNAME, TEAM_ABBREVIATION) |>
                 left_join(d1(), join_by(PLAYER_ID)))

weights <- reactive(lm(W_PCT ~ FG_PCT + PTS + PF + BLK + STL + TOV + AST + DREB + OREB, data = d2()) |> 
                      tidy() |> 
                      slice(2:10) |> 
                      select(estimate) |> 
                      data.matrix())

final <- reactive(data.matrix(select(d2(), FG_PCT, PTS, PF, BLK, STL, TOV, AST, DREB, OREB)) %*% weights() |>
                    as.data.frame() |> 
                    cbind(tidy_clutch) |> 
                    rename(clutch_score = estimate))