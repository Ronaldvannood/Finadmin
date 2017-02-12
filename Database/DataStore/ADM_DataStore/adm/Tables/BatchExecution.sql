CREATE TABLE [adm].[BatchExecution] (
    [BatchExecutionID]  BIGINT          IDENTITY (1, 1) NOT NULL,
    [BatchDefinitionID] INT             NOT NULL,
    [StatusCode]        NVARCHAR (50)   NOT NULL,
    [StartDateTime]     DATETIME        NOT NULL,
    [EndDateTime]       DATETIME        NULL,
    [ErrorDescription]  NVARCHAR (4000) NULL,
    [LastUpdatedBy]     NVARCHAR (255)  NOT NULL,
    [LastUpdateDate]    DATETIME        CONSTRAINT [df_BatchExecution_LastUpdateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (255)  NOT NULL,
    [CreationDate]      DATETIME        CONSTRAINT [df_BatchExecution_CreationDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_BatchExecution] PRIMARY KEY CLUSTERED ([BatchExecutionID] ASC),
    CONSTRAINT [fk_BatchDefinitionExecution_BatchDefinitionID_BatchDefinition_BatchDefinitionID] FOREIGN KEY ([BatchDefinitionID]) REFERENCES [adm].[BatchDefinition] ([BatchDefinitionID])
);

