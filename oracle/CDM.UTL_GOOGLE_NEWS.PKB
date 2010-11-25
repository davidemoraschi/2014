CREATE OR REPLACE PACKAGE BODY CDM.utl_google_news
AS
   nl_char              CONSTANT CHAR (1) := '
';

   FUNCTION list_news (
      p_id_feed                  IN       NUMBER DEFAULT 1)
      RETURN type_news PIPELINED
   AS
      x                             UTL_HTTP.html_pieces;
      len                           PLS_INTEGER;
      var_http_resp_clob            CLOB;
      var_http_resp_xml             XMLTYPE;
      v_url_feed                    http_rss_feeds.url_feed%TYPE;
   BEGIN
      SELECT url_feed
      INTO   v_url_feed
      FROM   http_rss_feeds
      WHERE  id_feed = p_id_feed;

      DBMS_LOB.createtemporary (var_http_resp_clob, FALSE);

      BEGIN
         x := UTL_HTTP.request_pieces (url => v_url_feed, max_pieces => 100, proxy => con_str_http_proxy);
      EXCEPTION                                                  --no me pregunte así funciona, tiene que ver con el proxy que no se abre muy rápido
         WHEN OTHERS
         THEN
            x := UTL_HTTP.request_pieces (url => v_url_feed, max_pieces => 100, proxy => con_str_http_proxy);
      END;

      len := 0;

      FOR i IN 1 .. x.COUNT
      LOOP
         len := len + LENGTH (x (i));
         DBMS_LOB.writeappend (var_http_resp_clob, LENGTH (x (i)), x (i));
      END LOOP;

      var_http_resp_xml := XMLTYPE (var_http_resp_clob);
      DBMS_LOB.freetemporary (var_http_resp_clob);

      FOR c1 IN (SELECT COLUMN_VALUE
                 FROM   TABLE (XMLSEQUENCE (var_http_resp_xml.EXTRACT ('/rss/channel/item/title'))))
      LOOP
         PIPE ROW (c1.COLUMN_VALUE.EXTRACT ('/title/text()').getstringval ());
      END LOOP;
   END list_news;

   FUNCTION list_news_by_date (
      p_id_feed                  IN       NUMBER DEFAULT 1)
      RETURN type_more_news PIPELINED
   AS
      x                             UTL_HTTP.html_pieces;
      len                           PLS_INTEGER;
      var_http_resp_clob            CLOB;
      var_http_resp_xml             XMLTYPE;
      v_url_feed                    http_rss_feeds.url_feed%TYPE;
      v_new                         type_new;
      n                             PLS_INTEGER := 1;
   BEGIN
      SELECT url_feed
      INTO   v_url_feed
      FROM   http_rss_feeds
      WHERE  id_feed = p_id_feed;

      DBMS_LOB.createtemporary (var_http_resp_clob, FALSE);

      BEGIN
         x := UTL_HTTP.request_pieces (url => v_url_feed, max_pieces => 100, proxy => con_str_http_proxy);
      EXCEPTION                                                  --no me pregunte así funciona, tiene que ver con el proxy que no se abre muy rápido
         WHEN OTHERS
         THEN
            x := UTL_HTTP.request_pieces (url => v_url_feed, max_pieces => 100, proxy => con_str_http_proxy);
      END;

      len := 0;

      FOR i IN 1 .. x.COUNT
      LOOP
         len := len + LENGTH (x (i));
         DBMS_LOB.writeappend (var_http_resp_clob, LENGTH (x (i)), x (i));
      END LOOP;

      var_http_resp_xml := XMLTYPE (var_http_resp_clob);
      DBMS_LOB.freetemporary (var_http_resp_clob);

      FOR c1 IN (SELECT COLUMN_VALUE
                 FROM   TABLE (XMLSEQUENCE (var_http_resp_xml.EXTRACT ('/rss/channel/item'))))
      LOOP
         DBMS_LOB.createtemporary (var_http_resp_clob, FALSE);
         --null;
         -- PIPE ROW (c1.COLUMN_VALUE.EXTRACT ('/title/text()').getstringval ());
         v_new.ID := n;
         v_new.title := c1.COLUMN_VALUE.EXTRACT ('/item/title/text()').getstringval ();
         v_new.pubdate :=
            TO_TIMESTAMP_TZ (c1.COLUMN_VALUE.EXTRACT ('/item/pubDate/text()').getstringval ()
                            ,'Dy, dd Mon yyyy HH24:MI:SS "GMT"TZH:TZM'
                            ,'NLS_DATE_LANGUAGE = AMERICAN');
         v_new.link_url := c1.COLUMN_VALUE.EXTRACT ('/item/link/text()').getstringval ();
         v_new.link_url := SUBSTR (v_new.link_url, INSTR (v_new.link_url, 'url=') + 4);

         BEGIN
            x := UTL_HTTP.request_pieces (url => v_new.link_url, max_pieces => 100, proxy => con_str_http_proxy);
         EXCEPTION                                               --no me pregunte así funciona, tiene que ver con el proxy que no se abre muy rápido
            WHEN OTHERS
            THEN
               NULL;
         END;

         len := 0;

         FOR i IN 1 .. x.COUNT
         LOOP
            len := len + LENGTH (x (i));
            DBMS_LOB.writeappend (var_http_resp_clob, LENGTH (x (i)), x (i));
         END LOOP;

         v_new.link_url := '<span alt="' || v_new.link_url || '">' || v_new.title || '</span>';
         v_new.html_content := var_http_resp_clob;
         PIPE ROW (v_new);
         DBMS_LOB.freetemporary (var_http_resp_clob);
         n := n + 1;
      END LOOP;
   END list_news_by_date;

   PROCEDURE fill_html_rss_news
   IS
      i                             PLS_INTEGER := 10;
   BEGIN
      EXECUTE IMMEDIATE 'delete from html_rss_news';

      FOR c1 IN (SELECT id_feed
                 FROM   http_rss_feeds)
      LOOP
         INSERT INTO html_rss_news
                     (news_id, title, pubdate, link_url, html_content)
            SELECT   i + ID
                    ,title
                    ,pubdate
                    ,link_url
                    ,REGEXP_REPLACE
                        (REGEXP_REPLACE
                            (REGEXP_REPLACE
                                (REGEXP_REPLACE
                                    (REGEXP_REPLACE
                                        (REGEXP_REPLACE
                                            (REGEXP_REPLACE
                                                (REGEXP_REPLACE
                                                    (REGEXP_REPLACE
                                                        (REGEXP_REPLACE
                                                                      (REGEXP_REPLACE (REGEXP_SUBSTR (html_content
                                                                                                     ,'<body((.|\n)*?)>((.|\n)*?)</body((.|\n)*?)>'
                                                                                                     ,1
                                                                                                     ,1
                                                                                                     ,'in')
                                                                                      ,'<script((.|\n)*?)>((.|\n)*?)</script((.|\n)*?)>'
                                                                                      ,''
                                                                                      ,1
                                                                                      ,0
                                                                                      ,'in')
                                                                      ,'<input((.|\n)*?)>'
                                                                      ,''
                                                                      ,1
                                                                      ,0
                                                                      ,'in')
                                                        ,'<ul((.|\n)*?)>((.|\n)*?)</ul((.|\n)*?)>'
                                                        ,''
                                                        ,1
                                                        ,0
                                                        ,'in')
                                                    ,'<li((.|\n)*?)>((.|\n)*?)</li((.|\n)*?)>'
                                                    ,''
                                                    ,1
                                                    ,0
                                                    ,'in')
                                                ,'<span((.|\n)*?)>((.|\n)*?)</span((.|\n)*?)>'
                                                ,''
                                                ,1
                                                ,0
                                                ,'in')
                                            ,'<a((.|\n)*?)>((.|\n)*?)</a((.|\n)*?)>'
                                            ,''
                                            ,1
                                            ,0
                                            ,'in')
                                        ,'<img((.|\n)*?)>((.|\n)*?)</((.|\n)*?)>'
                                        ,''
                                        ,1
                                        ,0
                                        ,'in')
                                    ,'<form((.|\n)*?)>((.|\n)*?)</form((.|\n)*?)>'
                                    ,''
                                    ,1
                                    ,0
                                    ,'in')
                                ,'<div((.|\n)*?)>'
                                ,''
                                ,1
                                ,0
                                ,'in')
                            ,'</div((.|\n)*?)>'
                            ,''
                            ,1
                            ,0
                            ,'in')
                        ,'<!--((.|\n)*?)-->'
                        ,''
                        ,1
                        ,0
                        ,'in')
            FROM     TABLE (utl_google_news.list_news_by_date (c1.id_feed))
            ORDER BY pubdate DESC;

         i := i + 10;
         COMMIT;
      END LOOP;
   END fill_html_rss_news;

   -- FUNCTION list_news (p_id_feed IN NUMBER DEFAULT 1
   -- ,p_max_rows IN NUMBER DEFAULT 10)
   -- RETURN type_news
   -- PIPELINED
   -- IS
   -- v_url_feed http_rss_feeds.url_feed%TYPE;
   -- var_http_request UTL_HTTP.req;
   -- var_http_response UTL_HTTP.resp;
   -- var_http_header_name VARCHAR2 (255);
   -- var_http_header_value  VARCHAR2 (1023);
   -- var_http_content_lenght NUMBER;
   -- var_http_content_chunks NUMBER;
   -- var_http_last_chunk_len NUMBER;
   -- var_http_resp_chunk  VARCHAR2 (32767);
   -- var_http_resp_clob   CLOB;
   -- var_http_resp_xml XMLTYPE;
   -- BEGIN
   -- SELECT url_feed
   -- INTO v_url_feed
   -- FROM http_rss_feeds
   -- WHERE id_feed = p_id_feed;
   -- -- Initialize the CLOB.
   -- DBMS_LOB.createtemporary (var_http_resp_clob, FALSE);
   -- prepare_connection;
   -- var_http_request := prepare_get_request (par_url => v_url_feed);
   -- var_http_response := UTL_HTTP.get_response (r => var_http_request);
   -- UTL_HTTP.get_header_by_name (r => var_http_response, name => 'Content-Length', VALUE => var_http_content_lenght, n => 1); -- Obtain the length of the response
   -- var_http_content_chunks := CEIL (var_http_content_lenght / 32767);
   -- var_http_last_chunk_len := MOD (var_http_content_lenght, 32767);
   --
   -- CASE var_http_response.status_code
   -- WHEN UTL_HTTP.http_ok THEN
   -- BEGIN
   -- <<read_response_loop>>
   -- LOOP
   -- UTL_HTTP.read_line (r => var_http_response, data => var_http_resp_chunk, remove_crlf => TRUE);
   -- DBMS_OUTPUT.put_line (var_http_resp_chunk);
   -- --PIPE ROW (var_http_resp_chunk);
   -- -- IF INSTR (var_http_value, 'Auth') > 0 THEN
   -- -- var_http_ret_val := SUBSTR (var_http_value, 6);
   -- -- EXIT read_response_loop;
   -- -- END IF;
   -- END LOOP;
   -- EXCEPTION
   -- WHEN UTL_HTTP.end_of_body THEN
   -- UTL_HTTP.end_response (r => var_http_response);
   -- END;
   -- WHEN UTL_HTTP.http_forbidden THEN
   -- PIPE ROW ('Fallo de autenticación: comprobar usuario y contraseña.');
   -- ELSE
   -- PIPE ROW (var_http_response.status_code || ' - ' || var_http_response.reason_phrase);
   -- END CASE;
   --
   -- -- FOR i IN 1 .. var_http_content_chunks -- obtain response in 32K blocks just in case it is greater than 32K
   -- -- LOOP
   -- -- UTL_HTTP.read_text (r => var_http_response, data => var_http_resp_chunk, len => CASE WHEN i < var_http_content_chunks THEN 32767 ELSE var_http_last_chunk_len END);
   -- -- PIPE ROW (var_http_resp_chunk);
   -- -- DBMS_LOB.writeappend (var_http_resp_clob, LENGTH (var_http_resp_chunk), var_http_resp_chunk);
   -- -- END LOOP;
   -- --UTL_HTTP.end_response (var_http_response);
   -- --PIPE ROW (xmltype (var_http_resp_clob));
   -- -- FOR c1
   -- -- IN (SELECT COLUMN_VALUE FROM TABLE (XMLSEQUENCE (xmltype (var_http_resp_clob).EXTRACT ('/feed/entry/title', 'xmlns="http://www.w3.org/2005/Atom"'))))
   -- -- LOOP
   -- -- PIPE ROW (c1.COLUMN_VALUE);
   -- -- END LOOP;
   -- DBMS_LOB.freetemporary (var_http_resp_clob);
   -- RETURN;
   -- END list_news;
   PROCEDURE prepare_connection
   IS
   BEGIN                                                                                                                 --Parámetros de la conexión
      UTL_HTTP.set_proxy (proxy => con_str_http_proxy);
      UTL_HTTP.set_wallet (PATH => con_str_wallet_path, PASSWORD => con_str_wallet_pass);
      UTL_HTTP.set_follow_redirect (max_redirects => 3);
      UTL_HTTP.set_response_error_check (ENABLE => FALSE);
      UTL_HTTP.set_detailed_excp_support (ENABLE => TRUE);
   END prepare_connection;

   FUNCTION prepare_get_request (
      par_url                    IN       VARCHAR2)
      RETURN UTL_HTTP.req
   IS
      var_http_request              UTL_HTTP.req;
   BEGIN
      var_http_request := UTL_HTTP.begin_request (url => par_url, method => 'GET', http_version => UTL_HTTP.http_version_1_1);
      --UTL_HTTP.set_header (r => var_http_request, NAME => 'Content-Type', VALUE => 'application/x-www-form-urlencoded');
      --UTL_HTTP.set_header (r => var_http_request, NAME => 'Content-Length', VALUE => LENGTH (var_http_request_params));
      --UTL_HTTP.set_header (r => var_http_request, NAME => 'GData-Version', VALUE => '2.0');
      --UTL_HTTP.set_header (r => var_http_request, NAME => 'Accept-Charset', VALUE => 'UTF-8');
      UTL_HTTP.set_cookie_support (r => var_http_request, ENABLE => TRUE);
      --UTL_HTTP.write_text (r => var_http_request, DATA => var_http_request_params);
      RETURN var_http_request;
   END prepare_get_request;

   PROCEDURE php
   IS
      v_data_clob                   CLOB;
   BEGIN
      --OWA_UTIL.mime_header ('text/html', FALSE);
      --HTP.p ('Content-Length: ' || DBMS_LOB.getlength (v_data_clob) || nl_char);
      --OWA_UTIL.http_header_close;
      --Download Data

      -- WPG_DOCLOAD.download_file (v_data_clob);
      HTP.p ('v_data_clob');
   EXCEPTION
      WHEN OTHERS
      THEN
         HTP.prn (SQLERRM);
   END php;
END utl_google_news;
/
