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
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC
GO

SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup
GO

SELECT AgeGroup, COUNT(AgeGroup) AS WizardCount
FROM(
SELECT 
CASE
	WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
	WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
	WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
	WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
	WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
	WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
	ELSE '[61+]'
END AS AgeGroup
FROM WizzardDeposits
) AS AgeGroups
GROUP BY AgeGroup
GO