*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F700 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FILL_RELEASED
*&---------------------------------------------------------------------*
FORM FILL_RELEASED.

  DATA: L_WA_VERSION TYPE /SIE/HR_IDP_S1VN
      , L_S1R TYPE /SIE/HR_IDP_S1R
      , L_WA_S1F TYPE /SIE/HR_IDP_S1F
      , H_VRSNR TYPE /SIE/HR_IDP_S1VN-VRSNR
      , FL_X TYPE XFLAG
      , FL_RELE TYPE XFLAG
  , L_D1 TYPE D
  , L_D2 TYPE D
  , FL_RELEASED TYPE XFLAG
  , FL_ACCEPT TYPE XFLAG
  .

  CLEAR G_RELEASED[]. CLEAR FL_RELEASED.

  SORT G_IFDATA_1000-S1VN BY VRSNR DESCENDING.

  LOOP AT G_IFDATA_1000-S1VN INTO L_WA_VERSION.
    CALL FUNCTION '/SIE/HR_IDP_RELE_DATE'
         EXPORTING
              VRSNR        = L_WA_VERSION-VRSNR
              S1F          = G_IFDATA_1000-S1F
         IMPORTING
              RELEASE_DATE = L_D1
              ACCEPT_DATE  = L_D2.

    IF L_D1 IS INITIAL.
      FL_RELEASED = NO.
    ELSE.
      FL_RELEASED = YES.
    ENDIF.

    IF L_D2 IS INITIAL.
      FL_ACCEPT = NO.
    ELSE.
      FL_ACCEPT = YES.
    ENDIF.

    IF FL_RELEASED = NO.
      WRITE ICON_RED_LIGHT TO G_RELEASED-ICON.
    ELSE.
      IF FL_ACCEPT = NO.
        IF FL_RELE = NO.
          FL_RELE = YES.
          WRITE ICON_YELLOW_LIGHT TO G_RELEASED-ICON.
          FL_X = YES.
        ELSE.
          CLEAR G_RELEASED-ICON.
        ENDIF.
      ELSE.
        IF FL_X = NO.
          FL_X = YES.
          FL_RELE = YES.
          WRITE ICON_GREEN_LIGHT TO G_RELEASED-ICON.
        ELSE.
          CLEAR G_RELEASED-ICON.
        ENDIF.
      ENDIF.
    ENDIF.
    G_RELEASED-VRSNR = L_WA_VERSION-VRSNR.

    H_VRSNR = G_IFDATA_VERS.
    G_IFDATA_VERS = L_WA_VERSION-VRSNR.
    CLEAR G_PROC_VEC-S1R.
    PERFORM READ_S1R.
    G_IFDATA_VERS = H_VRSNR.

    READ TABLE G_IFDATA_1000-S1F WITH KEY
                                 IFCID = G_IFDATA_TRAN-S1-IFCID
                                 VRSNR = L_WA_VERSION-VRSNR
                                 TROLE = '06'
                                 INTO L_WA_S1F.
    IF SY-SUBRC = 0.
      G_RELEASED-RELEASE_NAME = L_WA_S1F-CH_UNAME.
      G_RELEASED-RELEASE_DATE = L_WA_S1F-CH_DATUM.
      G_RELEASED-RELEASE_TEXT = L_WA_S1F-LTEXT.
    ELSE.
      CLEAR: G_RELEASED-RELEASE_NAME
           , G_RELEASED-RELEASE_DATE
           , G_RELEASED-RELEASE_TEXT
           .
    ENDIF.

    READ TABLE G_IFDATA_1000-S1F WITH KEY
                                 IFCID = G_IFDATA_TRAN-S1-IFCID
                                 VRSNR = L_WA_VERSION-VRSNR
                                 TROLE = '07'
                                 INTO L_WA_S1F.
    IF SY-SUBRC = 0.
      G_RELEASED-ACCEPT_NAME = L_WA_S1F-CH_UNAME.
      G_RELEASED-ACCEPT_DATE = L_WA_S1F-CH_DATUM.
      G_RELEASED-ACCEPT_TEXT = L_WA_S1F-LTEXT.
    ELSE.
      CLEAR: G_RELEASED-RELEASE_NAME
           , G_RELEASED-RELEASE_DATE
           , G_RELEASED-RELEASE_TEXT.
      .
    ENDIF.

    APPEND G_RELEASED.
  ENDLOOP.

  DESCRIBE TABLE G_RELEASED LINES TAB_LINES.
  TC_RELEASED-LINES = TAB_LINES.


ENDFORM.                    " FILL_RELEASED

*&---------------------------------------------------------------------*
*&      Form  DELETE_RECNA_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_RECNA_VALUES.

  DATA: ITAB_SATZART_VALUES TYPE VRM_VALUES WITH HEADER LINE.

  CLEAR ITAB_SATZART_VALUES[].
  ITAB_SATZART_VALUES-KEY = '1'.
  ITAB_SATZART_VALUES-TEXT = 'Vorlaufsatz'.
  APPEND ITAB_SATZART_VALUES.
  ITAB_SATZART_VALUES-KEY = '3'.
  ITAB_SATZART_VALUES-TEXT = 'Einmaldaten'.
  APPEND ITAB_SATZART_VALUES.
  ITAB_SATZART_VALUES-KEY = '4'.
  ITAB_SATZART_VALUES-TEXT = 'Wiederholdaten'.
  APPEND ITAB_SATZART_VALUES.
  ITAB_SATZART_VALUES-KEY = '5'.
  ITAB_SATZART_VALUES-TEXT = 'Nachlaufsatz'.
  APPEND ITAB_SATZART_VALUES.

  CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            ID              = '/SIE/HR_IDP_S1SA-RECTY'
            VALUES          = ITAB_SATZART_VALUES[]
       EXCEPTIONS
            ID_ILLEGAL_NAME = 1
            OTHERS          = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " DELETE_RECNA_VALUES
