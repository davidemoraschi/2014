CREATE OR REPLACE PROCEDURE CDM.fn_bulk_google_goecode
AS
   v_lat                         NUMBER;
   v_lng                         NUMBER;
   v_formatted_address           VARCHAR2 (250);
   xml_temp                      XMLTYPE;
BEGIN
   FOR c1 IN (SELECT *
              FROM   gc_tb_0001
              WHERE  prv_comunidad = '4'
              AND    geocode_lat = 0
              AND    geocode_lng = 0)
   LOOP
      BEGIN
         SELECT fn_google_geocode (c1.mun_nombre || c1.prv_nombre)
         INTO   xml_temp
         FROM   DUAL;

         SELECT TO_NUMBER (EXTRACTVALUE (xml_temp, '/result/lat'), '999G999G999D9999999', 'NLS_NUMERIC_CHARACTERS = ''.,''')
         INTO   v_lat
         FROM   DUAL;

         SELECT TO_NUMBER (EXTRACTVALUE (xml_temp, '/result/lng'), '999G999G999D9999999', 'NLS_NUMERIC_CHARACTERS = ''.,''')
         INTO   v_lng
         FROM   DUAL;

         SELECT EXTRACTVALUE (xml_temp, '/result/formatted_address')
         INTO   v_formatted_address
         FROM   DUAL;

         UPDATE gc_tb_0001
            SET geocode_lat = v_lat
               ,geocode_lng = v_lng
               ,mun_nombre = v_formatted_address
          WHERE mun_codigo = c1.mun_codigo;

         --NULL;
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            COMMIT;
      END;
   END LOOP;
--      RAISE;
END; 
/

