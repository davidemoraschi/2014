CREATE OR REPLACE PROCEDURE CDM.dump_table_to_csv (p_tname IN VARCHAR2, p_dir IN VARCHAR2, p_filename IN VARCHAR2)
IS
   l_output        UTL_FILE.file_type;
   l_theCursor     INTEGER DEFAULT DBMS_SQL.open_cursor;
   l_columnValue   VARCHAR2 (4000);
   l_status        INTEGER;
   l_query         VARCHAR2 (1000) DEFAULT 'select * from ' || p_tname;
   l_colCnt        NUMBER := 0;
   l_separator     VARCHAR2 (1);
   l_descTbl       DBMS_SQL.desc_tab;
BEGIN
   l_output := UTL_FILE.fopen (p_dir, p_filename, 'w');

   EXECUTE IMMEDIATE 'alter session set nls_date_format=''dd-mon-yyyy hh24:mi:ss'' ';

   DBMS_SQL.parse (l_theCursor, l_query, DBMS_SQL.native);
   DBMS_SQL.describe_columns (l_theCursor, l_colCnt, l_descTbl);

   FOR i IN 1 .. l_colCnt
   LOOP
      UTL_FILE.put (l_output, l_separator || '"' || l_descTbl (i).col_name || '"');
      DBMS_SQL.define_column (l_theCursor,
                              i,
                              l_columnValue,
                              4000);
      l_separator := ',';
   END LOOP;

   UTL_FILE.new_line (l_output);

   l_status := DBMS_SQL.execute (l_theCursor);

   WHILE (DBMS_SQL.fetch_rows (l_theCursor) > 0)
   LOOP
      l_separator := '';

      FOR i IN 1 .. l_colCnt
      LOOP
         DBMS_SQL.COLUMN_VALUE (l_theCursor, i, l_columnValue);
         UTL_FILE.put (l_output, l_separator || l_columnValue);
         l_separator := ',';
      END LOOP;

      UTL_FILE.new_line (l_output);
   END LOOP;

   DBMS_SQL.close_cursor (l_theCursor);
   UTL_FILE.fclose (l_output);

   EXECUTE IMMEDIATE 'alter session set nls_date_format=''dd-MON-yy'' ';
EXCEPTION
   WHEN OTHERS
   THEN
      EXECUTE IMMEDIATE 'alter session set nls_date_format=''dd-MON-yy'' ';

      RAISE;
END;
/
