#loading the required packeges i.e dplyr and read.table
library(dplyr)
library(data.table)

#checking if the file exixts or not.If it doesn't then downloading it 
file<-"Dataset.zip"
if(!file.exists(file)){
  url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url,destfile =file)
}

#unzipping the file 
if(!file.exists("UCI HAR Dataset")){
  unzip(file)
}

#Reading files 
features<-read.table("./UCI HAR Dataset/features.txt")
x_test<-read.table("./UCI HAR Dataset/test/X_test.txt",col.names = features[,2])
x_train<-read.table("./UCI HAR Dataset/train/X_train.txt",col.names = features[,2])
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt",col.names = "Subject")
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt",col.names = "Subject")
activity_test<-read.table("./UCI HAR Dataset/test/y_test.txt",col.names = "Activity")
activity_train<-read.table("./UCI HAR Dataset/train/y_train.txt",col.names = "Activity")

#combining the files
data_test_train<-rbind(x_test,x_train)
subject_data<-rbind(subject_test,subject_train)
activity_data<-rbind(activity_test,activity_train)

#Merging the files to create a large dataset
data<-cbind(subject_data,activity_data,data_test_train)

#Extracting only the mean and standatrd deviation varibales
data<-select(data,c("Subject","Activity",grep("[Mm]ean|[Ss]td",colnames(data))))

#Using descriptive activity names to name the activities in the dataset
activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt")
data$Activity<-activity_labels[data$Activity,2]

#labeling the dataset with descriptive variable names
colnames(data)<-gsub("^t", "time",colnames(data))
colnames(data)<-gsub("^f", "frequency",colnames(data))
colnames(data)<-gsub("Gyro", "Gyroscope",colnames(data))
colnames(data)<-gsub("Mag", "Magnitude",colnames(data))
colnames(data)<-gsub("Acc", "Accelerometer",colnames(data))

#averaging each variable in dataset grouping by activity and subject
final_data <-data %>%
  group_by(Subject, Activity) %>%
  summarise_all(funs(mean))
write.table(final_data, "Tidydata.txt", row.name=FALSE)
