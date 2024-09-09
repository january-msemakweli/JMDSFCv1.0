library(shiny)
library(shinyjs)
library(leaflet)
library(DT)
library(foreign)     # For older SPSS file compatibility
library(readr)
library(readxl)
library(haven)       # For handling SAS, SPSS, and Stata files
library(progress)
library(labelled)    # For converting labelled variables to factors
library(openxlsx)
library(rio)         # For flexible format conversion

# Function to shorten variable names to a 32-character limit (used for Stata and SAS)
shorten_var_names <- function(data) {
  colnames(data) <- make.names(substr(colnames(data), 1, 32), unique = TRUE)
  data
}

ui <- fluidPage(
  useShinyjs(),
  
  titlePanel("JMDSFCv1.0: Dataset Format Converter - GPS Data Generation"),
  
  tabsetPanel(
    tabPanel("Dataset Format Converter",
             sidebarLayout(
               sidebarPanel(
                 fileInput("file", "Choose a Dataset File", 
                           accept = c(".csv", ".xlsx", ".xls", ".sas7bdat", ".sav", ".dta", ".rdata", ".RDATA")),
                 selectInput("format", "Select Output Format",
                             choices = list("CSV" = "csv", "Excel" = "xlsx", "SAS" = "sas7bdat", "SPSS" = "sav", "Stata" = "dta", "RData" = "rdata")),
                 actionButton("convert", "Convert Dataset"),
                 hidden(downloadButton("downloadData", "Download Converted Dataset")),
                 textOutput("progress")
               ),
               
               mainPanel(
                 h4("Preview of Uploaded Data"),
                 dataTableOutput("dataTable")
               )
             )
    ),
    
    tabPanel("GPS Data Generation",
             sidebarLayout(
               sidebarPanel(
                 h4("Generated GPS Data"),
                 actionButton("getLocation", "Add My Location"),
                 actionButton("deleteRow", "Delete Selected Row"),
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
  # Dataset Conversion ----
  dataset <- reactive({
    req(input$file)
    file_ext <- tools::file_ext(input$file$name)
    
    # Try loading the dataset based on the file extension
    data <- tryCatch({
      switch(file_ext,
             csv = read_csv(input$file$datapath),
             xlsx = read_excel(input$file$datapath),
             xls = read_excel(input$file$datapath),
             sas7bdat = read_sas(input$file$datapath),
             sav = {
               data <- tryCatch({
                 # First attempt using haven
                 data <- read_sav(input$file$datapath)
                 data
               }, error = function(e) {
                 # Fallback to foreign::read.spss() for older SPSS versions
                 data <- foreign::read.spss(input$file$datapath, to.data.frame = TRUE)
                 data
               })
               # Convert labelled variables to factors
               as.data.frame(to_factor(data))
             },
             dta = read_dta(input$file$datapath),
             rdata = {load(input$file$datapath); get(ls()[1])},
             RDATA = {load(input$file$datapath); get(ls()[1])},
             stop("Unsupported file format"))
    }, error = function(e) {
      stop("Error loading file: ", e$message)
    })
    
    data
  })
  
  output$dataTable <- renderDataTable({
    dataset()
  })
  
  output$progress <- renderText({
    "Conversion not started"
  })
  
  observeEvent(input$convert, {
    shinyjs::disable("convert")
    progress <- Progress$new(session, min = 0, max = 100)
    progress$set(message = "Converting...", value = 0)
    
    for (i in 1:10) {
      Sys.sleep(0.1)
      progress$inc(10)
      output$progress <- renderText({paste("Conversion", i * 10, "% complete")})
    }
    
    progress$close()
    shinyjs::enable("convert")
    
    # Show the download button after conversion is complete
    shinyjs::show("downloadData")
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("converted_dataset.", input$format)
    },
    content = function(file) {
      data <- dataset()
      
      # Shorten variable names if converting to Stata or SAS
      if (input$format %in% c("dta", "sas7bdat")) {
        data <- shorten_var_names(data)
      }
      
      # Attempt conversion with rio package
      conversion_success <- tryCatch({
        rio::export(data, file = file, format = input$format)
        TRUE
      }, error = function(e) {
        FALSE
      })
      
      # If rio fails, fall back to manual methods
      if (!conversion_success) {
        switch(input$format,
               csv = write_csv(data, file),
               xlsx = write.xlsx(data, file),  # Use openxlsx for .xlsx
               sas7bdat = write_sas(data, file),
               sav = write_sav(data, file),
               dta = write_dta(data, file),
               rdata = save(data, file = file),
               stop("Unsupported file format"))
      }
    }
  )
  
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
  
  # Delete selected GPS row
  observeEvent(input$deleteRow, {
    selected <- input$gpsTable_rows_selected
    if (length(selected) > 0) {
      gps_data(gps_data()[-selected, ])
    } else {
      showNotification("No row selected for deletion", type = "error")
    }
  })
}

shinyApp(ui, server)
