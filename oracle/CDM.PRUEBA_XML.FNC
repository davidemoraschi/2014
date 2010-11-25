CREATE OR REPLACE FUNCTION CDM.prueba_xml
  RETURN VARCHAR2
AS
  x									  UTL_HTTP.html_pieces;
  len 								  PLS_INTEGER;
  var_http_resp_clob 			  CLOB;
  var_http_resp_xml				  XMLTYPE;
BEGIN
  DBMS_LOB.createtemporary (var_http_resp_clob, FALSE);
  x := UTL_HTTP.request_pieces (url => 'http://news.google.com/news?pz=1&cf=all&ned=es_us&hl=es&q=Consejer%C3%ADa+de+Salud+Junta+de+Andaluc%C3%ADa&cf=all&output=rss', max_pieces => 100, proxy => '10.234.23.117:8080');
  --DBMS_OUTPUT.put_line (x.COUNT || ' pieces were retrieved.');
  --DBMS_OUTPUT.put_line ('with total length ');
  len := 0;

  FOR i IN 1 .. x.COUNT LOOP
	 len := len + LENGTH (x (i));
	 DBMS_LOB.writeappend (var_http_resp_clob, LENGTH (x (i)), x (i));
  --DBMS_OUTPUT.put_line (SUBSTR (x (i), 0, 1000));
  END LOOP;

  --DBMS_OUTPUT.put_line (len);
  DBMS_OUTPUT.put_line (SUBSTR (var_http_resp_clob, 0, 2000));
  var_http_resp_xml := xmltype (var_http_resp_clob);
--  INSERT INTO log_google (result, last_execution)
--	 VALUES	  (var_http_resp_xml, SYSTIMESTAMP);
--  COMMIT;
  DBMS_OUTPUT.put_line (var_http_resp_xml.EXTRACT ('/rss/channel/item/title[1]').getstringval ());
  
  DBMS_LOB.freetemporary (var_http_resp_clob);
  RETURN (var_http_resp_xml.EXTRACT ('/rss/channel/item/title[1]').getstringval ());
END;

--  SELECT result
--  FROM	log_google
--  WHERE	last_execution = (SELECT MAX (last_execution) FROM log_google);
/
