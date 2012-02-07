CREATE OR REPLACE PROCEDURE CDM.home IS
BEGIN
  HTP.htmlopen;
  HTP.headopen;
  HTP.title('This is a test page!');
  HTP.headclose;
  HTP.bodyopen;
  HTP.print('This is a test page! DateTime: ' || TO_CHAR(SYSTIMESTAMP));
  HTP.bodyclose;
  HTP.htmlclose;
END home;
/

