CREATE TABLE [adm].[ConfigurationParameter] (
    [ConfigurationParameterID] INT            IDENTITY (1, 1) NOT NULL,
    [ParameterCode]            NVARCHAR (50)  NOT NULL,
    [ParameterDescription]     NVARCHAR (255) NOT NULL,
    [ParameterDataType]        NCHAR (1)      NOT NULL,
    [DefaultValueChar]         NVARCHAR (MAX) NULL,
    [DefaultValueNumeric]      FLOAT (53)     NULL,
    [DefaultValueDate]         DATETIME       NULL,
    [DefaultValueBit]          BIT            NULL,
    [CreationDate]             DATETIME       CONSTRAINT [df_ConfigurationParameter_CreationDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                NVARCHAR (255) NOT NULL,
    [LastUpdateDate]           DATETIME       CONSTRAINT [df_ConfigurationParameter_LastUpdateDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]            NVARCHAR (255) NOT NULL,
    CONSTRAINT [pk_ConfigurationParameter] PRIMARY KEY CLUSTERED ([ConfigurationParameterID] ASC),
    CONSTRAINT [ck_ConfigurationParameter_ParameterDataType] CHECK ([ParameterDataType]='B' OR [ParameterDataType]='D' OR [ParameterDataType]='N' OR [ParameterDataType]='C'),
    CONSTRAINT [uc_ConfigurationParameter_ConfigurationCode] UNIQUE NONCLUSTERED ([ParameterCode] ASC)
);

