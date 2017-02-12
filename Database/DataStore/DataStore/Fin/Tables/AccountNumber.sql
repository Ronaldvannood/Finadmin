CREATE TABLE [Fin].[AccountNumber] (
    [AccountNumberID]    BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountNumber]      NVARCHAR (50)   NOT NULL,
    [AccountDiscription] NVARCHAR (1000) NULL,
    [LastKnownBalance]   DECIMAL (18, 2) NULL,
    [CreationDate]       DATETIME        CONSTRAINT [df_AccountNumber_CreationDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          NVARCHAR (50)   CONSTRAINT [df_AccountNumber_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]    DATETIME        CONSTRAINT [df_AccountNumber_LastUpatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]      NVARCHAR (50)   CONSTRAINT [df_AccountNumber_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [pk_AccoutNumber] PRIMARY KEY CLUSTERED ([AccountNumberID] ASC),
    CONSTRAINT [uc_AccountNumber_AccountNumber] UNIQUE NONCLUSTERED ([AccountNumber] ASC)
);

