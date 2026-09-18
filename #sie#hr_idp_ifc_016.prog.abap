*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_016 .
*----------------------------------------------------------------------*

MODULE EXIT_COMMAND_0600 INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  CHECK_INPUT_600  INPUT
*&---------------------------------------------------------------------*
*       Prüfung ob die Quell- und Zielschnittstelle gelich sind.
*----------------------------------------------------------------------*
MODULE CHECK_INPUT_600 INPUT.

* Prüfung: Quellschnittstelle gleich Zielschnittstelle
  IF /SIE/HR_IDP_COPY_FIELDS-IFCID = /SIE/HR_IDP_COPY_FIELDS-NEW_IFCID.
    MESSAGE E016.
  ENDIF.

* Prüfung: Quellschnittstelle vorhanden?
  SELECT SINGLE * FROM /SIE/HR_IDP_S1
                  WHERE IFCID = /SIE/HR_IDP_COPY_FIELDS-IFCID.

  IF SY-SUBRC <> 0.
    MESSAGE E017.
  ENDIF.

ENDMODULE.                 " CHECK_INPUT_600  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0600 INPUT.
  CASE SVCODE.
    WHEN 'COPY'.                                            "#EC NOTEXT
      PERFORM COPY_INTERFACE.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0600  INPUT

*&---------------------------------------------------------------------*
*&      Form  COPY_INTERFACE
*&---------------------------------------------------------------------*
*       Schnittstellen kopieren
*----------------------------------------------------------------------*
FORM COPY_INTERFACE.

  DATA: L_DBSEL TYPE /SIE/HR_IDP_DB_SEL VALUE C_ALL_TABL
      , OLD_INTERFACE TYPE /SIE/HR_IDP_IFC_DB
      , NEW_INTERFACE TYPE /SIE/HR_IDP_IFC_DB
      .

  CLEAR OLD_INTERFACE.

  CALL FUNCTION '/SIE/HR_IDP_DB_READ'
       EXPORTING
            INTERFACE        = /SIE/HR_IDP_COPY_FIELDS-IFCID
            VERSION          = /SIE/HR_IDP_COPY_FIELDS-VRSNR
       CHANGING
            TRANSACTION_DATA = OLD_INTERFACE
            DBSEL            = L_DBSEL.

  CALL FUNCTION '/SIE/HR_IDP_IFC_COPY'
       EXPORTING
            OLD_INTERFACE = OLD_INTERFACE
            NEW_ID        = /SIE/HR_IDP_COPY_FIELDS-NEW_IFCID
            NEW_VERSION   = '0001'                          "#EC NOTEXT
            ACT_VERSION   = '0000'  "Initial! "#EC NOTEXT
            DBSEL         = L_DBSEL
       IMPORTING
            NEW_INTERFACE = NEW_INTERFACE.

  CALL FUNCTION '/SIE/HR_IDP_DB_UPDATE'
       EXPORTING
            INTERFACE        = /SIE/HR_IDP_COPY_FIELDS-NEW_IFCID
            VERSION          = '0001'                       "#EC NOTEXT
            SW_COMMIT_WORK   = YES
       CHANGING
            TRANSACTION_DATA = NEW_INTERFACE
            DBSEL            = L_DBSEL.

  CLEAR G_IFDATA_TRAN.
  CLEAR /SIE/HR_IDP_HEAD.

  G_IFDATA_TRAN-S1-IFCID = /SIE/HR_IDP_COPY_FIELDS-NEW_IFCID.
  /SIE/HR_IDP_HEAD-IFCID = /SIE/HR_IDP_COPY_FIELDS-NEW_IFCID.
  G_IFDATA_VERS = '0001'.                                   "#EC NOTEXT

  MESSAGE S061 WITH /SIE/HR_IDP_COPY_FIELDS-IFCID
                    /SIE/HR_IDP_COPY_FIELDS-VRSNR.

  CALL FUNCTION '/SIE/HR_IDP_DB_INIT'
            .

ENDFORM.                    " COPY_INTERFACE
