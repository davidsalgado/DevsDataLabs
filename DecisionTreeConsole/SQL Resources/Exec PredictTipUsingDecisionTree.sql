USE [taxidata]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[PredictTipUsingDecisionTree]
		@trip_distance = 2.5

SELECT	'Return Value' = @return_value

GO
