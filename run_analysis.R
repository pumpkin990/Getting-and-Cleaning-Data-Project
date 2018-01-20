## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")
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
names(Y_test) <- c("Activity_ID", "Activity_Label")
names(subject_test) <- "subject"
#combine the x_test and y_test
test_data <- cbind(as.data.table(subject_test), Y_test, X_test)

X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features

#extract the mean and the standard deviation 
X_train = X_train[,mean_sd_features]

#load the activity label
Y_train[,2] <- activity_labels[Y_train[,1]]
names(Y_train) <- c("Activity_ID", "Activity_Label")
names(subject_train) <- "subject"
#combine the x_train and y_train
train_data <- cbind(as.data.table(subject_train), Y_train, X_train)

data <- rbind(test_data, train_data)

id_labels <- c("subject", "Activity_ID", "Activity_Label")
data_labels <- setdiff(colnames(data), id_labels)
melt_data <- melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data <- dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")
