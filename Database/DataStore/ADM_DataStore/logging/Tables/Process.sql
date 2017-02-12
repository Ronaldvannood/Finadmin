CREATE TABLE [logging].[Process] (
    [ProcessID]     BIGINT           IDENTITY (1, 1) NOT NULL,
    [Guid]          UNIQUEIDENTIFIER NULL,
    [ProcedureName] NVARCHAR (250)   NULL,
    [Remark]        NVARCHAR (MAX)   NULL,
    [StartTime]     DATETIME         NULL,
    CONSTRAINT [pk_Process] PRIMARY KEY CLUSTERED ([ProcessID] ASC)
);

