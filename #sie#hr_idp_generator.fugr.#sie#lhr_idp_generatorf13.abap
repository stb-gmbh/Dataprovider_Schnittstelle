*----------------------------------------------------------------------*
*   INCLUDE /SIE/LHR_IDP_GENERATORF13                                  *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PROCESS_SATZART_KTO
*&---------------------------------------------------------------------*
*       Lohnkontofelder: Generierung des Codes zum einlesen
*----------------------------------------------------------------------*
*      -->P_RECNA  Satzart
*----------------------------------------------------------------------*
FORM PROCESS_SATZART_KTO USING P_RECNA TYPE /SIE/HR_IDP_RECORD_NAME
                               P_SNAME.
  DATA: FIELDS LIKE LINE OF IT_FELDER
      , FIELD_NAME(60) TYPE C.

  LOOP AT IT_FELDER INTO FIELDS WHERE RECNA = P_RECNA
                                  AND DPFTYPE = '3'.

    CONCATENATE 'ITAB_' P_SNAME '-' FIELDS-SELNAME INTO FIELD_NAME.

    PERFORM PROCESS_KTO USING FIELDS-ACL_TABTYP
                              FIELDS-ACLTAB
                              FIELDS-ACL_LENGTH
                              FIELDS-ACL_OFFSET
                              FIELDS-ACL_FLDTYP
                              FIELD_NAME.

  ENDLOOP.

ENDFORM.                    " PROCESS_SATZART_KTO

*---------------------------------------------------------------------*
*       FORM PROCESS_KTO                                              *
*---------------------------------------------------------------------*
*       Generierung des Codes für Lohnarten                           *
*---------------------------------------------------------------------*
*  -->  P_RTKZ          Feld des Lohnartenobjektes                    *
*  -->  P_LGART         Lohnart                                       *
*  -->  P_MTHBK         Monate in der Vergangenheit                   *
*  -->  P_AGGREGATE     Aggregatfunktion                              *
*---------------------------------------------------------------------*
FORM PROCESS_KTO USING VALUE(P_TABTYP) TYPE C
                       VALUE(P_ACLTAB) TYPE FIELDNAME
                       VALUE(P_ACL_LENGTH)
                       VALUE(P_ACL_OFFSET)
                       VALUE(P_ACL_FLDTYP) TYPE C
                       VALUE(P_FELD).
  DATA:
    TAG       TYPE /SIE/HR_IDP_TT_CODING,
    INPUT     TYPE /SIE/HR_IDP_TT_CODING,
    RESULT    TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'read_kto' CHANGING TAG.
  PERFORM REPLACE_PARAM USING 'TABTYP' P_TABTYP TAG
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].

  PERFORM REPLACE_PARAM USING 'ACLTAB' P_ACLTAB INPUT
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'ACL_LENGTH' P_ACL_LENGTH INPUT
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'ACL_OFFSET' P_ACL_OFFSET INPUT
                      CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'ACL_FLDTYP' P_ACL_FLDTYP INPUT
                      CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].

  PERFORM REPLACE_PARAM USING 'FELD' P_FELD INPUT
                      CHANGING RESULT.

  PERFORM INSERT_CODE USING RESULT.

*$<read_kto>
*$ perform get_kto using '&TABTYP'
*$                       '&ACLTAB'
*$                       '&ACL_LENGTH'
*$                       '&ACL_OFFSET'
*$                       '&ACL_FLDTYP'
*$              changing &FELD.
*$</read_kto>

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PROCESS_SATZART_LGART
*&---------------------------------------------------------------------*
*       Lohnarten
*----------------------------------------------------------------------*
*      -->P_RECNA  Satzart
*----------------------------------------------------------------------*
FORM PROCESS_SATZART_LGART USING P_RECNA TYPE /SIE/HR_IDP_RECORD_NAME
                                 P_SNAME.
  DATA: FIELDS LIKE LINE OF IT_FELDER
      , FIELD_NAME(60) TYPE C.

  LOOP AT IT_FELDER INTO FIELDS WHERE RECNA = P_RECNA
                                  AND DPFTYPE = '4'.

    CONCATENATE 'ITAB_' P_SNAME '-' FIELDS-SELNAME INTO FIELD_NAME.

    PERFORM PROCESS_RT USING FIELDS-RTKZ
                             FIELDS-LGART
                             FIELDS-MTHBK
                             FIELDS-AGGREGATE
                             FIELD_NAME.

  ENDLOOP.

ENDFORM.                    " PROCESS_SATZART_LGART

*---------------------------------------------------------------------*
*       FORM PROCESS_RT                                               *
*---------------------------------------------------------------------*
*       Generierung des Codes für Lohnarten                           *
*---------------------------------------------------------------------*
*  -->  P_RTKZ          Feld des Lohnartenobjektes                    *
*  -->  P_LGART         Lohnart                                       *
*  -->  P_MTHBK         Monate in der Vergangenheit                   *
*  -->  P_AGGREGATE     Aggregatfunktion                              *
*---------------------------------------------------------------------*
FORM PROCESS_RT USING VALUE(P_RTKZ)      TYPE /SIE/HR_IDP_RTKZ
                      VALUE(P_LGART)     TYPE LGART
                      VALUE(P_MTHBK)     TYPE /SIE/HR_IDP_MONTHS_BACK
                      VALUE(P_AGGREGATE) TYPE /SIE/HR_IDP_AGGREGATE
                      VALUE(P_FELD).
  DATA:
    TAG       TYPE /SIE/HR_IDP_TT_CODING,
    INPUT     TYPE /SIE/HR_IDP_TT_CODING,
    RESULT    TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'read_rt' CHANGING TAG.
  PERFORM REPLACE_PARAM USING 'LGART' P_LGART TAG
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'RTKZ' P_RTKZ INPUT
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'MTHBK' P_MTHBK INPUT
                        CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'AGGREGATE' P_AGGREGATE INPUT
                      CHANGING RESULT.
  MOVE RESULT[] TO INPUT[].
  PERFORM REPLACE_PARAM USING 'FELD' P_FELD INPUT
                      CHANGING RESULT.

  PERFORM INSERT_CODE USING RESULT.

*$<read_rt>
*$ perform get_rt using '&LGART'
*$                      '&RTKZ'
*$                      '&MTHBK'
*$                      '&AGGREGATE'
*$            changing  &FELD.
*$</read_rt>

ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESS_PAYROLL_INCLUDE                                  *
*---------------------------------------------------------------------*
*        Lesen der Abrechnungsergebnisse aus dem Cluster und          *
*        automatische Interpretation der Ergebnisse                   *
*---------------------------------------------------------------------*
FORM PROCESS_PAYROLL_INCLUDE.

  DATA:
    TAG       TYPE /SIE/HR_IDP_TT_CODING.

  PERFORM GET_TAG USING 'read_payroll' CHANGING TAG.
  PERFORM INSERT_CODE USING TAG.

*$<read_payroll>
*$ form get_rt using p_lgart
*$                   p_rtkz
*$                   p_mthbk
*$                   p_aggregate
*$          changing p_feld.
*$
*$ data: l_wf type /sie/hr_idp_fields.
*$ clear l_wf.
*$ l_wf-dpftype     = 4.
*$ l_wf-rtkz        = p_rtkz.
*$ l_wf-lgart       = p_lgart.
*$ l_wf-aggregate   = p_aggregate.
*$ l_wf-mthbk       = p_mthbk.
*$ perform get_payroll_result using l_wf
*$                     changing p_feld.
*$
*$ endform.
*$
*$ form get_kto using p_tabtyp
*$                    p_acltab
*$                    p_acl_length
*$                    p_acl_offset
*$                    p_acl_fldtyp
*$           changing p_feld.
*$
*$ data: l_wf type /sie/hr_idp_fields.
*$ clear l_wf.
*$ l_wf-dpftype     = 3.
*$ l_wf-acltab      = p_acltab.
*$ l_wf-acl_length  = p_acl_length.
*$ l_wf-acl_offset  = p_acl_offset.
*$ l_wf-acl_fldtyp  = p_acl_fldtyp.
*$ l_wf-mthbk       = '00'.
*$ perform get_payroll_result using l_wf
*$                 changing p_feld.
*$
*$ endform.
*$
*$ form get_payroll_result
*$           using value(wf)  type /sie/hr_idp_fields
*$           changing p_result type p.
*$
*$   clear: p_result.
*$
*$   perform read_payroll using wf
*$                        changing p_result.
*$
*$ endform.
*$ form read_payroll USING WF LIKE /SIE/HR_IDP_FIELDS
*$                   changing p_value.
*$
*$   data: payroll_result type payde_result.
*$
*$     perform read_result using pernr-pernr
*$                               wf-mthbk
*$                         changing payroll_result.
*$
*$     case wf-dpftype.
*$       when 3.     " Lohnkonto
*$         perform process_kto using payroll_result
*$                                   wf
*$                             changing p_value.
*$
*$       when 4.      " Lohnart
*$         perform process_rt using payroll_result
*$                                  wf
*$                            changing p_value.
*$       when others.
*$     endcase.
*$
*$  endform.
*$
*$ form read_result using    p_pernr like pernr-pernr
*$                           p_seqnr like /sie/hr_idp_s1pg-mthbk
*$                  changing p_result type payde_result.
*$
*$  read table it_rd with key mthbk = p_seqnr.
*$  if sy-subrc >< 0.
*$    clear p_result.
*$  else.
*$    p_result = it_rd-payde_result.
*$  endif.
*$
*$ endform.                    " READ_RESULT
*$
*$ form process_kto using value(p_result) type payde_result
*$                        value(wf) type /sie/hr_idp_fields
*$                  changing p_value.
*$
*$   data: buffer(3600).
*$
*$   field-symbols: <result>
*$                , <table> type table
*$                , <structure>
*$                , <field>
*$                .
*$
*$   case wf-acl_tabtyp.
*$     when 'u'.
*$       assign p_result to <result>.
*$       assign component wf-acltab
*$                        of structure <result> to <structure>.
*$       buffer = <structure>.
*$       assign buffer+wf-acl_offset(wf-acl_length) to <field>.
*$       p_value = <field>.
*$
*$     when 'h'.
*$       assign p_result to <result>.
*$       assign component wf-acltab of structure <result> to <table>.
*$
*$       loop at <table> into buffer.
*$         assign buffer+wf-acl_offset(wf-acl_length) to <field>
*$                type wf-acl_fldtyp.
*$         p_value = p_value + <field>.
*$       endloop.
*$     when others.
*$   endcase.
*$
*$ endform.                    " PROCESS_KTO
*$
*$ form process_rt using value(p_payroll) type payde_result
*$                       value(wf) type /sie/hr_idp_fields
*$                 changing p_result.
*$
*$   data: idx type i
*$       , wrt like pc207
*$       .
*$
*$   clear idx.
*$
*$   sort p_payroll-inter-rt by lgart apznr.
*$
*$   loop at p_payroll-inter-rt into wrt
*$                             where lgart = wf-lgart.
*$     case wf-rtkz.
*$       when 'A'.
*$         case wf-aggregate.
*$           when 'A'.
*$             p_result = p_result + wrt-betrg.
*$             idx = idx + 1.
*$
*$           when space. " Default
*$             p_result = p_result + wrt-betrg.
*$         endcase.
*$     when 'N'.
*$       p_result = p_result + wrt-anzhl.
*$
*$     when 'R'.
*$       case wf-aggregate.
*$         when 'A'.
*$           p_result = p_result + wrt-betrg.
*$           idx = idx + 1.
*$
*$         when 'F'.
*$           if p_result is initial.
*$             p_result = wrt-betpe.
*$           endif.
*$
*$         when 'L'.
*$           p_result = wrt-betpe.
*$
*$           when 'M'.
*$             if p_result is initial.
*$               p_result = wrt-betpe.
*$             else.
*$               if p_result > wrt-betpe.
*$                 p_result = wrt-betpe.
*$               endif.
*$             endif.
*$
*$           when 'X'.
*$             if p_result < wrt-betpe.
*$               p_result = wrt-betpe.
*$             endif.
*$
*$           when space.
*$             p_result = p_result + wrt-betpe.
*$
*$           when others.
*$         endcase.
*$
*$       when others.
*$     endcase.
*$   endloop.
*$    if wf-aggregate = 'A'.
*$      if idx <> 0.
*$        p_result = p_result / idx.
*$      else.
*$        p_result = 0.
*$      endif.
*$    endif.
*$
*$  endform.                    " PROCESS_RT
*$
*$</read_payroll>
ENDFORM.
