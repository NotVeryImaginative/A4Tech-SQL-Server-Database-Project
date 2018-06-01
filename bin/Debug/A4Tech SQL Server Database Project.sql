﻿/*
Deployment script for A4Tech SQL Server Database Project

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "A4Tech SQL Server Database Project"
:setvar DefaultFilePrefix "A4Tech SQL Server Database Project"
:setvar DefaultDataPath "C:\Users\m.simionidi\AppData\Local\Microsoft\VisualStudio\SSDT\A4Tech SQL Server Database Project"
:setvar DefaultLogPath "C:\Users\m.simionidi\AppData\Local\Microsoft\VisualStudio\SSDT\A4Tech SQL Server Database Project"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Altering [dbo].[vw_employee_job_information]...';


GO



ALTER VIEW [dbo].[vw_employee_job_information] AS

SELECT 
	DWH.DimEmployee.BusinessEntityID AS PersonID,
	FirstName, 
	LastName,
	JobTitle,
	FactMoney AS Salary,
	CASE WHEN DWH.FactTable.IdDimDate = MAX(IdDimDate)OVER(PARTITION BY DWH.DimEmployee.BusinessEntityID) THEN 'Present' ELSE 'Past' END AS CurrentJob,
	DWH.FactTable.IdDimDate
FROM	DWH.FactTable
INNER JOIN DWH.DimEmployee
	ON	DWH.DimEmployee.IdDimEmployee = DWH.FactTable.IdDimEmployee
INNER JOIN DWH.DimJobs
	ON	DWH.DimJobs.IdDimJobs = DWH.FactTable.IdDimJobs
INNER JOIN DWH.DimDate
	ON DWH.DimDate.DateKey = DWH.FactTable.IdDimDate
WHERE DWH.DimEmployee.BusinessEntityID IN 
(
SELECT
	BusinessEntityID
FROM	DWH.FactTable
INNER JOIN DWH.DimEmployee
	ON	DWH.DimEmployee.IdDimEmployee = DWH.FactTable.IdDimEmployee
INNER JOIN DWH.DimJobs
	ON	DWH.DimJobs.IdDimJobs = DWH.FactTable.IdDimJobs
GROUP BY DWH.DimEmployee.BusinessEntityID
HAVING COUNT(DWH.FactTable.IdDimDate) >= 2
)
GO
PRINT N'Altering [dbo].[DimJobs_UDP]...';


GO
ALTER PROCEDURE [dbo].[DimJobs_UDP] AS

TRUNCATE TABLE DWH.DimJobs

INSERT INTO DWH.DimJobs
(
	JobTitle
)
	SELECT DISTINCT
		SGT.view_StagingTable.JobTitle
	FROM	SGT.view_StagingTable
	ORDER BY SGT.view_StagingTable.JobTitle
GO
PRINT N'Update complete.';


GO
