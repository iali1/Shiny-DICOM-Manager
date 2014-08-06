library(shiny)
library(ggvis)
library(dplyr)


VariableList =  names(Data)

shinyUI(

    # Use a fluid Bootstrap layout
    fluidPage(


        # Give the page a title
        titlePanel("DICOM Management"),

        # Generate a row with a sidebar
        sidebarLayout(

            # Define the sidebar with one input
            sidebarPanel(

                tabsetPanel('sidebar',

                    tabPanel("Variables",

                        selectInput("xaxis", strong("X-axis:"),
                        choices=(VariableList)),
                        selectInput("yaxis", strong("Y-axis:"),
                        choices=(VariableList)),
                        selectInput("dng", strong("Color:"),
                        choices=(VariableList)),
                        selectInput("shp", strong("Shape:"), 
                                    choices=c(VariableList)),

                        hr(),


                        tabsetPanel('filters',


                                tabPanel('source',

                                fluidRow(

                                column(4,
                                    checkboxGroupInput("institution", label = h6("Institution: "),
                                    levels(Data$InstitutionName))),
                                column(4,
                                    checkboxGroupInput("manufacturer", label = h6("Manufacturer: "),
                                    levels(Data$Manufacturer))))),


                                tabPanel('patient',

                                    helpText(strong("Patient Id:"),
                                    tags$textarea(id = "patientID", rows=2, cols =40),

                                    sliderInput("patientAge", h6("Patient Age(yrs):"),
                                    0, 150, value = c(50,100)),
                                    checkboxGroupInput("sex", label = h6("Sex: "),
                                    choices = list("M", "F")),
                                    sliderInput("seriesDate", h6("Study/Series Date: "),
                                    0, 150, value = c(50,100)))),

                                tabPanel('scan',

                                    fluidRow(

                                        column(3,
                                            checkboxGroupInput("modality", label = h6("Modality: "),
                                            levels(Data$Modality)),
                                            checkboxGroupInput("contrast", label = h6("Image Contrast: "),
                                            choices = list("T1" , "T2" ))),
                                        column(2,
                                            checkboxGroupInput("scanType", label = h6("Scan Type: "),
                                            choices = list("MPRAGE" ,"DWI" ,
                                            "SPGR" , "BRAVO")),
                                            checkboxGroupInput("dimensionality","",
                                            choices = list("3D"))))),

                                tabPanel('Other',

                                helpText(strong("Accession Number: ")),
                                tags$textarea(id = "an", rows=2, cols =40))

                                )),

                                tabPanel("Data Upload & Download",
                                fileInput('file1', 'Choose CSV File:',
                                accept = c('text/csv',
                                            'text/comma-separated-values,text/plain',
                                            '.csv')),
                                            downloadButton('downloadData', 'Download Filtered Data: '))

                )),

            # Create a spot for the barplot
            mainPanel(

            htmlOutput("summary"),
            ggvisOutput("graph"),
            hr("Data Table"),
            dataTableOutput("table")


            )

)))
