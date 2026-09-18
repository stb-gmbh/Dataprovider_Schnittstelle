*---------------------Change Log-------------------------------*
*  M. Przygocki 20221215 ATC findings C2C correction for query order
*--------------------------------------------------------------*
REPORT /SIE/HR_IDP_PRICE .

TYPE-POOLS: SLIS.

TABLES: /SIE/HR_IDP_V1
      , /SIE/HR_IDP_S1
      , /SIE/HR_IDP_S1PC     "Pricing
      , /SIE/HR_IDP_S1P      "Protokoll
      , /SIE/HR_IDP_S1T
      , /SIE/HR_IDP_PRICING
      .

INCLUDE /SIE/HR_IDP_TYPES.

DATA: GT_S1P TYPE STANDARD TABLE OF /SIE/HR_IDP_S1P INITIAL SIZE 0
      WITH HEADER LINE
    , WA_S1P TYPE /SIE/HR_IDP_S1P
    , GT_S1PC TYPE STANDARD TABLE OF /SIE/HR_IDP_S1PC INITIAL SIZE 0
      WITH HEADER LINE
    , GT_VERRECHNUNG TYPE STANDARD TABLE OF /SIE/HR_IDP_PRICING
      INITIAL SIZE 0 WITH HEADER LINE
    , WA_VERRECHNUNG TYPE /SIE/HR_IDP_PRICING
    , G_REPID LIKE SY-REPID
    , G_VARIANT LIKE DISVARIANT
    , GX_VARIANT LIKE DISVARIANT
    , G_SAVE(1) TYPE C
    , G_EXIT(1) TYPE C
    , G_LOW_BEGDA TYPE D
    , G_HIGH_BEGDA TYPE D
    .

SELECTION-SCREEN BEGIN OF BLOCK SEL WITH FRAME TITLE TEXT-S00.
SELECT-OPTIONS: SO_ORGID FOR /SIE/HR_IDP_S1PC-KSTORGID
              , SO_IFCID FOR /SIE/HR_IDP_S1-IFCID
              , SO_SEQNO FOR /SIE/HR_IDP_S1P-SEQNO
              .

SELECT-OPTIONS: SO_BEGDA FOR /SIE/HR_IDP_S1P-BEGDA
              , SO_BEGUZ FOR /SIE/HR_IDP_S1P-BEGUZ DEFAULT
                '000000' TO '240000'.                       "#EC NOTEXT
.
SELECTION-SCREEN END OF BLOCK SEL.

SELECTION-SCREEN BEGIN OF BLOCK SUM WITH FRAME TITLE TEXT-S01.
PARAMETERS: P_CREAT AS CHECKBOX DEFAULT NO
          , P_MAINT AS CHECKBOX DEFAULT YES
          .
PARAMETERS: P_TOTONL AS CHECKBOX DEFAULT SPACE.
SELECTION-SCREEN END OF BLOCK SUM.

* Variante
SELECTION-SCREEN BEGIN OF BLOCK 0 WITH FRAME TITLE TEXT-064.
PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.
SELECTION-SCREEN END OF BLOCK 0.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4_FOR_VARIANT.

INITIALIZATION.
  G_REPID = SY-REPID.
  G_SAVE = 'A'.                                             "#EC NOTEXT
  PERFORM VARIANT_INIT.
* Get default variant
  GX_VARIANT = G_VARIANT.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
       EXPORTING
            I_SAVE     = G_SAVE
       CHANGING
            CS_VARIANT = GX_VARIANT
       EXCEPTIONS
            NOT_FOUND  = 2.
  IF SY-SUBRC = 0.
    P_VARI = GX_VARIANT-VARIANT.
  ENDIF.
* Vorschlagswert Datum
  IF SO_BEGDA IS INITIAL.
    G_LOW_BEGDA = SY-DATUM.
    G_LOW_BEGDA+6(2) = '01'.                                "#EC NOTEXT
    G_HIGH_BEGDA = SY-DATUM.
    SO_BEGDA-LOW = G_LOW_BEGDA.
    SO_BEGDA-HIGH = G_HIGH_BEGDA.
    SO_BEGDA-OPTION = 'BT'.                                 "#EC NOTEXT
    SO_BEGDA-SIGN = 'I'.                                    "#EC NOTEXT
    APPEND SO_BEGDA.
  ENDIF.

START-OF-SELECTION.
  PERFORM READ_S1P.
  PERFORM READ_S1PC.
  PERFORM DISPLAY_XLS.

AT SELECTION-SCREEN.
  PERFORM PAI_OF_SELECTION_SCREEN.

*---------------------------------------------------------------------*
*       FORM VARIANT_INIT                                             *
*---------------------------------------------------------------------*
FORM VARIANT_INIT.
  CLEAR G_VARIANT.
  G_VARIANT-REPORT = G_REPID.
  G_VARIANT-USERNAME = SY-UNAME.
ENDFORM.                               " VARIANT_INIT

*---------------------------------------------------------------------*
*       FORM READ_S1P                                                 *
*---------------------------------------------------------------------*
*       Liest Protokollinformationen ein                              *
*---------------------------------------------------------------------*
FORM READ_S1P.
  SELECT * FROM /SIE/HR_IDP_S1P INTO TABLE GT_S1P
                                WHERE IFCID IN SO_IFCID
                                AND   SEQNO IN SO_SEQNO
                                AND   BEGDA IN SO_BEGDA
                                AND   ENDDA IN SO_BEGDA
                                AND   BEGUZ IN SO_BEGUZ
                                AND   ENDUZ IN SO_BEGUZ.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM READ_S1PC                                                *
*---------------------------------------------------------------------*
FORM READ_S1PC.
  LOOP AT GT_S1P INTO WA_S1P.
    SELECT * FROM /SIE/HR_IDP_S1PC WHERE IFCID = WA_S1P-IFCID
                                   AND   VRSNR = WA_S1P-VRSNR
                                   AND   KSTORGID IN SO_ORGID.
      CLEAR WA_VERRECHNUNG.

* Schnittstelle/Ausgabeinformationen
      MOVE-CORRESPONDING WA_S1P TO WA_VERRECHNUNG.

* Schnittstellentext
      SELECT SINGLE * FROM /SIE/HR_IDP_S1T
                      WHERE IFCID = WA_VERRECHNUNG-IFCID
                      AND   SPRAS = SY-LANGU.
      IF SY-SUBRC = 0.
        WA_VERRECHNUNG-IDENT = /SIE/HR_IDP_S1T-IDENT.
      ELSE.
        CLEAR WA_VERRECHNUNG.
      ENDIF.

* Berechnung der Dauer
      WA_VERRECHNUNG-DAUER = ( ( WA_S1P-ENDDA - WA_S1P-BEGDA ) * 86400
                             + ( WA_S1P-ENDUZ - WA_S1P-BEGUZ ) ).

* Verrechnungsdaten
      MOVE-CORRESPONDING /SIE/HR_IDP_S1PC TO WA_VERRECHNUNG.

* Kosten
      IF /SIE/HR_IDP_S1PC-KOSTENDR IS INITIAL.
        SELECT * FROM /SIE/HR_IDP_V1
                 WHERE KOSTKATE = /SIE/HR_IDP_S1PC-KOSTKATE
                 AND   ENDDA    GE SY-DATUM
                 AND   BEGDA    LE SY-DATUM
                 ORDER BY PRIMARY KEY. "M. Przygocki 20221215
          EXIT.
        ENDSELECT.

* Einmalige Kosten
        IF NOT ( /SIE/HR_IDP_V1-AMOUNT IS INITIAL ) .
          WA_VERRECHNUNG-KOSTENDR = /SIE/HR_IDP_V1-AMOUNT.
          WA_VERRECHNUNG-CURRENCY = /SIE/HR_IDP_V1-CURRENCY.
        ENDIF.
      ENDIF.

* Pflegekosten
      WA_VERRECHNUNG-KOSTPFLG = WA_VERRECHNUNG-KOSTENDR *
                                WA_VERRECHNUNG-KOSTKATP / 100.
      WA_VERRECHNUNG-CURRENC2 = WA_VERRECHNUNG-CURRENCY.

* Anzahl der Läufe im selektierten Zeitraum
      WA_VERRECHNUNG-ANZHL = 1.

* Bei einmaligen Kosten die Kosten nur beim ersten Lauf anzeigen
      IF WA_S1P-SEQNO >< 1.
        CLEAR WA_VERRECHNUNG-KOSTENDR.
        CLEAR WA_VERRECHNUNG-CURRENCY.
      ELSE.
        CLEAR WA_VERRECHNUNG-KOSTPFLG.
        CLEAR WA_VERRECHNUNG-CURRENC2.
      ENDIF.

      APPEND WA_VERRECHNUNG TO GT_VERRECHNUNG.
    ENDSELECT.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM DISPLAY_XLS                                              *
*---------------------------------------------------------------------*
*       Erzeugt eine Liste von Verrechnungsinformationen              *
*---------------------------------------------------------------------*
FORM DISPLAY_XLS.

  DATA: LS_LAYOUT TYPE SLIS_LAYOUT_ALV
      , LT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV
      , LT_SORT TYPE SLIS_T_SORTINFO_ALV
      .

  PERFORM LAYOUT_BUILD CHANGING LS_LAYOUT.
  PERFORM FIELDCAT_BUILD CHANGING LT_FIELDCAT.
  PERFORM SORT_BUILD CHANGING LT_SORT.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
            I_CALLBACK_PROGRAM = G_REPID
            I_STRUCTURE_NAME   = '/SIE/HR_IDP_PRICING'      "#EC NOTEXT
            IS_LAYOUT          = LS_LAYOUT
            IT_FIELDCAT        = LT_FIELDCAT
            IT_SORT            = LT_SORT
            IS_VARIANT         = G_VARIANT
       TABLES
            T_OUTTAB           = GT_VERRECHNUNG
       EXCEPTIONS
            PROGRAM_ERROR      = 1
            OTHERS             = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM LAYOUT_BUILD                                             *
*---------------------------------------------------------------------*
FORM LAYOUT_BUILD CHANGING LS_LAYOUT TYPE SLIS_LAYOUT_ALV.

  LS_LAYOUT-ZEBRA             = YES.
  LS_LAYOUT-COLWIDTH_OPTIMIZE = YES.
*  ls_layout-totals_text       = 'Summe'(030).
*  ls_layout-subtotals_text    = 'Zw.Summe'(031).
  LS_LAYOUT-TOTALS_ONLY       = P_TOTONL.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_FIELD_CAT  text
*----------------------------------------------------------------------*
FORM FIELDCAT_BUILD CHANGING LT_FIELD_CAT TYPE SLIS_T_FIELDCAT_ALV.

  DATA: LS_FIELD_CAT TYPE SLIS_FIELDCAT_ALV
    , L_STRUC LIKE DD02L-TABNAME VALUE '/SIE/HR_IDP_PRICING'"#EC NOTEXT
      .

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            I_STRUCTURE_NAME       = L_STRUC
       CHANGING
            CT_FIELDCAT            = LT_FIELD_CAT
       EXCEPTIONS
            INCONSISTENT_INTERFACE = 1
            PROGRAM_ERROR          = 2
            OTHERS                 = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Schnittstelle
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                          WITH KEY FIELDNAME = 'IFCID'.     "#EC NOTEXT
  IF SY-SUBRC = 0.
    LS_FIELD_CAT-KEY = NO.
    LS_FIELD_CAT-FIX_COLUMN = NO.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

* Version
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                          WITH KEY FIELDNAME = 'VRSNR'.     "#EC NOTEXT
  IF SY-SUBRC = 0.
    LS_FIELD_CAT-KEY = NO.
    LS_FIELD_CAT-LZERO = YES.
    LS_FIELD_CAT-FIX_COLUMN = NO.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

* ORGID
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                          WITH KEY FIELDNAME = 'KSTORGID'.  "#EC NOTEXT
  IF SY-SUBRC = 0.
    LS_FIELD_CAT-KEY = YES.
    LS_FIELD_CAT-FIX_COLUMN = YES.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

* Bestellnr.
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                          WITH KEY FIELDNAME = 'KSTBSTLN'.  "#EC NOTEXT
  IF SY-SUBRC = 0.
    LS_FIELD_CAT-KEY = YES.
    LS_FIELD_CAT-FIX_COLUMN = YES.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

* Einmalige Kosten
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                          WITH KEY FIELDNAME = 'KOSTENDR'.  "#EC NOTEXT
  IF SY-SUBRC = 0.
    LS_FIELD_CAT-DO_SUM = YES.
    LS_FIELD_CAT-CURRENCY = 'EUR'.                          "#EC NOTEXT
    IF P_CREAT = YES.
      LS_FIELD_CAT-NO_OUT = NO.
    ELSE.
      LS_FIELD_CAT-NO_OUT = YES.
    ENDIF.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                          WITH KEY FIELDNAME = 'CURRENCY'.  "#EC NOTEXT
  IF SY-SUBRC = 0.
    IF P_CREAT = YES.
      LS_FIELD_CAT-NO_OUT = NO.
    ELSE.
      LS_FIELD_CAT-NO_OUT = YES.
    ENDIF.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

* Pflegekosten
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                         WITH KEY FIELDNAME = 'KOSTPFLG'.   "#EC NOTEXT
  IF SY-SUBRC = 0.
    LS_FIELD_CAT-CURRENCY = 'EUR'.                          "#EC NOTEXT
    LS_FIELD_CAT-DO_SUM = YES.
    IF P_MAINT = YES.
      LS_FIELD_CAT-NO_OUT = NO.
    ELSE.
      LS_FIELD_CAT-NO_OUT = YES.
    ENDIF.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                         WITH KEY FIELDNAME = 'KOSTKATP'.   "#EC NOTEXT
  IF SY-SUBRC = 0.
    IF P_MAINT = YES.
      LS_FIELD_CAT-NO_OUT = NO.
    ELSE.
      LS_FIELD_CAT-NO_OUT = YES.
    ENDIF.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                         WITH KEY FIELDNAME = 'CURRENC2'.   "#EC NOTEXT
  IF SY-SUBRC = 0.
    IF P_MAINT = YES.
      LS_FIELD_CAT-NO_OUT = NO.
    ELSE.
      LS_FIELD_CAT-NO_OUT = YES.
    ENDIF.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

* Anzahl der Läufe
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                        WITH KEY FIELDNAME = 'ANZHL'.       "#EC NOTEXT
  IF SY-SUBRC = 0.
    LS_FIELD_CAT-DO_SUM = YES.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

* Dauer
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                        WITH KEY FIELDNAME = 'DAUER'.       "#EC NOTEXT
  IF SY-SUBRC = 0.
    LS_FIELD_CAT-DO_SUM = YES.
    LS_FIELD_CAT-QUANTITY = 'SEC'.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

* Dateigröße
  READ TABLE LT_FIELD_CAT INTO LS_FIELD_CAT
                        WITH KEY FIELDNAME = 'FILESZ'.      "#EC NOTEXT
  IF SY-SUBRC = 0.
    LS_FIELD_CAT-DO_SUM = YES.
    MODIFY LT_FIELD_CAT FROM LS_FIELD_CAT INDEX SY-TABIX.
  ENDIF.

ENDFORM.                    " FIELDCAT_BUILD

*&---------------------------------------------------------------------*
*&      Form  SORT_BUILD
*&---------------------------------------------------------------------*
FORM SORT_BUILD CHANGING LT_SORT TYPE SLIS_T_SORTINFO_ALV.

  DATA: WA_SORT TYPE SLIS_SORTINFO_ALV.

  WA_SORT-FIELDNAME = 'IFCID'.                              "#EC NOTEXT
  WA_SORT-SPOS      = 1.
  WA_SORT-UP        = YES.
  APPEND WA_SORT TO LT_SORT.

  CLEAR WA_SORT.
  WA_SORT-FIELDNAME = 'VRSNR'.                              "#EC NOTEXT
  WA_SORT-SPOS      = 2.
  WA_SORT-UP        = YES.
  WA_SORT-SUBTOT    = YES.
  APPEND WA_SORT TO LT_SORT.  " SORT_BUILD

ENDFORM.

*---------------------------------------------------------------------*
*       FORM PAI_OF_SELECTION_SCREEN                                  *
*---------------------------------------------------------------------*
FORM PAI_OF_SELECTION_SCREEN.
*
  IF NOT P_VARI IS INITIAL.
    MOVE G_VARIANT TO GX_VARIANT.
    MOVE P_VARI TO GX_VARIANT-VARIANT.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
         EXPORTING
              I_SAVE     = G_SAVE
         CHANGING
              CS_VARIANT = GX_VARIANT.
    G_VARIANT = GX_VARIANT.
  ELSE.
    PERFORM VARIANT_INIT.
  ENDIF.
ENDFORM.                               " PAI_OF_SELECTION_SCREEN

*---------------------------------------------------------------------*
*       FORM F4_FOR_VARIANT                                           *
*---------------------------------------------------------------------*
FORM F4_FOR_VARIANT.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            IS_VARIANT = G_VARIANT
            I_SAVE     = G_SAVE
       IMPORTING
            E_EXIT     = G_EXIT
            ES_VARIANT = GX_VARIANT
       EXCEPTIONS
            NOT_FOUND  = 2.
  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S'      NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF G_EXIT = SPACE.
      P_VARI = GX_VARIANT-VARIANT.
    ENDIF.
  ENDIF.
ENDFORM.
