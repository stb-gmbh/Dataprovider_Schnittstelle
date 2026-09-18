*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_O11                                        *
*----------------------------------------------------------------------*

DATA: idx_count TYPE i.

*&---------------------------------------------------------------------*
*&      Module  READ_1001  OUTPUT
*&---------------------------------------------------------------------*
*       Füllen der Dynpro-strukturen
*----------------------------------------------------------------------*
MODULE read_1001 OUTPUT.
  CLEAR /sie/hr_idp_s1.
  MOVE-CORRESPONDING g_ifdata_tran-s1 TO /sie/hr_idp_s1.
ENDMODULE.                 " READ_1001  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SET_DEFAULTS  OUTPUT
*&---------------------------------------------------------------------*
*       Handelt es sich um eine Neue Schnittstelle, so werden
*       einige Felder mit Defaults ausgestattet.
*----------------------------------------------------------------------*
DATA: h_data TYPE /sie/hr_idp_ifc_db.

*---------------------------------------------------------------------*
*       MODULE SET_DEFAULTS OUTPUT                                    *
*---------------------------------------------------------------------*
*       Setzt defaults beim neu anlegen                               *
*---------------------------------------------------------------------*
MODULE set_defaults OUTPUT.

* Ist der Flag für Neue Schnittstellen gesetzt?
  IF sy-tcode = c_new__tcod.

    g_proc_vec-s1 = yes.
    g_proc_vec-s1t = yes.
    g_proc_vec-s1vt = yes.
    g_proc_vec-s1f = yes.
*   g_proc_vec-s1df = yes.
    g_ifdata_vers = '0001'.

* Beginn Datum Vorschlagen (Heutiger Tag)
    IF g_ifdata_tran-s1-valid_from IS INITIAL.
      g_ifdata_tran-s1-valid_from = sy-datum.
    ELSE.
* Dürfte nie der Fall sein.
    ENDIF.

* Ende Datum Vorschlagen (Letzter Tag im Jahr)
    IF g_ifdata_tran-s1-valid_to IS INITIAL.
      g_ifdata_tran-s1-valid_to = sy-datum.
      IF g_ifdata_tran-s1-valid_to+4(4) > '0930'.           "#EC NOTEXT
         g_ifdata_tran-s1-valid_to(4) = sy-datum(4) + 1.
      ENDIF.
      g_ifdata_tran-s1-valid_to+4(4) = '0930'.              "#EC NOTEXT
    ENDIF.

*<xft 18.12.2001>
*    g_ifdata_tran-s1-act_vers_nr = '0001'.
*<xft 18.12.2001>

    g_ifdata_tran-s1-new_version = yes.

* Wenn im System nur eine einzige Berechtigungsklasse existiert,
* dann diese nehmen!
    SELECT COUNT( * ) FROM /sie/hr_idp_s0 INTO idx_count.
    IF idx_count = 1.
      SELECT SINGLE * FROM /sie/hr_idp_s0. "#EC WARNOK
" 15.02.2023 M.Krzywda ATC findings C2C correction
      g_ifdata_tran-s1-auth_class = /sie/hr_idp_s0-auth_class.
    ENDIF.

* S1f Füllen.
    PERFORM init_s1f.
  ELSE.
    IF g_ifdata_tran-s1t-ident IS INITIAL.
      g_ifdata_tran-s1t-ident = g_ifdata_tran-s1t-ident.
    ENDIF.

* Annahme, daß 90% der Schnittstellen generiert werden
*    g_ifdata_tran-s1df-gnrtd = 'X'.


  ENDIF.

ENDMODULE.                 " SET_DEFAULTS  OUTPUT
