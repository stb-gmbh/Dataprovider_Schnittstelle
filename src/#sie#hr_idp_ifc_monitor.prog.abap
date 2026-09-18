*&---------------------------------------------------------------------*
*& Report  /SIE/HR_IDP_IFC_MONITOR                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Dieses Programm druckt eine Liste der Schnittstellen aus, die       *
*& aktuell freigegeben aber nicht abgenommen worden sind. Damit        *
*& kann man evtl. Schnittstellen die vom Kunden nicht abgenommen       *
*& werden aufspüren.                                                   *
*&---------------------------------------------------------------------*

REPORT  /SIE/HR_IDP_IFC_MONITOR       .

TABLES: /SIE/HR_IDP_S1
      , /SIE/HR_IDP_S1R
      , /SIE/HR_IDP_S1F
      .
INCLUDE /SIE/HR_IDP_TYPES.

TYPE-POOLS: SLIS.

DATA: GT_S1 TYPE STANDARD TABLE OF /SIE/HR_IDP_S1 INITIAL SIZE 0
            WITH HEADER LINE
    , VERSION TYPE /SIE/HR_IDP_VERS_NR
    , CURRENT_VERSION TYPE /SIE/HR_IDP_VERS_NR
    , CURRENT_RELEASED_VERSION TYPE /SIE/HR_IDP_VERS_NR
    , CURRENT_ACCEPTED_VERSION TYPE /SIE/HR_IDP_VERS_NR
    , G_DATA TYPE STANDARD TABLE OF /SIE/HR_IDP_MONITOR INITIAL SIZE 0
      WITH HEADER LINE
    , SEITE(3)
    , GC_FORMNAME_TOP_OF_PAGE TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE'
    , GT_EVENTS TYPE SLIS_T_EVENT.
.

* Listaufbereitung
DATA:   GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.
DATA:   GT_OUTTAB LIKE SIMLISTRUC OCCURS 0 WITH HEADER LINE.
DATA:   G_REPID LIKE SY-REPID.
DATA    GS_LAYOUT TYPE SLIS_LAYOUT_ALV.

PARAMETERS: STICHTAG TYPE D DEFAULT SY-DATUM.
PARAMETERS: MON_REL DEFAULT YES NO-DISPLAY.

START-OF-SELECTION.

  IF MON_REL = YES.

    SELECT * FROM /SIE/HR_IDP_S1 INTO TABLE GT_S1
                                 WHERE VALID_FROM LE STICHTAG
                                 AND   VALID_TO GE STICHTAG.

    LOOP AT GT_S1.

      CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
           EXPORTING
                INTERFACE         = GT_S1-IFCID
                ACTIVE            = YES
           IMPORTING
                VERSION           = VERSION
           EXCEPTIONS
                NO_ACTIVE_VERSION = 1
                OTHERS            = 2.
      CASE SY-SUBRC.
        WHEN 0.
          CALL FUNCTION '/SIE/HR_IDP_RELEASE_INFO'
               EXPORTING
                    INTERFACE_ID             = GT_S1-IFCID
                    VERSION                  = VERSION
               IMPORTING
                    CURRENT_VERSION          = CURRENT_VERSION
                    CURRENT_RELEASED_VERSION = CURRENT_RELEASED_VERSION
                    CURRENT_ACCEPTED_VERSION = CURRENT_ACCEPTED_VERSION.
        WHEN OTHERS.
          CLEAR: CURRENT_RELEASED_VERSION,
                 CURRENT_ACCEPTED_VERSION.
      ENDCASE.

      IF ( CURRENT_ACCEPTED_VERSION >< CURRENT_RELEASED_VERSION ).

        SELECT SINGLE * FROM /SIE/HR_IDP_S1R WHERE IFCID = GT_S1-IFCID
                      AND   VRSNR = CURRENT_RELEASED_VERSION
                      AND TROLE = '07'.                     "#EC NOTEXT
        IF SY-SUBRC = 0.
          G_DATA-IFCID = GT_S1-IFCID.
          G_DATA-VRNSR = CURRENT_RELEASED_VERSION.
          G_DATA-EMAIL = /SIE/HR_IDP_S1R-EMAIL.
        ELSE.
          G_DATA-IFCID = GT_S1-IFCID.
          G_DATA-VRNSR = CURRENT_RELEASED_VERSION.
          CLEAR G_DATA-EMAIL.
        ENDIF.

        SELECT SINGLE * FROM /SIE/HR_IDP_S1F WHERE IFCID = GT_S1-IFCID
                      AND   VRSNR = CURRENT_RELEASED_VERSION
                      AND TROLE = '06'.                     "#EC NOTEXT
        IF SY-SUBRC = 0.
          G_DATA-CH_DATUM = /SIE/HR_IDP_S1F-CH_DATUM.
        ELSE.
          CLEAR G_DATA-CH_DATUM.
        ENDIF.

        APPEND G_DATA.
      ENDIF.

    ENDLOOP.

  ENDIF.

  PERFORM DISPLAY_DATA.

TOP-OF-PAGE.
  PERFORM TOP_OF_PAGE.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA.

  G_REPID = SY-REPID.

  PERFORM VARIANT_INIT.
  PERFORM FILL_LAYOUT CHANGING GS_LAYOUT.
  PERFORM FILL_FIELDCAT CHANGING GT_FIELDCAT.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
            I_CALLBACK_PROGRAM = G_REPID
            IS_LAYOUT          = GS_LAYOUT
            IT_FIELDCAT        = GT_FIELDCAT
            IT_EVENTS          = GT_EVENTS
       TABLES
            T_OUTTAB           = G_DATA
       EXCEPTIONS
            PROGRAM_ERROR      = 1
            OTHERS             = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " DISPLAY_DATA

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       Die Anzeigevariante wird gesetzt
*----------------------------------------------------------------------*
FORM VARIANT_INIT.

  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.

  REFRESH GT_EVENTS.
  CLEAR LS_EVENT.
  LS_EVENT-NAME = 'TOP_OF_PAGE'.
  MOVE GC_FORMNAME_TOP_OF_PAGE TO LS_EVENT-FORM.
  APPEND LS_EVENT TO  GT_EVENTS.

ENDFORM.                    " VARIANT_INIT


*&---------------------------------------------------------------------*
*&      Form  FILL_LAYOUT
*&---------------------------------------------------------------------*
*       Füllt die Layout Feldleiste
*----------------------------------------------------------------------*
*      <--P_GS_LAYOUT  Layout
*----------------------------------------------------------------------*
FORM FILL_LAYOUT CHANGING P_GS_LAYOUT TYPE SLIS_LAYOUT_ALV.

  P_GS_LAYOUT-ZEBRA = YES.
  P_GS_LAYOUT-COLWIDTH_OPTIMIZE = YES.

ENDFORM.                    " FILL_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM FILL_FIELDCAT CHANGING P_GT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA: LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

  CLEAR P_GT_FIELDCAT[].

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            I_PROGRAM_NAME         = G_REPID
            I_STRUCTURE_NAME       = '/SIE/HR_IDP_MONITOR'
            I_CLIENT_NEVER_DISPLAY = 'X'
       CHANGING
            CT_FIELDCAT            = P_GT_FIELDCAT
       EXCEPTIONS
            INCONSISTENT_INTERFACE = 1
            PROGRAM_ERROR          = 2
            OTHERS                 = 3.

ENDFORM.                    " FILL_FIELDCAT


*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.

  DATA: LT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
  DATA: LS_LINE TYPE SLIS_LISTHEADER.

  CLEAR LS_LINE.
  SEITE = SY-PAGNO - 1.
* Kopfzeile
  LS_LINE-TYP = 'S'.
  LS_LINE-INFO = SY-TITLE.
  LS_LINE-INFO = TEXT-001.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
       EXPORTING
            IT_LIST_COMMENTARY = LT_TOP_OF_PAGE.

ENDFORM.
