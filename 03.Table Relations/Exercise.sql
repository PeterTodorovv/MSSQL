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



