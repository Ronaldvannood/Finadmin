CREATE TABLE [adm].[BatchDefinitionStep] (
    [BatchDefinitionStepID]          INT            IDENTITY (1, 1) NOT NULL,
    [BatchDefinitionID]              INT            NOT NULL,
    [BatchDefinitionStepOrderNumber] INT            NOT NULL,
    [ProgramTypeCode]                NVARCHAR (50)  NOT NULL,
    [ProgramName]                    NVARCHAR (MAX) NOT NULL,
    [BatchDefinitionStepDescription] NVARCHAR (250) NOT NULL,
    [IsDeleted]                      BIT            CONSTRAINT [df_BatchDefinitionStep_IsDeleted] DEFAULT ((0)) NOT NULL,
    [LastUpdatedBy]                  NVARCHAR (255) NOT NULL,
    [LastUpdateDate]                 DATETIME       CONSTRAINT [df_BatchDefinitionStep_LastUpdateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                      NVARCHAR (255) NOT NULL,
    [CreationDate]                   DATETIME       CONSTRAINT [df_BatchDefinitionStep_CreationDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_BatchDefinitionStep] PRIMARY KEY CLUSTERED ([BatchDefinitionStepID] ASC),
    CONSTRAINT [fk_BatchDefinitionStep_BatchDefinitionID_BatchDefinition_BatchDefinitionID] FOREIGN KEY ([BatchDefinitionID]) REFERENCES [adm].[BatchDefinition] ([BatchDefinitionID]),
    CONSTRAINT [uc_BatchDefinitionStep_BatchDefinitionID_BatchDefinitionStepOrderNumber] UNIQUE NONCLUSTERED ([BatchDefinitionID] ASC, [BatchDefinitionStepOrderNumber] ASC)
);

