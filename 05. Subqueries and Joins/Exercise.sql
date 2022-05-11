USE SoftUni

SELECT TOP(5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText FROM Employees AS e
JOIN Addresses AS a
On e.AddressID = a.AddressID
ORDER BY AddressID 
GO

SELECT TOP(50)e.FirstName, e.LastName, t.[Name], a.AddressText FROM Employees AS e
JOIN Addresses AS a
ON a.AddressID = e.AddressID
JOIN Towns AS t
ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName
GO

SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name] FROM Employees AS e
LEFT JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY e.EmployeeID
GO

SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.[Name] FROM Employees AS e
LEFT JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY e.DepartmentID
GO

SELECT TOP(3) e.EmployeeID, e.FirstName FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL
ORDER BY e.EmployeeID
GO

SELECT e.FirstName, e.LastName, e.HireDate, d.[Name] FROM Employees AS e
LEFT JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1991-01-01' AND d.[Name] IN ('Sales', 'Finance')
ORDER BY e.HireDate
GO

SELECT TOP(5) e.EmployeeID, e.FirstName, p.[Name] AS ProjectName FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID
LEFT JOIN Projects AS p
ON ep.ProjectID = p.ProjectID 
WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID
GO

SELECT e.EmployeeID, e.FirstName, 
CASE 
WHEN YEAR(p.StartDate) >= '2005' THEN NULL
ELSE p.[Name]
END AS ProjectName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID
LEFT JOIN Projects AS p
ON ep.ProjectID = p.ProjectID 
WHERE e.EmployeeID = 24
GO

SELECT e.EmployeeID, e.FirstName, m.EmployeeID AS ManagerID, m.FirstName AS ManagerName FROM Employees AS e
LEFT JOIN Employees AS m
ON e.ManagerID = m.EmployeeID
WHERE m.EmployeeID IN (3, 7)
ORDER BY e.EmployeeID
GO

SELECT TOP(50) e.EmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName, CONCAT(m.FirstName, ' ', m.LastName) AS ManagerName, d.[Name] AS DepartmentName
FROM Employees AS e
LEFT JOIN Employees AS m
ON e.ManagerID = m.EmployeeID
LEFT JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID
GO

SELECT MIN(s.AverageSalary) AS MinAverageSalary FROM 
(SELECT AVG(Salary) AS AverageSalary From Employees GROUP BY DepartmentID) AS s
GO

USE Geography
SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m
ON m.Id = mc.MountainId
LEFT JOIN Peaks AS p
ON p.MountainId = m.Id
WHERE p.Elevation > 2835 AND c.CountryCode = 'BG'
ORDER BY Elevation DESC
GO

SELECT c.CountryCode , COUNT(mc.MountainId) AS MountainRanges
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
ON c.CountryCode = mc.CountryCode
WHERE c.CountryCode IN ('US', 'BG', 'RU')
GROUP BY c.CountryCode
GO

SELECT TOP(5) c.CountryName, r.RiverName 
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr
ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r
ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName
GO

SELECT * FROM
(
SELECT c.ContinentCode, c.CurrencyCode, COUNT(c.CurrencyCode) AS CurrencyUsage
FROM Countries AS c
GROUP BY c.ContinentCode, c.CurrencyCode
) AS Subquery
WHERE CurrencyUsage > 1
ORDER BY ContinentCode
GO

SELECT TOP(5)
c.CountryName
,MAX(p.Elevation) AS HighestPeakElevation
,MAX(r.[Length]) AS LongestRiverLength
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m
ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p
ON m.Id = p.MountainId
LEFT JOIN CountriesRivers AS cr
ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r
ON cr.RiverId = r.Id
GROUP BY c.CountryName
ORDER BY p.Elevation DESC, r.[Length] DESC, c.CountryName