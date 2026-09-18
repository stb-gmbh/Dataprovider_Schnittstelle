*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_IFC_INFOF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  IFC_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_INTERFACE  text
*      <--P_VERSION  text
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
