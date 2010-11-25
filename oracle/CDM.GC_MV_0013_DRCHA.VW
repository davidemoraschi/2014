CREATE OR REPLACE FORCE VIEW CDM.GC_MV_0013_DRCHA
(ORD, CONTROL)
AS 
SELECT SUBSTR (UBI_NOMBRE, 1, 1) ORD
         ,'<span alt="' || UBI_CAH_CODIGO || UBI_CODIGO || '">' || UBI_NOMBRE || '</span>' AS CONTROL
     FROM GC_MV_0013
    WHERE SUBSTR (UBI_NOMBRE, 1, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9') AND INSTR (UBI_NOMBRE, 'Derecha') > 0
/
