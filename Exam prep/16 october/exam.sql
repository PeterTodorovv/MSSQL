CREATE DATABASE CigarShop
USE CigarShop
GO

--1
CREATE TABLE Sizes(
Id INT PRIMARY KEY IDENTITY
,[Length] INT NOT NULL
	CHECK([Length] BETWEEN 10 AND 25)
,RingRange DECIMAL(3, 2) NOT NULL
	CHECK(RingRange BETWEEN 1.5 AND 7.5)
)

CREATE TABLE Tastes(
Id INT PRIMARY KEY IDENTITY
,TasteType VARCHAR(20) NOT NULL
,TasteStrength VARCHAR(15) NOT NULL
,ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Brands(
Id INT PRIMARY KEY IDENTITY
,BrandName VARCHAR(30) UNIQUE NOT NULL
,BrandDescription VARCHAR(MAX) 
)

CREATE TABLE Cigars(
Id INT PRIMARY KEY IDENTITY
,CigarName VARCHAR(80) NOT NULL
,BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL
,TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL
,SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL
,PriceForSingleCigar DECIMAL(10, 2) NOT NULL
,ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Addresses(
Id INT PRIMARY KEY IDENTITY
,Town VARCHAR(30) NOT NULL
,Country NVARCHAR(30) NOT NULL
,Streat NVARCHAR(100) NOT NULL
,ZIP VARCHAR(30) NOT NULL
)

CREATE TABLE Clients(
Id INT PRIMARY KEY IDENTITY
,FirstName NVARCHAR(30) NOT NULL
,LastName NVARCHAR(50) NOT NULL
,Email NVARCHAR(50) NOT NULL
,AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
)

CREATE TABLE ClientsCigars(
ClientId INT FOREIGN KEY REFERENCES Clients(id)
,CigarId INT FOREIGN KEY REFERENCES Cigars(Id)
PRIMARY KEY(ClientId, CigarId)
)
GO

--2
INSERT INTO Cigars(CigarName, BrandId, TastId, SizeId, PriceForSingleCigar, ImageURL)
VALUES
('COHIBA ROBUSTO', 9, 1, 5, 15.50, 'cohiba-robusto-stick_18.jpg')
,('COHIBA SIGLO I', 9, 1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg')
,('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50, 'hoyo-du-maire-stick_17.jpg')
,('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00, 'hoyo-de-san-juan-stick_20.jpg')
,('TRINIDAD COLONIALES', 2, 3, 8, 85.21, 'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses(Town, Country, Streat, ZIP)
VALUES
('Sofia', 'Bulgaria', '18 Bul. Vasil levski', '1000')
,('Athens', 'Greece', '4342 McDonald Avenue', '10435')
,('Zagreb', 'Croatia', '4333 Lauren Drive', '10000')
GO

--3
UPDATE Cigars
SET PriceForSingleCigar +=  PriceForSingleCigar * 0.2
WHERE TastId = 1

UPDATE Brands
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL
GO

--4
DELETE FROM Addresses
WHERE Country LIKE 'C%'
GO

--5
SELECT CigarName, PriceForSingleCigar, ImageURL FROM Cigars
ORDER BY PriceForSingleCigar, CigarName DESC
GO

--6
SELECT c.Id, c.CigarName, c.PriceForSingleCigar, t.TasteType, t.TasteStrength
FROM Cigars AS c
LEFT JOIN Tastes AS t
ON t.Id = c.TastId
WHERE t.TasteType IN ('Earthy', 'Woody')
ORDER BY PriceForSingleCigar DESC
GO

--7
SELECT c.Id, CONCAT(c.FirstName, ' ', c.LastName) AS ClientName, c.Email
FROM Clients AS c
LEFT JOIN ClientsCigars AS cc
ON cc.ClientId = c.Id
LEFT JOIN Cigars AS cg
ON cc.CigarId = cg.Id
WHERE cg.Id IS NULL
ORDER BY FirstName
GO

--8
SELECT TOP(5) c.CigarName, c.PriceForSingleCigar, c.ImageURL FROM Cigars AS c
LEFT JOIN Sizes AS s
ON c.SizeId = s.Id 
WHERE s.Length >= 12 AND (c.CigarName LIKE '%ci%' OR c.PriceForSingleCigar > 50) AND s.RingRange > 2.55
ORDER BY c.CigarName, c.PriceForSingleCigar DESC
GO

--9
SELECT FullName, Country, ZIP, CONCAT('$', MAX(PriceForSingleCigar)) AS CigarPrice 
	FROM(
	SELECT CONCAT(cl.FirstName, ' ', cl.LastName) AS FullName, a.Country, a.ZIP, cg.PriceForSingleCigar
	FROM Clients AS cl
	LEFT JOIN Addresses AS a
	ON a.Id = cl.AddressId
	LEFT JOIN ClientsCigars AS cc
	ON cc.ClientId = cl.Id
	LEFT JOIN Cigars AS cg
	ON cc.CigarId = cg.Id
	WHERE ISNUMERIC(a.zip) = 1) AS subquery
GROUP BY FullName, Country, ZIP

--10
SELECT LastName, CiagrLength, CiagrRingRange FROM(
	SELECT cl.LastName, AVG(sz.[Length]) AS CiagrLength, CEILING(AVG(sz.RingRange)) AS CiagrRingRange
	FROM Clients AS cl
	LEFT JOIN ClientsCigars AS cc
	ON cc.ClientId = cl.Id
	LEFT JOIN Cigars AS cg
	ON cc.CigarId = cg.Id
	LEFT JOIN Sizes AS sz
	ON sz.Id = cg.SizeId
	WHERE cc.CigarId IS NOT NULL
	GROUP BY cl.LastName) subquery
ORDER BY CiagrLength DESC
GO

--11
CREATE FUNCTION udf_ClientWithCigars(@name NVARCHAR(50))
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(cg.Id) FROM Clients AS cl
	LEFT JOIN ClientsCigars AS cc
	ON cc.ClientId = cl.Id
	LEFT JOIN Cigars AS cg
	ON cc.CigarId = cg.Id
	WHERE FirstName = @name
	GROUP BY cl.FirstName)
END

SELECT dbo.udf_ClientWithCigars('Rachel')
GO

--12
CREATE PROC usp_SearchByTaste(@taste VARCHAR(30))
AS
BEGIN
	SELECT c.CigarName, CONCAT('$', c.PriceForSingleCigar) AS Price, t.TasteType, b.BrandName
	,CONCAT(s.[Length], ' cm') AS CigarLength, CONCAT(s.RingRange, ' cm') AS CigarRingRange
	FROM Cigars AS c
	LEFT JOIN Tastes AS t
	ON c.TastId = t.Id
	LEFT JOIN Brands AS b
	ON b.Id = c.BrandId
	LEFT JOIN Sizes AS s
	ON c.SizeId = s.Id
	WHERE t.TasteType = @taste
	ORDER BY s.[Length], s.RingRange DESC
END