
get.tabN <- function(DSD, tabD){
  ## Return table of dropcounts for each diameter class
  
  ## Inputs:
  ## DSD = matrix containing the drop counts per cubic meter per diameter class.
  ##       each column represents the center of a given diameter class
  ## tabD = vector of diameter classes [mm] (i.e., 32 values for Parsivel)
  
  ## Outputs:
  ## tabN = number of drops in each diameter class in each time step
  
  S <- .0054 #m^2
  dt <- 30 #sec
  tabV <- raindrop_velocity(tabD)
  
  # This is only valid if you are sure you have exclusively rain
  tabV[23:32] <- 0
  
  nrow <- dim(DSD)[1]
  ncol <- dim(DSD)[2]
  
  tabN   <- DSD*NA_real_
  rM     <- rowMeans(DSD)
  id.dry <- which(rM<=10^-9)
  id.wet <- which(rM>10^-9)
  Ndry   <- length(id.dry)
  if(Ndry>0){tabN[id.dry,] <- 0}
  for(i in id.wet){tabN[i,] <- DSD[i,]*S*dt*tabV}
  tabN[which(tabN<=10^-9)] <- 0
  tabN <- as.data.frame(tabN)
  colnames(tabN)[1:32] <- tabD
  tabN$date_time <- as.POSIXct(row.names(tabN))

  return(tabN)
}

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

get.sum_stats<- function(DSD, tabD){
  ## Return summary stats on drop size distribution
  
  ## Inputs:
  ## DSD = matrix containing the drop counts per cubic meter per diameter class.
  ##       each column represents the center of a given diameter class
  ## tabD = vector of diameter classes [mm] (i.e., 32 values for Parsivel)
  
  ## Outputs:
  ## data = data.frame of interesting computed values for each timestep
  
  mass_mean_diameter <- compute_volDm(DSD, tabD)
  median_diameter <- compute_volD0(storm.DSD, tabD)
  concentration <- rowSums(DSD)
  concentration <- as.data.frame(concentration)[,1]
  rain_rate <- compute_volR(DSD, tabD)
  rain_rate <- round(rain_rate, digits=3)
  rain_mm_tot <- rain_rate/120
  data <- data.frame(date_time=as.POSIXct(row.names(DSD)),
                     rain_mm_tot=rain_mm_tot,
                     rain_rate=rain_rate,
                     concentration=concentration,
                     mass_mean_diameter=mass_mean_diameter,
                     median_diameter=median_diameter)
  return(data)
}