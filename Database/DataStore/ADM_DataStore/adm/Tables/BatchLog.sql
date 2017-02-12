CREATE TABLE [adm].[BatchLog] (
    [BatchLogID]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [ParentBatchLogID]      BIGINT          NULL,
    [BatchDefinitionStepID] INT             NOT NULL,
    [StatusCode]            NVARCHAR (50)   NOT NULL,
    [StartDateTime]         DATETIME        NOT NULL,
    [EndDateTime]           DATETIME        NULL,
    [TargetTableName]       NVARCHAR (250)  NULL,
    [ProgramName]           NVARCHAR (MAX)  NULL,
    [NumberOfRowsInserted]  BIGINT          NULL,
    [NumberOfRowsUpdated]   BIGINT          NULL,
    [NumberOfRowsDeleted]   BIGINT          NULL,
    [ErrorCode]             NVARCHAR (50)   NULL,
    [ErrorDescription]      NVARCHAR (4000) NULL,
    [LastUpdatedBy]         NVARCHAR (255)  NOT NULL,
    [LastUpdateDate]        DATETIME        CONSTRAINT [df_BatchLog_LastUpdateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]             NVARCHAR (255)  NOT NULL,
    [CreationDate]          DATETIME        CONSTRAINT [df_BatchLog_CreationDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_BatchLog] PRIMARY KEY NONCLUSTERED ([BatchLogID] ASC),
    CONSTRAINT [fk_BatchLog_ParentBatchLogID_BatchLog_BatchLogID] FOREIGN KEY ([ParentBatchLogID]) REFERENCES [adm].[BatchLog] ([BatchLogID])
);

