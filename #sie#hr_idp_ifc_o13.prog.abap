*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_O13                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  SET_SUB_D1003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_SUB_D1003 OUTPUT.
  IF DYNPRONR IS INITIAL.
    DYNPRONR = '1103'.
    S1DF-ACTIVETAB = 'UC4'.

  ENDIF.
ENDMODULE.                 " SET_SUB_D1003  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_1003  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_1003 OUTPUT.
* beginn datum vorschlagen (aus s1)
  IF G_IFDATA_TRAN-S1DF-UC4FR IS INITIAL.
    G_IFDATA_TRAN-S1DF-UC4FR = G_IFDATA_TRAN-S1-VALID_FROM.
  ELSE.
* Alter Wert
  ENDIF.

* Ende Datum Vorschlagen (aus S1)
  IF G_IFDATA_TRAN-S1DF-UC4TO IS INITIAL.
    G_IFDATA_TRAN-S1DF-UC4TO = G_IFDATA_TRAN-S1-VALID_TO.
  ENDIF.

* Defaults für generierte Programme
  IF ( G_IFDATA_TRAN-S1DF-GNRTD IS INITIAL ) AND
     ( G_IFDATA_TRAN-S1DF-GNRVT IS INITIAL ) AND
     ( G_IFDATA_TRAN-S1DF-PROGR IS INITIAL ) AND
     ( G_IFDATA_TRAN-S1DF-VARIA IS INITIAL ).
    G_IFDATA_TRAN-S1DF-GNRTD = 'X'.
    G_IFDATA_TRAN-S1DF-GNRVT = 'X'.
  ENDIF.

  MOVE-CORRESPONDING G_IFDATA_TRAN-S1DF TO /SIE/HR_IDP_S1DF.

  PERFORM GET_XUNAME USING /SIE/HR_IDP_S1DF-UC4NM
                    CHANGING /SIE/HR_IDP_QIFC-XUNAME.


ENDMODULE.                 " READ_1003  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_RADIOB  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SET_RADIOB OUTPUT.

  CLEAR L_DAY. CLEAR L_OWNDF.

* Prüfe ob alles leer ist.
  IF ( /SIE/HR_IDP_S1DF-UC4DY IS INITIAL ) AND
     ( /SIE/HR_IDP_S1DF-UC4PR IS INITIAL ) AND
     ( /SIE/HR_IDP_S1DF-UC4NR IS INITIAL ).
    L_DAY = 'X'.
  ELSE.
    IF NOT ( /SIE/HR_IDP_S1DF-UC4DY IS INITIAL ).
      L_DAY = 'X'.
    ELSE.
      L_OWNDF = 'X'.
    ENDIF.
  ENDIF.
ENDMODULE.                 " SET_RADIOB  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  modify_screen_1103  OUTPUT
*&---------------------------------------------------------------------*
*       Checkbox Deltalieferung grausteuern, wenn von
*       Referenzschnittstelle übernommen
*----------------------------------------------------------------------*
module modify_screen_1103 output.

 IF NOT g_ifdata_tran-s1dl-referenz IS INITIAL.
    LOOP AT SCREEN.
       IF screen-name = '/SIE/HR_IDP_S1DF-DELTA'.
          screen-input = '0'.
          MODIFY SCREEN.
       ENDIF.
    ENDLOOP.
  ENDIF.

endmodule.                 " modify_screen_1103  OUTPUT
