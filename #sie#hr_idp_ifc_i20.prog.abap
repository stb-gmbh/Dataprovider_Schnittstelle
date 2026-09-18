*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_I20 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  EXIT_2000  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_2000 INPUT.
  PERFORM DEQUEUE.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " EXIT_2000  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_2000 INPUT.
  CHECK NOT ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).
  CASE SVCODE.
    WHEN 'CHECK'.
      PERFORM IFCID_CHECK.
    WHEN 'RELE'.
      PERFORM IFCID_RELEASE.
    WHEN 'DOCU' OR 'DOCU2' OR 'DOCU3'.
      PERFORM HANDLE_DOCUMENTATION.
    WHEN 'TRUN'.
      PERFORM IFCID_TEST.
    WHEN C_IFCF_CODE.
      PERFORM HANDLE_IFCF.
    WHEN OTHERS.
* do nothing.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_2000  INPUT
