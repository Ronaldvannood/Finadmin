/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

merge into adm.BatchDefinition as Target
using (values
(N'LoadData_SA_DataStore', N'', cast(0 as bit), system_user, getdate(), system_user, getdate())
)
as Source (BatchDefinitionCode, BatchDefinitionDescription, IsDeleted, LastUpdatedBy, LastUpdateDate, CreatedBy, CreationDate)
on Target.BatchDefinitionCode = Source.BatchDefinitionCode
-- update matched rows 
when matched then
update
set BatchDefinitionDescription = Source.BatchDefinitionDescription
, IsDeleted = Source.IsDeleted
, LastUpdatedBy = Source.LastUpdatedBy
, LastUpdateDate = Source.LastUpdateDate
-- insert new rows 
when not matched by Target then
insert (BatchDefinitionCode, BatchDefinitionDescription, IsDeleted, LastUpdatedBy, LastUpdateDate, CreatedBy, CreationDate)
values (BatchDefinitionCode, BatchDefinitionDescription, IsDeleted, LastUpdatedBy, LastUpdateDate, CreatedBy, CreationDate)
-- delete rows that are in the target but not the source 
when not matched by Source then
delete;


merge into adm.BatchDefinitionStep as Target
using (values
(1, 10, N'TSQL', N'Adm.usp_LoadData_SA_DataStore', N'', cast(0 as bit), system_user, getdate(), system_user, getdate())
)
as Source (BatchDefinitionID, BatchDefinitionStepOrderNumber, ProgramTypeCode, ProgramName, BatchDefinitionStepDescription, IsDeleted, LastUpdatedBy, LastUpdateDate, CreatedBy, CreationDate)
on Target.BatchDefinitionID = Source.BatchDefinitionID
and Target.ProgramName = Source.ProgramName
-- update matched rows 
when matched then
update
set BatchDefinitionStepOrderNumber = Source.BatchDefinitionStepOrderNumber
, ProgramTypeCode = Source.ProgramTypeCode
, BatchDefinitionStepDescription = Source.BatchDefinitionStepDescription
, IsDeleted = Source.IsDeleted
, LastUpdatedBy = system_user
, LastUpdateDate = getdate()
-- insert new rows 
when not matched by Target then
insert (BatchDefinitionID, BatchDefinitionStepOrderNumber, ProgramTypeCode, ProgramName, BatchDefinitionStepDescription, IsDeleted, LastUpdatedBy, LastUpdateDate, CreatedBy, CreationDate)
values (BatchDefinitionID, BatchDefinitionStepOrderNumber, ProgramTypeCode, ProgramName, BatchDefinitionStepDescription, IsDeleted, LastUpdatedBy, LastUpdateDate, CreatedBy, CreationDate)
-- delete rows that are in the target but not the source 
when not matched by Source then
delete;

merge into Config.ProcedureHook as Target
using (values
(N'ADM_DataStore.Adm.usp_LoadData_SA_DataStore', 1, 0, 0, 1, N'SA_DataStore.dbo.usp_LoadMain', system_user, getdate(), system_user, getdate())
)
as Source (StandardProcedureName, OrderNumber, ExecuteBefore, ExecuteAfter, ExecuteInsteadOf, CustomProcedureName, LastUpdatedBy, LastUpdateDate, CreatedBy, CreationDate)
on Target.StandardProcedureName = Source.StandardProcedureName
and Target.CustomProcedureName = Source.CustomProcedureName
-- update matched rows 
when matched then
update
set OrderNumber = Source.OrderNumber
, ExecuteBefore = Source.ExecuteBefore
, ExecuteAfter = Source.ExecuteAfter
, ExecuteInsteadOf = Source.ExecuteInsteadOf
, LastUpdatedBy = system_user
, LastUpdateDate = getdate()
-- insert new rows 
when not matched by Target then
insert (StandardProcedureName, OrderNumber, ExecuteBefore, ExecuteAfter, ExecuteInsteadOf, CustomProcedureName, LastUpdatedBy, LastUpdateDate, CreatedBy, CreationDate)
values (StandardProcedureName, OrderNumber, ExecuteBefore, ExecuteAfter, ExecuteInsteadOf, CustomProcedureName, LastUpdatedBy, LastUpdateDate, CreatedBy, CreationDate)
-- delete rows that are in the target but not the source 
when not matched by Source then
delete;