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
    tags$div(class = 'textboxTitle',
        tags$h4('With this tool you can generate plots that you can export and edit as pdf or pptx. You can also export them as uneditable png. The tool generates a random dataset every time so that you can visualize the aspect of the final plot. 
        You can also copy-paste your dataset from excel.
        Note that you can also add rows if you have more datapoints'),
        tags$div(
            HTML(
                'The project is developed by <a href = mailto:eva.benito@achucarro.org> Eva Benito Garagorri </a> and is freely available <a href="https://github.com/evilla-19/barPlotSierraLab" target = "_black"> here </a>'
            )
        )
    ),
    sidebarLayout(
        sidebarPanel(
            width = 6,
            rHandsontableOutput('table')
        ),
        mainPanel(
            width = 6,
            tableOutput('summaryTable'),
            numericInput('maxYforPlot', value = 10, min = 0, max = 100, label = 'Set maximum Y-axis value'),
            numericInput('yAxisTicks', value = 2, min = 1, max = 100, label = 'Set Y-axis tick interval'),
            checkboxInput("individualDataPoints", label = "Plot individual data points", value = FALSE),
            checkboxInput("boxPlot", label = "Boxplot", value = FALSE),
            actionButton('setYscale', label = 'Change Y-axis scale'),
            actionButton('setYscaleTicks', label = 'Change Y-axis ticks'),
            # actionButton('resetYscale', label = 'Reset Y-axis scale'),
            plotOutput(outputId = 'plot'),
            tags$div(class = 'buttonsContainer',
                downloadButton(outputId = 'download_png', label = 'download .png'),
                downloadButton(outputId = 'download_pdf', label = 'download .pdf'),
                downloadButton(outputId = 'download_pptx', label = 'download .pptx')
                )
        )
    )
)




#######################################
#######  helper functions   ###########
#######################################


plotData_barplot = function(data, maxY, yAxisTicks = 2){
        ## basic plot
        myplot = ggplot(data, aes(x = Group, y = Average, fill = Treatment)) + 
        geom_bar(width = 0.4, position = position_dodge(width = 0.5), stat = 'identity', color = 'black', size = 0.25, alpha = 0.5) + ## space between bars, black outline
        geom_errorbar(aes(ymin = Average , ymax = Average + se), width = 0.1, position = position_dodge(width = 0.5), size = 0.25) ## errorbars going up only

        ## remove grid, legend and control axes thickness
        myplot = myplot + 
        scale_y_continuous(expand = c(0, 0), limits = c(0,maxY), breaks = seq(0, maxY, yAxisTicks)) +
        theme(
            axis.text.x = element_text(face = 'bold', colour = 'black', size = 10),
            axis.text.y = element_text(colour = 'black', size = 8),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank(), ## remove grid
            panel.background = element_blank(), ## remove background
            # legend.position = 'none', ## remove legend
            axis.line = element_line(colour = "black", size = 0.25),
            axis.title.x = element_blank()
            ) ## control color and thickness of axes

        return(myplot) 

    }

plotData_boxplot = function(data, maxY, yAxisTicks = 2){
        ## basic plot
        myplot = ggplot(data, aes(x = Group, y = Measurement, fill = Treatment)) + 
        # stat_boxplot(geom = 'errorbar', linetype = 1, width = 0.5, aes(col = Treatment)) +
        geom_boxplot(alpha = 0.5, outlier.shape = 1, width = 0.5, position = position_dodge(width = 0.5)) + 
        geom_jitter(aes(col = Treatment), position=position_jitterdodge(jitter.width = 0.01, dodge.width = 0.5), size = 0.5)
        ## remove grid, legend and control axes thickness
        myplot = myplot + 
        scale_y_continuous(expand = c(0, 0), limits = c(0, maxY), breaks = seq(0, maxY, yAxisTicks)) +
        theme(
            axis.text.x = element_text(face = 'bold', colour = 'black', size = 10),
            axis.text.y = element_text(colour = 'black', size = 8),
            panel.grid.major = element_blank(), panel.grid.minor = element_blank(), ## remove grid
            panel.background = element_blank(), ## remove background
            # legend.position = 'none', ## remove legend
            legend.background = element_blank(),
            axis.line = element_line(colour = "black", size = 0.25),
            axis.title.x = element_blank()
            ) ## control color and thickness of axes

        return(myplot) 

    }    



#######################################
#######  Server  ######################
#######################################

server = function(output,input){
  ########################################
  ######## initialize data table #########
  ########################################
  group = sample(c('A', 'B'), 20, replace = TRUE)
  measurement = sample(20)
  treatment = sample(c('T', 'noT'), 20, replace = TRUE)
  df = data.frame(Group = group, Measurement = measurement, Treatment = treatment)
  
  datavalues = reactiveValues(data = df)

  ########################################
  ######## convert to RhandsOnTable ######
  ########################################
  
  
  output$table = renderRHandsontable({
    rhandsontable(datavalues$data) %>%
        hot_context_menu(allowRowEdit = TRUE, allowColEdit = TRUE) %>%
        hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
        hot_cols(columnSorting = TRUE)

  })
  
  ###############################################
  ######## observe changes in data table ########
  ###############################################
  
    observeEvent(
    input$table$changes$changes, # observe if any changes to the cells of the rhandontable
    {
        datavalues$data = hot_to_r(input$table) # convert the rhandontable to R data frame object 
        datavalues$data$Group = as.character(datavalues$data$Group)
        datavalues$data$Treatment = as.character(datavalues$data$Treatment)
        }
    )
    
    ###############################################
    ######## generate summary table ########
    ###############################################
    

    data_summ = reactive({
        data_summ = summarySE(datavalues$data, measurevar = 'Measurement', groupvars = c('Group', 'Treatment'))
        colnames(data_summ)[4] = 'Average'
        # print(data_summ$Average)
        return(data_summ)
    })

    ###############################################
    ######## output summary table ########
    ###############################################

    output$summaryTable = renderTable({
            data_summ()
        })
    
    ###############################################
    ######## calculate ymax reactively ########
    ###############################################
    
    ymax = reactive({
        if(input$setYscale){
            ymax = input$maxYforPlot
        }
        # else if(input$resetYscale){
        #     means = data_summ()$Average
        #     ymax = max(means)
        #     ymax = ymax + 3
        # }
        else {
            means = data_summ()$Average
            ymax = max(means)
            ymax = ymax + 3
        }        
        return(ymax)
    })


    ###############################################
    ######## calculate tick breaks reactively ########
    ###############################################

    yAxisTicks = reactive({
        if(input$setYscaleTicks){
            yAxisTicks = input$yAxisTicks
        }
        # else if(input$resetYscale){
        #     means = data_summ()$Average
        #     ymax = max(means)
        #     ymax = ymax + 3
        # }
        else {
            yAxisTicks = 2
        }        
        return(yAxisTicks)
    })

    ############################################################################################
    ######## plot reactively based on user selection of individual data points or not ########
    ############################################################################################


    myplot = reactive({
        if( (input$individualDataPoints == FALSE) & (input$boxPlot == FALSE) ){
            myplot = plotData_barplot(data_summ(), ymax(), yAxisTicks = yAxisTicks())
        }
        else if ( (input$individualDataPoints == TRUE) & (input$boxPlot == FALSE) ){
            myplot = plotData_barplot(data_summ(), ymax(), yAxisTicks = yAxisTicks())
            myplot = myplot + geom_jitter(aes(x = Group, y = Measurement, col = Treatment), size = 0.5, data = datavalues$data,  position = position_jitterdodge(jitter.width = 0.05, dodge.width = 0.5)) 
            
        }
        else if ( (input$individualDataPoints) == FALSE & (input$boxPlot == TRUE) ){
            myplot = plotData_boxplot(datavalues$data, ymax(), yAxisTicks = yAxisTicks())
        }
        
        myplot
    })

    isolate(print(datavalues$data))

    output$plot = renderPlot({

        myplot()
    })


    

    # observeEvent(input$setYscale, {
    #         ymax = input$maxYforPlot
    #         output$plot = renderPlot({
    #             myplot()
    #     })
    #     }        
    #     )

    
    
    # observeEvent(input$resetYscale, {
    #             ymax = ymax()
    #             output$plot = renderPlot({
    #                 myplot()
    #         })
    #         }        
    #         )

    ################################
    ######## png downloader ########
    ################################

    output$download_png = downloadHandler(
        filename ='test.png',
        content = function(file){
            ggsave(file, width = 6, height = 3, dpi = 300)
        }
        )
    
    ################################
    ######## eps downloader ########
    ################################

    output$download_pdf = downloadHandler(
        filename ='test.pdf',
        content = function(file){
            ggsave(file, width = 6, height = 3, dpi = 300, device = 'pdf')
        }
        )
    

    ################################
    ######## pptx downloader ########
    ################################

    output$download_pptx = downloadHandler(
        filename ='test.pptx', 
        content = function(file){
            graph2ppt(x = myplot(), file = file , width = 3.0, height = 1.5, paper = 'A4', orient = 'portrait', center = FALSE, offx = 1, offy = 1)
        }
        )

}


shinyApp(ui = ui, server = server)