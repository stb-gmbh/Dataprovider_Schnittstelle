*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_STAT_F01 .
*----------------------------------------------------------------------*
FORM F4_JUPER.

  TYPES: BEGIN OF TY_S_F4JUPER
        , JUPER LIKE /SIE/HR_JUP_TAB-JUPER
        , KURZTEXT LIKE /SIE/HR_JUP_TAB-KURZTEXT
        , BEGDA LIKE /SIE/HR_JUP_TAB-BEGDA
        , ENDDA LIKE /SIE/HR_JUP_TAB-ENDDA
        , END OF TY_S_F4JUPER
        , TY_T_F4JUPER TYPE STANDARD TABLE OF TY_S_F4JUPER
          INITIAL SIZE 0
        .

  DATA: L_REPID LIKE SY-REPID
      , L_DYNNR LIKE SY-DYNNR
      .

DATA: GET_HELP_FIELD   LIKE HELP_INFO-DYNPROFLD.

  STATICS: LT_F4JUPER TYPE TY_T_F4JUPER
         .

  DATA: LS_F4JUPER TYPE TY_S_F4JUPER.

  GET CURSOR FIELD GET_HELP_FIELD.
  L_REPID = SY-REPID.
  L_DYNNR = SY-DYNNR.

  DESCRIBE TABLE LT_F4JUPER.
  IF SY-TFILL = 0.
    SELECT * FROM /SIE/HR_JUP_TAB.
      MOVE-CORRESPONDING /SIE/HR_JUP_TAB TO LS_F4JUPER.
      APPEND LS_F4JUPER TO LT_F4JUPER.
    ENDSELECT.
  ELSE.
* NOP
  ENDIF.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
       EXPORTING
            RETFIELD        = 'JUPER'
            DYNPPROG        = L_REPID
            DYNPNR          = L_DYNNR
            DYNPROFIELD     = GET_HELP_FIELD
            VALUE_ORG       = 'S'
            MULTIPLE_CHOICE = NO
       TABLES
            VALUE_TAB       = LT_F4JUPER
       EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.





ENDFORM.                                                    " F4_JUPER
