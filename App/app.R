library(shiny)
library(shinyjs)
library(foreign)
library(readr)
library(readxl)
library(haven)
library(DT)
library(progress)
library(labelled)
library(openxlsx)

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
    
    switch(file_ext,
           csv = read_csv(input$file$datapath),
           xlsx = read_excel(input$file$datapath),
           xls = read_excel(input$file$datapath),
           sas7bdat = read_sas(input$file$datapath),
           sav = {
             data <- read_sav(input$file$datapath)
             # Replace coded variables with their labels
             data <- as.data.frame(to_factor(data))
             data
           },
           dta = read_dta(input$file$datapath),
           rdata = {load(input$file$datapath); get(ls()[1])},
           RDATA = {load(input$file$datapath); get(ls()[1])},
           stop("Unsupported file format"))
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
      
      switch(input$format,
             csv = write_csv(data, file),
             xlsx = write.xlsx(data, file),  # Use openxlsx for .xlsx
             sas7bdat = write_sas(data, file),
             sav = write_sav(data, file),
             dta = write_dta(data, file),
             rdata = save(data, file = file),
             stop("Unsupported file format"))
    }
  )
}

shinyApp(ui, server)
