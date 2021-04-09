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
options(shiny.trace = TRUE)
options(shiny.sanitize.errors = TRUE)
# Define UI for application that draws a histogram
ui <- fluidPage(
    theme = shinythemes::shinytheme("darkly"),
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
                        hr(style="border-top: 1px solid #bbb;"),
                        textInput(inputId = "countSpecifiedWord",
                                  label = "Word to Search for"),
                        h4(textOutput(outputId = "countwordz")
                           ),
                        tableOutput(outputId = "countwords"),
                        hr(style="border-top: 1px solid #bbb;"),
                        h4("message breakdown"),
                        tableOutput(outputId="countmsgz"),
                        hr(style="border-top: 1px solid #bbb;"),
                        h4("word breakdown"),
                        tableOutput(outputId = "countwordx"),
                        hr(style="border-top: 1px solid #bbb;"),
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
        req(input$fileinput)
        a<-input$fileinput$datapath[1]
        print(paste(strsplit(a, "/")[[1]][1:length(strsplit(a, "/")[[1]])-1], "/", collapse="", sep=""))
        res <- message_ops$loadMsgs(paste(strsplit(a, "/")[[1]][1:length(strsplit(a, "/")[[1]])-1], "/", collapse="", sep=""))
        rv$message <- res[1]
        rv$count <- res[2]
        rv$names <- res[3]
        print(res)
        return(rv)
    })

    output$countmsgz <- renderTable({
        data()$count
        z <- message_ops$WCKowalski(data()$message[[1]], message_ops$countMsgs, NULL, FALSE)
        matrix(unlist(z), nrow=1, ncol=length(z)) -> a
        print(a)
        colnames(a) <- names(z)
        return(data.frame(a))
    })

    output$countwordx <- renderTable({
        z <- message_ops$WCKowalski(data()$message[[1]], message_ops$countWords, NULL, FALSE)
        matrix(unlist(z), nrow=1, ncol=length(z)) -> a
        print(a)
        print(z)
        colnames(a) <- names(z)
        return(data.frame(a))
    })

    output$countwordz <- renderText({
        return(paste("Searching for:", input$countSpecifiedWord))
    })

    output$countwords <- renderTable({
        print(input$countSpecifiedWord)
        z <- message_ops$WCKowalski(data()$message[[1]], message_ops$countSpecificWord, input$countSpecifiedWord, FALSE)
        matrix(unlist(z), nrow=1, ncol=length(z)) -> a
        colnames(a) <- names(z)
        return(data.frame(a))
    })

    output$table <- renderDataTable({
        # generate bins based on input$bins from ui.R
        data()$message[[1]][[1]]->b

        name <- list()
        timestamp <- list()
        content <- list()

        for (i in 1:length(b)){
            name <- append(name, b[[i]]$sender_name)
            timestamp <- append(timestamp, b[[i]]$timestamp_ms)
            content <- append(content, b[[i]]$content)
        }
        c <- list("name"=name,"timestamp"=timestamp, "content"=content)
        matrix(unlist(c), nrow=length(c$timestamp), ncol=length(c)) -> a
        colnames(a) <- names(c)
        df <- data.frame(a)
        return(df)
    })
}

# Run the application
shinyApp(ui = ui, server = server)
