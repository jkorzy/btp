@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Country Texts'
@Metadata.ignorePropagatedAnnotations: true
define view entity zjkr_i_countries_t as select from zjkr_ctryt
{
    @Semantics.language: true
    key spras as Spras,
    @ObjectModel.text.element: [ 'CountryText' ]
    key country_code as Country,
    @Semantics.text: true
    country_text as CountryText
}
