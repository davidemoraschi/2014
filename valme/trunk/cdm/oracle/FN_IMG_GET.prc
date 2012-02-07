CREATE OR REPLACE PROCEDURE CDM.fn_img_get (
   p_img_url                           VARCHAR2)
AS
   con_str_http_proxy   CONSTANT VARCHAR2 (50) := '10.234.23.117:8080';
   con_str_wallet_path  CONSTANT VARCHAR2 (50) := 'file:C:\oracle\product\11.2.0';
   con_str_wallet_pass  CONSTANT VARCHAR2 (50) := 'Lepanto1571';
   s_mime_type                   VARCHAR2 (48);
   s_filename                    VARCHAR2 (400);
   n_length                      NUMBER;
   l_http_request                UTL_HTTP.req;
   l_http_response               UTL_HTTP.resp;
   l_blob                        BLOB;
   l_raw                         RAW (32767);
BEGIN
   -- Initialize the BLOB.
   DBMS_LOB.createtemporary (l_blob, FALSE);
   -- Make a HTTP request and get the response.
   UTL_HTTP.set_proxy (proxy => con_str_http_proxy);
   UTL_HTTP.set_wallet (PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);
   UTL_HTTP.set_follow_redirect (max_redirects => 3);
   UTL_HTTP.set_response_error_check (ENABLE => TRUE);
   UTL_HTTP.set_detailed_excp_support (ENABLE => TRUE);
   l_http_request := UTL_HTTP.begin_request (p_img_url);
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

   OWA_UTIL.mime_header (NVL (s_mime_type, 'application/octet'), FALSE);
-- Set the size so the browser knows how much it will be downloading.
   HTP.p ('Content-length: ' || n_length);
-- The filename will be used by the browser if the users does a "Save as"
   HTP.p ('Content-Disposition: filename="' || s_filename || '"');
   OWA_UTIL.http_header_close;
-- Download the BLOB
   WPG_DOCLOAD.download_file (l_blob);
EXCEPTION
   WHEN OTHERS
   THEN
      UTL_HTTP.end_response (l_http_response);
      DBMS_LOB.freetemporary (l_blob);
      RAISE;
END fn_img_get; 
/

