# Lab: Lap Around the R Tools for Visual Studio
 
In this lab you will use the R Tools for Visual Studio to build and execute an R script the creates a model using a decision tree using data from an instance of SQL Server 2016. 

## Requirements
* [SQL Server 2016 Developer Edition](https://www.microsoft.com/en-us/sql-server/sql-server-editions-developers) or higher
* [Visual Studio Community](http://www.visualstudio.com) or higher


Clone the provided project
Clone this repo on to your local machine. The recommended path is C:\RTools

### Create the database and table
1.	Open the *“lap around R tools.sln”* solution using Visual Studio 2015
2.	From Solution Explorer, expand the solution, then Solution Items folder and open “Create Sample Database.sql”.
3.	Adjust the file path for the **FROM** clause in the **BULK INSERT** statement if you cloned the project to a different location.
4.	Select the Execute button
5.	In the Connect dialog, provide your server name, authentication mode, username and password (as appropriate).
6.	Wait for the script to complete successfully.

### Install Microsoft R Client
1.	If you do not already have the Microsoft R Client installed, you can do so easily by select R Tools and then Install Microsoft R Client…
2.	Follow the prompts and then return to this lab.

### Setup the SQL Server Connection
1.	Within Visual Studio, open **script.R**. 
2.	Scroll down to the line that looks like:
```
sqlConnString <- "Driver=SQL Server;Server=SERVERNAME;Database=taxidata;Uid=USERNAME;Pwd=PASSWORD"
```

3.	Replace **SERVERNAME**, **USERNAME** and **PASSWORD** with the values appropriate to your local instance of SQL Server.
4.	Within the editor, highlight the text between 
```
## BEGIN SECTION 1 >>> and ## END SECTION 1 <<<
```

5.	With the text selected, press Control + Enter to execute the selection within the Interactive Window. 
6.	This section of code defined a connection string to SQL Server and configured the display of console output to the R Interactive Window.

### Query and Explore the Data
1.	Within the editor, highlight the text between 
```
## BEGIN SECTION 2 >>> and ## END SECTION 2 <<<
```

2.	With the text selected, press Control + Enter to execute the selection within the Interactive Window. 
3.	This section of code does a few things. 
4.	First, it defines the SQL query that will be used later to train the predictive model. 
5.	Second, it creates a Data Source object that uses this query, the SQL connection string and provides an R based schema for the shape of the query results. 
6.	Third, it summarizes the results of the query by trip distance using the **rxSummary** function—you should see the results of this summary in the R Interactive Window (the results provide the Mean, Standard Deviation, Minumum and Maximum values for the trip_distance column). 
7.	Fourth, it plots two histograms of the data, one each for the trip_distance and for the tipped flag. These are visible within the R Plots Window (accessible from the R Tools menu by selecting Windows, Plots). 
8.	Fifth, it uses **rxDataStep** to take a smaller sample of the data and store the data locally within Visual Studio’s process space. You can explore the data retrieved by going to the Variable Explorer Window (R Tools, Windows, Variable Explorer) and selecting the magnifying glass to the right of the variable with the name sampleOfData. This will display the data in a familiar grid format.

### Build and Execute the Model
1.	Within the editor, highlight the text between 
```
## BEGIN SECTION 3 >>> and ## END SECTION 3 <<<
```

2.	With the text selected, press Control + Enter to execute the selection within the Interactive Window. 
3.	The first line of code in this section builds a Decision Tree to predict whether or not a trip will be tipped based on the trip distance, using the taxi data from the query. This is accomplished by the call to **rxDTree**.
4.	The following call to print outputs the generated decision tree (which shows that trips less than 1.25 miles are predicted not to get tips). This output is shown in the Interactive Window.
5.	The last two lines prepare an input to use to predict against (e.g., predict if a tip will happen for a trip that 12.5 miles in distance) and then runs the prediction using the created model.
6.	Notice the prediction result is saved in the variable OutputDataSet, whose value you can see using the Variable Explorer Window.

