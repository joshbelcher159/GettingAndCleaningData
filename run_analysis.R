# set working directory
setwd("C://Users//Joshua//Desktop//Skoo//2015//Fall 2015//Getting And Cleaning Data//Project")

# set URL and local files
downloadUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
downloadFolder <- "./download"
downloadFile <- paste(downloadFolder, "Dataset.zip", sep = "/")
dataFolder <- "./UCI HAR Dataset"

# if the download folder does not exist, create it
if (!file.exists(downloadFolder)) {
  dir.create(downloadFolder)
}

# if the data set has not been downloaded, download it
if (!file.exists(downloadFile)) {
  download.file(downloadUrl, downloadFile)
}

# if the data set has not been unzipped, unzip it
if (!file.exists(dataFolder)) {
  unzip(downloadFile, exdir = ".")
}

# read in the training and testing data
# subjects, activities and actual data

# subjects
subTrain <- read.table(paste(dataFolder, "train/subject_train.txt", sep = "/"), header = FALSE)
subTest <- read.table(paste(dataFolder, "test/subject_test.txt", sep = "/"), header = FALSE)

# activities
actTrain <- read.table(paste(dataFolder, "train/Y_train.txt", sep = "/"), header = FALSE)
actTest <- read.table(paste(dataFolder, "test/Y_test.txt", sep = "/"), header = FALSE)

# data
datTrain <- read.table(paste(dataFolder, "train/X_train.txt", sep = "/"), header = FALSE)
datTest <- read.table(paste(dataFolder, "test/X_test.txt", sep = "/"), header = FALSE)

# merge the sets
subM <- rbind(subTrain, subTest)
actM <- rbind(actTrain, actTest)
datM <- rbind(datTrain, datTest)

# read activity labels and features
aVector <- read.table(paste(dataFolder, "activity_labels.txt", sep = "/"), header = FALSE)
fVector <- read.table(paste(dataFolder, "features.txt", sep = "/"), header = FALSE)

## set column names
colnames(aVector) <- c("Activity_code","Activity_str")
colnames(fVector) <- c("Feature_code","Feature_str")
colnames(datM) <- fVector$Feature_str

# filtering data
filtered <- names(datM)[grep("mean\\(\\)|std\\(\\)", names(datM))]
datM <- datM[,filtered]

# cleanup strings
colnames(datM) <- sub("\\(\\)", "Col", names(datM))

# prepend subject id and activity labels
datM <- cbind(SubjectId = subM[,1], ActivityLabel = actM[,1], datM)
datM$Activity <- apply (datM["ActivityLabel"], 1, function(x) aVector[x,2])

# tidy data set
tDat <- aggregate(.~SubjectId + ActivityLabel, data = datM, mean)

# write it all out
write.table(tDat, paste(dataFolder, "tidy.txt", sep = "/"), sep = "\t", col.names = T, row.names = T, quote = T)
