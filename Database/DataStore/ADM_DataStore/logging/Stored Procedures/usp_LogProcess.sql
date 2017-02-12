


CREATE procedure [Logging].[usp_LogProcess]
(
	@Guid			uniqueidentifier
,	@ProcedureName	nvarchar(250)
,	@Remark			nvarchar(max)
) as
insert into Logging.Process
(	[Guid]
,	ProcedureName
,	Remark
,	StartTime )
select @Guid
,	@ProcedureName
,	@Remark
,	getdate()