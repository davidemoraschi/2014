CREATE OR REPLACE PACKAGE CDM.PX002_BUSQUEDA
AS
   /* !Remove leading zeros from month! */
   con_str_DATEFORMAT   CONSTANT VARCHAR2 (12) := 'FMyyyy,mm,dd';

   --PROCEDURE xml (p_NUHSA IN VARCHAR2 := '0');

   PROCEDURE php (p_NUHSA IN VARCHAR2 := '0', p_TIMESPAN IN VARCHAR2 := '1');

   PROCEDURE xml (p_NUHSA IN VARCHAR2 := '0', p_TIMESPAN IN VARCHAR2 := '1');

   PROCEDURE xml (p_ADMISION_ID IN VARCHAR2 := '0');

   PROCEDURE streamDataSet (p_data_set XMLTYPE := NULL);
END PX002_BUSQUEDA;
/
