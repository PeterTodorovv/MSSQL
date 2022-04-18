USE SoftUni
GO

SELECT * FROM Departments
GO

SELECT Name FROM Departments
GO

SELECT FirstName, LastName, Salary FROM Employees
GO

SELECT FirstName, MiddleName, LastName FROM Employees
GO

SELECT FirstName + '.' + LastName + '@softuni.bg' AS 'Full Email Address'
FROM Employees
GO

SELECT DISTINCT Salary FROM Employees
GO

SELECT * FROM Employees WHERE JobTitle = 'Sales Representative'
GO

SELECT FirstName, LastName, JobTitle FROM Employees
WHERE Salary BETWEEN 20000 AND 30000
GO

SELECT FirstName +' ' + MiddleName + ' '  + LastName AS 'Full Name'
FROM Employees
WHERE Salary IN (25000, 14000, 12500, 23600)
GO

SELECT FirstName, LastName FROM Employees
WHERE ManagerID IS NULL
GO

SELECT FirstName, LastName, Salary FROM Employees
WHERE Salary > 50000
ORDER BY Salary DESC