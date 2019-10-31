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
            tags$h4('Input data - you can copy-paste from Excel or Text files.'),
            rHandsontableOutput('table'),
            tags$h4('Summary table'),
            tableOutput('summaryTable'),
        ),
        mainPanel(
            width = 6,
            tags$h4('Output graph'),
            plotOutput(outputId = 'plot'),
            tags$div(class = 'flexContainer', 
                numericInput('maxYforPlot', value = 10, min = 0, max = 100, label = 'Set maximum Y-axis value'),
                numericInput('yAxisTicks', value = 2, min = 1, max = 100, label = 'Set Y-axis tick interval'),
            ),
            tags$div(class = 'flexContainer', id = 'graphActionButtons',  
                actionButton('setYscale', label = 'Change Y-axis scale'),
                actionButton('setYscaleTicks', label = 'Change Y-axis ticks')
            ),
            tags$div(class = 'flexContainer',
                checkboxInput("individualDataPoints", label = "Plot individual data points", value = FALSE),
                checkboxInput("boxPlot", label = "Boxplot", value = FALSE)
            ),
            
            tags$div(class = 'flexContainer',
                downloadButton(outputId = 'download_png', label = 'download .png'),
                downloadButton(outputId = 'download_pdf', label = 'download .pdf'),
                downloadButton(outputId = 'download_pptx', label = 'download .pptx')
                ),
            tags$div(class = 'individualDataPointsBoxPlotContainer',
            
            )
            
            
            # actionButton('resetYscale', label = 'Reset Y-axis scale'),
            
        )
    )
)
