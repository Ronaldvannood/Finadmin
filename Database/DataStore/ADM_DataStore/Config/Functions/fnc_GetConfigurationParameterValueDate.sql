


/* 
=======================================================================================================================
Purpose:
Return configuration parameter value. If none specified, then return default value.

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2014-12-01  A. Siegers                  8482        Creation
=======================================================================================================================
*/
CREATE function [Config].[fnc_GetConfigurationParameterValueDate]
(
    @ParameterCode nvarchar(50)
)
returns datetime
as
begin
declare @ValueDate datetime;
select
    @ValueDate = CPV.ValueDate
from Config.fnc_GetConfigurationParameterValue(@ParameterCode) as CPV
;
return @ValueDate;
end;