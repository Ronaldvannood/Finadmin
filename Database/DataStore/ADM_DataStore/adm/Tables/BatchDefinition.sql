CREATE TABLE [adm].[BatchDefinition] (
    [BatchDefinitionID]          INT            IDENTITY (1, 1) NOT NULL,
    [BatchDefinitionCode]        NVARCHAR (50)  NOT NULL,
    [BatchDefinitionDescription] NVARCHAR (250) NOT NULL,
    [IsDeleted]                  BIT            CONSTRAINT [df_BatchDefinition_IsDeleted] DEFAULT ((0)) NOT NULL,
    [LastUpdatedBy]              NVARCHAR (255) NOT NULL,
    [LastUpdateDate]             DATETIME       CONSTRAINT [df_BatchDefinition_LastUpdateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                  NVARCHAR (255) NOT NULL,
    [CreationDate]               DATETIME       CONSTRAINT [df_BatchDefinition_CreationDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_BatchDefinition] PRIMARY KEY CLUSTERED ([BatchDefinitionID] ASC),
    CONSTRAINT [uc_BatchDefinition_BatchDefinitionCode] UNIQUE NONCLUSTERED ([BatchDefinitionCode] ASC)
);

