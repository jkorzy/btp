@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view Customer Phones'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZJKR_C_CUST_PHONE 
as projection on zjkr_r_cust_phone
{

    
    key CustomerID,       
    key PhoneID,
    @Consumption:{
        valueHelpDefinition: [{  
            entity: {
                name: 'zjkr_i_countries_vh', 
                element: 'Country'
            },
            useForValidation: true
        }]
    }
    @ObjectModel: {
        text: {
            element: [ 'CountryText' ]
        }
    }
    Country,
    _Country._Text.CountryText as CountryText : localized, 
    CountryPrefix,
    PhoneNo,
    DefaultPhone,
    LastChangedAt,
    /* Associations */
    _Customer : redirected to parent ZJKR_C_CUSTOMER,
    _Country
}
