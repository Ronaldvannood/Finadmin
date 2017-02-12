CREATE TABLE [SA].[FinancialTransaction] (
    [FinanialTransactionId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountNumber]         NVARCHAR (50)   NULL,
    [CurrencyCode]          NVARCHAR (10)   NULL,
    [ValueDate]             NVARCHAR (10)   NULL,
    [StartValue]            DECIMAL (18, 2) NULL,
    [EndValue]              DECIMAL (18, 2) NULL,
    [TransactionDate]       NVARCHAR (10)   NULL,
    [TransactionValue]      DECIMAL (18, 2) NULL,
    [Remark]                NVARCHAR (1000) NULL,
    [CreationDate]          DATETIME        CONSTRAINT [df_FinancialTransaction_CreationDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_FinancialTransaction] PRIMARY KEY CLUSTERED ([FinanialTransactionId] ASC)
);

