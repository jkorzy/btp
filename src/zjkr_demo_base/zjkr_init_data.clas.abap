CLASS zjkr_init_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS create_countries.
ENDCLASS.



CLASS ZJKR_INIT_DATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.



    create_countries( ).


*    l_tab_phones = VALUE #(
*        ( customer_id = '0000000001' phone_id = '001' country = 'PL' country_prefix = '0048' phone_no = '555111222'  default_phone = abap_true  )
*        ( customer_id = '0000000002' phone_id = '001' country = 'PL' country_prefix = '0048' phone_no = '777111222'  default_phone = abap_true  )
*    ).

*    MODIFY zjkr_cust_phone FROM TABLE @l_tab_phones.

  ENDMETHOD.


  METHOD create_countries.
    DATA l_tab_ctry TYPE STANDARD TABLE OF zjkr_ctry.
    DATA l_tab_ctryt TYPE STANDARD TABLE OF zjkr_ctryt.

    DELETE FROM zjkr_ctry.
    DELETE FROM zjkr_ctryt.

    l_tab_ctry = VALUE #(
        ( country_code = 'PL' prefix = '48' )
        ( country_code = 'GB' prefix = '44' )
        ( country_code = 'DE' prefix = '49' )
        ( country_code = 'CZ' prefix = '420' )
    ).

    l_tab_ctryt = VALUE #(
        ( country_code = 'PL' spras = 'E' country_text = 'Poland' )
        ( country_code = 'GB' spras = 'E' country_text = 'United Kingdom' )
        ( country_code = 'DE' spras = 'E' country_text = 'Germany' )
        ( country_code = 'CZ' spras = 'E' country_text = 'Czech Republic' )
        ( country_code = 'PL' spras = 'L' country_text = 'Polska' )
        ( country_code = 'GB' spras = 'L' country_text = 'Wielka Brytania' )
        ( country_code = 'DE' spras = 'L' country_text = 'Niemcy' )
        ( country_code = 'CZ' spras = 'L' country_text = 'Czechy' )
        ( country_code = 'PL' spras = 'D' country_text = 'Polem' )
        ( country_code = 'GB' spras = 'D' country_text = 'Großbritanien' )
        ( country_code = 'DE' spras = 'D' country_text = 'Deutschland' )
        ( country_code = 'CZ' spras = 'D' country_text = 'Tschechien' )
    ).


    INSERT zjkr_ctry FROM TABLE @l_tab_ctry.
    INSERT zjkr_ctryt FROM TABLE @l_tab_ctryt.

    COMMIT WORK.


  ENDMETHOD.
ENDCLASS.
