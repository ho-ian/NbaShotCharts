

library(shiny)

shinyUI(fluidPage(
  
  titlePanel("NBA Players' Shot Charts"),
  
  tabsetPanel(type="tabs",
              tabPanel("Shot Charts",
                       sidebarPanel(selectInput("season", "Season:",
                                                c("2018-19",
                                                  "2017-18",
                                                  "2016-17",
                                                  "2015-16",
                                                  "2014-15"),
                                                selected="2018-2019"),
                                    radioButtons("type", "Season Type:",
                                                 c("Regular Season"="Regular+Season",
                                                   "Playoffs"="Playoffs",
                                                   "Pre Season"="Pre+Season"),
                                                 selected="Regular+Season"),
                                    selectInput("team", "Team:",
                                                c("Atlanta Hawks"="1610612737",
                                                  "Boston Celtics"="1610612738",
                                                  "Brooklyn Nets"="1610612751",
                                                  "Charlotte Hornets"="1610612766",
                                                  "Chicago Bulls"="1610612741",
                                                  "Cleveland Cavaliers"="1610612739",
                                                  "Dallas Mavericks"="1610612742",
                                                  "Denver Nuggets"="1610612743",
                                                  "Detroit Pistons"="1610612765",
                                                  "Golden State Warriors"="1610612744",
                                                  "Houston Rockets"="1610612745",
                                                  "Indiana Pacers"="1610612754",
                                                  "Los Angeles Clippers"="1610612746",
                                                  "Los Angeles Lakers"="1610612747",
                                                  "Memphis Grizzlies"="1610612763",
                                                  "Miami Heat"="1610612748",
                                                  "Milwaukee Bucks"="1610612749",
                                                  "Minnesota Timerwolves"="1610612750",
                                                  "New Orleans Pelicans"="1610612740",
                                                  "New York Knicks"="1610612752",
                                                  "Oklahoma City Thunder"="1610612760",
                                                  "Orlando Magic"="1610612753",
                                                  "Philadelphia 76ers"="1610612755",
                                                  "Phoenix Suns"="1610612756",
                                                  "Portland Trail blazers"="1610612757",
                                                  "Sacramento Kings"="1610612758",
                                                  "San Antonio Spurs"="1610612759",
                                                  "Toronto Raptors"="1610612761",
                                                  "Utah Jazz"="1610612762",
                                                  "Washington Wizards"="1610612764"),
                                                selected="1610612744"),
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
