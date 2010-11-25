CREATE OR REPLACE PROCEDURE CDM.testerror
IS
   x   NUMBER;
BEGIN
   x := 1 / 0;
   DBMS_OUTPUT.put_line (x);
EXCEPTION
   WHEN OTHERS
   THEN
      OWA_UTIL.mime_header ('text/plain', TRUE);
      HTP.p (SQLERRM);
      HTP.p (DBMS_UTILITY.format_error_backtrace);
      --OWA_UTIL.SIGNATURE;
END;
/
