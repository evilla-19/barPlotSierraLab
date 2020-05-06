#####################################
#######  load libraries   ###########
#####################################

library(shiny)
library(rhandsontable)
library(Rmisc)
# library(shinyMatrix)
library(ggplot2)
library(tidyverse)
library(officer)
library(rvg)
library(plyr)
# options(rgl.useNULL=TRUE)
library(export)


#########################
#######  UI   ###########
#########################



shinyUI(fluidPage(
    includeCSS("styles.css"),
    titlePanel('Generate barplots from input'),
    tags$div(class = 'textboxTitle',
    fluidRow(
        column(width = 6,
        wellPanel(
        tags$div(
            HTML('<h5> Generate plots that you can export and edit as png, pdf or pptx </h5> 
            Features:
            <br>
            <ul>
                <li> Copy-paste from an excel/text file </li>
                <li> Add rows interactively or by right-clicking </li>
                <li> Reorder columns </li>
                <li> Customize tick spacing and Y-axis scale </li>
                <li> Name output file and export as .png, .pdf or .pptx </li>
                <li> Vectorial output for pdf and pptx </li>
            </ul>
            ')
            ),
            tags$div(
               HTML(
                '<small> The project is developed by <a href = mailto:eva.benito@achucarro.org> Eva Benito Garagorri </a> and is freely available <a href="https://github.com/evilla-19/barPlotSierraLab" target = "_black"> here </a> </small>'
                    )
                    )   
        )
    ),
    column(
        width = 6,
        tags$iframe(width="560", height="315", src="https://youtube.com/embed/vFxJRr-jIv8", frameborder="0", allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture", allowfullscreen=NA)
        )  

    )
    


       ),
    sidebarLayout(
        sidebarPanel(
            width = 6,
            wellPanel(
                tags$h4('Input data - you can copy-paste from Excel or Text files.'),
                tags$div(
                    tags$p('Important note: you cannot delete columns. If you do not have several treatment, simply use the same treatment (e.g. T1) for all rows. That will generate a simple barplot')
                )
            ),
            # numericInput('howManyRows', value = 10, min = 1, max = 1000, label = 'How many rows do you need?'),
            rHandsontableOutput('table'),
            tags$h4('Summary table'),
            tableOutput('summaryTable')
        ),
        mainPanel(
            width = 6,
            wellPanel(
                tags$h4('Output graph')
            ),
            wellPanel(
                plotOutput(outputId = 'plot'),

                tags$div(class = 'flexContainer', 
                    numericInput('maxYforPlot', value = 10, min = 0, max = 100, label = 'Set maximum Y-axis value'),
                    numericInput('yAxisTicks', value = 2, min = 1, max = 100, label = 'Set Y-axis tick interval')
                ),

                tags$div(class = 'flexContainer', id = 'graphActionButtons',  
                    actionButton('setYscale', label = 'Change Y-axis scale'),
                    actionButton('setYscaleTicks', label = 'Change Y-axis ticks')
                ),
            
                tags$div(class = 'flexContainer',
                    checkboxInput("individualDataPoints", label = "Plot individual data points", value = FALSE),
                    checkboxInput("boxPlot", label = "Boxplot", value = FALSE)
                )
            ),
            
            wellPanel(    
                textInput(inputId = 'fileName', label = 'Enter your desired filename here'),

                tags$div(class = 'flexContainer',
                    downloadButton(outputId = 'download_png', label = 'download .png'),
                    downloadButton(outputId = 'download_pdf', label = 'download .pdf'),
                    downloadButton(outputId = 'download_pptx', label = 'download .pptx')
                    ),
                tags$div(class = 'individualDataPointsBoxPlotContainer'
                )
            
            ),
            wellPanel(
                actionButton('bootstrap', label = 'Perform bootstrap test'),
                textInput('dataset_x', 'Choose first dataset'),
                textInput('dataset_y', 'Choose second dataset'),
                textOutput('bootstrap_test')
            )
            # actionButton('resetYscale', label = 'Reset Y-axis scale'), 
        )
    )
)
)

