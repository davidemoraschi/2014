CREATE OR REPLACE PROCEDURE CDM.fn_img_display (p_id NUMBER)
AS
   s_mime_type                   VARCHAR2 (48);
   n_length                      NUMBER;
   s_filename                    VARCHAR2 (400);
   lob_image                     BLOB;
BEGIN
   SELECT mime_type, DBMS_LOB.getlength (blob_content), file_name, blob_content
   INTO   s_mime_type, n_length, s_filename, lob_image
   FROM   html_media
   WHERE  media_id = p_id;

   OWA_UTIL.mime_header (NVL (s_mime_type, 'application/octet'), FALSE);
-- Set the size so the browser knows how much it will be downloading.
   HTP.p ('Content-length: ' || n_length);
-- The filename will be used by the browser if the users does a "Save as"
   HTP.p ('Content-Disposition: filename="' || s_filename || '"');
   OWA_UTIL.http_header_close;
-- Download the BLOB
   WPG_DOCLOAD.download_file (lob_image);
END fn_img_display; 
/

