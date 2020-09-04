# written by hao1ei (ver_20.03.13)
# hao1ei@foxmail.com
# qinlab.BNU

### Basic information set up ###
rm(list = ls())                                                # Delete all variables in the current environment
library(ggplot2); library(ggpubr)                              # Load and attach add-on packages
fig.dpi <- 300; fig.wid <- 18; fig.hei <- 12; fig.fmt <- "png" # Set parameters of the figure
fig.savedir <- getwd()                                         # Set the path where the picture will be saved

data.grp    <- "cohort2"                        # Group of the data
data.subgrp <- c("SWUC", "SWUA")                # Subgroups of the data
SWUC <- read.csv("fig1_data_cohort2_child.csv") # Read result file of basic information (.csv) for subgroup 1
SWUA <- read.csv("fig1_data_cohort2_adult.csv") # Read result file of basic information (.csv) for subgroup 2

condname.colname <- c("A_NoDoub_mean_abs",	"O_CenSpat_mean_abs",	"C_InconCon_mean_abs") # The indicators name in the data file
condname.figshow <- c("Alerting", "Orienting", "Executive")                              # The indicators name will present in the figure

### Make figure ###
# Convert the read data into a format recognized by the package
data.fig <- data.frame(matrix(NA,0,3))
for (igrp in  c(1:length(data.subgrp))) {
  for (icond in c(1:length(condname.figshow))) {
    data.con <- data.frame(rep(condname.figshow[icond], nrow(get(data.subgrp[igrp]))))
    data.ned <- data.frame(get(data.subgrp[igrp])[c("Group",condname.colname[icond])])
    
    data.tem <- cbind(data.con, data.ned)
    colnames(data.tem) <- c("Index","Group","Index.Data")
    
    data.fig <- rbind(data.fig, data.tem)
  }
}

# Set the figure parameters
data.barfig <- ggbarplot(data.fig,                            # The data frame of results
                         x="Index", y="Index.Data",           # Character string containing the name of x and y variable
                         color = "Group", fill = "Group",     # Outline color and fill color
                         add = "mean_se",                     # Adding another plot element
                         add.params = list(size = 1.5),       # parameters (size) for the argument 'add'
                         ylim = c(12.8,70),                   # Limitation of y axis
                         title = " ", xlab = " ", ylab = " ", # The x axis, y axis and title content of the figure
                         size = 0,                            # The size of points and outlines
                         position = position_dodge(0.72)) +   # Position adjustment
  # Add mean comparison p-values to the plot
  # stat_compare_means(aes(group=Group), method="t.test", label.y=c(50,50,50), label="p.signif", size=4) +                     
  
  # Customize the color of error bar for each group
  scale_color_manual(values=c("black","black"), name = "Group", labels = c("Children", "Adults"), guide = FALSE) +             
  
  # Customize the fill color for each group
  scale_fill_manual(values=c("lightseagreen","goldenrod1"), name = "Group", labels = c("Children", "Adults"), guide = FALSE) +
  
  # Position scales for continuous data of y axis
  scale_y_continuous(breaks=c(10,30,50,70), labels=c(10,30,50,70)) +                                                           
  
  # Modify components of a theme according to your preferences
  theme(
    plot.title            = element_text(size = 15, colour = "black", face = "bold", hjust = 0.5),
    axis.ticks            = element_line(size = 0.6, colour = "black"),
    axis.ticks.length     = unit(0.2, "cm"),
    axis.line.x           = element_line(colour = "black", size = 0.8),
    axis.line.y           = element_line(colour = "black", size = 0.8),
    axis.text.x           = element_text(size = 15, colour = 'black'),
    axis.text.y           = element_text(size = 15, colour = 'black'),
    axis.title            = element_text(size = 20, colour = "black"),
    panel.background      = element_rect(fill = "transparent"),
    plot.background       = element_rect(fill = "transparent", color = NA),
    legend.background     = element_rect(fill = "transparent"),
    legend.box.background = element_rect(fill = "transparent"),
    legend.title          = element_text(size = 18),
    legend.text           = element_text(size = 15),
    legend.position       = "right")
data.barfig

# Name of the figure
fig.name <- paste("fig1_bar_", data.grp, ".", fig.fmt, sep = "")
# Save figure to disk
ggsave(fig.name, path = fig.savedir, data.barfig, width=fig.wid, height=fig.hei, 
       units="cm", dpi=fig.dpi, bg="transparent")
