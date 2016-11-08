-- =============================================
-- Let's create a database so we can easily cleanup after we are done
-- =============================================
USE master
GO

IF  NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'JSONLab')
	CREATE DATABASE JSONLab
GO

USE JSONLab
GO

-- =========================================
-- Step 1 - Let's create some tables we will be using
-- =========================================

IF OBJECT_ID('dbo.UserProfile', 'U') IS NOT NULL
  DROP TABLE [dbo].[UserProfile]
GO

CREATE TABLE [dbo].[UserProfile]
(
	[UserId] [uniqueidentifier] DEFAULT(NEWID()) PRIMARY KEY,
	[UserLogin] [varchar](100) NOT NULL,
	[FirstName] [varchar](100) NOT NULL,
	[LastName] [varchar](100) NOT NULL,
	[UserSettings] [NVARCHAR](max) NULL
)
GO

IF OBJECT_ID('dbo.OrderTransaction', 'U') IS NOT NULL
  DROP TABLE dbo.[OrderTransaction]
GO


CREATE TABLE [dbo].[OrderTransaction](
	[TransactionID] [int] NULL,
	[CustomerID] [int] NULL,
	[CustomerName] [varchar](255) NULL,
	[TransactionDate] [datetime] NULL,
	[ProductDescription] [varchar](255) NULL,
	[ProductID] [varchar](255) NULL,
	[ProductSKU] [varchar](255) NULL,
	[Quantity] [int] NULL,
	[TotalCost] [decimal](18, 2) NULL,
	[AverageItemCost] [decimal](18,2) NULL,
	[ProductJSON] [nvarchar](max) NULL
) 
GO

IF OBJECT_ID('dbo.OrderAddress', 'U') IS NOT NULL
  DROP TABLE dbo.[OrderAddress]
GO


CREATE TABLE [dbo].[OrderAddress](
	[TransactionID] [int] NULL,
	[AddressType] [varchar](255) NULL,
	[Address1] [varchar](255) NULL,
	[City] [varchar](255) NULL,
	[State] [varchar](255) NULL,
	[PostalCode] [varchar](255) NULL
)
GO

IF OBJECT_ID('dbo.ExpenseTransaction', 'U') IS NOT NULL
  DROP TABLE dbo.[ExpenseTransaction]
GO

CREATE TABLE [dbo].[ExpenseTransaction](
	[EmployeeId] [int] NULL,
	[ExpenseDate] [datetime] NULL,
	[ExpenseCategory] [varchar](255) NULL,
	[Amount] [decimal](18,2) NULL,
	[PayeeInfo] [nvarchar](max) NULL
)
GO

-- =========================================
-- Step 2 - Let's add some User Profiles to our table
-- =========================================

Insert Into dbo.UserProfile (UserId, UserLogin, FirstName, LastName, UserSettings)
	VALUES(NEWID(), 'jsmith', 'Joan', 'Smith', JSON_QUERY('{
	"department":"Finance",
	"office":"London",
	"email":["jsmith@domain.com","joan.smith@domain.com"],
	"applications":
			{
				"application_financial":{
					"security_group":"administrators",
					"display_name":"Joan S.",
					"has_access":"True"
				},
				"application_expenses":{
					"approval_departments":["Finance","Accounting","Tax"],
					"approval_limit":15000,
					"has_access":"True"
				}
			}
}')),
(NEWID(), 'eparker', 'Elmer', 'Parker',JSON_QUERY('{
	"department":"Marketing",
	"office":"Tokyo",
	"email":["eparker@domain.com","elmer.parker@domain.com","marketing@domain.com"],
	"applications":
			{
				"application_marketing":{
					"installed_modules":["Reporting","Direct Mail","Social Marketing"],
					"email_enabled":"True",
					"export_data_enabled":"False",
					"has_access":"True"
				},
				"application_expenses":{
					"approval_departments":["Marketing"],
					"spending_limit":5000,
					"approval_limit":2500,
					"has_access":"False"
				}
			}
}'))


-- =========================================
-- Step 3: Returning a list of all users and systems they have access to
-- =========================================

Select
	UserLogin, FirstName, LastName, 
	JSON_VALUE(UserSettings, '$.email[0]') as primary_email,
	JSON_VALUE(UserSettings, '$.department') as department,
	JSON_VALUE(UserSettings, '$.office') as office,
	CAST(ISNULL(JSON_VALUE(UserSettings, '$.applications.application_financial.has_access'),0) as bit) as has_financial_access,
	CAST(ISNULL(JSON_VALUE(UserSettings, '$.applications.application_marketing.has_access'),0) as bit) as has_marketing_access,
	CAST(ISNULL(JSON_VALUE(UserSettings, '$.applications.application_expenses.has_access'),0) as bit) as has_expenses_access
From 
	dbo.UserProfile

-- =========================================
-- Step 4: Returning the Marketing settings for a user
-- =========================================

Select
    UserLogin, FirstName, LastName, 
	JSON_QUERY(UserSettings, '$.applications.application_marketing') as marketing_json
From 
	dbo.UserProfile
Where 
	UserLogin = 'eparker'

-- =========================================
-- Step 5: Updating settings in the JSON
-- =========================================


-- Updating a single scalar value
Update dbo.UserProfile
 Set UserSettings = JSON_MODIFY(UserSettings,'$.applications.application_expenses.spending_limit', CAST('6000' as int))
 Where UserLogin = 'eparker'

-- Updating a scalar value that does not exist
Update dbo.UserProfile
 Set UserSettings = JSON_MODIFY(UserSettings,'$.applications.application_expenses.spending_limit', CAST('100000' as int))
 Where UserLogin = 'jsmith'

-- Adding a value to an array
Update dbo.UserProfile
 Set UserSettings = JSON_MODIFY(UserSettings, 'append$.email','finance@domain.com')
 Where UserLogin = 'jsmith'

-- Adding a block of JSON
Update dbo.UserProfile
 Set UserSettings = JSON_MODIFY(UserSettings,'$.applications.application_marketing.social_settings', 
	JSON_QUERY('{"facebook_url":"www.facebook.com/myurl","linkedin_url":"www.linkedin.com/myurl","twitter_handle":"myhandle"}'))
 Where UserLogin = 'eparker'

 -- =========================================
 -- Step 6: Parsing JSON Documents into Tables
 -- =========================================

 DECLARE @json_expenses nvarchar(max)

 Set @json_expenses = '[{
	"EmployeeID": 264581,
	"ExpenseDate": "2016-10-16T18:25:43.511Z",
	"Category": "Meals",
	"Amount": 45.85,
	"Payee":{
			"PayeeName":"The Steak Place",
			"PayeeCity":"New York",
			"PayeeState":"NY"
			}
}, {
	"EmployeeID": 750943,
	"ExpenseDate": "2016-10-15T09:25:43.511Z",
	"Category": "Transportation",
	"Amount": 28.67,
	"Payee":{
			"PayeeName":"Taxi Service",
			"PayeeCity":"San Francisco",
			"PayeeState":"CA"
			}
},{
	"EmployeeID": 795463,
	"ExpenseDate": "2016-10-17T09:25:43.511Z",
	"Category": "Lodging",
	"Amount": 358.25,
	"Payee":{
			"PayeeName":"Hotels Supreme",
			"PayeeCity":"Seattle",
			"PayeeState":"WA"
			}
}]'

Insert Into dbo.ExpenseTransaction(EmployeeId, ExpenseDate, ExpenseCategory, Amount, PayeeInfo)
Select * From 
	OPENJSON(@json_expenses, '$')
	WITH (
			EmployeeID int,
			ExpenseDate datetime,
			ExpenseCategory varchar(255) '$.Category',
			Amount decimal(18,2),
			PayeeInfo nvarchar(max) '$.Payee' as JSON
		)

Select
	*
From dbo.ExpenseTransaction

 DECLARE @json_trans nvarchar(max)

 SET @json_trans = '{
	"TransactionID":"748594",
	"CustomerID":"989345934",
	"CustomerName":"John Glover",
	"TransactionDate":"2016-10-16T18:25:43.511Z",
	"ProductName":"Widget 2.0",
	"ProductCode":{"ProductID":"8jf749","ProductSKU":"9845kwrh8504"},
	"Quantity": 5,
	"TotalCost": 245.25,
	"Address": [{
		"AddressType": "Shipping",
		"StreetAddress": "123 Main St.",
		"City": "Anytown",
		"State": "WA",
		"PostalCode": "12345"
	}, {
		"AddressType": "Billing",
		"StreetAddress": "123 Main St.",
		"City": "Anytown",
		"State": "WA",
		"PostalCode": "12345"
	}],
	"ProductOptions": {
		"Length": 123,
		"Color": ["Red", "White", "Purple"],
		"Width": 10
	}
}'




Insert Into [dbo].[OrderTransaction]
Select 
	TransactionID, CustomerID, CustomerName, TransactionDate, ProductDescription, 
	ProductID, ProductSKU, Quantity, TotalCost, 
	-- We can add calculations just like we would in a Select from a Table
	(TotalCost/Quantity) as AverageItemCost, 
	ProductJSON
From
	OPENJSON(@json_trans)
	WITH
		(
			TransactionID int,
			CustomerID int,
			CustomerName varchar(255),
			TransactionDate datetime,
			ProductDescription varchar(255) '$.ProductName',
			-- ProductID and ProductSKU are nested so we need to
			-- provide a path to the sub-document
			ProductID varchar(255) '$.ProductCode.ProductID',
			ProductSKU varchar(255) '$.ProductCode.ProductSKU',
			Quantity int,
			TotalCost decimal(18,2),
			-- We need to specify AS JSON anytime we are returning a JSON object
			ProductJSON nvarchar(max) '$.ProductOptions' AS JSON
		)
		 
Insert Into [dbo].[OrderAddress]
Select ord.TransactionID, addr.* 
From 
	-- We want to get the array of addresses so are path pulls the value 
	-- for the Address property
	OPENJSON(@json_trans, '$.Address')
WITH
	(
		AddressType varchar(255),
		Address1 varchar(255) '$.StreetAddress',
		City varchar(255),
		[State] varchar(255),
		PostalCode varchar(255)
	) as addr
CROSS APPLY 
	-- We cross apply with the order so we can store the Transaction ID with each address
	-- This will be a common pattern we can use to deal with more complex documents.
	OPENJSON(@json_trans)
	WITH (TransactionID int) as ord



 -- =========================================
 -- Step 7: Returning Data using FOR JSON
 -- =========================================

 -- If we want to return some simple JSON Documents 
 -- we can use FOR JSON AUTO

 Select 
  UserId,
  UserLogin as login,
  FirstName as fname,
  LastName as lname,
  JSON_QUERY(UserSettings) as Settings
 From 
 dbo.UserProfile
 FOR JSON AUTO, ROOT('UserProfiles')


 -- When we need to have a more complex document with nested structures
 -- we can use the PATH option

 Select
	ot.TransactionID,
	ot.TransactionDate,
	ot.ProductID as [ProductInfo.ProductID],
	ot.ProductSKU as [ProductInfo.ProductDetails.ProductSKU],
	ot.ProductDescription as [ProductInfo.ProductDetails.ProductDescription],
	oas.Address1 as ShippingAddress,
	oas.City + ', ' + oas.[State] + ' ' + oas.PostalCode as ShippingCityStatePostal,
	oab.Address1 as BillingAddress,
	oab.City + ', ' + oab.[State] + ' ' + oab.PostalCode as BillingCityStatePostal
From
	dbo.OrderTransaction ot
Left Outer Join dbo.OrderAddress oas
	On ot.TransactionID = oas.TransactionID
		And oas.AddressType = 'Shipping'
Left Outer Join dbo.OrderAddress oab
	on ot.TransactionID = oab.TransactionID
		And oab.AddressType = 'Billing'
FOR JSON PATH

 -- =========================================
 -- Step 8: Indexing with JSON
 -- =========================================

 -- We will add a computed column that pulls the property from our document
 ALTER TABLE dbo.ExpenseTransaction
 ADD vPayeeState AS JSON_VALUE(PayeeInfo, '$.PayeeState')  
 GO
 
 -- Now we can create an index based on that virtual column
 -- We could also include any other columns in the index that 
 -- would show SQL Server to use the index in query plans
 CREATE INDEX idx_expensetransaction_payeestate  
	ON dbo.ExpenseTransaction(vPayeeState)
	INCLUDE (ExpenseDate, Amount)


-- It will use our index as long as our query uses 
-- the exact same syntax as our computed column

Select 
	ExpenseDate, Amount, JSON_VALUE(PayeeInfo, '$.PayeeState')
From 
	dbo.ExpenseTransaction
Where
	JSON_VALUE(PayeeInfo, '$.PayeeState') = 'CA'


 -- =========================================
 -- Step 9: Constraints
 -- =========================================


 -- We can use the ISJSON function to return a True/False for whether
 -- the text data is valid formatted JSON.

 ALTER TABLE dbo.ExpenseTransaction
 ADD CONSTRAINT [Payee Info should be a valid JSON Document]
 CHECK ( ISJSON(PayeeInfo) > 0 )
 GO

 -- We will also add a constraint to make sure the PayeeName is always populated.
 ALTER TABLE dbo.ExpenseTransaction
 ADD CONSTRAINT [Payee Info should have a Payee Name]
 CHECK ( JSON_VALUE(PayeeInfo, '$.PayeeName') IS NOT NULL)

 -- Now if we try and Insert invlid data we will fail
INSERT INTO [dbo].[ExpenseTransaction]
	([EmployeeId],[ExpenseDate],[ExpenseCategory],[Amount],[PayeeInfo])
VALUES
	(
	74630,'2016-10-31 09:25:43.510','Meals',125.25, 
--	Note that there is no : between the PayeeName Property and the Value
	'{"PayeeName""A Burger Place","PayeeCity":"Orlando","PayeeState":"FL"}'
	)

INSERT INTO [dbo].[ExpenseTransaction]
	([EmployeeId],[ExpenseDate],[ExpenseCategory],[Amount],[PayeeInfo])
VALUES
	(
	74630,'2016-10-31 09:25:43.510','Meals',125.25, 
	-- Note that the PayeeName Property is spelled incorrectly and this will not be found.
	'{"Payee_Name":"A Burger Place","PayeeCity":"Orlando","PayeeState":"FL"}'
	)
