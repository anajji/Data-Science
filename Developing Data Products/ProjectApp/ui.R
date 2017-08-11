library(shiny)
library(leaflet)
library(leaflet.extras)
library(sp)
# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("House Input Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
    sliderInput("price", label = h5("Price"), min = 0, 
                  max = 2900000, value = c(0,2900000), step = 5000),
    sliderInput("sqft", label = h5("Sqft of the Living Space"), min = 630, 
                  max = 5403, value = c(630,5403)),
    sliderInput("beds", label = h5("Number of Bedrooms"), min = 0, 
                max = 6, value = c(0,6)),
    sliderInput("bath", label = h5("Number of Bathrooms"), min = 0, 
              max = 4.5, value = c(0,4.5), step = 0.25),
    sliderInput("floor", label = h5("Number of floors"), min = 1, 
                max = 3, value = c(0,13.5),step=0.5)

    )
  ,
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Map", br(), 
                    leafletOutput("mymap"),
                    h3("Information of the selected area:"),
                    h4(textOutput("AvgPrice")),
                    h4(textOutput("AvgSqft")),
                    h4(textOutput("AvgBeds")),
                    h4(textOutput("AvgBaths")),
                    h4(textOutput("AvgFloors"))),
                  
                  tabPanel("Documentation", br(),
                           h3("Sliders"),
                           h4("Use the sliders to filter the houses shown on the map."),
                           h3("Map"),
                           h4("Draw on the map using the drawing tool. The application will return the average information of the house selected."))
      
    )
))))
