*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_VALIDITY_I5200 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_5200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_5200 INPUT.

  CASE SVCODE.
    WHEN 'OK  '.                                            "#EC NOTEXT
      IF NOT ( GT_INTERFACES-IFCID IS INITIAL ).
        CALL FUNCTION '/SIE/HR_IDP_IFC_PRINT'
             EXPORTING
                  INTERFACE = GT_INTERFACES-IFCID
                  FORM      = '/SIE/HR_IDP_IFCB'
                  RECEIVERS = /SIE/HR_IDP_ROLES.
      ENDIF.
     SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
     SET SCREEN 0. LEAVE SCREEN.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_5200  INPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_5200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_5200 OUTPUT.

  IF ( /SIE/HR_IDP_ROLES-R01 IS INITIAL ) AND
   ( /SIE/HR_IDP_ROLES-R02 IS INITIAL ) AND
   ( /SIE/HR_IDP_ROLES-R03 IS INITIAL ) AND
   ( /SIE/HR_IDP_ROLES-R04 IS INITIAL ) AND
   ( /SIE/HR_IDP_ROLES-R05 IS INITIAL ) AND
   ( /SIE/HR_IDP_ROLES-R06 IS INITIAL ) AND
   ( /SIE/HR_IDP_ROLES-R07 IS INITIAL ).

    /SIE/HR_IDP_ROLES-R04 = 'X'.
    /SIE/HR_IDP_ROLES-R05 = 'X'.
    /SIE/HR_IDP_ROLES-R04_CC = 'X'.

  ENDIF.


  IF /SIE/HR_IDP_ROLES-CC IS INITIAL.
    CLEAR G_CC.
    CALL FUNCTION '/SIE/HR_IDP_DEFAULT_CC'
         IMPORTING
              CC = G_CC.
    /SIE/HR_IDP_ROLES-CC = G_CC.
  ENDIF.

ENDMODULE.                 " INIT_5200  OUTPUT
