FUNCTION /SIE/HR_IDP_CHECK_REFERENCE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IFCID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"  EXPORTING
*"     VALUE(IFC_COUNT) TYPE  I
*"     VALUE(OUTTAB) TYPE  /SIE/HR_IDP_TT_SEARCH
*"----------------------------------------------------------------------
   data: ta_ifc    type /SIE/HR_IDP_TT_SEARCH with header line,
         rel_vrsnr type /SIE/HR_IDP_VERS_NR.

   select ifcid vrsnr from /SIE/HR_IDP_S1DL
                      into corresponding fields of table ta_ifc
                      where REFERENZ = ifcid
                      ORDER BY PRIMARY KEY.

   sort ta_ifc.
   loop at ta_ifc.

      at new ifcid.
*       Aktuelle aktive Version der Referenzschnittstelle ermitteln
        CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
           EXPORTING
             interface               = ta_ifc-ifcid
             active                  = 'X'
           IMPORTING
             version                 = rel_vrsnr
           EXCEPTIONS
              no_active_version       = 1
              OTHERS                  = 2
             .

        IF sy-subrc <> 0.
*          letzte Version nehmen
           CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
              EXPORTING
                interface               = ta_ifc-ifcid
                active                  = ' '
              IMPORTING
                version                 = rel_vrsnr
              EXCEPTIONS
                no_active_version       = 1
                OTHERS                  = 2
                .
        endif.
      endat.

*     Nicht mehr aktive Versionen entfernen
      check ta_ifc-vrsnr < rel_vrsnr.
      delete ta_ifc.

   endloop.

*  Ergebnis zurückgeben
   describe table ta_ifc lines IFC_COUNT.
   outtab[] = ta_ifc[].

ENDFUNCTION.
