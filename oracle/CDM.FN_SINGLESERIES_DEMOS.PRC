CREATE OR REPLACE PROCEDURE CDM.fn_singleseries_demos
AS
BEGIN
   HTP.htmlOpen;
      HTP.bodyOpen;
         /* Javascript function that alters the chart object tag and refreshes the chart/graph.
         Notice the use of the swf streaming procedure FusionFlashCharts.swf in the
         JavaScript function below.
         */
         HTP.p ('<script>');
         HTP.p
            ('function changeGraphType(p_graph_id,p_type){
                v_value_url = "FusionFlashCharts.swf?p_chart_code="+p_type;
                v_chart_object = document.getElementById(p_graph_id);
                v_movie_object = document.getElementById("movie_"+p_graph_id);
                v_embed_object = document.getElementById("embed_"+p_graph_id);
                v_movie_object.setAttribute("value",v_value_url);
                v_embed_object.setAttribute("src",v_value_url);
                }');
         HTP.p ('</script>');
         HTP.p ('<div id="switchCharts">');
         HTP.p ('<form id="selectForm">');
         HTP.p ('<select onchange="javascript:changeGraphType(''DemoChart'',this.value);">');
         /* Create a selection list containing all types of Single Series Flash charts. */
         HTP.p ('<option value="' || fusionflashcharts.fcf_area2d || '">2D Area Chart</option>');
         HTP.p ('<option value="' || fusionflashcharts.fcf_bar2d || '">2D Bar Chart</option>');
         HTP.p ('<option value="' || fusionflashcharts.fcf_column2d || '">2D Column Chart</option>');
         HTP.p ('<option value="' || fusionflashcharts.fcf_column3d || '">3D Column Chart</option>');
         HTP.p ('<option value="' || fusionflashcharts.fcf_doughnut2d || '">2D Doughnut Chart</option>');
         HTP.p ('<option value="' || fusionflashcharts.fcf_pie2d || '">2D Pie Chart</option>');
         HTP.p ('<option value="' || fusionflashcharts.fcf_pie3d || '">3D Pie Chart</option>');
         HTP.p ('<option value="' || fusionflashcharts.fcf_line || '">Line Chart</option>');
         HTP.p ('</select>');
         HTP.p ('</form>');
         HTP.p ('</div>');
         HTP.p ('<div id="chartdiv">');
         /*
         Add the <object/> tag to the page that renders the flash object.
         Notice the reference to singleSeriesChartData.xml! This is the
         Packaged procedure created in the previous example.
         */
         fusionflashcharts.addchart (p_chart_id          => 'DemoChart'
                                    ,p_chart_type        => fusionflashcharts.fcf_bar2d
                                    ,p_chart_width       => '800'
                                    ,p_chart_height      => '600'
                                    ,p_data_url          => 'aesdataset');
--                                    ,p_data_url          => 'PKG_singleseries_data.xml');
         HTP.p ('</div>');
      HTP.bodyClose;
   HTP.htmlClose;
END;
/
