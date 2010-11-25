CREATE OR REPLACE PROCEDURE CDM.fn_frame_list  AS 

    v_count_items NUMBER;

 BEGIN NULL;
htp.prn('?');
htp.prn('
');
htp.prn('
');
htp.prn('
');
  SELECT COUNT(ID) INTO v_count_items FROM GDATASOURCES; 
htp.prn('
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta http-equiv="Pragma" content="no-cache,no-store" />
    <meta http-equiv="Expires" content="-1" />
    <title>VALME en directo</title>
    <link rel="Stylesheet" href="/public/css/liquid.css" type="text/css" />
</head>
<body>
    <select onchange="parent.content.location.href=this.options[this.selectedIndex].value" 
        size="');
htp.prn( v_count_items );
htp.prn('">
        ');
  FOR C1 IN (SELECT ID, DESCR FROM GDATASOURCES WHERE IS_PUBLIC = 1) LOOP 
htp.prn('
            <option value="http://fraterno/cdm_dad/fn_table_display?p_gdatasource_id=');
htp.prn( C1.ID );
htp.prn('">');
htp.prn( C1.DESCR );
htp.prn('</option>
        ');
  END LOOP; 
htp.prn('
    </select>
</body>
</html>
');
 END;
/
