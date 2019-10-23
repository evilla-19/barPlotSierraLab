# barPlotSierraLab

A beta version of a shinyApp to plot data as barplots and have it exported as editable pptx, image or vector format.

![](barplot.png)

#### Current features: 

- allows **copy-paste from excel**
- **plots live** as you change data
- **individual** bar or **grouped bar** design
- **set** the **Y-axis** by default or manually
- choose to plot **individual datapoints**
- allows **pptx** or **png export**. pptx export is vectorial and ungrouppable

#### Known issues (to be fixed):

- pptx export does not work with individual data points
- The non-numerical data can only be modified *after* the numerical data has been modified
- Not possible to add a column 'on the fly' because of preset column types

#### Fixes/To-do's:

[] Fix pptx export 
[] Investigate order of numerica/non-numerical editing options
[] Investigate specifying column types interactively so that adding columns is possible

#### Enhancements:

[] Allow svg/eps export
[] Allow Setting y-axis scale
[] Add other types of plotting options to same data. 
    - Violin plots
    - Whisker plots
    - others?
[] Optimize automatic setting of Y-scale
[] Prettify website (css)