#Read CodeSet
features = read.table("features.txt", header=FALSE, as.is=TRUE, col.names=c("MeasureID", "MeasureName"))
extract_features = grep(".*mean\\(\\)|.*std\\(\\)", features$MeasureName)
activity_labels <- read.table(file="./activity_labels.txt", head=FALSE, col.names=c("ActivityId", "ActivityName"))

#Read Train Data Set
train_x <- read.table(file="./train/X_train.txt", head=FALSE, col.names = features$MeasureName)
train_y <- read.table(file="./train/y_train.txt", head=FALSE, col.names = c("ActivityId"))
subject_train <- read.table(file="./train/subject_train.txt", head=FALSE, col.names = c("SubjectId"))
merge_train <- cbind(subject_train, train_y)
merge_train <- cbind(merge_train, train_x)
merge_train = merge_train[, extract_features]

#Read Test Data Set
test_x <- read.table(file="./test/X_test.txt", head=FALSE, col.names = features$MeasureName)
test_y <- read.table(file="./test/y_test.txt", head=FALSE, col.names = c("ActivityId"))
subject_test <- read.table(file="./test/subject_test.txt", head=FALSE, col.names = c("SubjectId"))
merge_test <- cbind(subject_test, test_y)
merge_test <- cbind(merge_test, test_x)
merge_test = merge_test[, extract_features]

#merge train and test data sets
merge_x <- rbind(merge_train, merge_test)

#replace activity id to activity name
merged_data <- merge(merge_x, activity_labels)
col_idx <- grep("ActivityName", names(merged_data))
#move activityName to first. and remove activityId column
merged_data <- subset(merged_data, select=c(1,col_idx,3:ncol(merged_data)-1))

#remove unnecessary characters in column name
cnames = colnames(merged_data)
cnames = gsub("\\.+mean\\.+", cnames, replacement = "Mean")
cnames = gsub("\\.+std\\.+", cnames, replacement = "Std")
colnames(merged_data) = cnames

#get mean in all fields by ActivityName and SubjectId
library(reshape2)
vars = setdiff(colnames(merged_data), c("ActivityId", "ActivityName", "SubjectId"))
melted_data <- melt(merged_data, id=c("ActivityId", "ActivityName", "SubjectId"), measure.vars=vars)
tidy_data = dcast(melted_data, ActivityName + SubjectId ~ variable, mean)

#Write text file
write.table(file="./tidy.txt", tidy_data, row.name=FALSE)
