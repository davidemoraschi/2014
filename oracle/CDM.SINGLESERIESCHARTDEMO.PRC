CREATE OR REPLACE PROCEDURE CDM.singleserieschartdemo
AS
   v_graph_attr   flashchartgraphattrtype := flashchartgraphattrtype ();
   v_data_row     flashchartsettype := flashchartsettype ();
   v_data_set     flashchartrowsettype := flashchartrowsettype ();
BEGIN
   HTP.htmlOpen;
   HTP.bodyOpen;
   HTP.p ('<div id="chartdiv">');
   fusionflashcharts.addchart (p_chart_id       => 'DemoChart',
                               p_chart_type     => fusionflashcharts.fcf_bar2d,
                               p_chart_width    => '800',
                               p_chart_height   => '600',
                               p_data_url       => 'aesdataset.xml');
   HTP.p ('</div>');
   HTP.bodyClose;
   HTP.htmlClose;
END;
/
