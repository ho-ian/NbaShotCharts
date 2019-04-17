
library(shiny)
library(ggplot2)
library(jsonlite)
library(dplyr)
library(nbastatR)
library(rvest)
library(xml2)

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

getRoster = function(season, team) {
  team_info = team_season_roster(team=team, season=season, return_message=T)
  
  info_keep = c("namePlayer", "groupPosition", "heightInches", "weightLBS")
  team_info = select(team_info, info_keep)
  return (team_info)
  
}

getShotChart = function(player, season, type, team, shot_zone_basic) {
  shot_chart = teams_shots(teams=team, measures="FGA", seasons=season, season_types=type, return_message=T)
  
  if (length(shot_chart) == 0) {
    return (shot_chart)
  }
  
  info_keep = c("namePlayer", "nameTeam", "numberPeriod", "minutesRemaining",
                "secondsRemaining","zoneBasic", "locationX", "locationY", "isShotMade")
  
  shot_chart = shot_chart[shot_chart$namePlayer == player,]
  shot_chart = select(shot_chart, info_keep)
  shot_chart = shot_chart[shot_chart$zoneBasic %in% shot_zone_basic,]
  shot_chart$locationX = as.numeric(as.character(shot_chart$locationX))/10
  shot_chart$locationY = as.numeric(as.character(shot_chart$locationY))/10

  shot_chart$locationY = 37 - shot_chart$locationY #flip it bc they consider the rim as (0,0) but my rim is (0,37)
  
  return (shot_chart)
}

shinyServer(function(input, output) {
  
  output$playerList <- renderUI({
    ti = getRoster(as.numeric(input$season), input$team)
    selectInput("players", "Player:", as.list(ti$namePlayer), selected="Stephen Curry") #default to stephen curry
  })
   
  output$shotChartPlot <- renderPlot({
    
    hc = drawHalfCourt()
    sc = getShotChart(input$players, as.numeric(input$season), input$type, input$team, input$shot_zone_basic)
    #head(sc)
    
    if (length(sc)!=0) {
      sctitle = paste(sc[1,"namePlayer"], "Shot Chart Details", sep=" ")
      if (input$makemiss == "makes") {
        makes = sc[sc$isShotMade,]
        hc + xlim(-25,25) + ylim(-4.75, 42.25) + geom_point(data = makes, mapping=aes(x=locationX, y=locationY),alpha=0.75,shape="circle open", size=1.5, col="chartreuse3")+
          ggtitle(sctitle) + theme(plot.title = element_text(face="bold",size=30,hjust=0.5), legend.position = "none")
      }
      
      else if (input$makemiss == "misses") {
        misses = sc[!sc$isShotMade,]
        hc + xlim(-25,25) + ylim(-4.75, 42.25) + geom_point(data = misses, mapping=aes(x=locationX, y=locationY),alpha=0.75,shape="cross", size=1.5, col="firebrick1")+
          ggtitle(sctitle) + theme(plot.title = element_text(face="bold",size=30,hjust=0.5), legend.position = "none")
      }
      
      else {
        makes = sc[sc$isShotMade,]
        misses = sc[!sc$isShotMade,]
        hc + xlim(-25,25) + ylim(-4.75, 42.25) + geom_point(data = misses, mapping=aes(x=locationX, y=locationY),alpha=0.75,shape="cross", size=1.5, col="firebrick1")+
          geom_point(data = makes, mapping=aes(x=locationX, y=locationY),shape="circle open", size=1.5, col="chartreuse3")+
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
         <h3><strong>Github Page:</strong></h3></br>
         <a href='https://github.com/ho-ian/NbaShotCharts'>Link</a>")
    
  })
  
  output$resources <- renderUI({
    
    HTML("<h3><strong>Resources Used:</strong></h3></br>
         <a href='https://stats.nba.com/'>Nba Stats Api</a></br>
         <a href='https://gist.github.com/edkupfer/6354964'>Drawing of the NBA court</a>")
    
  })
  
})
