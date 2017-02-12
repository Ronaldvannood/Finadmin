CREATE TABLE [adm].[ConfigurationParameterValue] (
    [ConfigurationParameterValueID] INT            IDENTITY (1, 1) NOT NULL,
    [ConfigurationParameterID]      INT            NOT NULL,
    [ValueChar]                     NVARCHAR (MAX) NULL,
    [ValueNumeric]                  FLOAT (53)     NULL,
    [ValueDate]                     DATETIME       NULL,
    [ValueBit]                      BIT            NULL,
    [CreationDate]                  DATETIME       CONSTRAINT [df_ConfigurationParameterValue_CreationDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]                     NVARCHAR (255) NOT NULL,
    [LastUpdateDate]                DATETIME       CONSTRAINT [df_ConfigurationParameterValue_LastUpdateDate] DEFAULT (getdate()) NOT NULL,
    [LastUpdatedBy]                 NVARCHAR (255) NOT NULL,
    CONSTRAINT [pk_ConfigurationParameterValue] PRIMARY KEY CLUSTERED ([ConfigurationParameterValueID] ASC),
    CONSTRAINT [fk_ConfigurationParameterValue_ConfigurationParameterID_ConfigurationParameter_ConfigurationParameterID] FOREIGN KEY ([ConfigurationParameterID]) REFERENCES [adm].[ConfigurationParameter] ([ConfigurationParameterID])
);

