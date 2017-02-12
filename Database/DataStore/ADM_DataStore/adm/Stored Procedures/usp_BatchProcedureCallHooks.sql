


/* 
=======================================================================================================================
Purpose:

Called by BatchProcedureInitialize and BatchProcedureFinalize at the beginning and end ETL SPs.
If ProcedureHook record(s) are present the hook procedure(s) are called.
If called from BatchProcedureInitialize then hooks with ExecuteBefore and ExecuteInsteadOf are called.
If one or more ExecuteInsteadOf hooks are present then parameter IsInsteadOfHookExecuted is set to 1.
The calling SP then should not execute any default ETL anymore.

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2014-06-13  A. Siegers                  3700        Creation
2015-03-13  A. Siegers                  11212       Added parameter @DatabaseName
=======================================================================================================================
*/
CREATE procedure [Adm].[usp_BatchProcedureCallHooks]
(
    @IsInitialize            bit -- 1 when called during initialize, 0 when called during finalize
  , @BatchDefinitionStepID   int
  , @ParentBatchLogID        bigint
  , @DatabaseName            sysname
  , @ProgramName             nvarchar(max)
  , @UserName                nvarchar(256)
  , @IsInsteadOfHookExecuted bit out
)
as

set nocount on;

declare @ProcedureName nvarchar(250)    = left(object_schema_name(@@procid) + '.' + object_name(@@procid), 250)
      , @Guid          uniqueidentifier = newid()
      , @Remark        nvarchar(max)
;
declare @IsInsteadOfHookExecutedRetVal bit = cast(0 as bit);

set @Remark = 'Start';
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;

-------------------------------------------------------------------------------------------------------------------------
---- Loop through hooks and call programs
-------------------------------------------------------------------------------------------------------------------------
declare @StandardProcedureName nvarchar(256)
      , @CustomProcedureName   nvarchar(256)
      , @ExecuteInsteadOf      bit;

set @StandardProcedureName = concat(@DatabaseName, case
    when @DatabaseName is not null
    then '.'
end, @ProgramName);

set @Remark = 'Lookup hooks for ' + @StandardProcedureName + ', IsInitialize=' + cast(@IsInitialize as nvarchar(1));
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;

declare PH_Cursor cursor static forward_only local for
        select
            PH.CustomProcedureName
          , PH.ExecuteInsteadOf
        from Config.ProcedureHook as PH
        where PH.StandardProcedureName = @StandardProcedureName
            and cast(1 as bit) = case
                                    when @IsInitialize = cast(1 as bit) -- during initialize call before and instead of hooks
                                        and (PH.ExecuteBefore = cast(1 as bit)
                                        or PH.ExecuteInsteadOf = cast(1 as bit)
                                        )
                                    then cast(1 as bit)
                                    when @IsInitialize = cast(0 as bit) -- during finalize call after hooks
                                        and PH.ExecuteAfter = cast(1 as bit)
                                    then cast(1 as bit)
                                    else cast(0 as bit)
                                end
        order by PH.OrderNumber;

open PH_Cursor;
fetch next from PH_Cursor into @CustomProcedureName, @ExecuteInsteadOf;
while @@fetch_status = 0
begin
    set @Remark = 'Execute ' + @CustomProcedureName;
    exec Logging.usp_LogProcess @Guid
                              , @ProcedureName
                              , @Remark;

    exec @CustomProcedureName @BatchDefinitionStepID = @BatchDefinitionStepID
                            , @ParentBatchLogID      = @ParentBatchLogID
                            , @UserName              = @UserName
    ;
    if @ExecuteInsteadOf = cast(1 as bit)
        set @IsInsteadOfHookExecutedRetVal = cast(1 as bit);
    fetch next from PH_Cursor into @CustomProcedureName, @ExecuteInsteadOf;
end;
close PH_Cursor;
deallocate PH_Cursor;

set @IsInsteadOfHookExecuted = @IsInsteadOfHookExecutedRetVal;

set @Remark = 'End';
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;