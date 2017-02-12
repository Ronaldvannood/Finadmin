



/* 
=======================================================================================================================
Purpose:

Called at the end of ETL SPs.
If ProcedureHook record(s) are present the hook procedure(s) are called.
It then updates the BatchLog record.

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2014-06-13  A. Siegers                  3700        Creation
2015-03-13  A. Siegers                  11212       Added parameter @DatabaseName
=======================================================================================================================
*/
CREATE procedure [Adm].[usp_BatchProcedureFinalize]
(
    @BatchDefinitionStepID int
  , @BatchLogID            bigint
  , @DatabaseName          sysname = null
  , @ProgramName           nvarchar(max)
  , @UserName              nvarchar(256)
  , @NumberOfRowsInserted  bigint = null
  , @NumberOfRowsUpdated   bigint = null
  , @NumberOfRowsDeleted   bigint = null
)
as

set nocount on;

declare @ProcedureName nvarchar(250)    = left(object_schema_name(@@procid) + '.' + object_name(@@procid), 250)
      , @Guid          uniqueidentifier = newid()
      , @Remark        nvarchar(max)
;
declare @IsInsteadOfHookExecutedDummy bit;

set @Remark = 'Start';
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;

exec [Adm].[usp_BatchProcedureCallHooks] @IsInitialize            = 0
                                       , @BatchDefinitionStepID   = @BatchDefinitionStepID
                                       , @ParentBatchLogID        = @BatchLogID
                                       , @DatabaseName            = @DatabaseName
                                       , @ProgramName             = @ProgramName
                                       , @UserName                = @UserName
                                       , @IsInsteadOfHookExecuted = @IsInsteadOfHookExecutedDummy out -- N/A for ExecuteAfter hooks
;

update BL
set BL.StatusCode           = 'COMPLETED'
  , BL.EndDateTime          = getdate()
  , BL.NumberOfRowsInserted = @NumberOfRowsInserted
  , BL.NumberOfRowsUpdated  = @NumberOfRowsUpdated
  , BL.NumberOfRowsDeleted  = @NumberOfRowsDeleted
  , BL.LastUpdatedBy        = @UserName
  , BL.LastUpdateDate       = getdate()
from Adm.BatchLog as BL
where BL.BatchLogID = @BatchLogID
;

set @Remark = 'End';
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;