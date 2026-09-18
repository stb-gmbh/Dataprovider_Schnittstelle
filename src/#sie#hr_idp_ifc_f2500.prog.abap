*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F2500 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  READ_RELEASED_VERS
*&---------------------------------------------------------------------*
*       Einlesen der aktuellen, freigegebenen Version der Schnittstelle
*----------------------------------------------------------------------*
*      -->P_IFCID     Schnittstellen-Identifikation
*      <--P_VERS_NR   Schnittstellenversion
*----------------------------------------------------------------------*
FORM READ_RELEASED_VERS USING P_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID
                        CHANGING P_VERS_NR TYPE /SIE/HR_IDP_VERS_NR.

  CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
       EXPORTING
            INTERFACE         = P_IFCID
            ACTIVE            = YES
       IMPORTING
            VERSION           = P_VERS_NR
       EXCEPTIONS
            NO_ACTIVE_VERSION = 1
            OTHERS            = 2.
  IF SY-SUBRC <> 0.
    CLEAR P_VERS_NR.
  ENDIF.

ENDFORM.                    " READ_RELEASED_VERS

*&---------------------------------------------------------------------*
*&      Form  READ_SHORT_TEXT
*&---------------------------------------------------------------------*
*       Einlesen des Kurztextes einer Schnittstelle
*----------------------------------------------------------------------*
*      -->P_IFCID  Schnittstelle
*      <--P_IDENT  Schnittstellenkurztext
*----------------------------------------------------------------------*
FORM READ_SHORT_TEXT USING    P_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID
                     CHANGING P_IDENT TYPE /SIE/HR_IDP_IFNAME.

  IF NOT ( /SIE/HR_IDP_S1-IFCID IS INITIAL ).
    SELECT SINGLE * FROM /SIE/HR_IDP_S1T
             WHERE IFCID = /SIE/HR_IDP_S1-IFCID
             AND   SPRAS = SY-LANGU.
    IF SY-SUBRC = 0.
      P_IDENT = /SIE/HR_IDP_S1T-IDENT.
    ELSE.
      CLEAR P_IDENT.
    ENDIF.
  ELSE.
    CLEAR P_IDENT.
  ENDIF.

ENDFORM.                    " READ_SHORT_TEXT

*&---------------------------------------------------------------------*
*&      Form  ADHOC_EXECUTION
*&---------------------------------------------------------------------*
*       Ad-Hoc Schnittstellenlauf
*----------------------------------------------------------------------*
FORM ADHOC_EXECUTION.
* Einlesen der letzten freigegebenen Version
  PERFORM READ_RELEASED_VERS USING /SIE/HR_IDP_S1-IFCID
                             CHANGING /SIE/HR_IDP_S1-ACT_VERS_NR.
  IF /SIE/HR_IDP_S1-ACT_VERS_NR IS INITIAL.
    MESSAGE S163.
  ELSE.
    CALL SCREEN 2510 STARTING AT 5 5.
  ENDIF.
ENDFORM.                    " ADHOC_EXECUTION
