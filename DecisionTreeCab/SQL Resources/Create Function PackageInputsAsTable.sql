USE [taxidata]
GO

CREATE FUNCTION [dbo].[PackageInputsAsTable] (
	@trip_distance float = 0
)
RETURNS TABLE
AS
  RETURN
  (

	  SELECT
		@trip_distance AS trip_distance
  )


GO
