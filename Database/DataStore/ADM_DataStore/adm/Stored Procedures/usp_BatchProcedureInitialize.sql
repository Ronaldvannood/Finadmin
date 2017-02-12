


/* 
=======================================================================================================================
Purpose:

Called at the beginning of ETL SPs. It inserts a BatchLog record. The BatchLogID of the new record is returned.
Also, if ProcedureHook record(s) are present the hook procedure(s) are called.

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2014-06-13  A. Siegers                  3700        Creation
2015-03-13  A. Siegers                  11212       Added parameter @DatabaseName
=======================================================================================================================
*/
CREATE procedure [Adm].[usp_BatchProcedureInitialize]
(
    @BatchDefinitionStepID   int
  , @ParentBatchLogID        bigint
  , @DatabaseName            sysname = null
  , @ProgramName             nvarchar(max)
  , @TargetTableName         nvarchar(250) = null
  , @UserName                nvarchar(256)
  , @BatchLogID              bigint        out
  , @IsInsteadOfHookExecuted bit           out
)
as

set nocount on;

declare @ProcedureName nvarchar(250)    = left(object_schema_name(@@procid) + '.' + object_name(@@procid), 250)
      , @Guid          uniqueidentifier = newid()
      , @Remark        nvarchar(max)
;
declare @IsInsteadOfHookExecutedRetVal bit;

set @Remark = 'Start';
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;

insert into Adm.BatchLog
(
    ParentBatchLogID
  , BatchDefinitionStepID
  , StatusCode
  , StartDateTime
  , TargetTableName
  , ProgramName
  , LastUpdatedBy
  , CreatedBy
)
select
    ParentBatchLogID =      @ParentBatchLogID
  , BatchDefinitionStepID = @BatchDefinitionStepID
  , StatusCode =            'RUNNING'
  , StartDateTime =         getdate()
  , TargetTableName =       @TargetTableName
  , ProgramName =           @ProgramName
  , LastUpdatedBy =         @UserName
  , CreatedBy =             @UserName
;
set @BatchLogID = @@identity; -- detail log records need to be created as childs of this master record

exec [Adm].[usp_BatchProcedureCallHooks] @IsInitialize            = 1
                                       , @BatchDefinitionStepID   = @BatchDefinitionStepID
                                       , @ParentBatchLogID        = @BatchLogID
                                       , @DatabaseName            = @DatabaseName
                                       , @ProgramName             = @ProgramName
                                       , @UserName                = @UserName
                                       , @IsInsteadOfHookExecuted = @IsInsteadOfHookExecutedRetVal out
;

set @IsInsteadOfHookExecuted = @IsInsteadOfHookExecutedRetVal;

set @Remark = 'End';
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;