*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I02 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  INIT_PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       Die selektierte Version wird ersteinmal gelöscht
*----------------------------------------------------------------------*
MODULE INIT_PAI_0100 INPUT.
* clear g_ifdata_vers.
ENDMODULE.                 " INIT_PAI_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  SET_VERSION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_VERSION INPUT.
  PERFORM CHECK_VERSION.
ENDMODULE.                 " SET_VERSION  INPUT

*&---------------------------------------------------------------------*
*&      Module  PREPARE_FCODE  INPUT
*&---------------------------------------------------------------------*
*       Dieses Modul prüft, ob eine Version selektiert wurde und
*       ob eine Aktion nötig ist.
*----------------------------------------------------------------------*
MODULE PREPARE_FCODE INPUT.
  IF G_IFDATA_VERS IS INITIAL
     AND NOT ( G_IFDATA_TRAN-S1-IFCID IS INITIAL ).
    CASE OKCODE.
      WHEN C_HEAD_CODE OR C_VARI_CODE OR 'DEFI' OR C_DEFI_CODE.
        CLEAR OKCODE.
        MESSAGE E102.
        LEAVE SCREEN.
      WHEN OTHERS.
*       do nothing.
    ENDCASE.
  ENDIF.
ENDMODULE.                 " PREPARE_FCODE  INPUT


*&---------------------------------------------------------------------*
*&      Module  EXTRACT_USERDATA  INPUT
*&---------------------------------------------------------------------*
*       Falls der Benutzer die Detailansichten einer Schnittstelle
*       sehen möchte, dann wird die selektierte Zeile mit der Version
*       kopiert.
*----------------------------------------------------------------------*
MODULE EXTRACT_USERDATA INPUT.
  CASE SVCODE.
    WHEN C_HEAD_CODE OR C_PROG_CODE OR C_VARI_CODE OR C_DEFI_CODE
         OR C_COPY_CODE OR C_TIME_CODE OR 'OK' OR C_PRIC_CODE.
      PERFORM TRANSFER.
    WHEN OTHERS.
* Do nothing.
  ENDCASE.

ENDMODULE.                 " EXTRACT_USERDATA  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHANGE_TITLE  INPUT
*&---------------------------------------------------------------------*
*       Dieses Modul wird beim neu anlegen der Schnittstelle
*       aufgerufen.
*----------------------------------------------------------------------*
MODULE CHANGE_TITLE INPUT.
  G_IFDATA_TRAN-S1-IFCID = G_IFDATA_TRAN-S1-IFCID.
  FILL_ADM_INFO G_IFDATA_TRAN-S1.
  G_IFDATA_TRAN-S1-ACT_VERS_NR = '0001'.                    "#EC NOTEXT
  G_IFDATA_VERS = '0001'.                                   "#EC NOTEXT
  G_IFDATA_TRAN-S1-NEW_VERSION = YES.

* Langtexte
  MOVE-CORRESPONDING SY TO G_IFDATA_TRAN-S1T.
  G_IFDATA_TRAN-S1T-IFCID = G_IFDATA_TRAN-S1-IFCID.

* Versionen
  MOVE-CORRESPONDING SY TO G_IFDATA_TRAN-S1VN.
  G_IFDATA_TRAN-S1VN-IFCID = G_IFDATA_TRAN-S1-IFCID.
  G_IFDATA_TRAN-S1VN-VRSNR = G_IFDATA_TRAN-S1-ACT_VERS_NR.
  FILL_ADM_INFO G_IFDATA_TRAN-S1VN.

* Noch die Feldleiste füllen
  /SIE/HR_IDP_S1-IFCID =  G_IFDATA_TRAN-S1-IFCID.

* Daten Sperren??

ENDMODULE.                 " CHANGE_TITLE  INPUT

*&---------------------------------------------------------------------*
*&      Module  SET_LINE_COUNT_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_LINE_COUNT_1000 INPUT.
  G_LINE_COUNT = SY-LOOPC.
ENDMODULE.                 " SET_LINE_COUNT_1000  INPUT

*&---------------------------------------------------------------------*
*&      Module  READ_DATA_1000  INPUT
*&---------------------------------------------------------------------*
*       Liest die Transaktionsdaten
*----------------------------------------------------------------------*
MODULE FILL_KEYS_1000 INPUT.

  CASE SY-TCODE.
    WHEN C_NEW__TCOD.

* Beim neu anlegen der Daten müssen ein Paar Defaults vergeben
* werden. Die DB Schnittstelle vergibt Mandt und Admin Informationen.
      G_PROC_VEC-S1 = YES.
      G_PROC_VEC-S1T = YES.
      G_PROC_VEC-S1VN = YES.

* Füllen von globalen Variablen.
      G_IFDATA_VERS = '0001'.                               "#EC NOTEXT

* Füllen der S1t
      G_IFDATA_TRAN-S1T-IFCID = G_IFDATA_TRAN-S1-IFCID.
      G_IFDATA_TRAN-S1T-SPRAS = SY-LANGU.

* Füllen der S1vn
      G_IFDATA_TRAN-S1VN-IFCID = G_IFDATA_TRAN-S1-IFCID.
      G_IFDATA_TRAN-S1VN-VRSNR = G_IFDATA_VERS.

* Füllen der S1F
*break mch0664.
      LOOP AT G_IFDATA_TRAN-S1F INTO WA_S1F.
      WA_S1F-IFCID = G_IFDATA_TRAN-S1-IFCID.
      MODIFY G_IFDATA_TRAN-S1F FROM WA_S1F INDEX SY-TABIX.
      ENDLOOP.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " READ_DATA_1000  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_EXISTENCE  INPUT
*&---------------------------------------------------------------------*
*       Prüft, ob die Schnittstelle existiert.
*----------------------------------------------------------------------*
MODULE CHECK_EXISTENCE INPUT.
  CASE SY-TCODE.
    WHEN C_NEW__TCOD.
      PERFORM CHECK_EXISTANCE CHANGING RC.
      IF RC = 0.
        MESSAGE E109 WITH /SIE/HR_IDP_HEAD-IFCID.
      ENDIF.
    WHEN OTHERS.
* Do nothing.
  ENDCASE.
ENDMODULE.                 " CHECK_EXISTENCE  INPUT
