CREATE OR REPLACE FORCE VIEW CDM.GC_MV_0015
(NUHSA, ESTADO, FECHA_ADMISION, FECHA_ALTA, FECHA_SALIDA, 
 PROCEDENCIA, EPISODIO_URG_ID, EU_COD_CAUSA_ALTA_URG, MOTIVO_ALTA, UBICACION)
AS 
SELECT usu_bdu_nusa NUHSA, EST_NOMBRE ESTADO, AU_FECHA FECHA_ADMISION --, NUMTODSINTERVAL (EU_FHCREACION - AU_FECHA, 'DAY') ESPERA1
                                                                        --, EU_FHCREACION
         , EU_FHALTA FECHA_ALTA --, NUMTODSINTERVAL (AU_FECHASALIDA - EU_FHALTA, 'DAY') ESPERA2
                               , AU_FECHASALIDA FECHA_SALIDA --,NUMTODSINTERVAL (EU_FHALTA_REAL - AU_FECHASALIDA, 'DAY') ESPERA3
                                                             --, EU_FHALTA_REAL
                                                             --, AU_PROCEDENCIA
        ,AU_PROCEDENCIA2_TXT PROCEDENCIA, AU_EPISODIO EPISODIO_URG_ID --
                                                                     , EU_COD_CAUSA_ALTA_URG, DESCRIPCION MOTIVO_ALTA
        ,UBI_NOMBRE UBICACION
    /*, PRE_COD_PROCEDIMIENTO_URG*/
    FROM his_own.com_admision_urg@dae
         JOIN his_own.com_usuario_urg@dae
            ON (au_usuario = usu_id)
         LEFT JOIN his_own.com_episodio_urg@dae
            ON (AU_EPISODIO = EU_IDENTIFICADOR)
         /*       LEFT JOIN his_own.com_procedimiento_urg
                   ON (AU_EPISODIO = PRE_EPISODIO)*/
         LEFT JOIN his_own.com_estado_episodio_urg@dae
            ON (AU_EPISODIO = EUE_IDENTIFICADOR)
         LEFT JOIN his_own.com_m_ubicacion@dae
            ON (EUE_UBICACION = UBI_CODIGO)
         LEFT JOIN COD_CAUSA_ALTA_URG@dae
            ON (EU_COD_CAUSA_ALTA_URG = CODIGO)
         LEFT JOIN ESTADOS_URGENCIAS@dae
            ON (EUE_ESTADO = EST_IDENTIFICADOR)
   WHERE au_fecha >= TRUNC (SYSDATE)
--AND EU_COD_CAUSA_ALTA_URG = 8
ORDER BY AU_FECHA DESC
/
