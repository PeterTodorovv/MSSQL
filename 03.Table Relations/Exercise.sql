CREATE DATABASE TableRelations
GO

USE TableRelations

 CREATE TABLE Passports(
 PassportID INT PRIMARY KEY
,PassportNumber CHAR(8) NOT NULL
)
GO

 CREATE TABLE Persons (
 PersonID INT PRIMARY KEY IDENTITY
,FirstName VARCHAR(15) NOT NULL
,Salary DECIMAL(9, 2) NOT NULL
,PassportID INT FOREIGN
 KEY REFERENCES Passports (PassportID)
UNIQUE NOT NULL 
)
GO


CREATE TABLE Manufacturers (
ManufacturerID INT PRIMARY KEY IDENTITY
,[Name] VARCHAR(15) NOT NULL
,EstablishedOn DATE NOT NULL
)

CREATE TABLE Models(
 ModelID INT PRIMARY KEY IDENTITY(101, 1)
,[Name] VARCHAR(30) NOT NULL
,ManufacturerID INT FOREIGN KEY
REFERENCES Manufacturers (ManufacturerID)
)

INSERT INTO Manufacturers ([Name], EstablishedOn)
VALUES 
 ('BMW', '07/03/1916')
,('Tesla', '01/01/2003')
,('Lada', '01/05/1966')

INSERT INTO Models ([Name], ManufacturerID)
VALUES 
('X1', 1)
,('i6', 1)
,('Model S', 2)
,('Model X', 2)
,('Model 3', 2)
,('Nova', 3)
GO



CREATE TABLE Students(
 StudentID INT PRIMARY KEY IDENTITY
,[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Exams(
 ExamID INT PRIMARY KEY IDENTITY(101, 1)
,[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE StudentsExams(
StudentID INT FOREIGN KEY REFERENCES Students (StudentID)
,ExamID INT FOREIGN KEY REFERENCES  Exams (ExamID)
PRIMARY KEY (StudentID, ExamID)
)

INSERT INTO Students ([Name])
VALUES
('Mila')
,('Toni')
,('Ron')

INSERT INTO Exams ([Name])
VALUES
('SpringMVC')
,('Neo4j')
,('Oracle 11g')


INSERT INTO StudentsExams
VALUES
(1, 101)
,(1, 102)
,(2, 101)
,(3, 103)
,(2, 102)
,(2, 103)

GO

