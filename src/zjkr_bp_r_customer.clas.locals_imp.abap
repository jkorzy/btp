CLASS lhc_customerphone DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS getCountryPrefix FOR DETERMINE ON MODIFY
      IMPORTING keys FOR CustomerPhone~getCountryPrefix.
    METHODS defaultPhone FOR DETERMINE ON MODIFY
      IMPORTING keys FOR CustomerPhone~defaultPhone.
    METHODS checkDefault FOR VALIDATE ON SAVE
      IMPORTING keys FOR CustomerPhone~checkDefault.

ENDCLASS.


CLASS lhc_customerphone IMPLEMENTATION.

  METHOD getCountryPrefix.

    READ ENTITIES OF zjkr_r_customer IN LOCAL MODE
        ENTITY Customer BY \_CustomerPhone
        FIELDS ( Country CountryPrefix )
        WITH CORRESPONDING #( keys )
        RESULT DATA(l_tab_cust_phones).

    DELETE l_tab_cust_phones WHERE Country IS INITIAL.

    LOOP AT l_tab_cust_phones ASSIGNING FIELD-SYMBOL(<l_wrk_cust_phone>).
      SELECT SINGLE Prefix FROM zjkr_i_countries
        WHERE Country = @<l_wrk_cust_phone>-Country
        INTO  @<l_wrk_cust_phone>-CountryPrefix.
    ENDLOOP.

    MODIFY ENTITIES OF zjkr_r_customer IN LOCAL MODE
        ENTITY CustomerPhone
        UPDATE FIELDS ( CountryPrefix )
        WITH CORRESPONDING #( l_tab_cust_phones ).

  ENDMETHOD.

  METHOD defaultPhone.
    READ ENTITIES OF zjkr_r_customer IN LOCAL MODE
        ENTITY Customer BY \_CustomerPhone
        FIELDS ( DefaultPhone )
        WITH CORRESPONDING #( keys )
        RESULT DATA(l_tab_phones).

*   Check Number of phones marked as default
    DATA(l_no_defaults) = REDUCE i(
        INIT no_defaults = 0
        FOR phone IN l_tab_phones
            NEXT no_defaults = COND #( WHEN phone-DefaultPhone IS NOT INITIAL THEN no_defaults + 1 ELSE no_defaults )
    ).

*  When more then 1 then set all except the currently changed to not default
    IF l_no_defaults > 1.

      LOOP AT l_tab_phones ASSIGNING FIELD-SYMBOL(<l_wrk_phone>).
*       Changed record or one that already have DefaultPhone eq space will not be altered
        READ TABLE keys USING KEY entity FROM CORRESPONDING #( <l_wrk_phone> ) TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0 OR <l_wrk_phone>-DefaultPhone IS INITIAL.
          DELETE l_tab_phones.
        ELSE.
          CLEAR <l_wrk_phone>-DefaultPhone.
        ENDIF.
      ENDLOOP.

      MODIFY ENTITIES OF zjkr_r_customer IN LOCAL MODE
              ENTITY CustomerPhone
              UPDATE FIELDS ( DefaultPhone )
              WITH CORRESPONDING #( l_tab_phones )
          REPORTED DATA(l_tab_reported).

      reported = CORRESPONDING #( DEEP l_tab_reported ).
    ENDIF.

  ENDMETHOD.

  METHOD checkDefault.

    READ ENTITIES OF zjkr_r_customer IN LOCAL MODE
        ENTITY Customer BY  \_CustomerPhone
        FIELDS ( DefaultPhone )
        WITH CORRESPONDING #( keys )
        RESULT DATA(l_tab_phones).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>) GROUP BY <key>-CustomerID.
      DATA(l_no_defaults) = REDUCE i(
          INIT no_defaults = 0
          FOR phone IN l_tab_phones USING KEY entity WHERE ( CustomerID = <key>-CustomerID AND DefaultPhone = abap_true )
          NEXT no_defaults = no_defaults + 1
      ).
      IF l_no_defaults NE 1.
        APPEND VALUE #(
            %tky = CORRESPONDING #( <key>-%tky )
        ) TO failed-customer.

        append value #(
            %tky = corrESPONDING #( <key>-%tky )
            %msg = new zjkr_customer_msg(
                textid = zjkr_customer_msg=>wrong_default_phone
                severity = if_abap_behv_message=>severity-error
            )
        ) to reported-customer.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_zjkr_r_customer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Customer
        RESULT result,
      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE Customer,
      earlynumbering_create_phone FOR NUMBERING
        IMPORTING entities FOR CREATE Customer\_CustomerPhone,
      earlynumbering_create_email FOR NUMBERING
        IMPORTING entities FOR CREATE Customer\_CustomerEmail,
      validateMandatory FOR VALIDATE ON SAVE
        IMPORTING keys FOR Customer~validateMandatory.
ENDCLASS.

CLASS lhc_zjkr_r_customer IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD earlynumbering_create.

    "Find the highest customer id => select higher from both tables application and draft

    "- Check in application table
    SELECT MAX( customer_id ) FROM zjkr_customer
        INTO @DATA(l_max_customer_id).

    SELECT MAX( customerid ) FROM zjkr_customer_d
      INTO @DATA(l_max_draft).

    IF l_max_draft > l_max_customer_id.
      l_max_customer_id = l_max_draft.
    ENDIF.

    LOOP AT entities INTO DATA(customer) .

      IF customer-CustomerID IS NOT INITIAL.
        APPEND CORRESPONDING #( customer ) TO mapped-customer.
      ELSE.
        l_max_customer_id += 1.
        customer-CustomerID = l_max_customer_id.
        APPEND CORRESPONDING #( customer ) TO mapped-customer.
      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD validateMandatory.

    READ ENTITIES OF zjkr_r_customer IN LOCAL MODE
        ENTITY Customer
        FIELDS ( Name1 Street HouseNo City PostCode Country )
        WITH CORRESPONDING #( keys )
        RESULT DATA(l_tab_customers)
        FAILED DATA(l_tab_failed).

    "Add entities that couldn't be read to failed response table
    failed = CORRESPONDING #( DEEP l_tab_failed ).

    LOOP AT l_tab_customers INTO DATA(l_wrk_customer).
      APPEND VALUE #( %tky = l_wrk_customer-%tky
                      %state_area = 'VALIDATE_MANDATORY'
                    ) TO reported-customer.
      IF l_wrk_customer-Name1 IS INITIAL
        OR l_wrk_customer-Street IS INITIAL
        OR l_wrk_customer-HouseNo IS INITIAL
        OR l_wrk_customer-PostCode IS INITIAL
        OR l_wrk_customer-City IS INITIAL
        OR l_wrk_customer-Country IS INITIAL.

        APPEND VALUE #( %tky = l_wrk_customer-%tky ) TO failed-customer.
        APPEND VALUE #(
                         %tky = l_wrk_customer-%tky
                         %state_area = 'VALIDATE_MANDATORY'
                         %msg = new_message_with_text(
                             severity = if_abap_behv_message=>severity-error
                             text = 'Enter all mandatory fields'
                         )
                         %element-Name1 = COND #( WHEN l_wrk_customer-Name1 IS INITIAL THEN if_abap_behv=>mk-on )
                         %element-Street = COND #( WHEN l_wrk_customer-Street IS INITIAL THEN if_abap_behv=>mk-on )
                         %element-HouseNo = COND #( WHEN l_wrk_customer-HouseNo IS INITIAL THEN if_abap_behv=>mk-on )
                         %element-PostCode = COND #( WHEN l_wrk_customer-PostCode IS INITIAL THEN if_abap_behv=>mk-on )
                         %element-City = COND #( WHEN l_wrk_customer-City IS INITIAL THEN if_abap_behv=>mk-on )
                         %element-Country = COND #( WHEN l_wrk_customer-Country IS INITIAL THEN if_abap_behv=>mk-on )
                      ) TO reported-customer.

      ENDIF.
    ENDLOOP.



  ENDMETHOD.

  METHOD earlynumbering_create_phone.

    DATA: l_max_phone_id TYPE zjkr_numc3.

    READ ENTITIES OF zjkr_r_customer IN LOCAL MODE
        ENTITY Customer BY \_CustomerPhone
        FROM CORRESPONDING #( entities )
        LINK DATA(l_tab_cust_phones).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<l_wrk_customer>) GROUP BY <l_wrk_customer>-CustomerID.
      l_max_phone_id = REDUCE #(
          INIT max = CONV zjkr_numc3( '0' )
          FOR l_wrk_phone IN l_tab_cust_phones USING KEY entity WHERE ( source-customerID = <l_wrk_customer>-CustomerID )
          NEXT max = COND zjkr_numc3( WHEN l_wrk_phone-target-PhoneID > max THEN l_wrk_phone-target-PhoneID ELSE max )
     ).

      l_max_phone_id = REDUCE #(
         INIT max = l_max_phone_id
         FOR l_wrk_entity IN entities USING KEY entity WHERE ( CustomerID = <l_wrk_customer>-CustomerID )
         FOR l_wrk_target IN l_wrk_entity-%target
         NEXT max  = COND zjkr_numc3( WHEN l_wrk_target-PhoneID > max THEN l_wrk_target-PhoneID ELSE max  )
      ).

      LOOP AT <l_wrk_customer>-%target ASSIGNING FIELD-SYMBOL(<l_wrk_target>).
        APPEND CORRESPONDING #(  <l_wrk_target> ) TO mapped-customerphone ASSIGNING FIELD-SYMBOL(<l_wrk_mapped>).
        IF <l_wrk_mapped>-PhoneID IS INITIAL.
          l_max_phone_id += 1.
          <l_wrk_mapped>-PhoneID = l_max_phone_id.
        ENDIF.
      ENDLOOP.


    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create_email.

    READ ENTITIES OF zjkr_r_customer IN LOCAL MODE
      ENTITY Customer BY \_CustomerEmail
      FROM CORRESPONDING #( entities )
      LINK DATA(l_tab_emails).


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<l_wrk_customer>) GROUP BY <l_wrk_customer>-customerId.

      LOOP AT <l_wrk_customer>-%target ASSIGNING FIELD-SYMBOL(<l_wrk_email>).
        DATA(l_emaild) = REDUCE zjkr_numc3(
            INIT max = CONV #( '0' )
            FOR email IN l_tab_emails USING KEY entity WHERE ( source-customerId = <l_wrk_customer>-CustomerID )
            NEXT max = COND #( WHEN email-target-emailid > max THEN email-target-EmailId ELSE max )
        ).

        l_emaild = REDUCE #(
            INIT max = l_emaild
            FOR entity IN entities USING KEY entity WHERE ( CustomerID = <l_wrk_customer>-CustomerID )
              FOR target IN entity-%target
                NEXT max = COND #( WHEN target-EmailId > max THEN target-EmailId ELSE max )
        ).
      ENDLOOP.
      APPEND CORRESPONDING #( <l_wrk_email> ) TO mapped-customeremail ASSIGNING FIELD-SYMBOL(<l_wrk_mapped>).
      IF <l_wrk_mapped>-EmailId IS INITIAL.
        l_emaild += 1.
        <l_wrk_mapped>-EmailId = l_emaild.
      ENDIF.
    ENDLOOP.




  ENDMETHOD.

ENDCLASS.
