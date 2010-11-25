CREATE OR REPLACE PROCEDURE CDM.singleserieschartdemos
AS
   v_graph_attr   flashchartgraphattrtype := flashchartgraphattrtype ();
   v_data_row     flashchartsettype := flashchartsettype ();
   v_data_set     flashchartrowsettype := flashchartrowsettype ();
BEGIN
   HTP.htmlOpen;
   HTP.bodyOpen;
   /* Javascript function that alters the chart object tag and refreshes the chart/graph. */
   HTP.p ('<SCRIPT>');
   HTP.
    p (
      '
                    var _kbcXmlHttp;
                    var _kbcRespText = new String();
                    var func_GetResponseText = function getResponsetext() {
                        _kbcRespText = new String();
                        if (_kbcXmlHttp.readyState == 4) {
                            _kbcRespText = _kbcXmlHttp.responseText;
                        }
                    }
                    function initXmlHttp() {
                        if (window.XMLHttpRequest) {
                            //IE7, FireFox, Chrome, Opera
                            _kbcXmlHttp = new XMLHttpRequest();
                        } else if (window.ActiveXObject) {
                            //IE6
                            _kbcXmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
                        }
                    }
                    function executeXmlHttpSynch(p_url, p_statechange_func) {
                        _kbcXmlHttp.open("GET", p_url, false);
                        _kbcXmlHttp.send(null);
                        p_statechange_func();
                    }
                    function executeXmlHttpAsynch(p_url, p_statechange_func) {
                        _kbcXmlHttp.onreadystatechange = p_statechange_func;
                        _kbcXmlHttp.open("GET", p_url, true);
                        _kbcXmlHttp.send(null);
                    }
                    function getXmlHttpResponseText() {
                        return _kbcRespText;
                    }
                    function changeGraphType(p_graph_id, p_type) {
                        initXmlHttp();
                        v_value_url = "FusionFlashCharts.addChart?p_chart_id=" 
                            + p_graph_id + "&p_chart_type=" + p_type 
                            + "&p_chart_width=800&p_chart_height=600&p_data_url=aesdataset";
                        v_chart_div = document.getElementById("chartdiv");
                        executeXmlHttpSynch(v_value_url, func_GetResponseText);
                        v_chart_div.innerHTML = getXmlHttpResponseText();
                    }
      ');
   HTP.p ('</script>');
   HTP.p ('<div id="switchCharts">');
   HTP.p ('<form id="selectForm">');
   HTP.p ('<select onchange="javascript:changeGraphType(''DemoChart'',this.value);">');
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
   fusionflashcharts.addchart (p_chart_id       => 'DemoChart',
                               p_chart_type     => fusionflashcharts.fcf_area2d,
                               p_chart_width    => '800',
                               p_chart_height   => '600',
                               p_data_url       => 'aesdataset');
   HTP.p ('</div>');
   HTP.bodyClose;
   HTP.htmlClose;
END;
/
