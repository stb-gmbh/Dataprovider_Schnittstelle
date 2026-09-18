*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O1005 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  READ_1005  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_1005 OUTPUT.

  CLEAR /SIE/HR_IDP_S1PR.

  IF G_IFDATA_TRAN-S1PR IS INITIAL.
    MOVE-CORRESPONDING G_IFDATA_TRAN-S1 TO G_IFDATA_TRAN-S1PR.
    MOVE G_IFDATA_VERS TO G_IFDATA_TRAN-S1PR-VRSNR.
    CLEAR /SIE/HR_IDP_S1PR.
  ENDIF.

  MOVE-CORRESPONDING G_IFDATA_TRAN-S1PR TO /SIE/HR_IDP_S1PR.

  CLEAR: QPPNP-TIMR1,
         QPPNP-TIMR2,
         QPPNP-TIMR3,
         QPPNP-TIMR4,
         QPPNP-TIMR5,
         QPPNP-TIMR6,
         QPPNP-TIMR7.

  CASE /SIE/HR_IDP_S1PR-TIMED.
    WHEN 'Z'.   QPPNP-TIMR6 = YES.
    WHEN 'D'.   QPPNP-TIMR1 = YES.
    WHEN 'M'.   QPPNP-TIMR2 = YES.
    WHEN 'Y'.   QPPNP-TIMR3 = YES.
    WHEN 'P'.   QPPNP-TIMR4 = YES.
    WHEN 'F'.   QPPNP-TIMR5 = YES.
    WHEN 'A'.   QPPNP-TIMR7 = YES.
    WHEN SPACE.
      QPPNP-TIMR1 = YES.
      /SIE/HR_IDP_S1PR-TIMED = 'D'.                         "#EC NOTEXT
  ENDCASE.

ENDMODULE.                 " READ_1005  OUTPUT
