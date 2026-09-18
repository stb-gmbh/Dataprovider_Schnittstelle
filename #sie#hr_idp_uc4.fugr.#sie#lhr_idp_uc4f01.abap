*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_UC4F01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_TEMPLATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_REPID  text
*      <--P_G_TEMPLATE  text
*----------------------------------------------------------------------*
FORM get_template USING    p_sy_repid LIKE sy-repid
                           p_application TYPE c
                  CHANGING p_template TYPE /sie/hr_idp_tt_sd.

  DATA:
    ri        TYPE /sie/hr_idp_tt_sd,
    l         LIKE LINE OF ri,
    incl_id   LIKE sy-repid,
    name2     LIKE trdir-name,
    dummy     TYPE c,
    dummy2(2) TYPE c.

  CONCATENATE '*' p_application INTO dummy2.

  CLEAR ri.
  READ REPORT p_sy_repid INTO ri.
  LOOP AT ri INTO l.
    IF l+0(1) >< '*'.                                       "#EC NOTEXT
      TRANSLATE l TO UPPER CASE.
      CONDENSE  l.
      SHIFT l UP TO '"' RIGHT.                              "#EC NOTEXT
      SHIFT l UP TO 'INCLUDE'.                              "#EC NOTEXT
      IF l(7) EQ 'INCLUDE'.                                 "#EC NOTEXT
        SHIFT l BY 8 PLACES.
        TRANSLATE l USING '. '.                             "#EC NOTEXT
        IF    l(9) NE 'STRUCTURE'                           "#EC NOTEXT
          AND l(4) NE 'TYPE'                                "#EC NOTEXT
          AND l(7) NE 'METHODS'.                            "#EC NOTEXT
          SPLIT l AT space INTO name2 dummy.
        ENDIF.
        PERFORM get_template USING name2 p_application
                CHANGING p_template.
      ENDIF.
    ENDIF.
    IF l+0(2) EQ dummy2.
      SHIFT l BY 2 PLACES.
      APPEND l TO p_template.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PROCESS_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_DEFINITION_S1DF_FILE  text
*----------------------------------------------------------------------*
FORM process_filename USING VALUE(file_name) TYPE text256.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(filename)' CHANGING tag.
  PERFORM replace_param USING 'NAME'
                              file_name
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(filename)>
*$<filename>&NAME</filename>
*$</(filename)>
ENDFORM.                    " PROCESS_FILENAME
*&---------------------------------------------------------------------*
*&      Form  PROCESS_ENCRYPTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_DEFINITION_S1DF_ENCR  text
*----------------------------------------------------------------------*
FORM process_encryption USING p_encr.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(encryption)' CHANGING tag.
  PERFORM replace_param USING 'FLAG'
                              p_encr
                              tag
                        CHANGING result.
  PERFORM insert_code USING result.
*$<(encryption)>
*$<encryption>&FLAG</encryption>
*$</(encryption)>

ENDFORM.                    " PROCESS_ENCRYPTION
*&---------------------------------------------------------------------*
*&      Form  PROCESS_HOST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_DEFINITION_S1DF_HOST  text
*----------------------------------------------------------------------*
FORM process_host USING    p_host.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(host)' CHANGING tag.
  PERFORM replace_param USING 'HOST'
                              p_host
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(host)>
*$<host>&HOST</host>
*$</(host)>

ENDFORM.                    " PROCESS_HOST
*&---------------------------------------------------------------------*
*&      Form  PROCESS_IP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_DEFINITION_S1DF_TCPI  text
*----------------------------------------------------------------------*
FORM process_ip USING    p_tcpi.

  DATA:
    l           TYPE LINE OF /sie/hr_idp_tt_sd,
    tag         TYPE /sie/hr_idp_tt_sd,
    result      TYPE /sie/hr_idp_tt_sd,
    ip_form(15) TYPE c.


  CALL FUNCTION 'CONVERSION_EXIT_TCPIP_OUTPUT'
    EXPORTING
      input  = p_tcpi
    IMPORTING
      output = ip_form.

  PERFORM get_tag USING '(ip)' CHANGING tag.
  PERFORM replace_param USING 'IP'
                              ip_form
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(ip)>
*$<ip>&IP</ip>
*$</(ip)>
ENDFORM.                    " PROCESS_IP
*&---------------------------------------------------------------------*
*&      Form  PROCESS_PORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_DEFINITION_S1DF_PORT  text
*----------------------------------------------------------------------*
FORM process_port USING    p_port.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(port)' CHANGING tag.
  PERFORM replace_param USING 'PORT'
                              p_port
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(port)>
*$<port>&PORT</port>
*$</(port)>

ENDFORM.                    " PROCESS_PORT
*&---------------------------------------------------------------------*
*&      Form  PROCESS_ADMISSION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_DEFINITION_S1DF_TRFA  text
*----------------------------------------------------------------------*
FORM process_admission USING    p_trfa.
  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(admission)' CHANGING tag.
  PERFORM replace_param USING 'ADMISSION'
                              p_trfa
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(admission)>
*$<admission>&ADMISSION</admission>
*$</(admission)>
ENDFORM.                    " PROCESS_ADMISSION

*---------------------------------------------------------------------*
*       FORM GET_TAG                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_TAGNAME                                                     *
*  -->  P_TAG                                                         *
*---------------------------------------------------------------------*
FORM get_tag USING    p_tagname
             CHANGING p_tag TYPE /sie/hr_idp_tt_sd.
  DATA:
    l              TYPE LINE OF /sie/hr_idp_tt_sd,
    start_mark(72),
    end_mark(72),
    found.

  CONCATENATE '<' p_tagname '>' INTO start_mark.
  CONCATENATE '</' p_tagname '>' INTO end_mark.
  LOOP AT g_template INTO l.
    IF l CS start_mark.
      found = 'X'.
    ELSEIF l CS end_mark.
      EXIT.
    ELSEIF NOT found IS INITIAL.
      TRANSLATE l TO UPPER CASE.
      APPEND l TO p_tag.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_TAG
*---------------------------------------------------------------------*
*       FORM REPLACE_PARAM                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_PARAM                                                       *
*  -->  P_VALUE                                                       *
*  -->  P_TAG                                                         *
*  -->  P_RESULT                                                      *
*---------------------------------------------------------------------*
FORM replace_param USING    p_param
                            p_value
                            p_tag    TYPE /sie/hr_idp_tt_sd
                   CHANGING p_result TYPE /sie/hr_idp_tt_sd.
  FIELD-SYMBOLS: <fs>.
  DATA:
    l         TYPE LINE OF /sie/hr_idp_tt_sd,
    p         TYPE LINE OF /sie/hr_idp_tt_sd,
    parts     TYPE /sie/hr_idp_tt_sd,
    len_value TYPE i,
    len_param TYPE i,
    pos       TYPE i,
    param(72).
  CLEAR p_result.
  CONCATENATE '&' p_param INTO param.

  len_value = strlen( p_value ).
  len_param = strlen( param ).
  LOOP AT p_tag INTO l.
    DO.
      IF len_value GT 0.
        ASSIGN p_value+0(len_value) TO <fs>.
        REPLACE param LENGTH len_param WITH <fs> INTO l.
      ELSE.
        REPLACE param LENGTH len_param WITH '' INTO l.
      ENDIF.
      IF sy-subrc NE 0. EXIT. ENDIF.
    ENDDO.
    APPEND l TO p_result.
  ENDLOOP.
ENDFORM.                    " REPLACE_PARAM

*---------------------------------------------------------------------*
*       FORM INSERT_CODE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_TAG                                                         *
*---------------------------------------------------------------------*
FORM insert_code USING    p_tag TYPE /sie/hr_idp_tt_sd.
  DATA:
    l TYPE LINE OF /sie/hr_idp_tt_sd.
  LOOP AT p_tag INTO l.
    APPEND l TO code.
  ENDLOOP.
ENDFORM.                    " INSERT_CODE

*&---------------------------------------------------------------------*
*&      Form  PROCESS_XML_VERSION
*&---------------------------------------------------------------------*
*       Generiert den XML Tag
*----------------------------------------------------------------------*
FORM process_xml_version.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(xml_vers)' CHANGING tag.

  PERFORM insert_code USING tag.

*$<(xml_vers)>
*$<?xml version="1.0"?>
*$</(xml_vers)>

ENDFORM.                    " PROCESS_XML_VERSION

*&---------------------------------------------------------------------*
*&      Form  PROCESS_EMAIL_SUC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_DEFINITION_S1DF_EMSU  text
*----------------------------------------------------------------------*
FORM process_email_suc USING p_emsu.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(eml_succ)' CHANGING tag.

  PERFORM replace_param USING 'EML_SUCC'
                              p_emsu
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(eml_succ)>
*$<email_success>&EML_SUCC</email_success>
*$</(eml_succ)>

ENDFORM.                    " PROCESS_EMAIL_SUC

*&---------------------------------------------------------------------*
*&      Form  PROCESS_EMAIL_ERR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INTERFACE_DEFINITION_S1DF_EMER  text
*----------------------------------------------------------------------*
FORM process_email_err USING  p_emsu.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(eml_err)' CHANGING tag.

  PERFORM replace_param USING 'EML_ERR'
                              p_emsu
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(eml_err)>
*$<email_error>&EML_ERR</email_error>
*$</(eml_err)>

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_sftp_user
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> INTERFACE_DEFINITION_S1DF_SFTP
*&---------------------------------------------------------------------*
FORM process_sftp_user  USING    p_sftp_user.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(sftp_user)' CHANGING tag.

  PERFORM replace_param USING 'SFTP_USER'
                              p_sftp_user
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(sftp_user)>
*$<sftp_user>&SFTP_USER</sftp_user>
*$</(sftp_user)>

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_SFTP_PUBLICKEY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> INTERFACE_DEFINITION_S1DF_SFTP
*&---------------------------------------------------------------------*
FORM process_SFTP_PUBLICKEY  USING    p_sftp_publickey.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(sftp_publickey)' CHANGING tag.

  PERFORM replace_param USING 'SFTP_PUBLICKEY'
                              p_sftp_publickey
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(sftp_publickey)>
*$<sftp_publickey>&SFTP_PUBLICKEY</sftp_publickey>
*$</(sftp_publickey)>

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_SFTP_ZIELVERZEICHNIS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> INTERFACE_DEFINITION_S1DF_SFTP
*&---------------------------------------------------------------------*
FORM process_SFTP_ZIELVERZEICHNIS  USING    p_sftp_zielverzeichnis.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(sftp_zielverzeichnis)' CHANGING tag.

  PERFORM replace_param USING 'SFTP_ZIELVERZEICHNIS'
                              p_sftp_zielverzeichnis
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(sftp_zielverzeichnis)>
*$<sftp_zielverzeichnis>&SFTP_ZIELVERZEICHNIS</sftp_zielverzeichnis>
*$</(sftp_zielverzeichnis)>

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_SFTP_TRANSFER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> INTERFACE_DEFINITION_S1DF_SFTP
*&---------------------------------------------------------------------*
FORM process_SFTP_TRANSFER  USING    p_sftp_transfer.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  IF p_sftp_transfer = abap_true.
    l = '<TRANSFER_TYPE>SFTP</TRANSFER_TYPE>'.
  ELSE.
    l = '<TRANSFER_TYPE>OPENFT</TRANSFER_TYPE>'.
    endif.

    APPEND l TO result.
    PERFORM insert_code USING result.

ENDFORM.
FORM process_SFTP_CONFIGFILE USING    p_sftp_configfile.

  DATA:
    l      TYPE LINE OF /sie/hr_idp_tt_sd,
    tag    TYPE /sie/hr_idp_tt_sd,
    result TYPE /sie/hr_idp_tt_sd.

  PERFORM get_tag USING '(sftp_configfile)' CHANGING tag.

  PERFORM replace_param USING 'SFTP_CONFIGFILE'
                              p_sftp_configfile
                              tag
                        CHANGING result.

  PERFORM insert_code USING result.

*$<(sftp_configfile)>
*$<sftp_configfile>&SFTP_CONFIGFILE</sftp_configfile>
*$</(sftp_configfile)>

ENDFORM.
