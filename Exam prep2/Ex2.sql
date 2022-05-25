CREATE DATABASE Airport
USE Airport

CREATE TABLE Passengers(
Id INT PRIMARY KEY IDENTITY 
,FullName VARCHAR(100) UNIQUE NOT NULL
,Email VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Pilots(
Id INT PRIMARY KEY IDENTITY 
,FirstName VARCHAR(30) UNIQUE NOT NULL
,LastName VARCHAR(30) UNIQUE NOT NULL
,Age TINYINT NOT NULL
CHECK (Age BETWEEN 21 AND 62)
,Rating DECIMAL(4, 2)
CHECK (Rating BETWEEN 0.0 AND 10.0)
)

CREATE TABLE AircraftTypes(
Id INT PRIMARY KEY IDENTITY 
,TypeName VARCHAR(30) UNIQUE NOT NULL
)

CREATE TABLE Aircraft(
Id INT PRIMARY KEY IDENTITY 
,Manufacturer VARCHAR(25) NOT NULL
,Model VARCHAR(30) NOT NULL
,[Year] INT NOT NULL
,FlightHours INT
,Condition CHAR NOT NULL
,TypeId INT FOREIGN KEY REFERENCES  AircraftTypes(Id) NOT NULL
)

CREATE TABLE PilotsAircraft(
AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id)
,PilotId INT NOT NULL FOREIGN KEY REFERENCES Pilots(Id)
PRIMARY KEY(AircraftId, PilotId)
)

CREATE TABLE Airports(
Id INT PRIMARY KEY IDENTITY 
,AirportName VARCHAR(70) UNIQUE NOT NULL
,Country VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE FlightDestinations(
Id INT PRIMARY KEY IDENTITY 
, AirportId INT NOT NULL FOREIGN KEY REFERENCES Airports(Id)
,[Start] DATETIME2 NOT NULL
,AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id)
,PassengerId INT NOT NULL FOREIGN KEY REFERENCES Passengers(Id)
,TicketPrice DECIMAL(18, 2) NOT NULL
DEFAULT 15
)
GO

INSERT INTO Passengers 
SELECT CONCAT(FirstName, ' ' ,LastName) AS FullName, CONCAT(FirstName, LastName, '@gmail.com')
FROM Pilots
WHERE Id BETWEEN 5 AND 15
GO

UPDATE Aircraft
SET Condition = 'A'
WHERE Condition IN ('B', 'C') AND (FlightHours IS NULL OR FlightHours <= 100) AND [YEAR] > 2013
GO

DELETE FROM Passengers
WHERE LEN(FullName) <= 10
GO


SELECT Manufacturer, Model, FlightHours, Condition FROM Aircraft
ORDER BY FlightHours DESC
GO

SELECT p.FirstName, p.LastName, a.Manufacturer, a.Model, a.FlightHours
FROM Pilots AS p
LEFT JOIN PilotsAircraft AS pa
ON pa.PilotId = p.Id
LEFT JOIN Aircraft AS a
ON a.Id = pa.AircraftId
WHERE FlightHours IS NOT NULL AND FlightHours < 304
ORDER BY FlightHours DESC, p.FirstName
GO

SELECT TOP(20) fd.Id, fd.[Start], p.FullName, a.AirportName, fd.TicketPrice
FROM FlightDestinations AS fd
LEFT JOIN Airports AS a
ON fd.AirportId = a.Id
LEFT JOIN Passengers AS p
ON p.Id = fd.PassengerId
WHERE DAY([Start]) % 2 = 0
ORDER BY fd.TicketPrice DESC, AirportName
GO

SELECT GroupedAircrafts.Id, a.Manufacturer, a.FlightHours, FlightDestinationsCount, AvgPrice
FROM(
	SELECT a.Id, COUNT(fd.Id) AS FlightDestinationsCount, ROUND(AVG(fd.TicketPrice), 2) AS AvgPrice
	FROM Aircraft AS a
	LEFT JOIN FlightDestinations AS fd
	ON fd.AircraftId = a.Id
	GROUP BY a.Id, a.FlightHours
	HAVING COUNT(fd.Id) >= 2) 
	AS GroupedAircrafts
LEFT JOIN Aircraft AS a
ON GroupedAircrafts.Id = a.Id
ORDER BY FlightDestinationsCount DESC, GroupedAircrafts.Id
GO

SELECT FullName, COUNT(a.Id) AS CountOfAircraft, SUM(fd.TicketPrice) AS TotalPayed
FROM Passengers AS p
LEFT JOIN FlightDestinations AS fd
ON p.Id = fd.PassengerId
LEFT JOIN Aircraft AS a
ON fd.AircraftId = a.Id
WHERE SUBSTRING(FullName, 2, 1) = 'a'
GROUP BY p.FullName
HAVING COUNT(a.Id) > 1
ORDER BY p.FullName
GO

SELECT ap.AirportName, fd.[Start] AS DayTime, fd.TicketPrice, p.FullName, ac.Manufacturer, ac.Model
FROM FlightDestinations AS fd
LEFT JOIN Airports AS ap
ON fd.AirportId = ap.Id
LEFT JOIN Aircraft AS ac
ON ac.Id = fd.AircraftId
LEFT JOIN Passengers AS p
ON p.Id = fd.PassengerId
WHERE (DATEPART(HOUR, fd.[Start]) BETWEEN 6 AND 20) AND TicketPrice > 2500
ORDER BY ac.Model
GO

CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50)) 
RETURNS INT
BEGIN
	RETURN (SELECT COUNT(fd.Id) FROM Passengers AS p
	LEFT JOIN FlightDestinations AS fd
	ON fd.PassengerId = p.Id
	WHERE p.Email = @email
	GROUP BY p.FullName)
END
GO


CREATE PROC usp_SearchByAirportName (@airportName VARCHAR(70))
AS
BEGIN
	SELECT ap.AirportName, p.FullName,
CASE
	WHEN TicketPrice <= 400 THEN 'Low'
	WHEN TicketPrice BETWEEN 401 AND 1500 THEN 'Medium' 
	ELSE 'High' 
	END AS LevelOfTickerPrice
,ac.Manufacturer, ac.Condition, [at].TypeName
FROM Airports AS ap
JOIN FlightDestinations AS fd
ON fd.AirportId = ap.Id
JOIN Passengers AS p
ON p.Id = fd.PassengerId
JOIN Aircraft AS ac
ON ac.Id = fd.AircraftId
JOIN AircraftTypes AS [at]
ON [at].Id = ac.TypeId
WHERE @airportName = ap.AirportName
ORDER BY ac.Manufacturer, p.FullName
END

EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'