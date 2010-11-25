CREATE OR REPLACE FORCE VIEW CDM.GC_WV_0010
(ULTIMOS_INGRESOS, HORA_REGISTRO)
AS 
SELECT NUHSA ULTIMOS_INGRESOS, TO_CHAR (hora_reg_ingreso, 'HH24:MI') HORA_REGISTRO
       FROM his_own.adm_admision@dae JOIN his_own.com_usuario@dae ON (usuario = id_usuario)
      WHERE fch_ingreso = TRUNC (SYSDATE) AND epis_contab = 1 AND modalidad_asist = 1
   ORDER BY hora_reg_ingreso DESC
/
