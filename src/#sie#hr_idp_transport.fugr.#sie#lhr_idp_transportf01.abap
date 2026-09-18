*----------------------------------------------------------------------*
***INCLUDE /SIE/LHR_IDP_TRANSPORTF01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FILL_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_EVENTS  text
*----------------------------------------------------------------------*
FORM FILL_EVENTS CHANGING P_T_EVENTS TYPE T_XML_EVENT.

  DATA: LS_XML_EVENT TYPE S_XML_EVENT.

  DEFINE REGISTER_EVENT.
    CLEAR LS_XML_EVENT.
    LS_XML_EVENT-EVENT = &1.
    LS_XML_EVENT-CALLBACK_FORM = &2.
    APPEND LS_XML_EVENT TO P_T_EVENTS.
  END-OF-DEFINITION.

  REGISTER_EVENT: '<layout>' 'cb_layout'
                , '<recordtype>' 'cb_recordt'
                , '<field>' 'cb_field'
                .

ENDFORM.                    " FILL_EVENTS
