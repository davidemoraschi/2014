CREATE OR REPLACE PROCEDURE CDM.noticia (p_ID IN NUMBER)
AS
   NL_CHAR   CONSTANT CHAR (1) := '
';
   v_data_clob        CLOB;
BEGIN
   SELECT html_content
     INTO v_data_clob
     FROM HTML_RSS_NEWS
    WHERE NEWS_ID = p_ID;

   OWA_UTIL.mime_header ('text/html', FALSE);
   HTP.p ('Content-Length: ' || DBMS_LOB.getLength (v_data_clob) || NL_CHAR);
   OWA_UTIL.http_header_close;
   HTP.htmlopen;
   HTP.p (v_data_clob);
   HTP.htmlclose;
EXCEPTION
   WHEN OTHERS
   THEN
      HTP.htmlopen;
      HTP.headopen;
      HTP.title ('File Downloaded');
      HTP.headclose;
      HTP.bodyopen;
      HTP.header (1, 'Oracle error');
      --      HTP.PRINT ('Download of ' || l_filename || ' failed.');
      HTP.PRINT (SQLERRM);
      HTP.bodyclose;
      HTP.htmlclose;
      DBMS_LOB.freetemporary (v_data_clob);
END;
/
