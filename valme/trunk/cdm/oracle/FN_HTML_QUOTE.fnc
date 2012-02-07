CREATE OR REPLACE FUNCTION CDM.fn_html_quote
   RETURN VARCHAR2
AS
   var_str_html                  VARCHAR2 (255);
BEGIN
   SELECT    REPLACE (REGEXP_SUBSTR (EXTRACTVALUE (a.entry, '/rss/channel/item[1]/description'), '"(.*?)"'), '"')
          || ' - '
          || REPLACE (EXTRACTVALUE (a.entry, '/rss/channel/item[1]/title'), '"')
   INTO   var_str_html
   FROM   log_google@mtidae a;

   RETURN var_str_html;
END; 
/

