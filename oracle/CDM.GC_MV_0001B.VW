CREATE OR REPLACE FORCE VIEW CDM.GC_MV_0001B
(LAT, LNG, MUN_NOMBRE)
AS 
SELECT geocode_lat + dbms_random.value(0.001, 0.029)
                     geocode_lat,
          geocode_lng + dbms_random.value(0.001, 0.029)
                     geocode_lng,
             UPPER (SUBSTR (GC_MV_0001.mun_nombre, 0, INSTR (GC_MV_0001.mun_nombre, ',') - 1))
          || ': '
          || COUNT (*) OVER (PARTITION BY GC_MV_0001.mun_nombre)
          || DECODE (COUNT (*) OVER (PARTITION BY GC_MV_0001.mun_nombre), 1, ' paciente', ' pacientes')
             mun_nombre
     FROM GC_MV_0001 JOIN GC_TB_0001 USING (mun_codigo)
/
