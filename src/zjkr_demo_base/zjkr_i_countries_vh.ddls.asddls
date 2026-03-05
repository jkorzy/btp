@AbapCatalog.sqlViewName: 'ZJKR_VCTRVH'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for countries'
@VDM.viewType: #BASIC
@Metadata.ignorePropagatedAnnotations: true
define view zjkr_i_countries_vh as select from zjkr_i_countries
{
    key Country,
    _Text[1:Spras = $session.system_language].CountryText as CountryText
}
