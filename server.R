

library(shiny)
library(ggvis)

Data = read.csv("data/SampleData.csv")

VariableList =  names(Data)

# Define a server for the Shiny app
shinyServer(function(input, output) {
    
    
    #Filters
    DataTable = reactive({
    
    		if(!is.null(input$file1)){
        Data <- read.csv(input$file1$datapath, header = TRUE)
  			}
        
        MinAge = input$patientAge[1]
        MaxAge = input$patientAge[2]
        
        
        #Applying Filters
        
        FData = Data %>%
        filter(
       		PatientAge>MinAge,
       		PatientAge<MaxAge)
        
        # Filter by insitution
        if (!is.null(input$institution)) {
            institution = paste0( input$institution)
            FData = FData %>% filter(InstitutionName == institution)
        }
        #filter by manufacturer
        if (!is.null(input$manufacturer)) {
            manufacturer = paste0( input$manufacturer)
            FData = FData %>% filter(Manufacturer == manufacturer)
        }
        #filter by Modality
        if (!is.null(input$modality)) {
            modality = paste0( tolower(input$modality))
            FData = FData %>% filter(grepl(modality, tolower(Modality)))
        }
        
        #filter by gender
        if (!is.null(input$sex)) {
            sex = paste0( input$sex)
            FData = FData %>% filter(PatientSex == sex)
        }
        
        #filter by Scan Type
        if (!is.null(input$scanType)) {
            scanType = paste0(tolower(input$scanType))
            FData = FData %>% filter(grepl(scanType, tolower(SeriesDescription)))
        }
        
        #filter by Contrast
        if (!is.null(input$contrast)) {
            contrast = paste0( tolower(input$contrast))
            FData = FData %>% filter(grepl(contrast, tolower(SeriesDescription)))
        }
       
       #filter by 3D
       if (!is.null(input$dimensionality)) {
           dimensionality = paste0( tolower(input$dimensionality))
           FData = FData %>% filter(grepl(dimensionality, tolower(SeriesDescription)))
       }
       
        #filter by patient id
        if (!is.null(input$patientID) && input$patientID !="") {
            patientID = unlist(strsplit(paste0(input$patientID), "[ ,'\n ]"))
            FData = FData %>% filter(paste0(id) %in% patientID)
        }
        
        #filter by AccessionNumber
        if (!is.null(input$AN) && input$AN !="") {
            AN = unlist(strsplit(paste0(input$AN), "[ ,'\n ]"))
            FData = FData %>% filter(paste0(AccessionNumber) %in% AN)
        }
        
        
        FData = as.data.frame(FData)
        
    })
    
    	#Function for generation tooltip text
    		Image_tooltip <- function(x) {
      			if(is.null(x)) return(Null)
        		if(is.null(x$AccessionNumber)) return(Null)
        
		        #Pick out the image with this ID
		        Data <- isolate(DataTable())
		        image <- Data[Data$AccessionNumber==x$AccessionNumber,]
        
        paste0("<b>","AN: ", image$AccessionNumber, "</b><br>",
		        "Patient Id: ",image$PatientID,"<br>",
		        "Inst: ",image$InstitutionName,"<br>",
		        "Series Descp:", image$SeriesDescription, "<br>", "<br>")
  		 }
    
    
    
    
    # Fill in the spot we created for a plot
    vis = reactive({
        
        xvar = prop("x", as.symbol(input$xaxis))
        yvar = prop("y", as.symbol(input$yaxis))
        
        DataTable %>%
        ggvis(xvar, yvar) %>%
        
        layer_points(fill = as.symbol(input$dng),
        opacity := 0.4,
        size = ~DataTable()$NumberOfDicoms,
        shape = as.symbol(input$shp),
        key:=~AccessionNumber ) %>%
        
        add_legend("fill",
        properties = legend_props(
        legend = list( y = 100))) %>%
        add_legend("size", title = "Number of DICOMS") %>%
        
        add_tooltip(Image_tooltip, "hover")
        
    })
    
    vis %>% bind_shiny('graph')
    
    output$table <- renderDataTable(DataTable()[,
                                                c(
                                                'id',
                                                'AccessionNumber',
                                                'InstitutionName',
                                                'PatientAge',
                                                'SeriesDescription')],
                                    options = list(aLengthMenu = list(c(10, 25, 50, 100, -1),
                                                                      c('10', '25','50', '100', 'All')),
                                                                      iDisplayLength = 10))
    
    
     output$summary <- renderText({
        
       paste0(strong("Number of Series Selected: "), nrow(DataTable()))
        
    })
    
    
    output$downloadData <- downloadHandler(
     filename = function(){
         paste(DataTable(), '.csv', sep='')
     },
     content = function(file) {
         write.csv(DataTable(), file)
     })

    
    
    
    
})
