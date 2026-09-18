*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_FIND_FORMS                                 *
*----------------------------------------------------------------------*
*Änderungen: SIE001: Ausgabe der Ansprechpartner korrigiert
*  M. Przygocki 20230328 ATC findings C2C correction
*&---------------------------------------------------------------------*
*&      Form  SEARCH_DATA
*&---------------------------------------------------------------------*
FORM SEARCH_DATA.

  DATA: IDX TYPE I.

* Freigegebene Schnittstellen
  IF P_RELEAS = YES.
    CLEAR: G_DATA[].

    DATA: WA_S1VT LIKE /SIE/HR_IDP_VS1T.

    SELECT * FROM /SIE/HR_IDP_VS1T
             UP TO LOOPC ROWS
             INTO TABLE G_VS1T
             WHERE IFCID IN P_KEY1
             AND   SPRAS = SY-LANGU
             AND   IDENT IN P_XTEXT
             AND   UNAME IN P_UNAME
             AND   DATUM IN P_DATUM
             AND   CR_UNAME IN P_CRNAM
             ORDER BY PRIMARY KEY.      "M. Przygocki 20230328

    LOOP AT G_VS1T INTO WA_S1VT.
      MOVE-CORRESPONDING WA_S1VT TO G_WA.
      CHECK NOT ( WA_S1VT-ACT_VERS_NR IS INITIAL ).
      G_WA-VRSNR = WA_S1VT-ACT_VERS_NR.
      APPEND G_WA TO G_DATA.
    ENDLOOP.
  ENDIF.

* Aktuelle nicht freigegebene Schnittstellen in Bearbeitung.
  IF P_INWORK = YES.
    SELECT * FROM /SIE/HR_IDP_VS1T
             UP TO LOOPC ROWS
             INTO TABLE G_VS1T
             WHERE IFCID IN P_KEY1
             AND   SPRAS = SY-LANGU
             AND   IDENT IN P_XTEXT
             AND   UNAME IN P_UNAME
             AND   DATUM IN P_DATUM
             AND   CR_UNAME IN P_CRNAM
             AND   NEW_VERSION = YES
             ORDER BY PRIMARY KEY.    "M. Przygocki 20230328

    LOOP AT G_VS1T INTO WA_S1VT.
      SELECT MAX( VRSNR )
             INTO /SIE/HR_IDP_S1VN-VRSNR
             FROM /SIE/HR_IDP_S1VN WHERE IFCID = WA_S1VT-IFCID.
      MOVE-CORRESPONDING WA_S1VT TO G_WA.
      G_WA-VRSNR = /SIE/HR_IDP_S1VN-VRSNR.
      APPEND G_WA TO G_DATA.
    ENDLOOP.

  ENDIF.

* Alle Versionen
  IF P_HISTO = YES.
    SELECT * FROM /SIE/HR_IDP_VS1T
             UP TO LOOPC ROWS
             INTO TABLE G_VS1T
             WHERE IFCID IN P_KEY1
             AND   SPRAS = SY-LANGU
             AND   IDENT IN P_XTEXT
             AND   UNAME IN P_UNAME
             AND   DATUM IN P_DATUM
             AND   CR_UNAME IN P_CRNAM
             ORDER BY PRIMARY KEY.   "M. Przygocki 20230328

    LOOP AT G_VS1T INTO WA_S1VT.
      IDX = WA_S1VT-ACT_VERS_NR - 1.
      DO IDX TIMES.
        SELECT SINGLE * FROM /SIE/HR_IDP_S1VN
                       WHERE IFCID = WA_S1VT-IFCID
                       AND   VRSNR = SY-INDEX.
        MOVE-CORRESPONDING WA_S1VT TO G_WA.
        G_WA-VRSNR = /SIE/HR_IDP_S1VN-VRSNR.
        APPEND G_WA TO G_DATA.
      ENDDO.
    ENDLOOP.
  ENDIF.

* Zusätzliche Selektionen einlesen und gerade eingelesene Daten
* Filtern
  PERFORM FILTER_VERSIONS.

  PERFORM ADDITIONAL_SEARCH.

  LOOP AT G_DATA INTO G_WA.

    SELECT * FROM /SIE/HR_IDP_S1R WHERE IFCID = G_WA-IFCID
                                  AND VRSNR = G_WA-VRSNR.
      CASE /SIE/HR_IDP_S1R-TROLE.
        WHEN '04'.
          G_WA-TANSP = /SIE/HR_IDP_S1R-EMAIL.
        WHEN '05'.
*          g_wa-tansp = /sie/hr_idp_s1r-email.
          G_WA-FANSP = /SIE/HR_IDP_S1R-EMAIL.        "SIE001
      ENDCASE.
    ENDSELECT.

    CALL FUNCTION '/SIE/HR_IDP_VERSION_INFO'
         EXPORTING
              INTERFACE_ID = G_WA-IFCID
              VERSION      = G_WA-VRSNR
         IMPORTING
              RC_ICON      = G_WA-ICON.

    MODIFY G_DATA FROM G_WA.
  ENDLOOP.

  SORT G_DATA.
  DELETE ADJACENT DUPLICATES FROM G_DATA.

ENDFORM.                    " SEARCH_DATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM DISPLAY_DATA.

  PERFORM VARIANT_INIT.
  PERFORM FILL_LAYOUT CHANGING GS_LAYOUT.
  PERFORM FILL_FIELDCAT CHANGING GT_FIELDCAT.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
            I_CALLBACK_PROGRAM       = G_REPID
            I_CALLBACK_PF_STATUS_SET = 'CALLBACK_PF_STATUS_SET'
            I_CALLBACK_USER_COMMAND  = 'CALLBACK_USER_COMMAND'
            IS_LAYOUT                = GS_LAYOUT
            IT_FIELDCAT              = GT_FIELDCAT
       TABLES
            T_OUTTAB                 = G_DATA
       EXCEPTIONS
            PROGRAM_ERROR            = 1
            OTHERS                   = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " DISPLAY_DATA

*---------------------------------------------------------------------*
*       FORM CALLBACK_PF_STATUS_SET                                   *
*---------------------------------------------------------------------*
*       Setzt den PF Status bzw. erlaubt das löschen von FCodes       *
*---------------------------------------------------------------------*
FORM CALLBACK_PF_STATUS_SET USING EXTAB TYPE SLIS_T_EXTAB.

  DATA: H_VALUE(5) TYPE C.
  DESCRIBE TABLE G_DATA.
  WRITE SY-TFILL TO H_VALUE NO-ZERO LEFT-JUSTIFIED.

  SET PF-STATUS 'MAIN' EXCLUDING EXTAB.
*  set titlebar 'MAIN' with h_value.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM CALLBACK_USER_COMMAND                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM CALLBACK_USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                           RS_SELFIELD TYPE SLIS_SELFIELD.

  DATA: L_DATA TYPE /SIE/HR_IDP_IFCSEARCH
      , L_ITAB_LT TYPE STANDARD TABLE OF /SIE/HR_IDP_S1LT
                       INITIAL SIZE 0
                       WITH HEADER LINE
      , RC LIKE SY-SUBRC
      .

  CASE R_UCOMM.
    WHEN '%IC1'.                                            "#EC NOTEXT
      READ TABLE G_DATA INTO L_DATA INDEX RS_SELFIELD-TABINDEX.
      SELECT * FROM /SIE/HR_IDP_S1LT
               INTO TABLE L_ITAB_LT
               WHERE IFCID = L_DATA-IFCID.


      SELECT SINGLE * FROM /SIE/HR_IDP_S1 WHERE IFCID = L_DATA-IFCID.
      IF SY-SUBRC = 0.
        PERFORM CHECK_AUTHORITY USING SY-TCODE
                                   C_DISPLAY
                                   /SIE/HR_IDP_S1-AUTH_CLASS
                                   L_DATA-IFCID
                                   'DOCU'
                              CHANGING RC.

        CALL FUNCTION '/SIE/HR_IDP_S1LT_SHOW'
             TABLES
                  I_S1LT = L_ITAB_LT.
      ENDIF.
      CLEAR R_UCOMM.

    WHEN 'AUFF'.                                            "#EC NOTEXT
      CLEAR G_DATA.
      PERFORM SEARCH_DATA.
      RS_SELFIELD-REFRESH = YES.
      RS_SELFIELD-ROW_STABLE = 'X'.
      CLEAR R_UCOMM.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       Die Anzeigevariante wird gesetzt
*----------------------------------------------------------------------*
FORM VARIANT_INIT.
  CLEAR G_VARIANT.
  G_VARIANT-REPORT = G_REPID.
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

  CLEAR LS_FIELDCAT.
  LS_FIELDCAT-TABNAME       = G_TABNAME.
  LS_FIELDCAT-FIELDNAME     = 'IFCID'.
  LS_FIELDCAT-KEY           = 'X'.        "sets key field
  APPEND LS_FIELDCAT TO P_GT_FIELDCAT.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            I_PROGRAM_NAME         = G_REPID
            I_INTERNAL_TABNAME     = G_TABNAME
            I_STRUCTURE_NAME       = '/SIE/HR_IDP_IFCSEARCH'
            I_CLIENT_NEVER_DISPLAY = 'X'
       CHANGING
            CT_FIELDCAT            = P_GT_FIELDCAT
       EXCEPTIONS
            INCONSISTENT_INTERFACE = 1
            PROGRAM_ERROR          = 2
            OTHERS                 = 3.

ENDFORM.                    " FILL_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  ADDITIONAL_SEARCH
*&---------------------------------------------------------------------*
*       Sucht nach Langtext Dokumentation und anderen Attibuten wie
*       Felder
*----------------------------------------------------------------------*
FORM ADDITIONAL_SEARCH.

  DATA: WA_DATA TYPE /SIE/HR_IDP_IFCSEARCH
      , L_DATA TYPE STANDARD TABLE OF /SIE/HR_IDP_IFCSEARCH
               INITIAL SIZE 0.

  RANGES: LR_IFC FOR /SIE/HR_IDP_S1-IFCID.

* SIE001_BEG
*  Suche nach Referenzschnittstelle(nur wenn gewünscht)
   read table p_refer index 1 transporting no fields.
   if sy-subrc = 0.

     LOOP AT G_DATA INTO WA_DATA.
       SELECT SINGLE ifcid FROM /SIE/HR_IDP_S1DL
                           into wa_data-ifcid "Dummy
                           WHERE IFCID =  WA_DATA-IFCID
                             AND VRSNR = WA_DATA-VRSNR
                             AND Referenz IN P_refer.
       IF SY-SUBRC = 0.
*      Feld behalten
       ELSE.
         DELETE G_DATA.
       ENDIF.
     endloop.

  endif.
* SIE001_END

* Langtextsuche.
  CLEAR LR_IFC[].
  LOOP AT G_DATA INTO WA_DATA.
    LR_IFC-SIGN = 'I'.
    LR_IFC-OPTION = 'EQ'.
    LR_IFC-LOW = WA_DATA-IFCID.
    APPEND LR_IFC.
  ENDLOOP.

  CLEAR WA_DATA.
  SELECT * FROM /SIE/HR_IDP_S1LT WHERE TLINE IN P_TEXT.
    WA_DATA-IFCID = /SIE/HR_IDP_S1LT-IFCID.
    APPEND WA_DATA TO L_DATA.
  ENDSELECT.

* Nun werden die gefundenen Texte und felder abgemischt.
  DELETE ADJACENT DUPLICATES FROM L_DATA COMPARING IFCID VRSNR.

  LOOP AT G_DATA INTO WA_DATA.
    READ TABLE L_DATA WITH KEY IFCID = WA_DATA-IFCID
                      TRANSPORTING NO FIELDS.
    IF SY-SUBRC >< 0.
* Vor dem Löschen sollte aber noch geprüft werden, ob das Feld
* überhaupt Dokumentation besitzt. Ansonsten wird es gelöscht.
      SELECT SINGLE * FROM /SIE/HR_IDP_S1LT WHERE IFCID = WA_DATA-IFCID.
      IF SY-SUBRC >< 0.
* Feld existiert nicht in der Datenbank. Das Feld behalten.
      ELSE.
        DELETE G_DATA.
      ENDIF.
    ELSE.
* Alles in Ordnung. Das Feld behalten.
    ENDIF.
  ENDLOOP.

  LOOP AT G_DATA INTO WA_DATA.
    SELECT SINGLE * FROM /SIE/HR_IDP_S1PG WHERE IFCID = WA_DATA-IFCID
                                   AND VRSNR = WA_DATA-VRSNR
                                   AND FELDNAME IN P_FIELD.
    IF SY-SUBRC = 0.
* Feld behalten
    ELSE.
      DELETE G_DATA.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " ADDITIONAL_SEARCH

*&---------------------------------------------------------------------*
*&      Form  FILTER_VERSIONS
*&---------------------------------------------------------------------*
*       Diese Form routine Filtert aus der G_DATA alle nicht mit
*       dem Selektionsbild konformen Versionen.
*----------------------------------------------------------------------*
FORM FILTER_VERSIONS.

  DATA: WA_DATA TYPE /SIE/HR_IDP_IFCSEARCH
      , L_DATA TYPE STANDARD TABLE OF /SIE/HR_IDP_IFCSEARCH
               INITIAL SIZE 0.

  RANGES: LR_IFC FOR /SIE/HR_IDP_S1-IFCID.

* Langtextsuche.
*  clear lr_ifc[].
*  loop at g_data into wa_data.
*    lr_ifc-sign = 'I'.
*    lr_ifc-option = 'EQ'.
*    lr_ifc-low = wa_data-ifcid.
*    append lr_ifc.
*  endloop.

*    select * from /sie/hr_idp_s1vn where ifcid in lr_ifc.
*      if not ( p_releas is initial ).
*        if not ( /sie/hr_idp_s1vn-relea_date is initial ).
*          wa_data-ifcid = /sie/hr_idp_s1vn-ifcid.
*          wa_data-vrsnr = /sie/hr_idp_s1vn-vrsnr.
*          append wa_data.
*        else.
* do nothing
*        endif.

*     if p_inwork is initial.
*
*
*    endif.
*
*      endselect.
*
*
ENDFORM.                    " FILTER_VERSIONS

INCLUDE /SIE/HR_IDP_AUTHORITY.
