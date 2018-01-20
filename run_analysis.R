if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

library(data.table)
library(reshape2)

#read the features 
features <- read.table("./UCI HAR Dataset/features.txt",header = F,stringsAsFactors = F)[,2]
#import the activity label
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",header = F,stringsAsFactors = F)[,2]
#extract the mena and the standard deviation
mean_sd_features<-grepl("mean|std",features)

#read the x_test and y_test table
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
#name the column by features
names(X_test)<-features
#extract the mean and the sd column 
X_test<-X_test[,mean_sd_features]
#import the activity label
Y_test[,2] <- activity_labels[Y_test[,1]]
names(Y_test) <- c("ActivityID", "ActivityLabel")
names(subject_test) <- "Subject"
#combine the x_test and y_test
DataTest.df <- cbind(as.data.table(subject_test), Y_test, X_test)

X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) <- features

#extract the mean and the standard deviation 
X_train <- X_train[,mean_sd_features]

#load the activity label
Y_train[,2] <- activity_labels[Y_train[,1]]
names(Y_train) <- c("ActivityID", "ActivityLabel")
names(subject_train) <- "Subject"
#combine the x_train and y_train
DataTrain.df <- cbind(as.data.table(subject_train), Y_train, X_train)

data <- rbind(DataTest.df, DataTrain.df)

IdLabels <- c("Subject", "ActivityID", "ActivityLabel")
DataLabels <- setdiff(colnames(data), IdLabels)
mdata <- melt(data, id = IdLabels, measure.vars = DataLabels)

# Apply mean function to dataset using dcast function
clean_data <- dcast(mdata, Subject + ActivityLabel ~ variable, mean)

write.table(clean_data, file = "./tidy_data.txt")
