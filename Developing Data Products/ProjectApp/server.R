library(shiny)
library(leaflet)
library(leaflet.extras)
library(sp)
suppressWarnings(library(dplyr))


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  df<-read.csv("kc_house_data.csv")
  df$date<- substr(df$date,1,4)
  df<-df[df$date==2015,]
  df<-df[1:200,]
  house_coordinates <- SpatialPointsDataFrame(df[,c("long","lat")],df)

  
#Filter based on the user input and render the map
output$mymap <- renderLeaflet({
    
    df %>% 
    filter(between(sqft_living,input$sqft[1],input$sqft[2]))%>%
    filter(between(bathrooms,input$bath[1],input$bath[2]))%>%
    filter(between(bedrooms,input$beds[1],input$beds[2]))%>%
    filter(between(price,input$price[1],input$price[2]))%>%
    filter(between(floors,input$floor[1],input$floor[2]))%>%
    leaflet() %>% 
    addTiles() %>% 
    addMarkers(~long, ~lat,popup=~paste(paste("Price:", price,"$"),
                                        paste("Sqft of the Living Space:", sqft_living),
                                        paste("Number of floors:", floors),
                                        paste("Number of bedrooms:", bedrooms),
                                        paste("Number of bathrooms:", bathrooms),
                                        sep = "<br />")) %>%
    addDrawToolbar(
          targetGroup='draw',
          polylineOptions=FALSE,
          markerOptions = FALSE,
          circleOptions = TRUE,
          singleFeature = TRUE)  %>%
    addLayersControl(overlayGroups = c('draw'), options =
                           layersControlOptions(collapsed=FALSE)) 
  })

 house <- reactive({
   #use the draw_stop event to detect when users finished drawing
   req(input$mymap_draw_stop)
   feature_type <- input$mymap_draw_new_feature$properties$feature_type
   if(feature_type %in% c("rectangle","polygon")) {
     
     #get the coordinates of the polygon
     polygon_coordinates <- input$mymap_draw_new_feature$geometry$coordinates[[1]]
     
     #transform them to an sp Polygon
     drawn_polygon <- Polygon(do.call(rbind,lapply(polygon_coordinates,function(x){c(x[[1]][1],x[[2]][1])})))
     
     #use over from the sp package to identify selected cities
     selected_house <- house_coordinates %over% SpatialPolygons(list(Polygons(list(drawn_polygon),"drawn_polygon")))
     
     selected_house<-df[which(!is.na(selected_house)),]
     selected_house
     
   } else if(feature_type=="circle") {
     #get the coordinates of the center of the cirle
     center_coords <- matrix(c(input$mymap_draw_new_feature$geometry$coordinates[[1]],input$mymap_draw_new_feature$geometry$coordinates[[2]]),ncol=2)
     
     #calculate the distance of the cities to the center
     dist_to_center <- spDistsN1(house_coordinates,center_coords,longlat=TRUE)
     
     #select the cities that are closer to the center than the radius of the circle
     selected_house <- house_coordinates[dist_to_center < input$mymap_draw_new_feature$properties$radius/1000,]
     selected_house
     }
 })

 output$AvgSqft<-renderText({
   if(nrow(house())==0){"Average Sqft of the Selected Houses: No House Selected"}
   else {paste("Average Sqft of the Selected Houses: ",round(mean((house()$sqft_living)),1), "sqft")}
 })
 output$AvgPrice<-renderText({
   if(nrow(house())==0){"Average Price of the Selected Houses: No House Selected"}
   else {paste("Average Price of the Selected Houses: ",round(mean((house()$price)),1),"$")}
 })
 output$AvgBeds<-renderText({
   if(nrow(house())==0){"Average Number of Bedrooms of the Selected Houses: No House Selected"}
   else {paste("Average Number of Bedrooms of the Selected Houses: ",round(mean((house()$bedrooms))))}
 })
 output$AvgBaths<-renderText({
   if(nrow(house())==0){"Average Number of Bathrooms of the Selected Houses:No House Selected"}
   else {paste("Average Number of Bathrooms of the Selected Houses: ",0.5*round(mean((house()$bathrooms)/0.5)))}
 })
 output$AvgFloors<-renderText({
   if(nrow(house())==0){"Average Number of Floors of the Selected Houses: No House Selected"}
   else {paste("Average Number of Floors of the Selected Houses: ",0.5*round(mean((house()$floors)/0.5)))}
 })
 
   
})