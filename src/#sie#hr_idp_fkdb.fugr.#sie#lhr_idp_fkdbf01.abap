*----------------------------------------------------------------------*
*   INCLUDE /SIE/LHR_IDP_DBF01                                         *
*----------------------------------------------------------------------*
FORM READ_S1 USING INTERFACE TYPE /SIE/HR_IDP_INTERFACE_ID
                   BYPASS_BUFFER TYPE XFLAG
             CHANGING INTERFACE_DESCRIPTION TYPE /SIE/HR_IDP_S1
                      INTERFACE_TEXT TYPE /SIE/HR_IDP_S1T
                      RC TYPE SYSUBRC.

  TYPES: L_S1 TYPE /SIE/HR_IDP_S1
       , L_S1T TYPE /SIE/HR_IDP_S1T
       , T_S1 TYPE SORTED TABLE OF L_S1 WITH UNIQUE DEFAULT KEY
                   INITIAL SIZE 0
       , T_S1T TYPE SORTED TABLE OF L_S1T WITH UNIQUE DEFAULT KEY
                   INITIAL SIZE 0
       .

  STATICS: ITAB_S1 TYPE T_S1
          , ITAB_S1T TYPE T_S1T
          , WA_S1T TYPE L_S1T
          , WA_S1 TYPE L_S1
          .

  DESCRIBE TABLE ITAB_S1.
  IF SY-TFILL EQ 0 OR BYPASS_BUFFER = 'X'.                  "#EC NOTEXT
    SELECT * FROM /SIE/HR_IDP_S1 INTO TABLE ITAB_S1.
    SELECT * FROM /SIE/HR_IDP_S1T INTO TABLE ITAB_S1T.
  ENDIF.

  CLEAR INTERFACE_DESCRIPTION.
  READ TABLE ITAB_S1 INTO WA_S1 WITH KEY IFCID = INTERFACE.
  IF SY-SUBRC = 0.
    INTERFACE_DESCRIPTION = WA_S1.
    READ TABLE ITAB_S1T INTO WA_S1T WITH KEY SPRAS = SY-LANGU
                                             IFCID = INTERFACE.
    IF SY-SUBRC = 0.
      INTERFACE_TEXT = WA_S1T.
    ELSE.
      CLEAR INTERFACE_TEXT.
    ENDIF.
  ELSE.
    CLEAR INTERFACE_TEXT.
    RC = 1.
*   Die Schnittstelle &1 wurde noch nicht angelegt.
  ENDIF.

ENDFORM.
