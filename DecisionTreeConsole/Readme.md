# Lab: Using a Decision Tree for Classification 
 
In the lab you will build a simple decision tree that predicts whether or not a taxi ride will receive a tip given the trip distance. You will also inspect the decision tree to understand the rules it learned to make the prediction. 

## Requirements
You can always run the R part of the lab on your favorite R Editor (RStudio, RGui, R Tools for VS), but if you want to have the complete experience, then you'd need:
* [SQL Server 2016 Developer Edition](https://www.microsoft.com/en-us/sql-server/sql-server-editions-developers) or higher 
* [Visual Studio 2015 Community Edition with Update 3](http://www.visualstudio.com) or Higher 


## Clone the project
Clone this repo on to your local machine. Make sure that you remember the path where you clone, i.e. C:\Decision Trees

## Create the database and table
1.	Open the DecisionTreeConsole.sln solution using Visual Studio 2015
2.	From Solution Explorer, expand the DecisionTreeConsole solution, then Solution Items folder and open “Create Sample Database.sql”.
3.	Adjust the file path for the FROM clause in the BULK INSERT statement if you cloned the project to a different location.
4.	Select the Execute button
5.	In the Connect dialog, provide your server name, authentication mode, username and password (as appropriate).
6.	Wait for the script to complete successfully.

## Create the Classification Training Stored Procedure
1.	Within Visual Studio, open “Create Procedure TrainTipPredictionModelUsingDecisionTree.sql”. This stored procedure queries the data in the nyctaxi_features table and creates a decision tree using to predict if the driver will be tipped based on the distance traveled. It uses the rxDTree function to accomplish this. The formula syntax "tipped ~ trip_distance” used in the first parameter simply means to predict tipped given the trip distance. The script then prints out the representation of the tree and saves the model to a table in the database.
2.	Execute the script to create the stored procedure.

## Execute the Classification Training Stored Procedure
1.	Within Visual Studio, open “Execute Procedure TrainTipPredictionModelUsingDecisionTree.sql”.
2.	Select the Execute button
3.	In the Connect dialog, provide your server name, authentication mode, username and password (as appropriate).
4.	Wait for the script to complete successfully.
5.	Observe the results on the Message tab.

You should see a textual representation of the results the looks like the following:

 

Graphically, you can interpret the results this way:
 

In summary, the tree that was generated predicts a tip when the trip distance is 1.25 miles or longer (the value 0.5675874 is closer to 1.0 which we interpret as tip). Trips shorter than 1.25 miles do not receive a tip (0.4473193 is closer to 0 which interpret as no tip). 

## Create the Classification Prediction Stored Procedure
1.	Within Visual Studio, open “Create Procedure TrainTipPredictionModelUsingDecisionTree.sql”. This stored procedure uses the model that was previously created to predict a tip given the trip duration.
2.	Execute the script to create the stored procedure.

## Execute the Classification Prediction Stored Procedure
1.	Within Visual Studio, open “Exec PredictTipUsingDecisionTree.sql”. This will invoke the prediction using a value of 2.5 miles as the trip distance. Feel free to experiment with your own trip distances.
2.	Execute the script. 
3.	Observe the results. 
4.	If the Score returned is greater than 0.5 assume a tip is predicted.

## Leverage Classification from an Application
1.	Within Visual Studio.
2.	Open program.cs and observe that this application is making a call to the PredictTipUsingDecisionTree stored procedure.
3.	Open app.config located underneath the DecisionTreeConsole project in Solution Explorer.
4.	Set the connectionString value so that it points to your SQL Server.
5.	Save the file.
6.	From the Debug menu, select Start Without Debugging.
7.	Enter a trip distance and observe the predicted tip or no tip.

## done?
You can explore other R and predictive analytics labs like:
* [this one](http://www.medium.com/@davidsb) where you will learn how to predict the number of customers that will visit a ski resort on a given date
*  or [this one](https://github.com/davidsalgado/DevsDataLabs/tree/master/Implementing%20Predictive%20Analytics) about predicting if a cab driver will be tipped or not.

Please feel free to open issues on the repo or PR to include more labs that have been useful for you

