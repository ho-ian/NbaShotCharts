
library(shiny)
library(ggplot2)
library(jsonlite)
library(dplyr)

roster_url = "https://stats.nba.com/stats/commonteamroster?LeagueID=&Season=////&TeamID=///"
shotchart_url = "https://stats.nba.com/stats/shotchartdetail?AheadBehind=&ClutchTime=&ContextFilter=&
ContextMeasure=FGA&DateFrom=&DateTo=&EndPeriod=&EndRange=&GameID=&GameSegment=&LastNGames=0&LeagueID=00&
Location=&Month=0&OpponentTeamID=0&Outcome=&Period=0&PlayerID=//////&PlayerPosition=&PointDiff=&Position=&
RangeType=&RookieYear=&Season=/////&SeasonSegment=&SeasonType=////&StartPeriod=&StartRange=&
TeamID=///&VsConference=&VsDivision="

drawHalfCourt = function() {
    #source: https://gist.github.com/edkupfer/6354964
  
    ## modified to make a halfcourt instead of full court 
    return (ggplot(data=data.frame(x=1,y=1),aes(x,y))+
    ###outside box:
    geom_path(data=data.frame(x=c(-25,-25,25,25,-25),y=c(-4.75,42.25,42.25,-4.75,-4.75)))+
    ###halfcourt line:
    geom_path(data=data.frame(x=c(-25,25),y=c(-4.75,-4.75)))+
    ###halfcourt semicircle:
    geom_path(data=data.frame(x=c(-6000:(-1)/1000,1:6000/1000),y=c(sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))-4.75),aes(x=x,y=y))+
    ###solid FT semicircle above FT line:
    geom_path(data=data.frame(x=c(-6000:(-1)/1000,1:6000/1000),y=c(28-sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))-4.75),aes(x=x,y=y))+
    ###dashed FT semicircle below FT line:
    geom_path(data=data.frame(x=c(-6000:(-1)/1000,1:6000/1000),y=c(28+sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))-4.75),
              aes(x=x,y=y),linetype='dashed')+
    ###key:
    geom_path(data=data.frame(x=c(-8,-8,8,8,-8),y=c(42.25,28-4.75,28-4.75,42.25,42.25)))+
    ###box inside the key:
    geom_path(data=data.frame(x=c(-6,-6,6,6,-6),y=c(42.25,28-4.75,28-4.75,42.25,42.25)))+
    ###restricted area semicircle:
    geom_path(data=data.frame(x=c(-4000:(-1)/1000,1:4000/1000),y=c(37-sqrt(4^2-c(-4000:(-1)/1000,1:4000/1000)^2))),aes(x=x,y=y))+
    ###rim:
    geom_path(data=data.frame(x=c(-750:(-1)/1000,1:750/1000,750:1/1000,-1:-750/1000),
                              y=c(c(37+sqrt(0.75^2-c(-750:(-1)/1000,1:750/1000)^2)),
                                  c(37-sqrt(0.75^2-c(750:1/1000,-1:-750/1000)^2)))),aes(x=x,y=y))+
    ###backboard:
    geom_path(data=data.frame(x=c(-3,3),y=c(38.25,38.25)),lineend='butt')+
    ###three-point line:
    geom_path(data=data.frame(x=c(-22,-22,-22000:(-1)/1000,1:22000/1000,22,22),
                              y=c(42.25,42.25-169/12,37-sqrt(23.75^2-c(-22000:(-1)/1000,1:22000/1000)^2),42.25-169/12,42.25)),aes(x=x,y=y))+
    ###fix aspect ratio to 1:1
    coord_fixed() +
    
    # make plot black and white and remove axis components
    theme_bw() +
    theme(panel.border = element_blank(), panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
          axis.text = element_blank(), axis.ticks = element_blank(),
          axis.title = element_blank(), axis.line.x = element_blank(), axis.line.y = element_blank())
    )
}

getRoster = function(season,team, url) {
  url = gsub("////", season, url)
  url = gsub("///", team, url)
  
  team_info = read_json(url, simplifyVector = TRUE) # don't overuse
  header = team_info[[3]][[2]][[1]]
  team_info = as.data.frame(team_info[[3]][[3]][[1]])
  names(team_info) = header
  
  info_keep = c("PLAYER", "POSITION", "HEIGHT", "WEIGHT", "PLAYER_ID")
  team_info = select(team_info, info_keep)
  return (team_info)
  
}

getShotChart = function(player, season, type, team, url, shot_zone_basic) {
  url = gsub("//////", player, url)
  url = gsub("/////", season, url)
  url = gsub("////", type, url)
  url = gsub("///", team, url)
  
  shot_chart = read_json(url, simplifyVector=TRUE)
  header = shot_chart[[3]][[2]][[1]]
  shot_chart = as.data.frame(shot_chart[[3]][[3]][[1]])
  
  
  if (length(shot_chart) == 0) {
    return (shot_chart)
  }
  names(shot_chart) = header
  
  info_keep = c("PLAYER_NAME", "PERIOD", "MINUTES_REMAINING", 
                "SECONDS_REMAINING","SHOT_ZONE_BASIC", "SHOT_DISTANCE",
                "LOC_X", "LOC_Y", "SHOT_MADE_FLAG")
  
  shot_chart = select(shot_chart, info_keep)
  shot_chart = shot_chart[shot_chart$SHOT_ZONE_BASIC %in% shot_zone_basic,]
  shot_chart$SHOT_MADE_FLAG = as.numeric(as.character(shot_chart$SHOT_MADE_FLAG))
  shot_chart$LOC_X = as.numeric(as.character(shot_chart$LOC_X))/10
  shot_chart$LOC_Y = as.numeric(as.character(shot_chart$LOC_Y))/10

  shot_chart$LOC_Y = 37 - shot_chart$LOC_Y #flip it bc they consider the rim as (0,0) but my rim is (0,37)
  
  return (shot_chart)
}

shinyServer(function(input, output) {
  
  output$playerList <- renderUI({
    ti = getRoster(input$season, input$team, roster_url)
    selectInput("players", "Player:", setNames(as.list(ti$PLAYER_ID), ti$PLAYER), selected="201939") #default to stephen curry
  })
   
  output$shotChartPlot <- renderPlot({
    
    hc = drawHalfCourt()
    sc = getShotChart(input$players, input$season, input$type, input$team, shotchart_url, input$shot_zone_basic)
    
    if (length(sc)!=0) {
      sctitle = paste(sc[1,"PLAYER_NAME"], "Shot Chart Details", sep=" ")
      if (input$makemiss == "makes") {
        makes = sc[sc$SHOT_MADE_FLAG == 1,]
        hc + xlim(-25,25) + ylim(-4.75, 42.25) + geom_point(data = makes, mapping=aes(x=LOC_X, y=LOC_Y),alpha=0.75,shape="circle open", size=1.5, col="chartreuse3")+
          ggtitle(sctitle) + theme(plot.title = element_text(face="bold",size=30,hjust=0.5), legend.position = "none")
      }
      
      else if (input$makemiss == "misses") {
        misses = sc[sc$SHOT_MADE_FLAG == 0,]
        hc + xlim(-25,25) + ylim(-4.75, 42.25) + geom_point(data = misses, mapping=aes(x=LOC_X, y=LOC_Y),alpha=0.75,shape="cross", size=1.5, col="firebrick1")+
          ggtitle(sctitle) + theme(plot.title = element_text(face="bold",size=30,hjust=0.5), legend.position = "none")
      }
      
      else {
        makes = sc[sc$SHOT_MADE_FLAG == 1,]
        misses = sc[sc$SHOT_MADE_FLAG == 0,]
        hc + xlim(-25,25) + ylim(-4.75, 42.25) + geom_point(data = misses, mapping=aes(x=LOC_X, y=LOC_Y),alpha=0.75,shape="cross", size=1.5, col="firebrick1")+
          geom_point(data = makes, mapping=aes(x=LOC_X, y=LOC_Y),shape="circle open", size=1.5, col="chartreuse3")+
          ggtitle(sctitle) + theme(plot.title = element_text(face="bold",size=30,hjust=0.5), legend.position = "none")
      }
    }
    else {
      hc + xlim(-25,25) + ylim(-4.75, 42.25) + ggtitle("SHOT CHART UNAVAILABLE") + theme(plot.title = element_text(face="bold",size=30,hjust=0.5), legend.position = "none")
    }
    
  })
  
  output$aboutme <- renderUI({
    
    HTML("<h3><strong>Created By:</strong></h3></br>
         <h4>Ian Ho - Computer Science Undergraduate from Simon Fraser University</h4></br>
         <a href='https://github.com/ho-ian'>Github</a></br>
         <a href='https://www.linkedin.com/in/ian-ho-015149106/'>LinkedIn</a></br>
         <h3><strong>Description:</strong></h3></br>
         <h4>I originally wanted to create an app that would display the Toronto Raptors' core players
         and their shooting charts based on wins and losses in order to compare how well they shot in 
         both scenarios. It was first created on a Jupyter Notebook but it didn't have the flexibility 
         that I wanted. After learning and using more RSTUDIO, I learned about ShinyApps from STAT 240
         from SFU and now I combined the two ideas to provide more choices to the user and display more
         information than I had originally planned. If there are more things you would like to see
         in this web app, please visit the github page for the source code and contribute if you would like.</h4></br>
         <h3><strong>Contributors:</strong></h3></br>
         </br>
         <h3><strong>Github Page:</strong></h3></br>")
    
  })
  
  output$resources <- renderUI({
    
    HTML("<h3><strong>Resources Used:</strong></h3></br>
         <a href='https://stats.nba.com/'>Nba Stats Api</a></br>
         <a href='https://gist.github.com/edkupfer/6354964'>Drawing of the NBA court</a>")
    
  })
  
})
