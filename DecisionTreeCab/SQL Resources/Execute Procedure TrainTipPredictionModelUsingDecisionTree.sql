USE [taxidata]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[TrainTipPredictionModelUsingDecisionTree]

SELECT	'Return Value' = @return_value

GO
