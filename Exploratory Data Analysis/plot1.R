### Loading the data ###


#Create a vector with the columns classes to convert directly the columns
Classes =c("character","character","numeric","numeric","numeric","numeric","numeric","numeric","numeric")
data<-read.table("household_power_consumption.txt",sep = ";",header = TRUE,colClasses = Classes,na.strings = "?")

#Select the data from 2007-02-01 and 2007-02-02
data<-data[data$Date =="1/2/2007" | data$Date =="2/2/2007",]

### Create and save the plot

png("plot1.png", width = 480, height = 480)
hist(data$Global_active_power,col = "red",xlab = "Global Active Power (kilowatts)",main = "Global Active Power")
dev.off()
