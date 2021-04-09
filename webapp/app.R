#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(reticulate)

message_ops <- import("message_ops")

# Define UI for application that draws a histogram
ui <- fluidPage(
    fluidRow(
        column(1,
        ),
        column(10,
               height="100vh",
               titlePanel("Facebook Message Analysis"),
                    div(
                        class="well",
                        height="100vh",
                        width = "100%",
                        fileInput(inputId = "fileinput",
                                  accept="json",
                                  label = "file input"),
                        textInput(inputId = "countSpecifiedWord",
                                  label = "Word to Search for"),
                        textOutput(outputId = "countmsg"),
                        textOutput(outputId = "countwordz"),
                        dataTableOutput(outputId = "countwords"),
                        dataTableOutput(outputId="table"),
                    )
        ),
        column(1,
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

    rv <- reactiveValues()

    data <- reactive({
        a<-input$fileinput$datapath[1]
        print(paste(strsplit(a, "/")[[1]][1:length(strsplit(a, "/")[[1]])-1], "/", collapse="", sep=""))
        res <- message_ops$loadMsgs(paste(strsplit(a, "/")[[1]][1:length(strsplit(a, "/")[[1]])-1], "/", collapse="", sep=""))
        rv$message <- res[1]
        rv$count <- res[2]
        rv$names <- res[3]
        print(res)
        return(rv)
    })

    output$countmsg <- renderText({
        data()$count
    })

    output$countwordz <- renderText({
        return(input$countSpecifiedWord)
    })

    output$countwords <- renderDataTable({
        print(input$countSpecifiedWord)
        z <- message_ops$WCKowalski(data()$message[[1]], message_ops$countSpecificWord, input$countSpecifiedWord, FALSE)
        matrix(unlist(z), nrow=1, ncol=2) -> a
        colnames(a) <- names(z)
        return(data.frame(a))
    })

    output$table <- renderDataTable({
        # generate bins based on input$bins from ui.R
        data()$message[[1]][[1]]->b
        matrix(unlist(b), nrow=length(b), byrow=TRUE) -> a
        colnames(a) <- names(b[[1]])
        df <- data.frame(a)
        return(df)
    })
}

# Run the application
shinyApp(ui = ui, server = server)
