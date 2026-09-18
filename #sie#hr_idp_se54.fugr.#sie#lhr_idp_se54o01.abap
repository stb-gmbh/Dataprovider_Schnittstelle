*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_SE54O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ENABLE_GROUP1_001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ENABLE_GROUP1_001 OUTPUT.
  IF STATUS-ACTION EQ AENDERN
  OR STATUS-ACTION EQ ANZEIGEN.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 EQ '001'.
        SCREEN-INPUT = 1.
        SCREEN-ACTIVE = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 EQ '001'.
        CHECK SCREEN-NAME >< 'LTEXT'.
        SCREEN-INPUT = 0.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " ENABLE_GROUP1_001  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  READ_QFIELDS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE READ_QFIELDS OUTPUT.
  PERFORM READ_QFIELDS.
ENDMODULE.                 " READ_QFIELDS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ENABLE_GROUP4_001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ENABLE_GROUP4_001 OUTPUT.

  IF STATUS-ACTION NE ANZEIGEN.
    LOOP AT SCREEN.
      CASE /SIE/HR_IDP_VF1T-DPFTYPE.
        WHEN 1.
          CASE SCREEN-GROUP4.
            WHEN '001'.
              SCREEN-INPUT = 1.
              SCREEN-ACTIVE = 1.
              MODIFY SCREEN.
            WHEN '002' OR '003' OR '004'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 0.
              MODIFY SCREEN.
            WHEN OTHERS.
          ENDCASE.
        WHEN 2.
          CASE SCREEN-GROUP4.
            WHEN '002'.
              SCREEN-INPUT = 1.
              SCREEN-ACTIVE = 1.
              MODIFY SCREEN.
            WHEN '001' OR '003' OR '004'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 0.
              MODIFY SCREEN.
            WHEN OTHERS.
          ENDCASE.
        WHEN 3.
          CASE SCREEN-GROUP4.
            WHEN '003'.
              SCREEN-INPUT = 1.
              SCREEN-ACTIVE = 1.
              MODIFY SCREEN.
            WHEN '001' OR '002' OR '004'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 0.
              MODIFY SCREEN.
            WHEN  OTHERS.
          ENDCASE.
        WHEN 4.
          CASE SCREEN-GROUP4.
            WHEN '004'.
              SCREEN-INPUT = 1.
              SCREEN-ACTIVE = 1.
              MODIFY SCREEN.
            WHEN '001' OR '002' OR '003'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 0.
              MODIFY SCREEN.
            WHEN OTHERS.
          ENDCASE.
      ENDCASE.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      CASE /SIE/HR_IDP_VF1T-DPFTYPE.
        WHEN 1.
          CASE SCREEN-GROUP4.
            WHEN '001'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 1.
              MODIFY SCREEN.
            WHEN '002' OR '003' OR '004'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 0.
              MODIFY SCREEN.
            WHEN OTHERS.
          ENDCASE.
        WHEN 2.
          CASE SCREEN-GROUP4.
            WHEN '002'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 1.
              MODIFY SCREEN.
            WHEN '001' OR '003' OR '004'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 0.
              MODIFY SCREEN.
            WHEN OTHERS.
          ENDCASE.
        WHEN 3.
          CASE SCREEN-GROUP4.
            WHEN '003'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 1.
              MODIFY SCREEN.
            WHEN '001' OR '002' OR '004'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 0.
              MODIFY SCREEN.
            WHEN  OTHERS.
          ENDCASE.
        WHEN 4.
          CASE SCREEN-GROUP4.
            WHEN '004'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 1.
              MODIFY SCREEN.
            WHEN '001' OR '002' OR '003'.
              SCREEN-INPUT = 0.
              SCREEN-ACTIVE = 0.
              MODIFY SCREEN.
            WHEN OTHERS.
          ENDCASE.
      ENDCASE.
    ENDLOOP.

  ENDIF.
ENDMODULE.                 " ENABLE_GROUP4_001  OUTPUT
