CREATE OR REPLACE PROCEDURE CDM.test3  AS 
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
          var query1, query2, query3, visualization1, visualization2, visualization3, visualization4;
          function initialize() {
              visualization1 = new google.visualization.Gauge(document.getElementById(''visualization1''));
              visualization2 = new google.visualization.ColumnChart(document.getElementById(''visualization2''));
              visualization3 = new google.visualization.Map(document.getElementById(''visualization3''));
              visualization4 = new google.visualization.Table(document.getElementById(''visualization4''));
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
              visualization2.draw(response.getDataTable(), { legend: ''top'', title: ''Actividad''
                ,hAxis: {title: ''Unidad Funcional'', titleTextStyle: {color: ''black''}}
                ,backgroundColor: ''#FFFACD''
                ,colors: [''blue'',''green''] });
              visualization4.draw(response.getDataTable(), {legend: ''bottom'', title: ''Datos''});
          }
          function drawVisualization3(response) {
              if (response.isError()) {
                  alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
                  return;
              }
              visualization3.draw(response.getDataTable(), { mapType: ''terrain'', title: ''Map'' });
          }
          google.setOnLoadCallback(initialize);
      </script>
      <style>
          body{
                background: #000 url(http://posterous.com/themes/fluid/background-body-repeat.png) repeat-y top center ;
                font-size:11px;
                font-family:  "Lucida Grande", "Lucida Sans", "Lucida Sans Unicode", Geneva, Verdana, sans-serif ;
                text-shadow: #000 0px 1px 0px;
            }
            #wrap{
                width: 905px;
                padding-left:28px;
                padding-right:28px;
                margin:0 auto;
                position:relative;
                overflow:hidden;
                background: url(http://posterous.com/themes/fluid/background-top.jpg) no-repeat top center;
            }
            #title{
                height: 109px;
                background: url(http://posterous.com/themes/fluid/background-title.png) repeat-x center top;
                float:left;
                position:relative;
                margin-left:68px;
                margin-top:40px;
                text-shadow: #000 0px 2px 0px;    

            }
            #title h1{
                font-size:42px;
                font-weight:bold;
                text-shadow: #fff 0px 1px 0px;
                margin-top:15px;
                padding-left:5px;
                padding-right:5px;
    
            }
            #title a{
                text-decoration:none;
                color:#fff;
                font-weight:bold;
                text-shadow: #fff 0px 1px 0px;
                padding:0;
                display:block;
            }
            #title b{
                height:93px;
                width:36px;
                position: absolute;
                top:0px;
            }
            #title b.left{
                background: url(http://posterous.com/themes/fluid/background-title.png) top left;
                left:-36px;
            }
            #title b.right{
                background: url(http://posterous.com/themes/fluid/background-title.png) top right;
                right:-36px;    
            }
      </style>
</head>
<body>
<div id="wrap">
        <div id="visualization1" style="height: 250px; width: 400px; border: 1px solid; float: left; margin-left: 120px" />
    </div>
    <div>
        <div id="visualization3" style="height: 250px; width: 400px; float: right; margin-right: 170px" />
    </div>
    <div>
        <div id="visualization2" style="height: 400px; width: 600px; float: left; margin-left: 120px" />
    </div>
    <div>
        <div id="visualization4" style="height: 400px; width: 300px; border: 1px solid; float: right; margin-right: 170px" />       
</div>
</body>
</html>
');
 END;
/

