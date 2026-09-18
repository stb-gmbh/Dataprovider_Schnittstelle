*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_F02                                        *
*----------------------------------------------------------------------*

* Diese Include beinhaltet FORMS für das Dynpro 1000 und 0100.

*&---------------------------------------------------------------------*
*&      Form  TRANSFER
*&---------------------------------------------------------------------*
*       Dieses Form prüft, ob eine Version ausgesucht wurde und
*       merkt sich diese. Das Table Control erlaubt nur eine
*       Zeile als Auswahl.
*----------------------------------------------------------------------*
FORM TRANSFER.

  IF /SIE/HR_IDP_IFC_VERSIONS-SELECTION = YES.
    IF GV_FLAG_NEWVERSION = YES.
      GV_FLAG_NEWVERSION = NO.
      CLEAR G_IFDATA_VERS.
    ELSE.
      MOVE /SIE/HR_IDP_IFC_VERSIONS-VRSNR TO G_IFDATA_VERS.
    ENDIF.
  ENDIF.

ENDFORM.                    " TRANSFER

*&---------------------------------------------------------------------*
*&      Form  FILL_VERSION_DATA
*&---------------------------------------------------------------------*
*       Dieses Form füllt die Versionsdaten ins table control.
*----------------------------------------------------------------------*
FORM FILL_VERSION_DATA.

  DATA: L_WA_VERSION TYPE /SIE/HR_IDP_S1VN
      , FL_X TYPE XFLAG
      , FL_RELEASE TYPE XFLAG
      , FL_ACCEPT TYPE XFLAG
      , FL_RELE TYPE XFLAG
      , L_D1 TYPE D
      , L_D2 TYPE D
      .

  CLEAR G_T_VERS_0100[]. CLEAR /SIE/HR_IDP_IFC_VERSIONS.
  CLEAR FL_RELE.

  SORT G_IFDATA_1000-S1VN BY VRSNR DESCENDING.

  LOOP AT G_IFDATA_1000-S1VN INTO L_WA_VERSION.
    G_T_VERS_0100-VRSNR = L_WA_VERSION-VRSNR.
    G_T_VERS_0100-UNAME = L_WA_VERSION-UNAME.
    G_T_VERS_0100-DATUM = L_WA_VERSION-DATUM.

    CALL FUNCTION '/SIE/HR_IDP_RELE_DATE'
         EXPORTING
              VRSNR        = L_WA_VERSION-VRSNR
              S1F          = G_IFDATA_1000-S1F
         IMPORTING
              RELEASE_DATE = L_D1
              ACCEPT_DATE  = L_D2.

    IF L_D1 IS INITIAL.
      FL_RELEASE = NO.
    ELSE.
      FL_RELEASE = YES.
    ENDIF.

    IF L_D2 IS INITIAL.
      FL_ACCEPT = NO.
    ELSE.
      FL_ACCEPT = YES.
    ENDIF.

    IF FL_RELEASE = NO.
      WRITE ICON_RED_LIGHT TO G_T_VERS_0100-ICON.
    ELSE.
      IF FL_ACCEPT = NO.
        IF FL_RELE = NO.
          FL_RELE = YES.
          WRITE ICON_YELLOW_LIGHT TO G_T_VERS_0100-ICON.
          FL_X = YES.
        ELSE.
          CLEAR G_T_VERS_0100-ICON.
        ENDIF.
      ELSE.
        IF FL_X = NO.
          FL_X = YES.
          FL_RELE = YES.
          WRITE ICON_GREEN_LIGHT TO G_T_VERS_0100-ICON.
        ELSE.
          CLEAR G_T_VERS_0100-ICON.
        ENDIF.
      ENDIF.
    ENDIF.

    APPEND G_T_VERS_0100.
  ENDLOOP.

ENDFORM.                    " FILL_VERSION_DATA

*&---------------------------------------------------------------------*
*&      Form  MUX_CHECK_AUTHORITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MUX_CHECK_AUTHORITY USING VALUE(P_STATUS) TYPE TY_STATUS
                         CHANGING RC LIKE SY-SUBRC.

  DATA: SUBOBJECT(4) TYPE C
      .

  CASE P_STATUS.
    WHEN C_1000_STAT.
      SUBOBJECT = SPACE.
    WHEN C_1001_STAT.
      SUBOBJECT = 'HEAD'.
    WHEN C_1002_STAT.
      SUBOBJECT = 'UC4P'.
    WHEN C_1003_STAT.
      SUBOBJECT = 'SELE'.
    WHEN C_1004_STAT.
      SUBOBJECT = 'DEFI'.
    WHEN C_1005_STAT.
      SUBOBJECT = 'PARA'.
    WHEN C_1006_STAT.
      SUBOBJECT = 'DEFI'.
    WHEN C_DOCU_STAT.
      SUBOBJECT = 'DOCU'.
    WHEN C_PRIC_STAT.
      SUBOBJECT = 'PRIC'.
    WHEN OTHERS.
      SUBOBJECT = SPACE.
  ENDCASE.

  CHECK SUBOBJECT NE SPACE.

  CASE SY-TCODE.
    WHEN '/SIE/HR_IDP_IFC_DISP'.
      PERFORM CHECK_AUTHORITY USING SY-TCODE
                                 C_DISPLAY
                                 G_IFDATA_TRAN-S1-AUTH_CLASS
                                 G_IFDATA_TRAN-S1-IFCID
                                 SUBOBJECT
                        CHANGING RC.
    WHEN '/SIE/HR_IDP_IFC_MOD'.
      PERFORM CHECK_AUTHORITY USING SY-TCODE
                                 C_UPDATE
                                 G_IFDATA_TRAN-S1-AUTH_CLASS
                                 G_IFDATA_TRAN-S1-IFCID
                                 SUBOBJECT
                        CHANGING RC.
    WHEN '/SIE/HR_IDP_IFC_NEW'.
      PERFORM CHECK_AUTHORITY USING SY-TCODE
                                 C_CREATE
                                 G_IFDATA_TRAN-S1-AUTH_CLASS
                                 G_IFDATA_TRAN-S1-IFCID
                                 SUBOBJECT
                        CHANGING RC.
    WHEN  OTHERS.
* undefined. Display Authorization
      PERFORM CHECK_AUTHORITY USING SY-TCODE
                                 C_DISPLAY
                                 G_IFDATA_TRAN-S1-AUTH_CLASS
                                 G_IFDATA_TRAN-S1-IFCID
                                 SUBOBJECT
                        CHANGING RC.
  ENDCASE.

ENDFORM.                    " MUX_CHECK_AUTHORITY
