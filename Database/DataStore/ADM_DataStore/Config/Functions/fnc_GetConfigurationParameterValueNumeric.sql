


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
CREATE function [Config].[fnc_GetConfigurationParameterValueNumeric]
(
    @ParameterCode nvarchar(50)
)
returns float
as
begin
declare @ValueNumeric float
select
    @ValueNumeric = CPV.ValueNumeric
from Config.fnc_GetConfigurationParameterValue(@ParameterCode) as CPV
;
return @ValueNumeric;
end;