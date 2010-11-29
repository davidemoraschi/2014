CREATE OR REPLACE FORCE VIEW CDM.GC_VW_0001_IN_CONNECT_RATE
(INDICADOR, DISPATCHER, BYTES, MINUTOS, TIEMPO_DE_VIDA, 
 MAXIMO, MEDIA)
AS 
SELECT 'in_connect_rate' indicador, name dispatcher, CUR_IN_CONNECT_RATE bytes, (SCALE_IN_CONNECT / 100 / 60) minutos
           , (TTL_IN_CONNECT / 100 / 60) tiempo_de_vida /*minutos*/
                                                       , MAX_IN_CONNECT_RATE MAXIMO, MAX_IN_CONNECT_RATE MEDIA
       FROM v$dispatcher_rate
   ORDER BY name
/
