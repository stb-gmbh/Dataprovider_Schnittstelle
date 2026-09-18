*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O2510 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  READ_2510  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_2510 OUTPUT.

  DATA: L_VRSNR TYPE /SIE/HR_IDP_VERS_NR.

* Müssen wir überhaupt etwas tun? Das einlesen ist nur nötig, wenn wir
* zum ersten Mal hier ankommen.

  IF /SIE/HR_IDP_A1-UC4NM IS INITIAL.
* Existieren für diese Schnittstellendefinition Ad-Hoc Parameter?
    SELECT SINGLE * FROM /SIE/HR_IDP_A1
           WHERE IFCID = /SIE/HR_IDP_S1-IFCID
           AND   VRSNR = /SIE/HR_IDP_S1-ACT_VERS_NR.
    IF SY-SUBRC >< 0.
* Zweite Chance: Die vorherige Version einlesen
      IF /SIE/HR_IDP_S1-ACT_VERS_NR > 1.
        L_VRSNR = /SIE/HR_IDP_S1-ACT_VERS_NR - 1.
        SELECT SINGLE * FROM /SIE/HR_IDP_A1
               WHERE IFCID = /SIE/HR_IDP_S1-IFCID
               AND   VRSNR = L_VRSNR.
        IF SY-SUBRC = 0.
          /SIE/HR_IDP_A1-VRSNR = /SIE/HR_IDP_S1-ACT_VERS_NR.
* Aber hier muß man noch aufpassen, daß die Report-namen richtig
* gesetzt werden!
          PERFORM READ_S1DF.
          /SIE/HR_IDP_A1-PROGR = G_IFDATA_TRAN-S1DF-PROGR.
          /SIE/HR_IDP_A1-VARIA = G_IFDATA_TRAN-S1DF-VARIA.
        ELSE.
* Dritte Chance:
* Einlesen aus der Schnittstellendefinition falls alles leer ist!
          PERFORM READ_S1DF.
          MOVE-CORRESPONDING G_IFDATA_TRAN-S1DF TO /SIE/HR_IDP_A1.
        ENDIF.
      ELSE.
        PERFORM READ_S1DF.
        MOVE-CORRESPONDING G_IFDATA_TRAN-S1DF TO /SIE/HR_IDP_A1.
      ENDIF.
    ENDIF.
  ENDIF.


ENDMODULE.                 " READ_2510  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_2510  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_2510 OUTPUT.
  /SIE/HR_IDP_HEAD-IFCID = /SIE/HR_IDP_S1-IFCID.

  IF G_IFDATA_OLDV NE /SIE/HR_IDP_S1-IFCID.
    CLEAR /SIE/HR_IDP_A1.
    CLEAR G_PROC_VEC. CLEAR G_IFDATA_TRAN.
    G_IFDATA_OLDV = /SIE/HR_IDP_S1-IFCID.
    G_IFDATA_TRAN-S1-IFCID = /SIE/HR_IDP_S1-IFCID.
    G_IFDATA_VERS = /SIE/HR_IDP_S1-ACT_VERS_NR.
  ENDIF.

ENDMODULE.                 " INIT_2510  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_2510  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_2510 OUTPUT.
  SET PF-STATUS 'IFC_ADHOC_EXEC'.                           "#EC NOTEXT
ENDMODULE.                 " STATUS_2510  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2510  INPUT
*&---------------------------------------------------------------------*
*       User-Command für Dynpro 2510
*----------------------------------------------------------------------*
MODULE USER_COMMAND_2510 INPUT.
  CASE SVCODE.
    WHEN 'RESE'.
      PERFORM READ_S1DF.
      MOVE-CORRESPONDING G_IFDATA_TRAN-S1DF TO /SIE/HR_IDP_A1.
    WHEN 'ADHOC'.
      PERFORM EXEC_INTERFACE.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_2510  INPUT
