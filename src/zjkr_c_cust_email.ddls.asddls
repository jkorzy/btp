@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Customer Email'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zjkr_c_cust_email as projection on zjkr_r_cust_email
{    
    key CustomerId,
    key EmailId,
    @Semantics.eMail.address: true
    Email,
    DefaultEmail,
    LastChangedAt,
    /* Associations */
    _Customer : redirected to parent ZJKR_C_CUSTOMER
}
