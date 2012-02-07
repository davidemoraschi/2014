CREATE OR REPLACE PROCEDURE CDM.test1  AS 
 BEGIN NULL;
owa_util.mime_header('text/html'); htp.prn('﻿');
htp.prn('
');
htp.prn('
');
htp.prn('
');
htp.prn('
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>Valme en Directo</title>
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
</head>
<body>
    <h1>test</h1>
</body>
</html>
');
 END;
/

