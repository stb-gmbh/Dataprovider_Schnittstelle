*----------------------------------------------------------------------*
*   INCLUDE /SIE/HR_IDP_IFC_ALERT_MAIN                                 *
*----------------------------------------------------------------------*
* SIE001: Fehlender Schnittstellenname & Empfänger in "AN" & "CC"
*         erhalten Mail evtl unter "CC"

INITIALIZATION.
  PERFORM init_selection.

END-OF-SELECTION.

  IF p_only = space.
    CLEAR: gt_interfaces[].
    CALL FUNCTION '/SIE/HR_IDP_READ_VALIDITY_DATE'
         EXPORTING
              interval       = val_intv
         TABLES
              tab_interfaces = gt_interfaces
         CHANGING
              date_from      = val_date.

  ELSE.
* Alternative Selektion über Schnittstellen, die per Select option
* übermittelt werden. Wird bei externen Submits benutzt für
* Allgemeine Korrespondenz.
    CLEAR: gt_interfaces[].

    SELECT * FROM /sie/hr_idp_vs1t
             INTO TABLE g_vs1t
             WHERE ifcid IN so_ifcid
             AND   spras = sy-langu.

    LOOP AT g_vs1t INTO wa_s1vt.
      CLEAR gt_interfaces.
      MOVE-CORRESPONDING wa_s1vt TO gt_interfaces.
      CHECK NOT ( gt_interfaces-act_vers_nr IS INITIAL ).
      gt_interfaces-vrsnr = wa_s1vt-act_vers_nr.
      APPEND gt_interfaces.
    ENDLOOP.

  ENDIF.


  SORT gt_interfaces. "21Hana

  DELETE ADJACENT DUPLICATES FROM gt_interfaces.

  LOOP AT gt_interfaces WHERE ifcid IN so_ifcid.

    CLEAR  /sie/hr_idp_ifc_validity_mail.

    MOVE-CORRESPONDING gt_interfaces TO /sie/hr_idp_ifc_validity_mail.

    SELECT SINGLE * FROM /sie/hr_idp_s1
                    WHERE ifcid = gt_interfaces-ifcid.
    IF sy-subrc = 0.
      MOVE /sie/hr_idp_s1-customer
           TO /sie/hr_idp_ifc_validity_mail-customer.
    ENDIF.

    SELECT SINGLE * FROM /sie/hr_idp_s1t
                    WHERE ifcid = gt_interfaces-ifcid
                    AND   spras = sy-langu.
    IF sy-subrc = 0.
      MOVE /sie/hr_idp_s1t-ident TO /sie/hr_idp_ifc_validity_mail-ident.
    ELSE.
      CLEAR /sie/hr_idp_ifc_validity_mail-ident.
    ENDIF.

    SELECT SINGLE * FROM /sie/hr_idp_s1pc
                    WHERE ifcid = gt_interfaces-ifcid
                    AND   vrsnr = gt_interfaces-vrsnr.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING /sie/hr_idp_s1pc
                      TO /sie/hr_idp_ifc_validity_mail.
    ELSE.
*      CLEAR /SIE/HR_IDP_IFC_VALIDITY_MAIL-IDENT. "SIE001
    ENDIF.

    SELECT * FROM /sie/hr_idp_s1vt INTO TABLE selections
                                   WHERE ifcid = gt_interfaces-ifcid
                                   AND   vrsnr =   gt_interfaces-vrsnr.

    PERFORM create_content TABLES contents.
    PERFORM create_receiver_list TABLES receivers.

    receivers_h[] = receivers[].

    IF p_email = 'X'.
      CHECK NOT ( receivers[] IS INITIAL ).
*SIE001_BEG
      DATA h_tabix LIKE sy-tabix.

      SORT receivers BY copy.
      LOOP AT receivers.
         h_tabix = sy-tabix + 1.
         DELETE receivers FROM h_tabix
                          WHERE receiver = receivers-receiver.
      ENDLOOP.
*     DELETE ADJACENT DUPLICATES FROM RECEIVERS[].*
*SIE001_END
      PERFORM notify_user TABLES contents
                                 receivers
                          USING cc.
    ENDIF.

    IF p_screen = 'X'.
      PERFORM write_log TABLES contents
                               receivers_h.
    ENDIF.

  ENDLOOP.
  IF sy-subrc >< 0.
    MESSAGE s167.
  ENDIF.
