CREATE OR REPLACE PROCEDURE CDM.content  AS 
 BEGIN NULL;
owa_util.mime_header('text/html'); htp.prn('¿');
htp.prn('
');
htp.prn('
');
htp.prn('
');
htp.prn('

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
   <head>
      <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
      <title>
         Google Visualization API
      </title>
      <script type="text/javascript" src="http://www.google.com/jsapi"></script>
      <script type="text/javascript">
          google.load(''visualization'', ''1'', { packages: [''columnchart'', ''linechart''] });
      </script>
      <script type="text/javascript">
          var query1, visualization1;
          function initialize() {
              visualization1 = new google.visualization.ColumnChart(document.getElementById(''visualization1''));
              query1 = new google.visualization.Query(''http://jansipke.nl/res/visualization/chart-data.py'');
              query1.setRefreshInterval(2);
              query1.send(drawVisualization1);
           }
          function drawVisualization1(response) {
              if (response.isError()) {
                  alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
                  return;
              }
              visualization1.draw(response.getDataTable(), { legend: ''bottom'', title: ''ColumnChart'' });
          }
          google.setOnLoadCallback(initialize);
      </script>
   </head>
   <body>
      <div>
         <div id="visualization1" style="height: 600px; width: 800px; border: 1px solid; float: left;" />
      </div>
    </body>
</html>
');
 END;
/

