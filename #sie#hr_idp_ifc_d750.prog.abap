***INCLUDE /SIE/HR_IDP_IFC_D750 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0750  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0750 INPUT.
  okcode = sy-ucomm.
ENDMODULE.                 " USER_COMMAND_0700  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_750  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_input_750 INPUT.
  DATA h_referenz LIKE /sie/hr_idp_s1dl-referenz.

  svcode = sy-ucomm.

* Nur Prüfen bei OK & wenn RefSchnittstelle angegeben
  IF okcode = 'OK' AND
     NOT /sie/hr_idp_s1dl-referenz IS INITIAL.

*    Prüfung auf freigegebene Version
     CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
           EXPORTING
             interface               = /sie/hr_idp_s1dl-referenz
             active                  = 'X'
           IMPORTING
             version                 = /sie/hr_idp_head-vrsnr
           EXCEPTIONS
             no_active_version       = 1
             OTHERS                  = 2
                   .
     IF sy-subrc <> 0.
        MESSAGE e450.
        CLEAR okcode.
      ENDIF.

*    Prüfung ob Referenzschnittstelle nicht selbst referenziert
     SELECT SINGLE referenz FROM /sie/hr_idp_s1dl
                            INTO h_referenz
                            WHERE ifcid = /sie/hr_idp_s1dl-referenz
                              AND vrsnr = /sie/hr_idp_head-vrsnr.

     IF NOT h_referenz IS INITIAL.
        MESSAGE e451.
        CLEAR okcode.
     ENDIF.

  ENDIF.

ENDMODULE.                 " CHECK_INPUT_700  INPUT
*&---------------------------------------------------------------------*
*&      Module  OK_CODE_750  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ok_code_750 INPUT.
  CASE okcode.
    WHEN 'OK'.
*      if old_ifcid = /sie/hr_idp_s1dl-referenz.
         SET SCREEN 0. LEAVE SCREEN.
*      endif.

    WHEN 'BREA'.
      SET SCREEN 0. LEAVE SCREEN.

    WHEN OTHERS.
*     SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " OK_CODE_700  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_PF_STATUS_750  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_pf_status_750 OUTPUT.
  SET TITLEBAR  'IFC_MENU' WITH g_ifdata_tran-s1-ifcid
                                'Referenzschnittstelle'.
  SET PF-STATUS 'IFC_POPUP'.
ENDMODULE.                 " SET_PF_STATUS_700  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0750  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_command_0750 INPUT.
  CLEAR okcode.                  "SIE005
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " EXIT_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*&      Module  init_0750  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_0750 OUTPUT.

   PERFORM get_reference_data.

ENDMODULE.                 " init_0750  OUTPUT
