USE SoftUni
SELECT FirstName, LastName
FROM Employees
WHERE FirstName  LIKE 'Sa%'
GO

SELECT FirstName, LastName 
FROM Employees
WHERE LastName LIKE '%ei%'
GO

SELECT FirstName FROM Employees
WHERE DepartmentID IN (3, 10) AND YEAR(HireDate) BETWEEN 1995 AND 2005
GO

SELECT FirstName, LastName FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'
GO

SELECT [Name] FROM Towns
WHERE LEN([Name]) IN (5, 6)
ORDER BY [Name]
GO

SELECT TownID, [Name] FROM Towns
WHERE LEFT([Name], 1) IN ('M', 'K', 'B', 'E')
ORDER BY [Name]
GO

SELECT TownID, [Name] FROM Towns
WHERE LEFT([Name], 1) NOT IN ('R', 'B', 'D')
ORDER BY [Name]
GO

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName FROM Employees
WHERE YEAR(HireDate) > 2000
GO

SELECT FirstName, LastName FROM Employees
WHERE LEN(LastName) = 5
GO

USE SoftUni
SELECT * FROM(
SELECT EmployeeID, FirstName, LastName, Salary,
DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank]
FROM Employees
WHERE Salary BETWEEN 10000 AND 50000 
)
AS RankingTable
WHERE RankingTable.[Rank] = 2
ORDER BY Salary DESC
GO



USE Geography
SELECT CountryName, IsoCode FROM Countries
WHERE CountryName LIke '%a%a%a%'
ORDER BY IsoCode
GO

SELECT PeakName, RiverName,
LOWER(CONCAT(LEFT(PeakName, LEN(PeakName) - 1), RiverName)) AS MIX
FROM Peaks, Rivers 
WHERE RIGHT(PeakName, 1) = LEFT(RiverName, 1)
ORDER BY MIX
GO

USE Diablo
SELECT [Name], 
FORMAT([Start], 'yyyy-MM-dd') AS [Start] 
FROM Games
WHERE DATEPART(YEAR ,[Start]) IN (2011, 2012)
ORDER BY [Start], [Name]
GO

SELECT Username, 
RIGHT(Email, LEN(Email) - CHARINDEX('@', Email)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username
GO

SELECT Username, IpAddress FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username
GO

SELECT [Name] AS Game,
CASE
	WHEN DATEPART(HOUR, [Start]) >= 0 AND DATEPART(HOUR, [Start]) < 12 THEN 'Morning'
	WHEN DATEPART(HOUR, [Start]) >= 12 AND DATEPART(HOUR, [Start]) < 18 THEN 'Afternoon'
	ELSE 'Evening'
	END AS [Part of the day],
CASE 
	WHEN Duration <=3 THEN 'Extra Short'
	WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
	WHEN Duration > 6 THEN 'Long'
	ELSE 'Extra Long' 
	END AS Duration
FROM Games
ORDER BY Game, Duration
GO

