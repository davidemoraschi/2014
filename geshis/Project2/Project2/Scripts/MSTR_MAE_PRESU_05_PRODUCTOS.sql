DROP MATERIALIZED VIEW MSTR_MAE_PRESU_05_PRODUCTOS;
DROP TABLE MSTR_MAE_PRESU_05_PRODUCTOS;

CREATE TABLE MSTR_MAE_PRESU_05_PRODUCTOS
(
   SUBID_PRODUCTO   PRIMARY KEY
  ,NATID_PRODUCTO   NOT NULL
  ,DESCR_PRODUCTO   NOT NULL
  ,SUBID_GRUPO      NOT NULL
  ,SUBID_SUBGRUPO   NOT NULL
  ,SUBID_FAMILIA    NOT NULL
  ,SUBID_EPIGRAFE   NOT NULL
)
ORGANIZATION INDEX
PARALLEL 6
NOLOGGING
NOMONITORING
AS
   SELECT TO_NUMBER ("codart") SUBID_PRODUCTO, RTRIM ("codart") NATID_PRODUCTO, RTRIM ("nomart") DESCR_PRODUCTO
         ,TO_NUMBER (NVL ("gruart", -1)) SUBID_GRUPO, TO_NUMBER ("gruart" * 100 + "subart") SUBID_SUBGRUPO
         ,TO_NUMBER (DECODE ("famart",  '   ', -1,  NULL, -1,  "gruart" || "subart" || "famart")) SUBID_FAMILIA
         ,SUBID_EPIGRAFE
     FROM artic@INFORMIX_GESHIS JOIN MSTR_AUX_ARTIC_PRESU_04_EPIGR ON (SUBID_ARTICULO = "codart")
    WHERE NULL IS NOT NULL;

CREATE MATERIALIZED VIEW MSTR_MAE_PRESU_05_PRODUCTOS ON PREBUILT TABLE
AS
   SELECT TO_NUMBER ("codart") SUBID_PRODUCTO, RTRIM ("codart") NATID_PRODUCTO, RTRIM ("nomart") DESCR_PRODUCTO
         ,TO_NUMBER (NVL ("gruart", -1)) SUBID_GRUPO, TO_NUMBER ("gruart" * 100 + "subart") SUBID_SUBGRUPO
         ,TO_NUMBER (DECODE ("famart",  '   ', -1,  NULL, -1,  "gruart" || "subart" || "famart")) SUBID_FAMILIA
         ,SUBID_EPIGRAFE
     FROM artic@INFORMIX_GESHIS JOIN MSTR_AUX_ARTIC_PRESU_04_EPIGR ON (SUBID_ARTICULO = "codart");

    ALTER TABLE MSTR_MAE_PRESU_05_PRODUCTOS ADD
CONSTRAINT UK_MSTR_MAE_PRESU_05_PRODU
 UNIQUE  (NATID_PRODUCTO)
 ENABLE
 VALIDATE;

 ALTER TABLE MSTR_MAE_PRESU_05_PRODUCTOS ADD
CONSTRAINT FK_MAE_PRESU_05_PRODU_EPIGR
 FOREIGN KEY (SUBID_EPIGRAFE)
 REFERENCES MSTR_MAE_PRESU_04_EPIGRAFES (SUBID_EPIGRAFE)
 ENABLE
 VALIDATE;

 ALTER TABLE MSTR_MAE_PRESU_05_PRODUCTOS ADD
CONSTRAINT FK_MAE_PRESU_05_PRODU_GRUPO
 FOREIGN KEY (SUBID_GRUPO)
 REFERENCES GESHIS_GRUAR (SUBID_GRUPO)
 ENABLE
 VALIDATE;

-- ALTER TABLE MSTR_MAE_PRESU_05_PRODUCTOS ADD
--CONSTRAINT FK_MAE_PRESU_05_PRODU_SUBGRUPO
-- FOREIGN KEY (SUBID_SUBGRUPO)
-- REFERENCES GESHIS_SUBAR (SUBID_SUBGRUPO)
-- ENABLE
-- VALIDATE;

 ALTER TABLE MSTR_MAE_PRESU_05_PRODUCTOS ADD
CONSTRAINT FK_MAE_PRESU_05_PRODU_FAMILIA
 FOREIGN KEY (SUBID_FAMILIA)
 REFERENCES GESHIS_FAMAR (SUBID_FAMILIA)
 ENABLE
 VALIDATE;

CREATE INDEX IDX_01_MAE_PRESU_05_PRODUCTOS
   ON MSTR_MAE_PRESU_05_PRODUCTOS (SUBID_EPIGRAFE)
   PARALLEL 6
   NOLOGGING
   COMPRESS;

CREATE INDEX IDX_02_MAE_PRESU_05_PRODUCTOS
   ON MSTR_MAE_PRESU_05_PRODUCTOS (SUBID_GRUPO)
   PARALLEL 6
   NOLOGGING
   COMPRESS;


CREATE INDEX IDX_03_MAE_PRESU_05_PRODUCTOS
   ON MSTR_MAE_PRESU_05_PRODUCTOS (SUBID_SUBGRUPO)
   PARALLEL 6
   NOLOGGING
   COMPRESS;


CREATE INDEX IDX_04_MAE_PRESU_05_PRODUCTOS
   ON MSTR_MAE_PRESU_05_PRODUCTOS (SUBID_FAMILIA)
   PARALLEL 6
   NOLOGGING
   COMPRESS;

BEGIN
   DBMS_MVIEW.REFRESH ('MSTR_MAE_PRESU_05_PRODUCTOS');
END;
/

ALTER TABLE MSTR_MAE_PRESU_05_PRODUCTOS READ ONLY;
COMMIT;

EXEC dbms_stats.gather_table_stats( user, 'MSTR_MAE_PRESU_05_PRODUCTOS' );