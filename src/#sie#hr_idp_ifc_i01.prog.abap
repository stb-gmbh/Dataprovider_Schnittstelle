*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_I01                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       Modul zur Behandlung von EXIT Kommandos wie cancel, exit, etc.
*----------------------------------------------------------------------*
MODULE EXIT_COMMAND INPUT.
  CASE OKCODE.
    WHEN  C_BACK_CODE.
*     set screen 0. leave screen.
      PERFORM BACK.
    WHEN C_END__CODE.
*     set screen 0. leave screen.
      PERFORM XEND.
    WHEN C_BREA_CODE.
*     set screen 0. leave screen.
      PERFORM BREA.
    WHEN OTHERS.
*     do nothing.
  ENDCASE.
ENDMODULE.                 " EXIT_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       Verarbeitet alle "NORMALEN" OK Codes für alle Bildschirme
*----------------------------------------------------------------------*
MODULE USER_COMMAND INPUT.

  CASE SY-DYNNR.
    WHEN C_MAIN_DYNP.
      PERFORM PROCESS_OK_CODES_1000.
    WHEN C_HEAD_DYNP.
      PERFORM PROCESS_OK_CODES_1001.
    WHEN C_VARI_DYNP.
      PERFORM PROCESS_OK_CODES_1002.
    WHEN C_PROG_DYNP.
      PERFORM PROCESS_OK_CODES_1003.
    WHEN C_DEFI_DYNP.
      PERFORM PROCESS_OK_CODES_1004."Gibt hier kein Dynpro,obsolet? (RH)
    WHEN C_TIME_DYNP.
      PERFORM PROCESS_OK_CODES_1005.
    WHEN C_1006_DYNP.
      PERFORM PROCESS_OK_CODES_1006.
    WHEN C_1007_DYNP.
      PERFORM PROCESS_OK_CODES_1007.
    WHEN OTHERS.
*     do nothing.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  COPY_OK_CODE  INPUT
*&---------------------------------------------------------------------*
*       Dieses Modul kopiert das OKCODE und löscht es.
*----------------------------------------------------------------------*
MODULE COPY_OK_CODE INPUT.
  SVCODE = OKCODE.
  CLEAR OKCODE.
ENDMODULE.                 " COPY_OK_CODE  INPUT

*&---------------------------------------------------------------------*
*&      Module  INIT  OUTPUT
*&---------------------------------------------------------------------*
*       Es werden die OKCODES initialisiert.
*----------------------------------------------------------------------*
MODULE INIT OUTPUT.

  CLEAR: OKCODE, SVCODE.

  IF ( G_IFDATA_OLDV NE G_IFDATA_TRAN-S1-IFCID ).
    PERFORM DEQUEUE.
* Flag zur Initialisierung der Versionsanzeige im Dynpro 1000 setzen.
* Der Flag wird im Dynpro der Versionsmatrix gelesen und initialisiert.
    IF SY-DYNNR = '1000'.
      FL_NEW_VERSION = YES.
    ENDIF.
  ENDIF.

  IF ( G_IFDATA_OLDV NE G_IFDATA_TRAN-S1-IFCID ) OR
     ( G_IFDATA_VERS NE OLD_VERSION ).

    OLD_VERSION = G_IFDATA_VERS.
    G_IFDATA_OLDV = G_IFDATA_TRAN-S1-IFCID.

* Alles nochmal einlesen, aber nur wenn es nicht um das Anlegen
* einer neuen Schnittstelle handelt
    IF SY-TCODE >< '/SIE/HR_IDP_IFC_NEW'.
      CLEAR G_PROC_VEC.
      CLEAR G_IFDATA_TRAN.
      CLEAR G_ITAB_S1PG[].
      CLEAR G_1004_LOADED.
      CLEAR /SIE/HR_IDP_S1T.
      G_IFDATA_TRAN-S1-IFCID = G_IFDATA_OLDV.
      CLEAR: G_SATZART_OLD, G_700_SATZART, G_FELDNAME,
             G_FELDNAME_IDX.
    ENDIF.

  ENDIF.

  CASE SY-DYNNR.
    WHEN C_MAIN_DYNP.
      CLEAR G_1004_LOADED.
    WHEN OTHERS.
  ENDCASE.

* Bei neuen Schnittstellenangaben, Version vorbelegen.
  IF NOT ( G_IFDATA_TRAN-S1-IFCID IS INITIAL ).
    IF G_IFDATA_VERS IS INITIAL.
      SELECT MAX( VRSNR ) INTO (G_IFDATA_VERS)
                           FROM /SIE/HR_IDP_S1VN
                           WHERE IFCID = G_IFDATA_TRAN-S1-IFCID.
      IF SY-SUBRC >< 0.
        CLEAR G_IFDATA_VERS.
      ELSE.
        GV_FLAG_NEWVERSION = NO.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " INIT  OUTPUT
