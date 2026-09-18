*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_UTFIELDCATALOG_MAC                             *
*----------------------------------------------------------------------*

DEFINE FILL_ADM_INFO.
  MOVE-CORRESPONDING SY TO &1.
  IF &1-CR_UNAME IS INITIAL.
    MOVE SY-UNAME TO &1-CR_UNAME.
    MOVE SY-REPID TO &1-CR_REPID.
    MOVE SY-UZEIT TO &1-CR_UZEIT.
    MOVE SY-DATUM TO &1-CR_DATUM.
  ENDIF.
END-OF-DEFINITION.
