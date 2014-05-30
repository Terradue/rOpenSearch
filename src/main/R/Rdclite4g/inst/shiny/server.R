library(shiny)
library(RCurl)
library(XML)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should re-execute automatically
  #     when inputs change
  #  2) Its output type is a plot
  dataInput <- reactive({ 
  
    if(input$get == 0) return(NULL)
    
    value <- c(100, "2010-01-10", "2010-01-31")
    type <- c("count", "time:start", "time:end")
    df.params <- data.frame(type, value)
  
  })

  output$osd.url <- renderText({
  
     if(input$get == 0) return(NULL)
  
     paste("You have queried ", input$osd)
  })

  output$mytable = renderDataTable({
  
       if(input$get == 0) return(NULL)
    
      res <- Query(input$osd, df.params)
      
      res$series
  })
#  output$distPlot <- renderPlot({
#    x    <- faithful[, 2]  # Old Faithful Geyser data
#    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
 #   hist(x, breaks = bins, col = 'darkgray', border = 'white')
#  })
})
