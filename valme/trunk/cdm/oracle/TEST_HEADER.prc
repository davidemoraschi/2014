CREATE OR REPLACE PROCEDURE CDM.test_header (
   p_url                      IN       VARCHAR2)
AS
   s_mime_type                   VARCHAR2 (48) := 'text/html';
BEGIN
   OWA_UTIL.mime_header (NVL (s_mime_type, 'application/octet'), FALSE);
-- Set the size so the browser knows how much it will be downloading.
   --HTP.p ('Content-length: ' || 100);
-- The filename will be used by the browser if the users does a "Save as"
--   HTP.p ('Content-Disposition: filename="foo.bar"');
   OWA_UTIL.http_header_close;
   HTP.p (p_url);
END; 
/

