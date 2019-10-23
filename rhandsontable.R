#####################################
#######  load libraries   ###########
#####################################

library(shiny)
library(rhandsontable)
library(Rmisc)
library(shinyMatrix)
library(ggplot2)
library(tidyverse)
library(officer)
library(rvg)
library(plyr)
library(export)


#########################
#######  UI   ###########
#########################


ui = fluidPage(
    includeCSS("styles.css"),
    titlePanel('Generate barplots from input'),
    sidebarLayout(
        sidebarPanel(
            width = 6,
            rHandsontableOutput('table')
        ),
        mainPanel(
            width = 6,
            tableOutput('summaryTable'),
            numericInput('maxYforPlot', value = 10, min = 0, max = 100, label = 'Set maximum Y-axis value'),
            checkboxInput("checkbox", label = "Plot individual data points", value = FALSE),
            actionButton('setYscale', label = 'Change Y-axis scale'),
            actionButton('resetYscale', label = 'Reset Y-axis scale'),
            plotOutput(outputId = 'plot'),
            downloadButton(outputId = 'download_png', label = 'download .png'),
            downloadButton(outputId = 'download_pptx', label = 'download .pptx')
        )
    )
)




#######################################
#######  helper functions   ###########
#######################################


plotData = function(data, maxY){
        ## basic plot
        myplot = ggplot(data, aes(x = Group, y = Average, fill = Treatment)) + 
        geom_bar(width = 0.4, position = position_dodge(width = 0.5), stat = 'identity', color = 'black', size = 0.25, alpha = 0.5) + ## space between bars, black outline
        geom_errorbar(aes(ymin = Average , ymax = Average + se), width = 0.1, position = position_dodge(width = 0.5), size = 0.25) ## errorbars going up only

        ## remove grid, legend and control axes thickness
        myplot = myplot + 
        scale_y_continuous(expand = c(0, 0), limits = c(0,maxY)) +
        theme(
            axis.text.x = element_text(face = 'bold', colour = 'black', size = 10),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank(), ## remove grid
            panel.background = element_blank(), ## remove background
            # legend.position = 'none', ## remove legend
            axis.line = element_line(colour = "black", size = 0.25),
            axis.title.x = element_blank()
            ) ## control color and thickness of axes

        return(myplot) 

    }


#######################################
#######  Server  ######################
#######################################

server = function(output,input){
  
  group = sample(rep('A', 20))
  measurement = sample(rep(0, 20))
  treatment = rep('T', 20)
  df = data.frame(Group = group, Measurement = measurement, Treatment = treatment)
  
  datavalues = reactiveValues(data = df)


  
  output$table = renderRHandsontable({
    rhandsontable(datavalues$data) %>%
        hot_context_menu(allowRowEdit = TRUE, allowColEdit = TRUE) %>%
        hot_table(highlightCol = TRUE, highlightRow = TRUE)

  })
  
  
    observeEvent(
    input$table$changes$changes, # observe if any changes to the cells of the rhandontable
    {
        datavalues$data = hot_to_r(input$table) # convert the rhandontable to R data frame object so manupilation / calculations could be d
        datavalues$data$Group = as.character(datavalues$data$Group)
        datavalues$data$Treatment = as.character(datavalues$data$Treatment)
        }
    )
    
    

    data_summ = reactive({
        data_summ = summarySE(datavalues$data, measurevar = 'Measurement', groupvars = c('Group', 'Treatment'))
        colnames(data_summ)[4] = 'Average'
        # print(data_summ$Average)
        return(data_summ)
    })

    

    ymax = reactive({
        means = data_summ()$Average
        ymax = max(means)
        ymax = ymax + 2
        return(ymax)
    })



    output$summaryTable = renderTable({
        data_summ()
    })
    

    output$plot = renderPlot({

        if(input$checkbox == FALSE){
            myplot = plotData(data_summ(), ymax())
        }
        else{
            myplot = plotData(data_summ(), ymax())
            myplot = myplot + geom_jitter(aes(x = Group, y = Measurement, col = Treatment), data = datavalues$data,  position = position_jitterdodge(jitter.width = 0.05, dodge.width = 0.5)) 
        }
        
        myplot
    })


    observeEvent(input$setYscale, {
            ymax = input$maxYforPlot
            output$plot = renderPlot({
                if(input$checkbox == FALSE){
                    myplot = plotData(data_summ(), ymax)
                    }
                else{
                    myplot = plotData(data_summ(), ymax)
                    myplot = myplot + geom_jitter(aes(x = Group, y = Measurement, col = Treatment), data = datavalues$data,  position = position_jitterdodge(jitter.width = 0.05, dodge.width = 0.5)) 
        }
        
        myplot
        })
        }        
        )

    observeEvent(input$resetYscale, {
                ymax = ymax()
                output$plot = renderPlot({
                    if(input$checkbox == FALSE){
                        myplot = plotData(data_summ(), ymax)
                        }
                    else{
                        myplot = plotData(data_summ(), ymax)
                        myplot = myplot + geom_jitter(aes(x = Group, y = Measurement, col = Treatment), data = datavalues$data,  position = position_jitterdodge(jitter.width = 0.05, dodge.width = 0.5, size = 0.2)) 
        }
        
        myplot
            })
            }        
            )


    output$download_png = downloadHandler(
        filename ='test.png',
        content = function(file){
            ggsave(file, width = 6, height = 3, dpi = 300)
        }
        )


    output$download_pptx = downloadHandler(
        filename ='test.pptx', 
        content = function(file){
            myplot = plotData(data_summ(), input$maxYforPlot)
            myplot
            ###########
            

            ###########

            graph2ppt(x = myplot, file = file , width = 3.0, height = 1.5, paper = 'A4', orient = 'portrait', center = FALSE, offx = 1, offy = 1)
        }
        )

}


shinyApp(ui = ui, server = server)