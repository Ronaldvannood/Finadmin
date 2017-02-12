CREATE TABLE [Fin].[FinancialTransaction] (
    [FinancialTransactionID]       BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountNumberID]              BIGINT          NOT NULL,
    [ExpenseID]                    BIGINT          NOT NULL,
    [ContactID]                    BIGINT          NULL,
    [ContractID]                   BIGINT          NULL,
    [LedgerID]                     BIGINT          NULL,
    [CurrencyCode]                 NVARCHAR (10)   NULL,
    [FinancialTransactionDate]     DATETIME        NOT NULL,
    [FinancialTransactionValue]    DECIMAL (18, 2) NOT NULL,
    [FinancialTransactionRemark]   NVARCHAR (1000) NULL,
    [financialTransactionDocument] IMAGE           NULL,
    [CreationDate]                 DATETIME        CONSTRAINT [df_FinancialTransaction_CreationDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                    NVARCHAR (50)   CONSTRAINT [df_FinancialTransaction_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]              DATETIME        CONSTRAINT [df_FinancialTransaction_LastUpatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]                NVARCHAR (50)   CONSTRAINT [df_FinancialTransaction_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [pk_FianacialTransaction] PRIMARY KEY CLUSTERED ([FinancialTransactionID] ASC),
    FOREIGN KEY ([AccountNumberID]) REFERENCES [Fin].[AccountNumber] ([AccountNumberID]),
    FOREIGN KEY ([ContactID]) REFERENCES [Fin].[Contact] ([ContactID]),
    FOREIGN KEY ([ContractID]) REFERENCES [Fin].[Contract] ([ContractID]),
    FOREIGN KEY ([ExpenseID]) REFERENCES [Fin].[Expense] ([ExpenseID]),
    FOREIGN KEY ([LedgerID]) REFERENCES [Fin].[Ledger] ([LedgerID])
);



