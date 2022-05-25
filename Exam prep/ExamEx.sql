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


SELECT Available FROM(
SELECT Available, [Status], MechanicId FROM(
SELECT CONCAT(m.FirstName, ' ', m.LastName) AS Available, m.MechanicId, j.Status
FROM Mechanics AS m
LEFT JOIN Jobs AS j
ON m.MechanicId = j.MechanicId
) Mechanics
GROUP BY Available, MechanicId, [Status]
) AS AllAvailable
WHERE 'Pending' != ANY(SELECT [Status]) AND 'In Progress' != ALL(SELECT [Status])
GO


SELECT j.JobId,
CASE
	WHEN
		SUM(op.Quantity * p.Price) IS NULL THEN 0.00
	ELSE
		SUM(op.Quantity * p.Price)
	END AS Total
FROM Jobs AS j
LEFT JOIN Orders AS o
ON o.JobId = j.JobId
LEFT JOIN OrderParts AS op
ON o.OrderId = op.OrderId
LEFT JOIN Parts AS p
ON op.PartId = p.PartId
WHERE j.[Status] = 'Finished'
GROUP BY j.JobId
ORDER BY Total DESC, JobId
GO

SELECT *  FROM (
SELECT p.PartId, p.[Description], pn.Quantity AS [Required], p.StockQty AS [In Stock], ISNULL(op.Quantity, 0) AS Ordered
FROM Jobs AS j
JOIN PartsNeeded AS pn
ON j.JobId = pn.JobId
LEFT JOIN Parts AS p
ON pn.PartId = p.PartId
LEFT JOIN Orders AS o
ON o.JobId = j.JobId
LEFT JOIN OrderParts AS op
ON p.PartId = op.PartId
WHERE j.[Status] <> 'Finished' AND (o.Delivered = 0 OR o.Delivered IS NULL) 
) AS PartsQuantity
WHERE [Required] > [In Stock] + Ordered
ORDER BY PartID
GO

CREATE PROC usp_PlaceOrder (@JobId INT, @SerialNumber VARCHAR(50), @Quantity INT)
AS
BEGIN
	DECLARE @JobCount INT = (SELECT COUNT(OrderId) FROM Jobs AS j
							LEFT JOIN Orders AS o
							ON j.JobId = o.JobId
							WHERE j.JobId = @JobId)
END
GO

CREATE FUNCTION udf_GetCost(@JobID INT)
RETURNS DECIMAL(8, 2)
BEGIN
	RETURN ISNULL((SELECT SUM(op.Quantity * Price) FROM Jobs AS j
								LEFT JOIN Orders AS o
								ON o.JobId = j.JobId
								LEFT JOIN OrderParts AS op
								ON op.OrderId = o.OrderId
								LEFT JOIN Parts AS p
								ON p.PartId = op.PartId
								WHERE j.JobId = @JobID
								GROUP BY j.JobId), 0)
END

GO