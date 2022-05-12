USE Gringotts

SELECT COUNT(*) FROM WizzardDeposits
GO

SELECT MAX(MagicWandSize) AS LongestMagicWand
FROM WizzardDeposits
GO

SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand 
FROM WizzardDeposits
GROUP BY DepositGroup
GO

SELECT TOP(2) DepositGroup 
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize) 
GO

SELECT DepositGroup, SUM(DepositAmount) 
FROM WizzardDeposits
GROUP BY DepositGroup
GO

SELECT DepositGroup, SUM(DepositAmount)
FROM  WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
GO

SELECT DepositGroup, SUM(DepositAmount) AS 'TotalSum'
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup, DepositAmount