library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Hello Shiny!"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      textInput("osd", label = h3("OpenSearch description URL"), 
        value = "http://eo-virtual-archive4.esa.int/search/ASA_IM__0P/description"), 
        dateRangeInput("dates", label = h3("Date range")),
        br(), 
        actionButton("get", "Get Stock")

    ),

    # Show a plot of the generated distribution
    mainPanel(
      textOutput("osd.url")
    )
  )
))
