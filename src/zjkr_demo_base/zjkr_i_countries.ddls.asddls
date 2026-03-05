@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Countries'
@Metadata.ignorePropagatedAnnotations: true
define view entity zjkr_i_countries
  as select from zjkr_ctry
  association [0..*] to zjkr_i_countries_t as _Text on $projection.Country = _Text.country
{
  key country_code as Country,      
      prefix       as Prefix,
      _Text

}
