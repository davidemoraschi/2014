CREATE OR REPLACE PACKAGE CDM.px001_admision
AS
   /* NOTE you must include curr as a parameter option. */
   PROCEDURE xml (curr VARCHAR2 := NULL, p_ID_CHART IN NUMBER := 0);

   FUNCTION gen_xml_from_sysref (rf IN SYS_REFCURSOR, p_chart_type IN VARCHAR2 := 'column')
      RETURN XMLTYPE;

   FUNCTION gen_xml_from_sysref (p_view_name IN VARCHAR2 := 'DUAL', p_chart_type IN VARCHAR2 := 'column')
      RETURN XMLTYPE;

   FUNCTION gen_chart_xml_from_view (p_ID_CHART IN NUMBER := 0)
      RETURN XMLTYPE;

   PROCEDURE streamDataSet (p_data_set XMLTYPE := NULL);
END;
/
