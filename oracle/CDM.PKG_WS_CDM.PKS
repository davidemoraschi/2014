CREATE OR REPLACE PACKAGE CDM.pkg_ws_cdm
AS
   PROCEDURE ws001_lista_servicios (p_quieneres IN VARCHAR2, p_resultado OUT XMLTYPE);

   FUNCTION gen_xml_from_refcursor (rf IN SYS_REFCURSOR)
      RETURN XMLTYPE;

   PROCEDURE start_up (p_quieneres IN VARCHAR2);
END pkg_ws_cdm;
/
