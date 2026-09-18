FUNCTION /SIE/HR_IDP_FILENAMES.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID OPTIONAL
*"             VALUE(ITYPE) TYPE  /SIE/HR_IDP_ITYPE
*"             VALUE(VRSNR) TYPE  /SIE/HR_IDP_VERS_NR OPTIONAL
*"             VALUE(PROGRAM_NAME) TYPE  REPID
*"             VALUE(LOGICAL_FILENAME) TYPE  FILEINTERN OPTIONAL
*"       EXPORTING
*"             VALUE(FILEN_DATA) TYPE  TEXT256
*"             VALUE(FILEN_SD) TYPE  TEXT256
*"       EXCEPTIONS
*"              FILE_NOT_FOUND
*"----------------------------------------------------------------------
  DATA: PARAM_1(100)
      , PARAM_2(100)
      , PARAM_3(100)
      , LOGICAL_NAME TYPE FILEINTERN
      , DIRECTORY TYPE TEXT256
      , DIRECTORY_SD TYPE TEXT256
      .

  PERFORM CREATE_PARAMETERS USING IFCID
                                  VRSNR
                                  ITYPE
                                  PROGRAM_NAME
                            CHANGING PARAM_1
                                     PARAM_2
                                     PARAM_3.

* Schnittstellenausgabedatei
  CASE LOGICAL_NAME.
    WHEN SPACE.
      LOGICAL_NAME = '/SIE/HR_IDP'.                         "#EC NOTEXT
    WHEN OTHERS.
      LOGICAL_NAME = LOGICAL_FILENAME.
  ENDCASE.

  PERFORM CREATE_FILENAME USING LOGICAL_NAME
                                PARAM_1
                                PARAM_2
                                PARAM_3
                          CHANGING FILEN_DATA.

* Directory Anlegen falls er noch nicht existiert.
  PERFORM CREATE_FILENAME USING LOGICAL_NAME
                                SPACE
                                SPACE
                                PARAM_3
                          CHANGING DIRECTORY.

  CALL FUNCTION '/SIE/HR_IDP_DIRECTORY'
       EXPORTING
            DIRECTORY           = DIRECTORY
       EXCEPTIONS
            DIRECTORY_NOT_FOUND = 1
            OTHERS              = 2.
  IF SY-SUBRC >< 0.
    RAISE FILE_NOT_FOUND.
  ELSE.
    COMMIT WORK.
  ENDIF.

* Sendeauftrag
  LOGICAL_NAME = '/SIE/HR_IDP_SD'.                          "#EC NOTEXT
  PERFORM CREATE_FILENAME USING LOGICAL_NAME
                                PARAM_1
                                PARAM_2
                                PARAM_3
                          CHANGING FILEN_SD.

* Directory Anlegen falls er noch nicht existiert.
  PERFORM CREATE_FILENAME USING LOGICAL_NAME
                                SPACE
                                SPACE
                                PARAM_3
                          CHANGING DIRECTORY_SD.

  SEARCH DIRECTORY_SD FOR '.SD'.
  IF SY-SUBRC = 0.
    DIRECTORY_SD = DIRECTORY_SD(SY-FDPOS).
  ELSE.
    RAISE FILE_NOT_FOUND.
  ENDIF.

  CALL FUNCTION '/SIE/HR_IDP_DIRECTORY'
       EXPORTING
            DIRECTORY           = DIRECTORY_SD
       EXCEPTIONS
            DIRECTORY_NOT_FOUND = 1
            OTHERS              = 2.
  IF SY-SUBRC >< 0.
    RAISE FILE_NOT_FOUND.
  ELSE.
    COMMIT WORK.
  ENDIF.

ENDFUNCTION.
