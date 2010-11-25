CREATE OR REPLACE PACKAGE BODY CDM.pkg_ws_cdm
AS
   PROCEDURE ws001_lista_servicios (p_quieneres IN VARCHAR2, p_resultado OUT XMLTYPE) --, p_campos OUT VARCHAR2)
   IS
      c1   SYS_REFCURSOR;
   BEGIN
      start_up (p_quieneres);
      DBMS_APPLICATION_INFO.set_action (action_name => 'Devuelve lista de unidades funcionales');

      OPEN c1 FOR SELECT * FROM VW_MAPA_04_UNID_FUNCIONALES;

      p_resultado := gen_xml_from_refcursor (c1);
   END ws001_lista_servicios;

   FUNCTION gen_xml_from_refcursor (rf IN SYS_REFCURSOR)
      RETURN XMLTYPE
   AS
      lxmldata   XMLTYPE;
      lcontext   DBMS_XMLGEN.ctxhandle;
   BEGIN
      DBMS_APPLICATION_INFO.set_action (action_name => 'Transforma un refcursor en un ROWSET xml');
      lcontext := DBMS_XMLGEN.newcontext (rf);
      -- setNullHandling to 1 (or 2) to allow null columns
      -- to be displayed
      DBMS_XMLGEN.setnullhandling (lcontext, 1);
      DBMS_XMLGEN.setrowsettag (lcontext, 'table');
      DBMS_XMLGEN.setrowtag (lcontext, 'row');
      lxmldata := DBMS_XMLGEN.getxmltype (lcontext, DBMS_XMLGEN.NONE);
      DBMS_XMLGEN.closecontext (lcontext);
      RETURN NVL (lxmldata, XMLTYPE ('<ERROR>La consulta no ha devuelto datos</ERROR>'));
   END gen_xml_from_refcursor;

   PROCEDURE start_up (p_quieneres IN VARCHAR2)
   IS
   BEGIN
      DBMS_APPLICATION_INFO.set_module (module_name => 'Web Service para CDM', action_name => 'inicio');
      DBMS_APPLICATION_INFO.set_client_info (client_info => p_quieneres);
   END start_up;
END pkg_ws_cdm;
/
