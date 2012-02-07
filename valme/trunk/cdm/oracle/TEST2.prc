CREATE OR REPLACE PROCEDURE CDM.test2  AS 
 BEGIN NULL;
htp.prn('¿');
htp.prn('
');
htp.prn('
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Valme en Directo</title>
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">
          google.load(''visualization'', ''1'', { packages: [''corechart'', ''table'', ''gauge'', ''map''] });
    </script>
      <script type="text/javascript">
          var query1, query2, visualization1, visualization2, visualization3;

          function initialize() {
              visualization1 = new google.visualization.Gauge(document.getElementById(''visualization1''));
              visualization2 = new google.visualization.ColumnChart(document.getElementById(''visualization2''));
              visualization3 = new google.visualization.Map(document.getElementById(''visualization3''));
              query1 = new google.visualization.Query(''http://fraterno:8181/cdm_dad/gdatasource2.get_json?p_datasource_id=gauge'');
              query1.setRefreshInterval(10);
              query1.send(drawVisualization1);
              query2 = new google.visualization.Query(''http://fraterno:8181/cdm_dad/gdatasource2.get_json?p_datasource_id=addr'');
              query2.setRefreshInterval(20);
              query2.send(drawVisualization2);
           }
          function drawVisualization1(response) {
              if (response.isError()) {
                  alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
                  return;
              }
              visualization1.draw(response.getDataTable(), { legend: ''bottom'', title: ''Gauge'' });
              visualization2.draw(response.getDataTable(), { legend: ''bottom'', title: ''ColumnChart'' });
          }
          function drawVisualization2(response) {
              if (response.isError()) {
                  alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
                  return;
              }
              visualization3.draw(response.getDataTable(), { mapType: ''terrain'', title: ''Map'' });
          }
          google.setOnLoadCallback(initialize);
      </script>
</head>
<body>
    <h1>test2.7</h1>
    <div>
        <div id="visualization1" style="height: 250px; width: 400px; border: 1px solid; float: left;" />
    </div>
    <div>
        <div id="visualization2" style="height: 250px; width: 400px; border: 1px solid; float: left; margin-left: 10px" />
    </div>
    <div>
        <div id="visualization3" style="height: 250px; width: 400px; border: 1px solid; float: left; margin-left: 10px">
    </div>
</body>
</html>
');
 END;
/

