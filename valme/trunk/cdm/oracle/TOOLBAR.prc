CREATE OR REPLACE PROCEDURE CDM.toolbar  AS 
 BEGIN NULL;
owa_util.mime_header('text/html'); htp.prn('¿');
htp.prn('
');
htp.prn('
');
htp.prn('
');
htp.prn('

');
htp.prn( fn_html_constant(1) );
htp.prn('
');
htp.prn( fn_html_constant(2) );
htp.prn('
<head>
');
htp.prn( fn_html_constant(3) );
htp.prn('
');
htp.prn( fn_html_constant(4) );
htp.prn('
</head>
');
htp.prn( fn_html_page(3) );
htp.prn('
    
</html>
');
 END;
/

