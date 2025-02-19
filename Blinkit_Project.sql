SELECT *
FROM Projects.dbo.BlinkIT_Project

--Data Cleaning
/*
Cleaning the Item_Fat_Content field ensures data consistency and accuracy in analysis. 
The presence of multiple variations of the same category (e.g., LF, low fat vs. Low Fat) 
can cause issues in reporting, aggregations, and filtering. 
By standardizing these values, we improve data quality, making it easier to generate insights and maintain uniformity in our datasets.
*/
Update BlinkIT_Project
Set Item_Fat_Content = 
	Case 
		When Item_Fat_Content IN ('LF', 'low fat') Then 'Low Fat'
		When Item_Fat_Content = 'reg' Then 'Regular'
		Else Item_Fat_Content
		End


--Check whether Data has been cleaned or not for Item_Fat_Content
Select DISTINCT Item_Fat_Content
From Projects.dbo.BlinkIT_Project

--Alternatively
Select Item_Fat_Content, COUNT(*) as Cnt
From Projects.dbo.BlinkIT_Project
Group by Item_Fat_Content


--Creating KPI's
--1. Total Sales:
Select Round(SUM(Total_Sales),2) AS Total_Sales
From Projects.dbo.BlinkIT_Project


--2. Average Sales:
Select Round(AVG(Total_Sales),2) as Average_Sales
From Projects.dbo.BlinkIT_Project


--3. Total Orders Count
Select COUNT(*) as Total_Orders_Count
From Projects.dbo.BlinkIT_Project


--4. Average Rating, Rating contains too many nulls
--Method 1: Replace NULL with a Default Value Using (COALESCE)
;WITH Avg_Rating 
AS
	(
		Select Distinct Coalesce(Rating, 0) AS Rating
		From Projects.dbo.BlinkIT_Project
	)
Select AVG(Rating) as Average_Rating
From Avg_Rating

--Method 2: Replace NULL with Column Average (AVG + COALESCE)
;WITH Avg_Rating 
AS
	(
		Select Coalesce(Rating, (Select AVG(Rating) From Projects.dbo.BlinkIT_Project)) as Rating
		From Projects.dbo.BlinkIT_Project
		)
Select AVG(Rating) as Average_Rating
From Avg_Rating

--Method 3: Filter Out NULL Values (WHERE IS NOT NULL)
Select AVG(Rating) as Average_Rating
From Projects.dbo.BlinkIT_Project
Where Rating IS NOT NULL


--Total Sales by Fat Content - Low Fat Sale is more as compared to Regualar Fat
Select Item_Fat_Content, Round(SUM(Total_Sales),2) as Total_Sales_by_FatContent
From Projects.dbo.BlinkIT_Project
Group by Item_Fat_Content
Order by Total_Sales DESC


--Total Sales by Item Type - Fruits & Vegetables are the most sold Item
Select Item_Type, Round(Sum(Total_Sales),2) AS Sales_by_ItemType
From Projects.dbo.BlinkIT_Project
Group by Item_Type
Order by Sales_by_ItemType DESC

--Fat Content by Outlet for Total Sales
--Method 1:
Select Item_Fat_Content, Outlet_Location_Type, SUM(Total_Sales) as Sales_by_FC_and_Outlet
From Projects.dbo.BlinkIT_Project
Group by Item_Fat_Content, Outlet_Location_Type
Order by Sales_by_FC_and_Outlet DESC


--Method 2: Using Pivot much more better than Method 1
Select Outlet_Location_Type
	, ISNULL("Low Fat", 0) as "Low Fat"
	, ISNULL("Regular", 0) as "Regular"
From
	(
		Select Outlet_Location_Type, Item_Fat_Content, Round(SUM(Total_Sales),2) as Total_Sales
		From Projects.dbo.BlinkIT_Project
		Group by Outlet_Location_Type, Item_Fat_Content
	) AS SourceTable
	
PIVOT
	(
		Sum(Total_Sales)
		For Item_Fat_Content IN ("Low Fat", "Regular")
	) as T1


--Total Sales by Outlet Establishment
Select Outlet_Establishment_Year
	, Cast(Sum(Total_Sales) AS DECIMAL(10,2)) AS Total_Sales
From Projects.dbo.BlinkIT_Project
Group by Outlet_Establishment_Year
Order by Total_Sales DESC



--Percentage of Sales by Outlet Size
Select Outlet_Size
	, Sum(Total_Sales) AS Total_Sales
	, Sum(Total_Sales)*100 / SUM(Sum(Total_Sales)) Over () AS Sales_Percentage
From Projects.dbo.BlinkIT_Project
Group by Outlet_Size
Order by Total_Sales DESC


--Sales by Outlet Location
Select Outlet_Location_Type, Round(Sum(Total_Sales),2) as Total_Sales
From Projects.dbo.BlinkIT_Project
Group by Outlet_Location_Type
Order by Total_Sales DESC

--Percentage Sales by Outlet Location
Select Outlet_Location_Type
	, Round(Sum(Total_Sales),2) AS Total_Sales
	, Round(SUM(Total_Sales) * 100 / SUM(Sum(Total_Sales)) OVER (),2) AS PercentageByOutletLoction
From Projects.dbo.BlinkIT_Project
Group by Outlet_Location_Type
Order by Total_Sales DESC


--All Metrics by Outlet Type:
Select Outlet_Type
	, SUM(Total_Sales) as Total_Sales
	, AVG(Total_Sales) as Avg_Sales
	, Count(*) AS Total_Orders
	, Cast(AVG(Rating) as decimal(10,2)) AS Avg_Rating
From Projects.dbo.BlinkIT_Project
Group by Outlet_Type


