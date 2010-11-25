CREATE OR REPLACE PROCEDURE CDM.fn_table_display (
p_gdatasource_id IN VARCHAR2 default 'test') AS 
 BEGIN NULL;
htp.prn('?');
htp.prn('
');
htp.prn('
');
htp.prn('

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta http-equiv="Pragma" content="no-cache,no-store" />
    <meta http-equiv="Expires" content="-1" />
    <title>VALME en directo</title>
    <link rel="Stylesheet" href="/public/css/liquid.css" type="text/css" />
    <script src="/public/js/jsapi.js" type="text/javascript"></script>
    <style type="text/css" media="screen, print">
        @font-face
        {
            font-family: "MyBlueRoom";
            src: url("http://fraterno/public/ttf/MyBlueRoom.ttf");
        }
        
        #clock
        {
            font-family: "MyBlueRoom" , sans-serif;
            font-size: 1em;
            color: rgba(200, 255, 0, 0.7);
        }
    </style>
    <script type="text/javascript">
        function init() {
            timeDisplay = document.createTextNode("");
            document.getElementById("clock").appendChild(timeDisplay);
        }

        function updateClock() {
        //debugger
            var currentTime = new Date();
            var currentHours = currentTime.getHours();
            var currentMinutes = currentTime.getMinutes();
            var currentSeconds = currentTime.getSeconds();
            currentMinutes = (currentMinutes < 10 ? "0" : "") + currentMinutes;
            currentSeconds = (currentSeconds < 10 ? "0" : "") + currentSeconds;
            var timeOfDay = (currentHours < 12) ? "AM" : "PM";
            var currentTimeString = currentHours + "." + currentMinutes + "." + currentSeconds;
            document.getElementById("clock").firstChild.nodeValue = currentTimeString;
        }
        function switchClock() {
            if (document.getElementById("clock").style.color == ''red'') {
                document.getElementById("clock").style.color = "rgba(200, 255, 0, 0.7)";
                clearInterval(wooYayIntervalId);
            }
            else {
                document.getElementById("clock").style.color = "red";
                //                alert(''./cdm_dad/fn_informe_hablado'');
                //                wooYayIntervalId = setInterval("DHTMLSound(''./cdm_dad/fn_informe_hablado'')", 3000);
            }
        }
        function DHTMLSound(surl) {
            document.getElementById("span_voice_comment").innerHTML =
            "<embed src=''" + surl + "'' hidden=true autostart=true loop=false>";
        }
    </script>
    <script type="text/javascript">
        google.load(''visualization'', ''1'', { packages: [''corechart'', ''table''], language: ''es'' });
        var str_web_query = ''http://fraterno.valme.net/cdm_dad/gdatasource2.get_json?p_datasource_id=');
htp.prn( p_gdatasource_id );
htp.prn(''';
        var query2, visualization2;
        function initialize() {

            visualization2 = new google.visualization.Table(document.getElementById(''google_visualization_1''));
            query2 = new google.visualization.Query(str_web_query);
            query2.setRefreshInterval(10);
            query2.send(drawVisualization2);
        }
        function drawVisualization2(response) {
            if (response.isError()) {
                alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
                return;
            }
            var TcssClassNames = { headerRow: ''th'', tableRow: ''tic'', oddTableRow: ''tac'', hoverTableRow: ''toc'', selectedTableRow: ''toc'' };
            var Tdata = new google.visualization.DataTable();
            Tdata = response.getDataTable();
            //var formatter = new google.visualization.ArrowFormat();
            //formatter.format(Tdata, 4);
            visualization2.draw(Tdata, { allowHtml: true, cssClassNames: TcssClassNames });

        }
        google.setOnLoadCallback(initialize);
    </script>
    <script type="text/javascript">
    </script>
</head>
<body>
    <div id="google_visualization_1" />
</body>
</html>
');
 END;
/
