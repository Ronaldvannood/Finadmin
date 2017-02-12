CREATE TABLE [Fin].[Expense] (
    [ExpenseID]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [ExpenseCode]        NVARCHAR (50)   NOT NULL,
    [ExpenseDescription] NVARCHAR (1000) NULL,
    [CreationDate]       DATETIME        CONSTRAINT [df_Expense_CreationDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          NVARCHAR (50)   CONSTRAINT [df_Expense_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]    DATETIME        CONSTRAINT [df_Expense_LastUpatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]      NVARCHAR (50)   CONSTRAINT [df_Expense_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [pk_Expense] PRIMARY KEY CLUSTERED ([ExpenseID] ASC),
    CONSTRAINT [uc_Expense_ExpenseCode] UNIQUE NONCLUSTERED ([ExpenseCode] ASC)
);

