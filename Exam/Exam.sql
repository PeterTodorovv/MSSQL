CREATE DATABASE Zoo

USE Zoo

CREATE TABLE Owners(
Id INT PRIMARY KEY IDENTITY
,[Name] VARCHAR(50) NOT NULL
,PhoneNumber VARCHAR(15) NOT NULL
,[Address] VARCHAR(50)
)

CREATE TABLE AnimalTypes(
Id INT PRIMARY KEY IDENTITY
,AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages(
Id INT PRIMARY KEY IDENTITY
,AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE Animals(
Id INT PRIMARY KEY IDENTITY
,[Name] VARCHAR(30) NOT NULL
,BirthDate DATE NOT NULL
,OwnerId INT FOREIGN KEY REFERENCES Owners(Id)
,AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE AnimalsCages(
CageId INT FOREIGN KEY REFERENCES Cages(Id) NOT NULL
,AnimalId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
PRIMARY KEY(CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments(
Id INT PRIMARY KEY IDENTITY
,DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers(
Id INT PRIMARY KEY IDENTITY
,[Name] VARCHAR(50) NOT NULL
,PhoneNumber VARCHAR(15) NOT NULL
,[Address] VARCHAR(50)
,AnimalId INT FOREIGN KEY REFERENCES Animals(Id)
,DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
)
GO

INSERT INTO Volunteers([Name], PhoneNumber, [Address], AnimalId, DepartmentId)
VALUES
('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1)
,('Dimitur Stoev', '0877564223', NULL, 42, 4)
,('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7)
,('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8)
,('Boryana Mileva', '0888112233', NULL, 31, 5)

INSERT INTO Animals([Name], BirthDate, OwnerId, AnimalTypeId)
VALUES
('Giraffe', '2018-09-21', 21, 1)
,('Harpy Eagle', '2015-04-17', 15, 3)
,('Hamadryas Baboon', '2017-11-02', NULL, 1)
,('Tuatara', '2021-06-30', 2, 4)
GO


--4
UPDATE Animals
SET OwnerId = 4
WHERE OwnerId IS NULL
GO

SELECT [Name], PhoneNumber, Address, AnimalId, DepartmentId 
FROM Volunteers
ORDER BY [Name], AnimalId, DepartmentId
GO


SELECT a.[Name], at.AnimalType, convert(varchar, a.BirthDate, 104) AS BirthDate
FROM Animals AS a
LEFT JOIN AnimalTypes AS [at]
ON at.Id = a.AnimalTypeId
ORDER BY a.[Name]
GO


SELECT TOP(5) o.[Name] AS [Owner], COUNT(a.Id) AS CountOfAnimals
FROM Owners AS o
LEFT JOIN Animals AS a
ON a.OwnerId = o.Id
GROUP BY o.[Name]
ORDER BY CountOfAnimals DESC, o.[Name]
GO

SELECT CONCAT(o.[Name], '-', a.[Name]) AS OwnersAnimals, o.PhoneNumber, ac.CageId AS CageId
FROM Owners AS o
LEFT JOIN Animals AS a
ON a.OwnerId = o.Id
LEFT JOIN AnimalsCages AS ac
ON ac.AnimalId = a.Id
WHERE a.AnimalTypeId = 1
ORDER BY o.[Name], a.[Name] DESC
GO

SELECT * FROM AnimalTypes

SELECT v.[Name], v.PhoneNumber,  RIGHT([Address], LEN([Address]) - CHARINDEX(',', [Address]) - 1) AS Address
FROM Volunteers AS v
WHERE v.DepartmentId = 2 AND v.[Address] LIKE '%Sofia%'
ORDER BY v.[Name] 
GO

SELECT a.[Name], YEAR(BirthDate) AS BirthYear, [at].AnimalType FROM Animals AS a
LEFT JOIN AnimalTypes AS [at]
ON [at].Id = a.AnimalTypeId
WHERE a.OwnerId IS NULL AND [at].AnimalType != 'Birds' AND DATEDIFF(YEAR, a.BirthDate, '01/01/2022') < 5
ORDER BY a.[Name]
GO

CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30))
RETURNS INT
BEGIN
	RETURN (SELECT COUNT(v.Id) FROM VolunteersDepartments AS vd
	LEFT JOIN Volunteers AS v
	ON v.DepartmentId = vd.Id
	WHERE vd.DepartmentName = @VolunteersDepartment
	GROUP BY vd.DepartmentName)
END

SELECT dbo.udf_GetVolunteersCountFromADepartment ('Zoo events')
GO

CREATE PROC usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS
BEGIN
	SELECT a.[Name], 
		CASE
		WHEN a.OwnerId IS NULL THEN 'For adoption'
		ELSE o.[Name]
		END AS OwnersName
	FROM Animals AS a
	LEFT JOIN Owners AS o
	ON o.Id = a.OwnerId
	WHERE a.[Name] = @AnimalName
END
GO

DELETE FROM Volunteers
WHERE DepartmentId IN 
(SELECT DepartmentId FROM VolunteersDepartments
WHERE DepartmentName = 'Education program assistant')

DELETE FROM VolunteersDepartments
WHERE DepartmentName = 'Education program assistant'