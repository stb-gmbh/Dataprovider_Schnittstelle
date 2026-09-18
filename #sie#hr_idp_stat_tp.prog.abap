*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_STAT_TP                                        *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PRINT_HEADER
*&---------------------------------------------------------------------*
FORM PRINT_HEADER.

  NEW-PAGE.

  CLEAR G_MARK.
*  write: / g_mark as checkbox.

  HIDE: WA_S1P-IFCID, WA_S1P-SEQNO.

  IF WA_S1P-ERROR = YES.
    WRITE: ICON_RED_LIGHT.
  ELSE.
    WRITE: ICON_GREEN_LIGHT.
  ENDIF.

  WRITE:
         'Protokolldaten der Schnittstelle'(001)
       , WA_S1P-IFCID NO-GAP
       , 'Lauf '(003)
       , WA_S1P-SEQNO
       .
ENDFORM.                    " PRINT_HEADER
