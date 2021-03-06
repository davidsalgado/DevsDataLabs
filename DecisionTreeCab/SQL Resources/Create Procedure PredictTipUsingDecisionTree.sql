USE [taxidata]
GO

CREATE PROCEDURE [dbo].[PredictTipUsingDecisionTree] 
	@trip_distance float = 0
AS
BEGIN

  -- Package the inputs as a table	
  DECLARE @inquery nvarchar(max) = N'
	SELECT trip_distance FROM [dbo].[PackageInputsAsTable]( @trip_distance )
	'

  -- Load the serialized model from the nyc_taxi_models table		
  DECLARE @lmodel2 varbinary(max) = (SELECT TOP 1 model FROM nyc_taxi_models);

  -- Invoke the prediction
  EXEC sp_execute_external_script 
		@language = N'R',
        @script = N'
			mod <- unserialize(as.raw(model));

			OutputDataSet<-rxPredict(modelObject = mod, data = InputDataSet, outData = NULL, 
						predVarNames = "Score");

			',
		@input_data_1 = @inquery,
		@params = N'@model varbinary(max), 
					@trip_distance float',
        @model = @lmodel2,
		@trip_distance = @trip_distance
		WITH RESULT SETS ((Score float));

END


