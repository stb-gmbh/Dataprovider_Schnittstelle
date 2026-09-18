FUNCTION /sie/hr_idp_refresh_reference.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  CHANGING
*"     VALUE(TRANSACTION_DATA) TYPE  /SIE/HR_IDP_IFC_DB
*"  EXCEPTIONS
*"      NO_ACTIVE_VERSION
*"----------------------------------------------------------------------

   DATA: ref_ifcid TYPE /sie/hr_idp_interface_id,
         ref_vrsnr TYPE /sie/hr_idp_vers_nr,
         ref_trans TYPE /sie/hr_idp_ifc_db.

   DATA: l_dbsel   TYPE /sie/hr_idp_db_sel.

   DATA: BEGIN OF ifc_key,
            mandt TYPE mandt,
            ifcid TYPE /sie/hr_idp_interface_id,
            vrsnr TYPE /sie/hr_idp_vers_nr,
         END OF ifc_key.

   FIELD-SYMBOLS: <ref_s1pg> LIKE LINE OF ref_trans-s1pg,
                  <ref_s1ps> LIKE LINE OF ref_trans-s1ps,
                  <ref_s1sa> LIKE LINE OF ref_trans-s1sa.


* Referenzschnittstelle ermitteln
   ref_ifcid = transaction_data-s1dl-referenz.
   check not ref_ifcid IS INITIAL.

* Aktuelle aktive Version der Referenzschnittstelle ermitteln
   CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
     EXPORTING
       interface               = ref_ifcid
       active                  = 'X'
     IMPORTING
       version                 = ref_vrsnr
     EXCEPTIONS
       no_active_version       = 1
       OTHERS                  = 2
             .
   IF sy-subrc <> 0.

      RAISE no_active_version.

   ENDIF.

* Benötigte Tabellen markieren und importieren

   l_dbsel-s1pg = 'X'. "Felder
   l_dbsel-s1ps = 'X'. "Filter
   l_dbsel-s1sa = 'X'. "Satzarten
   l_dbsel-s1dl = 'X'. "Delimiter
   l_dbsel-s1df = 'X'. "Deltakennzeichen

   CALL FUNCTION '/SIE/HR_IDP_DB_READ'
     EXPORTING
       interface              = ref_ifcid
       version                = ref_vrsnr

     CHANGING
       transaction_data       = ref_trans
       dbsel                  = l_dbsel.
             .

* Schlüsselfelder auf neue Schnittstelle umbiegen
   MOVE-CORRESPONDING transaction_data-s1dl TO ifc_key.

   LOOP AT ref_trans-s1pg ASSIGNING <ref_s1pg>.
      MOVE-CORRESPONDING ifc_key TO <ref_s1pg>.
   ENDLOOP.
   LOOP AT ref_trans-s1ps ASSIGNING <ref_s1ps>.
      MOVE-CORRESPONDING ifc_key TO <ref_s1ps>.
   ENDLOOP.
   LOOP AT ref_trans-s1sa ASSIGNING <ref_s1sa>.
      MOVE-CORRESPONDING ifc_key TO <ref_s1sa>.
   ENDLOOP.

* Entsprechende Daten zurückgeben
   transaction_data-s1pg[] = ref_trans-s1pg[].
   transaction_data-s1ps[] = ref_trans-s1ps[].
   transaction_data-s1sa[] = ref_trans-s1sa[].

   transaction_data-s1dl-fixfm = ref_trans-s1dl-fixfm.
   transaction_data-s1dl-delim = ref_trans-s1dl-delim.
   transaction_data-s1df-delta = ref_trans-s1df-delta.

ENDFUNCTION.
