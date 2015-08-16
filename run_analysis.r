# The script run_analysis.r and the zip file from 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# should be at the same folder. Only then this script will be working properly

# First download file from the web
zipUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if (!file.exists('usiHarDataset.zip')) {
        download.file(zipUrl, destfile = "usiHarDataset.zip")        
}

# Unzip downloaded file 
unzip("usiHarDataset.zip")

# Go to the "UCI HAR Dataset" directory
setwd(".")

# Reading in dataframes data from ./test directory
X_test <- read.table('./UCI HAR Dataset/test/X_test.txt')
y_test <- read.table('./UCI HAR Dataset/test/y_test.txt')
subject_test <- read.table('./UCI HAR Dataset/test/subject_test.txt')

# Merging X_test and y_test to Xy_test with cbin
Xy_test <- cbind(X_test, y_test, subject_test)

# Reading in dataframes data from ./train directory
X_train <- read.table('./UCI HAR Dataset/train/X_train.txt')
y_train <- read.table('./UCI HAR Dataset/train/y_train.txt')
subject_train <- read.table('./UCI HAR Dataset/train/subject_train.txt')

# Mergin X_train and y_train to Xy_train with cbin
Xy_train <- cbind(X_train, y_train, subject_train)

# Mergin Xy_test and Xy_train to Xy in one big data frame with rbind
Xy <- rbind(Xy_test, Xy_train)

# We want only mean and std to be left so we create a logical vector
# that is TRUE only with features that have words "mean" and "std" in
# their names
features <- read.table('./UCI HAR Dataset/features.txt')
colMeanStd <- grepl('std', as.character(features$V2)) | grepl('mean', as.character(features$V2))

# Delete columns that we don't need
Xy <- Xy[, colMeanStd]

# Creating proper names for labels in final dataframe
features <- features[colMeanStd, ]
colNames <- as.character(features$V2)
colNames <- c(colNames, "Activity", "Subject Id")

colnames(Xy) <- colNames

# Uses descriptive activity names to name the activity in data set
activity <- read.table('./UCI HAR Dataset/activity_labels.txt')
activity <- as.character(activity$V2)
activity_col <- activity[as.numeric(Xy$Activity)]

# Delete activity column in Xy data frame
Xy$Activity <- NULL
# Add new column with activity names
Xy$Activity <- activity_col

# Here I'am using dplyr library
library("dplyr")

Xy_dplyr <- tbl_df(Xy)
Xy_dplyr <- group_by(Xy_dplyr, `Subject Id`, Activity)
Xy_summary <- summarise_each(Xy_dplyr, funs(mean), 1:(length(Xy_dplyr)-2))

write.table(Xy_summary, file = 'summary.txt', row.name=FALSE)  
