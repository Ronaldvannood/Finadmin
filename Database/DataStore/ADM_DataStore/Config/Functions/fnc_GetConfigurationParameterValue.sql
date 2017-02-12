

/* 
=======================================================================================================================
Purpose:
Return configuration parameter value. If none specified, then return default value.

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2014-12-01  A. Siegers                  8482        Creation
2015-10-05  J. de Rhoter               18082        Tabel en ID teruggeven
2016-03-01  T. Veldhuis                21478        Logica verhuisd naar vw_ConfigurationParameterValue ten behoeve
                                                    van een Initiele build DGW
=======================================================================================================================
*/
CREATE function [Config].[fnc_GetConfigurationParameterValue]
(
    @ParameterCode nvarchar(50)
)
returns @ValueTable table (
    ValueChar      nvarchar(max)
  , ValueNumeric   float
  , ValueDate      datetime
  , ValueBit       bit
  , RecordSource   nvarchar(128)
  , SourceRecordID nvarchar(50)
)
as
begin
insert into @ValueTable
(
    ValueChar
  , ValueNumeric
  , ValueDate
  , ValueBit
  , RecordSource
  , SourceRecordID
)
select
    CPV.ValueChar
  , CPV.ValueNumeric
  , CPV.ValueDate
  , CPV.ValueBit
  , CPV.RecordSource
  , CPV.SourceRecordID
from Adm.vw_ConfigurationParameterValue as CPV
where CPV.ParameterCode = @ParameterCode
;
return;
end;