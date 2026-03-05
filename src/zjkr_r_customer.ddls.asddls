@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZJKR_CUSTOMER'
@EndUserText.label: 'Customer'
define root view entity ZJKR_R_CUSTOMER
  as select from zjkr_customer
  
  composition [0..*] of zjkr_r_cust_phone as _CustomerPhone
  composition [0..*] of zjkr_r_cust_email as _CustomerEmail
  
  association [1..1] to zjkr_i_countries as _Countries on $projection.Country = _Countries.Country
{
  key customer_id as CustomerID,
  name_1 as Name1,
  name_2 as Name2,
  street as Street,
  house_no as HouseNo,
  city as City,
  post_code as PostCode,
  country as Country,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_change_at as LastChangeAt,
  
  _CustomerPhone,
  _CustomerEmail,
  _Countries
}
