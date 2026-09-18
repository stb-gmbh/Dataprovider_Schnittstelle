*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_O100 .
*----------------------------------------------------------------------*
DEFINE MODIFY_FIELDS.
  LOOP AT SCREEN.
    IF SCREEN-GROUP2 = &1.
      SCREEN-INPUT = SPACE.
      SCREEN-REQUIRED = SPACE.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
END-OF-DEFINITION.

DEFINE HIDE_FIELDS.
  loop at screen.
    CHECK SCREEN-GROUP3 = &1.
    screen-invisible = '1'.
    modify screen.
  endloop.
END-OF-DEFINITION.

DATA: WA_S1VN TYPE /SIE/HR_IDP_S1VN.

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_100  OUTPUT
*&---------------------------------------------------------------------*
*       Felder eingabe-bereit oder nicht machen. Default:
*       Version ist nicht eingabebereit aber sichtbar und sowohl
*       Schnittstelle als auch Text eingabebereit.
*----------------------------------------------------------------------*
MODULE MODIFY_SCREEN_100 OUTPUT.

  CASE SY-TCODE.
* Anzeigen.
    WHEN C_DISP_TCOD.          " Anzeigen
      CASE G_STATUS_TRAN.
        WHEN C_1000_STAT.      " Hauptdynpro
* Beim Hauptdynpro sollte die Versionsnummer verschwinden,
* der Schnittstellennamen sollte nicht eingabebereit sein. Die
* Schnittstelle sollte eingabebereit sein.
          MODIFY_FIELDS: '002'.
          HIDE_FIELDS: '001'.

        WHEN OTHERS.           " Zweite Ebene
* Bei der zweiten Ebene sollten die Versionsnummer, die Schnittstelle
* und der Text nicht Eingabebereit sein.
          MODIFY_FIELDS: '001'
                       , '002'
                       .
      ENDCASE.

* Anlegen
    WHEN  C_NEW__TCOD.
* Schnittstelle ist Eingabebereit. Der Text ist auf dem 1001 Dynpro
* eingabebereit
      CASE G_STATUS_TRAN.
        WHEN C_1001_STAT.
        WHEN OTHERS.
          MODIFY_FIELDS: '002'.
      ENDCASE.

* Freigegebene Schnittstelle ändern
    WHEN C_RMOD_TCOD.
      CASE G_STATUS_TRAN.
        WHEN C_4000_STAT.      " Hauptdynpro
          MODIFY_FIELDS: '002'.
        WHEN C_4001_STAT.
          LOOP AT SCREEN.
            IF SCREEN-NAME = '/SIE/HR_IDP_HEAD-IFCID'.
              SCREEN-INPUT = '0'.
              MODIFY SCREEN.
            ENDIF.
          ENDLOOP.
        WHEN OTHERS.
      ENDCASE.

* Ändern
    WHEN OTHERS.
      CASE G_STATUS_TRAN.
        WHEN C_1000_STAT.
* Beim Ändern sollte auf dem Übersichtsdynpro die Version verschwinden,
* die Schnittstelle sollte eingabebereit sein und der Text nicht
* Eingabebereit sein.
          MODIFY_FIELDS: '002'.
          HIDE_FIELDS: '001'.
        WHEN OTHERS.
* Beim Ändern auf der zweiten Ebene sollte die Version nicht
* Eingabebereit sein, der Text sollte eingabebereit sein
* (aber nur auf dem 1001 Dynpro)
* und die Version sichtbar aber nicht eingabebereit sein.
          MODIFY_FIELDS: '001'.
* Ausnahme hiervon, ist wenn die Schnittstelle schon freiegegeben
* wurde, denn dann sollte auch auf der zweiten Ebene der
* Text nicht eingabebereit sein!
          CALL FUNCTION '/SIE/HR_IDP_RELE_DATE'
               EXPORTING
                    VRSNR        = G_IFDATA_VERS
                    S1F          = G_IFDATA_TRAN-S1F
               IMPORTING
                    RELEASE_DATE = WA_S1F-CH_DATUM.

          IF NOT ( WA_S1F-CH_DATUM IS INITIAL ).
            MODIFY_FIELDS '002'.
          ENDIF.
      ENDCASE.

      CASE G_STATUS_TRAN.
        WHEN C_1001_STAT.
        WHEN OTHERS.
          MODIFY_FIELDS: '002'.
      ENDCASE.

  ENDCASE.

*BREAK MCH0664.
*  IF G_IFDATA_VERS = 0.
*    LOOP AT SCREEN.
*      IF SCREEN-NAME = '/SIE/HR_IDP_S1-ACT_VERS_NR'.
**         or screen-name = ''.
*        SCREEN-INVISIBLE = '1'.
*        MODIFY SCREEN.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*


ENDMODULE.                 " MODIFY_SCREEN_100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  FILL_DATA_100  OUTPUT
*&---------------------------------------------------------------------*
*       Beim PBO soll das Dynpro die Daten zeigen
*----------------------------------------------------------------------*
MODULE FILL_DATA_100 OUTPUT.

  /SIE/HR_IDP_HEAD-IFCID = G_IFDATA_TRAN-S1-IFCID.
  /SIE/HR_IDP_HEAD-IDENT = G_IFDATA_TRAN-S1T-IDENT.
  /SIE/HR_IDP_HEAD-VRSNR = G_IFDATA_VERS.

  PERFORM FILL_DATA_100 USING /SIE/HR_IDP_HEAD-IFCID
                              /SIE/HR_IDP_HEAD-VRSNR
                        CHANGING /SIE/HR_IDP_HEAD-ICON.

ENDMODULE.                 " FILL_DATA_100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_VERSION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_VERSION OUTPUT.

ENDMODULE.                 " INIT_VERSION  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE INIT_0100 OUTPUT.
  IF ( G_IFDATA_TRAN-S1-IFCID IS INITIAL ).
    GET PARAMETER ID '/SIE/HR_IDP_IFCID' FIELD /SIE/HR_IDP_HEAD-IFCID.
  ENDIF.
ENDMODULE.                 " INIT_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  FILL_DATA_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/SIE/HR_IDP_HEAD_IFCID  text
*      -->P_/SIE/HR_IDP_HEAD_IDENT  text
*      -->P_/SIE/HR_IDP_HEAD_VRSNR  text
*      <--P_SIE/HR_IDP_HEAD_ICON  text
*----------------------------------------------------------------------*
FORM FILL_DATA_100 USING    P_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID
                            P_VRSNR TYPE /SIE/HR_IDP_VERS_NR
                   CHANGING P_ICON TYPE ICON_L4.

  CALL FUNCTION '/SIE/HR_IDP_VERSION_INFO'
       EXPORTING
            INTERFACE_ID = P_IFCID
            VERSION      = P_VRSNR
       IMPORTING
            RC_ICON      = P_ICON.

ENDFORM.                    " FILL_DATA_100

*&---------------------------------------------------------------------*
*&      Module  CHECK_NAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
DATA: L TYPE I.
FIELD-SYMBOLS: <F>.


*---------------------------------------------------------------------*
*       MODULE CHECK_NAME INPUT                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE CHECK_NAME INPUT.

  L = STRLEN( /SIE/HR_IDP_HEAD-IFCID ).
  ASSIGN /SIE/HR_IDP_HEAD-IFCID(L) TO <F>.
  IF <F> CA SPACE.
    MESSAGE E160.
  ENDIF.

ENDMODULE.                 " CHECK_NAME  INPUT
