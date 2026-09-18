*---------------------------------------------------------------------*
*    generated viewmaintenance function pool top
*   generation date: 04.07.2001 at 13:03:32 by user MCH0341
*---------------------------------------------------------------------*
FUNCTION-POOL /SIE/HR_IDP_SE54           MESSAGE-ID SV.

TABLES: /SIE/HR_IDP_QVF1T
      , /SIE/HR_IDP_QF0T
      , T582S
      , T512T
      , T591S
      .

INCLUDE LSVIMDAT                                . "general data decl.
INCLUDE /SIE/LHR_IDP_SE54T00                    . "view rel. data dcl.
INCLUDE /SIE/LHR_IDP_SE54DLT.

INCLUDE <ICON>.

DATA: DOCU_BUTTON LIKE ICON.
