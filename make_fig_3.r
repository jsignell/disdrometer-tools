plot.DSD <- function(tabN){
  ## Generate a colormap plot of drop size distribution across a storm
  
  ## Inputs:
  ## tabN = data.frame of drop counts for each diameter class. 
  ##        Column names are the avearage diameters of the classes.
  ##        Last column is called date_time and contains dates in POSIXct
  
  ## Output:
  ## p = ggplot2 dependant plot using a colormap to show DSD
  
  library(reshape2)
  library(ggplot2)
  
  storm.m <- melt(tabN, id_vars = date_time, 
                  measure.vars = colnames(tabN)[1:32],
                  value.name = "drop_count")
  
  colnames(storm.m)[2] <- "drop_diameter"
  storm.m$drop_diameter <- as.numeric(levels(storm.m$drop_diameter))[storm.m$drop_diameter]
  
  # add column containing widths of classes
  width <- as.data.frame(get.classD())
  w <- width$V2-width$V1
  storm.m$width <- rep(w,each = dim(tabN)[1])
  
  # plot heat map with linear scale
  p <- ggplot(data=storm.m, aes(x=date_time, y=drop_diameter, fill=drop_count)) +
    geom_tile(aes(height=width))+
    scale_fill_gradient(low = "white", high = "darkblue") +
    ylab("Drop Diameter (mm)")+
    ylim(0.2495,5)+
    ggtitle("Drop Size Distribution during 2015-10-09 storm")
  
  return(p)
}
