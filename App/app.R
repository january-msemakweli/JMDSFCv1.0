library(shiny)
library(shinyjs)
library(foreign)     # For older SPSS file compatibility
library(readr)
library(readxl)
library(haven)       # For handling SAS, SPSS, and Stata files
library(DT)
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
  
  titlePanel("JMDSFCv1.0: Dataset Format Converter"),
  
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
  ),
  
  hr(),
  
  div("Developed by January G. Msemakweli & Khalid Mzuka", style = "text-align: right; font-size: small;")
)

server <- function(input, output, session) {
  dataset <- reactive({
    req(input$file)
    file_ext <- tools::file_ext(input$file$name)
    
    # Try loading the dataset based on the file extension
    data <- tryCatch({
      switch(file_ext,
             csv = read_csv(input$file$datapath),
             xlsx = read_excel(input$file$datapath),
             xls = read_excel(input$file$datapath),
             sas7bdat = {
               data <- read_sas(input$file$datapath)
               # Convert labelled variables to factors
               as.data.frame(to_factor(data))
             },
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
             dta = {
               data <- read_dta(input$file$datapath)
               # Convert labelled variables to factors
               as.data.frame(to_factor(data))
             },
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
}

shinyApp(ui, server)
