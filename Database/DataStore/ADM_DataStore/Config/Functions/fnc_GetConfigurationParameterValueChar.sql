


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
CREATE function [Config].[fnc_GetConfigurationParameterValueChar]
(
    @ParameterCode nvarchar(50)
)
returns nvarchar(max)
as
begin
declare @ValueChar nvarchar(max);
select
    @ValueChar = CPV.ValueChar
from Config.fnc_GetConfigurationParameterValue(@ParameterCode) as CPV
;
return @ValueChar;
end;