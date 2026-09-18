function /sie/hr_idp_check_conversion.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(LOGICAL_FIELD) TYPE  /SIE/HR_IDP_FNAME
*"             VALUE(CONVERSION) TYPE  /SIE/HR_IDP_KONVNAM
*"       EXCEPTIONS
*"              NOT_ALLOWED
*"              TYPE_NOT_FOUND
*"----------------------------------------------------------------------

  data: l_field type inttype
      , l_length type ddleng
      , l_dblength type ddleng
      , l_type type dynptype
      , l_decimals type decimals
      , l_sign type signflag
      .

  if not ( conversion is initial ).

* Ermittlung aller Typen in der Konvertierung
    perform read_conversion_types using conversion.

* Ermittlung des Typs des logischen Feldnamens.
    perform read_fieldname_type using logical_field
                                changing l_field
                                         l_length
                                         l_dblength
                                         l_type
                                         l_decimals
                                         l_sign.

    if l_field in g_itab_types.
      if l_field = space.
        message e235 with logical_field raising type_not_found.
      else.
*       do nothing and exit gracefully!
      endif.
    else.
      message e236 with conversion logical_field
                   raising not_allowed.
    endif.
  else.
*  do nothing and exit gracefully!
  endif.

endfunction.
