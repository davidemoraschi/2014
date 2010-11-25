CREATE OR REPLACE FUNCTION CDM.fn_google_geocode (p_direccion IN VARCHAR2)
   RETURN XMLTYPE
AS
   v_google_response    VARCHAR2 (32000);
   x_google_response    XMLTYPE;
   r_geocodes           XMLTYPE;
   var_http_resp_clob   CLOB;
   x                    UTL_HTTP.html_pieces;
   len                  PLS_INTEGER;
   v_direccion          VARCHAR2 (1000);
BEGIN
   UTL_HTTP.set_proxy (proxy => '10.234.23.117:8080');
   v_direccion := p_direccion;

--      v_direccion := REPLACE (v_direccion, 'á', 'a');
--      v_direccion := REPLACE (v_direccion, 'é', 'e');
--      v_direccion := REPLACE (v_direccion, 'í', 'i');
--      v_direccion := REPLACE (v_direccion, 'ó', 'o');
--      v_direccion := REPLACE (v_direccion, 'ú', 'u');
   
      v_direccion := REPLACE (v_direccion, ' de ', ' ');
      v_direccion := REPLACE (v_direccion, ' la ', ' ');
      v_direccion := REPLACE (v_direccion, ' del ', ' ');

      v_direccion := REPLACE (v_direccion, ' ', '+');

--      v_direccion := SUBSTR (v_direccion, 0, INSTR (v_direccion, ',') - 1);
   --
   --   DBMS_LOB.createtemporary (var_http_resp_clob, FALSE);
   --
   --   BEGIN
   --      x :=
   --         UTL_HTTP.request_pieces (url          => 'http://maps.google.com/maps/api/geocode/xml?address=' || (v_direccion) || '&sensor=false',
   --                                  max_pieces   => 100,
   --                                  proxy        => '10.234.23.117:8080');
   ----   EXCEPTION --no me pregunte así funciona, tiene que ver con el proxy que no se abre muy rápido
   ----      WHEN OTHERS
   ----      THEN
   ----         x :=
   ----            UTL_HTTP.request_pieces (url          => 'http://maps.google.com/maps/api/geocode/xml?address=' || (v_direccion) || '&sensor=false',
   ----                                     max_pieces   => 100,
   ----                                     proxy        => '10.234.23.117:8080');
   --   END;
   --
   --   len := 0;
   --
   --   FOR i IN 1 .. x.COUNT
   --   LOOP
   --      len := len + LENGTH (x (i));
   --      DBMS_LOB.writeappend (var_http_resp_clob, LENGTH (x (i)), x (i));
   --   END LOOP;
   --
   --   x_google_response := XMLTYPE (var_http_resp_clob);
   --   --var_http_resp_xml := xmltype (var_http_resp_clob);
   --   DBMS_LOB.freetemporary (var_http_resp_clob);

   SELECT UTL_HTTP.request ('http://maps.google.com/maps/api/geocode/xml?address=' || v_direccion || '&sensor=false') INTO v_google_response FROM DUAL;

   x_google_response := XMLTYPE (v_google_response);


   SELECT XMLELEMENT ("result",
                      XMLELEMENT ("lat", EXTRACTVALUE (x_google_response, '/GeocodeResponse/result/geometry/location/lat')),
                      XMLELEMENT ("lng", EXTRACTVALUE (x_google_response, '/GeocodeResponse/result/geometry/location/lng')),
                      XMLELEMENT ("formatted_address", EXTRACTVALUE (x_google_response, '/GeocodeResponse/result/formatted_address')))
     INTO r_geocodes
     FROM DUAL;

   --RETURN x_google_response;
   RETURN r_geocodes;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN x_google_response;
--      COMMIT;
--      RAISE;
END;
/
