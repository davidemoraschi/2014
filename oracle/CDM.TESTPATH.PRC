CREATE OR REPLACE PROCEDURE CDM.testpath
IS
BEGIN
   --HTP.p ('<p>OWA_UTIL.GET_OWA_SERVICE_PATH: ' || OWA_UTIL.GET_OWA_SERVICE_PATH || '</p>');
   --HTP.p ('<p>OWA_UTIL.GET_PROCEDURE: ' || OWA_UTIL.GET_PROCEDURE || '</p>');
   OWA_UTIL.LISTPRINT (p_theQuery => 'select rownum, title,null from HTML_RSS_NEWS', p_cname => 'titulos', p_nsize => 20, p_multiple => FALSE);
EXCEPTION
   WHEN OTHERS
   THEN
      HTP.p (SQLERRM);
END;
/
