CREATE TABLE [Fin].[Contract] (
    [ContractID]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [ContactID]           BIGINT          NOT NULL,
    [ContractCode]        NVARCHAR (50)   NOT NULL,
    [ContractDestription] NVARCHAR (1000) NULL,
    [ContractDocument]    IMAGE           NULL,
    [StartDate]           DATETIME        NOT NULL,
    [EndDate]             DATETIME        NULL,
    [IsEAF]               BIT             NOT NULL,
    [IsUnknown]           BIT             NOT NULL,
    [CreationDate]        DATETIME        CONSTRAINT [df_Contract_CreationDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]           NVARCHAR (50)   CONSTRAINT [df_Contract_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]     DATETIME        CONSTRAINT [df_Contract_LastUpatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]       NVARCHAR (50)   CONSTRAINT [df_Contract_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [pk_Contract] PRIMARY KEY CLUSTERED ([ContractID] ASC),
    FOREIGN KEY ([ContactID]) REFERENCES [Fin].[Contact] ([ContactID]),
    CONSTRAINT [uc_Contract_ContractCode_StartDate] UNIQUE NONCLUSTERED ([ContractCode] ASC, [StartDate] ASC)
);

