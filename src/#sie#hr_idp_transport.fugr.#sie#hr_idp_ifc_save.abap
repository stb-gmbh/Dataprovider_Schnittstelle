FUNCTION /SIE/HR_IDP_IFC_SAVE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(DB_DATA) TYPE  /SIE/HR_IDP_IFC_DB
*"     VALUE(FL_ENVELOPE) TYPE  XFELD DEFAULT 'X'
*"  EXCEPTIONS
*"      NO_IFACE
*"----------------------------------------------------------------------
* 20150527 ML   Unicode (Aus2Mach1)                                UNI1

  TYPES: BEGIN OF S_DATA
       , TEXT(1000)
       , END OF S_DATA
       , T_DATA TYPE STANDARD TABLE OF S_DATA INITIAL SIZE 0
       .

  DATA: DBSEL TYPE /SIE/HR_IDP_DB_SEL VALUE C_ALL_TABL
      , DB_IFACE TYPE  /SIE/HR_IDP_IFC_DB
      , FILE_NAME TYPE RLGRAP-FILENAME
      , LT_BUFFER TYPE T_DATA
      .

  CALL FUNCTION '/SIE/HR_IDP_WRITE_TO_XML'
       EXPORTING
            FL_ENVELOPE = FL_ENVELOPE
            DB_DATA     = DB_DATA
       TABLES
            XML_DATA    = LT_BUFFER.

  CONCATENATE DB_DATA-S1-IFCID
              '-V'                                          "#EC NOTEXT
              DB_DATA-S1VN-VRSNR
              '.xml'                                        "#EC NOTEXT
       INTO FILE_NAME.

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
*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
*    EXPORTING
**      BIN_FILESIZE              =
*      FILENAME                  = l_filename
*      FILETYPE                  = 'ASC'
**      APPEND                    = SPACE
**      WRITE_FIELD_SEPARATOR     = SPACE
**      HEADER                    = '00'
**      TRUNC_TRAILING_BLANKS     = SPACE
**      WRITE_LF                  = 'X'
**      COL_SELECT                = SPACE
**      COL_SELECT_MASK           = SPACE
**      DAT_MODE                  = SPACE
**      CONFIRM_OVERWRITE         = SPACE
**      NO_AUTH_CHECK             = SPACE
**      CODEPAGE                  = SPACE
**      IGNORE_CERR               = ABAP_TRUE
**      REPLACEMENT               = '#'
**      WRITE_BOM                 = SPACE
**      TRUNC_TRAILING_BLANKS_EOL = 'X'
**      WK1_N_FORMAT              = SPACE
**      WK1_N_SIZE                = SPACE
**      WK1_T_FORMAT              = SPACE
**      WK1_T_SIZE                = SPACE
**      SHOW_TRANSFER_STATUS      = 'X'
**      FIELDNAMES                =
**      WRITE_LF_AFTER_LAST_LINE  = 'X'
**    IMPORTING
**      FILELENGTH                =
*    CHANGING
*      DATA_TAB                  = LT_BUFFER
*    EXCEPTIONS
*      FILE_WRITE_ERROR          = 1
*      NO_BATCH                  = 2
*      GUI_REFUSE_FILETRANSFER   = 3
*      INVALID_TYPE              = 4
*      NO_AUTHORITY              = 5
*      UNKNOWN_ERROR             = 6
*      HEADER_NOT_ALLOWED        = 7
*      SEPARATOR_NOT_ALLOWED     = 8
*      FILESIZE_NOT_ALLOWED      = 9
*      HEADER_TOO_LONG           = 10
*      DP_ERROR_CREATE           = 11
*      DP_ERROR_SEND             = 12
*      DP_ERROR_WRITE            = 13
*      UNKNOWN_DP_ERROR          = 14
*      ACCESS_DENIED             = 15
*      DP_OUT_OF_MEMORY          = 16
*      DISK_FULL                 = 17
*      DP_TIMEOUT                = 18
*      FILE_NOT_FOUND            = 19
*      DATAPROVIDER_EXCEPTION    = 20
*      CONTROL_FLUSH_ERROR       = 21
*      NOT_SUPPORTED_BY_GUI      = 22
*      ERROR_NO_GUI              = 23
*      others                    = 24
*          .
*  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.


  CALL FUNCTION 'DOWNLOAD'
       TABLES
            DATA_TAB                = LT_BUFFER
       EXCEPTIONS
            INVALID_FILESIZE        = 1
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

ENDFUNCTION.
