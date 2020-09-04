# written by hao1ei (ver_20.03.13)
# hao1ei@foxmail.com
# qinlab.BNU

### Basic information set up ###
rm(list = ls())                                                # Delete all variables in the current environment
library(ggsignif); library(ggplot2); library(ggpubr)           # Load and attach add-on packages
fig.dpi <- 300; fig.wid <- 20; fig.hei <- 10; fig.fmt <- "png" # Set parameters of the figure
fig.savedir <- getwd()                                         # Set the path where the picture will be saved

# Read result file of basic information (.csv)
data.index <- read.csv("fig4_data_cohort1_adult_img.csv")

data.subcond <- c("cond1", "cond2", "cond3")                                   # Conditions of the figure
cond1 <- merge(read.csv("res_rsa_sim_12_con.csv"), data.index, by = "Scan_ID") # Read result file (.csv) of pair between alerting and orienting condition
cond2 <- merge(read.csv("res_rsa_sim_13_con.csv"), data.index, by = "Scan_ID") # Read result file (.csv) of pair between alerting and executive condition
cond3 <- merge(read.csv("res_rsa_sim_23_con.csv"), data.index, by = "Scan_ID") # Read result file (.csv) of pair between orienting and executive condition

# The indicators name in the data file
condname.colname <- c("Grp_CBD_Speci_fdr05_r01_ai_b","Grp_CBD_Speci_fdr05_r02_dacc_r","Grp_CBD_Speci_fdr05_r03_tpj_r")

### Make figure ###
# Convert the read data into a format recognized by the package
data.fig <- data.frame(matrix(NA,0,3))
for (icond in  c(1:length(data.subcond))) {
  for (icol in c(1:length(condname.colname))) {
    data.con <- data.frame(rep(condname.colname[icol], nrow(get(data.subcond[icond]))))
    data.ned <- data.frame(get(data.subcond[icond])[c("Conds",condname.colname[icol])])
    
    data.tem <- cbind(data.con, data.ned)
    colnames(data.tem) <- c("Index","Conds","Index.Data")
    
    data.fig <- rbind(data.fig, data.tem)
  }
}

# Set the figure parameters
data.barfig <- ggbarplot (data.fig,                            # The data frame of results
                          x = "Index", y = "Index.Data",       # Character string containing the name of x and y variable
                          title = " ", xlab = " ", ylab = " ", # The x axis, y axis and title content of the figure
                          add = "mean_se",                     # Adding another plot element
                          add.params = list(size = 0.6),       # parameters (size) for the argument 'add'
                          size = 0,                            # The size of points and outlines
                          color = "Conds", fill = "Conds",     # Outline color and fill color
                          position = position_dodge(0.8)) +    # Position adjustment
  
  # Customize the fill color for each condition
  scale_fill_manual(values=c("yellow3","mediumvioletred","darkcyan"), name = "Conds", labels = c("ao","ac","oc")) +
  
  # Customize the color of error bar for each condition
  scale_color_manual(values=c("black","black","black"), name = "Conds", labels = c("ao","ac","oc"), guide = FALSE) +
  
  # Position scales for discrete data of x axis
  scale_x_discrete(breaks = condname.colname, labels = c('AI','dACC','TPJ')) +
  
  # Limitation of y axis
  coord_cartesian(ylim = c(-0.2, 0.31)) +
  
  # Modify components of a theme according to your preferences
  theme(
    plot.title            = element_text(size = 15, colour = "black", face = "bold", hjust = 0.5),
    axis.ticks            = element_line(size = 0.6, colour = "black"),
    axis.ticks.length     = unit(0.2, "cm"),
    axis.line.x           = element_line(colour = "black", size = 0.8),
    axis.line.y           = element_line(colour = "black", size = 0.8),
    axis.text             = element_text(size = 15, colour = "black"),
    axis.text.x           = element_text(size = 15, colour = "black"),
    axis.title            = element_text(size = 20, colour = "black"),
    panel.background      = element_rect(fill = "transparent"),
    plot.background       = element_rect(fill = "transparent", color = NA),
    legend.background     = element_rect(fill = "transparent"),
    legend.box.background = element_rect(fill = "transparent"),
    legend.position       = "none"
  )
data.barfig

# Name of the figure
fig.name <- paste("fig4_bar_adults_roi456", ".", fig.fmt, sep = "")
# Save figure to disk
ggsave(fig.name, path = fig.savedir, data.barfig, width = fig.wid, height = fig.hei, 
       units = "cm", dpi = fig.dpi, bg = "transparent")
