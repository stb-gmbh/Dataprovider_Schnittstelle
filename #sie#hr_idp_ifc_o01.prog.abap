*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_O01                                        *
*----------------------------------------------------------------------*
*Änderungen: SIE003 Hierl 23.06.2004 Neue Tabelle S1PS für Filter auf
*                                    Feldebene eingebaut

*&---------------------------------------------------------------------*
*&      Module  SET_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       Es werden in Abhängigkeit der Transaktion die Menüs und
*       Titelleisten geändert.
*----------------------------------------------------------------------*
MODULE set_status OUTPUT.

  PERFORM exclude_commands.

* Setzte die Titel und Menüs.
  SET PF-STATUS c_modi_pfst EXCLUDING g_excl_commands.
  CASE sy-tcode.
    WHEN c_modi_tcod.
      SET TITLEBAR g_pf_title WITH g_ifdata_tran-s1-ifcid 'Ändern'.
    WHEN c_new__tcod.
      SET TITLEBAR g_pf_title WITH g_ifdata_tran-s1-ifcid 'Anlegen'.
    WHEN c_accp_tcod.
      SET TITLEBAR g_pf_title WITH g_ifdata_tran-s1-ifcid 'Abnehmen'.
    WHEN c_rele_tcod.
      SET TITLEBAR g_pf_title
             WITH g_ifdata_tran-s1-ifcid 'Freigabe zum Test'.
    WHEN c_rmod_tcod.
      SET TITLEBAR g_pf_title WITH g_ifdata_tran-s1-ifcid 'Ändern'.
    WHEN c_adhoc_tcod.
      SET TITLEBAR g_pf_title WITH g_ifdata_tran-s1-ifcid 'Ausführen'.
    WHEN OTHERS.
      SET TITLEBAR g_pf_title WITH g_ifdata_tran-s1-ifcid 'Anzeigen'.
  ENDCASE.

ENDMODULE.                 " SET_STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       Im Anzeigemodus werden spezielle Felder als Nichteingabe-
*       bereit angezeigt.
*---------------------------------------------------------------------*
MODULE modify_screen OUTPUT.

*SIE003_BEG
*  DATA: l_d1 TYPE d.
*
*  CASE sy-tcode.
*    WHEN c_disp_tcod OR c_rele_tcod OR c_accp_tcod.
*      LOOP AT SCREEN.
*       IF screen-group1 = '001'.
*         screen-input = '0'.
*         MODIFY SCREEN.
*       ENDIF.
*      ENDLOOP.
*    WHEN  c_modi_tcod OR c_new__tcod.
*      CALL FUNCTION '/SIE/HR_IDP_RELE_DATE'
*           EXPORTING
*                vrsnr        = g_ifdata_vers
*                s1f          = g_ifdata_tran-s1f
*           IMPORTING
*                release_date = l_d1.
*      IF NOT ( l_d1 IS INITIAL ).
** Umschalten zwischen Anzeigen und Ändern
*        LOOP AT SCREEN.
*          IF screen-group1 = '001'.
*            screen-input = '0'.
*            MODIFY SCREEN.
*          ENDIF.
*        ENDLOOP.
*      ELSE.
**     do nothing
*      ENDIF.
*    WHEN c_rmod_tcod.
** Alles änderbar machen
*    WHEN OTHERS.
*      LOOP AT SCREEN.
*        IF screen-group1 = '001'.
*          screen-input = '0'.
*          MODIFY SCREEN.
*        ENDIF.
*      ENDLOOP.
*  ENDCASE.

   PERFORM modify_screen.
*SIE003_END

ENDMODULE.                 " MODIFY_SCREEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_ENQUEUE  OUTPUT
*&---------------------------------------------------------------------*
*       Entsperrt die alte Schnittstelle
*----------------------------------------------------------------------*
MODULE set_dequeue OUTPUT.
*  if g_ifdata_oldv ne g_ifdata_tran-s1-ifcid.
*    perform dequeue.
*  endif.
ENDMODULE.                 " SET_ENQUEUE  OUTPUT

*---------------------------------------------------------------------*
*       MODULE HIDE_KEYS                                              *
*---------------------------------------------------------------------*
*       Dieses Form wird bei Detailbilder benutzt, um die Anzeigbar-  *
*       keit von Schlüsselfelder zu ändern. Z.B. soll auf den Detail  *
*       Bilder der Name der Schnittstelle nicht geändert werden.      *
*---------------------------------------------------------------------*

DEFINE hide_fields.
  loop at screen.
    if screen-group2 = &1.
      screen-input = space.
      screen-required = space.
      modify screen.
    endif.
  endloop.
END-OF-DEFINITION.

*---------------------------------------------------------------------*
*       MODULE HIDE_KEYS OUTPUT                                       *
*---------------------------------------------------------------------*
*       Es werden hier die Felder der Schnittstelle ausgeblendet wie  *
*       Name und Beschreibung.                                        *
*---------------------------------------------------------------------*
MODULE hide_keys OUTPUT.
* Umschalten auf nicht anzeigbar bei speziellen Felder, unabhängig
* von der Transaktion (Schlüsselfelder)
  CASE g_status_tran.
    WHEN c_1000_stat.
      hide_fields: '002'.

* Versionsfeld nicht anzeigen.
      LOOP AT SCREEN.
        CHECK screen-group3 = '001'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDLOOP.

    WHEN c_1001_stat.
      IF g_ifcid_new = yes OR sy-tcode = '/SIE/HR_IDP_IFC_NEW'.
        g_ifcid_new = yes.
* Bei einer neuen Schnittstelle soll der Name der Schnittstelle
* änderbar sein. Dasselbe gilt für das Text.
        LOOP AT SCREEN.
          IF screen-group2 = '001' OR screen-group2 = '002'.
            screen-input = '1'.
            screen-required = '1'.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ELSE.
        hide_fields: '001'
                   , '002'
                   .
      ENDIF.
    WHEN c_1002_stat OR c_1003_stat.
      hide_fields: '001'
                 , '002'
                 .
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  INIT_OKCODES  OUTPUT
*&---------------------------------------------------------------------*
*       Initialisiert die Ok_codes
*----------------------------------------------------------------------*
MODULE init_okcodes OUTPUT.
  CLEAR: okcode, svcode.
ENDMODULE.                 " INIT_OKCODES  OUTPUT
