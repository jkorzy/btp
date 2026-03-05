@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Customer'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZJKR_CUSTOMER'
}
@AccessControl.authorizationCheck: #MANDATORY

define root view entity ZJKR_C_CUSTOMER
  provider contract transactional_query
  as projection on ZJKR_R_CUSTOMER
{
  key CustomerID,
      Name1,
      Name2,
      Street,
      HouseNo,
      City,
      PostCode,
      @ObjectModel: {
        text: {
            element: [ 'CountryText' ]
        }
      }
      @Consumption: {
        valueHelpDefinition: [{
            entity: { name: 'zjkr_i_countries_vh', element: 'Country'  },
            useForValidation: true }]
      }
      Country,
      _Countries._Text.CountryText as CountryText : localized,
      @Semantics: {
        user.createdBy: true
      }
      CreatedBy,
      @Semantics: {
        systemDateTime.createdAt: true
      }
      CreatedAt,
      @Semantics: {
        user.localInstanceLastChangedBy: true
      }
      LocalLastChangedBy,
      @Semantics: {
        systemDateTime.localInstanceLastChangedAt: true
      }
      LocalLastChangedAt,
      @Semantics: {
        systemDateTime.lastChangedAt: true
      }
      LastChangeAt,
      _CustomerPhone : redirected to composition child ZJKR_C_CUST_PHONE,
      _CustomerEmail : redirected to composition child ZJKR_C_CUST_EMAIL
}
