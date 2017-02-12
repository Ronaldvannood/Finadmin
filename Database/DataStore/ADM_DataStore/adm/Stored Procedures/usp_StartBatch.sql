
/* 
=======================================================================================================================
Purpose:
Start an ETL batch process. Can be called manually or automatically from sql agent (when batch was scheduled).

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2017-02-12  R.van Nood                              Creation
=======================================================================================================================
*/
create procedure [Adm].[usp_StartBatch]
(
    @BatchDefinitionCode nvarchar(50)
  , @UserName            nvarchar(256) = null
)
as

set nocount on;

declare @ProcedureName nvarchar(250)    = left(object_schema_name(@@procid) + '.' + object_name(@@procid), 250)
      , @Guid          uniqueidentifier = newid()
      , @Remark        nvarchar(max)
;

declare @BatchExecutionID    bigint
      , @BatchLogID          bigint
      , @BatchLockAcquired   int
      , @Bit_0               bit = 0
      , @Bit_1               bit = 1
      , @BatchLockIdentifier bit;

declare @ReleaseBatchLockOnError bit = iif(@BatchLockIdentifier is not null, @Bit_0, @Bit_1);

-----------------------------------------------------------------------------------------------------------------------
-- Start
-----------------------------------------------------------------------------------------------------------------------

begin try
    set @Remark = 'Start';
    exec Logging.usp_LogProcess @Guid
                              , @ProcedureName
                              , @Remark;

    set @UserName = isnull(@UserName, system_user);

    declare @BatchDefinitionID int =
    (
        select
            BD.BatchDefinitionID
        from Adm.BatchDefinition as BD
        where BD.BatchDefinitionCode = @BatchDefinitionCode
            and BD.IsDeleted = @Bit_0
    );
    if @BatchDefinitionID is null -- not found
    begin
        raiserror ('Batch definition code %s not found. Exiting.', 11, 1, @BatchDefinitionCode);
    end;

    insert into Adm.BatchExecution
    (
        BatchDefinitionID
      , StatusCode
      , StartDateTime
      , LastUpdatedBy
      , CreatedBy
    )
    select
        BatchDefinitionID = @BatchDefinitionID
      , StatusCode =        'RUNNING'
      , StartDateTime =     getdate()
      , LastUpdatedBy =     @UserName
      , CreatedBy =         @UserName
    ;
    set @BatchExecutionID = @@identity;


    -----------------------------------------------------------------------------------------------------------------------
    -- Loop through batch steps and call programs
    -----------------------------------------------------------------------------------------------------------------------
    declare @BatchDefinitionStepID          int
          , @ProgramTypeCode                nvarchar(50)
          , @ProgramName                    nvarchar(max)
          , @BatchDefinitionStepDescription nvarchar(250);

    declare BDS_Cursor cursor static forward_only local for
            select
                BDS.BatchDefinitionStepID
              , BDS.ProgramTypeCode
              , BDS.ProgramName
              , BDS.BatchDefinitionStepDescription
            from Adm.BatchDefinitionStep as BDS
            where BDS.BatchDefinitionID = @BatchDefinitionID
                and BDS.IsDeleted = cast(0 as bit)
            order by BDS.BatchDefinitionStepOrderNumber;
    declare @IsFirstStep bit = cast(1 as bit);

    open BDS_Cursor;
    fetch next from BDS_Cursor into @BatchDefinitionStepID, @ProgramTypeCode, @ProgramName, @BatchDefinitionStepDescription;

    while @@fetch_status = 0
    begin
        set @Remark = @ProcedureName + ': Execute ' + @ProgramName + ' (' + @ProgramTypeCode + ')';
        exec Logging.usp_LogProcess @Guid
                                  , @ProcedureName
                                  , @Remark;
        insert into Adm.BatchLog
        (
            BatchDefinitionStepID
          , StatusCode
          , StartDateTime
          , ProgramName
          , LastUpdatedBy
          , CreatedBy
        )
        select
            BatchDefinitionStepID = @BatchDefinitionStepID
          , StatusCode =            'RUNNING'
          , StartDateTime =         getdate()
          , ProgramName =           @Remark
          , LastUpdatedBy =         @UserName
          , CreatedBy =             @UserName
        ;
        set @BatchLogID = @@identity; -- detail log records need to be created as childs of this master record

        -----------------------------------------------------------------------------------------------------------------------------
        -- If first step and DoMergeHookData is True Merge hooks and parameter values from all (ADM) databases to ADM_DataGateway 
        -----------------------------------------------------------------------------------------------------------------------------
        if @ProgramTypeCode = 'TSQL'
        begin
            exec @ProgramName @BatchDefinitionStepID = @BatchDefinitionStepID
                            , @ParentBatchLogID      = @BatchLogID
                            , @UserName              = @UserName
            ;
        end;
        else
        begin
            if @ProgramTypeCode = 'SSIS'
                exec Adm.usp_StartSSISpackage @BatchDefinitionStepID = @BatchDefinitionStepID
                                            , @ParentBatchLogID      = @BatchLogID
                                            , @UserName              = @UserName
                                            , @ProgramName           = @ProgramName
                ;
            else
                raiserror ('Program type %s is not supported. Exiting.', 11, 1, @ProgramTypeCode);
        end;
        update BL
        set BL.StatusCode     = 'COMPLETED'
          , BL.EndDateTime    = getdate()
          , BL.LastUpdateDate = getdate()
          , BL.LastUpdatedBy  = @UserName
        from Adm.BatchLog as BL
        where BL.BatchLogID = @BatchLogID
        ;
        set @BatchDefinitionStepID = null;

        fetch next from BDS_Cursor into @BatchDefinitionStepID, @ProgramTypeCode, @ProgramName, @BatchDefinitionStepDescription;
    end;
    close BDS_Cursor;
    deallocate BDS_Cursor;

    update BE
    set BE.StatusCode     = 'COMPLETED'
      , BE.EndDateTime    = getdate()
      , BE.LastUpdateDate = getdate()
      , BE.LastUpdatedBy  = @UserName
    from Adm.BatchExecution as BE
    where BE.BatchExecutionID = @BatchExecutionID
    ;

    set @Remark = 'End';
    exec Logging.usp_LogProcess @Guid
                              , @ProcedureName
                              , @Remark;
end try
begin catch
    /* Rethrow error */
    declare @ErrorMessage         nvarchar(4000)
          , @ErrorSeverity        int            = error_severity()
          , @ErrorState           int            = error_state()
          , @OriginalErrorMessage nvarchar(2048) = error_message()
    ;

    set @ErrorMessage = left(N'Error ' + cast(error_number() as nvarchar(max))
    + N', Level ' + cast(@ErrorSeverity as nvarchar(max))
    + N', State ' + cast(@ErrorState as nvarchar(max))
    + N', Procedure ' + isnull(error_procedure(), N'<unknown>')
    + N', Line ' + cast(error_line() as nvarchar(max))
    + N', Message: ' + @OriginalErrorMessage
    , 4000);

    if @BatchExecutionID is not null
        update BE
        set BE.StatusCode       = 'FAILED'
          , BE.ErrorDescription = @ErrorMessage
          , BE.EndDateTime      = getdate()
          , BE.LastUpdateDate   = getdate()
          , BE.LastUpdatedBy    = @UserName
        from Adm.BatchExecution as BE
        where BE.BatchExecutionID = @BatchExecutionID
        ;

    if @BatchLogID is not null
        /* Recursively update status to failed for all SP batchlog records in hierarchy with status RUNNING.
                           If e.g. a master SP calls a 2 child SPs and the 1st SP is sucessful but the 2nd is not, then
                           the batchlog record for the 1st SP will have status COMPLETED while the 2nd is still set to
                           RUNNING at this point. CTE update below corrects this.
                        */
        with CTE_BL as
        (
            select
                BatchLogID = BL.BatchLogID
            from Adm.BatchLog as BL
            where BL.BatchLogID = @BatchLogID
            union all
            select
                BL_C.BatchLogID
            from CTE_BL as BL_P
            inner join Adm.BatchLog as BL_C
                on BL_C.ParentBatchLogID = BL_P.BatchLogID
        )
        update BL
        set BL.StatusCode       = 'FAILED'
          , BL.ErrorDescription = @ErrorMessage
          , BL.EndDateTime      = getdate()
          , BL.LastUpdateDate   = getdate()
          , BL.LastUpdatedBy    = @UserName
        from CTE_BL
        inner join Adm.BatchLog as BL
            on BL.BatchLogID = CTE_BL.BatchLogID
        where BL.StatusCode = 'RUNNING'
        ;

    raiserror (@ErrorMessage, @ErrorSeverity, @ErrorState);
end catch;