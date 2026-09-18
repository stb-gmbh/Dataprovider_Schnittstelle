*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_F750 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_reference_data
*&---------------------------------------------------------------------*
FORM get_reference_data.

*   STATICS: old_ifcid LIKE /sie/hr_idp_s1dl-referenz.
*
*   IF old_ifcid <> /sie/hr_idp_s1dl-referenz
*      OR ( NOT /sie/hr_idp_s1dl-referenz IS INITIAL
*           AND /sie/hr_idp_head-ident IS INITIAL ).

      CLEAR /sie/hr_idp_head.

*     Initialwert zulassen, entspricht keiner Referenz
      IF NOT /sie/hr_idp_s1dl-referenz IS INITIAL.
*        Text, letzte freigegebene Version und Ampelicon füllen
         SELECT SINGLE ident FROM /sie/hr_idp_s1t
                             INTO /sie/hr_idp_head-ident
                             WHERE spras = sy-langu
                               AND ifcid = /sie/hr_idp_s1dl-referenz.

         CALL FUNCTION '/SIE/HR_IDP_IFC_CURR_VERSION'
           EXPORTING
             interface               = /sie/hr_idp_s1dl-referenz
             active                  = 'X'
           IMPORTING
             version                 = /sie/hr_idp_head-vrsnr
           EXCEPTIONS
             no_active_version       = 1
             OTHERS                  = 2
                   .
         IF sy-subrc = 0.

           CALL FUNCTION '/SIE/HR_IDP_VERSION_INFO'
              EXPORTING
                 interface_id = /sie/hr_idp_s1dl-referenz
                 version      = /sie/hr_idp_head-vrsnr
              IMPORTING
                 rc_icon      = /sie/hr_idp_head-icon.

         ELSE.

            /sie/hr_idp_head-icon = icon_red_light.
            CLEAR /sie/hr_idp_head-vrsnr.

         ENDIF.
      ENDIF.

*      old_ifcid = /sie/hr_idp_s1dl-referenz.
*   ENDIF.

ENDFORM.                    " get_reference_data
