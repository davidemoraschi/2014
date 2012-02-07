CREATE OR REPLACE PROCEDURE CDM.test  AS 
 BEGIN NULL;
owa_util.mime_header('text/html'); htp.prn('
');
htp.prn('
');
htp.prn('
<!--
  copyright (c) 2009 Google inc.
 
  You are free to copy and use this sample.
  License can be found here: http://code.google.com/apis/ajaxsearch/faq/#license
-->
 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>
      Google Visualization API Sample
    </title>
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load(''visualization'', ''1'', {packages: [''table'', ''motionchart'', ''annotatedtimeline'']});
    </script>
    <script type="text/javascript">
    var visualization;
 
    function drawVisualization() {
      var query1 = new google.visualization.Query(
          ''http://lab2.oraperf.com:8070/igoogle/datasource2?tabname=TEST2'');
      var query2 = new google.visualization.Query(
          ''http://lab2.oraperf.com:8070/igoogle/datasource2?tabname=TEST2'');
      var query3 = new google.visualization.Query(
          ''http://lab2.oraperf.com:8070/igoogle/datasource2?tabname=TEST2'');
 
      
      // Apply query language.
      query1.setQuery(''SELECT col1, col2,col3 label col1 Date, col2 Number, Col3 String'');
      
      // Send the query with a callback function.
      query1.send(handleQueryResponse1);
      
      // Apply query language.
      query2.setQuery(''SELECT col3, col1, col2 label col1 Date, col2 Number, Col3 String'');
      
      // Send the query with a callback function.
      query2.send(handleQueryResponse2);
 
      // Apply query language.
      query3.setQuery(''select col1, col2 label col1 Datum, col2 Nummer'');
      
      // Send the query with a callback function.
      query3.send(handleQueryResponse3);
    }
    
    function handleQueryResponse1(response) {
      if (response.isError()) {
        alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
        return;
      }
    
      var data = response.getDataTable();
      visualization = new google.visualization.Table(document.getElementById(''visualization1''));
      visualization.draw(data, {''width'': 800, ''height'': 200});
    }
 
    function handleQueryResponse2(response) {
      if (response.isError()) {
        alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
        return;
      }
    
      var data = response.getDataTable();
      visualization = new google.visualization.MotionChart(document.getElementById(''visualization2''));
      visualization.draw(data, {''width'': 800, ''height'': 400});
    }
 
    function handleQueryResponse3(response) {
      if (response.isError()) {
        alert(''Error in query: '' + response.getMessage() + '' '' + response.getDetailedMessage());
        return;
      }
    
      var data = response.getDataTable();
      visualization = new google.visualization.AnnotatedTimeLine(document.getElementById(''visualization3''));
      visualization.draw(data, {''width'': 800, ''height'': 400});
    }
 
    google.setOnLoadCallback(drawVisualization);
    </script>
  </head>
  <body style="font-family: Arial;border: 0 none;">
    <h1>Plain table example</h1>
    <div id="visualization1" style="height: 300px; width: 800px;"></div>
    <h1>MotionChart example</h1>
    <div id="visualization2" style="height: 450px; width: 800px;"></div>
    <h1>AnnotatedTimeline example</h1>
    <div id="visualization3" style="height: 450px; width: 800px;"></div>
  </body>
</html>

');
 END;
/

