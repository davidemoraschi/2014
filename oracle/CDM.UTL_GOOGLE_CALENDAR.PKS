CREATE OR REPLACE PACKAGE CDM.utl_google_calendar
AS
   con_str_http_proxy         CONSTANT VARCHAR2 (50) := '10.234.23.117:8080';
   con_str_wallet_path        CONSTANT VARCHAR2 (50) := 'file:C:\oracle\product\11.2.0';
   con_str_wallet_pass        CONSTANT VARCHAR2 (50) := 'Lepanto1571';
   con_str_google_login       CONSTANT VARCHAR2 (100) := 'https://www.google.com/accounts/ClientLogin';
   con_str_google_createcal   CONSTANT VARCHAR2 (100) := 'https://www.google.com/calendar/feeds/default/owncalendars/full';
   con_str_account_type       CONSTANT VARCHAR2 (10) := 'GOOGLE';
   con_str_account_name       CONSTANT VARCHAR2 (25) := 'hvalme@gmail.com';
   con_str_account_pass       CONSTANT VARCHAR2 (30) := 'SPANISH_SPAIN.WE8MSWIN1252';
   con_str_google_cal_serv    CONSTANT VARCHAR2 (10) := 'cl';
   con_str_package_version    CONSTANT VARCHAR2 (20) := 'VALME-Almagesto-1.6';

   var_http_response                   UTL_HTTP.resp;
   var_http_value                      VARCHAR2 (32767);
   var_http_ret_val                    VARCHAR2 (32767);
   var_http_value_raw                  RAW (32767);
   var_http_request_params             VARCHAR2 (1024)
      :=    'accountType='
         || con_str_account_type
         || '&Email='
         || con_str_account_name
         || '&Passwd='
         || con_str_account_pass
         || '&service='
         || con_str_google_cal_serv
         || '&source='
         || con_str_package_version;

   PROCEDURE prepare_connection;

   FUNCTION prepare_GET_request (par_url IN VARCHAR2)
      RETURN UTL_HTTP.req;

   FUNCTION prepare_POST_request (par_url IN VARCHAR2, par_calendar_entry IN XMLTYPE, par_http_authorization_token IN VARCHAR2)
      RETURN UTL_HTTP.req;

   FUNCTION get_authorization_token (p_str_account_name IN VARCHAR2, p_str_account_pass IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION create_calendar (p_str_account_name   IN VARCHAR2,
                             p_str_account_pass   IN VARCHAR2,
                             p_cal_name           IN VARCHAR2,
                             p_cal_descr          IN VARCHAR2,
                             p_cal_location       IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE TEST_ME;
END utl_google_calendar;
/
