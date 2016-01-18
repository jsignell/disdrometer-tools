#### Messy script for managing everything that is a work in progress #####
library(ggplot2)

file <- get.campbellsci_file("C:/Users/Julia/work/LoggerNet/CR6_SN1698_P_Size.dat")
DSD_perwidth <- 10**file
colnames(DSD_perwidth)[1:32] <- tabD
DSD <- DSD_perwidth
DSD_df <- as.data.frame(DSD_perwidth)
DSD_df$date_time <- as.POSIXct(row.names(DSD_df))

tabD <- rowMeans(get.classD())
tabN <- get.tabN(DSD, tabD)
data <- get.sum_stats(DSD, tabD, tabN)

# Friday:
storm.tabN <- tabN[3600:3700,]
storm.DSD <- DSD_df[3600:3700,]

# Wednesday:
storm.data <- data[58000:59000,]

storm.DSD <- DSD_df[58000:58300,]
storm.data <- data[58000:58300,]

storm.DSD <- DSD_df[58770:58870,]
storm.data <- data[58770:58870,]

storm.DSD <- DSD_df[58890:58970,]
storm.data <- data[58890:58970,]

plot.rate_gage(storm.data, rain_gage)
plot.DSD(storm.DSD)
plot.rate(data)
write.csv(data, file="Storm_summary_stats.csv", row.names=FALSE)

##### Nice plot of the rain rate with Parsivel and other gages #####

file <- get.campbellsci_file("GitHub/disdrometer-tools/input/CR5000_2015_10_30_14_25_40.dat")

##### Use pandas in python to quickly resample to 5 min interval #####
## python: import pandas as pd
##         df = pd.read_csv("Storm_summary_stats.csv", parse_dates=True, index_col=[1])
##         df.resample("5min", label="right").to_csv("Parsivel_5min.csv")

Parsivel_5min$date_time=as.POSIXct(Parsivel_5min$date_time)

rain_gage <- data.frame(date_time=as.POSIXct(row.names(file)),
                        rain_1=file$Rain_1_mm_Tot,
                        rain_2=file$Rain_2_mm_Tot)

rain_gage$rate_1 <- rain_gage$rain_1*60
rain_gage$rate_2 <- rain_gage$rain_2*60
rain_gage$rate <- (rain_gage$rate_1+rain_gage$rate_2)/2

# find storm:
qplot(data=gage, date_time, rate_1)

plot.rate_gage <- function(storm.data, rain_gage){
  
  start = storm.data[1,'date_time']
  end = storm.data[dim(storm.data)[1],'date_time']
  
  s = match(start,rain_gage$date_time)
  e = match(end,rain_gage$date_time)
  gage = rain_gage[s:e,]
  
  ar <- paste(c("Accumulated Rain:", '\n',
                "Parsivel:",round(sum(storm.data$rain_rate/120), digits=2),"mm (black)", '\n',
                "Gage Avg:",round(sum(gage$rate/60), digits=2),"mm (red)"), collapse = " ")
  
  p <- ggplot(storm.data, aes(date_time, rain_rate)) + geom_line() + 
          geom_point(data=gage, aes(date_time, rate), colour="red")+
          xlab("Time (UTC)")+
          ylab("Rain Rate (mm/hr)")+
          ggtitle("Comparison of Rain Rates during 2015-10-28 to 29 storm")
          #annotate("text", x = storm.data$date_time[600], y = 110, label = ar)
  return(p)
}
