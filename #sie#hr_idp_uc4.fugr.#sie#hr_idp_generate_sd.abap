FUNCTION /sie/hr_idp_generate_sd.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(INTERFACE_ID) TYPE  /SIE/HR_IDP_INTERFACE_ID
*"     VALUE(VERSION) TYPE  /SIE/HR_IDP_VERS_NR
*"     VALUE(FILE_NAME) TYPE  TEXT256
*"     VALUE(SD_FILE_NAME) TYPE  TEXT256
*"     VALUE(ADHOC_EXEC) TYPE  XFELD DEFAULT SPACE
*"  EXCEPTIONS
*"      FAILED
*"----------------------------------------------------------------------

  DATA: proc_vector TYPE /sie/hr_idp_db_sel
      , interface_definition TYPE /sie/hr_idp_ifc_db
      , l LIKE LINE OF code
      .

  REFRESH code.

* Lese die Struktur der Sendedatei
  PERFORM get_template USING sy-repid '$' CHANGING g_template.
  PERFORM process_xml_version.
  PERFORM process_filename USING file_name.
* Ist überhaupt etwas zu tun? Wenn wir in der Pflegeoberfläche sind
* und lassen die Schnittstelle zu testzwecke laufen, dann soll keine
* Sendedatei entstehen.
  CHECK ( sy-tcode >< '/SIE/HR_IDP_IFC_MOD' ) AND
        ( sy-tcode >< '/SIE/HR_IDP_IFC_DISP' ) AND
        ( sy-tcode >< '/SIE/HR_IDP_IFC_RELE' ).

* Falls es sich um ein AD-HOC Lauf handelt, die UC4 Parameter aus der
* Tabelle /SIE/HR_IDP_A1 lesen.
  IF adhoc_exec = no.
    proc_vector = c_all_tabl.
    CALL FUNCTION '/SIE/HR_IDP_DB_READ'
      EXPORTING
        interface        = interface_id
        version          = version
      CHANGING
        transaction_data = interface_definition
        dbsel            = proc_vector.


    IF interface_definition-s1df-sftp_transfer = abap_true.
      PERFORM process_sftp_transfer USING interface_definition-s1df-sftp_transfer. "SFTP oder OPENFT?
*      PERFORM process_encryption USING interface_definition-s1df-encry.
      PERFORM process_host USING interface_definition-s1df-hostn.
      PERFORM process_ip USING interface_definition-s1df-tcpip.
      PERFORM process_port USING interface_definition-s1df-portn.
      PERFORM process_sftp_user USING interface_definition-s1df-sftp_user. "SFTP
      PERFORM process_sftp_publickey USING interface_definition-s1df-sftp_publickey. "SFTP
      PERFORM process_sftp_zielverzeichnis USING interface_definition-s1df-sftp_zielverzeichnis. "SFTP
      PERFORM process_sftp_configfile USING interface_definition-s1df-sftp_configfile. "SFTP
*      PERFORM process_admission USING interface_definition-s1df-trfad.
      PERFORM process_email_suc USING interface_definition-s1df-emsuc.
      PERFORM process_email_err USING interface_definition-s1df-emerr.

    ELSE.
      PERFORM process_sftp_transfer USING interface_definition-s1df-sftp_transfer. "SFTP oder OPENFT?
      PERFORM process_encryption USING interface_definition-s1df-encry.
      PERFORM process_host USING interface_definition-s1df-hostn.
      PERFORM process_ip USING interface_definition-s1df-tcpip.
      PERFORM process_port USING interface_definition-s1df-portn.
*      PERFORM process_sftp_user USING interface_definition-s1df-sftp_user. "SFTP
*      PERFORM process_sftp_publickey USING interface_definition-s1df-sftp_publickey. "SFTP
*      PERFORM process_sftp_zielverzeichnis USING interface_definition-s1df-sftp_zielverzeichnis. "SFTP
      PERFORM process_admission USING interface_definition-s1df-trfad.
      PERFORM process_email_suc USING interface_definition-s1df-emsuc.
      PERFORM process_email_err USING interface_definition-s1df-emerr.


    ENDIF.


  ELSE.

    SELECT SINGLE * FROM /sie/hr_idp_a1 WHERE ifcid = interface_id
                                 AND vrsnr = version.
    IF sy-subrc = 0.
      PERFORM process_encryption USING yes.
      PERFORM process_host USING /sie/hr_idp_a1-hostn.
      PERFORM process_ip USING /sie/hr_idp_a1-tcpip.
      PERFORM process_port USING /sie/hr_idp_a1-portn.
      PERFORM process_admission USING /sie/hr_idp_a1-trfad.
      PERFORM process_email_suc USING /sie/hr_idp_a1-emsuc.
      PERFORM process_email_err USING /sie/hr_idp_a1-emerr.
    ELSE.
      RAISE failed.
    ENDIF.
  ENDIF.

* Die Sendedatei nun ausgeben.
  PERFORM output_file USING interface_id
                            version
                            interface_definition-s1df-itype
                            sd_file_name.

* Berechtigung für UC4 ändern
  DATA: sd_file TYPE string.
  MOVE sd_file_name TO sd_file.
  CALL FUNCTION '/SIE/HR_I_CHMOD'
    EXPORTING
      iv_file = sd_file
      iv_mode = '0664'
* IMPORTING
*     ET_RETURN       =
    .

ENDFUNCTION.
