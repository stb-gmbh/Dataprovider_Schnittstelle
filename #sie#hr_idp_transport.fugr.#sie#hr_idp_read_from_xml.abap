FUNCTION /SIE/HR_IDP_READ_FROM_XML.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       EXPORTING
*"             VALUE(IFC_DATA) TYPE  /SIE/HR_IDP_IFC_DB
*"       TABLES
*"              XML_DATA
*"----------------------------------------------------------------------
*SIE001 29.03.2004 Hierl  Neue Option "kein Trennzeichen" CR 4199
*SIE002 29.06.2004 Hierl  Neue Funktion Filter auf Feldebene CR 4258
*SIE003 22.11.2004 Hierl  Nachbearb./glob.Sel/UC4-Startzeit CR4258

  DATA: LT_BUFFER TYPE T_XML_FILE
      , LS_BUFFER TYPE S_XML_FILE
      , T_XML TYPE T_XML_FILE
      , T_ATTRIBUTES TYPE /SIE/HR_IDP_TT_ATTRIBUTES
      , S_ATTRIBUTES TYPE /SIE/HR_IDP_PAIRS
      , S_ATTRIBUTE TYPE /SIE/HR_IDP_PAIR
      , WA_S1 TYPE /SIE/HR_IDP_S1
      , WA_S1T TYPE /SIE/HR_IDP_S1T
      , WA_S1LT TYPE /SIE/HR_IDP_S1LT
      , WA_S1VN TYPE /SIE/HR_IDP_S1VN
      , WA_S1VT TYPE /SIE/HR_IDP_S1VT
      , WA_S1DF TYPE /SIE/HR_IDP_S1DF
      , WA_S1DL TYPE /SIE/HR_IDP_S1DL
      , WA_S1SA TYPE /SIE/HR_IDP_S1SA
      , WA_S1PG TYPE /SIE/HR_IDP_S1PG
      , WA_S1PS TYPE /SIE/HR_IDP_S1PS
      , WA_S1R TYPE /SIE/HR_IDP_S1R
      , WA_S1PR TYPE /SIE/HR_IDP_S1PR
      , FOUND  TYPE TY_YESNO
      , WA_S1PC TYPE /SIE/HR_IDP_S1PC
      , G_VRSNR TYPE /SIE/HR_IDP_VERS_NR
      , IDX(4) TYPE N
      , G_VRSNR_ORG TYPE /SIE/HR_IDP_VERS_NR
      , BUFFER1(100) TYPE C
      .

  DEFINE REPLACE_SPACE.
    CLEAR BUFFER1.
    BUFFER1 = S_ATTRIBUTE-VALUE.
    DO.
      REPLACE TEXT-SPC WITH SPACE INTO BUFFER1.
      IF SY-SUBRC >< 0.
        EXIT.
      ENDIF.
    ENDDO.

    DO.
      REPLACE TEXT-SKO WITH TEXT-SK0 INTO BUFFER1.
      IF SY-SUBRC >< 0.
        EXIT.
      ENDIF.
    ENDDO.

    DO.
      REPLACE TEXT-AMP WITH TEXT-AM1 INTO BUFFER1.
      IF SY-SUBRC >< 0.
        EXIT.
      ENDIF.
    ENDDO.

    &1 = BUFFER1.

  END-OF-DEFINITION.

  T_XML[] = XML_DATA[].
  CLEAR LT_BUFFER[].

* Head
  CLEAR T_ATTRIBUTES[].
  LOOP AT T_XML INTO LS_BUFFER.
    PERFORM GET_TAG_ATTRIBUTES USING  'head'                "#EC NOTEXT
                                       LS_BUFFER
                                CHANGING T_ATTRIBUTES.
    LOOP AT T_ATTRIBUTES INTO S_ATTRIBUTES.
      CASE S_ATTRIBUTES-NODE_NAME.
        WHEN 'head'.                                        "#EC NOTEXT
          LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
            CASE S_ATTRIBUTE-ATTRIBUTENAME.
              WHEN 'ifcid'.                                 "#EC NOTEXT
                REPLACE_SPACE WA_S1-IFCID.
                TRANSLATE WA_S1-IFCID TO UPPER CASE.
              WHEN 'version'.                               "#EC NOTEXT
                G_VRSNR_ORG = S_ATTRIBUTE-VALUE.
                G_VRSNR = '0001'.
              WHEN 'customer'.                              "#EC NOTEXT
                REPLACE_SPACE WA_S1-CUSTOMER.
              WHEN 'auth_class'.                            "#EC NOTEXT
                REPLACE_SPACE WA_S1-AUTH_CLASS.
              WHEN 'valid_from'.                            "#EC NOTEXT
                WA_S1-VALID_FROM = S_ATTRIBUTE-VALUE.
              WHEN 'valid_to'.                              "#EC NOTEXT
                WA_S1-VALID_TO = S_ATTRIBUTE-VALUE.
              WHEN 'act_vers_nr'.                           "#EC NOTEXT
                WA_S1-ACT_VERS_NR = '0000'.
              WHEN 'new_version'.                           "#EC NOTEXT
                WA_S1-NEW_VERSION = S_ATTRIBUTE-VALUE.
            ENDCASE.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.
  MOVE-CORRESPONDING WA_S1 TO IFC_DATA-S1.

* Kurztext
  CLEAR LT_BUFFER[].
  PERFORM GET_TAG_ORG TABLES T_XML
                          LT_BUFFER
                   USING 'short_description'.
  WA_S1T-IFCID = IFC_DATA-S1-IFCID.
  WA_S1T-SPRAS = SY-LANGU.
  READ TABLE LT_BUFFER INDEX 1 INTO LS_BUFFER.
  WA_S1T-IDENT = LS_BUFFER-LINE.
  MOVE-CORRESPONDING WA_S1T TO IFC_DATA-S1T.

  CLEAR LT_BUFFER[].
  PERFORM GET_TAG_ORG TABLES T_XML
                          LT_BUFFER
                   USING 'documentation'.
  FOUND = NO.
  IDX = 0.
  LOOP AT T_XML INTO LS_BUFFER.
    IF LS_BUFFER CS '<line'.
      FOUND = YES.
      CONTINUE.
    ENDIF.
    IF LS_BUFFER CS '</line>'.
      FOUND = NO.
      CONTINUE.
    ENDIF.
    IF FOUND = YES.
      IDX = IDX + 1.
      WA_S1LT-IFCID = IFC_DATA-S1-IFCID.
      WA_S1LT-SPRAS = SY-LANGU.
      WA_S1LT-TLINE = LS_BUFFER-LINE.
      WA_S1LT-SEQNR = IDX.
      APPEND WA_S1LT TO IFC_DATA-S1LT.
    ENDIF.
  ENDLOOP.

* Delimiter
  CLEAR T_ATTRIBUTES[].
  LOOP AT T_XML INTO LS_BUFFER.
    PERFORM GET_TAG_ATTRIBUTES USING  'delimiter'           "#EC NOTEXT
                                       LS_BUFFER
                                CHANGING T_ATTRIBUTES.
    LOOP AT T_ATTRIBUTES INTO S_ATTRIBUTES.
      CASE S_ATTRIBUTES-NODE_NAME.
        WHEN 'delimiter'.                                   "#EC NOTEXT
          LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
            CASE S_ATTRIBUTE-ATTRIBUTENAME.
              WHEN 'fixfm'.                                 "#EC NOTEXT
                WA_S1DL-FIXFM = S_ATTRIBUTE-VALUE.
              WHEN 'delim'.                                 "#EC NOTEXT
                WA_S1DL-DELIM = S_ATTRIBUTE-VALUE.
            ENDCASE.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.
  WA_S1DL-IFCID = IFC_DATA-S1-IFCID.
  WA_S1DL-VRSNR = G_VRSNR.
  MOVE-CORRESPONDING WA_S1DL TO IFC_DATA-S1DL.

* Parameter
  CLEAR T_ATTRIBUTES[].
  LOOP AT T_XML INTO LS_BUFFER.
    PERFORM GET_TAG_ATTRIBUTES USING  'parameters'          "#EC NOTEXT
                                       LS_BUFFER
                                CHANGING T_ATTRIBUTES.
    LOOP AT T_ATTRIBUTES INTO S_ATTRIBUTES.
      CASE S_ATTRIBUTES-NODE_NAME.
        WHEN 'parameters'.                                  "#EC NOTEXT
          LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
            CASE S_ATTRIBUTE-ATTRIBUTENAME.
              WHEN 'timed'.                                 "#EC NOTEXT
                WA_S1PR-TIMED = S_ATTRIBUTE-VALUE.
              WHEN 'begdt'.                                 "#EC NOTEXT
                WA_S1PR-BEGDT = S_ATTRIBUTE-VALUE.
              WHEN 'begdo'.                                 "#EC NOTEXT
                WA_S1PR-BEGDO = S_ATTRIBUTE-VALUE.
              WHEN 'enddt'.                                 "#EC NOTEXT
                WA_S1PR-ENDDT = S_ATTRIBUTE-VALUE.
              WHEN 'enddo'.                                 "#EC NOTEXT
                WA_S1PR-ENDDO = S_ATTRIBUTE-VALUE.
              WHEN 'begpt'.                                 "#EC NOTEXT
                WA_S1PR-BEGPT = S_ATTRIBUTE-VALUE.
              WHEN 'endpt'.                                 "#EC NOTEXT
                WA_S1PR-ENDPT = S_ATTRIBUTE-VALUE.
              WHEN 'endpo'.                                 "#EC NOTEXT
                WA_S1PR-ENDPO = S_ATTRIBUTE-VALUE.
              WHEN 'begpo'.                                 "EC NOTEXT
                WA_S1PR-BEGPO = S_ATTRIBUTE-VALUE.
              WHEN 'xabkr'.                                 "#EC NOTEXT
                WA_S1PR-XABKR = S_ATTRIBUTE-VALUE.
              WHEN 'abkro'.                                 "#EC NOTEXT
                WA_S1PR-ABKRO = S_ATTRIBUTE-VALUE.
            ENDCASE.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.
  WA_S1PR-IFCID = IFC_DATA-S1-IFCID.
  WA_S1PR-VRSNR = G_VRSNR.
  MOVE-CORRESPONDING WA_S1PR TO IFC_DATA-S1PR.

* UC4
  CLEAR T_ATTRIBUTES[].
  LOOP AT T_XML INTO LS_BUFFER.
    PERFORM GET_TAG_ATTRIBUTES USING  'uc4'                 "#EC NOTEXT
                                       LS_BUFFER
                                CHANGING T_ATTRIBUTES.
    LOOP AT T_ATTRIBUTES INTO S_ATTRIBUTES.
      CASE S_ATTRIBUTES-NODE_NAME.
        WHEN 'uc4'.                                         "#EC NOTEXT
          LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
            CASE S_ATTRIBUTE-ATTRIBUTENAME.
              WHEN 'gnrtd'.                                 "#EC NOTEXT
                WA_S1DF-GNRTD = S_ATTRIBUTE-VALUE.
              WHEN 'progr'.                                 "#EC NOTEXT
                WA_S1DF-PROGR = S_ATTRIBUTE-VALUE.
              WHEN 'gnrvt'.                                 "#EC NOTEXT
                WA_S1DF-GNRVT = S_ATTRIBUTE-VALUE.
              WHEN 'varia'.                                 "#EC NOTEXT
                WA_S1DF-VARIA = S_ATTRIBUTE-VALUE.
              WHEN 'uc4fr'.                                 "#EC NOTEXT
                WA_S1DF-UC4FR = S_ATTRIBUTE-VALUE.
              WHEN 'uc4to'.                                 "#EC NOTEXT
                WA_S1DF-UC4TO = S_ATTRIBUTE-VALUE.
              WHEN 'uc4dy'.                                 "#EC NOTEXT
                WA_S1DF-UC4DY = S_ATTRIBUTE-VALUE.
              WHEN 'uc4nr'.                                 "#EC NOTEXT
                WA_S1DF-UC4NR = S_ATTRIBUTE-VALUE.
              WHEN 'uc4pr'.                                 "#EC NOTEXT
                WA_S1DF-UC4PR = S_ATTRIBUTE-VALUE.
              WHEN 'filen'.                                 "#EC NOTEXT
                REPLACE_SPACE WA_S1DF-FILEN.
              WHEN 'hostn'.                                 "#EC NOTEXT
                WA_S1DF-HOSTN = S_ATTRIBUTE-VALUE.
              WHEN 'tcpip'.                                 "#EC NOTEXT
                WA_S1DF-TCPIP = S_ATTRIBUTE-VALUE.
              WHEN 'portn'.                                 "#EC NOTEXT
                WA_S1DF-PORTN = S_ATTRIBUTE-VALUE.
              WHEN 'trfad'.                                 "#EC NOTEXT
                REPLACE_SPACE WA_S1DF-TRFAD.
              WHEN 'encry'.                                 "#EC NOTEXT
                WA_S1DF-ENCRY = S_ATTRIBUTE-VALUE.
              WHEN 'emsuc'.                                 "#EC NOTEXT
                REPLACE_SPACE WA_S1DF-EMSUC.
              WHEN 'emerr'.                                 "#EC NOTEXT
                REPLACE_SPACE WA_S1DF-EMERR.
              WHEN 'uc4nm'.                                 "#EC NOTEXT
                WA_S1DF-UC4NM = S_ATTRIBUTE-VALUE.
              WHEN 'itype'.                                 "#EC NOTEXT
                WA_S1DF-ITYPE = S_ATTRIBUTE-VALUE.
              WHEN 'delta'.                                 "#EC NOTEXT
                WA_S1DF-DELTA = S_ATTRIBUTE-VALUE.
*SIE003_BEG
              WHEN 'nachbearb'.
                wa_s1df-nachbearb = S_ATTRIBUTE-VALUE.
              WHEN 'uc4st'.
                wa_s1df-uc4st = S_ATTRIBUTE-VALUE.
              WHEN 'uc4sm'.
                wa_s1df-uc4sm = S_ATTRIBUTE-VALUE.
              WHEN 'nogsel'.
                wa_s1df-nogsel = S_ATTRIBUTE-VALUE.
*SIE003_END

            ENDCASE.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.
  WA_S1DF-IFCID = IFC_DATA-S1-IFCID.
  WA_S1DF-VRSNR = G_VRSNR.
  IFC_DATA-S1DF = WA_S1DF.

* Select Options
  CLEAR LT_BUFFER[].
  CLEAR T_ATTRIBUTES[].
  PERFORM GET_TAG_ORG TABLES T_XML
                          LT_BUFFER
                   USING 'select_options'.
  LOOP AT LT_BUFFER INTO LS_BUFFER.
    PERFORM GET_TAG_ATTRIBUTES USING  'option'
                                      LS_BUFFER
                               CHANGING T_ATTRIBUTES.
  ENDLOOP.

  LOOP AT T_ATTRIBUTES INTO S_ATTRIBUTES.
    CASE S_ATTRIBUTES-NODE_NAME.
      WHEN 'option'.                                        "#EC NOTEXT
        LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
          CASE S_ATTRIBUTE-ATTRIBUTENAME.
            WHEN 'feldname'.                                "#EC NOTEXT
              WA_S1VT-FELDNAME = S_ATTRIBUTE-VALUE.
            WHEN 'seqno'.                                   "#EC NOTEXT
              WA_S1VT-SEQNO = S_ATTRIBUTE-VALUE.
            WHEN 'ssign'.                                   "#EC NOTEXT
              WA_S1VT-SSIGN = S_ATTRIBUTE-VALUE.
            WHEN 'sopti'.                                   "#EC NOTEXT
              WA_S1VT-SOPTI = S_ATTRIBUTE-VALUE.
            WHEN 'sllow'.                                   "#EC NOTEXT
              WA_S1VT-SLLOW = S_ATTRIBUTE-VALUE.
            WHEN 'shigh'.                                   "#EC NOTEXT
              WA_S1VT-SHIGH = S_ATTRIBUTE-VALUE.
          ENDCASE.
        ENDLOOP.
    ENDCASE.
    WA_S1VT-IFCID = IFC_DATA-S1-IFCID.
    WA_S1VT-VRSNR = G_VRSNR.
    APPEND WA_S1VT TO IFC_DATA-S1VT[].
  ENDLOOP.

* Pricing
  CLEAR T_ATTRIBUTES[].
  LOOP AT T_XML INTO LS_BUFFER.
    PERFORM GET_TAG_ATTRIBUTES USING  'pricing'             "#EC NOTEXT
                                       LS_BUFFER
                                CHANGING T_ATTRIBUTES.
    LOOP AT T_ATTRIBUTES INTO S_ATTRIBUTES.
      CASE S_ATTRIBUTES-NODE_NAME.
        WHEN 'pricing'.                                     "#EC NOTEXT
          LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
            CASE S_ATTRIBUTE-ATTRIBUTENAME.
              WHEN 'kstorgid'.                              "#EC NOTEXT
                WA_S1PC-KSTORGID = S_ATTRIBUTE-VALUE.
              WHEN 'kstbstln'.                              "#EC NOTEXT
                WA_S1PC-KSTBSTLN = S_ATTRIBUTE-VALUE.
              WHEN 'verwzwck'.                              "#EC NOTEXT
                REPLACE_SPACE WA_S1PC-VERWZWCK.
              WHEN 'kostkate'.                              "#EC NOTEXT
                WA_S1PC-KOSTKATE = S_ATTRIBUTE-VALUE.
              WHEN 'kzkosdir'.                              "#EC NOTEXT
                WA_S1PC-KZKOSDIR = S_ATTRIBUTE-VALUE.
              WHEN 'kostendr'.                              "#EC NOTEXT
                WA_S1PC-KOSTENDR = S_ATTRIBUTE-VALUE.
              WHEN 'currency'.                              "#EC NOTEXT
                WA_S1PC-CURRENCY = S_ATTRIBUTE-VALUE.
              WHEN 'kostkatp'.                              "#EC NOTEXT
                WA_S1PC-KOSTKATP = S_ATTRIBUTE-VALUE.
            ENDCASE.
          ENDLOOP.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.
  WA_S1PC-IFCID = IFC_DATA-S1-IFCID.
  WA_S1PC-VRSNR = G_VRSNR.
  MOVE-CORRESPONDING WA_S1PC TO IFC_DATA-S1PC.

* Roles
  CLEAR LT_BUFFER[].
  CLEAR T_ATTRIBUTES[].
  PERFORM GET_TAG_ORG TABLES T_XML
                          LT_BUFFER
                   USING 'contacts'.                        "#EC NOTEXT
  LOOP AT LT_BUFFER INTO LS_BUFFER.
    PERFORM GET_TAG_ATTRIBUTES USING  'role'                "#EC NOTEXT
                                      LS_BUFFER
                               CHANGING T_ATTRIBUTES.
  ENDLOOP.

  LOOP AT T_ATTRIBUTES INTO S_ATTRIBUTES.
    CASE S_ATTRIBUTES-NODE_NAME.
      WHEN 'role'.                                          "#EC NOTEXT
        LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
          CASE S_ATTRIBUTE-ATTRIBUTENAME.
            WHEN 'id'.                                      "#EC NOTEXT
              WA_S1R-TROLE = S_ATTRIBUTE-VALUE(2).
            WHEN 'pernr'.                                   "#EC NOTEXT
              WA_S1R-PERNR = S_ATTRIBUTE-VALUE.
            WHEN 'usern'.                                   "#EC NOTEXT
              WA_S1R-USERN = S_ATTRIBUTE-VALUE.
            WHEN 'orgeh'.                                   "#EC NOTEXT
              WA_S1R-ORGEH = S_ATTRIBUTE-VALUE.
            WHEN 'email'.                                   "#EC NOTEXT
              REPLACE_SPACE WA_S1R-EMAIL.
          ENDCASE.
        ENDLOOP.
    ENDCASE.
    WA_S1R-IFCID = IFC_DATA-S1-IFCID.
    WA_S1R-VRSNR = G_VRSNR.
    APPEND WA_S1R TO IFC_DATA-S1R[].
  ENDLOOP.

* Layout
  PERFORM GET_TAG_ORG TABLES T_XML
                          LT_BUFFER
                   USING 'layout'.                          "#EC NOTEXT

  LOOP AT LT_BUFFER INTO LS_BUFFER.
    PERFORM GET_TAG_ATTRIBUTES USING  'recordtype'          "#EC NOTEXT
                                      LS_BUFFER
                               CHANGING T_ATTRIBUTES.

    PERFORM GET_TAG_ATTRIBUTES USING  'field'               "#EC NOTEXT
                                      LS_BUFFER
                               CHANGING T_ATTRIBUTES.

    PERFORM GET_TAG_ATTRIBUTES USING  'filter'             "SIE002
                                      LS_BUFFER
                               CHANGING T_ATTRIBUTES.

  ENDLOOP.

  CLEAR IFC_DATA-S1SA[].
  CLEAR IFC_DATA-S1PG[].

* Befüllen der Schnittstelleninformationen
  WA_S1SA-IFCID = IFC_DATA-S1-IFCID.
  WA_S1SA-VRSNR = G_VRSNR.
  WA_S1PG-IFCID = IFC_DATA-S1-IFCID.
  WA_S1PG-VRSNR = G_VRSNR.
  WA_S1PS-IFCID = IFC_DATA-S1-IFCID.                       "SIE002
  WA_S1PS-VRSNR = G_VRSNR.                                 "SIE002

  LOOP AT T_ATTRIBUTES INTO S_ATTRIBUTES.
    CASE S_ATTRIBUTES-NODE_NAME.
      WHEN 'recordtype'.
        LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
          CASE S_ATTRIBUTE-ATTRIBUTENAME.
            WHEN 'name'.
              WA_S1SA-RECNA = S_ATTRIBUTE-VALUE(8).
              WA_S1PG-RECNA = WA_S1SA-RECNA.
              WA_S1PS-RECNA = WA_S1SA-RECNA.               "SIE002
            WHEN 'dbahd'. WA_S1SA-DBAHD = S_ATTRIBUTE-VALUE.
            WHEN 'dbaoc'. WA_S1SA-DBAOC = S_ATTRIBUTE-VALUE.
            WHEN 'recty'. WA_S1SA-RECTY = S_ATTRIBUTE-VALUE(1).
            WHEN 'infty'. WA_S1SA-INFTY = S_ATTRIBUTE-VALUE(4).
            WHEN 'subty'. WA_S1SA-SUBTY = S_ATTRIBUTE-VALUE(4).
            WHEN 'kzsrn'. WA_S1SA-KZSRN = S_ATTRIBUTE-VALUE(1).
            WHEN 'kzspn'. WA_S1SA-KZSPN = S_ATTRIBUTE-VALUE(1).
            WHEN 'sortn'. WA_S1SA-SORTN = S_ATTRIBUTE-VALUE.

          WHEN 'operan'. WA_S1SA-OPERAN = S_ATTRIBUTE-VALUE.
          WHEN 'operat'. WA_S1SA-OPERAT = S_ATTRIBUTE-VALUE.
          WHEN 'opeval'. WA_S1SA-OPEVAL = S_ATTRIBUTE-VALUE.

            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
        APPEND WA_S1SA TO IFC_DATA-S1SA.
      WHEN 'field'.
        LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
          CASE S_ATTRIBUTE-ATTRIBUTENAME.
            WHEN 'fname'.   WA_S1PG-FELDNAME = S_ATTRIBUTE-VALUE.
            WHEN 'fldps'.
              WA_S1PG-FLDPS = S_ATTRIBUTE-VALUE.
              WA_S1PS-FLDPS = WA_S1PG-FLDPS.
            WHEN 'mthbk'.   WA_S1PG-MTHBK = S_ATTRIBUTE-VALUE.
            WHEN 'konvnam'. WA_S1PG-KONVNAM = S_ATTRIBUTE-VALUE.
            WHEN 'keypos'.  WA_S1PG-KEYPOS = S_ATTRIBUTE-VALUE.
            when 'nosep'.   WA_S1PG-NOSEP = S_ATTRIBUTE-VALUE. "SIE001
            WHEN 'param'.   WA_S1PG-PARAM = S_ATTRIBUTE-VALUE.
            WHEN 'offst'.   WA_S1PG-OFFST = S_ATTRIBUTE-VALUE.
            WHEN 'paramgb'. WA_S1PG-PARAMGB = S_ATTRIBUTE-VALUE.
            WHEN 'length'.
              WA_S1PG-LENGTH = S_ATTRIBUTE-VALUE.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
        APPEND WA_S1PG TO IFC_DATA-S1PG.
*      SIE002_BEG
       WHEN 'filter'.
        LOOP AT S_ATTRIBUTES-ATTRIBUTES INTO S_ATTRIBUTE.
          CASE S_ATTRIBUTE-ATTRIBUTENAME.
             WHEN 'seqno'.
              WA_S1PS-SEQNO = S_ATTRIBUTE-VALUE.
            WHEN 'ssign'.
              WA_S1PS-SSIGN = S_ATTRIBUTE-VALUE.
            WHEN 'sopti'.
              WA_S1PS-SOPTI = S_ATTRIBUTE-VALUE.
            WHEN 'sllow'.
              WA_S1PS-SLLOW = S_ATTRIBUTE-VALUE.
            WHEN 'shigh'.
              WA_S1PS-SHIGH = S_ATTRIBUTE-VALUE.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
        APPEND WA_S1PS TO IFC_DATA-S1PS.
*       SIE002_END

      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  WA_S1VN-IFCID = IFC_DATA-S1-IFCID.
  WA_S1VN-VRSNR = G_VRSNR_ORG.
  MOVE-CORRESPONDING WA_S1VN TO IFC_DATA-S1VN.

ENDFUNCTION.
