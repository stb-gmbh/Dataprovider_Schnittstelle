*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_TYPESF01 .
*----------------------------------------------------------------------*
*---------------------Change Log-------------------------------*
*  M. Przygocki 20230111 ATC findings C2C correction
*--------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  READ_CONVERSION_TYPES
*&---------------------------------------------------------------------*
form read_conversion_types using p_conversion type /sie/hr_idp_konvnam.

  data: begin of itab occurs 10,
          word type c,
        end   of itab.

  clear g_itab_types[].

  select single * from /sie/hr_idp_c1 where konvnam = p_conversion.
  if sy-subrc = 0.
    case /sie/hr_idp_c1-konvflag.
      when '+'.
        split /sie/hr_idp_c1-konvlist at field_type into table itab.
        loop at itab.
          clear g_itab_types.
          g_itab_types-sign = 'I'.
          g_itab_types-option = 'EQ'.
          g_itab_types-low = itab-word.
          g_itab_types-high = space.
          append g_itab_types.
        endloop.

      when '-'.
        split /sie/hr_idp_c1-konvlist at field_type into table itab.
        loop at itab.
          clear g_itab_types.
          g_itab_types-sign = 'E'.
          g_itab_types-option = 'EQ'.
          g_itab_types-low = itab-word.
          g_itab_types-high = space.
          append g_itab_types.
        endloop.

      when space.
        clear g_itab_types[].
      when others.
        clear g_itab_types[].
    endcase.
  else.
    clear g_itab_types[].
  endif.
endform.                    " READ_CONVERSION_TYPES

*&---------------------------------------------------------------------*
*&      Form  READ_FIELDNAME_TYPE
*&---------------------------------------------------------------------*
form read_fieldname_type using value(p_logical_field)
                                     type /sie/hr_idp_fname
                         changing p_field    type inttype
                                  p_length   type ddleng
                                  p_dblength type ddleng
                                  p_type     type dynptype
                                  p_decimals type decimals
                                  p_signflag type signflag.


  select single * from /sie/hr_idp_f1
                  where feldname = p_logical_field.
  if sy-subrc = 0.
    case /sie/hr_idp_f1-dpftype.
      when 1.
        perform find_infty_type using /sie/hr_idp_f1-infty
                                      /sie/hr_idp_f1-inftyfeld
                                changing p_field
                                         p_length
                                         p_dblength
                                         p_type
                                         p_decimals
                                         p_signflag.
      when 2.
        perform find_gbegriff_type using /sie/hr_idp_f1-begriff
                                   changing p_field
                                            p_length
                                            p_dblength
                                            p_type
                                            p_decimals
                                            p_signflag.
      when 3.
        perform find_kto_type using /sie/hr_idp_f1-acltab
                                    /sie/hr_idp_f1-aclfeld
                              changing p_field
                                       p_length
                                       p_dblength
                                       p_type
                                       p_decimals
                                       p_signflag.
      when 4.
        perform find_lgart_type using /sie/hr_idp_f1-rtkz
                                changing p_field
                                         p_length
                                         p_dblength
                                         p_type
                                         p_decimals
                                         p_signflag.
      when 5.
        case /sie/hr_idp_f1-feldname.
          when 'HT_DATUM'.
            p_type = 'DATS'. p_length = 8. p_field = 'D'. p_dblength = 16.
          when 'HT_URZEIT'.
            p_type = 'TIMS'. p_length = 6. p_field = 'T'. p_dblength = 12.
          when 'HT_SYSTEM'.
            p_type = 'CHAR'. p_length = 8. p_field = 'C'.  p_dblength = 16.
          when 'HT_MANDANT'.
            p_type = 'CLNT'. p_length = 3. p_field = 'C'.  p_dblength = 6.
          when 'HT_BEZUGSDATUM'.
            p_type = 'DATS'. p_length = 8. p_field = 'D'.  p_dblength = 16.
          when 'HT_RECORD_COUNT'.
            p_type = 'NUMC'. p_length = 10. p_field = 'N'.  p_dblength = 20.
          when 'HT_PERNR_COUNT'.
            p_type = 'NUMC'. p_length = 10. p_field = 'N'.  p_dblength = 20.
          when 'HT_FILESIZE'.
            p_type = 'NUMC'. p_length = 10. p_field = 'N'.  p_dblength = 20.
          when 'HT_FILENAME'.
            p_type = 'CHAR'. p_length = 256. p_field = 'C'.  p_dblength = 512.
          when 'HT_VERSION'.
            p_type = 'NUMC'. p_length = 4. p_field = 'N'.  p_dblength = 8.
        endcase.
      when others.
    endcase.
  else.
    p_field = space.
  endif.

endform.                    " READ_FIELDNAME_TYPE

*&---------------------------------------------------------------------*
*&      Form  FIND_INFTY_TYPE
*&---------------------------------------------------------------------*
form find_infty_type using value(p_infty) like /sie/hr_idp_f1-infty
                           value(p_feld) like /sie/hr_idp_f1-inftyfeld
                     changing p_field type inttype
                              p_length   type ddleng
                              p_dblength type ddleng
                              p_type type dynptype
                              p_decimals type decimals
                              p_signflag type signflag.

  data: l_structure like dcobjdef-name
  , itab_x031l type standard table of x031l initial size 0 with
    header line
  , itab_dfies type standard table of dfies initial size 0 with
    header line
  .

  concatenate 'P' p_infty into l_structure.
  call function 'DDIF_NAMETAB_GET'
    exporting
      tabname   = l_structure
    tables
      x031l_tab = itab_x031l
      dfies_tab = itab_dfies
    exceptions
      not_found = 1
      others    = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
  loop at itab_x031l where fieldname = p_feld.
    p_field = itab_x031l-exid.
    p_dblength = itab_x031l-dblength.
    p_type  = itab_x031l-dtyp.
    p_decimals = itab_x031l-decimals.
    read table itab_dfies with key fieldname = p_feld.
    if sy-subrc = 0.
      p_signflag = itab_dfies-sign.
      p_length = itab_dfies-leng.  "wg Unicode
    else.
      clear p_signflag.
    endif.
    exit.
  endloop.

endform.                    " FIND_INFTY_TYPE

*&---------------------------------------------------------------------*
*&      Form  FIND_LGART_TYPE
*&---------------------------------------------------------------------*
form find_lgart_type using value(p_rtkz) like /sie/hr_idp_f1-rtkz
                     changing p_field type inttype
                              p_length type ddleng
                              p_dblength type ddleng
                              p_type type dynptype
                              p_decimals type decimals
                              p_signflag type signflag.
  case p_rtkz.
    when 'A'.  p_type = 'CURR'. p_decimals = 2. p_signflag = 'X'.
    when 'R'.  p_type = 'CURR'. p_decimals = 2. p_signflag = 'X'.
    when 'N'.  p_type = 'DEC'. p_decimals = 2. p_signflag = 'X'.
    when others.
  endcase.

  p_length = 15.
  p_dblength = 15.
  p_field = 'P'.

endform.                    " FIND_LGART_TYPE

*&---------------------------------------------------------------------*
*&      Form  FIND_GBEGRIFF_TYPE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_/SIE/HR_IDP_F1_BEGRIFF  text
*      <--P_P_FIELD  text
*----------------------------------------------------------------------*
form find_gbegriff_type using p_begriff like /sie/hr_idp_f1-begriff
                        changing p_field type inttype
                                 p_length type ddleng
                                 p_dblength type ddleng
                                 p_type type dynptype
                                 p_decimals type decimals
                                 p_signflag type signflag.

  data: funcname like rs38l-name
      , itab_rsexp type standard table of rsexp   initial size 0 with
        header line
      , dtel like dcobjdef-name
      , dtel_l(40) type c
      , dfies_wa like dfies
      , itab_rsexc type standard table of rsexc initial size 0 with
        header line
      , itab_rsimp type standard table of rsimp initial size 0 with
        header line
      , itab_rstbl type standard table of rstbl initial size 0 with
        header line
      , l_table  like dcobjdef-name
      , l_field  like dcobjdef-name
      , l_t_dfies type standard table of dfies initial size 0 with
        header line
      .

  select single * from /sie/hr_fuba_kat
                  where begriff = p_begriff.
  if sy-subrc = 0.
    funcname = /sie/hr_fuba_kat-fuba.
    call function 'FUNCTION_IMPORT_INTERFACE'
      exporting
        funcname           = funcname
      tables
        exception_list     = itab_rsexc
        import_parameter   = itab_rsimp
        export_parameter   = itab_rsexp
        tables_parameter   = itab_rstbl
      exceptions
        error_message      = 1
        function_not_found = 2
        invalid_name       = 3
        others             = 4.
    if sy-subrc <> 0.
      p_field = space.
    else.
      loop at itab_rsexp where parameter = /sie/hr_fuba_kat-exparam.
        dtel = itab_rsexp-typ.
        dtel_l = itab_rsexp-typ.

* Check if this is a dataelement or a table?
        case dtel.
          when 'P'.
            p_field = 'P'.
            p_length = 8.
            p_dblength = 8.
            p_type = 'DEC'.
          when 'I'. p_field = 'I'. p_length = 10. p_dblength = 10. p_type = 'INT4'. "?
          when 'C'. p_field = 'C'. p_length = 1.  p_dblength = 2.  p_type = 'CHAR'.
          when 'N'. p_field = 'N'. p_length = 1.  p_dblength = 2.  p_type = 'NUMC'.
          when 'D'. p_field = 'D'. p_length = 8.  p_dblength = 16. p_type = 'DATS'.
          when 'T'. p_field = 'T'. p_length = 6.  p_dblength = 12. p_type = 'TIMS'.
          when others.
            if dtel ca '-'.                                 "#EC NOTEXT
              clear: l_table, l_field.
              split dtel_l at '-' into l_table l_field.
              call function 'DDIF_FIELDINFO_GET'
                exporting
                  tabname        = l_table
                  fieldname      = l_field
                  all_types      = 'X'
                tables
                  dfies_tab      = l_t_dfies
                exceptions
                  not_found      = 1
                  internal_error = 2
                  others         = 3.
              if sy-subrc <> 0.
                p_field = space.
              else.
                read table l_t_dfies index 1.
                p_field = l_t_dfies-inttype.
                p_length = l_t_dfies-leng. "wg Unicode! Intlen ist doppelt so groß
                p_dblength = l_t_dfies-intlen.
                p_type = l_t_dfies-datatype.
                p_decimals = l_t_dfies-decimals.
                p_signflag = l_t_dfies-sign.
                exit.
              endif.
            else.
              call function 'DDIF_FIELDINFO_GET'
                exporting
                  tabname        = dtel
                  all_types      = 'X'
                importing
                  dfies_wa       = dfies_wa
                exceptions
                  not_found      = 1
                  internal_error = 2
                  others         = 3.
              if sy-subrc <> 0.
                p_field = space.
              else.
                p_field = dfies_wa-inttype.
                p_length = dfies_wa-leng.
                P_dbLENGTH = DFIES_WA-INTLEN.
                p_type = dfies_wa-datatype.
                p_decimals = dfies_wa-decimals.
                p_signflag = dfies_wa-sign.
                exit.
              endif.
            endif.
        endcase.
      endloop.
      if sy-subrc <> 0.
        p_field = space.
      endif.
    endif.
  else.
    p_field = space.
  endif.

endform.                    " FIND_GBEGRIFF_TYPE

*&---------------------------------------------------------------------*
*&      Form  FIND_KTO_TYPE
*&---------------------------------------------------------------------*
form find_kto_type using    p_acltab like /sie/hr_idp_f1-acltab
                            p_aclfeld like /sie/hr_idp_f1-aclfeld
                   changing p_field type inttype
                            p_length type ddleng
                            p_dblength type ddleng
                            p_type type dynptype
                            p_decimals type decimals
                            p_signflag type signflag.

  constants: clusterid like  pcl2-relid value 'RD'.

  statics: requested_objects_list type standard table of hrpystruc
        initial size 0 with header line
      .

  data: typename like dcobjdef-name value 'PAYXX_RESULT'.
  data: iso_code like t500l-intca.
  data: help_lname type dfies-lfieldname.
  data: hyphen_offset type sy-fdpos.

  constants: int_name(5)     value 'INTER',
             nat_name(3)     value 'NAT',
             evp_name(3)     value 'EVP',
             result_name(6)  value 'RESULT',
             version_name(7) value 'VERSION'.

  data: l_structure like dcobjdef-name
      , l_acl_tabtyp type c
      .

  data: itab_x031l type standard table of x031l initial size 0 with
        header line
      , itab_dfies type standard table of dfies initial size 0 with
        header line
  .

  describe table itab_dfies.
  if sy-tfill = 0.

    clear requested_objects_list[].
    select intca into iso_code from t500l up to 1 rows
           where relid = clusterid
      ORDER BY PRIMARY KEY.                                       "M. Przygocki 20230111
    endselect.
    replace 'XX' with iso_code into typename.

    call function 'DDIF_FIELDINFO_GET'
      exporting
        tabname        = typename
        all_types      = 'X'
      tables
        dfies_tab      = itab_dfies
      exceptions
        not_found      = 1
        internal_error = 2
        others         = 3.
    if sy-subrc <> 0.
      raise ddictype_does_not_exist.
    endif.

  endif.

  read table itab_dfies with key fieldname = p_acltab
*                                DATATYPE = 'TTAB'.
                                 datatype = 'TTYP'."SIE001
  l_acl_tabtyp = itab_dfies-inttype.

  if itab_dfies-rollname(2) = 'PC'.
    l_structure = itab_dfies-rollname.
  else.
    if itab_dfies-lfieldname(5) eq int_name.
      select * from dd40l where typename like 'HRPAY99%'
        ORDER BY PRIMARY KEY.                                 "M. Przygocki 20230111
        if dd40l+8(22) = p_acltab.
          move dd40l-rowtype to l_structure.
          exit.
        endif.
      endselect.
    elseif itab_dfies-lfieldname(3) eq nat_name.
      select * from dd40l where typename like 'HRPAYDE%'.
        if dd40l+8(22) = p_acltab.
          move dd40l-rowtype to l_structure.
          exit.                                           "#EC CI_NOORDER
        endif.
      endselect.
    endif.
  endif.

  clear itab_dfies[].
  call function 'DDIF_NAMETAB_GET'
    exporting
      tabname   = l_structure
    tables
      x031l_tab = itab_x031l
      dfies_tab = itab_dfies
    exceptions
      not_found = 1
      others    = 2.
  if sy-subrc <> 0.
    clear itab_x031l[]. clear itab_dfies[]. p_field = space.
  endif.

  loop at itab_x031l where fieldname = p_aclfeld.
    p_field = itab_x031l-exid.
    p_dblength = itab_x031l-dblength.   "aha003
    p_length = itab_x031l-dblength.
    p_type = itab_x031l-dtyp.
    p_decimals = itab_x031l-decimals.
    read table itab_dfies with key fieldname = p_field.
    if sy-subrc = 0.
      p_signflag = itab_dfies-sign.
    else.
      clear p_signflag.
    endif.
    "Unicodeanpassung begin aha003
    read table itab_dfies with key fieldname = p_aclfeld.
    if sy-subrc = 0.
      p_length = itab_dfies-leng.
    endif.
    "Unicodeanpassung  end aha003

    exit.
  endloop.
  if sy-subrc = 0.
  else.
    p_field = space.
  endif.

endform.                    " FIND_KTO_TYPE
