# NBA Shot Charts
I wanted to create a short web app that could easily visualize stats.nba.com's Shot Chart Details of each player based on Season and Team. 
Unforunately, the deployed version of the web app does not work with stats.nba.com. This took me a while to debug but I also found that
another similar web app had the same issue here: https://github.com/toddwschneider/ballr.

This app does work locally though, so feel free to try it out.

## Getting Started
To get started using my app locally, just pull the repository and make sure you have R installed with shiny web app capabilities.

### Prerequisites
The only required libraries are 'ggplot2' and 'nbastatR'.

Run these two commands in the R console inside RSTUDIO:
install.packages('ggplot2')
devtools::install_github("abresler/nbastatR")

### Running the App
Once everything is setup, click 'Run App' or use the command runApp('NBAShotCharts') in the console.

### Examples
![Stephen Curry Shot Chart](https://github.com/ho-ian/NbaShotCharts/tree/master/screenshots)
![Demar Derozan Playoff 2's](https://github.com/ho-ian/NbaShotCharts/blob/master/screenshots/2.png)

## Built With
* [nbastatsR] (https://github.com/abresler/nbastatR)
* [nba court] (https://gist.github.com/edkupfer/6354964)
