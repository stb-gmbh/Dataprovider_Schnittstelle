FUNCTION /SIE/HR_IDP_GENERATE_VARIANT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"             VALUE(VRSNR) TYPE  /SIE/HR_IDP_VERS_NR
*"             VALUE(TEST_EXEC) TYPE  XFELD DEFAULT SPACE
*"       EXPORTING
*"             VALUE(DBSEL) LIKE  /SIE/HR_IDP_DB_SEL
*"                             STRUCTURE  /SIE/HR_IDP_DB_SEL
*"       CHANGING
*"             VALUE(INTERFACE) TYPE  /SIE/HR_IDP_IFC_DB OPTIONAL
*"----------------------------------------------------------------------
  DATA: REPORT_NAME LIKE RSVAR-REPORT
      , VARI_NAME LIKE  RSVAR-VARIANT
      , VARI_DESC LIKE VARID
      , VARI_CONT TYPE STANDARD TABLE OF RSPARAMS INITIAL SIZE 0
        WITH HEADER LINE
      , VARI_TEXT TYPE STANDARD TABLE OF VARIT INITIAL SIZE 0
        WITH HEADER LINE
      , WA_S1VT LIKE /SIE/HR_IDP_S1VT
      , LT_DUMMY OCCURS 0
      .

  DATA: RS_KEY LIKE RSVARKEY
      , RS_VARI LIKE RVARI OCCURS 20 WITH HEADER LINE
      .

* Freie Abgrenzungen
  DATA: BEGIN OF LT_RSTISEL OCCURS 0,
          TNAME  TYPE TABNAME,
          FNAME  TYPE FIELDNAME,
          SIGN   LIKE RSDSSELOPT-SIGN,
          OPTION LIKE RSDSSELOPT-OPTION,
          LOW    LIKE RSDSSELOPT-LOW,
          HIGH   LIKE RSDSSELOPT-HIGH,
        END   OF LT_RSTISEL.
  DATA: LL_FREESEL_TB TYPE RSDS_RANGE.
  DATA: LL_FREESEL_FR LIKE LINE OF LL_FREESEL_TB-FRANGE_T.
  DATA: LL_FREESEL_SO LIKE LINE OF LL_FREESEL_FR-SELOPT_T.

  DATA: ET_EXPRESSIONS TYPE  RSDS_TEXPR
      , LT_FREESEL TYPE RSDS_TRANGE
      .

  DATA: SUBRC LIKE SY-SUBRC.

  DEFINE FILL_PARAMETER.
    CLEAR VARI_CONT.
    VARI_CONT-SELNAME = &1.
    VARI_CONT-KIND = 'P'.
    VARI_CONT-SIGN = 'I'.
    VARI_CONT-OPTION = 'EQ'.
    VARI_CONT-LOW = &2.
    VARI_CONT-HIGH = SPACE.
    APPEND VARI_CONT.
  END-OF-DEFINITION.

* Einlesen der Schnittstelle
  IF NOT ( INTERFACE IS REQUESTED ).
    CLEAR INTERFACE.
    DBSEL-S1 = YES.
    DBSEL-S1VN = YES.
    DBSEL-S1VT = YES.
    DBSEL-S1DF = YES.
    DBSEL-S1PR = YES.

    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
         EXPORTING
              INTERFACE        = IFCID
              VERSION          = VRSNR
         CHANGING
              TRANSACTION_DATA = INTERFACE
              DBSEL            = DBSEL.
  ENDIF.

* Fill header data of Variant
*perform fill_header.
  VARI_TEXT-REPORT = REPORT_NAME = INTERFACE-S1DF-PROGR.
  VARI_TEXT-VARIANT = VARI_NAME = INTERFACE-S1DF-VARIA.
  VARI_DESC-MANDT = SY-MANDT.
  VARI_TEXT-VTEXT = SPACE.
  VARI_TEXT-LANGU = SY-LANGU.
  APPEND VARI_TEXT.

  VARI_DESC-MANDT = SY-MANDT.
  VARI_DESC-REPORT = REPORT_NAME.
  VARI_DESC-VARIANT = VARI_NAME.
  VARI_DESC-TRANSPORT = 'F'.
  VARI_DESC-ENVIRONMNT = 'A'.
  VARI_DESC-MLANGU = SY-LANGU.
  VARI_DESC-EDAT = SY-DATUM.
  VARI_DESC-ETIME = SY-UZEIT.
  VARI_DESC-ENAME = SY-UNAME.
  VARI_DESC-AEDAT = SY-DATUM.
  VARI_DESC-AETIME = SY-UZEIT.
  VARI_DESC-AENAME = SY-UNAME.

* Zuerst werden die Selektionsparameter eingelesen und eingetragen
  SELECT * FROM /SIE/HR_IDP_F1S.
    LOOP AT INTERFACE-S1VT INTO WA_S1VT
                           WHERE FELDNAME = /SIE/HR_IDP_F1S-FELDNAME.
*      select single * from /sie/hr_idp_f1s
*                      where feldname = wa_s1vt-feldname.
      CASE /SIE/HR_IDP_F1S-SLNAM(2).
        WHEN OTHERS.
          VARI_CONT-SELNAME = /SIE/HR_IDP_F1S-SLNAM.
          VARI_CONT-KIND    = 'S'.
          VARI_CONT-SIGN    = WA_S1VT-SSIGN.
          VARI_CONT-OPTION  = WA_S1VT-SOPTI.
          VARI_CONT-LOW     = WA_S1VT-SLLOW.
          VARI_CONT-HIGH    = WA_S1VT-SHIGH.
          APPEND VARI_CONT.
      ENDCASE.
    ENDLOOP.
    IF SY-SUBRC >< 0.
      CASE /SIE/HR_IDP_F1S-SLNAM(2).
        WHEN OTHERS.
          CLEAR VARI_CONT.
          VARI_CONT-SELNAME = /SIE/HR_IDP_F1S-SLNAM.
          VARI_CONT-KIND    = 'S'.
          VARI_CONT-SIGN    = SPACE.
          VARI_CONT-OPTION  = SPACE.
          VARI_CONT-LOW     = SPACE.
          VARI_CONT-HIGH    = SPACE.
          APPEND VARI_CONT.
      ENDCASE.
    ENDIF.
  ENDSELECT.

* Danach die Parameter (hauptsächlich Zeitselektionen).
  CASE INTERFACE-S1PR-TIMED.
    WHEN 'A'.
      FILL_PARAMETER: 'PNPTIMED' SPACE
                    , 'PNPXABKR' INTERFACE-S1PR-XABKR
                    , 'PNPTIMR1' NO
                    , 'PNPTIMR2' NO
                    , 'PNPTIMR3' NO
                    , 'PNPTIMR4' NO
                    , 'PNPTIMR5' NO
                    , 'PNPTIMR6' YES
                    , 'PNPTIMR7' NO
                    , 'PNPTIMR8' NO
                    , 'PNPTIMR9' YES
                    , 'ABKRO'    SPACE
                    , 'BEGDT' SPACE
                    , 'BEGDO' SPACE
                    , 'ENDDT' SPACE
                    , 'ENDDO' SPACE
                    , 'BEGPT' SPACE
                    , 'BEGPO' SPACE
                    , 'ENDPT' SPACE
                    , 'ENDPO' SPACE
                    , 'P_REL' NO
                    .
      FILL_PARAMETER: 'ABKRO' INTERFACE-S1PR-ABKRO.
    WHEN 'Z'.
      FILL_PARAMETER 'PNPTIMED' SPACE.
      FILL_PARAMETER: 'PNPXABKR' SPACE.
      FILL_PARAMETER: 'PNPTIMR1' NO
                    , 'PNPTIMR2' NO
                    , 'PNPTIMR3' NO
                    , 'PNPTIMR4' NO
                    , 'PNPTIMR5' NO
                    , 'PNPTIMR6' YES
                    , 'PNPTIMR7' NO
                    , 'PNPTIMR8' NO
                    , 'PNPTIMR9' YES
                    , 'ABKRO'    SPACE
                    .
      FILL_PARAMETER: 'BEGDT' INTERFACE-S1PR-BEGDT.
      FILL_PARAMETER: 'BEGDO' INTERFACE-S1PR-BEGDO.
      FILL_PARAMETER: 'ENDDT' INTERFACE-S1PR-ENDDT.
      FILL_PARAMETER: 'ENDDO' INTERFACE-S1PR-ENDDO.
      FILL_PARAMETER: 'BEGPT' INTERFACE-S1PR-BEGPT.
      FILL_PARAMETER: 'BEGPO' INTERFACE-S1PR-BEGPO.
      FILL_PARAMETER: 'ENDPT' INTERFACE-S1PR-ENDPT.
      FILL_PARAMETER: 'ENDPO' INTERFACE-S1PR-ENDPO.
      FILL_PARAMETER: 'P_REL' YES.
    WHEN OTHERS.
      FILL_PARAMETER 'PNPTIMED' INTERFACE-S1PR-TIMED.
      FILL_PARAMETER: 'PNPXABKR' SPACE.
      FILL_PARAMETER: 'PNPTIMR1' NO
                    , 'PNPTIMR2' NO
                    , 'PNPTIMR3' NO
                    , 'PNPTIMR4' NO
                    , 'PNPTIMR5' NO
                    , 'PNPTIMR6' YES
                    , 'PNPTIMR7' NO
                    , 'PNPTIMR8' NO
                    , 'PNPTIMR9' YES
                    , 'ABKRO'    SPACE
                    , 'BEGDT' SPACE
                    , 'BEGDO' SPACE
                    , 'ENDDT' SPACE
                    , 'ENDDO' SPACE
                    , 'BEGPT' SPACE
                    , 'BEGPO' SPACE
                    , 'ENDPT' SPACE
                    , 'ENDPO' SPACE
                    , 'P_REL' NO
                    .

  ENDCASE.

  COMMIT WORK.

  CALL FUNCTION 'RS_VARIANT_DEL_ALL_CLIENTS'
       EXPORTING
            REPORT              = REPORT_NAME
            MANDT               = SY-MANDT
       TABLES
            DEL_VARIANTS        = LT_DUMMY
       EXCEPTIONS
            NOT_AUTHORIZED      = 1
            NOT_EXECUTED        = 2
            NO_REPORT           = 3
            REPORT_NOT_EXISTENT = 4
            REPORT_NOT_SUPPLIED = 5
            VARIANT_LOCKED      = 6
            OTHERS              = 7.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  COMMIT WORK.

  CALL FUNCTION 'RS_CREATE_VARIANT'
       EXPORTING
            CURR_REPORT               = REPORT_NAME
            CURR_VARIANT              = VARI_NAME
            VARI_DESC                 = VARI_DESC
       TABLES
            VARI_CONTENTS             = VARI_CONT
            VARI_TEXT                 = VARI_TEXT
       EXCEPTIONS
            ILLEGAL_REPORT_OR_VARIANT = 1
            ILLEGAL_VARIANTNAME       = 2
            NOT_AUTHORIZED            = 3
            NOT_EXECUTED              = 4
            REPORT_NOT_EXISTENT       = 5
            REPORT_NOT_SUPPLIED       = 6
            VARIANT_EXISTS            = 7
            VARIANT_LOCKED            = 8
            OTHERS                    = 9.
  CASE SY-SUBRC.
    WHEN 0. " All OK
    WHEN 3.  " No authorizations
    WHEN 7. " Variant exists allready
*      break-point.
      CALL FUNCTION 'RS_CHANGE_CREATED_VARIANT'
           EXPORTING
                CURR_REPORT               = REPORT_NAME
                CURR_VARIANT              = VARI_NAME
                VARI_DESC                 = VARI_DESC
           TABLES
                VARI_CONTENTS             = VARI_CONT
                VARI_TEXT                 = VARI_TEXT
           EXCEPTIONS
                ILLEGAL_REPORT_OR_VARIANT = 1
                ILLEGAL_VARIANTNAME       = 2
                NOT_AUTHORIZED            = 3
                NOT_EXECUTED              = 4
                REPORT_NOT_EXISTENT       = 5
                REPORT_NOT_SUPPLIED       = 6
                VARIANT_DOESNT_EXIST      = 7
                VARIANT_LOCKED            = 8
                SELECTIONS_NO_MATCH       = 9
                OTHERS                    = 10.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

  COMMIT WORK.

  IF TEST_EXEC = SPACE.

* Zweite Variante erzeugen, um ADHOC Läufe zu realisieren
    FILL_PARAMETER: 'P_ADHOC' YES.
    CONCATENATE VARI_NAME '_AH' INTO VARI_NAME.
    VARI_DESC-VARIANT = VARI_NAME.
    VARI_DESC-VARIANT = VARI_NAME.
    LOOP AT VARI_TEXT.
      VARI_TEXT-VARIANT = VARI_NAME.
      MODIFY VARI_TEXT.
    ENDLOOP.

    CALL FUNCTION 'RS_CREATE_VARIANT'
         EXPORTING
              CURR_REPORT               = REPORT_NAME
              CURR_VARIANT              = VARI_NAME
              VARI_DESC                 = VARI_DESC
         TABLES
              VARI_CONTENTS             = VARI_CONT
              VARI_TEXT                 = VARI_TEXT
         EXCEPTIONS
              ILLEGAL_REPORT_OR_VARIANT = 1
              ILLEGAL_VARIANTNAME       = 2
              NOT_AUTHORIZED            = 3
              NOT_EXECUTED              = 4
              REPORT_NOT_EXISTENT       = 5
              REPORT_NOT_SUPPLIED       = 6
              VARIANT_EXISTS            = 7
              VARIANT_LOCKED            = 8
              OTHERS                    = 9.
    CASE SY-SUBRC.
      WHEN 0. " All OK
      WHEN 3.  " No authorizations
      WHEN 7. " Variant exists allready
        CALL FUNCTION 'RS_CHANGE_CREATED_VARIANT'
             EXPORTING
                  CURR_REPORT               = REPORT_NAME
                  CURR_VARIANT              = VARI_NAME
                  VARI_DESC                 = VARI_DESC
             TABLES
                  VARI_CONTENTS             = VARI_CONT
                  VARI_TEXT                 = VARI_TEXT
             EXCEPTIONS
                  ILLEGAL_REPORT_OR_VARIANT = 1
                  ILLEGAL_VARIANTNAME       = 2
                  NOT_AUTHORIZED            = 3
                  NOT_EXECUTED              = 4
                  REPORT_NOT_EXISTENT       = 5
                  REPORT_NOT_SUPPLIED       = 6
                  VARIANT_DOESNT_EXIST      = 7
                  VARIANT_LOCKED            = 8
                  SELECTIONS_NO_MATCH       = 9
                  OTHERS                    = 10.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
    ENDCASE.

  ENDIF.

  COMMIT WORK.

ENDFUNCTION.
