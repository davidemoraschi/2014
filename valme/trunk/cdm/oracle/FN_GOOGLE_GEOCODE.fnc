CREATE OR REPLACE FUNCTION CDM.fn_google_geocode (
   p_direccion                IN       VARCHAR2)
   RETURN XMLTYPE
AS
   v_google_response             VARCHAR2 (4000);
   x_google_response             XMLTYPE;
   r_geocodes                    XMLTYPE;
BEGIN
   UTL_HTTP.set_proxy (proxy => '10.234.23.117:8080');

   --INSERT INTO http_geocodes
   SELECT UTL_HTTP.request ('http://maps.google.com/maps/api/geocode/xml?address=' || REPLACE(p_direccion,'á','') || '&sensor=false')
   INTO   v_google_response
   FROM   DUAL;

   x_google_response := XMLTYPE (v_google_response);

   SELECT XMLELEMENT ("result"
                     ,XMLELEMENT ("lat", EXTRACTVALUE (x_google_response, '/GeocodeResponse/result/geometry/location/lat'))
                     ,XMLELEMENT ("lng", EXTRACTVALUE (x_google_response, '/GeocodeResponse/result/geometry/location/lng'))
                     ,XMLELEMENT ("formatted_address", EXTRACTVALUE (x_google_response, '/GeocodeResponse/result/formatted_address')))
   INTO   r_geocodes
   FROM   DUAL;

   RETURN r_geocodes;
--EXCEPTION
--   WHEN OTHERS
--   THEN
--      INSERT INTO http_geocodes
--                  (request)
--           VALUES ('http://maps.google.com/maps/api/geocode/xml?address=' || p_direccion || '&sensor=false');

--      COMMIT;
--      RAISE;
END; 
/

