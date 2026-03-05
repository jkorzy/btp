@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity Customer Phones'
@Metadata.ignorePropagatedAnnotations: true
define view entity zjkr_r_cust_phone 
    as select from zjkr_cust_phone as CustomerPhone
    
    association to parent ZJKR_R_CUSTOMER as _Customer on $projection.CustomerID = _Customer.CustomerID
    
    association [1..1] to zjkr_i_countries as _Country on $projection.Country = _Country.Country
    
{
    key customer_id as CustomerID,
    key phone_id as PhoneID,
    country as Country,
    country_prefix as CountryPrefix,
    phone_no as PhoneNo,
    default_phone as DefaultPhone,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    
    _Customer,
    _Country
}
