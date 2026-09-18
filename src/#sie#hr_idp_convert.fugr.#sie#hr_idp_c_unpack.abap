FUNCTION /SIE/HR_IDP_C_UNPACK.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(P_IN)
*"             VALUE(P_PARAMETERS) TYPE  /SIE/HR_IDP_KONVPARA
*"                             OPTIONAL
*"       EXPORTING
*"             VALUE(P_OUT)
*"----------------------------------------------------------------------
*" 20141106 ML    Unicode-Umstellung (INC5560081)                  ML001
*"----------------------------------------------------------------------

  DATA: SIGN TYPE C.

** Machine state data
  DATA: DUMMY_PARAM TYPE TY_PARAM                 " Zur Übersetzung
     , FL_NEGATIVE TYPE TY_YESNO                 " Vorzeichen ausgeben?
     , FL_SIGN_SUFFIX TYPE TY_YESNO              " Vz vorne od. hinten?
     , FL_SIGN_POSITIVE TYPE TY_YESNO            " Pluszeichen auch?
     , CHAR_SIGN TYPE C                          " Vorzeichen plus?
     , NUM_DECIMALS TYPE DECIMALS                " Anz. Dezimalstellen?
     , CHAR_SEPERATOR                            " Komma, Punkt
     , OUTPUT_LENGTH TYPE I
     .

* Parsing data
  DATA: T_PARAM TYPE TY_TPAIR
      .

  FIELD-SYMBOLS: <CHAR_DUMMY>
               , <DUMMY>
               , <FMASK>
               .

* Die übergebenen Parameter ins interne Format übersetzen.
  PERFORM PARSE_PARAMETERS USING P_PARAMETERS
                           CHANGING T_PARAM.

* Dezimalzeichen ?
*  perform parse_values using t_param
*                             'dc'                           "#EC NOTEXT
*                       changing dummy_param.
*  num_decimals = dummy_param.
*  describe field p_in decimals num_decimals.

* Vorzeichen anzeigen?
*  perform parse_values using t_param
*                             'sgn'                          "#EC NOTEXT
*                       changing dummy_param.
*  if dummy_param = 'NO'.
*    fl_negative = no.
*  else.
*    fl_negative = yes.
*  endif.

* Positives Vorzeichen auch ausgeben?
*  perform parse_values using t_param
*                             'shpo'                         "#EC NOTEXT
*                       changing dummy_param.
*  if dummy_param = 'YES'.
*    fl_sign_positive = no.
*  else.
*    fl_sign_positive = yes.
*  endif.

* Vorzeichen als prefix/suffix
*  perform parse_values using t_param
*                             'sgnp'                         "#EC NOTEXT
*                        changing dummy_param.
*  case dummy_param.
*    when 'L'.
*      fl_sign_suffix = yes.
*    when 'R'.
*      fl_sign_suffix = no.
*    when others.
*      fl_sign_suffix = no.
*  endcase.

* Dezimaltrennzeichen?
  PERFORM PARSE_VALUES USING T_PARAM
                             'decp'                         "#EC NOTEXT
                       CHANGING DUMMY_PARAM.
  CASE DUMMY_PARAM.
    WHEN '.'.                                               "#EC NOTEXT
      CHAR_SEPERATOR = '.'.                                 "#EC NOTEXT
    WHEN ','.                                               "#EC NOTEXT
      CHAR_SEPERATOR = ','.                                 "#EC NOTEXT
    WHEN OTHERS.
      CHAR_SEPERATOR = SPACE.
  ENDCASE.

  PERFORM PARSE_VALUES USING T_PARAM
                             'sign'
                       CHANGING DUMMY_PARAM.
  SIGN = DUMMY_PARAM(1).

*  call function '/SIE/HR_IDP_CONVERT_P_TO_C'
*       exporting
*            imp_pfeld = p_in
*            imp_nopls = fl_sign_positive
*            imp_umsdc = yes
*            imp_anzdc = num_decimals
*            imp_vzlor = fl_sign_suffix
*            imp_trenn = char_seperator
*       changing
*            chg_cfeld = p_out.
*
*  CASE FL_SIGN_SUFFIX.
*    WHEN YES.     " Vz. Links
*      CASE FL_SIGN_POSITIVE.
*        WHEN YES.
*          SIGN = '2'.
*        WHEN NO.
*          SIGN = '3'.
*        WHEN OTHERS.
*          SIGN = SPACE.
*      ENDCASE.
*    WHEN NO.     " Vz. Rechts
*      CASE FL_SIGN_POSITIVE.
*        WHEN YES.
*          SIGN = '0'.
*        WHEN NO.
*          SIGN = '1'.
*        WHEN OTHERS.
*          SIGN = SPACE.
*      ENDCASE.
*    WHEN OTHERS.
*      SIGN = SPACE.
*  ENDCASE.

  DESCRIBE FIELD P_OUT LENGTH OUTPUT_LENGTH IN CHARACTER MODE. "ML001 Umstellung UNICODE ka20150821

  CALL FUNCTION '/SIE/HR_IDP_C_P2C'
       EXPORTING
            OUTPUT_LENGTH         = OUTPUT_LENGTH
            SIGN                  = SIGN
            DECIMAL_CHARACTER     = CHAR_SEPERATOR
            PACKED_VALUE          = P_IN
       CHANGING
            UNPACKED_VALUE        = P_OUT
       EXCEPTIONS
            NOT_A_NUMBER          = 1
            FIELD_LENGTH_MISMATCH = 2
            OTHERS                = 3.
  IF SY-SUBRC <> 0.
    CLEAR P_OUT.
  ENDIF.

ENDFUNCTION.
