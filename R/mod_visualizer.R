#' visualizer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#' @import shiny highcharter magrittr dplyr
#' @importFrom colourpicker colourInput
#' @importFrom shinycssloaders withSpinner

mod_visualizer_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    fluidRow( style = 'padding:20px',
              shinycssloaders::withSpinner(
                highchartOutput(ns("plot"), height = "500px"),
                type = 7, color = "#158cba", size = 1),
              
             
              column(width = 2,
                     actionButton(ns("upload"), "Upload .csv", icon = icon("upload"), class = "btn-success", width = "100%")
              ),
              column(width = 2,
                     actionButton(ns("refresh"), "Refresh graph", icon = icon("spinner"), class = "btn-success", width = "100%")
              ),
              column(width = 8,
                     HTML("This Shiny App permits to visually inspect a timeseries. Just upload a <code>.csv</code> file and visualize.
                    The file must have the first column <code>timestamp</code> in ISO format (<code>YYYY-mm-dd HH:MM:SS</code>)
                    and the second column a numerical variable called <code>variable</code>.")
              ),
    ),
    wellPanel(
      fluidRow(
        column(width = 4,
               textInput(ns("series_name"), label = NULL, placeholder = "Series name.."),
               selectInput(ns("units"), label = NULL, choices = c( "Units of measure..."= "", "kW")),
               colourpicker::colourInput(ns("color"), label = NULL, "#158cba")
        ),
        column(width = 4,
               textInput(ns("xlabel"), label = NULL, placeholder = "X Axis label..."),
               textInput(ns("ylabel"), label = NULL, placeholder = "Y Axis label...")
        ),
        column(width = 4,
               textInput(ns("title"), label = NULL, placeholder = "Title.."),
               textInput(ns("subtitle"), label = NULL, placeholder = "Subtitle.."),
               textInput(ns("credits"), label = NULL, placeholder = "Credits ..."),
               textInput(ns("credits_href"), label = NULL, placeholder = "Credits link https://www...")
               
        )
      )
    )
  )
}

#' visualizer Server Functions
#'
#' @noRd 
mod_visualizer_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    xlabel       <- eventReactive(input$refresh, { input$xlabel },  ignoreNULL = F)
    ylabel       <- eventReactive(input$refresh, { input$ylabel } ,  ignoreNULL = F)
    units        <- eventReactive(input$refresh, { input$units } ,   ignoreNULL = F)
    title        <- eventReactive(input$refresh, { input$title } ,   ignoreNULL = F)
    subtitle     <- eventReactive(input$refresh, { input$subtitle } ,   ignoreNULL = F)
    series_name  <- eventReactive(input$refresh, { input$series_name } ,   ignoreNULL = F)
    credits      <- eventReactive(input$refresh, { input$credits } ,   ignoreNULL = F)
    credits_href <- eventReactive(input$refresh, { input$credits_href } ,   ignoreNULL = F)
    
    
    output$plot <- renderHighchart({
      
     
      
      highcharter::hchart(
        data, 
        name = ifelse(series_name() == "", "Series",  series_name() ) ,
        color = input$color
      ) %>%
        # X AXIS OPTIONS https://api.highcharts.com/highcharts/xAxis
        highcharter::hc_xAxis(
          title = list(
            text =  ifelse(xlabel() == "", "", xlabel()) 
          )
        ) %>%
        
        # Y AXIS OPTIONS https://api.highcharts.com/highcharts/yAxis
        highcharter::hc_yAxis(
          labels = list(
            format = paste('{value}', ifelse(units() == "", "", units()))
            
          ),
          offset = 50, # prevents overlap of labels
          opposite = T,
          title = list(
            text = ifelse( ylabel() == "", "", ylabel()),      # The actual title text
            align = "middle"   # Documentation says options are: low, middle or high
          )
        ) %>%
        # EXPORT
        highcharter::hc_exporting(
          enabled = T,
          sourceWidth = 1000,
          sourceHeight = 500,
          scale = 1.5, 
          buttons=list(
            contextButton = list(
              align = 'right',
              verticalAlign = 'top'
            )
          )
          
        ) %>% 
        # CHART OPTIONS https://api.highcharts.com/highcharts/chart
        highcharter::hc_chart(
          zoomType = 'xy'
          # marginLeft = 30
          # marginRight = 60
        ) %>%
        # TITLE 
        highcharter::hc_title(
          text = ifelse( title() == "", "", title()),
          align = "left",
          style = list(fontSize = "20px",
                       fontStyle = "bold")
        ) %>%
        highcharter::hc_subtitle(
          text = ifelse(subtitle() == "", "", subtitle()),
          align = "left",
          style = list(fontSize = "12px",
                       fontStyle = "italic")
        ) %>% 
        highcharter::hc_credits(
          enabled = TRUE,
          text = ifelse(credits() == "", "", credits()),
          href = ifelse(credits_href() == "", "", credits_href())
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
          pointFormat = paste('<span style="color:{series.color}">{series.name}</span>= {point.y:.2f}',ifelse(units() == "", "", units()) ,'<br>'),
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
