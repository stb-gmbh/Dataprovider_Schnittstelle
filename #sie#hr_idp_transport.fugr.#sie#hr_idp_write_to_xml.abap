FUNCTION /sie/hr_idp_write_to_xml.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(DB_DATA) TYPE  /SIE/HR_IDP_IFC_DB
*"             VALUE(FL_ENVELOPE) TYPE  XFELD DEFAULT 'X'
*"       TABLES
*"              XML_DATA
*"----------------------------------------------------------------------

*SIE001 29.03.2004 Hierl  Neue Option "kein Trennzeichen" CR 4199
*SIE002 29.06.2004 Hierl  Neue Funktion Filter auf Feldebene CR 4258
*SIE003 22.11.2004 Hierl  Nachbearb./glob.Sel/UC4-Startzeit CR4258

  TYPES: BEGIN OF s_data
       , text(1000)
       , END OF s_data
       , t_data TYPE STANDARD TABLE OF s_data INITIAL SIZE 0
       .

  DATA: db_iface TYPE  /sie/hr_idp_ifc_db
      , wa_s1sa TYPE /sie/hr_idp_s1sa
      , wa_s1pg TYPE /sie/hr_idp_s1pg
      , wa_s1ps TYPE /sie/hr_idp_s1ps                      "SIE002
      , wa_s1lt TYPE /sie/hr_idp_s1lt
      , wa_s1r TYPE /sie/hr_idp_s1r
      , wa_s1df TYPE /sie/hr_idp_s1df
      , wa_s1pr TYPE /sie/hr_idp_s1pr
      , wa_s1vt TYPE /sie/hr_idp_s1vt
      , ls_buffer TYPE s_data
      , lt_buffer TYPE t_data
      , sapdpversion(15) TYPE c
      , n1(15) TYPE c
      , n2(15) TYPE c
      , i1(3) TYPE n
      , i2(3) TYPE n
      , i3(3) TYPE n
      , i4(3) TYPE n
      , buffer1(1000) TYPE c
      , buffer2(1000) TYPE c
      , buffer3(1000) TYPE c
      , buffer4(1000) TYPE c
      , buffer_h(1000) TYPE c
      , len TYPE i
      , lt_entry TYPE STANDARD TABLE OF s_data INITIAL SIZE 0
                 WITH HEADER LINE
      , fl_space TYPE c
      , p TYPE p DECIMALS 2
      .

  DEFINE create_tag.
    clear ls_buffer-text.
    concatenate &1 &2 &3 into ls_buffer-text.
    append ls_buffer to lt_buffer.
  END-OF-DEFINITION.

  DEFINE replace_space.

    translate &2 using ' ~'.
    concatenate &2 '~' into &2.
    clear lt_entry[].
    fl_space = no.
    clear &1.
    split &2 at text-am1 into table lt_entry.
    describe table lt_entry lines len.
    do.
      if len = 0. exit. endif.
      read table lt_entry index len.
      fl_space = yes.
      if sy-index = 1.
        &1 = lt_entry.
      else.
        concatenate lt_entry text-amp &1 into &1.
      endif.
      len = len - 1.
    enddo.

    clear lt_entry[].
    fl_space = no.
    buffer_h = &1. clear &1.
    split buffer_h at text-sk0 into table lt_entry.
    describe table lt_entry lines len.
    do.
      if len = 0. exit. endif.
      read table lt_entry index len.
      fl_space = yes.
      if sy-index = 1.
        &1 = lt_entry.
      else.
        concatenate lt_entry text-sko &1 into &1.
      endif.
      len = len - 1.
    enddo.

    clear lt_entry[].
    fl_space = no.
    buffer_h = &1. clear &1.
    split buffer_h at space into table lt_entry.
    describe table lt_entry lines len.
    do.
      if len = 0. exit. endif.
      read table lt_entry index len.
      fl_space = yes.
      if sy-index = 1.
        &1 = lt_entry.
      else.
        concatenate lt_entry text-spc &1 into &1.
      endif.
      len = len - 1.
    enddo.

    translate &1 using '~ '.

  END-OF-DEFINITION.

  CALL FUNCTION '/SIE/HR_IDP_IFC_VERSION'
       IMPORTING
            version = sapdpversion.

* XML File declaration
  IF fl_envelope = yes.
    ls_buffer-text = text-001.
    APPEND ls_buffer TO lt_buffer.
  ENDIF.

  IF fl_envelope = yes.
    CONCATENATE '<sap_dp'
                ' version='
                text-003 sapdpversion text-003
                ' />'
    INTO ls_buffer.
    APPEND ls_buffer TO lt_buffer.
  ENDIF.

* Begin of data
  ls_buffer-text = '<interface>'.
  APPEND ls_buffer TO lt_buffer.

  replace_space buffer1 db_data-s1-ifcid.
  replace_space buffer2 db_data-s1-customer.
  replace_space buffer3 db_data-s1-auth_class.

  CONCATENATE '<head' ' ifcid=' text-003 buffer1 text-003
              ' version=' text-003 db_data-s1vn-vrsnr text-003
              ' customer=' text-003 buffer2 text-003
              ' auth_class=' text-003 buffer3 text-003
              ' valid_from=' text-003 db_data-s1-valid_from text-003
              ' valid_to=' text-003 db_data-s1-valid_to text-003
             ' act_vers_nr=' text-003 db_data-s1-act_vers_nr text-003
             ' new_version=' text-003 db_data-s1-new_version text-003
              ' />'
                 INTO ls_buffer-text.
  APPEND ls_buffer TO lt_buffer.

  ls_buffer-text = '<short_description>'.
  APPEND ls_buffer TO lt_buffer.

  ls_buffer-text = db_data-s1t-ident.
  APPEND ls_buffer TO lt_buffer.

  ls_buffer-text = '</short_description>'.
  APPEND ls_buffer TO lt_buffer.

  CONCATENATE '<documentation language='
              text-003
              sy-langu
              text-003
              ' >'
         INTO ls_buffer-text.
  APPEND ls_buffer TO lt_buffer.

  LOOP AT db_data-s1lt INTO wa_s1lt.
    CONCATENATE '<line id=' text-003 wa_s1lt-seqnr text-003 '>'
    INTO ls_buffer-text.
    APPEND ls_buffer TO lt_buffer.
    ls_buffer-text = wa_s1lt-tline.
    APPEND ls_buffer TO lt_buffer.
    ls_buffer-text = '</line>'.
    APPEND ls_buffer TO lt_buffer.
  ENDLOOP.

  ls_buffer-text = '</documentation>'.                      "#EC NOTEXT
  APPEND ls_buffer TO lt_buffer.

  p = db_data-s1pc-kostendr.
  CALL FUNCTION '/SIE/HR_IDP_C_UNPACK'
       EXPORTING
            p_in         = p
            p_parameters = 'DECP=.'
       IMPORTING
            p_out        = n1.

  p = db_data-s1pc-kostkatp.
  CALL FUNCTION '/SIE/HR_IDP_C_UNPACK'
       EXPORTING
            p_in         = p
            p_parameters = 'DECP=.'
       IMPORTING
            p_out        = n2.

  replace_space buffer1 db_data-s1pc-verwzwck.

  CONCATENATE '<pricing'
              ' kstorgid=' text-003 db_data-s1pc-kstorgid text-003
              ' kstbstln=' text-003 db_data-s1pc-kstbstln text-003
              ' verwzwck=' text-003 buffer1 text-003
              ' kostkate=' text-003 db_data-s1pc-kostkate text-003
              ' kzkosdir=' text-003 db_data-s1pc-kzkosdir text-003
              ' kostendr=' text-003 n1 text-003
              ' currency=' text-003 db_data-s1pc-currency text-003
              ' kostkatp=' text-003 n2 text-003
              ' />'
         INTO ls_buffer-text.
  APPEND ls_buffer TO lt_buffer.

  ls_buffer-text = '<contacts>'.                            "#EC NOTEXT
  APPEND ls_buffer TO lt_buffer.

  LOOP AT db_data-s1r INTO wa_s1r.
    replace_space buffer1 wa_s1r-email.
    CONCATENATE '<role'
                ' id=' text-003 wa_s1r-trole text-003
                ' pernr=' text-003 wa_s1r-pernr text-003
                ' usern=' text-003 wa_s1r-usern text-003
                ' orgeh=' text-003 wa_s1r-orgeh text-003
                ' email=' text-003 buffer1 text-003
                 ' />'
             INTO ls_buffer-text.
    APPEND ls_buffer TO lt_buffer.
  ENDLOOP.

  ls_buffer-text = '</contacts>'.                           "#EC NOTEXt
  APPEND ls_buffer TO lt_buffer.

  CONCATENATE '<delimiter'
              ' fixfm=' text-003 db_data-s1dl-fixfm text-003
              ' delim=' text-003 db_data-s1dl-delim text-003
              ' />'
         INTO ls_buffer-text.
  APPEND ls_buffer TO lt_buffer.

* Parameters
  wa_s1pr = db_data-s1pr.
* i1 = wa_s1pr-begdo.
* i2 = wa_s1pr-enddo.
* i3 = wa_s1pr-begpo.
* i4 = wa_s1pr-endpo.
  WRITE wa_s1pr-begdo TO i1.
  WRITE wa_s1pr-enddo TO i2.
  WRITE wa_s1pr-begpo TO i3.
  WRITE wa_s1pr-endpo TO i4.

    CONCATENATE '<parameters'
                ' timed=' text-003 wa_s1pr-timed text-003
                ' begdt=' text-003 wa_s1pr-begdt text-003
                ' begdo=' text-003 i1 text-003
                ' enddt=' text-003 wa_s1pr-enddt text-003
                ' enddo=' text-003 i2 text-003
                ' begpt=' text-003 wa_s1pr-begpt text-003
                ' begpo=' text-003 i3 text-003
                ' endpt=' text-003 wa_s1pr-endpt text-003
                ' endpo=' text-003 i4 text-003
                ' xabkr=' text-003 wa_s1pr-xabkr text-003
                ' abkro=' text-003 wa_s1pr-abkro text-003
                ' />'
           INTO ls_buffer-text.
  APPEND ls_buffer TO lt_buffer.

* Select Options
  ls_buffer-text = '<select_options>'.                      "#EC NOTEXT
  APPEND ls_buffer TO lt_buffer.

  LOOP AT db_data-s1vt INTO wa_s1vt.
    CONCATENATE:
      '<option'
     ' feldname=' text-003 wa_s1vt-feldname text-003
     ' seqno=' text-003 wa_s1vt-seqno  text-003
     ' ssign='  text-003 wa_s1vt-ssign text-003
     ' sopti=' text-003 wa_s1vt-sopti  text-003
     ' sllow=' text-003 wa_s1vt-sllow  text-003
     ' shigh='  text-003 wa_s1vt-shigh text-003
     ' />' INTO ls_buffer-text.
    APPEND ls_buffer TO lt_buffer.
  ENDLOOP.

  ls_buffer-text = '</select_options>'.                     "#EC NOTEXT
  APPEND ls_buffer TO lt_buffer.

* UC4
  wa_s1df = db_data-s1df.
  replace_space buffer1 wa_s1df-trfad.
  replace_space buffer2 wa_s1df-emsuc.
  replace_space buffer3 wa_s1df-emerr.
  replace_space buffer4 wa_s1df-filen.

  CONCATENATE '<uc4'       ' gnrtd=' text-003 wa_s1df-gnrtd text-003
                           ' progr=' text-003 space text-003
                           ' gnrvt=' text-003 wa_s1df-gnrvt text-003
                           ' varia=' text-003 space text-003
                           ' uc4fr=' text-003 wa_s1df-uc4fr text-003
                           ' uc4to=' text-003 wa_s1df-uc4to text-003
                           ' uc4dy=' text-003 wa_s1df-uc4dy text-003
                           ' uc4nr=' text-003 wa_s1df-uc4nr text-003
                           ' uc4pr=' text-003 wa_s1df-uc4pr text-003
                           ' filen=' text-003 buffer4 text-003
                           ' hostn=' text-003 wa_s1df-hostn text-003
                           ' tcpip=' text-003 wa_s1df-tcpip text-003
                           ' portn=' text-003 wa_s1df-portn text-003
                           ' trfad=' text-003 buffer1 text-003
                           ' encry=' text-003 wa_s1df-encry text-003
                           ' emsuc=' text-003 buffer2 text-003
                           ' emerr=' text-003 buffer3 text-003
                           ' uc4nm=' text-003 wa_s1df-uc4nm text-003
                           ' itype=' text-003 wa_s1df-itype text-003
                           ' delta=' text-003 wa_s1df-delta text-003
*SIE003_BEG
                       ' nachbearb=' text-003 wa_s1df-nachbearb text-003
                           ' uc4st=' text-003 wa_s1df-uc4st text-003
                           ' uc4sm=' text-003 wa_s1df-uc4sm text-003
                          ' nogsel=' text-003 wa_s1df-nogsel text-003
*SIE003_END
                           ' />'
                                  INTO ls_buffer-text.
  APPEND ls_buffer TO lt_buffer.

* Layout
  ls_buffer-text = '<layout>'.                              "#EC NOTEXT
  APPEND ls_buffer TO lt_buffer.

  LOOP AT db_data-s1sa INTO wa_s1sa.

    CONCATENATE '<recordtype' ' name=' text-003 wa_s1sa-recna text-003
                             ' recty=' text-003 wa_s1sa-recty text-003
                             ' dbahd=' text-003 wa_s1sa-dbahd text-003
                             ' dbaoc=' text-003 wa_s1sa-dbaoc text-003
                             ' infty=' text-003 wa_s1sa-infty text-003
                             ' subty=' text-003 wa_s1sa-subty text-003
                             ' kzsrn=' text-003 wa_s1sa-kzsrn text-003
                             ' kzspn=' text-003 wa_s1sa-kzspn text-003
                             ' sortn=' text-003 wa_s1sa-sortn text-003
                           ' operan=' text-003 wa_s1sa-operan text-003
                          ' operat='  text-003 wa_s1sa-operat text-003
                          ' opeval='  text-003 wa_s1sa-opeval text-003
                             ' >' INTO ls_buffer-text.
    APPEND ls_buffer TO lt_buffer.

    LOOP AT db_data-s1pg INTO wa_s1pg
                          WHERE recna = wa_s1sa-recna.
      replace_space buffer1 wa_s1pg-param.
      replace_space buffer2 wa_s1pg-paramgb.
      CONCATENATE:
        '<field'
       ' fname=' text-003 wa_s1pg-feldname text-003
       ' fldps=' text-003 wa_s1pg-fldps text-003
       ' mthbk='  text-003 wa_s1pg-mthbk      text-003
       ' konvnam=' text-003 wa_s1pg-konvnam   text-003
       ' keypos=' text-003 wa_s1pg-keypos  text-003
       ' nosep=' text-003 wa_s1pg-nosep text-003               "SIE001
       ' param='  text-003 buffer1  text-003
       ' offst=' text-003  wa_s1pg-offst   text-003
       ' length=' text-003 wa_s1pg-length  text-003
       ' paramgb=' text-003 buffer2  text-003
*      ' />' INTO LS_BUFFER-TEXT.                              "SIE002
       ' >' INTO ls_buffer-text.                               "SIE002
      APPEND ls_buffer TO lt_buffer.

*     SIE002_BEG
      LOOP AT db_data-s1ps INTO wa_s1ps
                           WHERE recna = wa_s1pg-recna
                             AND fldps = wa_s1pg-fldps.

        CONCATENATE:
          '<filter'
          ' seqno=' text-003 wa_s1ps-seqno text-003
          ' ssign=' text-003 wa_s1ps-ssign text-003
          ' sopti=' text-003 wa_s1ps-sopti text-003
          ' sllow=' text-003 wa_s1ps-sllow text-003
          ' shigh=' text-003 wa_s1ps-shigh text-003
          ' />' INTO LS_BUFFER-TEXT.

        APPEND ls_buffer TO lt_buffer.
      ENDLOOP.

      create_tag: space space '</field>'.
*     SIE002_END

    ENDLOOP.

    create_tag: space space '</recordtype>'.

  ENDLOOP.

  ls_buffer-text = '</layout>'.                             "#EC NOTEXT
  APPEND ls_buffer TO lt_buffer.


  ls_buffer-text = '</interface>'.                          "#EC NOTEXT
  APPEND ls_buffer TO lt_buffer.

  xml_data[] = lt_buffer[].

ENDFUNCTION.
