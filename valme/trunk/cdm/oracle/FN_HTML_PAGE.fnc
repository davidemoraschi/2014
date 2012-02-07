CREATE OR REPLACE FUNCTION CDM.fn_html_page (
   p_id_page                  IN       NUMBER)
   RETURN VARCHAR2
IS
   var_str_html                  VARCHAR2 (4000);
BEGIN
   SELECT EXTRACT (desc_page, '/').getstringval ()
   INTO   var_str_html
   FROM   html_pages
   WHERE  id_page = p_id_page;

   RETURN var_str_html;
END; 
/

