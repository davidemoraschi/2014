CREATE OR REPLACE PROCEDURE CDM.fn_google_clock
AS
   con_str_http_proxy   CONSTANT VARCHAR2 (50) := '10.234.23.117:8080';
   l_http_request                UTL_HTTP.req;
   l_http_response               UTL_HTTP.resp;
   l_blob                        BLOB;
   l_raw                         RAW (32767);
   s_mime_type                   VARCHAR2 (48) := 'image/png';
   s_filename                    VARCHAR2 (400) := 'google_clock.png';
   n_length                      NUMBER;
BEGIN
--HTP.p (p_url);

   -- Initialize the BLOB.
   DBMS_LOB.createtemporary (l_blob, FALSE);
   -- Make a HTTP request and get the response.
   UTL_HTTP.set_proxy (proxy => con_str_http_proxy);
   l_http_request :=
      UTL_HTTP.begin_request (   'http://chart.apis.google.com/chart?cht=p3&chd=t:'
                              || TO_CHAR (60 - EXTRACT (MINUTE FROM SYSTIMESTAMP))
                              || TO_CHAR (SYSDATE, ',SS')
                              || '&chs=500x200&chl='
                              || TO_CHAR (SYSDATE, 'MI" minutos"')
                              || '|'
                              || TO_CHAR (SYSDATE, 'SS" segundos"'));                                                                              --Hello|World
   l_http_response := UTL_HTTP.get_response (l_http_request);

   -- Copy the response into the BLOB.
   BEGIN
      LOOP
         UTL_HTTP.read_raw (l_http_response, l_raw, 32767);
         DBMS_LOB.writeappend (l_blob, UTL_RAW.LENGTH (l_raw), l_raw);
      END LOOP;
   EXCEPTION
      WHEN UTL_HTTP.end_of_body
      THEN
         UTL_HTTP.end_response (l_http_response);
   END;

   OWA_UTIL.mime_header (s_mime_type, FALSE);
   n_length := DBMS_LOB.getlength (l_blob);
   HTP.p ('Content-length: ' || n_length);
   HTP.p ('Content-Disposition: filename="' || s_filename || '"');
   OWA_UTIL.http_header_close;
   WPG_DOCLOAD.download_file (l_blob);
   DBMS_LOB.freetemporary (l_blob);
EXCEPTION
   WHEN OTHERS
   THEN
      UTL_HTTP.end_response (l_http_response);
      DBMS_LOB.freetemporary (l_blob);
      RAISE;
END fn_google_clock; 
/

