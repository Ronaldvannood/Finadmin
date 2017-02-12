


/* 
=======================================================================================================================
Purpose:

Start an SSIS package.

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2015-02-12  B. Kooij                    3700        Creation
2015-11-26  E. Weber                   19752        Niet alleen de errors met een message_source_type = 60 (dataflow task) en status 4 (failed)
                                                    uitvragen, maar alle types en statussen voor event_name = 'OnError'.
=======================================================================================================================
*/
CREATE procedure [Adm].[usp_StartSSISpackage]
(
    @BatchDefinitionStepID int
  , @ParentBatchLogID      bigint
  , @UserName    nvarchar(256)
  , @ProgramName nvarchar(max)
)
as

set nocount on;

declare @ProcedureName nvarchar(250)    = left(object_schema_name(@@procid) + '.' + object_name(@@procid), 250)
      , @Guid          uniqueidentifier = newid()
      , @Remark        nvarchar(max)
;
declare @executionid       bigint
      , @SSISProjectName   nvarchar(255)
      , @SSISPackageName   nvarchar(max)
      , @SeparatorPosition int
      , @Referenceid       int
      , @Status            int
      , @Message           nvarchar(max)
;

set @Remark = 'Start';
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;

declare @BatchLogID bigint;

exec Adm.usp_BatchProcedureInitialize @BatchDefinitionStepID   = @BatchDefinitionStepID
                                    , @ParentBatchLogID        = @ParentBatchLogID
                                    , @ProgramName             = @ProcedureName
                                    , @UserName                = @UserName
                                    , @BatchLogID              = @BatchLogID out
                                    , @IsInsteadOfHookExecuted = null
;

set @SSISPackageName = Config.fnc_GetConfigurationParameterValueChar(@ProgramName);

if @SSISPackageName is null
begin
    set @Remark = 'No ' + @ProgramName + ' parameter value present. Skipping SSIS batch step.';
    exec Logging.usp_LogProcess @Guid
                              , @ProcedureName
                              , @Remark;
end;
else
begin

    -- Set variables
    set @SeparatorPosition = charindex('\', @SSISPackageName);
    set @SSISProjectName = substring(@SSISPackageName, 1, @SeparatorPosition - 1);
    set @SSISPackageName = substring(@SSISPackageName, @SeparatorPosition + 1, len(@SSISPackageName));
    
    -- select Referenceid
    select
             @Referenceid = reference_id
    from SSISDB.[catalog].environment_references as env
	inner join SSISDB.[catalog].projects as proj
	on env.project_id = proj.project_id
    where environment_name = 'CloudBI'
	and proj.Name = @SSISProjectName;

    -- Create execution and execute
    exec SSISDB.[catalog].create_execution @package_name    = @SSISPackageName
                                             , @execution_id    = @executionid output
                                             , @folder_name     = N'CloudBI'
                                             , @project_name    = @SSISProjectName
                                             , @use32bitruntime = true
                                             , @reference_id    = @Referenceid;

    -- turn on synchronized execution
    exec SSISDB.[catalog].set_execution_parameter_value @execution_id = @executionid
                                                          , @object_type     = 50   -- Execution Setting
                                                          , @parameter_name  = N'SYNCHRONIZED'
                                                          , @parameter_value = 1; 

    -- Start Execution
    exec SSISDB.[catalog].start_execution @executionid;

    -- Get Error Message
    -- Overzicht van de mogelijke waarden van catalog.event_messages.message_source_type
    -- 10 Entry APIs, such as T-SQL and CLR Stored procedures
    -- 20 External process used to run package (ISServerExec.exe)
    -- 30 Package-level objects
    -- 40 Control Flow tasks
    -- 50 Control Flow containers
    -- 60 Data Flow task
 
    -- Overzicht van de mogelijke waarden van catalog.executions.status
    -- 1 Created, 2 running, 3 canceled, 4 failed, 5 pending, 6 ended unexpectedly, 7 succeeded, 8 stopping, 9 completed

    select
        @Message = M.[message]
    from SSISDB.[catalog].executions E
    inner join SSISDB.[catalog].event_messages M
        on E.execution_id = M.operation_id
    where E.execution_id = @executionid
        and event_name = 'OnError'
    ;
    if @@rowcount > 0
        raiserror (@Message, 11, 1, @ProgramName);

end;


exec Adm.usp_BatchProcedureFinalize @BatchDefinitionStepID = @BatchDefinitionStepID
                                  , @BatchLogID            = @BatchLogID
                                  , @ProgramName           = @ProcedureName
                                  , @UserName              = @UserName
;

set @Remark = 'End'
;
exec Logging.usp_LogProcess @Guid
                          , @ProcedureName
                          , @Remark;