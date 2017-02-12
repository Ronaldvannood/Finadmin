CREATE TABLE [Fin].[Ledger] (
    [LedgerID]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [LedgerGroupID]     BIGINT          NOT NULL,
    [LedgerCode]        NVARCHAR (50)   NOT NULL,
    [LedgerDescription] NVARCHAR (1000) NULL,
    [CreationDate]      DATETIME        CONSTRAINT [df_Ledger_CreationDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (50)   CONSTRAINT [df_Ledger_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]   DATETIME        CONSTRAINT [df_Ledger_LastUpatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]     NVARCHAR (50)   CONSTRAINT [df_Ledger_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [pk_Ledger] PRIMARY KEY CLUSTERED ([LedgerID] ASC),
    FOREIGN KEY ([LedgerGroupID]) REFERENCES [Fin].[LedgerGroup] ([LedgerGroupID]),
    CONSTRAINT [uc_Ledger_LedgerCode] UNIQUE NONCLUSTERED ([LedgerCode] ASC)
);

