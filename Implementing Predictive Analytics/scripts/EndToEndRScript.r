## Just in case you want to go through the steps on an R tool like (RGui, RStudio or R Tools for VS)
## these are the step by step to reproduce the lab

install.packages("RODBC")
library(RODBC)

##Connect to SQL Server 2016, assumes a Windows Authentication method
dbhandle <- odbcDriverConnect('driver={SQL Server};server=<yourservername>;database=taxidata;trusted_connection=true')

##Run the query to brin the data we'll use to create the model
res <- sqlQuery(dbhandle, 'select tipped,  passenger_count, trip_time_in_secs, trip_distance, direct_distance   from nyctaxi_features  tablesample (70 percent) repeatable (98052)')

##Create the model... 
logitObj <- rxLogit(tipped ~ passenger_count + trip_distance + trip_time_in_secs + direct_distance, data = res)

##Now, let's create the frame with the parameters for the prediction
prediction_parameters <- data.frame(passenger_count = c(1), trip_distance = c(2.5), trip_time_in_secs = c(631), direct_distance = c(2))

##predict
OutputDataSet<-rxPredict(modelObject = logitObj, data = prediction_parameters, outData = NULL, predVarNames = "Score", type = "response", writeModelVars = FALSE, overwrite = TRUE);
