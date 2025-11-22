require(shiny)

source("ui.R")
source("server.R")

runApp(shinyApp(ui = ui, server = server))
