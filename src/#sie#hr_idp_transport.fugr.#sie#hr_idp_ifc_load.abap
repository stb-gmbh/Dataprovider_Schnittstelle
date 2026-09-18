FUNCTION /SIE/HR_IDP_IFC_LOAD.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  CHANGING
*"     VALUE(IFC_DATA) TYPE  /SIE/HR_IDP_IFC_DB
*"----------------------------------------------------------------------
* 20150527 ML   Unicode (Aus2Mach1)                                UNI1

  DATA: LT_BUFFER TYPE T_XML_FILE
      , LS_BUFFER TYPE S_XML_FILE
      , T_XML TYPE T_XML_FILE
      , T_ATTRIBUTES TYPE /SIE/HR_IDP_TT_ATTRIBUTES
      , S_ATTRIBUTES TYPE /SIE/HR_IDP_PAIRS
      , S_ATTRIBUTE TYPE /SIE/HR_IDP_PAIR
      , WA_S1SA TYPE /SIE/HR_IDP_S1SA
      , WA_S1PG TYPE /SIE/HR_IDP_S1PG
      , CHAR1(1) TYPE C
      , EXIT TYPE TY_YESNO
      .

* Prüfen ob das Sst. Layout schon existiert
  IF NOT ( IFC_DATA-S1SA[] IS INITIAL ).
    CALL FUNCTION 'POPUP_TO_CONFIRM_LOSS_OF_DATA'
         EXPORTING
              TEXTLINE1    = 'Möchten Sie das aktuelle Layout'(101)
              TEXTLINE2    = 'trotzdem löschen?'(102)
              TITEL        = 'Aktuelles Layout löschen'(103)
              START_COLUMN = 25
              START_ROW    = 6
         IMPORTING
              ANSWER       = CHAR1
         EXCEPTIONS
              OTHERS       = 1.
    IF SY-SUBRC EQ 0 AND CHAR1 EQ 'J'.
      EXIT = NO.
    ELSE.
      EXIT = YES. "operation abbrechen
    ENDIF.
  ENDIF.

  CHECK EXIT = NO.

* UNI1 begin
*  data: t_filetable   type filetable.
*  data: l_rc          type i.
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
**    EXPORTING
**      WINDOW_TITLE            =
**      DEFAULT_EXTENSION       =
**      DEFAULT_FILENAME        =
**      FILE_FILTER             =
**      WITH_ENCODING           =
**      INITIAL_DIRECTORY       =
**      MULTISELECTION          =
*    CHANGING
*      FILE_TABLE              = t_filetable
*      RC                      = l_rc
**      USER_ACTION             =
**      FILE_ENCODING           = c_encoding
**    EXCEPTIONS
**      FILE_OPEN_DIALOG_FAILED = 1
**      CNTL_ERROR              = 2
**      ERROR_NO_GUI            = 3
**      NOT_SUPPORTED_BY_GUI    = 4
**      others                  = 5
*          .
*  IF SY-SUBRC <> 0.
**   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*  data: l_filename type string.
*  loop at t_filetable into l_filename.
*  endloop.
*    DATA: LT_BUFFER2 TYPE T_XML_FILE.
*
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
*    EXPORTING
*      FILENAME                = l_filename
*      FILETYPE                = 'BIN'
**      HAS_FIELD_SEPARATOR     = SPACE
**      HEADER_LENGTH           = 0
**      READ_BY_LINE            = 'X'
**      DAT_MODE                = SPACE
*      CODEPAGE                = '1110'
**      IGNORE_CERR             = ABAP_TRUE
**      REPLACEMENT             = '#'
**      VIRUS_SCAN_PROFILE      =
**    IMPORTING
**      FILELENGTH              =
**      HEADER                  =
*    CHANGING
*      DATA_TAB                = LT_BUFFER2
**      ISSCANPERFORMED         = SPACE
**    EXCEPTIONS
**      FILE_OPEN_ERROR         = 1
**      FILE_READ_ERROR         = 2
**      NO_BATCH                = 3
**      GUI_REFUSE_FILETRANSFER = 4
**      INVALID_TYPE            = 5
**      NO_AUTHORITY            = 6
**      UNKNOWN_ERROR           = 7
**      BAD_DATA_FORMAT         = 8
**      HEADER_NOT_ALLOWED      = 9
**      SEPARATOR_NOT_ALLOWED   = 10
**      HEADER_TOO_LONG         = 11
**      UNKNOWN_DP_ERROR        = 12
**      ACCESS_DENIED           = 13
**      DP_OUT_OF_MEMORY        = 14
**      DISK_FULL               = 15
**      DP_TIMEOUT              = 16
**      NOT_SUPPORTED_BY_GUI    = 17
**      ERROR_NO_GUI            = 18
**      others                  = 19
*          .
*  IF SY-SUBRC <> 0.
**   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
* UNI1 end

  CALL FUNCTION 'UPLOAD'
       EXPORTING
            CODEPAGE                = '1110'
       TABLES
            DATA_TAB                = LT_BUFFER
       EXCEPTIONS
            CONVERSION_ERROR        = 1
            INVALID_TABLE_WIDTH     = 2
            INVALID_TYPE            = 3
            NO_BATCH                = 4
            UNKNOWN_ERROR           = 5
            GUI_REFUSE_FILETRANSFER = 6
            OTHERS                  = 7.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* translate escape characters
   LOOP AT LT_BUFFER INTO LS_BUFFER.
     IF LS_BUFFER CA '&amp;'.
       REPLACE '&amp;' WITH '&' INTO LS_BUFFER.
       MODIFY LT_BUFFER FROM LS_BUFFER.
     ENDIF.
   ENDLOOP.

* Layout
  PERFORM GET_TAG  TABLES LT_BUFFER
                          T_XML
                   USING 'layout'.                          "#EC NOTEXT

  LOOP AT LT_BUFFER INTO LS_BUFFER.

    PERFORM GET_TAG_ATTRIBUTES USING  'recordtype'          "#EC NOTEXT
                                      LS_BUFFER
                               CHANGING T_ATTRIBUTES.

    PERFORM GET_TAG_ATTRIBUTES USING  'field'               "#EC NOTEXT
                                      LS_BUFFER
                               CHANGING T_ATTRIBUTES.

  ENDLOOP.

  CLEAR IFC_DATA-S1SA[].
  CLEAR IFC_DATA-S1PG[].

* Befüllen der Schnittstelleninformationen
  WA_S1SA-IFCID = IFC_DATA-S1-IFCID.
  WA_S1SA-VRSNR = IFC_DATA-S1VN-VRSNR.
  WA_S1PG-IFCID = IFC_DATA-S1-IFCID.
  WA_S1PG-VRSNR = IFC_DATA-S1VN-VRSNR.

  LOOP AT T_ATTRIBUTES INTO S_ATTRIBUTES.
    CASE S_ATTRIBUTES-NODE_NAME.
      WHEN 'recordtype'.
        LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
          CASE S_ATTRIBUTE-ATTRIBUTENAME.
            WHEN 'name'.
              WA_S1SA-RECNA = S_ATTRIBUTE-VALUE(8).
              WA_S1PG-RECNA = WA_S1SA-RECNA.
            WHEN 'dbahd'. WA_S1SA-DBAHD = S_ATTRIBUTE-VALUE.
            WHEN 'dbaoc'. WA_S1SA-DBAOC = S_ATTRIBUTE-VALUE.
            WHEN 'recty'. WA_S1SA-RECTY = S_ATTRIBUTE-VALUE(1).
            WHEN 'infty'. WA_S1SA-INFTY = S_ATTRIBUTE-VALUE(4).
            WHEN 'subty'. WA_S1SA-SUBTY = S_ATTRIBUTE-VALUE(4).
            WHEN 'kzsrn'. WA_S1SA-KZSRN = S_ATTRIBUTE-VALUE(1).
            WHEN 'kzspn'. WA_S1SA-KZSPN = S_ATTRIBUTE-VALUE(1).
            WHEN 'sortn'. WA_S1SA-SORTN = S_ATTRIBUTE-VALUE.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
        WA_S1SA-IFCID = IFC_DATA-S1-IFCID.
        WA_S1SA-VRSNR = IFC_DATA-S1VN-VRSNR.
        APPEND WA_S1SA TO IFC_DATA-S1SA.
      WHEN 'field'.
        LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
          CASE S_ATTRIBUTE-ATTRIBUTENAME.
            WHEN 'fname'.   WA_S1PG-FELDNAME = S_ATTRIBUTE-VALUE.
            WHEN 'fldps'.   WA_S1PG-FLDPS = S_ATTRIBUTE-VALUE.
            WHEN 'mthbk'.   WA_S1PG-MTHBK = S_ATTRIBUTE-VALUE.
            WHEN 'konvnam'. WA_S1PG-KONVNAM = S_ATTRIBUTE-VALUE.
            WHEN 'keypos'.  WA_S1PG-KEYPOS = S_ATTRIBUTE-VALUE.
            WHEN 'param'.   WA_S1PG-PARAM = S_ATTRIBUTE-VALUE.
            WHEN 'offst'.   WA_S1PG-OFFST = S_ATTRIBUTE-VALUE.
            WHEN 'length'.
              WA_S1PG-LENGTH = S_ATTRIBUTE-VALUE.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
        WA_S1PG-IFCID = IFC_DATA-S1-IFCID.
        WA_S1PG-VRSNR = IFC_DATA-S1VN-VRSNR.
        APPEND WA_S1PG TO IFC_DATA-S1PG.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFUNCTION.
