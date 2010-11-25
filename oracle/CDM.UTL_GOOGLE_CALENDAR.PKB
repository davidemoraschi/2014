CREATE OR REPLACE PACKAGE BODY CDM.utl_google_calendar
AS
   PROCEDURE prepare_connection
   IS
   BEGIN --Parámetros de la conexión
      UTL_HTTP.set_proxy (proxy => con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);
      UTL_HTTP.set_follow_redirect (max_redirects => 3);
      UTL_HTTP.set_response_error_check (ENABLE => FALSE);
      UTL_HTTP.set_detailed_excp_support (ENABLE => TRUE);
   END prepare_connection;

   FUNCTION prepare_GET_request (par_url IN VARCHAR2)
      RETURN UTL_HTTP.req
   IS
      var_http_request   UTL_HTTP.req;
   BEGIN
      var_http_request := UTL_HTTP.begin_request (url => par_url, method => 'POST', http_version => UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header (r => var_http_request, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
      UTL_HTTP.set_header (r => var_http_request, NAME => 'Content-Length', VALUE => LENGTH (var_http_request_params));
      UTL_HTTP.set_header (r => var_http_request, NAME => 'GData-Version', VALUE => '2.0');
      UTL_HTTP.set_header (r => var_http_request, NAME => 'Accept-Charset', VALUE => 'iso-8859-1');
      UTL_HTTP.set_cookie_support (r => var_http_request, ENABLE => TRUE);
      UTL_HTTP.write_text (r => var_http_request, DATA => var_http_request_params);
      RETURN var_http_request;
   END prepare_GET_request;

   FUNCTION prepare_POST_request (par_url IN VARCHAR2, par_calendar_entry IN XMLTYPE, par_http_authorization_token IN VARCHAR2)
      RETURN UTL_HTTP.req
   IS
      var_http_request     UTL_HTTP.req;
      var_calendar_entry   VARCHAR2 (32767);
   BEGIN
      var_calendar_entry := par_calendar_entry.getstringval ();
      var_http_request := UTL_HTTP.begin_request (url => par_url, method => 'POST', http_version => UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header (r => var_http_request, NAME => 'Content-Type', VALUE => 'application/atom+xml;charset=iso-8859-1');
      UTL_HTTP.set_header (r => var_http_request, NAME => 'Content-Length', VALUE => LENGTH (var_calendar_entry));
      UTL_HTTP.set_header (r => var_http_request, NAME => 'GData-Version', VALUE => '2.0');
      UTL_HTTP.set_header (r => var_http_request, NAME => 'Accept-Charset', VALUE => 'iso-8859-1');
      UTL_HTTP.set_header (r => var_http_request, NAME => 'Authorization', VALUE => 'GoogleLogin auth=' || par_http_authorization_token);
      UTL_HTTP.set_cookie_support (r => var_http_request, ENABLE => TRUE);
      UTL_HTTP.write_text (r => var_http_request, DATA => par_calendar_entry.getstringval ());
      RETURN var_http_request;
   END prepare_POST_request;

   FUNCTION get_authorization_token (p_str_account_name IN VARCHAR2, p_str_account_pass IN VARCHAR2)
      RETURN VARCHAR2
   IS
      var_http_request   UTL_HTTP.req;
   BEGIN
      var_http_request_params :=
            'accountType='
         || con_str_account_type
         || '&Email='
         || p_str_account_name
         || '&Passwd='
         || p_str_account_pass
         || '&service='
         || con_str_google_cal_serv
         || '&source='
         || con_str_package_version;

      prepare_connection;
      var_http_request := prepare_GET_request (par_url => con_str_google_login);
      var_http_response := UTL_HTTP.get_response (r => var_http_request);

      CASE var_http_response.status_code
         WHEN UTL_HTTP.http_ok
         THEN
           <<read_response_loop>>
            LOOP
               UTL_HTTP.read_line (r => var_http_response, DATA => var_http_value, remove_crlf => TRUE);

               IF INSTR (var_http_value, 'Auth') > 0
               THEN
                  var_http_ret_val := SUBSTR (var_http_value, 6);
                  EXIT read_response_loop;
               END IF;
            END LOOP;
         WHEN UTL_HTTP.HTTP_FORBIDDEN
         THEN
            var_http_ret_val := 'Fallo de autenticación: comprobar usuario y contraseña.';
         ELSE
            var_http_ret_val := var_http_response.status_code || ' - ' || var_http_response.reason_phrase;
      END CASE;

      UTL_HTTP.end_response (r => var_http_response);
      RETURN var_http_ret_val;
   END get_authorization_token;

   FUNCTION create_calendar (p_str_account_name   IN VARCHAR2,
                             p_str_account_pass   IN VARCHAR2,
                             p_cal_name           IN VARCHAR2,
                             p_cal_descr          IN VARCHAR2,
                             p_cal_location       IN VARCHAR2)
      RETURN VARCHAR2
   IS
      var_http_request               UTL_HTTP.req;
      var_http_authorization_token   VARCHAR2 (1024);
      var_xml_calendar               XMLTYPE;
   BEGIN
      SELECT XMLELEMENT (
                "entry",
                xmlattributes ('http://www.w3.org/2005/Atom' AS "xmlns",
                               'http://schemas.google.com/g/2005' AS "xmlns:gd",
                               'http://schemas.google.com/gCal/2005' AS "xmlns:gCal"),
                XMLELEMENT ("title", xmlattributes ('text' AS "type"), QUIR_ID),
                XMLELEMENT ("summary", xmlattributes ('text' AS "type"), QUIR_NOMBRE),
                XMLELEMENT ("gCal:hidden", xmlattributes ('false' AS "value")),
                XMLELEMENT ("gCal:color", xmlattributes ('#0ACE69' AS "value")),
                XMLELEMENT ("gCal:timezone", xmlattributes ('Europe/Madrid' AS "value")),
                XMLELEMENT ("gd:where", xmlattributes ('Sevilla, Spain' AS "valueString")))
        INTO var_xml_calendar
        FROM GC_MV_0007
       WHERE ROWNUM = 1;

      var_http_authorization_token := get_authorization_token (p_str_account_name, p_str_account_pass);
      var_http_request :=
         prepare_POST_request (
            'https://www.google.com/calendar/feeds/default/owncalendars/full',
            XMLTYPE (
                  '
                              <entry xmlns=''http://www.w3.org/2005/Atom''
                                    xmlns:gd=''http://schemas.google.com/g/2005'' 
                                    xmlns:gCal=''http://schemas.google.com/gCal/2005''> 
                                    <title type=''text''>'
               || p_cal_name
               || '</title> 
                                    <summary type=''text''>'
               || p_cal_descr
               || '</summary> 
                                    <gCal:hidden value=''false''></gCal:hidden> 
                                    <gCal:timezone value=''(GMT+01:00) Madrid''></gCal:timezone> 
                                    <gd:where rel='''' label='''' valueString='''
               || p_cal_location
               || '''></gd:where> 
                            </entry>
      '),
            var_http_authorization_token);
      var_http_response := UTL_HTTP.get_response (r => var_http_request);
      var_http_ret_val := NULL;

      CASE var_http_response.status_code
         WHEN UTL_HTTP.HTTP_CREATED
         THEN
            BEGIN
              <<read_response_loop>>
               LOOP
                  UTL_HTTP.read_line (r => var_http_response, DATA => var_http_value, remove_crlf => TRUE);
                  var_http_ret_val := var_http_ret_val || var_http_value;
               END LOOP;
            EXCEPTION
               WHEN UTL_HTTP.end_of_body
               THEN
                  UTL_HTTP.end_response (r => var_http_response);
            END;
         WHEN UTL_HTTP.HTTP_FORBIDDEN
         THEN
            var_http_ret_val := 'Fallo de autenticación: comprobar usuario y contraseña.';
            UTL_HTTP.end_response (r => var_http_response);
         ELSE
            var_http_ret_val := var_http_response.status_code || ' - ' || var_http_response.reason_phrase;
            UTL_HTTP.end_response (r => var_http_response);
      END CASE;

   --   RETURN xmltype (var_http_ret_val).EXTRACT ('/entry/id/text()', 'xmlns="http://www.w3.org/2005/Atom"').getstringval ();
   RETURN var_http_ret_val;
   END create_calendar;

   PROCEDURE TEST_ME
   IS
      var_http_request               UTL_HTTP.req;
      var_http_authorization_token   VARCHAR2 (1024);
   BEGIN
      var_http_authorization_token := get_authorization_token ('hvalme@gmail.com', 'SPANISH_SPAIN.WE8MSWIN1252');
      DBMS_OUTPUT.put_line (var_http_authorization_token);
      var_http_request :=
         prepare_POST_request ('https://www.google.com/calendar/feeds/default/owncalendars/full',
                               XMLTYPE ('
                              <entry xmlns=''http://www.w3.org/2005/Atom''
                                    xmlns:gd=''http://schemas.google.com/g/2005'' 
                                    xmlns:gCal=''http://schemas.google.com/gCal/2005''> 
                                    <title type=''text''>TEST</title> 
                                    <summary type=''text''>Quirófano 1, Área Quirúrgica</summary> 
                                    <gCal:hidden value=''false''></gCal:hidden> 
                                    <gCal:color value=''#2952A3''></gCal:color> 
                                    <gCal:timezone value=''Europe/Prague''></gCal:timezone> 
                                    <gd:where rel='''' label='''' valueString=''Sevilla, Spain''></gd:where> 
                            </entry>
      '),
                               var_http_authorization_token);
      var_http_response := UTL_HTTP.get_response (r => var_http_request);
      DBMS_OUTPUT.put_line (var_http_response.status_code);
      UTL_HTTP.end_response (r => var_http_response);
   END TEST_ME;
END utl_google_calendar;
/
