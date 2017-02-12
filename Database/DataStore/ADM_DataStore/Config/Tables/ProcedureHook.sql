CREATE TABLE [Config].[ProcedureHook] (
    [ProcedureHookID]       INT            IDENTITY (1, 1) NOT NULL,
    [StandardProcedureName] NVARCHAR (256) NOT NULL,
    [OrderNumber]           INT            NOT NULL,
    [ExecuteBefore]         BIT            NOT NULL,
    [ExecuteAfter]          BIT            NOT NULL,
    [ExecuteInsteadOf]      BIT            NOT NULL,
    [CustomProcedureName]   NVARCHAR (256) NOT NULL,
    [LastUpdatedBy]         NVARCHAR (255) NOT NULL,
    [LastUpdateDate]        DATETIME       CONSTRAINT [df_ProcedureHook_LastUpdateDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]             NVARCHAR (255) NOT NULL,
    [CreationDate]          DATETIME       CONSTRAINT [df_ProcedureHook_CreationDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [pk_ProcedureHook] PRIMARY KEY CLUSTERED ([ProcedureHookID] ASC),
    CONSTRAINT [uc_ProcedureHook_StandardProcedureName_OrderNumber] UNIQUE NONCLUSTERED ([StandardProcedureName] ASC, [OrderNumber] ASC)
);

