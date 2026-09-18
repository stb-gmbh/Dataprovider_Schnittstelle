*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_IFC_ALERT_F02 .
*----------------------------------------------------------------------*
* 20141104|ML  | Unicode-Umstellung (INC5560081)                ML001  *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CREATE_RECEIVER_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_receiver_list TABLES receivers STRUCTURE somlreci1.

  DATA: BEGIN OF role
     ,    role(1)
     ,    to(1)
     ,    cc(1)
     ,  END OF role.

  CLEAR receivers[].

  /sie/hr_idp_roles-r01 = p_01.
  /sie/hr_idp_roles-r01_to = r_01_to.
  /sie/hr_idp_roles-r01_cc = r_01_cc.

  /sie/hr_idp_roles-r02 = p_02.
  /sie/hr_idp_roles-r02_to = r_02_to.
  /sie/hr_idp_roles-r02_cc = r_02_cc.

  /sie/hr_idp_roles-r03 = p_03.
  /sie/hr_idp_roles-r03_to = r_03_to.
  /sie/hr_idp_roles-r03_cc = r_03_cc.

  /sie/hr_idp_roles-r04 = p_04.
  /sie/hr_idp_roles-r04_to = r_04_to.
  /sie/hr_idp_roles-r04_cc = r_04_cc.

  /sie/hr_idp_roles-r05 = p_05.
  /sie/hr_idp_roles-r05_to = r_05_to.
  /sie/hr_idp_roles-r05_cc = r_05_cc.

  /sie/hr_idp_roles-r06 = p_06.
  /sie/hr_idp_roles-r06_to = r_06_to.
  /sie/hr_idp_roles-r06_cc = r_06_cc.

  /sie/hr_idp_roles-r07 = p_07.
  /sie/hr_idp_roles-r07_to = r_07_to.
  /sie/hr_idp_roles-r07_cc = r_07_cc.


  DO 7 TIMES VARYING role-role FROM /sie/hr_idp_roles-r01        "ML001
*  DO 7 TIMES VARYING role FROM /sie/hr_idp_roles-r01
                          NEXT /sie/hr_idp_roles-r02.
    IF role-role = 'X'.                                     "#EC NOTEXT
      SELECT SINGLE * FROM /sie/hr_idp_s1r
                      WHERE ifcid = gt_interfaces-ifcid
                      AND   vrsnr = gt_interfaces-vrsnr
                      AND   trole = sy-index.
      IF sy-subrc = 0.
        CHECK NOT ( /sie/hr_idp_s1r-email IS INITIAL ).
        CLEAR receivers.                                   "SIE001
        receivers-receiver = /sie/hr_idp_s1r-email.
        receivers-rec_type = 'U'.                           "#EC NOTEXT
        receivers-express  = 'X'.                           "#EC NOTEXT
        IF role-to = 'X'.                                   "#EC NOTEXT
*         do nothing, default is to send
        ELSE.
          receivers-copy = 'X'.                             "#EC NOTEXT
        ENDIF.

        APPEND receivers.
      ENDIF.
    ENDIF.
  ENDDO.

* Zusätzlicher Adressat
  IF NOT cc IS INITIAL.
    CLEAR receivers_h[].
    SPLIT cc AT ';' INTO TABLE receivers_h.                 "#EC NOTEXT
    LOOP AT receivers_h.
      CLEAR receivers.                                     "SIE001
      receivers-receiver = receivers_h.
      receivers-rec_type = 'U'.                           "#EC NOTEXT
      receivers-express  = 'X'.
      receivers-copy = 'X'.                                 "#EC NOTEXT
      APPEND receivers.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " CREATE_RECEIVER_LIST
