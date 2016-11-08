
## BEGIN SECTION 1 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
library(RevoScaleR)

# Configure connection string
# If your Server includes an instance name use a \\ to escape it, for example localhost\sql2016 should be localhost\\sql2016
sqlConnString <- "Driver=SQL Server;Server=SERVER;Database=taxidata;Uid=USERNAME;Pwd=PASSWORD"

# Create the ComputeContext  
sqlShareDir <- paste("C:\\A Lap Around R Tools\\", Sys.getenv("USERNAME"), sep = "")
sqlWait <- TRUE
sqlConsoleOutput <- FALSE

## END SECTION 1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



## BEGIN SECTION 2 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Define the input query
inputQuery <- "select tipped,  trip_distance   
                from nyctaxi_features  
                tablesample (20 percent) repeatable (98052)"


# Create a data source by combining the SQL query, connection string and the R types of all columns selected by the SQL query
# data type options include: numeric, integer, logical, character, POSIXct (for date/time), and raw (for binary)
inDataSource <- RxSqlServerData(sqlQuery = inputQuery, connectionString = sqlConnString,
                                        colClasses = c(tipped = "numeric", trip_distance = "numeric"),
                                        rowsPerRead = 500)


# Get a summary of the data
rxSummary( ~ trip_distance, data = inDataSource)


# Plot a histogram using the trip distance
rxHistogram( ~ trip_distance, data = inDataSource, title = "Trip Distance Histogram")

# Plot a histogram using the tipped flag
rxHistogram( ~ tipped, data = inDataSource, title = "Tipped Histogram")


# Retrieve a subset of the data into a local data frame to view the rows
sampleOfData <- rxDataStep(inData = inDataSource,
    rowSelection = trip_distance > 50,
    varsToKeep = c("trip_distance", "tipped"))


## END SECTION 2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


## BEGIN SECTION 3 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
## Create model  
tipTree <- rxDTree(tipped ~ trip_distance, data = inDataSource, maxDepth = 1)

## print out the generated tree
print(tipTree)

## Package the input as a data frame
inputData <-  data.frame(
                        trip_distance = c(12.5)
                        )

## Run a prediction using the model and input data
OutputDataSet <- rxPredict(modelObject = tipTree, data = inputData, outData = NULL,
                        predVarNames = "Score");

## END SECTION 3 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<