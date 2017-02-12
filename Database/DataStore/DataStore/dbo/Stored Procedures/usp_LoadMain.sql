



/* 
=======================================================================================================================
Purpose:
Main procedure for loading data.

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2014-11-17  A. Siegers                  8423        Creation
=======================================================================================================================
*/
create procedure [dbo].[usp_LoadMain]
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
      , @LoadDate      datetime
;
declare @BatchLogID              bigint
      , @IsInsteadOfHookExecuted bit
;

set @Remark = 'Start';
exec ADM_DataStore.Logging.usp_LogProcess @Guid
                                        , @ProcedureName
                                        , @Remark;

declare @DBName sysname = db_name();
exec ADM_DataStore.Adm.usp_BatchProcedureInitialize @BatchDefinitionStepID   = @BatchDefinitionStepID
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
    exec ADM_DataStore.Logging.usp_LogProcess @Guid
                                            , @ProcedureName
                                            , @Remark;
end;
else
begin
    set @Remark = 'Executing standard ETL';
    exec ADM_DataStore.Logging.usp_LogProcess @Guid
                                            , @ProcedureName
                                            , @Remark;

    set @LoadDate = getdate();
-----------------------------------------------------------------------------------------------------------------------
-- Start
-----------------------------------------------------------------------------------------------------------------------

begin try

    set @Remark = 'Load Production tables';
    exec ADM_DataStore.Logging.usp_LogProcess @Guid
                                            , @ProcedureName
                                            , @Remark
    ;

    -----------------------------------------------------------------------------------------------------------------------
    --  Load tables
    -----------------------------------------------------------------------------------------------------------------------



    -----------------------------------------------------------------------------------------------------------------------
    -- Geef transaction log diskruimte vrij
    -----------------------------------------------------------------------------------------------------------------------
    dbcc shrinkdatabase (SA_DataStore, 0, truncateonly);


end try
begin catch
    /* Rethrow error */
    declare @ErrorSeverity        int            = error_severity()
          , @ErrorState           int            = error_state()
          , @OriginalErrorMessage nvarchar(2048) = error_message()
    ;
    set @Remark = left(concat(N'Error ', error_number()
    , N', Level ', @ErrorSeverity
    , N', State ', @ErrorState
    , N', Procedure ', isnull(error_procedure(), N'<unknown>')
    , N', Line ', error_line()
    , N', Message: ', @OriginalErrorMessage)
    , 4000);

    exec ADM_DataStore.Logging.usp_LogProcess @Guid
                                            , @ProcedureName
                                            , @Remark
    ;
    throw;

end catch;

end;

-----------------------------------------------------------------------------------------------------------------------
--  End
-----------------------------------------------------------------------------------------------------------------------
exec ADM_DataStore.Adm.usp_BatchProcedureFinalize @BatchDefinitionStepID = @BatchDefinitionStepID
                                                , @BatchLogID            = @BatchLogID
                                                , @DatabaseName          = @DBName
                                                , @ProgramName           = @ProcedureName
                                                , @UserName              = @UserName;

set @Remark = 'End';
exec ADM_DataStore.Logging.usp_LogProcess @Guid
                                        , @ProcedureName
                                        , @Remark;