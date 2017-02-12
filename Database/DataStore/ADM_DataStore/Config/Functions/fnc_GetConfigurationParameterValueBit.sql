


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
CREATE function [Config].[fnc_GetConfigurationParameterValueBit]
(
    @ParameterCode nvarchar(50)
)
returns bit
as
begin
declare @ValueBit bit
select
    @ValueBit = CPV.ValueBit
from Config.fnc_GetConfigurationParameterValue(@ParameterCode) as CPV
;
return @ValueBit;
end;