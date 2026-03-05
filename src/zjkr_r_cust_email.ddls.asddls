@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Entity Customer Emails'
@Metadata.ignorePropagatedAnnotations: true
define view entity zjkr_r_cust_email as select from zjkr_cust_email
association to parent ZJKR_R_CUSTOMER as _Customer
    on $projection.CustomerId = _Customer.CustomerID
{    
    key zjkr_cust_email.customer_id as CustomerId,
    key zjkr_cust_email.email_id as EmailId,
    @Semantics.eMail.address: true
    zjkr_cust_email.email as Email,
    zjkr_cust_email.default_email as DefaultEmail,
    zjkr_cust_email.last_changed_at as LastChangedAt,
    _Customer // Make association public
}
