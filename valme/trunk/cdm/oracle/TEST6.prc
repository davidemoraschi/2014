CREATE OR REPLACE PROCEDURE CDM.test6  AS 
 BEGIN NULL;
htp.prn('�');
htp.prn('
');
htp.prn('
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Valme en Directo</title>
    <link rel="stylesheet" href="http://fraterno:8181/images/css/posterous.css" type="text/css" />
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">
          google.load(''visualization'', ''1'', { packages: [''corechart'', ''gauge'', ''map''] });
    </script>
      <script type="text/javascript">
          var query1, query2, query3, visualization1, visualization2, visualization3;

          function initialize() {
              visualization1 = new google.visualization.Gauge(document.getElementById(''visualization1''));
              visualization2 = new google.visualization.ColumnChart(document.getElementById(''visualization2''));
              visualization3 = new google.visualization.Map(document.getElementById(''visualization3''));
              query1 = new google.visualization.Query(''http://fraterno:8181/cdm_dad/gdatasource2.get_json?p_datasource_id=gauge'');
              query1.setRefreshInterval(10);
              query1.send(drawVisualization1);
              query2 = new google.visualization.Query(''http://fraterno:8181/cdm_dad/gdatasource2.get_json?p_datasource_id=dae'');
              query2.setRefreshInterval(10);
              query2.send(drawVisualization2);
              query3 = new google.visualization.Query(''http://fraterno:8181/cdm_dad/gdatasource2.get_json?p_datasource_id=addr'');
              query3.setRefreshInterval(60);
              query3.send(drawVisualization3);
           }
          function drawVisualization1(response) {
              if (response.isError()) {
                  alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
                  return;
              }
              visualization1.draw(response.getDataTable(), { legend: ''bottom'', title: ''Gauge'' });
          }
          function drawVisualization2(response) {
              if (response.isError()) {
                  alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
                  return;
              }
              visualization2.draw(response.getDataTable(), { legend: ''top'', fontName: ''Microsoft Sans Serif''
                ,hAxis: { textStyle: {color: ''black'', fontName: ''Verdana'', fontSize: 10} }
                ,backgroundColor: ''lightBlue''
                ,colors: [''goldenrod'',''green''] });
          }
          function drawVisualization3(response) {
              if (response.isError()) {
                  alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
                  return;
              }
              visualization3.draw(response.getDataTable(), { mapType: ''normal'', title: ''Map'', showTip: ''true'' });
          }
          google.setOnLoadCallback(initialize);
      </script>
      <style>
      </style>
</head>
<body>
<div id="wrap" class="both">
    <div id="title">
        <h1><a href="#" class="textfix">Cuadro de mando VALME en directo</a></h1>
    </div>
<TABLE BORDER=0 CELLPADDING=4>
    <TR><TD>
    <div>
        <div class="one" id="visualization1" />
    </div>
    </TD><TD>
    <div>
        <div class="one" id="visualization3" />
    </div>
    </TD></TR>
    <TR><TD COLSPAN=2>
    <div>
        <div class="two" id="visualization2" />
    </div>
    </TD></TR>
    </TABLE>
</div>
</body>
</html>
');
 END;
/

