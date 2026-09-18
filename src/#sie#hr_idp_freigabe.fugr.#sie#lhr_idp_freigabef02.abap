*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_FREIGABEF02 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  IFC_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_INTERFACE  text
*      <--P_CRC  text
*----------------------------------------------------------------------*
FORM IFC_CHECK USING   P_TEST TYPE C
               CHANGING P_INTERFACE TYPE /SIE/HR_IDP_IFC_DB
                        P_VRSNR TYPE /SIE/HR_IDP_VERS_NR
                        P_CRC TYPE TY_YESNO.

  DATA: RC TYPE SYSUBRC.

  CALL FUNCTION '/SIE/HR_IDP_IFC_CHECK'
       EXPORTING
            IFCID           = P_INTERFACE-S1-IFCID
            SW_WITH_RELEASE = YES
            SW_TEST         = P_TEST
       IMPORTING
            SUBRC           = RC
       CHANGING
            INTERFACE       = P_INTERFACE
            VERSION         = P_VRSNR.
* Hier fehlen noch exceptions
  IF RC = 0.
    P_CRC = YES.
  ELSE.
    P_CRC = NO.
  ENDIF.

ENDFORM.                    " IFC_CHECK

*&---------------------------------------------------------------------*
*&      Form  IFC_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_INTERFACE  text
*      <--P_DBSEL  text
*----------------------------------------------------------------------*
FORM IFC_READ CHANGING P_INTERFACE TYPE /SIE/HR_IDP_IFC_DB
                       P_VRSNR TYPE /SIE/HR_IDP_VERS_NR
                       P_DBSEL TYPE /SIE/HR_IDP_DB_SEL.

  CALL FUNCTION '/SIE/HR_IDP_DB_READ'
       EXPORTING
            INTERFACE        = P_INTERFACE-S1-IFCID
            VERSION          = P_VRSNR
       CHANGING
            TRANSACTION_DATA = P_INTERFACE
            DBSEL            = P_DBSEL.
  .

ENDFORM.                    " IFC_READ

*&---------------------------------------------------------------------*
*&      Form  IFC_RELEASE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_INTERFACE  text
*----------------------------------------------------------------------*
FORM IFC_RELEASE CHANGING P_INTERFACE.

ENDFORM.                    " IFC_RELEASE
*&---------------------------------------------------------------------*
*&      Form  IFC_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_INTERFACE  text
*      <--P_DBSEL  text
*----------------------------------------------------------------------*
FORM IFC_SAVE CHANGING P_INTERFACE TYPE /SIE/HR_IDP_IFC_DB
                       P_VRSNR TYPE /SIE/HR_IDP_VERS_NR
                       P_DBSEL TYPE /SIE/HR_IDP_DB_SEL.

  CALL FUNCTION '/SIE/HR_IDP_DB_UPDATE'
       EXPORTING
            INTERFACE        = P_INTERFACE-S1-IFCID
            VERSION          = P_VRSNR
            SW_COMMIT_WORK   = YES
       CHANGING
            TRANSACTION_DATA = P_INTERFACE
            DBSEL            = P_DBSEL.

ENDFORM.                    " IFC_SAVE

*&---------------------------------------------------------------------*
*&      Form  IFC_REFRESH_REFERENCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_INTERFACE  text
*      <--P_DBSEL  text
*----------------------------------------------------------------------*
FORM IFC_REFRESH_REFERENCE CHANGING P_INTERFACE TYPE /SIE/HR_IDP_IFC_DB.

   CALL FUNCTION '/SIE/HR_IDP_REFRESH_REFERENCE'
     changing
       transaction_data        = p_interface
     EXCEPTIONS
       NO_ACTIVE_VERSION       = 1
       OTHERS                  = 2
             .
   IF sy-subrc <> 0.
      MESSAGE i452.
   ENDIF.

ENDFORM.                    " REFRESH_REFERENCE

*&---------------------------------------------------------------------*
*&      Form  IFC_CURR_VERS
*&---------------------------------------------------------------------*
*       Liest die aktuelle Version einer Schnittstelle ein
*----------------------------------------------------------------------*
FORM IFC_CURR_VERS USING    P_IFCID TYPE /SIE/HR_IDP_INTERFACE_ID
                   CHANGING P_CRC TYPE X
                            P_VERSION TYPE /SIE/HR_IDP_VERS_NR.
  SELECT MAX( VRSNR ) FROM /SIE/HR_IDP_S1VN
                      INTO P_VERSION
                      WHERE IFCID = P_IFCID.
  IF SY-SUBRC NE 0.
    P_CRC = 8.
    CLEAR P_VERSION.
  ELSE.
    P_CRC = 0.
  ENDIF.


ENDFORM.                    " IFC_CURR_VERS

*&---------------------------------------------------------------------*
*&      Form  DEQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IFCID  text
*----------------------------------------------------------------------*
FORM DEQUEUE USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID.

  CALL FUNCTION 'DEQUEUE_/SIE/HR_IDPIFCID'
       EXPORTING
            MODE_/SIE/HR_IDP_S1 = 'E'
            MANDT               = SY-MANDT
            IFCID               = P_IFCID
            _SYNCHRON           = YES.

ENDFORM.                    " DEQUEUE

*&---------------------------------------------------------------------*
*&      Form  ENQUEUE
*&---------------------------------------------------------------------*
*       Sperren der selektierten Schnittstelle
*----------------------------------------------------------------------*
FORM ENQUEUE USING VALUE(P_IFCID) TYPE /SIE/HR_IDP_INTERFACE_ID
             CHANGING RC TYPE X.

  DATA: XUNAME LIKE SY-UNAME.

  CALL FUNCTION 'ENQUEUE_/SIE/HR_IDPIFCID'
       EXPORTING
            MODE_/SIE/HR_IDP_S1 = 'E'
            MANDT               = SY-MANDT
            IFCID               = P_IFCID
       EXCEPTIONS
            FOREIGN_LOCK        = 1
            SYSTEM_FAILURE      = 2
            OTHERS              = 3.
  CASE SY-SUBRC.
    WHEN 0.
      RC = 0.
    WHEN 1.
* Überprüfen, ob der Benutzer sich selbst sperrt oder nicht.
      IF SY-MSGV1 = SY-UNAME.
        MESSAGE S106 WITH SY-MSGV1 SPACE SPACE SPACE
                        RAISING ENQUEUE.
      ELSE.
        XUNAME = SY-MSGV1.
        MESSAGE S105 WITH TEXT-902 P_IFCID XUNAME SPACE
                        RAISING ENQUEUE.
      ENDIF.
    WHEN OTHERS.
      XUNAME = SY-MSGV1.
      MESSAGE S105 WITH TEXT-902 P_IFCID SY-MSGV1 SPACE
                      RAISING ENQUEUE.
  ENDCASE.
ENDFORM.                    " ENQUEUE

*&---------------------------------------------------------------------*
*&      Form  RELEASE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM RELEASE.

ENDFORM.                    " RELEASE
*&---------------------------------------------------------------------*
*&      Form  SHOW_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SHOW_LOG.

ENDFORM.                    " SHOW_LOG
