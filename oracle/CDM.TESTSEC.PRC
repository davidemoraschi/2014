CREATE OR REPLACE PROCEDURE CDM.testsec
IS
BEGIN
   HTP.p ('User: ' || OWA_SEC.get_client_hostname);
EXCEPTION
   WHEN OTHERS
   THEN
      HTP.p (SQLERRM || '<hr>');
      HTP.p (DBMS_UTILITY.format_error_backtrace);
END;
/
