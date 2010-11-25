CREATE OR REPLACE PACKAGE BODY CDM.PX002_BUSQUEDA
AS
   NL_CHAR   CONSTANT CHAR (1) := '
';

   /*
           <link rel="stylesheet" type="text/css" href="/codebase/v2.css">
           <link rel="stylesheet" type="text/css" href="/codebase/style.css">
           <!--[if IE]>
               <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js" type="text/javascript"></script>
               <link rel="stylesheet" href="/codebase/style-ie.css" type="text/css" >
           <![endif]-->
           <!--[if IE 6]>
           <link rel="stylesheet" href="/codebase/style-ie6.css" type="text/css">
           <![endif]-->
           <script src="/codebase/js/top_menu.js" type="text/javascript"></script>
           <script src="/codebase/js/dhtmlxcommon.js" type="text/javascript"></script>

   */
   PROCEDURE php (p_NUHSA IN VARCHAR2 := '0', p_TIMESPAN IN VARCHAR2 := '1')
   /*
    Returns a XML file to format a gantt chart. All parameters are optional.
    curr:                   used to bypass the explorer cache, can be any value, usually a random number. It is not used in the code; if omitted takes the NULL value.
    p_ID_CHART:      used to select a record of the HTML_CHARTS table, the recor contains all the parameters to generate the chart. If omitted defaults to zero,
                              and returns a test chart.
   */
   IS
      v_NUHSA       VARCHAR2 (12);
      v_ganttdata   XMLTYPE := NULL;
      v_TIMESPAN    NUMBER;
   BEGIN
      /* Por si se ejecuta desde la línea del Explorer o desde javascript */
      IF INSTR (p_NUHSA, '?') > 0
      THEN
         v_NUHSA := UPPER (SUBSTR (p_NUHSA, 0, INSTR (p_NUHSA, '?') - 1));
      ELSE
         v_NUHSA := p_NUHSA;
      END IF;

      IF INSTR (p_TIMESPAN, '?') > 0
      THEN
         v_TIMESPAN := UPPER (SUBSTR (p_TIMESPAN, 0, INSTR (p_TIMESPAN, '?') - 1));
      ELSE
         v_TIMESPAN := p_TIMESPAN;
      END IF;

      /* Por si se ejecuta desde la línea del Explorer o desde javascript */

      SELECT XMLROOT (
                XMLELEMENT (
                   "projects",
                   --XMLELEMENT ("project"),
                   (  SELECT XMLAGG (
                                XMLELEMENT (
                                   "project",
                                   xmlattributes (a.admision_id AS "id",
                                                  DECODE (a.fch_admision_urgencias, NULL, uf.uf_nombre, 'Puerta de Urgencias.') AS "name",
                                                  TO_CHAR (NVL (a.fch_admision_urgencias, a.fch_ingreso), con_str_DATEFORMAT) AS "startdate"),
                                   XMLAGG (
                                      XMLELEMENT (
                                         "task",
                                         xmlattributes (t.traslado_id AS "id"),
                                         XMLELEMENT ("name",
                                                        t.observaciones
                                                     || ', '
                                                     || DECODE (t.cambio_asistencia_sn,  1, 'CAMBIO Asist. ',  0, NULL)
                                                     || (SELECT uf_nombre
                                                           FROM his_own.com_m_unidad_funcional@dae
                                                          WHERE uf_codigo = t.unidad_funcional)
                                                     || (SELECT ' (cama ' || ubi_nombre || ')'
                                                           FROM his_own.com_m_ubicacion@dae
                                                          WHERE ubi_codigo = t.ubic_terminal)),
                                         XMLELEMENT ("est", TO_CHAR (fch_apertura, con_str_DATEFORMAT)),
                                         XMLELEMENT (
                                            "duration",
                                            CEIL (
                                               ( (NVL (t.fch_cierre + (t.hora_cierre - TRUNC (t.hora_cierre)), SYSDATE))
                                                - (t.fch_apertura + (t.hora_apertura - TRUNC (t.hora_apertura))))
                                               * 8 /* 8 horas laborables al día */
                                                  )),
                                         XMLELEMENT ("percentcompleted", DECODE (t.ubic_terminal, NULL, 0, 100)),
                                         XMLELEMENT ("predecessortasks"),
                                         XMLELEMENT ("childtasks"))
                                      ORDER BY t.fch_apertura, t.hora_apertura)))
                        FROM his_own.adm_traslado@dae t
                             JOIN his_own.adm_admision@dae a
                                ON (admision = admision_id)
                             JOIN his_own.com_usuario@dae u
                                ON (usuario = id_usuario)
                             JOIN his_own.com_m_unidad_funcional@dae uf
                                ON (unid_func_ingreso = uf_codigo)
                       WHERE nuhsa = v_NUHSA AND a.fch_ingreso >= TRUNC (SYSDATE) - v_TIMESPAN AND a.epis_contab = 1 AND a.modalidad_asist = 1
                    GROUP BY admision_id,
                             uf.uf_nombre,
                             a.fch_ingreso,
                             a.fch_admision_urgencias)),
                VERSION '1.0" encoding="UTF-8')
        INTO v_ganttdata
        FROM DUAL;

      /*INSERTXMLBEFORE(XMLType_Instance>, <XPath_string>,<value_expression>, <namespace_string>)*/
      FOR c1
         IN (SELECT a.admision_id, (a.fch_admision_urgencias) fch_admision_urgencias
                   , (a.fch_alta_urgencias) fch_alta_urgencias
                   ,TO_DATE (TO_CHAR (a.fch_alta_urgencias, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS') - TO_DATE (TO_CHAR (a.fch_admision_urgencias, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS') urg_time
               FROM his_own.adm_admision@dae a JOIN his_own.com_usuario@dae u ON (usuario = id_usuario)
              WHERE u.nuhsa = v_NUHSA AND a.fch_ingreso >= TRUNC (SYSDATE) - 365 AND a.epis_contab = 1 AND a.modalidad_asist = 1)
      LOOP
         IF c1.fch_admision_urgencias IS NOT NULL
         THEN
            SELECT INSERTXMLBEFORE (v_ganttdata, '/projects/project[@id=' || c1.admision_id || ']/task[1]'
                  ,XMLELEMENT ("task", xmlattributes (c1.admision_id AS "id"), XMLELEMENT ("name", 'Urgencias'), XMLELEMENT ("est", TO_CHAR (c1.fch_admision_urgencias, con_str_DATEFORMAT)), XMLELEMENT ("duration", CEIL (c1.urg_time * 8)), XMLELEMENT ("percentcompleted", 0), XMLELEMENT ("predecessortasks"), XMLELEMENT ("childtasks")))
              INTO v_ganttdata
              FROM DUAL;
         END IF;
      END LOOP;

      streamdataset (v_ganttdata);
   EXCEPTION
      WHEN OTHERS
      THEN
         --         streamdataset (xmltype ('<error>' || SQLERRM || '</error>'));
         streamdataset (
            xmltype (
                  '<?xml version="1.0" encoding="UTF-8"?>
                                   <projects>
                                       <project id = "1" name = "'
               || SQLERRM
               || '" startdate = "2010,12,14">
                                       </project>
                                   </projects>
                                   '));
   END php;


   --   PROCEDURE xml (p_NUHSA IN VARCHAR2 := '0')
   --   /*
   --    Returns a XML file to format a gantt chart. All parameters are optional.
   --    curr:                   used to bypass the explorer cache, can be any value, usually a random number. It is not used in the code; if omitted takes the NULL value.
   --    p_ID_CHART:      used to select a record of the HTML_CHARTS table, the recor contains all the parameters to generate the chart. If omitted defaults to zero,
   --                              and returns a test chart.
   --   */
   --   IS
   --      v_NUHSA       VARCHAR2 (12);
   --      v_ganttdata   XMLTYPE := NULL;
   --   BEGIN
   --      /* Por si se ejecuta desde la línea del Explorer o desde javascript */
   --      IF INSTR (p_NUHSA, '?') > 0
   --      THEN
   --         v_NUHSA := UPPER (SUBSTR (p_NUHSA, 0, INSTR (p_NUHSA, '?') - 1));
   --      ELSE
   --         v_NUHSA := p_NUHSA;
   --      END IF;
   --
   --      /* Por si se ejecuta desde la línea del Explorer o desde javascript */
   --
   --      SELECT XMLROOT (
   --                XMLELEMENT (
   --                   "projects",
   --                   (  SELECT XMLAGG (
   --                                XMLELEMENT (
   --                                   "project",
   --                                   xmlattributes (a.admision_id AS "id", uf.uf_nombre AS "name", TO_CHAR (a.fch_ingreso, con_str_DATEFORMAT) AS "startdate"),
   --                                   XMLAGG (
   --                                      XMLELEMENT (
   --                                         "task",
   --                                         xmlattributes (t.traslado_id AS "id"),
   --                                         XMLELEMENT ("name",
   --                                                        t.observaciones
   --                                                     || ', '
   --                                                     || DECODE (t.cambio_asistencia_sn,  1, 'CAMBIO Asist. ',  0, NULL)
   --                                                     || (SELECT uf_nombre
   --                                                           FROM his_own.com_m_unidad_funcional@dae
   --                                                          WHERE uf_codigo = t.unidad_funcional)
   --                                                     || (SELECT ' (cama ' || ubi_nombre || ')'
   --                                                           FROM his_own.com_m_ubicacion@dae
   --                                                          WHERE ubi_codigo = t.ubic_terminal)),
   --                                         XMLELEMENT ("est", TO_CHAR (fch_apertura, con_str_DATEFORMAT)),
   --                                         XMLELEMENT (
   --                                            "duration",
   --                                            CEIL (
   --                                               ( (NVL (t.fch_cierre + (t.hora_cierre - TRUNC (t.hora_cierre)), SYSDATE))
   --                                                - (t.fch_apertura + (t.hora_apertura - TRUNC (t.hora_apertura))))
   --                                               * 8 /* 8 horas laborables al día */
   --                                                  )),
   --                                         XMLELEMENT ("percentcompleted", DECODE (t.fch_cierre, NULL, 99, 100)),
   --                                         XMLELEMENT ("predecessortasks"),
   --                                         XMLELEMENT ("childtasks"))
   --                                      ORDER BY t.fch_apertura, t.hora_apertura)))
   --                        FROM his_own.adm_traslado@dae t
   --                             JOIN his_own.adm_admision@dae a
   --                                ON (admision = admision_id)
   --                             JOIN his_own.com_usuario@dae u
   --                                ON (usuario = id_usuario)
   --                             JOIN his_own.com_m_unidad_funcional@dae uf
   --                                ON (unid_func_ingreso = uf_codigo)
   --                       WHERE nuhsa = v_NUHSA AND a.fch_ingreso >= TRUNC (SYSDATE) - 365 AND a.epis_contab = 1 AND a.modalidad_asist = 1
   --                    GROUP BY admision_id, uf.uf_nombre, a.fch_ingreso)),
   --                VERSION '1.0" encoding="UTF-8')
   --        INTO v_ganttdata
   --        FROM DUAL;
   --
   --      streamdataset (v_ganttdata);
   --   EXCEPTION
   --      WHEN OTHERS
   --      THEN
   --         --         streamdataset (xmltype ('<error>' || SQLERRM || '</error>'));
   --         streamdataset (
   --            xmltype ('<?xml version="1.0" encoding="UTF-8"?>
   --                                   <projects>
   --                                       <project id = "1" name = "' || SQLERRM || '" startdate = "2010,12,14">
   --                                       </project>
   --                                   </projects>
   --                                   '));
   --   END xml;

   PROCEDURE xml (p_NUHSA IN VARCHAR2 := '0', p_TIMESPAN IN VARCHAR2 := '1')
   /*
    Returns a XML file to format a gantt chart. All parameters are optional.
    curr:                   used to bypass the explorer cache, can be any value, usually a random number. It is not used in the code; if omitted takes the NULL value.
    p_ID_CHART:      used to select a record of the HTML_CHARTS table, the recor contains all the parameters to generate the chart. If omitted defaults to zero,
                              and returns a test chart.
   */
   IS
      v_NUHSA       VARCHAR2 (12);
      v_ganttdata   XMLTYPE := NULL;
      v_TIMESPAN    NUMBER;
   BEGIN
      /* Por si se ejecuta desde la línea del Explorer o desde javascript */
      IF INSTR (p_NUHSA, '?') > 0
      THEN
         v_NUHSA := UPPER (SUBSTR (p_NUHSA, 0, INSTR (p_NUHSA, '?') - 1));
      ELSE
         v_NUHSA := p_NUHSA;
      END IF;

      IF INSTR (p_TIMESPAN, '?') > 0
      THEN
         v_TIMESPAN := UPPER (SUBSTR (p_TIMESPAN, 0, INSTR (p_TIMESPAN, '?') - 1));
      ELSE
         v_TIMESPAN := p_TIMESPAN;
      END IF;

      /* Por si se ejecuta desde la línea del Explorer o desde javascript */

      SELECT XMLROOT (
                XMLELEMENT (
                   "projects",
                   --XMLELEMENT ("project"),
                   (  SELECT XMLAGG (
                                XMLELEMENT (
                                   "project",
                                   xmlattributes (a.admision_id AS "id",
                                                  DECODE (a.fch_admision_urgencias, NULL, uf.uf_nombre, 'Puerta de Urgencias.') AS "name",
                                                  TO_CHAR (NVL (a.fch_admision_urgencias, a.fch_ingreso), con_str_DATEFORMAT) AS "startdate"),
                                   XMLAGG (
                                      XMLELEMENT (
                                         "task",
                                         xmlattributes (t.traslado_id AS "id"),
                                         XMLELEMENT ("name",
                                                        t.observaciones
                                                     || ', '
                                                     || DECODE (t.cambio_asistencia_sn,  1, 'CAMBIO Asist. ',  0, NULL)
                                                     || (SELECT uf_nombre
                                                           FROM his_own.com_m_unidad_funcional@dae
                                                          WHERE uf_codigo = t.unidad_funcional)
                                                     || (SELECT ' (cama ' || ubi_nombre || ')'
                                                           FROM his_own.com_m_ubicacion@dae
                                                          WHERE ubi_codigo = t.ubic_terminal)),
                                         XMLELEMENT ("est", TO_CHAR (fch_apertura, con_str_DATEFORMAT)),
                                         XMLELEMENT (
                                            "duration",
                                            CEIL (
                                               ( (NVL (t.fch_cierre + (t.hora_cierre - TRUNC (t.hora_cierre)), SYSDATE))
                                                - (t.fch_apertura + (t.hora_apertura - TRUNC (t.hora_apertura))))
                                               * 8 /* 8 horas laborables al día */
                                                  )),
                                         XMLELEMENT ("percentcompleted", DECODE (t.ubic_terminal, NULL, 0, 100)),
                                         XMLELEMENT ("predecessortasks"),
                                         XMLELEMENT ("childtasks"))
                                      ORDER BY t.fch_apertura, t.hora_apertura)))
                        FROM his_own.adm_traslado@dae t
                             JOIN his_own.adm_admision@dae a
                                ON (admision = admision_id)
                             JOIN his_own.com_usuario@dae u
                                ON (usuario = id_usuario)
                             JOIN his_own.com_m_unidad_funcional@dae uf
                                ON (unid_func_ingreso = uf_codigo)
                       WHERE nuhsa = v_NUHSA AND a.fch_ingreso >= TRUNC (SYSDATE) - v_TIMESPAN AND a.epis_contab = 1 AND a.modalidad_asist = 1
                    GROUP BY admision_id,
                             uf.uf_nombre,
                             a.fch_ingreso,
                             a.fch_admision_urgencias)),
                VERSION '1.0" encoding="UTF-8')
        INTO v_ganttdata
        FROM DUAL;

      /*INSERTXMLBEFORE(XMLType_Instance>, <XPath_string>,<value_expression>, <namespace_string>)*/
      FOR c1
         IN (SELECT a.admision_id, (a.fch_admision_urgencias) fch_admision_urgencias
                   , (a.fch_alta_urgencias) fch_alta_urgencias
                   ,TO_DATE (TO_CHAR (a.fch_alta_urgencias, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS') - TO_DATE (TO_CHAR (a.fch_admision_urgencias, 'DD/MM/YYYY HH24:MI:SS'), 'DD/MM/YYYY HH24:MI:SS') urg_time
               FROM his_own.adm_admision@dae a JOIN his_own.com_usuario@dae u ON (usuario = id_usuario)
              WHERE u.nuhsa = v_NUHSA AND a.fch_ingreso >= TRUNC (SYSDATE) - 365 AND a.epis_contab = 1 AND a.modalidad_asist = 1)
      LOOP
         IF c1.fch_admision_urgencias IS NOT NULL
         THEN
            SELECT INSERTXMLBEFORE (v_ganttdata, '/projects/project[@id=' || c1.admision_id || ']/task[1]'
                  ,XMLELEMENT ("task", xmlattributes (c1.admision_id AS "id"), XMLELEMENT ("name", 'Urgencias'), XMLELEMENT ("est", TO_CHAR (c1.fch_admision_urgencias, con_str_DATEFORMAT)), XMLELEMENT ("duration", CEIL (c1.urg_time * 8)), XMLELEMENT ("percentcompleted", 0), XMLELEMENT ("predecessortasks"), XMLELEMENT ("childtasks")))
              INTO v_ganttdata
              FROM DUAL;
         END IF;
      END LOOP;

      streamdataset (v_ganttdata);
   EXCEPTION
      WHEN OTHERS
      THEN
         --         streamdataset (xmltype ('<error>' || SQLERRM || '</error>'));
         streamdataset (
            xmltype (
                  '<?xml version="1.0" encoding="UTF-8"?>
                                   <projects>
                                       <project id = "1" name = "'
               || SQLERRM
               || '" startdate = "2010,12,14">
                                       </project>
                                   </projects>
                                   '));
   END xml;


   PROCEDURE xml (p_ADMISION_ID IN VARCHAR2 := '0')
   /*
    Returns a XML file to format a gantt chart. All parameters are optional.
    curr:                   used to bypass the explorer cache, can be any value, usually a random number. It is not used in the code; if omitted takes the NULL value.
    p_ID_CHART:      used to select a record of the HTML_CHARTS table, the recor contains all the parameters to generate the chart. If omitted defaults to zero,
                              and returns a test chart.
   */
   IS
      v_ADMISION_ID   VARCHAR2 (12);
      v_ganttdata     XMLTYPE := NULL;
   BEGIN
      /* Por si se ejecuta desde la línea del Explorer o desde javascript */
      IF INSTR (p_ADMISION_ID, '?') > 0
      THEN
         v_ADMISION_ID := UPPER (SUBSTR (p_ADMISION_ID, 0, INSTR (p_ADMISION_ID, '?') - 1));
      ELSE
         v_ADMISION_ID := p_ADMISION_ID;
      END IF;

      SELECT XMLROOT (
                XMLELEMENT (
                   "projects",
                   (  SELECT XMLAGG (
                                XMLELEMENT (
                                   "project",
                                   xmlattributes (a.admision_id AS "id",
                                                     uf.uf_nombre
                                                  || ' ('
                                                  || DECODE (a.centro_ingreso,  10004, 'VALME',  10192, 'TOMILLAR')
                                                  || ') '
                                                  || DECODE (a.modalidad_asist,  1, ' Hosp. ',  2, ' HD ')
                                                  || DECODE (a.epis_contab,  1, NULL,  0, ' NO CONTAB. ')
                                                  || (SELECT 'NUHSA: ' || nuhsa
                                                        FROM his_own.com_usuario@dae
                                                       WHERE id_usuario = a.usuario) AS "name",
                                                  TO_CHAR (a.fch_ingreso, con_str_DATEFORMAT) AS "startdate"),
                                   XMLAGG (
                                      XMLELEMENT (
                                         "task",
                                         xmlattributes (t.traslado_id AS "id"),
                                         XMLELEMENT ("est", TO_CHAR (t.fch_apertura, con_str_DATEFORMAT)),
                                         XMLELEMENT (
                                            "duration",
                                            CEIL (
                                               ( (NVL (t.fch_cierre + (t.hora_cierre - TRUNC (t.hora_cierre)), SYSDATE))
                                                - (t.fch_apertura + (t.hora_apertura - TRUNC (t.hora_apertura))))
                                               * 8)),
                                         XMLELEMENT ("percentcompleted", DECODE (t.fch_cierre, NULL, 99, 100)),
                                         XMLELEMENT ("predecessortasks"),
                                         XMLELEMENT ("childtasks"),
                                         XMLELEMENT ("name",
                                                        (SELECT uf_nombre
                                                           FROM his_own.com_m_unidad_funcional@dae
                                                          WHERE uf_codigo = t.unidad_funcional)
                                                     || DECODE (t.ubic_terminal,
                                                                NULL, ' (sin cama). ',
                                                                (SELECT ' (cama ' || ubi_nombre || '). '
                                                                   FROM his_own.com_m_ubicacion@dae
                                                                  WHERE ubi_codigo = t.ubic_terminal))
                                                     || t.observaciones
                                                     || ', '
                                                     || DECODE (t.cambio_asistencia_sn,  1, 'CAMBIO Asist. ',  0, NULL)))
                                      ORDER BY t.fch_apertura, t.hora_apertura)))
                        FROM his_own.adm_traslado@dae t
                             JOIN his_own.adm_admision@dae a
                                ON (admision = admision_id)
                             JOIN his_own.com_m_unidad_funcional@dae uf
                                ON (unid_func_ingreso = uf_codigo)
                       WHERE t.admision = v_ADMISION_ID
                    --AND modalidad_asist = 1
                    --AND epis_contab = 1
                    --AND t.cambio_asistencia_sn = 1
                    GROUP BY a.usuario,
                             a.admision_id,
                             a.centro_ingreso,
                             uf.uf_nombre,
                             a.fch_ingreso,
                             a.modalidad_asist,
                             a.epis_contab)),
                VERSION '1.0" encoding="UTF-8')
        INTO v_ganttdata
        FROM DUAL;

      streamdataset (v_ganttdata);
   EXCEPTION
      WHEN OTHERS
      THEN
         streamdataset (
            xmltype (
                  '<?xml version="1.0" encoding="UTF-8"?>
                                   <projects>
                                       <project id = "1" name = "'
               || SQLERRM
               || '" startdate = "2010,12,14">
                                       </project>
                                   </projects>
                                   '));
   END xml;

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
         DBMS_LOB.read (v_doc_clob, l_amount, l_offset, l_buffer);
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
END PX002_BUSQUEDA;
/
