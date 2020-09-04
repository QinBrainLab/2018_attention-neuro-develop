# written by hao1ei (ver_20.03.13)
# hao1ei@foxmail.com
# qinlab.BNU

### Basic information set up ###
rm(list = ls())                                                # Delete all variables in the current environment
library(visreg); library(ggplot2); library(mgcv)               # Load and attach add-on packages
fig.dpi <- 300; fig.wid <- 14; fig.hei <- 12; fig.fmt <- "png" # Set parameters of the figure
fig.savedir <- getwd()                                         # Set the path where the picture will be saved
data.fig <- read.csv("fig1_data_cohort1_child.csv")            # Read result file of basic information (.csv)

name.colname <- c("A_NoDoub_mean_abs",	"O_CenSpat_mean_abs",	"C_InconCon_mean_abs") # The indicators name in the data file
name.figshow <- c("c1Alerting",	"c2Orienting",	"c3Executive")                       # The indicators name will present in the figure
con.col      <- c("lightcoral","darkolivegreen3","deepskyblue")                      # The indicators color will present in the figure

### Make figure ###
for (i in 1:length(name.colname)) {
  # Convert the read data into a format recognized by the package
  data.gam <- data.frame(data.fig[c("Group","Age1","Age2","Gender",name.colname[i])])
  colnames(data.gam) <- c("Group","Age1","Age2","Gender","index.fig")
  
  # Select Smoothing Parameters with REML, Using P-splines and Draw by visreg and ggplot2
  fit.agedev <- gam(index.fig ~ s(Age1)+Gender, data=data.gam, method="REML")
  fit.sum    <- summary(fit.agedev)
  
  # Set the present position of p-values
  p.x <- as.numeric(min(data.gam$Age2)) + 1
  p.y <- min(data.gam$index.fig)
  if (fit.sum$s.pv < 0.05 & fit.sum$s.pv >= 0.01) {
    p.v <- paste(as.character(format(fit.sum$s.pv,scientific=TRUE,digit=3)),"(*)",sep="")
  } else if (fit.sum$s.pv < 0.01 & fit.sum$s.pv >= 0.001) {
    p.v <- paste(as.character(format(fit.sum$s.pv,scientific=TRUE,digit=3)),"(**)",sep="")
  } else if (fit.sum$s.pv < 0.001) {
    p.v <- paste(as.character(format(fit.sum$s.pv,scientific=TRUE,digit=3)),"(***)",sep="")
  } else if (fit.sum$s.pv > 0.05) {
    p.v <- paste(as.character(format(fit.sum$s.pv,scientific=TRUE,digit=3)),"(ns)",sep="")
  }
  
  # Configure figure parameters
  fig.agedev <- visreg(fit.agedev,                                     # The fitted model object you wish to visualize
                       "Age1",                                         # Specifying the variable to be put on the x-axis of your plot
                       gg = TRUE,                                      # Use ggplot2's drawing properties
                       partial = T,                                    # If partial=TRUE or T, partial residuals are shown on the plot
                       band = T,                                       # If band=TRUE or T, confidence bands are shown on the plot
                       line = list(col = con.col[i], size = 1.5),      # Customize the color and size of fit line
                       points.par = list(size = 0.4,col = "gray50")) + # Customize the color of point
    
    # Add p-value to the plot
    annotate("text", x = p.x, y = p.y, label = paste("p<", p.v, sep = ""), size = 6) + 
    
    # Position scales for continuous data of x axis
    scale_x_continuous(breaks=c(7,8,9,10,11,12), labels=c(7,8,9,10,11,12)) + 
    
    # Limitation of y axis
    # scale_y_continuous(limits=c(10, 70)) +
    
    # The x axis, y axis and title content of the figure
    labs(x=" ", y=" ", title=" ") +
    
    # Modify components of a theme according to your preferences
    theme(
      plot.title            = element_text(size = 15, colour = "black", face = "bold", hjust = 0.5),
      axis.ticks            = element_line(size = 0.6, colour = "black"),
      axis.ticks.length     = unit(0.2, "cm"),
      axis.line.x           = element_line(colour = "black", size = 0.8),
      axis.line.y           = element_line(colour = "black", size = 0.8),
      axis.text             = element_text(size = 15, colour = "black"),
      axis.title            = element_text(size = 20, colour = "black"),
      panel.background      = element_rect(fill = "transparent"),
      plot.background       = element_rect(fill = "transparent", color = NA),
      legend.background     = element_rect(fill = "transparent"),
      legend.box.background = element_rect(fill = "transparent"),
      panel.grid.major      = element_blank(),
      panel.grid.minor      = element_blank(),
      legend.position       = "none")
  
  # Name of the figure
  fig.name <- paste("fig1_gam_", name.figshow[i], ".", fig.fmt, sep = "")
  # Save figure to disk
  ggsave(fig.name, path = fig.savedir, fig.agedev, width = fig.wid, height = fig.hei, 
         units = "cm", dpi = fig.dpi, bg = "transparent")
}
