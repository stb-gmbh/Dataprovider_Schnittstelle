*----------------------------------------------------------------------*
***INCLUDE /SIE/HR_IDP_MONITOR_GD_F01 .
*----------------------------------------------------------------------*

*sie001 bei Verlängerung der Schnittstelle um Monate wird nicht auf den
*sie001 gleichen Tag verlängert sondern jeweils auf den Monats-Ultimo
*sie001 Hn, 18.06.2004



 DEFINE icon_line.
   if &4 = 0.
     format intensified off.
   else.
     format intensified on.
   endif.
   write: / '|', &1 as icon,   7(59) &2 color &3 , 60 '|'.
 END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  GET_CURRENT_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM get_current_line.

   DATA: cursor_line TYPE i
       , idx TYPE i
       , lines TYPE STANDARD TABLE OF popuptext INITIAL SIZE 0
         WITH HEADER LINE
       ,  fl_change_all TYPE xfeld
       .

   DATA: answer TYPE c.

   DATA: h_ultimo TYPE /sie/hr_idp_s1-valid_to.             "sie001

   GET CURSOR LINE cursor_line.
   idx = ctrl_validity-top_line + cursor_line - 1.
   READ TABLE gt_interfaces INDEX idx.

   PERFORM fill_lines TABLES lines.

   CALL FUNCTION '/SIE/HR_IDP_IFC_POPUP_TEXT'
        EXPORTING
             titel  = 'Gültigkeit verlängern'
        IMPORTING
             answer = answer
        TABLES
             lines  = lines.

   CASE answer.
     WHEN 'Y'.                                              "#EC NOTEXT
       SELECT SINGLE * FROM /sie/hr_idp_s1
              WHERE ifcid = gt_interfaces-ifcid.
       CALL FUNCTION '/SIE/HR_IDP_AUTH_CHECK'
            EXPORTING
                 activity     = '92'
                 if_class     = /sie/hr_idp_s1-auth_class
                 object       = gt_interfaces-ifcid
                 subobject    = 'HEAD'
            EXCEPTIONS
                 no_authority = 1
                 OTHERS       = 2.
       .
       IF sy-subrc <> 0.
         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
       ELSE.

         SELECT SINGLE * FROM /sie/hr_idp_s1
                WHERE ifcid = gt_interfaces-ifcid.
         IF sy-subrc = 0.
*          /sie/hr_idp_monitor_head-ext_interval = 3.
           IF /sie/hr_idp_monitor_head-ext_interval >< 0.
             PERFORM day_plus_months(sapfp500)
                     USING /sie/hr_idp_s1-valid_to
                           /sie/hr_idp_monitor_head-ext_interval
                           /sie/hr_idp_s1-valid_to.


*sie001 /sie/hr_idp_s1-valid_to wird mit dem Monatsultimo
*sie001 des schon belegten Datums überschrieben
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'                      "sie001 Beginn
       EXPORTING
           day_in = /sie/hr_idp_s1-valid_to
       IMPORTING
           last_day_of_month = h_ultimo
*      EXCEPTIONS
*          DAY_IN_NO_DATE          = 1
*          OTHERS                  = 2
                             .
             IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
             ENDIF.

             /sie/hr_idp_s1-valid_to = h_ultimo.          "sie001 Ende



             fill_adm_info /sie/hr_idp_s1.
             MODIFY /sie/hr_idp_s1.

             IF /sie/hr_idp_monitor_head-ext_uc4 = 'X'.

               SELECT SINGLE * FROM /sie/hr_idp_s1df
                              WHERE ifcid = gt_interfaces-ifcid
                              AND   vrsnr = gt_interfaces-vrsnr.
               fill_adm_info /sie/hr_idp_s1df.
               /sie/hr_idp_s1df-uc4to = /sie/hr_idp_s1-valid_to.
               MODIFY /sie/hr_idp_s1df.
* Bei modifizierten SSt. auch die neueste Verlängern!
               IF /sie/hr_idp_s1-new_version = 'X'.         "#EC NOTEXT

                 CLEAR: answer
                      , lines[]
                      .

     lines-text = 'Diese Schnittstelle wird momentan mit einer höheren'.
                 APPEND lines.

  lines-text = 'Version bearbeitet. Möchten Sie, daß die UC4 Parameter'.
                 APPEND lines.

                 lines-text = 'dieser Version auch verlängert werden?'.
                 APPEND lines.

                 CALL FUNCTION '/SIE/HR_IDP_IFC_POPUP_TEXT'
                      EXPORTING
                           titel  = 'Eine neue Version existiert.'
                      IMPORTING
                           answer = answer
                      TABLES
                           lines  = lines.
                 IF answer = 'Y'.
                   gt_interfaces-vrsnr = gt_interfaces-vrsnr + 1.
                   SELECT SINGLE * FROM /sie/hr_idp_s1df
                                  WHERE ifcid = gt_interfaces-ifcid
                                  AND   vrsnr = gt_interfaces-vrsnr.
                   fill_adm_info /sie/hr_idp_s1df.
                   /sie/hr_idp_s1df-uc4to = /sie/hr_idp_s1-valid_to.
                   MODIFY /sie/hr_idp_s1df.
                   gt_interfaces-vrsnr = gt_interfaces-vrsnr - 1.
                 ENDIF.
               ENDIF.

             ELSE.
               MESSAGE s250.
             ENDIF.
             MESSAGE s251.
             CALL SCREEN 5200 STARTING AT 30 5.
           ENDIF.
         ELSE.
           MESSAGE s250.
         ENDIF.
       ENDIF.
     WHEN 'N'.
       MESSAGE s250.
   ENDCASE.

 ENDFORM.                    " GET_CURRENT_LINE

*&---------------------------------------------------------------------*
*&      Form  SHOW_LEGEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM show_legend.

   NEW-PAGE NO-TITLE LINE-SIZE 60.

   WRITE: /
 'Folgende Farben kennzeichnen den Status einer Schnittstelle'(c00).

   SKIP.

   ULINE.
   icon_line icon_red_light
        'Die Version muß noch freigegeben werden'(c01) 6 1.

   icon_line icon_yellow_light
        'Die Version ist (noch) nicht abgenommen worden'(c02) 3 1.

   icon_line icon_green_light
        'Die Version ist freigegeben und abgenommen'(c03) 5 1.

   icon_line space
        ' Historische Version'(c04) col_normal 1.
   ULINE.

 ENDFORM.                    " SHOW_LEGEND

*&---------------------------------------------------------------------*
*&      Form  SCROLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM scroll USING p_svcode LIKE sy-ucomm.

   DATA: l_display LIKE sy-tabix.
   FIELD-SYMBOLS: <c> TYPE cxtab_control.

   ASSIGN ctrl_validity TO <c>.

   CALL FUNCTION 'SCROLLING_IN_TABLE'
        EXPORTING
             ok_code     = p_svcode
             entry_act   = <c>-top_line
             entry_to    = <c>-lines
             loops       = step_lines
             overlapping = 'X'
        IMPORTING
             entry_new   = <c>-top_line
        EXCEPTIONS
             OTHERS      = 1.
   IF sy-subrc <> 0.
   ENDIF.

 ENDFORM.                    " SCROLL

*&---------------------------------------------------------------------*
*&      Form  FILL_LINES
*&---------------------------------------------------------------------*
*       Initialisert den Text zur ABfrage ob die Schnittstellengültig-
*       keit verlängert werden soll.
*----------------------------------------------------------------------*
 FORM fill_lines TABLES p_lines STRUCTURE popuptext.

   CLEAR p_lines[].

   p_lines-text
         = 'Durch drücken der OK Taste wird die Gültigkeit der '(001).
   APPEND p_lines.

   p_lines-text = 'Schnittstelle verlängert.'(002).
   APPEND p_lines.

   p_lines-text = ''.
   APPEND p_lines.

   p_lines-text
     = 'Diese Vorgehensweise darf nur angewendet werden, wenn (a)'(003).
   APPEND p_lines.

   p_lines-text =
            'eine Rückmeldung durch den Anwender vorliegt und (b)'(004).
   APPEND p_lines.

   p_lines-text =
       'keine weiteren Parameter (wie z.B. Kontierungsmerkmale)'(005).
   APPEND p_lines.

   p_lines-text = 'sich ändern'(006).
   APPEND p_lines.
 ENDFORM.                    " FILL_LINES
