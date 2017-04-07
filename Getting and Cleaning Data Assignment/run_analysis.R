
# Load the features select the index of the features

features<-read.table("features.txt")
featuresSelected <- grep(".*mean.*|.*std.*", features[,2])
featuresNames <- as.character(features[featuresSelected,2])
featuresNames <-gsub("[()]","",featuresNames)
featuresNames <-gsub("[-]","",featuresNames)
featuresNames <-gsub("std","Std",featuresNames)
featuresNames <-gsub("mean","Mean",featuresNames)

# Create a vector to select only the features of interest and to convert the data as numeric

cols<-rep("NULL",nrow(features))
cols[featuresSelected]<- "numeric"

# Load the data 

x_train <- read.table("./train/x_train.txt",colClasses = cols)
trainActivities<-read.table("./train/y_train.txt")
trainSubject <-read.table("./train/subject_train.txt")

x_test <- read.table("./test/x_test.txt",colClasses = cols)
testActivities<-read.table("./test/y_test.txt")
testSubject <-read.table("./test/subject_test.txt")

# combine the data in one table

train <- cbind(trainSubject,trainActivities,x_train)
test <- cbind(testSubject,testActivities,x_test)
data<-rbind(train,test)

#Provide appropriate name for the data
colnames(data)<-c("subject","activity",featuresNames)

#Replace the activity labels 
activity <-read.table("activity_labels.txt")
activity$V2<-as.character(activity$V2)


#Create a tidy data set with the average of each variable for each activity and each subject
dataMelt <- melt(data,id=c("activity","subject"))
dataMean <- dcast(dataMelt, activity + subject ~ variable, mean)

write.table(dataMean, "tidyData.txt", row.names = FALSE)

