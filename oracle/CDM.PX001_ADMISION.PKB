CREATE OR REPLACE PACKAGE BODY CDM.px001_admision
AS
   NL_CHAR   CONSTANT CHAR (1) := '
';

   PROCEDURE xml (curr VARCHAR2 := NULL, p_ID_CHART IN NUMBER := 0)
   /*
    Returns a XML file to format a SWF chart. All parameters are optional.
    curr:                   used to bypass the explorer cache, can be any value, usually a random number. It is not used in the code; if omitted takes the NULL value.
    p_ID_CHART:      used to select a record of the HTML_CHARTS table, the recor contains all the parameters to generate the chart. If omitted defaults to zero,
                              and returns a test chart.
   */
   IS
      v_chartdata   XMLTYPE := NULL;
   BEGIN
      v_chartdata :=
         XMLTYPE (
            '
                        <chart>
                          <chart_type>bar</chart_type>
                          <chart_border top_thickness=''0'' bottom_thickness=''1'' left_thickness=''0'' right_thickness=''1'' color=''6D7B8D'' />
                          <chart_data>
                            <row>
                              <null/>
                              <string>2006</string>
                              <string>2007</string>
                              <string>2008</string>
                              <string>2009</string>
                            </row>
                            <row>
                              <string>Region A</string>
                              <number>5</number>
                              <number>10</number>
                              <number>30</number>
                              <number>63</number>
                            </row>
                            <row>
                              <string>Region B</string>
                              <number>100</number>
                              <number>20</number>
                              <number>65</number>
                              <number>55</number>
                            </row>
                            <row>
                              <string>Region D</string>
                              <number>56</number>
                              <number>21</number>
                              <number>5</number>
                              <number>99</number>
                            </row>
                          </chart_data>

                        </chart>
                        ');

      IF p_ID_CHART = 0
      THEN
         /* returns a test chart */
         streamdataset (v_chartdata);
      ELSE
         /* returns the chart identified by the p_ID_CHART in the HTML_CHARTS table */
         streamdataset (gen_chart_xml_from_view (p_ID_CHART));
      END IF;
   END xml;

   FUNCTION gen_xml_from_sysref (rf IN SYS_REFCURSOR, p_chart_type IN VARCHAR2 := 'column')
      RETURN XMLTYPE
   AS
      lhtmloutput   XMLTYPE;
      lxsl          LONG;
      lxmldata      XMLTYPE;
      lcontext      DBMS_XMLGEN.ctxhandle;
   BEGIN
      lcontext := DBMS_XMLGEN.newcontext (rf);
      -- setNullHandling to 1 (or 2) to allow null columns
      -- to be displayed
      DBMS_XMLGEN.setnullhandling (lcontext, 1);
      -- set the name of rowset to be chart_data
      DBMS_XMLGEN.setrowsettag (lcontext, 'chart_data');
      -- set the name of row to be row
      DBMS_XMLGEN.setrowtag (lcontext, 'row');

      SELECT XMLELEMENT (
                "chart",
                XMLELEMENT ("chart_rect", xmlattributes (200 AS "x", '250' AS "width")),
                XMLELEMENT ("series_color", XMLELEMENT ("color", 'FF9966'), XMLELEMENT ("color", '0099CC')),
                XMLELEMENT ("axis_category", xmlattributes ('false' AS "bold", 11 AS "size")),
                XMLELEMENT ("legend",
                            xmlattributes ('false' AS "bold",
                                           12 AS "size",
                                           200 AS "x",
                                           250 AS "width")),
                XMLELEMENT ("update", xmlattributes ('/cdm_dad/PX001_admision.xml?curr=' || TO_CHAR (SYSDATE, 'HH24MISS') AS "url", 1 AS "delay")),
                XMLELEMENT ("chart_type", p_chart_type),
                XMLELEMENT ("chart_border", xmlattributes (1 AS "bottom_thickness", 1 AS "right_thickness", '6D7B8D' AS "color")),
                XMLELEMENT ("chart_data",
                            XMLELEMENT ("row", XMLELEMENT ("null"), XMLAGG (SYS_XMLGEN (unidad_funcional, xmlformat.createformat ('string')))),
                            XMLELEMENT ("row", XMLELEMENT ("string", 'INGRESOS'), XMLAGG (SYS_XMLGEN (NVL (ingresos, 0), xmlformat.createformat ('number')))),
                            XMLELEMENT ("row", XMLELEMENT ("string", 'ALTAS'), XMLAGG (SYS_XMLGEN (NVL (altas, 0), xmlformat.createformat ('number')))),
                            XMLELEMENT ("row", XMLELEMENT ("string", 'SEC'), XMLAGG (SYS_XMLGEN (TO_CHAR (SYSDATE, 'SS'), xmlformat.createformat ('number'))))))
        INTO lxmldata
        FROM gc_mv_0002;

      DBMS_XMLGEN.closecontext (lcontext);
      RETURN lxmldata;
   END gen_xml_from_sysref;

   FUNCTION gen_xml_from_sysref (p_view_name IN VARCHAR2 := 'DUAL', p_chart_type IN VARCHAR2 := 'column')
      RETURN XMLTYPE
   AS
      --      lhtmloutput   XMLTYPE;
      --      lxsl          LONG;
      lxmldata         XMLTYPE;
      lxmlfirstrow     XMLTYPE;
      lxmlotherrows    XMLTYPE;
      lxmltemp         XMLTYPE;
      --      lcontext      DBMS_XMLGEN.ctxhandle;
      --      v_rec_count      NUMBER;
      --      v_select         VARCHAR2 (1024);
      v_view_name      VARCHAR2 (50);

      TYPE typ_column_names IS TABLE OF USER_TAB_COLUMNS.TABLE_NAME%TYPE;

      t_column_names   typ_column_names;
   BEGIN
      --lcontext := DBMS_XMLGEN.newcontext (rf);
      -- setNullHandling to 1 (or 2) to allow null columns
      -- to be displayed
      --DBMS_XMLGEN.setnullhandling (lcontext, 1);
      -- set the name of rowset to be chart_data
      --DBMS_XMLGEN.setrowsettag (lcontext, 'chart_data');
      -- set the name of row to be row
      --DBMS_XMLGEN.setrowtag (lcontext, 'row');
      v_view_name := UPPER (p_view_name);

      EXECUTE IMMEDIATE 'SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = :b_view_name ORDER BY COLUMN_ID'
         BULK COLLECT INTO t_column_names
         USING v_view_name;

      EXECUTE IMMEDIATE
            'SELECT XMLELEMENT("row", XMLCONCAT (XMLELEMENT ("null"), XMLAGG (SYS_XMLGEN ('
         || t_column_names (1)
         || ', xmlformat.createformat (''string''))))) FROM '
         || v_view_name
         INTO lxmlfirstrow;

      FOR r IN 2 .. t_column_names.LAST
      LOOP
         SELECT XMLELEMENT ("row", XMLELEMENT ("string", 'INGRESOS'), XMLAGG (SYS_XMLGEN (NVL (ingresos, 0), xmlformat.createformat ('number'))))
           INTO lxmltemp
           FROM gc_mv_0002;

         SELECT XMLCONCAT (lxmlotherrows, lxmltemp) INTO lxmlotherrows FROM DUAL;
      --lxmlotherrows :=lxmlotherrows+ lxmltemp;
      END LOOP;

      --      SELECT XMLELEMENT (
      --                "chart",
      --                XMLELEMENT ("chart_rect", xmlattributes (200 AS "x", '250' AS "width")),
      --                XMLELEMENT ("series_color", XMLELEMENT ("color", 'FF9966'), XMLELEMENT ("color", '0099CC')),
      --                XMLELEMENT ("axis_category", xmlattributes ('false' AS "bold", 11 AS "size")),
      --                XMLELEMENT ("legend", xmlattributes ('false' AS "bold",
      --                                                     12 AS "size",
      --                                                     200 AS "x",
      --                                                     250 AS "width")),
      --                XMLELEMENT ("update", xmlattributes ('/cdm_dad/PX001_admision.xml?curr=' || TO_CHAR (SYSDATE, 'HH24MISS') AS "url", 1 AS "delay")),
      --                XMLELEMENT ("chart_type", p_chart_type),
      --                XMLELEMENT ("chart_border", xmlattributes (1 AS "bottom_thickness", 1 AS "right_thickness", '6D7B8D' AS "color")),
      --                XMLELEMENT ("chart_data",
      --                            XMLELEMENT ("row", XMLELEMENT ("null"), XMLAGG (SYS_XMLGEN (unidad_funcional, xmlformat.createformat ('string')))),
      --                            XMLELEMENT ("row", XMLELEMENT ("string", 'INGRESOS'), XMLAGG (SYS_XMLGEN (NVL (ingresos, 0), xmlformat.createformat ('number')))),
      --                            XMLELEMENT ("row", XMLELEMENT ("string", 'ALTAS'), XMLAGG (SYS_XMLGEN (NVL (altas, 0), xmlformat.createformat ('number')))),
      --                            XMLELEMENT ("row", XMLELEMENT ("string", 'SEC'), XMLAGG (SYS_XMLGEN (TO_CHAR (SYSDATE, 'SS'), xmlformat.createformat ('number'))))))
      --        INTO lxmldata
      --        FROM gc_mv_0002;
      --
      --DBMS_XMLGEN.closecontext (lcontext);
      SELECT XMLELEMENT ("chart", XMLELEMENT ("chart_type", p_chart_type), XMLELEMENT ("chart_data", XMLCONCAT (lxmlfirstrow, lxmlotherrows)))
        INTO lxmldata
        FROM DUAL;

      RETURN lxmldata;
   END gen_xml_from_sysref;

   FUNCTION gen_chart_xml_from_view (p_ID_CHART IN NUMBER)
      RETURN XMLTYPE
   /*
    Generate and returns a XML file to format a SWF chart. Reads info from the table HTML_CHARTS. Should not be called directly.
    p_ID_CHART:      used to select a record of the HTML_CHARTS table, the recor contains all the parameters to generate the chart. If omitted defaults to zero.

   */
   AS
      lxmldata         XMLTYPE;
      lxmlfirstrow     XMLTYPE;
      lxmlotherrows    XMLTYPE;
      lxmltemp         XMLTYPE;
      v_SOURCE_VIEW    HTML_CHARTS.SOURCE_VIEW%TYPE;
      v_TYPE_CHART     HTML_CHARTS.TYPE_CHART%TYPE;
      v_SIZEX_CHART    HTML_CHARTS.POSX_CHART%TYPE;
      v_SIZEY_CHART    HTML_CHARTS.WIDTH_CHART%TYPE;


      TYPE typ_column_names IS TABLE OF USER_TAB_COLUMNS.TABLE_NAME%TYPE;

      t_column_names   typ_column_names;
   BEGIN
      SELECT SOURCE_VIEW,
             TYPE_CHART,
             POSX_CHART,
             WIDTH_CHART
        INTO v_SOURCE_VIEW,
             v_TYPE_CHART,
             v_SIZEX_CHART,
             v_SIZEY_CHART
        FROM HTML_CHARTS
       WHERE ID_CHART = p_ID_CHART;


      EXECUTE IMMEDIATE 'SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = :b_view_name ORDER BY COLUMN_ID'
         BULK COLLECT INTO t_column_names
         USING v_SOURCE_VIEW;


      EXECUTE IMMEDIATE
            'SELECT XMLELEMENT("row", XMLCONCAT (XMLELEMENT ("null"), XMLAGG (SYS_XMLGEN ('
         || t_column_names (1)
         || ', xmlformat.createformat (''string''))))) FROM '
         || v_SOURCE_VIEW
         INTO lxmlfirstrow;


      FOR r IN 2 .. t_column_names.LAST
      LOOP
         EXECUTE IMMEDIATE
               'SELECT XMLELEMENT ("row", XMLELEMENT ("string", :t), XMLAGG (SYS_XMLGEN (NVL ('
            || t_column_names (r)
            || ', 0), xmlformat.createformat (''number''))))
                      FROM '
            || v_SOURCE_VIEW
            INTO lxmltemp
            USING t_column_names (r);

         SELECT XMLCONCAT (lxmlotherrows, lxmltemp) INTO lxmlotherrows FROM DUAL;
      END LOOP;

      /* FOR DEBUGGING PURPOSES TO BE REMOVED ON RELEASE
      EXECUTE IMMEDIATE
         'SELECT XMLELEMENT ("row", XMLELEMENT ("string", ''SEC''), XMLAGG (SYS_XMLGEN (TO_CHAR(SYSDATE,''SS''), xmlformat.createformat (''number'')))) FROM '
         || v_SOURCE_VIEW
         INTO lxmltemp;

      SELECT XMLCONCAT (lxmlotherrows, lxmltemp) INTO lxmlotherrows FROM DUAL;

      FOR DEBUGGING PURPOSES TO BE REMOVED ON RELEASE */

      SELECT XMLELEMENT (
                "chart",
                XMLELEMENT (
                   "update",
                   xmlattributes ('/cdm_dad/PX001_admision.xml?p_ID_CHART=' || p_ID_CHART || '&curr=' || TO_CHAR (SYSDATE, 'HH24MISS') AS "url", 60 AS "delay")),
                CASE WHEN (v_SIZEX_CHART IS NOT NULL AND v_SIZEY_CHART IS NOT NULL) THEN
                     XMLELEMENT ("chart_rect", xmlattributes (v_SIZEX_CHART AS "x", v_SIZEY_CHART AS "width"))
                ELSE
                    NULL
                END,
                XMLELEMENT ("chart_type", v_TYPE_CHART),
                XMLELEMENT ("chart_border", xmlattributes (1 AS "bottom_thickness", 1 AS "right_thickness", '6D7B8D' AS "color")),
                XMLELEMENT ("axis_value", xmlattributes ('false' AS "bold", 11 AS "size")),
                XMLELEMENT ("axis_category", xmlattributes ('false' AS "bold", 11 AS "size")),
                XMLELEMENT ("legend", xmlattributes ('false' AS "bold", 12 AS "size")),
                XMLELEMENT ("series_color", XMLELEMENT ("color", 'FF9966'), XMLELEMENT ("color", '0099CC')),
                XMLELEMENT ("chart_data", XMLCONCAT (lxmlfirstrow, lxmlotherrows)))
        INTO lxmldata
        FROM DUAL;


      RETURN lxmldata;
   END gen_chart_xml_from_view;

   PROCEDURE streamDataSet (p_data_set XMLTYPE := NULL)
   IS
      v_data_blob    BLOB := NULL;

      v_doc_clob     CLOB := p_data_set.getClobVal ();

      l_blob         BLOB;
      l_clob         CLOB;
      l_len          NUMBER;
      l_offset       NUMBER := 1;
      l_amount       NUMBER := 16000;
      l_buffer       VARCHAR2 (32767);
      l_buffer_raw   RAW (32767);
   BEGIN
      DBMS_LOB.createTemporary (v_data_blob, FALSE, DBMS_LOB.CALL);

      --     FOR pos IN 1 .. dbms_lob.getLength(v_doc_clob) LOOP
      --      DBMS_LOB.writeappend(v_data_blob,1,utl_raw.cast_to_raw(substr(v_doc_clob,pos,1)));
      --   END LOOP;

      l_len := DBMS_LOB.getlength (v_doc_clob);
      l_offset := 1;

      WHILE l_offset < l_len
      LOOP
         DBMS_LOB.read (v_doc_clob,
                        l_amount,
                        l_offset,
                        l_buffer);
         l_buffer_raw := UTL_RAW.cast_to_raw (l_buffer);
         DBMS_LOB.writeappend (v_data_blob, UTL_RAW.LENGTH (l_buffer_raw), l_buffer_raw);

         l_offset := l_offset + l_amount;

         IF l_len - l_offset < 16000
         THEN
            l_amount := l_len - l_offset;
         END IF;
      END LOOP;

      -- Prepare Headers
      OWA_UTIL.mime_header ('text/xml', FALSE);
      HTP.p ('Content-Length: ' || DBMS_LOB.getLength (v_data_blob) || NL_CHAR);
      OWA_UTIL.http_header_close;
      --Download Data

      WPG_DOCLOAD.download_file (v_data_blob);
   END streamDataSet;
END;
/
