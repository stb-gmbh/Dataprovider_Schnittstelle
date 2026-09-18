*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_ALERT_F00                                  *
*----------------------------------------------------------------------*
* 20141104|ML  | Unicode-Umstellung (INC5560081)                ML001  *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  INIT_SELECTION
*&---------------------------------------------------------------------*
*       Initialisiert das Selektionsbildschirm
*----------------------------------------------------------------------*
FORM init_selection.

  IF ( p_01 IS INITIAL )
    AND ( p_02 IS INITIAL )
    AND ( p_03 IS INITIAL )
    AND ( p_04 IS INITIAL )
    AND ( p_05 IS INITIAL )
    AND ( p_06 IS INITIAL )
    AND ( p_07 IS INITIAL ).
    p_04 = 'X'. p_05 = 'X'.  " Fachlicher/Technischer Ansprechpartner
  ENDIF.

  IF form IS INITIAL.
    form = '/SIE/HR_IDP_IFCG'.  " Formular (Gültigkeitsintervall!)
  ENDIF.

*  IF CC IS INITIAL.
*    CALL FUNCTION '/SIE/HR_IDP_DEFAULT_CC'
*         IMPORTING
*              CC = CC.
*  ENDIF.

  IF von IS INITIAL.
    von = /sie/hr_icl_constant=>gc_adr_remedy.
  ENDIF.

ENDFORM.                    " INIT_SELECTION

*&---------------------------------------------------------------------*
*&      Form  NAMEREQUEST
*&---------------------------------------------------------------------*
*       Ermöglicht eine F4 Hilfe für SAPSCRIPT Formulare
*----------------------------------------------------------------------*
FORM namerequest.
  DATA lc_field(56) type c.                           "ML001
  FIELD-SYMBOLS <lf_field> type c.                    "ML001
  ASSIGN rstxd TO <lf_field> CASTING.                 "ML001
  lc_field = <lf_field>.                              "ML001

  SUBMIT rstxfcat VIA SELECTION-SCREEN AND RETURN.
  GET PARAMETER ID 'TTX' FIELD lc_field.              "ML001
*  GET PARAMETER ID 'TTX' FIELD rstxd.                "ML001
  CHECK rstxd-tdform NE space.
  form    = rstxd-tdform.
  spras   = rstxd-tdspras.
ENDFORM.                    " NAMEREQUEST
