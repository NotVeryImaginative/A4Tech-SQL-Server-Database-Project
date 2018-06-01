﻿CREATE PROCEDURE [dbo].[FactTable_UDP] AS

TRUNCATE TABLE DWH.FactTable

INSERT INTO DWH.FactTable
(
IdDimEmployee,
IdDimJobs,
IdDimDate,
FactMoney
)
SELECT IdDimEmployee, IdDimJobs, DWH.DimDate.DateKey AS IdDimDate, Salary
FROM SGT.view_StagingTable
INNER JOIN DWH.DimJobs
	ON SGT.view_StagingTable.JobTitle = DWH.DimJobs.JobTitle
INNER JOIN DWH.DimDate
	ON DWH.DimDate.[Date] = SGT.view_StagingTable.EmployeeModifiedDate
INNER JOIN DWH.DimEmployee
	ON DWH.DimEmployee.BusinessEntityID = SGT.view_StagingTable.BusinessEntityID AND SGT.view_StagingTable.PersonModifiedDate = DWH.DimEmployee.StartDate
ORDER BY IdDimEmployee, IdDimJobs