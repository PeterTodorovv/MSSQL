USE SOFTUNI

CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000 
AS
BEGIN
	SELECT FirstName, LastName
	FROM Employees
	WHERE Salary > 35000
END
GO
EXEC usp_GetEmployeesSalaryAbove35000
GO

CREATE PROC usp_GetEmployeesSalaryAboveNumber(@MinSalary DECIMAL(18,4))
AS
BEGIN
SELECT FirstName, LastName FROM Employees
WHERE Salary >= @MinSalary
END
GO
EXEC usp_GetEmployeesSalaryAboveNumber 48100
GO


CREATE PROC usp_GetTownsStartingWith 
(@StartingString VARCHAR(20))
AS
BEGIN
	SELECT [Name] FROM Towns
	WHERE [Name] LIKE @StartingString + '%'
END
GO
EXEC usp_GetTownsStartingWith 'b'
GO

CREATE PROC usp_GetEmployeesFromTown 
(@TownName VARCHAR(30))
AS
BEGIN
	SELECt FirstName, LastName FROM Employees AS e
	LEFT JOIN Addresses AS a
	ON a.AddressID = e.AddressID
	LEFT JOIN Towns AS t
	ON t.TownID = a.TownID
	WHERE @TownName = t.[Name]
END
GO
EXEC usp_GetEmployeesFromTown 'Sofia'
GO

CREATE FUNCTION ufn_GetSalaryLevel (@salary DECIMAL(18,4))
RETURNS VARCHAR(10)
AS
BEGIN
DECLARE @SalaryLevel VARCHAR(10)
	IF @salary < 30000
		BEGIN
		SET @SalaryLevel = 'Low'
		END
	ELSE IF @salary BETWEEN 30000 AND 50000 
		BEGIN 
		SET @SalaryLevel = 'Average'
		END
	ELSE
		BEGIN
		SET @SalaryLevel = 'High'
		END
	RETURN @SalaryLevel
END
GO
SELECT Salary, dbo.ufn_GetSalaryLevel(Salary) FROM Employees
GO

CREATE PROC usp_EmployeesBySalaryLevel @SalaryLevel VARCHAR(7)
AS
BEGIN
	SELECT FirstName, LastName FROM Employees
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @SalaryLevel
END
GO
EXEC usp_EmployeesBySalaryLevel 'High'
GO

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(10), @word VARCHAR(20))
RETURNS BIT
AS
BEGIN
DECLARE @CurrentIndex INT = 1
WHILE(@currentIndex <= LEN(@word))
	BEGIN
	DECLARE @currentLetter varchar(1) = SUBSTRING(@word, @currentIndex, 1)
	SET @CurrentIndex += 1
	IF CHARINDEX(@currentLetter, @setOfLetters) = 0
	RETURN 0
	END
RETURN 1
END
GO


USE Bank

CREATE PROC usp_GetHoldersFullName
AS
BEGIN
SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name] FROM AccountHolders
END
GO
EXEC usp_GetHoldersFullName
GO

CREATE PROC usp_GetHoldersWithBalanceHigherThan (@MinMoney MONEY)
AS
BEGIN
SELECT FirstName AS [First Name], LastName AS [Last Name] FROM AccountHolders AS ah
LEFT JOIN Accounts AS a
ON ah.Id = a.AccountHolderId
GROUP BY AccountHolderId, FirstName, LastName
HAVING SUM(Balance) > @MinMoney
ORDER BY FirstName, LastName
END
GO
EXEC usp_GetHoldersWithBalanceHigherThan 50000
GO


CREATE OR ALTER FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(15, 4), @yearlyInterestRate FLOAT, @years INT)
RETURNS DECIMAL(15, 4)
AS
BEGIN
	RETURN @sum * (POWER((1 + @yearlyInterestRate), @years))
END
GO
SELECT dbo.ufn_CalculateFutureValue(1000, 0.10, 5)
GO

CREATE PROC usp_CalculateFutureValueForAccount (@AccountId INT, @InterestRate FLOAT) 
AS
BEGIN
SELECT AccountHolderId, FirstName AS [First Name], LastName AS [Last Name], Balance AS [Current Balance], dbo.ufn_CalculateFutureValue(Balance, @InterestRate, 5) AS [Balance in 5 years]
FROM AccountHolders AS ah
LEFT JOIN Accounts AS a
ON ah.Id = a.AccountHolderId
WHERE a.Id = @AccountId
END
GO
EXEC usp_CalculateFutureValueForAccount 1, 0.1
GO

USE Diablo

CREATE FUNCTION ufn_CashInUsersGames (@GameName nvarchar(50))
RETURNS TABLE
AS
RETURN
SELECT SUM(Cash) AS SumCash FROM(
SELECT RowNumber % 2 AS EvenOrOdd, Cash FROM(
SELECT ROW_NUMBER() OVER(ORDER BY cash DESC) AS RowNumber, Cash FROM UsersGames AS ug
JOIN Games AS g
ON ug.GameId = g.Id AND [Name] = @GameName 
) AS NumberedCash
) AS EvenAndOddCash
GROUP BY EvenOrOdd
HAVING EvenOrOdd = 1
GO

SELECT * FROM dbo.ufn_CashInUsersGames('Love in a mist')

USE Bank

CREATE TABLE Logs(
LogId INT PRIMARY KEY IDENTITY
,AccountId INT NOT NULL
,OldSum INT NOT NULL
,NewSum INT NOT NULL
)
GO

CREATE TRIGGER tr_AddToLogsOnAccountUpdate
ON Accounts FOR UPDATE
AS
INSERT INTO Logs(AccountId, OldSum, NewSum)
SELECT a.[Id], d.Balance, a.Balance FROM Accounts AS a
JOIN deleted AS d
ON a.Id = d.Id
GO

CREATE TABLE NotificationEmails(
id INT PRIMARY KEY IDENTITY
,Recipient INT NOT NULL
,[Subject] VARCHAR(30) NOT NULL
,Body VARCHAR(100) NOT NULL
)
GO

CREATE TRIGGER tr_CreateEmail
ON Logs FOR INSERT
AS
INSERT INTO NotificationEmails(Recipient, [Subject], Body)
SELECT l.AccountId
,CONCAT('Balance change for account: ', l.AccountId)
,CONCAT('On ',FORMAT (getdate(), 'MMM dd yyyy hh:mm tt') ,' your balance was changed from ', l.OldSum,' to ', l.NewSum,'.')
FROM Logs AS l

UPDATE Accounts
SET Balance -= 100
WHERE Id < 5
GO

CREATE PROC usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN
UPDATE Accounts
SET Balance += @MoneyAmount
WHERE Id = @AccountId
END
GO

CREATE PROC usp_WithdrawMoney  (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN
UPDATE Accounts
SET Balance -= @MoneyAmount
WHERE Id = @AccountId
END
GO


CREATE PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(15, 4)) 
AS
BEGIN TRANSACTION
EXEC usp_WithdrawMoney @SenderId, @Amount
EXEC usp_DepositMoney @ReceiverId, @Amount
COMMIT
