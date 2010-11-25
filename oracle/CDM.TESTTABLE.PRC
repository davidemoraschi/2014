CREATE OR REPLACE PROCEDURE CDM.testtable
IS
   ignore_more   BOOLEAN;
BEGIN
   ignore_more := OWA_UTIL.TABLEPRINT ('GC_MV_0001', 'style="border: 1px solid black"');
EXCEPTION
   WHEN OTHERS
   THEN
      HTP.p ('<pre>');
      HTP.p (SQLERRM);
      HTP.p (DBMS_UTILITY.format_error_backtrace);
      HTP.p ('</pre>');
END;
/
