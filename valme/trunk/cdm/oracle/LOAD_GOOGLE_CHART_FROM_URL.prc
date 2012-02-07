CREATE OR REPLACE PROCEDURE CDM.load_google_chart_from_url (
   p_url                      IN       VARCHAR2)
AS
   con_str_http_proxy   CONSTANT VARCHAR2 (50) := '10.234.23.117:8080';
   l_http_request                UTL_HTTP.req;
   l_http_response               UTL_HTTP.resp;
   l_blob                        BLOB;
   l_raw                         RAW (32767);
   s_mime_type                   VARCHAR2 (48) := 'image/png';
   s_filename                    VARCHAR2 (400) := 'google_chart.png';
   n_length                      NUMBER;
BEGIN
--HTP.p (p_url);

   -- Initialize the BLOB.
   DBMS_LOB.createtemporary (l_blob, FALSE);
   -- Make a HTTP request and get the response.
   UTL_HTTP.set_proxy (proxy => con_str_http_proxy);
   l_http_request := UTL_HTTP.begin_request (p_url);
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

   -- Insert the data into the table.
--   INSERT INTO http_blob_test
--               (ID, url, DATA)
--        VALUES (http_blob_test_seq.NEXTVAL, p_url, l_blob);

   -- Relase the resources associated with the temporary LOB.
   --DBMS_LOB.freetemporary (l_blob);
--   COMMIT;
   --   DBMS_OUTPUT.put_line ('s_mime_type: ' || s_mime_type);
   OWA_UTIL.mime_header (s_mime_type, FALSE);
   -- Set the size so the browser knows how much it will be downloading.
   n_length := DBMS_LOB.getlength (l_blob);
--   DBMS_OUTPUT.put_line ('BLOB size: ' || TO_CHAR (n_length));
   HTP.p ('Content-length: ' || n_length);
   -- The filename will be used by the browser if the users does a "Save as"
   HTP.p ('Content-Disposition: filename="' || s_filename || '"');
   OWA_UTIL.http_header_close;
   -- Download the BLOB
   WPG_DOCLOAD.download_file (l_blob);
   -- Relase the resources associated with the temporary LOB.
   DBMS_LOB.freetemporary (l_blob);
--   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      UTL_HTTP.end_response (l_http_response);
      DBMS_LOB.freetemporary (l_blob);
--      COMMIT;
      RAISE;
END load_google_chart_from_url; 
/

