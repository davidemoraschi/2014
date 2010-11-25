CREATE OR REPLACE PACKAGE CDM.utl_google_news
AS
   --TYPE array IS TABLE OF NUMBER;
   TYPE type_new IS RECORD (
      ID                            NUMBER
     ,title                         html_rss_news.title%TYPE
     ,pubdate                       TIMESTAMP WITH TIME ZONE
     ,link_url                      VARCHAR2 (2000)
     ,html_content                  CLOB
   );

   TYPE type_news IS TABLE OF VARCHAR2 (500);

   TYPE type_more_news IS TABLE OF type_new;

   con_str_http_proxy   CONSTANT VARCHAR2 (50) := '10.234.23.117:8080';
   con_str_wallet_path  CONSTANT VARCHAR2 (50) := 'file:C:\oracle\product\11.2.0';
   con_str_wallet_pass  CONSTANT VARCHAR2 (50) := 'Lepanto1571';

   FUNCTION list_news (
      p_id_feed                  IN       NUMBER DEFAULT 1)
      RETURN type_news PIPELINED;

   FUNCTION list_news_by_date (
      p_id_feed                  IN       NUMBER DEFAULT 1)
      RETURN type_more_news PIPELINED;

   PROCEDURE fill_html_rss_news;

   --
   -- FUNCTION list_news (p_id_feed IN NUMBER DEFAULT 1
   --   ,p_max_rows IN NUMBER DEFAULT 10)
   -- RETURN type_news
   -- PIPELINED;
   PROCEDURE prepare_connection;

   FUNCTION prepare_get_request (
      par_url                    IN       VARCHAR2)
      RETURN UTL_HTTP.req;

   PROCEDURE php;
END utl_google_news;
/
