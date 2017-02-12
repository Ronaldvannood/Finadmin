CREATE TABLE [Fin].[Contact] (
    [ContactID]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [ContactCode]        NVARCHAR (50)   NOT NULL,
    [ContactDescription] NVARCHAR (1000) NULL,
    [CreationDate]       DATETIME        CONSTRAINT [df_Contact_CreationDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]          NVARCHAR (50)   CONSTRAINT [df_Contact_CreatedBy] DEFAULT (suser_sname()) NOT NULL,
    [LastUpdatedDate]    DATETIME        CONSTRAINT [df_Contact_LastUpatedDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]      NVARCHAR (50)   CONSTRAINT [df_Contact_LastUpdatedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [pk_Contact] PRIMARY KEY CLUSTERED ([ContactID] ASC),
    CONSTRAINT [uc_Contact_ContactCode] UNIQUE NONCLUSTERED ([ContactCode] ASC)
);

