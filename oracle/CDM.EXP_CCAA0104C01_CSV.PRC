CREATE OR REPLACE PROCEDURE CDM.EXP_ccaa0104c01_CSV
AS
   CURSOR c_data
   IS
        SELECT objectid, data, nombre
          FROM ccaa0104c01
      ORDER BY objectid;

   v_file   UTL_FILE.FILE_TYPE;
BEGIN
   v_file := UTL_FILE.FOPEN (location => 'MAPS_DIR', filename => 'ccaa0104c01.csv', open_mode => 'w', max_linesize => 32767);

   FOR cur_rec IN c_data
   LOOP
      UTL_FILE.PUT_LINE (v_file, cur_rec.objectid || ',' || cur_rec.data || ',' || cur_rec.nombre);
   END LOOP;

   UTL_FILE.FCLOSE (v_file);
EXCEPTION
   WHEN OTHERS
   THEN
      UTL_FILE.FCLOSE (v_file);
END;
/
