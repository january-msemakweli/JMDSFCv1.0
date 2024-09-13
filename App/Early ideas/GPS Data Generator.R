library(shiny)
library(shinyjs)
library(leaflet)
library(DT)

ui <- fluidPage(
  useShinyjs(),
  
  titlePanel("JMDSFCv1.0: Dataset Format Converter - GPS Data Generation"),
  
  tabsetPanel(
    tabPanel("GPS Data Generation",
             sidebarLayout(
               sidebarPanel(
                 h4("Generated GPS Data"),
                 actionButton("getLocation", "Add My Location"),
                 dataTableOutput("gpsTable"),
                 br(),
                 downloadButton("downloadGPS", "Download GPS Data")
               ),
               mainPanel(
                 h4("GPS Points Map"),
                 leafletOutput("map", height = 500)
               )
             )
    )
  ),
  
  hr(),
  
  div("Developed by January G. Msemakweli & Khalid Mzuka", style = "text-align: right; font-size: small;"),
  
  # JavaScript to get device location
  tags$script(HTML("
    shinyjs.getLocation = function() {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(onSuccess, onError);
      } else {
        Shiny.onInputChange('geolocation', {error: 'Geolocation is not supported by this browser.'});
      }
    
      function onSuccess(position) {
        Shiny.onInputChange('geolocation', {
          lat: position.coords.latitude,
          long: position.coords.longitude,
          time: new Date()
        });
      }
    
      function onError(error) {
        Shiny.onInputChange('geolocation', {error: error.message});
      }
    };
  "))
)

server <- function(input, output, session) {
  # GPS Data ----
  gps_data <- reactiveVal(data.frame(
    ID = integer(),
    Longitude = numeric(),
    Latitude = numeric()
  ))
  
  # Add actual device location to the dataset
  observeEvent(input$getLocation, {
    runjs("shinyjs.getLocation()")  # Trigger JS to get location
  })
  
  observeEvent(input$geolocation, {
    if (!is.null(input$geolocation$lat) && !is.null(input$geolocation$long)) {
      new_point <- data.frame(
        ID = nrow(gps_data()) + 1,
        Longitude = round(input$geolocation$long, 11),  # Round to 11 decimals
        Latitude = round(input$geolocation$lat, 11)     # Round to 11 decimals
      )
      gps_data(rbind(gps_data(), new_point))
    } else {
      showNotification("Failed to get location", type = "error")
    }
  })
  
  # Render GPS Data Table
  output$gpsTable <- renderDataTable({
    datatable(gps_data(), 
              options = list(dom = 't', pageLength = 10), 
              selection = 'single')
  })
  
  # Display GPS points on the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 0, lat = 0, zoom = 2)
  })
  
  observe({
    leafletProxy("map", data = gps_data()) %>%
      clearMarkers() %>%
      addMarkers(~Longitude, ~Latitude)
  })
  
  # Download GPS Data
  output$downloadGPS <- downloadHandler(
    filename = function() {
      paste0("gps_data.csv")
    },
    content = function(file) {
      write.csv(gps_data(), file, row.names = FALSE)
    }
  )
}
