*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_O12                                        *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE READ_1002  OUTPUT                           "SIE004    *
*---------------------------------------------------------------------*
*       Füllen der sonstigen Felder auf Dynpro                        *
*---------------------------------------------------------------------*
MODULE READ_1002 OUTPUT.

   move-corresponding g_ifdata_tran-s1df to /SIE/HR_IDP_S1DF.

*   /sie/hr_idp_s1df-gsel_mini1 = 'X'.                      "SIE007 ah001

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  FILL_VARDATA  OUTPUT
*&---------------------------------------------------------------------*
*       Fuellen der internen Tabelle g_vardata, mit der der TC
*       tc_var gefuellt wird
*----------------------------------------------------------------------*
MODULE FILL_VARDATA OUTPUT.
  DATA OLD_FELDNAME TYPE /SIE/HR_IDP_S1VT-FELDNAME.
  CLEAR: G_VARDATA
       , G_VARDATA[]
       , WA_TRAN_S1VT
       , CONTENT
       .
* Derselbe Feldname kommt in g_ifdata_tran-s1vt mehrfach vor, wenn zu
* einem Selektionsfeld mehrere Select-Options gehören. Im TC wird das
* Feld nur einmal ausgegeben.
  OLD_FELDNAME = 'INIT'.
  LOOP AT G_IFDATA_TRAN-S1VT INTO WA_TRAN_S1VT.
    IF NOT WA_TRAN_S1VT-FELDNAME IS INITIAL.
      CHECK OLD_FELDNAME NE WA_TRAN_S1VT-FELDNAME.
      OLD_FELDNAME = WA_TRAN_S1VT-FELDNAME.
      G_VARDATA-FELDNAME = WA_TRAN_S1VT-FELDNAME.
      PERFORM GET_IDENT USING    WA_TRAN_S1VT-FELDNAME
                        CHANGING G_VARDATA-IDENT.
      IF WA_TRAN_S1VT-SSIGN IS INITIAL.
        G_VARDATA-ICON = ICON_ENTER_MORE.
      ELSE.
        G_VARDATA-ICON = ICON_DISPLAY_MORE.
      ENDIF.
    ENDIF.
    APPEND G_VARDATA.
  ENDLOOP.
  SORT G_VARDATA BY FELDNAME.
*  do 15 times.
*    append initial line to g_vardata.
*  enddo.
* Scrollen
  DESCRIBE TABLE G_VARDATA LINES COUNT.
  TAB_LINES = COUNT.
  TC_VAR-LINES = COUNT.
*  REFRESH CONTROL 'TC_VAR' FROM SCREEN '0300'.
* Cursor in erstes eingabebereites Feld setzen
  SET_CURSOR = 'X'.
ENDMODULE.                 " FILL_VARDATA  OUTPUT

*---------------------------------------------------------------------*
*       MODULE MODIFY_TC  OUTPUT                                      *
*---------------------------------------------------------------------*
*       Ändern der Eingabebereitschaft der TC_Felder                  *
*---------------------------------------------------------------------*
MODULE MODIFY_TC OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 EQ '001'.
* Bei einer Leerzeile muß der Feldname eingabebereit sein, wenn die
* Schnittstelle noch nicht freigegeben wurde
      READ TABLE G_IFDATA_TRAN-S1F INTO WA_S1F WITH KEY TROLE = '06'.
      IF /SIE/HR_IDP_VARDATA-FELDNAME IS INITIAL
*        and g_ifdata_tran-s1vn-release_date is initial.
AND WA_S1F-CH_DATUM IS INITIAL.
        SCREEN-INPUT = '1'.
        IF SET_CURSOR EQ 'X'.
          SET CURSOR 1 TC_VAR-CURRENT_LINE.
          SET_CURSOR = SPACE.
        ENDIF.
      ELSE.
        SCREEN-INPUT = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
