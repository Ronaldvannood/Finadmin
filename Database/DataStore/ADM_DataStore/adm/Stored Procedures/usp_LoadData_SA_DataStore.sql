


/* 
=======================================================================================================================
Purpose:
Main procedure for loading production data. This procedure needs to be overridden by creating a hook procedure and
registering the hook in table [Config].[ProcedureHook]. If no hook is registered this procedure will raise an error.

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2014-07-01  A. Siegers                  3700        Creation
=======================================================================================================================
*/
create procedure [Adm].[usp_LoadData_SA_DataStore]
(
    @BatchDefinitionStepID int
  , @ParentBatchLogID      bigint
  , @UserName              nvarchar(256)
)
as

set nocount on;

declare @ProcedureName nvarchar(250)    = left(object_schema_name(@@procid) + '.' + object_name(@@procid), 250)
      , @Guid          uniqueidentifier = newid()
      , @Remark        nvarchar(max)
;
declare @BatchLogID              bigint
      , @IsInsteadOfHookExecuted bit
;

set @Remark = 'Start';
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;

declare @DBName sysname = db_name();
exec Adm.usp_BatchProcedureInitialize @BatchDefinitionStepID   = @BatchDefinitionStepID
                                    , @ParentBatchLogID        = @ParentBatchLogID
                                    , @DatabaseName            = @DBName
                                    , @ProgramName             = @ProcedureName
                                    , @UserName                = @UserName
                                    , @BatchLogID              = @BatchLogID out
                                    , @IsInsteadOfHookExecuted = @IsInsteadOfHookExecuted out
;
if @IsInsteadOfHookExecuted = cast(1 as bit)
begin
    set @Remark = 'Skipping standard ETL since instead-of hook was executed.';
    exec Logging.usp_LogProcess @Guid
                              , @ProcedureName
                              , @Remark;
end;
else
begin
    set @Remark = 'Executing standard ETL';
    exec Logging.usp_LogProcess @Guid
                              , @ProcedureName
                              , @Remark;

    raiserror ('No hook procedure registered for production SA load (%s). Exiting.', 11, 1, @ProcedureName);
end;

exec Adm.usp_BatchProcedureFinalize @BatchDefinitionStepID = @BatchDefinitionStepID
                                  , @BatchLogID            = @BatchLogID
                                  , @DatabaseName          = @DBName
                                  , @ProgramName           = @ProcedureName
                                  , @UserName              = @UserName
;

set @Remark = 'End';
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;