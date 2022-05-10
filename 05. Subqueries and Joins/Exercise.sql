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

SELECT MIN(Salary) AS MinAverageSalary FROM Employees