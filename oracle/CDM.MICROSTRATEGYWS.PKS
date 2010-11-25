CREATE OR REPLACE PACKAGE CDM.MicroStrategyWS
AS
   /******************************************************************************
      NAME:       MicroStrategyWS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        22/11/2010      Davide       1. Created this package.
   ******************************************************************************/
   MSTR_USER       CONSTANT VARCHAR2 (20) := 'IUSR_WEBSERVICE';
   MSTR_PASSWORD   CONSTANT VARCHAR2 (20) := 'aumentanun4,9%';
   soap_request             XMLTYPE;
   http_req                 UTL_HTTP.req;
   http_resp                UTL_HTTP.resp;
   var_http_value           VARCHAR2 (32767);
   var_http_ret_val         VARCHAR2 (32767);

   FUNCTION TestService (pServer IN VARCHAR2, pProjectName IN VARCHAR2, pLogin IN VARCHAR2, pPassword IN VARCHAR2)
      RETURN XMLTYPE;

   PROCEDURE TestService;

   FUNCTION iServerConnect (pServer IN VARCHAR2, pProjectName IN VARCHAR2, pLogin IN VARCHAR2, pPassword IN VARCHAR2)
      RETURN XMLTYPE;

   FUNCTION iServerDisconnect
      RETURN XMLTYPE;

   -- RETURN VARCHAR2;
   FUNCTION SimpleExecuteReport (pServer IN VARCHAR2, pProjectName IN VARCHAR2, pLogin IN VARCHAR2, pPassword IN VARCHAR2)
      --      RETURN XMLTYPE;
      RETURN VARCHAR2;

   PROCEDURE ExecuteReport (pReportID IN VARCHAR2);

   --   (pServer        IN VARCHAR2,
   --                            pProjectName   IN VARCHAR2,
   --                            pLogin         IN VARCHAR2,
   --                            pPassword      IN VARCHAR2);

   -- RETURN XMLTYPE;

   --RETURN VARCHAR2;

   PROCEDURE streamDataSet (p_data_set XMLTYPE := NULL);

   PROCEDURE ListReports;

   PROCEDURE hola;
END MicroStrategyWS;
/
