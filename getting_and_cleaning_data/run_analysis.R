# runProject is the main function for the project. This function does the following
# Download and unzip the file from the webserver
# Read the test and training  data and add appropriate column names from features.txt
# Filter the data by the mean and standard deviation columns
# Add the actvity label by merging with activity data set
# Remove the activity id column (since it is no longer necessary)
# Compute the average of each column by subject and actvity label
# Write the results to a file
runProject <- function()
{
    downloadAndUnzipProjectData()
    dataTable <-loadAndMergeTestAndTrainingData()
    filteredData <- filterColumns( dataTable)
    activityLabelTable <- readActivityLabelTable()
    filteredDataSetWithActivity <- merge (activityLabelTable, filteredData)
    finalSummaryTable <- generateSummaryTable ( filteredDataSetWithActivity )
    
    #Write the final results to a file
    write.table(finalSummaryTable, file="finalSummary.txt", row.name=FALSE)
    
    # Return the final result
    finalSummaryTable
}

# downloadAndUnzipProjectData function is responsible to 
# Check if the data is already present.
# Download the file is required
# Unzip the downloaded file
downloadAndUnzipProjectData <- function()
{
    destFile <- "UCI.zip"
    dataDir <- "UCI HAR Dataset"
    if (!file.exists (destFile))
    {
        sourceUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(sourceUrl, destFile)
    }
    if (! file.exists (dataDir))
    {
        dir.create(dataDir)
        unzip (destFile)
    }
}

# This function merges the training and test data set
# Both daasets must have the same schema 
loadAndMergeTestAndTrainingData <- function()
{
    trainingData <- readTrainingData()
    testData  <- readTestData()    
    allMydata <- rbind(trainingData, testData)    
}

# generateSummaryTable function
# Remove the activityIndex column since  we now have a proper label
# melt the data and identifies the ID columns
# Generate a summary by activity level and subject index
generateSummaryTable <- function ( data )
{
    data$activityIndex <- NULL
    meltedData <- melt (data, id = c("activityLabel", "subjectIndex") )
    cast(meltedData, activityLabel+subjectIndex~variable, mean)
}


# Read the test data. Use Features.txt to represent the columns of the dataset
# Add the activity index column from the y_test.txt file
# Add the subject index column from the subject_test.txt
readTestData <- function()
{
    columns = readFeatures()
    testData <- "UCI HAR Dataset\\test\\X_test.txt"
    testTable <- read.table ( testData, col.names = columns)
    
    testLabelDataActivityFile <- "UCI HAR Dataset\\test\\y_test.txt"
    columns = c("activityIndex")
    testLabelActivityTable <- read.table ( testLabelDataActivityFile, col.names= columns)
    
    completeTesting <- cbind(testLabelActivityTable, testTable)
    
    testLabelSubjectFile <- "UCI HAR Dataset\\test\\subject_test.txt"
    columns <- c("subjectIndex")
    testLabelSubjectTable <- read.table ( testLabelSubjectFile, col.names= columns)
    completeTesting <- cbind(testLabelSubjectTable, completeTesting)
    
}

# Read the training data. Use Features.txt to represent the colums of the dataset
# Add the activity index column from the y_training.txt file
# Add the subject index column from the subject_training.txt
readTrainingData <- function()
{
    columns = readFeatures()    
    trainingData <- "UCI HAR Dataset\\train\\X_train.txt"
    trainingTable <- read.table ( trainingData, col.names = columns)
    
    trainingLabelDataActivityFile <- "UCI HAR Dataset\\train\\y_train.txt"
    columns <- c("activityIndex")
    trainingLabelActivityTable <- read.table ( trainingLabelDataActivityFile, col.names= columns)
    
    completeTraining <- cbind(trainingLabelActivityTable, trainingTable)
    
    trainingLabelSubjectFile <- "UCI HAR Dataset\\train\\subject_train.txt"
    columns <- c("subjectIndex")
    trainingLabelSubjectTable <- read.table ( trainingLabelSubjectFile, col.names= columns)
    completeTraining <- cbind(trainingLabelSubjectTable, completeTraining)

}

# Read factor table. Function not used
#readFactorTable <- function(inputFile)
#{
#    columns <- c("index", "label")
#    factorsDataTable <- read.table ( inputFile, col.names = columns )
#     
#}

# readActivityLabelTable
# Read the activity_labels.txt file
# Returns a two column data frame
# activityIndex - the first column of the activity File. It is the index that 
# links to the test and training data sets
# activityLabel - the second column. It the descriptoin  for the index.
readActivityLabelTable <- function()
{
    columns <- c("activityIndex", "activityLabel")
    featuresTable <- read.table ( "UCI HAR Dataset\\activity_labels.txt", col.names = columns )
}

# readFeatures
# Read the feature table features.txt. 
# The features.txt represents the column headings for both training and activity dataset
readFeatures <- function()
{
    columns <- c("index", "label")
    featuresTable <- read.table ( "UCI HAR Dataset\\features.txt", col.names = columns )
    factor(featuresTable$label, ordered = TRUE )  
}

# filterColumns
# Ensures that the only column measure  present ae standard deviatoin and mean column
# Add the ID columns activityIndex and subjectIndex
filterColumns <- function(data)
{        
    allColumns = names ( data )
    stdColumns<- allColumns[grepl("std", allColumns) ]
    meanColumns<- allColumns[grepl("mean", allColumns) ]
    indexColumns <- c("activityIndex", "subjectIndex")
    filteredColumns = c(indexColumns, meanColumns, stdColumns )
    data[,filteredColumns]
}
