CREATE OR REPLACE FUNCTION CDM.fn_html_constant (
   p_id_constant              IN       NUMBER)
   RETURN VARCHAR2
IS
   var_str_html                  VARCHAR2 (255);
BEGIN
   SELECT desc_constant
   INTO   var_str_html
   FROM   html_constants
   WHERE  id_constant = p_id_constant;

   RETURN var_str_html;
END; 
/

