*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O200 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CATCH_OKCODE_PICK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CATCH_OKCODE_PICK INPUT.
  PERFORM CATCH_OKCODE_PICK.
ENDMODULE.                 " CATCH_OKCODE_PICK  INPUT

*&---------------------------------------------------------------------*
*&      Form  CATCH_OKCODE_PICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CATCH_OKCODE_PICK.
  DATA: CURSOR_OFFSET     LIKE SY-STEPL
   , CURSOR_LINE       LIKE SY-STEPL
   , CURSOR_FIELD(70) TYPE C
  .

  CASE SVCODE.
    WHEN 'PICK'.
      GET CURSOR FIELD CURSOR_FIELD
                 LINE  CURSOR_LINE
                 OFFSET  CURSOR_OFFSET.
      CASE CURSOR_FIELD(24).
        WHEN '/SIE/HR_IDP_IFC_VERSIONS'.
          CURSOR_LINE = CURSOR_LINE + TC_VERS-TOP_LINE - 1.
          READ TABLE G_T_VERS_0100 INTO /SIE/HR_IDP_IFC_VERSIONS
                                   INDEX CURSOR_LINE.
          G_IFDATA_VERS = /SIE/HR_IDP_IFC_VERSIONS-VRSNR.

        WHEN OTHERS.
      ENDCASE.
  ENDCASE.

ENDFORM.                    " CATCH_OKCODE_PICK
