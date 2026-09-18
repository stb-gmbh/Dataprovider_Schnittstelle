*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_D700 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.
  okcode = sy-ucomm.
ENDMODULE.                 " USER_COMMAND_0700  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_700 INPUT.
  svcode = sy-ucomm.
* Prüfung: Quellschnittstelle gleich Zielschnittstelle
*  IF /SIE/HR_IDP_S1-IFCID = G_TARGET_IFCID.
*    MESSAGE E016.
*  ENDIF.
*
** Prüfung: Satzart vorhanden?
  READ TABLE g_itab_sa WITH KEY recna = g_700_satzart
       TRANSPORTING NO FIELDS.
  IF sy-subrc LT 4.
    CLEAR okcode.
    MESSAGE e400.
  ENDIF.

* Prüfung ob die Satzart mit // anfängt (für Delta Generator notwendig)
  IF g_700_satzart(2) ='//'.                               "#EC NOTEXT.
    CLEAR okcode.
    MESSAGE e401.
  ENDIF.

ENDMODULE.                 " CHECK_INPUT_700  INPUT
*&---------------------------------------------------------------------*
*&      Module  OK_CODE_700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ok_code_700 INPUT.
  CASE okcode.
    WHEN 'OK'.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN 'BREA'.
      CLEAR g_700_satzart. CLEAR /sie/hr_idp_s1sa.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
*     SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " OK_CODE_700  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_PF_STATUS_700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_pf_status_700 OUTPUT.

  IF svcode = 'COPY_RECNAM'.           "#EC NOTEXT         "SIE005
    SET TITLEBAR  'IFC_MENU' WITH g_ifdata_tran-s1-ifcid   "SIE005
                                  'Satzart kopieren'.      "SIE005
  ELSE.                                                    "SIE005
    SET TITLEBAR  'IFC_MENU' WITH g_ifdata_tran-s1-ifcid 'Neue Satzart'.
  ENDIF.                                                   "SIE005
  SET PF-STATUS 'IFC_POPUP'.
  CLEAR g_700_satzart.
ENDMODULE.                 " SET_PF_STATUS_700  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0700 INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " EXIT_COMMAND_0700  INPUT
