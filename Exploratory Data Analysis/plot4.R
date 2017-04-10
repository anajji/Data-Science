### Loading the data ###


# Create a vector with the columns classes to convert directly the columns
Classes =c("character","character","numeric","numeric","numeric","numeric","numeric","numeric","numeric")
data<-read.table("household_power_consumption.txt",sep = ";",header = TRUE,colClasses = Classes,na.strings = "?")

# Select the data from 2007-02-01 and 2007-02-02
data<-data[data$Date =="1/2/2007" | data$Date =="2/2/2007",]

# Create a datetime vector
datetime = strptime(paste(data$Date, data$Time, sep=" "), "%d/%m/%Y %H:%M:%S")

### Create and save the plot


png("plot4.png", width = 480, height = 480)

par(mfrow=c(2,2),mar=c(5,5,1,1))

plot(datetime,data$Global_active_power,type="l",xlab="",ylab="Global Active Power (kilowatts)")

plot(datetime, data$Voltage, xlab="datetime", ylab="Voltage", type="l")

plot(datetime,data$Sub_metering_1,type="l",xlab="",ylab="Energy sub metering")
lines(datetime,data$Sub_metering_2,type="l",col="red")
lines(datetime,data$Sub_metering_3,type="l",col="blue")
legend("topright", legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),lty=1,col=c("black","red","blue"), bty = "n")

plot(datetime, data$Global_reactive_power, xlab="datetime", ylab="Global_reactive_power", type="l")

dev.off()

