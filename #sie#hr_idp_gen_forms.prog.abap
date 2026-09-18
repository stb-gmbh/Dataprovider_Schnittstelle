*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_GEN_FORMS                                      *
*----------------------------------------------------------------------*

* FRAGE: Wird dieses Include auch dann funktionieren, wenn mehrere
* Schnittstellen darauf zugreifen??? Wenn nicht, müssen wir die
* eine andere Speicherarchitektur ausarbeiten!!! Zum Bespiel
* dürfen dann keine externen Performs mehr hierher aufrufen.

*&---------------------------------------------------------------------*
*&      Form  INIT_STATS
*&---------------------------------------------------------------------*
*       Aufruf bei START-OF-SELECTION
*----------------------------------------------------------------------*
*   --> P_IFCID    Interface ID
*----------------------------------------------------------------------*
FORM INIT_STATISTICS
                USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID.

  DATA: L_S1P LIKE /SIE/HR_IDP_S1P.

  _BEGDA = SY-DATUM.
  _BEGUZ = SY-UZEIT.

  CLEAR: SELPN, NUMBR, SEQNO, FL_EMAIL, FL_ERROR, G_S1S[].

  SELECT MAX( SEQNO ) FROM /SIE/HR_IDP_S1P
         INTO /SIE/HR_IDP_S1P-SEQNO
         WHERE IFCID = P_IFCID.

  SEQNO = /SIE/HR_IDP_S1P-SEQNO + 1.

  G_S1L_IDX = 0.

ENDFORM.                    " INIT_STATS

*&---------------------------------------------------------------------*
*&      Form  UPDATE_STATISTICS
*&---------------------------------------------------------------------*
*       Aufruf im GET PERNR
*----------------------------------------------------------------------*
FORM UPDATE_STATISTICS
   USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID
         VALUE(P_JUPER) TYPE JUPER
         VALUE(P_WERKS) TYPE PERSA
         VALUE(P_BREIN) TYPE /SIE/HR_PM_BREINH.

  NUMBR = NUMBR + 1.

  PERFORM FILL_S1S USING P_IFCID
                         P_JUPER
                         P_WERKS
                         P_BREIN.

ENDFORM.                    " UPDATE_STATISTICS

*&---------------------------------------------------------------------*
*&      Form  WRITE_STATS
*&---------------------------------------------------------------------*
*  Aufruf beim END-OF-SELECTION
*----------------------------------------------------------------------*
FORM WRITE_STATISTICS
                 USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID
                       VALUE(P_VRSNR) TYPE /SIE/HR_IDP_VERS_NR
                       VALUE(P_VARIA) TYPE VARIANT
                       VALUE(P_UC4NAM) TYPE /SIE/HR_IDP_UC4_UNAME.

  PERFORM WRITE_S1S.
  PERFORM WRITE_S1P USING P_IFCID P_VRSNR P_VARIA P_UC4NAM.

ENDFORM.                    " WRITE_STATS

*---------------------------------------------------------------------*
*       FORM APPEND_LOG                                               *
*---------------------------------------------------------------------*
FORM APPEND_LOG USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID
                     VALUE(P_LOGTP) TYPE /SIE/HR_IDP_LOGTP
                     VALUE(P_TEXT) TYPE TEXT60.

  CLEAR /SIE/HR_IDP_S1L.

  G_S1L_IDX = G_S1L_IDX + 1.

  /SIE/HR_IDP_S1L-IFCID = P_IFCID.
  /SIE/HR_IDP_S1L-SEQNO = SEQNO.
  /SIE/HR_IDP_S1L-SUBSQ = G_S1L_IDX.
  /SIE/HR_IDP_S1L-LOGTP = P_LOGTP.
  /SIE/HR_IDP_S1L-TEXT = P_TEXT.

  INSERT /SIE/HR_IDP_S1L.

  COMMIT WORK.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM SET_ERROR                                                *
*---------------------------------------------------------------------*
*       Setzt den Fehler Flag                                         *
*---------------------------------------------------------------------*
FORM SET_ERROR.
  FL_ERROR = 'X'.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM SET_EMAIL                                                *
*---------------------------------------------------------------------*
*       Setzt den Email Flag                                          *
*---------------------------------------------------------------------*
FORM SET_EMAIL.
  FL_EMAIL = 'X'.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM WRITE_S1P                                                *
*---------------------------------------------------------------------*
*       Schreibt ein Statistikprotokoll.                              *
*---------------------------------------------------------------------*
*   --> P_IFCID    Schnittstellenname
*   --> P_VRSNR    Schnittstellen Version
*   --> P_VARIA    Variantennamen
*---------------------------------------------------------------------*
FORM WRITE_S1P USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID
                     VALUE(P_VRSNR) TYPE /SIE/HR_IDP_VERS_NR
                     VALUE(P_VARIA) TYPE VARIANT
                     VALUE(P_UC4NAM) TYPE /SIE/HR_IDP_UC4_UNAME.

  /SIE/HR_IDP_S1P-MANDT = SY-MANDT.
  /SIE/HR_IDP_S1P-IFCID = P_IFCID.
  /SIE/HR_IDP_S1P-BEGUZ = _BEGUZ.
  /SIE/HR_IDP_S1P-ENDUZ = SY-UZEIT.
  /SIE/HR_IDP_S1P-BEGDA = _BEGDA.
  /SIE/HR_IDP_S1P-ENDDA = SY-DATUM.
  /SIE/HR_IDP_S1P-NUMBR = NUMBR.
  /SIE/HR_IDP_S1P-SEQNO = SEQNO.
  /SIE/HR_IDP_S1P-IFCID = P_IFCID.
  /SIE/HR_IDP_S1P-VARIA = P_VARIA.
  /SIE/HR_IDP_S1P-PROGR = SY-REPID.
  /SIE/HR_IDP_S1P-VRSNR = P_VRSNR.
  /SIE/HR_IDP_S1P-ERROR = FL_ERROR.
  /SIE/HR_IDP_S1P-EMAIL = FL_EMAIL.
  /SIE/HR_IDP_S1P-PFNAM = DSN.
  /SIE/HR_IDP_S1P-UC4NAM = P_UC4NAM.

  INSERT INTO /SIE/HR_IDP_S1P VALUES /SIE/HR_IDP_S1P.
  COMMIT WORK.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_S1S
*&---------------------------------------------------------------------*
*       Füllt die Statistiktabelle
*----------------------------------------------------------------------*
FORM FILL_S1S USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID
                    VALUE(P_JUPER) TYPE JUPER
                    VALUE(P_WERKS) TYPE PERSA
                    VALUE(P_BREIN) TYPE /SIE/HR_PM_BREINH.

  /SIE/HR_IDP_S1S-MANDT = SY-MANDT.
  /SIE/HR_IDP_S1S-IFCID = P_IFCID.
  /SIE/HR_IDP_S1S-SELPN = 1.
  /SIE/HR_IDP_S1S-JUPER = P_JUPER.
  /SIE/HR_IDP_S1S-WERKS = P_WERKS.
  /SIE/HR_IDP_S1S-BREIN = P_BREIN.
  /SIE/HR_IDP_S1S-SEQNO = SEQNO.

  COLLECT /SIE/HR_IDP_S1S INTO G_S1S.

ENDFORM.                                                    " FILL_S1S

*&---------------------------------------------------------------------*
*&      Form  WRITE_S1S
*&---------------------------------------------------------------------*
*       Schreibt die Statistikdatei auf die DB
*----------------------------------------------------------------------*
FORM WRITE_S1S.

  DATA: L_S1S TYPE /SIE/HR_IDP_S1S.

  DESCRIBE TABLE G_S1S.
  CHECK SY-TFILL > 0.

  LOOP AT G_S1S INTO L_S1S.
    L_S1S-SUBSQ = SY-TABIX.
    MODIFY G_S1S FROM L_S1S INDEX SY-TABIX.
  ENDLOOP.

  INSERT /SIE/HR_IDP_S1S FROM TABLE G_S1S.
  COMMIT WORK.

ENDFORM.                                                    " WRITE_S1S

*---------------------------------------------------------------------*
*       FORM COMPOSE_MESSAGE                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM COMPOSE_MESSAGE USING P_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID.

  DATA: MESSAGE_TEXT LIKE SY-LISEL.

  CALL FUNCTION 'RPY_MESSAGE_COMPOSE'
       EXPORTING
            MESSAGE_ID        = SY-MSGID
            MESSAGE_NUMBER    = SY-MSGNO
            MESSAGE_VAR1      = SY-MSGV1
            MESSAGE_VAR2      = SY-MSGV2
            MESSAGE_VAR3      = SY-MSGV3
            MESSAGE_VAR4      = SY-MSGV4
       IMPORTING
            MESSAGE_TEXT      = MESSAGE_TEXT
       EXCEPTIONS
            MESSAGE_NOT_FOUND = 1
            OTHERS            = 2.
  IF SY-SUBRC <> 0.
* Hier sollte u.U. ein Dump erzeugt werden!
    PERFORM APPEND_LOG USING P_IFCID
                              SY-MSGTY
                              'Unbekannte Systemnachricht!'.
  ELSE.
    PERFORM APPEND_LOG USING P_IFCID
                              SY-MSGTY
                              MESSAGE_TEXT(60).
  ENDIF.

ENDFORM.
