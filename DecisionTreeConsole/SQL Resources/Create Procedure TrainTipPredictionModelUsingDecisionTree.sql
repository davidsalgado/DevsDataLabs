USE [taxidata]
GO

CREATE PROCEDURE [dbo].[TrainTipPredictionModelUsingDecisionTree]  
AS  
BEGIN  
  DECLARE @inquery nvarchar(max) = N'  
    select tipped,  trip_distance   
    from nyctaxi_features  
    tablesample (20 percent) repeatable (98052)  
'  
  -- Insert the trained model into a database table  
  INSERT INTO nyc_taxi_models  
  EXEC sp_execute_external_script
	@language = N'R',  
    @script = N'  

	## Create model  
	tipTree <- rxDTree(tipped ~ trip_distance, data = InputDataSet, maxDepth = 1)  

	## print out the generated tree
	print(tipTree)

	## Serialize model and put it in data frame  
	trained_model <- data.frame(model=as.raw(serialize(tipTree, NULL)));  
									',  
    @input_data_1 = @inquery,  
    @output_data_1_name = N'trained_model'  
  ;  

END  
GO  