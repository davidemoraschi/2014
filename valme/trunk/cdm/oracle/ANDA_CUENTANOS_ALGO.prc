/* Formatted on 2010/09/16 12:27 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PROCEDURE cdm.anda_cuentanos_algo (p_texto IN VARCHAR2 default 'No hay ningun texto para leer, por favor use el parámetro p_texto')
IS
   http_method          CONSTANT VARCHAR2 (5) := 'POST';
   show_header          CONSTANT NUMBER := 1;
   s_mime_type          CONSTANT VARCHAR2 (48) := 'audio/x-wav';
   s_filename           CONSTANT VARCHAR2 (400) := 'Leonor.wav';
   s_voice              CONSTANT VARCHAR2 (20) := 'Leonor';
   http_req                      UTL_HTTP.req;
   http_resp                     UTL_HTTP.resp;
   loquendo_api_url              VARCHAR2 (1000) := 'http://tts.loquendo.com:8080/TTS7/LoquendoTTS?id=305174485';
   v_post_data                   VARCHAR2 (1024)
                                        := 'testo="' || p_texto || '"&voce=' || s_voice || '&yeruy47yyehedher7=yeruy47yyehedher7';
   h_name                        VARCHAR2 (255);
   h_value                       VARCHAR2 (1023);
   l_blob                        BLOB;
   l_raw                         RAW (32767);
   n_length                      NUMBER;
   last_id                       VARCHAR2 (10);
BEGIN
   DBMS_LOB.createtemporary (l_blob, FALSE);
   UTL_HTTP.set_proxy ('10.234.23.117:8080');
   UTL_HTTP.set_response_error_check (TRUE);
   UTL_HTTP.set_detailed_excp_support (TRUE);
   http_req := UTL_HTTP.begin_request (loquendo_api_url, http_method, UTL_HTTP.http_version_1_1);
   UTL_HTTP.set_header (http_req
                       ,'User-Agent'
                       ,'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.8) Gecko/20100722 Firefox/3.6.8');
   UTL_HTTP.set_header (r => http_req, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
   UTL_HTTP.set_header (r => http_req, NAME => 'Content-Length', VALUE => LENGTH (v_post_data));
   UTL_HTTP.write_text (http_req, v_post_data);
   http_resp := UTL_HTTP.get_response (http_req);

   IF show_header = 1
   THEN
      DBMS_OUTPUT.put_line ('status code: ' || http_resp.status_code);
      DBMS_OUTPUT.put_line ('reason phrase: ' || http_resp.reason_phrase);

      FOR i IN 1 .. UTL_HTTP.get_header_count (http_resp)
      LOOP
         UTL_HTTP.get_header (http_resp, i, h_name, h_value);
         DBMS_OUTPUT.put_line (h_name || ': ' || h_value);
      END LOOP;
   END IF;

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

   INSERT INTO http_blob_temp
               (ID, url, DATA)
        VALUES (http_blob_test_seq.NEXTVAL, v_post_data, l_blob)
     RETURNING ID
          INTO last_id;

   COMMIT;
   n_length := DBMS_LOB.getlength (l_blob);
   OWA_UTIL.mime_header (NVL (s_mime_type, 'application/octet'), FALSE);
-- Set the size so the browser knows how much it will be downloading.
   HTP.p ('Content-length: ' || n_length);
-- The filename will be used by the browser if the users does a "Save as"
   HTP.p ('Content-Disposition: filename="' || s_filename || '"');
   OWA_UTIL.http_header_close;
-- Download the BLOB
   WPG_DOCLOAD.download_file (l_blob);
   DBMS_LOB.freetemporary (l_blob);
EXCEPTION
   WHEN OTHERS
   THEN
      UTL_HTTP.end_response (http_resp);
      DBMS_LOB.freetemporary (l_blob);
      COMMIT;
      RAISE;
END;
/