CREATE OR REPLACE PACKAGE BODY CDM.MicroStrategyWS
AS
   NL_CHAR   CONSTANT CHAR (1) := '
';

   /******************************************************************************
      NAME:       MicroStrategyWS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        22/11/2010      Davide       1. Created this package body.
   ******************************************************************************/

   FUNCTION TestService (pServer IN VARCHAR2, pProjectName IN VARCHAR2, pLogin IN VARCHAR2, pPassword IN VARCHAR2)
      RETURN XMLTYPE
   IS
   BEGIN
      soap_request :=
         XMLTYPE (
            '<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <TestService xmlns="http://microstrategy.com/webservices/v1_0">
              <Server>'
            || pServer
            || '</Server>
              <ProjectName>'
            || pProjectName
            || '</ProjectName>
              <Login>'
            || pLogin
            || '</Login>
              <Password>'
            || pPassword
            || '</Password>
            </TestService>
          </soap:Body>
        </soap:Envelope> ');
      http_req := UTL_HTTP.begin_request ('http://deotila/MicroStrategyWS/MSTRWS.asmx', 'POST', 'HTTP/1.1');
      --UTL_HTTP.set_authentication (http_req, con_str_http_cueserval, con_str_http_cueserval_pw, 'Basic', FALSE);
      UTL_HTTP.set_header (http_req, 'Content-Type', 'text/xml; charset=utf-8');
      UTL_HTTP.set_header (http_req, 'Content-Length', LENGTH (soap_request.getstringval ()));
      UTL_HTTP.set_header (http_req, 'SOAPAction', '"http://microstrategy.com/webservices/v1_0/TestService"');
      UTL_HTTP.write_text (http_req, soap_request.getstringval ());
      http_resp := UTL_HTTP.get_response (http_req);

      BEGIN
        <<read_response_loop>>
         LOOP
            UTL_HTTP.read_line (r => http_resp, DATA => var_http_value, remove_crlf => TRUE);
            var_http_ret_val := var_http_ret_val || var_http_value;
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (r => http_resp);
      END;

      RETURN XMLTYPE (var_http_ret_val).EXTRACT ('/soap:Envelope/soap:Body/child::node()'
            ,'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"');
   END TestService;

   PROCEDURE TestService
   IS
   BEGIN
      soap_request :=
         XMLTYPE (
            '<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <TestService xmlns="http://microstrategy.com/webservices/v1_0">
              <Server>'
            || 'fraterno'
            || '</Server>
              <ProjectName>'
            || 'AGD'
            || '</ProjectName>
              <Login>'
            || 'IUSR_WEBSERVICE'
            || '</Login>
              <Password>'
            || MSTR_PASSWORD
            || '</Password>
            </TestService>
          </soap:Body>
        </soap:Envelope> ');
      http_req := UTL_HTTP.begin_request ('http://deotila/MicroStrategyWS/MSTRWS.asmx', 'POST', 'HTTP/1.1');
      --UTL_HTTP.set_authentication (http_req, con_str_http_cueserval, con_str_http_cueserval_pw, 'Basic', FALSE);
      UTL_HTTP.set_header (http_req, 'Content-Type', 'text/xml; charset=utf-8');
      UTL_HTTP.set_header (http_req, 'Content-Length', LENGTH (soap_request.getstringval ()));
      UTL_HTTP.set_header (http_req, 'SOAPAction', '"http://microstrategy.com/webservices/v1_0/TestService"');
      UTL_HTTP.write_text (http_req, soap_request.getstringval ());
      http_resp := UTL_HTTP.get_response (http_req);

      BEGIN
        <<read_response_loop>>
         LOOP
            UTL_HTTP.read_line (r => http_resp, DATA => var_http_value, remove_crlf => TRUE);
            var_http_ret_val := var_http_ret_val || var_http_value;
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (r => http_resp);
      END;

      OWA_UTIL.mime_header ('text/xml', TRUE);

      HTP.p (var_http_ret_val);
   --      RETURN XMLTYPE (var_http_ret_val).EXTRACT ('/soap:Envelope/soap:Body/child::node()'
   --            ,'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"');
   EXCEPTION
      WHEN OTHERS
      THEN
         OWA_UTIL.mime_header ('text/html', TRUE);
         HTP.p (SQLERRM || '<hr>');
         HTP.p (DBMS_UTILITY.format_error_backtrace);
         OWA_UTIL.SIGNATURE;
   END TestService;

   FUNCTION iServerConnect (pServer IN VARCHAR2, pProjectName IN VARCHAR2, pLogin IN VARCHAR2, pPassword IN VARCHAR2)
      RETURN XMLTYPE
   IS
      v_ultima_transaccion   LOG_MICROSTRATEGY.ID_ULTIMA_TRANSACCION%TYPE;
   BEGIN
      soap_request :=
         XMLTYPE (
            '<?xml version="1.0" encoding="utf-8"?>
            <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <Connect xmlns="http://microstrategy.com/webservices/v1_0">
                  <cInfo>
              <Login>'
            || pLogin
            || '</Login>
              <Password>'
            || pPassword
            || '</Password>
              <ProjectName>'
            || pProjectName
            || '</ProjectName>
                    <ProjectSource>'
            || pServer
            || '</ProjectSource>
                     <AuthMode>MWSStandard</AuthMode>
                  </cInfo>
                </Connect>
              </soap:Body>
            </soap:Envelope>');
      http_req := UTL_HTTP.begin_request ('http://deotila/MicroStrategyWS/MSTRWS.asmx', 'POST', 'HTTP/1.1');
      --UTL_HTTP.set_authentication (http_req, con_str_http_cueserval, con_str_http_cueserval_pw, 'Basic', FALSE);
      UTL_HTTP.set_header (http_req, 'Content-Type', 'text/xml; charset=utf-8');
      UTL_HTTP.set_header (http_req, 'Content-Length', LENGTH (soap_request.getstringval ()));
      UTL_HTTP.set_header (http_req, 'SOAPAction', '"http://microstrategy.com/webservices/v1_0/Connect"');
      UTL_HTTP.write_text (http_req, soap_request.getstringval ());
      http_resp := UTL_HTTP.get_response (http_req);

      BEGIN
        <<read_response_loop>>
         LOOP
            UTL_HTTP.read_line (r => http_resp, DATA => var_http_value, remove_crlf => TRUE);
            var_http_ret_val := var_http_ret_val || var_http_value;
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (r => http_resp);
      END;

      SELECT MAX (id_ultima_transaccion) + 1 INTO v_ultima_transaccion FROM LOG_MICROSTRATEGY;

      INSERT INTO LOG_MICROSTRATEGY (ID_ULTIMA_TRANSACCION, LAST_SESSION, RESULT, LAST_EXECUTION)
           VALUES (v_ultima_transaccion, XMLTYPE (var_http_ret_val).EXTRACT ('/soap:Envelope/soap:Body/child::node()', 'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"').EXTRACT ('ConnectResponse/ConnectResult/text()', 'xmlns="http://microstrategy.com/webservices/v1_0"')
                  ,XMLTYPE (var_http_ret_val).EXTRACT ('/soap:Envelope/soap:Body/child::node()', 'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"').EXTRACT ('ConnectResponse/ConnectResult', 'xmlns="http://microstrategy.com/webservices/v1_0"')
                  ,SYSTIMESTAMP);

      COMMIT;
      RETURN XMLTYPE (var_http_ret_val).EXTRACT ('/soap:Envelope/soap:Body/child::node()'
            ,'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"');
   END iServerConnect;

   FUNCTION iServerDisconnect
      RETURN XMLTYPE
   -- RETURN VARCHAR2
   IS
      v_ultima_transaccion   LOG_MICROSTRATEGY.ID_ULTIMA_TRANSACCION%TYPE;
      v_ultima_session_id    LOG_MICROSTRATEGY.LAST_SESSION%TYPE;
   BEGIN
      SELECT MAX (id_ultima_transaccion) INTO v_ultima_transaccion FROM LOG_MICROSTRATEGY;

      SELECT LAST_SESSION
        INTO v_ultima_session_id
        FROM LOG_MICROSTRATEGY
       WHERE id_ultima_transaccion = v_ultima_transaccion;

      /*
                    <soap:Header>
                      <MWSSoapHeader xmlns="http://microstrategy.com/webservices/v1_0">
                        <xy199Val>string</xy199Val>
                        <xy299Val>string</xy299Val>
                        <xy399Val>string</xy399Val>
                      </MWSSoapHeader>
                    </soap:Header>
      */
      soap_request :=
         XMLTYPE (
            '<?xml version="1.0" encoding="utf-8"?>
            <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <Disconnect xmlns="http://microstrategy.com/webservices/v1_0">
                  <arrSessions>
                    <string>'
            || v_ultima_session_id
            || '</string>
                  </arrSessions>
                </Disconnect>
              </soap:Body>
            </soap:Envelope>');
      http_req := UTL_HTTP.begin_request ('http://deotila/MicroStrategyWS/MSTRWS.asmx', 'POST', 'HTTP/1.1');
      --UTL_HTTP.set_authentication (http_req, con_str_http_cueserval, con_str_http_cueserval_pw, 'Basic', FALSE);
      UTL_HTTP.set_header (http_req, 'Content-Type', 'text/xml; charset=utf-8');
      UTL_HTTP.set_header (http_req, 'Content-Length', LENGTH (soap_request.getstringval ()));
      UTL_HTTP.set_header (http_req, 'SOAPAction', '"http://microstrategy.com/webservices/v1_0/Disconnect"');
      UTL_HTTP.write_text (http_req, soap_request.getstringval ());
      http_resp := UTL_HTTP.get_response (http_req);

      BEGIN
        <<read_response_loop>>
         LOOP
            UTL_HTTP.read_line (r => http_resp, DATA => var_http_value, remove_crlf => TRUE);
            var_http_ret_val := var_http_ret_val || var_http_value;
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (r => http_resp);
      END;

      --RETURN var_http_ret_val;
      RETURN XMLTYPE (var_http_ret_val).EXTRACT ('/soap:Envelope/soap:Body/child::node()'
            ,'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"');
   END iServerDisconnect;

   FUNCTION SimpleExecuteReport (pServer IN VARCHAR2, pProjectName IN VARCHAR2, pLogin IN VARCHAR2, pPassword IN VARCHAR2)
      -- RETURN XMLTYPE
      RETURN VARCHAR2
   IS
      --      var_resp_header_name    VARCHAR2 (1024);
      --      var_resp_header_value   VARCHAR2 (1024);
      l_blob                 CLOB;
      l_raw                  RAW (32767);
      v_ultima_transaccion   LOG_MICROSTRATEGY.ID_ULTIMA_TRANSACCION%TYPE;
   BEGIN
      /*
                    <soap:Header>
                      <MWSSoapHeader xmlns="http://microstrategy.com/webservices/v1_0">
                        <xy199Val>string</xy199Val>
                        <xy299Val>string</xy299Val>
                        <xy399Val>string</xy399Val>
                      </MWSSoapHeader>
                    </soap:Header>

                          <Session>string</Session>
                          <HasHeuristics>boolean</HasHeuristics>
                          <PortNumber>int</PortNumber>
                          <ArrayConnectProperty>
                            <MWSConnectProperty2>
                              <ConnectPropertyFlag>MWSSessionLocaleID or MWSDisplayLocaleID or MWSClientWSDLVersion or MWSUseUTCBasedTime or MWSCheckLicense or MWSClientUILocaleID</ConnectPropertyFlag>
                              <ConnectPropertyValue>string</ConnectPropertyValue>
                            </MWSConnectProperty2>
                            <MWSConnectProperty2>
                              <ConnectPropertyFlag>MWSSessionLocaleID or MWSDisplayLocaleID or MWSClientWSDLVersion or MWSUseUTCBasedTime or MWSCheckLicense or MWSClientUILocaleID</ConnectPropertyFlag>
                              <ConnectPropertyValue>string</ConnectPropertyValue>
                            </MWSConnectProperty2>
                          </ArrayConnectProperty>
                          <ClientIPAddress>string</ClientIPAddress>
                        <sAnswerPrompt>string</sAnswerPrompt>
      */
      soap_request :=
         XMLTYPE (
            '<?xml version="1.0" encoding="utf-8"?>
            <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <SimpleExecuteReport xmlns="http://microstrategy.com/webservices/v1_0">
                  <cInfo>
              <Login>'
            || pLogin
            || '</Login>
              <Password>'
            || pPassword
            || '</Password>
              <ProjectName>'
            || pProjectName
            || '</ProjectName>
                    <ProjectSource>'
            || pServer
            || '</ProjectSource>
                    <AuthMode>MWSStandard</AuthMode>
                  </cInfo>
                  <sReportName>TM_TIPO_ANESTESIA</sReportName>
                </SimpleExecuteReport>
              </soap:Body>
            </soap:Envelope>');
      http_req := UTL_HTTP.begin_request ('http://deotila/MicroStrategyWS/MSTRWS.asmx', 'POST', 'HTTP/1.1');
      --UTL_HTTP.set_authentication (http_req, con_str_http_cueserval, con_str_http_cueserval_pw, 'Basic', FALSE);
      UTL_HTTP.set_header (http_req, 'Content-Type', 'text/xml; charset=utf-8');
      UTL_HTTP.set_header (http_req, 'Content-Length', LENGTH (soap_request.getstringval ()));
      UTL_HTTP.set_header (http_req, 'SOAPAction', '"http://microstrategy.com/webservices/v1_0/SimpleExecuteReport"');
      UTL_HTTP.write_text (http_req, soap_request.getstringval ());
      http_resp := UTL_HTTP.get_response (http_req);

      DBMS_LOB.createtemporary (l_blob, FALSE);

      --      FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
      --      LOOP
      --         UTL_HTTP.get_header (r       => http_resp,
      --                              n       => i,
      --                              NAME    => var_resp_header_name,
      --                              VALUE   => var_resp_header_value);
      --      END LOOP;

      BEGIN
         LOOP
            UTL_HTTP.read_raw (http_resp, l_raw, 32767);
            DBMS_LOB.writeappend (l_blob, UTL_RAW.LENGTH (l_raw), l_raw);
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (http_resp);
      END;

      SELECT MAX (id_ultima_transaccion) + 1 INTO v_ultima_transaccion FROM LOG_MICROSTRATEGY;


      INSERT INTO LOG_MICROSTRATEGY (id_ultima_transaccion, CLOB_RESULT, LAST_EXECUTION)
           VALUES (v_ultima_transaccion, l_blob, SYSTIMESTAMP);

      -- Relase the resources associated with the temporary LOB.
      DBMS_LOB.freetemporary (l_blob);
      COMMIT;

      RETURN http_resp.status_code;
   --      BEGIN
   --        <<read_response_loop>>
   --         LOOP
   --            UTL_HTTP.read_line (r => http_resp, DATA => var_http_value, remove_crlf => FALSE);
   --            var_http_ret_val := var_http_ret_val || var_http_value;
   --         END LOOP;
   --      EXCEPTION
   --         WHEN UTL_HTTP.end_of_body
   --         THEN
   --            UTL_HTTP.end_response (r => http_resp);
   --      END;
   --
   ----      RETURN XMLTYPE (var_http_ret_val).EXTRACT ('/soap:Envelope/soap:Body/child::node()', 'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"');
   --      RETURN var_http_ret_val;
   END SimpleExecuteReport;

   PROCEDURE ExecuteReport (pReportID IN VARCHAR2)
   --   (pServer        IN VARCHAR2,
   --                            pProjectName   IN VARCHAR2,
   --                            pLogin         IN VARCHAR2,
   --                            pPassword      IN VARCHAR2)
   --RETURN XMLTYPE
   IS
      l_blob   CLOB;
      l_raw    RAW (32767);
   --      v_ultima_transaccion   LOG_MICROSTRATEGY.ID_ULTIMA_TRANSACCION%TYPE;
   BEGIN
      soap_request :=
         XMLTYPE (
            '<?xml version="1.0" encoding="utf-8"?>
            <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
              <soap:Body>
                <ExecuteReport xmlns="http://microstrategy.com/webservices/v1_0">
                  <cInfo>
              <Login>'
            || MSTR_USER
            || '</Login>
              <Password>'
            || MSTR_PASSWORD
            || '</Password>
              <ProjectName>'
            || 'AGD'
            || '</ProjectName>
                    <ProjectSource>'
            || 'fraterno'
            || '</ProjectSource>
                    <AuthMode>MWSStandard</AuthMode>
                  </cInfo>
                  <sReportID>'
            || pReportID
            || '</sReportID>
                  <sStyle>DataHTML</sStyle>
                </ExecuteReport>
              </soap:Body>
            </soap:Envelope>');
      http_req := UTL_HTTP.begin_request ('http://deotila/MicroStrategyWS/MSTRWS.asmx', 'POST', 'HTTP/1.1');
      --UTL_HTTP.set_authentication (http_req, con_str_http_cueserval, con_str_http_cueserval_pw, 'Basic', FALSE);
      UTL_HTTP.set_header (http_req, 'Content-Type', 'text/xml; charset=utf-8');
      UTL_HTTP.set_header (http_req, 'Content-Length', LENGTH (soap_request.getstringval ()));
      UTL_HTTP.set_header (http_req, 'SOAPAction', '"http://microstrategy.com/webservices/v1_0/ExecuteReport"');
      UTL_HTTP.write_text (http_req, soap_request.getstringval ());
      http_resp := UTL_HTTP.get_response (http_req);

      BEGIN
        <<read_response_loop>>
         LOOP
            UTL_HTTP.read_line (r => http_resp, DATA => var_http_value, remove_crlf => TRUE);
            var_http_ret_val := var_http_ret_val || var_http_value;
         END LOOP;
      EXCEPTION
         WHEN UTL_HTTP.end_of_body
         THEN
            UTL_HTTP.end_response (r => http_resp);
      END;

      --      SELECT MAX (id_ultima_transaccion) + 1 INTO v_ultima_transaccion FROM LOG_MICROSTRATEGY;
      --
      --
      --      INSERT INTO LOG_MICROSTRATEGY (id_ultima_transaccion, RESULT, LAST_EXECUTION)
      --           VALUES (
      --                     v_ultima_transaccion,
      --                     XMLTYPE (var_http_ret_val).EXTRACT ('/soap:Envelope/soap:Body/child::node()', 'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'),
      --                     SYSTIMESTAMP);
      --
      --      COMMIT;
      HTP.p --streamdataset (xmltype
            (
         DBMS_XMLGEN.CONVERT (XMLTYPE (var_http_ret_val).EXTRACT ('/soap:Envelope/soap:Body/child::node()', 'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"').EXTRACT ('ExecuteReportResponse/ExecuteReportResult/ResultXML/text()', 'xmlns="http://microstrategy.com/webservices/v1_0"').getstringval ()
        ,DBMS_XMLGEN.ENTITY_DECODE));
   --);
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
   END ExecuteReport;

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

   PROCEDURE ListReports
   IS
   BEGIN
      OWA_UTIL.mime_header ('text/html', TRUE);
      HTP.HEADOPEN;
      HTP.LINKREL (crel => 'Stylesheet', curl => '/public/css/canvas.css');
      HTP.HEADCLOSE;
      HTP.BODYOPEN;
      HTP.DIV (NULL, 'class="liquid-round"');
      HTP.DIV (NULL, 'class="top"');
      HTP.P ('<span></span>');
      HTP.P ('</div>');
      HTP.DIV (NULL, 'class="center-content"');
      OWA_UTIL.LISTPRINT (p_theQuery => 'SELECT OBJECT_ID, OBJECT_NAME, NULL
                                            FROM MICROSTRATEGY_METADATA.DSSMDOBJINFO
                                            WHERE OBJECT_TYPE = 3 
                                            AND PROJECT_ID = ''7ACF08504BD7D571A6393593361002C2'' 
                                            AND PARENT_ID = ''D3C7D461F69C4610AA6BAA5EF51F4125'' ORDER BY 2', p_cname => 'lst_MSTRReportList" id="lst_MSTRReportList" class="SelectList" onchange="parent.main.location.href = ''/cdm_dad/MicroStrategyWS.ExecuteReport?pReportID=''+ this.options[this.selectedIndex].value;', p_nsize => 25, p_multiple => FALSE); --parent.main.location.href = ''/cdm_dad/MicroStrategyWS.ExecuteReport?pReportName=TM_TIPO_ANESTESIA''; --alert(''Index: '' + this.selectedIndex+ ''\nValue: '' + this.options[this.selectedIndex].value)
      HTP.P ('</div>');
      HTP.DIV (NULL, 'class="bottom"');
      HTP.P ('<span></span>');
      HTP.P ('</div>');
      HTP.P ('</div>');
      HTP.BODYCLOSE;
   EXCEPTION
      WHEN OTHERS
      THEN
         OWA_UTIL.mime_header ('text/plain', TRUE, 'utf-8');
         HTP.p (SQLERRM);
         HTP.p (DBMS_UTILITY.format_error_backtrace);
   --OWA_UTIL.SIGNATURE;
   END ListReports;

   PROCEDURE hola
   IS
   BEGIN
      HTP.p ('<h1>estoy aquí</h1>');
   END hola;
END MicroStrategyWS;
/
