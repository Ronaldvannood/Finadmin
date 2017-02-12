



/*
=======================================================================================================================
Purpose:
View die alle parameters teruggeeft, mbv de functie fnc_GetConfigurationParameterValue

Changelog:
-----------------------------------------------------------------------------------------------------------------------
Date        Author                      Bug         Comment
-----------------------------------------------------------------------------------------------------------------------
2015-10-08  M. Dieperink                18082       Creation
2016-03-01  T. Veldhuis                 21478       Functie getConfigurationParameterValue ingebouwd in de view ten
                                                    behoeve van een initiele build (View kan geen functie bevatten,
                                                    omdat functie nog niet bestaat)
=======================================================================================================================
*/
create view [Adm].[vw_ConfigurationParameterValue]
as
with ConfigurationParameterValue as
(
    select
        CP.ParameterCode
      , ValueChar =      case
                       when CPV.ConfigurationParameterID is not null
                       then CPV.ValueChar
                       else CP.DefaultValueChar
                   end
      , ValueNumeric =   case
                          when CPV.ConfigurationParameterID is not null
                          then CPV.ValueNumeric
                          else CP.DefaultValueNumeric
                      end
      , ValueDate =      case
                       when CPV.ConfigurationParameterID is not null
                       then CPV.ValueDate
                       else CP.DefaultValueDate
                   end
      , ValueBit =       case
                      when CPV.ConfigurationParameterID is not null
                      then CPV.ValueBit
                      else CP.DefaultValueBit
                  end
      , RecordSource =   case
                          when CPV.ConfigurationParameterValueID is not null
                          then 'ConfigurationParameterValue'
                          else 'ConfigurationParameter'
                      end
      , SourceRecordID = cast(case
            when CPV.ConfigurationParameterValueID is not null
            then CPV.ConfigurationParameterValueID
            else CP.ConfigurationParameterID
        end as nvarchar(50))
    from Adm.ConfigurationParameter as CP
    left join Adm.ConfigurationParameterValue as CPV
        on CPV.ConfigurationParameterID = CP.ConfigurationParameterID
)
select
    CP.ConfigurationParameterID
  , CP.ParameterCode
  , CP.ParameterDescription
  , CPV.ValueChar
  , CPV.ValueNumeric
  , CPV.ValueDate
  , CPV.ValueBit
  , CPV.RecordSource
  , CPV.SourceRecordID
from Adm.ConfigurationParameter as CP
left join ConfigurationParameterValue as CPV
    on CPV.ParameterCode = CP.ParameterCode
;