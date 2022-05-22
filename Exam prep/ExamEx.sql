CREATE DATABASE WMS
GO
USE WMS

CREATE TABLE Models(
ModelId INT PRIMARY KEY IDENTITY
,[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Mechanics(
MechanicId INT PRIMARY KEY IDENTITY
,FirstName VARCHAR(50) NOT NULL
,LastName VARCHAR(50) NOT NULL
,[Address] VARCHAR(255) NOT NULL
)


CREATE TABLE Clients(
ClientId INT PRIMARY KEY IDENTITY
,FirstName VARCHAR(50) NOT NULL
,LastName VARCHAR(50) NOT NULL
,Phone CHAR(12) UNIQUE NOT NULL
CHECK(LEN(Phone) = 12)
)


CREATE TABLE Jobs(
JobId INT PRIMARY KEY IDENTITY
,ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL
,[Status] VARCHAR(11) NOT NULL
DEFAULT 'Pending'
CHECK([Status] IN ('Pending', 'In Progress', 'Finished'))
,ClientId INT FOREIGN KEY REFERENCES  Clients(ClientId) NOT NULL
,MechanicId INT  FOREIGN KEY REFERENCES  Mechanics(MechanicId)
,IssueDate DATE NOT NULL
,FinishDate Date
)

CREATE TABLE Vendors(
VendorId INT PRIMARY KEY IDENTITY
,[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts(
PartId INT PRIMARY KEY IDENTITY
,SerialNumber VARCHAR(50) UNIQUE NOT NULL
,[Description] VARCHAR(255) 
,Price DECIMAL(6, 2) NOT NULL
CHECK (Price < 9999.99 AND Price > 0)
,VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL
,StockQty INT NOT NULL
DEFAULT 0
CHECK (StockQty >= 0)
)

CREATE TABLE PartsNeeded(
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL
,PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL
PRIMARY KEY(JobId, PartId)
,Quantity INT NOT NULL
DEFAULT 1
CHECK (Quantity > 0)
)

CREATE TABLE Orders(
OrderId INT PRIMARY KEY IDENTITY
,JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL
,IssueDate DATE 
,Delivered BIT NOT NULL
DEFAULT 0
)

CREATE TABLE OrderParts(
OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL
,PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL
PRIMARY KEY(OrderId, PartId)
,Quantity INT NOT NULL
DEFAULT 1
CHECK (Quantity > 0)
)
GO

INSERT INTO Clients(FirstName, LastName, Phone)
VALUES
('Teri', 'Ennaco', '570-889-5187')
,('Merlyn', 'Lawler', '201-588-7810')
,('Georgene', 'Montezuma', '925-615-5185')
,('Jettie', 'Mconnell', '908-802-3564')
,('Lemuel', 'Latzke', '631-748-6479')
,('Melodie', 'Knipp', '805-690-1682')
,('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts(SerialNumber,	[Description], Price, VendorId)
VALUES
('WP8182119', 'Door Boot Seal', 117.86, 2)
,('W10780048', 'Suspension Rod', 42.81, 1)
,('W10841140', 'Silicone Adhesive ', 6.77, 4)
,('WPY055980', 'High Temperature Adhesive', 13.94, 3)
GO

UPDATE Jobs
SET MechanicId = 3
WHERE [Status] = 'Pending'

UPDATE Jobs
SET [Status] = 'In Progress'
WHERE MechanicId = 3 AND [Status] = 'Pending'
GO

DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
WHERE OrderId = 19
GO

SELECT CONCAT(m.FirstName, ' ', m.LastName), [Status],  j.IssueDate FROM Jobs AS j
LEFT JOIN Mechanics AS m
ON j.MechanicId = m.MechanicId
Order by m.MechanicId, j.IssueDate, JobId 
GO

SELECT CONCAT(c.FirstName, ' ', c.LastName) AS Client, (DAY('2017-04-24') - DAY(j.IssueDate)) AS [Days going], j.[Status]
FROM Clients AS c
JOIN Jobs AS j
ON c.ClientId = j.ClientId
WHERE j.[Status] != 'Finished'
ORDER BY[Days going] DESC, c.ClientId
GO

SELECT Mechanic, AVG(DaysNeeded) AS [Average Days]
FROM(
SELECT CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic, DATEDIFF(DAY, j.IssueDate, j.FinishDate) AS DaysNeeded, m.MechanicId
FROM Mechanics AS m
JOIN Jobs AS j
ON m.MechanicId = j.MechanicId AND [Status] = 'Finished'
) Mechanics
GROUP BY Mechanic, MechanicId
ORDER BY MechanicId
GO

SELECT * FROM(
SELECT CONCAT(m.FirstName, ' ', m.LastName) AS Available, [Status]
FROM Mechanics AS m
JOIN Jobs AS j
ON m.MechanicId = j.MechanicId
) Mechanics
GROUP BY Available
HAVING COUNT([Status] = 'Pending') = 0 AND COUNT([Status] = 'Pending') = 0
