#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(wordcloud)
library(shinydashboard)

# Define UI for application that draws a histogram
ui <- dashboardPage(skin = "black",
   
   # Application title
   dashboardHeader(title="Next Word Prediction"),
   dashboardSidebar(
     sidebarMenu(
       menuItem("About", tabName = "about"),
       menuItem("Next Word Prediction", tabName = "pred")
     )
   ),
     dashboardBody(
       tabItems(
        tabItem(tabName="pred",
          fluidRow(
            box(status = "success",solidHeader = TRUE,
              title="Word Prediction",
              textAreaInput("Line",label="",value="Hello",height = "200px"),
              actionButton("action1", textOutput("First"),width = "275px"), 
              actionButton("action2", textOutput("Second"),width = "275px"),
              actionButton("action3", textOutput("Third"),width = "275px"),
              width=8,
              height = "400px"),
            box(title="Word Cloud of the 100 predicted Words",
                plotOutput("cloud",width = "80%"),width = 4,collapsible = TRUE)
          )
        ),
        tabItem(tabName="about",
                h3("About"),
                p("The Next Word Prediction application is based on the Katz NLP model for text prediction with Good Turing discount. The model uses unigram, bigram and trigram built from the dataset provided by Coursera."),
                h3("How to use it"),
                tags$li("Type a word or a sentence in the text input area."),
                tags$li("3 words will appear on the clickable button."),
                tags$li("By clicking on the button, the predicted word will automatically be added to the input text."),
                tags$li("The user also have the possibility to check a word cloud based on the 100 predicted words."),
                br(),
                br(),
                img(src='coursera.png', align = "left",height = 50, width = 350),
                img(src='university.png', align = "right",height = 70, width = 320)
                
                )
     )
     )
   
)

source("PredictNextWordKatz.R")

nGramModel<- readRDS("nGramModel.rds")
unigram <- nGramModel[[1]]
bigram <- nGramModel[[2]]
trigram <- nGramModel[[3]]

server <- function(input, output,session) {
  
   ## Predict the 10 most probable next wordq
   Text <- reactive({(input$Line)})
   NextWords <- reactive({KatzBackOff(Text())})
   
   ## Take the 3 most probable words and show them on the action button
   output$First <- renderText({(NextWords()[1,"last_words"])})
   output$Second <- renderText({NextWords()[2,"last_words"]})
   output$Third <- renderText({NextWords()[3,"last_words"]})
   
   ## Create and display wordcloud
   output$cloud <- renderPlot({
     wordcloud(NextWords()$last_words,NextWords()$freq, scale=c(5,1), max.words=100, random.order=FALSE, rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, 'Dark2'))
   },width = 400,height = 400) 
   
   
   ## Trigger to add the predicted word to the sentence
   observeEvent(input$action1,{
     updateTextInput(session,
            inputId = "Line",value=paste(input$Line,NextWords()[1,"last_words"],sep = " "))
   })
   observeEvent(input$action2,{
     updateTextInput(session,
                     inputId = "Line",value=paste(input$Line,NextWords()[2,"last_words"],sep = " "))
   })
   observeEvent(input$action3,{
     updateTextInput(session,
                     inputId = "Line",value=paste(input$Line,NextWords()[3,"last_words"],sep = " "))
   })
   
}

# Run the application 
shinyApp(ui = ui, server = server)

