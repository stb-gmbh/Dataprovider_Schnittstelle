*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O04 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE FILL_0400 OUTPUT.
* Es werden nun die Felder entweder ausgeblendet oder angezeigt,
* bzw als Mußfelder deklariert, je nach +/*/- Matrix
  PERFORM SHOW_HIDE_MATRIX.
ENDMODULE.                 " FILL_0400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_MATRIX  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
DEFINE FILL_MATRIX_DATA.
* Füllen der Darstellungsmatrix
  CLEAR /SIE/HR_IDP_S1R. CLEAR /SIE/HR_IDP_IFC_ROLES-TROLE.
  /SIE/HR_IDP_IFC_ROLES-TROLE = &1.
  PERFORM GET_DOMA_TEXT USING /SIE/HR_IDP_IFC_ROLES-TROLE
                        CHANGING /SIE/HR_IDP_IFC_ROLES-TEXT.
  APPEND /SIE/HR_IDP_IFC_ROLES TO G_ITAB_S1R.
* Füllen der DB Matrix
  /SIE/HR_IDP_S1R-MANDT = SY-MANDT.
  /SIE/HR_IDP_S1R-IFCID = G_IFDATA_TRAN-S1-IFCID.
  /SIE/HR_IDP_S1R-VRSNR = '0001'.
  /SIE/HR_IDP_S1R-TROLE = &1.
  APPEND /SIE/HR_IDP_S1R TO G_IFDATA_TRAN-S1R.
END-OF-DEFINITION.

*---------------------------------------------------------------------*
*       MODULE FILL_MATRIX OUTPUT                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE FILL_MATRIX OUTPUT.

  CLEAR G_ITAB_S1R[]. CLEAR /SIE/HR_IDP_IFC_ROLES.

* Ist die Tabelle schon mal gefüllt geworden?
  DESCRIBE TABLE G_IFDATA_TRAN-S1R.
  IF SY-TFILL = 0.
    FILL_MATRIX_DATA: '01', '02', '03', '04', '05', '06', '07'.  " Nein
  ELSE.
* Ja, fülle mir die Tabelle gemäß g_ifdata_tran-s1r.
    LOOP AT G_IFDATA_TRAN-S1R INTO /SIE/HR_IDP_S1R.
      MOVE-CORRESPONDING /SIE/HR_IDP_S1R TO /SIE/HR_IDP_IFC_ROLES.
      PERFORM GET_DOMA_TEXT USING /SIE/HR_IDP_IFC_ROLES-TROLE
                            CHANGING /SIE/HR_IDP_IFC_ROLES-TEXT.

      PERFORM GET_ENAME USING /SIE/HR_IDP_IFC_ROLES-PERNR
                        CHANGING /SIE/HR_IDP_IFC_ROLES-ENAME.

      PERFORM GET_XUNAME USING /SIE/HR_IDP_IFC_ROLES-USERN
                        CHANGING /SIE/HR_IDP_IFC_ROLES-XUNAME.

      PERFORM GET_ORGTX USING /SIE/HR_IDP_IFC_ROLES-ORGEH
                        CHANGING /SIE/HR_IDP_IFC_ROLES-ORGTX.

      APPEND /SIE/HR_IDP_IFC_ROLES TO G_ITAB_S1R.
    ENDLOOP.
  ENDIF.

  DESCRIBE TABLE G_IFDATA_TRAN-S1R LINES TAB_LINES.
  TC_MATRIX-LINES = TAB_LINES.
ENDMODULE.                 " FILL_MATRIX  OUTPUT
