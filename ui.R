

library(shiny)

shinyUI(fluidPage(
  
  titlePanel("NBA Players' Shot Charts"),
  
  tabsetPanel(type="tabs",
              tabPanel("Shot Charts",
                       sidebarPanel(selectInput("season", "Season:",
                                                c("2018-19"=2019,
                                                  "2017-18"=2018,
                                                  "2016-17"=2017,
                                                  "2015-16"=2016,
                                                  "2014-15"=2015),
                                                selected=2019),
                                    radioButtons("type", "Season Type:",
                                                 c("Regular Season",
                                                   "Playoffs",
                                                   "Pre Season"),
                                                 selected="Regular Season"),
                                    selectInput("team", "Team:",
                                                c("Atlanta Hawks",
                                                  "Boston Celtics",
                                                  "Brooklyn Nets",
                                                  "Charlotte Hornets",
                                                  "Chicago Bulls",
                                                  "Cleveland Cavaliers",
                                                  "Dallas Mavericks",
                                                  "Denver Nuggets",
                                                  "Detroit Pistons",
                                                  "Golden State Warriors",
                                                  "Houston Rockets",
                                                  "Indiana Pacers",
                                                  "Los Angeles Clippers",
                                                  "Los Angeles Lakers",
                                                  "Memphis Grizzlies",
                                                  "Miami Heat",
                                                  "Milwaukee Bucks",
                                                  "Minnesota Timerwolves",
                                                  "New Orleans Pelicans",
                                                  "New York Knicks",
                                                  "Oklahoma City Thunder",
                                                  "Orlando Magic",
                                                  "Philadelphia 76ers",
                                                  "Phoenix Suns",
                                                  "Portland Trail blazers",
                                                  "Sacramento Kings",
                                                  "San Antonio Spurs",
                                                  "Toronto Raptors",
                                                  "Utah Jazz",
                                                  "Washington Wizards"),
                                                selected="Golden State Warriors"),
                                    uiOutput("playerList"),
                                    selectInput("makemiss", "Make/Miss",
                                                c("Makes"="makes",
                                                  "Misses"="misses",
                                                  "Makes and Misses"="makesmisses"),
                                                selected="Makes and Misses"),
                                    checkboxGroupInput("shot_zone_basic", "Shot Zone:",
                                                       c("In The Paint" = "In The Paint (Non-RA)",
                                                         "Restricted Area",
                                                         "Mid-Range",
                                                         "Left Corner 3",
                                                         "Right Corner 3",
                                                         "Above the Break 3"),
                                                       selected=c("In The Paint (Non-RA)",
                                                                  "Restricted Area",
                                                                  "Mid-Range",
                                                                  "Left Corner 3",
                                                                  "Right Corner 3",
                                                                  "Above the Break 3"))
                                    
                                    
                       ),
                       
                       mainPanel(
                         plotOutput("shotChartPlot", height="625px", width="625px")
                       )),
              tabPanel("About",
                         htmlOutput("aboutme")
                       ),
              tabPanel("Resources",
                       htmlOutput("resources"))
              )
  
))
