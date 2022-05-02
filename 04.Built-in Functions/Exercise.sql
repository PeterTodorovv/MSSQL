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

SELECT EmployeeID, FirstName, LastName FROM Employees