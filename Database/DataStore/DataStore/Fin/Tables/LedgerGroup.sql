CREATE TABLE [Fin].[LedgerGroup] (
    [LedgerGroupID]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [LedgerGroupCode]        NVARCHAR (50)   NOT NULL,
    [LedgerGroupDescription] NVARCHAR (1000) NULL,
    [CreationDate]           DATETIME        CONSTRAINT [df_LedgerGroup_CreationDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]              NVARCHAR (50)   CONSTRAINT [df_LedgerGroup_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]        DATETIME        CONSTRAINT [df_LedgerGroup_LastUpatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]          NVARCHAR (50)   CONSTRAINT [df_LedgerGroup_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [pk_LedgerGroup] PRIMARY KEY CLUSTERED ([LedgerGroupID] ASC),
    CONSTRAINT [uc_LedgerGroup_LedgerGroupCode] UNIQUE NONCLUSTERED ([LedgerGroupCode] ASC)
);

