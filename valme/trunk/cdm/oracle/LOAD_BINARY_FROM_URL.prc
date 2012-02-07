CREATE OR REPLACE PROCEDURE CDM.load_binary_from_url (p_url IN VARCHAR2)
AS
   con_str_http_proxy   CONSTANT VARCHAR2 (50) := '10.234.23.117:8080';
   l_http_request                UTL_HTTP.req;
   l_http_response               UTL_HTTP.resp;
   l_blob                        BLOB;
   l_raw                         RAW (32767);
BEGIN
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
   INSERT INTO http_blob_temp
               (ID, url, DATA)
        VALUES (http_blob_test_seq.NEXTVAL, p_url, l_blob);

   -- Relase the resources associated with the temporary LOB.
   DBMS_LOB.freetemporary (l_blob);
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      UTL_HTTP.end_response (l_http_response);
      DBMS_LOB.freetemporary (l_blob);
      COMMIT;
      RAISE;
END load_binary_from_url; 
/

