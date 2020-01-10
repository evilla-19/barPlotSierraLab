

# init.R
#
# Example R code to install packages if not already installed
#

my_packages = c('shiny','rhandsontable','Rmisc','shinyMatrix','ggplot2','tidyverse','officer','rvg','plyr','export')

###########################################################

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p, dependencies = TRUE)
  }
  else {
    cat(paste("Skipping already installed package:", p, "\n"))
  }
}
invisible(sapply(my_packages, install_if_missing))

# install.packages("/app/packages/rgl_0.100.30.tar.gz", repos=NULL, type="source")
# install.packages("/app/packages/export_0.2.2.tar.gz", repos=NULL, type="source")

if (require("devtools")) install_github("INWTlab/shiny-matrix")
