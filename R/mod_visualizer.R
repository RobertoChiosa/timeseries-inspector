#' visualizer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#' @import shiny highcharter magrittr dplyr

mod_visualizer_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    wellPanel(
      fluidRow(
        
        column(width = 2,
               h3("Series"),
               textInput(ns("series_name"), label = NULL, placeholder = "Series name.."),
               selectInput(ns("units"), label = NULL, choices = c( "Units of measure..."= "", "kW"))
        ),
        column(width = 2,
               h3("Axis"),
               textInput(ns("xlabel"), label = NULL, placeholder = "X Axis label..."),
               textInput(ns("ylabel"), label = NULL, placeholder = "Y Axis label..."),
               
        ),
        column(width = 2,
               h3("Annotations"),
               textInput(ns("title"), label = NULL, placeholder = "Title.."),
               textInput(ns("subtitle"), label = NULL, placeholder = "Subtitle.."),
               
        ),
        column(width = 2,
        ),
        column(width = 2,
        )
      )
    ),
    fluidRow(
      highchartOutput(ns("plot"), height = "500px")
    )
  )
}

#' visualizer Server Functions
#'
#' @noRd 
mod_visualizer_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    output$plot <- renderHighchart({
      
      
      highcharter::hchart(data, name = ifelse(input$series_name == "", "Series", input$series_name) ) %>%
        # hc_add_series(qxts[,2],  type = "spline", name = "Canteen") %>%
        highcharter::hc_xAxis(
          title = list(
            text =  ifelse(input$xlabel == "", "", input$xlabel) 
          )
        ) %>%
        highcharter::hc_yAxis(
          labels = list(
            format = paste('{value}', ifelse(input$units == "", "", input$units))
          ),
          title = list(
            text = ifelse(input$ylabel == "", "", input$ylabel),      # The actual title text
            align = "middle"   # Documentation says options are: low, middle or high
          )
        ) %>%
        highcharter::hc_exporting(
          
          enabled=T,
          buttons=list(
            contextButton = list(
              align = 'right',
              verticalAlign = 'top'
            )
          )
          
        ) %>% 
        highcharter::hc_chart(zoomType = 'xy') %>%
        highcharter::hc_title(
          text = ifelse(input$title == "", "", input$title),
          align = "left",
          style = list(fontSize = "20px",
                       fontStyle = "bold")
        ) %>%
        highcharter::hc_subtitle(
          text = ifelse(input$subtitle == "", "", input$subtitle),
          align = "left",
          style = list(fontSize = "12px",
                       fontStyle = "italic")
        ) %>% 
        # highcharter::hc_legend(
        #   enabled = TRUE,
        #   align = "bottom",
        #   verticalAlign = "top",
        #   layout = "vertical",
        #   x = 0,
        #   y = 0
        # ) %>%
        highcharter::hc_tooltip(
          shared = TRUE,
          split = FALSE,
          pointFormat = paste('{point.series.name} = {point.y:.2f}',ifelse(input$units == "", "", input$units) ,'<br>'),
          crosshairs = c(TRUE, TRUE)
        )  %>%
        highcharter::hc_rangeSelector(
          verticalAlign = "top",
          align = 'center',
          # selected = 4,
          buttons = list(
            list(count = 1,
                 text = 'All',
                 type = 'all'),
            list(count = 1,
                 text = '1yr',
                 type = 'year'),
            list(count = 6,
                 text = '6mo',
                 type = 'month'),
            list(count = 1,
                 text = '1mo',
                 type = 'month'),
            list(count = 7,
                 text = '1w',
                 type = 'day'),
            list(count = 1,
                 text = '1d',
                 type = 'day'),
            list(count = 6,
                 text = '6h',
                 type = 'hour')
          )
        ) 
      
      
    })
    
  })
}

## To be copied in the UI
# mod_visualizer_ui("visualizer_ui_1")

## To be copied in the server
# mod_visualizer_server("visualizer_ui_1")

# library(shiny)
# library(highcharter)
# library(dplyr)
# library(magrittr)
# 
# ui <- fluidPage(
#   mod_visualizer_ui("visualizer_ui_1")
# )
# 
# server <- function(input, output, session) {
#   mod_visualizer_server("visualizer_ui_1")
# }
# 
# shinyApp(ui, server)
