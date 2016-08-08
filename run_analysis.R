###############################################################################
# STEP 1. Merges the training and the test sets to create one data set
###############################################################################

#1.1 download and extract dataset
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#1.2 read in datasets
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", col.names = c("ActivityId", "Activity"))

#1.3 Combine datasets and add names
subject_all <- rbind(subject_train, subject_test)
y_all <- rbind(y_train, y_test)
x_all <- rbind(x_train, x_test)
names(subject_all)<-c("Subject")
names(y_all)<- c("ActivityId")
features <- read.table("./data/UCI HAR Dataset/features.txt",head=FALSE)
names(x_all) <- features$V2

subject_y <- cbind(subject_all, y_all)
data_all <- cbind(x_all, subject_y)

###############################################################################
# STEP 2. Extracts only the measurements on the mean and standard deviation 
# for each measurement
###############################################################################

subset1 <- data_all[,grepl("mean|std|Subject|ActivityId", names(data_all))]

###############################################################################
# STEP 3. Uses descriptive activity names to name the activities in the data set
###############################################################################

subset2 <- join(subset1, activity_labels, by = "ActivityId", match = "first")

###############################################################################
# STEP 4. Appropriately label the data set with descriptive variable names
###############################################################################

colnames(subset2)
names(subset2) <- gsub("^t", "Time", names(subset2))
names(subset2) <- gsub("^f", "Frequency", names(subset2))
names(subset2) <- gsub("-mean\\(\\)", "Mean", names(subset2))
names(subset2) <- gsub("-meanFreq\\(\\)", "MeanFreq", names(subset2))
names(subset2) <- gsub("-std\\(\\)", "StdDev", names(subset2))
names(subset2) <- gsub("-", "", names(subset2))
names(subset2) <- gsub("BodyBody", "Body", names(subset2))
colnames(subset2)

###############################################################################
# STEP 5. From the data set in step 4, creates a second, independent tidy data 
# set with the average of each variable for each activity and each subject
###############################################################################

tidy1 <- aggregate(. ~Subject + Activity, subset2, mean)
tidy1 <- tidy1[order(tidy1$Subject, tidy1$ActivityId),]
write.table(tidy1, "tidy.txt", row.name=FALSE)
