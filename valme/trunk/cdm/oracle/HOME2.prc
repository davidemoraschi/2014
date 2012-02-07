CREATE OR REPLACE PROCEDURE CDM.home2 (
   p_url                      IN       VARCHAR2)
IS
BEGIN
   HTP.htmlOpen;
      HTP.headOpen;
         HTP.title ('This is a test page!');
      HTP.headClose;
      HTP.bodyOpen;
         HTP.PRINT ('This is a test page! DateTime: ' || TO_CHAR (p_url));
      HTP.bodyClose;
   HTP.htmlClose;
END home2; 
/

