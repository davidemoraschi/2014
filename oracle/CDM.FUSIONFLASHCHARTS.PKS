CREATE OR REPLACE PACKAGE CDM.FusionFlashCharts AS

  /* NUMERIC BOOLEAN CONSTANTS */

     NUMERIC_TRUE  CONSTANT NUMBER(1) := 1;
     NUMERIC_FALSE CONSTANT NUMBER(1) := 0;

  /*
      Hex Color Codes.
      This is small list to get you started. 

  */
      
      BLACK       CONSTANT VARCHAR2(6) := '000000';
      WHITE       CONSTANT VARCHAR2(6) := 'FFFFFF';

      BLUE        CONSTANT VARCHAR2(6) := '0000FF';
      AQUA        CONSTANT VARCHAR2(6) := '00FFFF';
      DARKBLUE    CONSTANT VARCHAR2(6) := '00008B';
      MEDIUMBLUE  CONSTANT VARCHAR2(6) := '0000CD';
      NAVYBLUE    CONSTANT VARCHAR2(6) := '000080';

      RED         CONSTANT VARCHAR2(6) := 'FF0000';
      DARKRED     CONSTANT VARCHAR2(6) := '8B0000';
      MAROON      CONSTANT VARCHAR2(6) := '800000';
      CRIMSON     CONSTANT VARCHAR2(6) := 'DC143C';
      DEEPPINK    CONSTANT VARCHAR2(6) := 'FF1493';

      GREEN       CONSTANT VARCHAR2(6) := '008000';
      DARKGREEN   CONSTANT VARCHAR2(6) := '006400';
      LIME        CONSTANT VARCHAR2(6) := '00FF00';
      FORESTGREEN CONSTANT VARCHAR2(6) := '228B22';

      YELLOW      CONSTANT VARCHAR2(6) := 'FFFF00';
      GOLD        CONSTANT VARCHAR2(6) := 'FFD700';

      ORANGE      CONSTANT VARCHAR2(6) := 'FFA500';
      DARKORANGE  CONSTANT VARCHAR2(6) := 'FF8C00';
      ORANGERED   CONSTANT VARCHAR2(6) := 'FF4500';

      PURPLE      CONSTANT VARCHAR2(6) := '800080';
      INDIGO      CONSTANT VARCHAR2(6) := '4B0082';


  /*

      Chart Type Codes

  */
     -- Fusion Charts Free Charts

     FCF_Area2D                 CONSTANT VARCHAR2(5) := 'AR2DF';
     FCF_Bar2D                  CONSTANT VARCHAR2(5) := 'BC2DF';
     FCF_Candlestick            CONSTANT VARCHAR2(5) := 'CSTKF';
     FCF_Column2D               CONSTANT VARCHAR2(5) := 'CL2DF';
     FCF_Column3D               CONSTANT VARCHAR2(5) := 'CL3DF';
     FCF_Doughnut2D             CONSTANT VARCHAR2(5) := 'DN2DF';
     FCF_Funnel                 CONSTANT VARCHAR2(5) := 'FUNLF';
     FCF_Gantt                  CONSTANT VARCHAR2(5) := 'GNTTF';
     FCF_Line                   CONSTANT VARCHAR2(5) := 'LINEF';
     FCF_MSArea2D               CONSTANT VARCHAR2(5) := 'MA2DF';
     FCF_MSBar2D                CONSTANT VARCHAR2(5) := 'MB2DF';
     FCF_MSColumn2D             CONSTANT VARCHAR2(5) := 'MC2DF';
     FCF_MSColumn2DLineDY       CONSTANT VARCHAR2(5) := 'MCL2F';
     FCF_MSColumn3D             CONSTANT VARCHAR2(5) := 'MC3DF';
     FCF_MSColumn3DLineDY       CONSTANT VARCHAR2(5) := 'MCL3F';
     FCF_MSLine                 CONSTANT VARCHAR2(5) := 'ML2DF';
     FCF_Pie2D                  CONSTANT VARCHAR2(5) := 'PI2DF';
     FCF_Pie3D                  CONSTANT VARCHAR2(5) := 'PI3DF';
     FCF_StackedArea2D          CONSTANT VARCHAR2(5) := 'SA2DF';
     FCF_StackedBar2D           CONSTANT VARCHAR2(5) := 'SB2DF';
     FCF_StackedColumn2D        CONSTANT VARCHAR2(5) := 'SC2DF';
     FCF_StackedColumn3D        CONSTANT VARCHAR2(5) := 'SC3DF';

     -- Fusion Charts Version 3 Charts
    
     V3_Area2D                  CONSTANT VARCHAR2(5) := 'AR2D3';
     V3_Bar2D                   CONSTANT VARCHAR2(5) := 'BC2D3';
     V3_Bubble                  CONSTANT VARCHAR2(5) := 'BUBL3';
     V3_Column2D                CONSTANT VARCHAR2(5) := 'CL2D3';
     V3_Column3D                CONSTANT VARCHAR2(5) := 'CL3D3';
     V3_Doughnut2D              CONSTANT VARCHAR2(5) := 'DN2D3';
     V3_Doughnut3D              CONSTANT VARCHAR2(5) := 'DN3D3';
     V3_Line                    CONSTANT VARCHAR2(5) := 'LINE3';
     V3_MSArea                  CONSTANT VARCHAR2(5) := 'MA2D3';
     V3_MSBar2D                 CONSTANT VARCHAR2(5) := 'MB2D3';
     V3_MSBar3D                 CONSTANT VARCHAR2(5) := 'MB3D3';
     V3_MSColumn2D              CONSTANT VARCHAR2(5) := 'MC2D3';
     V3_MSColumn3D              CONSTANT VARCHAR2(5) := 'MC3D3';
     V3_MSColumn3DLineDY        CONSTANT VARCHAR2(5) := 'MCL33';
     V3_MSColumnLine3D          CONSTANT VARCHAR2(5) := 'MLC33';
     V3_MSCombi2D               CONSTANT VARCHAR2(5) := 'M2DY3';
     V3_MSCombi3D               CONSTANT VARCHAR2(5) := 'M3DY3';
     V3_MSCombiDY2D             CONSTANT VARCHAR2(5) := '2DYC3';
     V3_MSLine                  CONSTANT VARCHAR2(5) := 'ML2D3';
     V3_MSStackedColumn2D       CONSTANT VARCHAR2(5) := 'MSC23';
     V3_MSStackedColumn2DLineDY CONSTANT VARCHAR2(5) := 'M2DL3';
     V3_Pie2D                   CONSTANT VARCHAR2(5) := 'PI2D3';
     V3_Pie3D                   CONSTANT VARCHAR2(5) := 'PI3D3';
     V3_Scatter                 CONSTANT VARCHAR2(5) := 'SCTR3';
     V3_ScrollArea2D            CONSTANT VARCHAR2(5) := 'SA2D3';
     V3_ScrollColumn2D          CONSTANT VARCHAR2(5) := 'SC2D3';
     V3_ScrollCombi2D           CONSTANT VARCHAR2(5) := 'SCB23';
     V3_ScrollCombiDY2D         CONSTANT VARCHAR2(5) := 'SCY23';
     V3_ScrollLine2D            CONSTANT VARCHAR2(5) := 'SL2D3';
     V3_ScrollStackedColumn2D   CONSTANT VARCHAR2(5) := 'SSC23';
     V3_SSGrid                  CONSTANT VARCHAR2(5) := 'GRID3';
     V3_StackedArea2D           CONSTANT VARCHAR2(5) := 'ST2D3';
     V3_StackedBar2D            CONSTANT VARCHAR2(5) := 'SB2D3';
     V3_StackedBar3D            CONSTANT VARCHAR2(5) := 'SB3D3';
     V3_StackedColumn2D         CONSTANT VARCHAR2(5) := 'STC23';
     V3_StackedColumn3D         CONSTANT VARCHAR2(5) := 'SC3D3';
     V3_StackedColumn3DLineDY   CONSTANT VARCHAR2(5) := 'SCL33';     


  /* Fusion Charts V3 Style Constants */
     
	 STYLE_TYPE_FONT              CONSTANT VARCHAR2(4) := 'Font';
     STYLE_TYPE_ANIMATION         CONSTANT VARCHAR2(9) := 'Animation';
     STYLE_TYPE_SHADOW            CONSTANT VARCHAR2(6) := 'Shadow';
	 STYLE_TYPE_GLOW              CONSTANT VARCHAR2(4) := 'Glow';
	 STYLE_TYPE_BEVEL             CONSTANT VARCHAR2(5) := 'Bevel';
	 STYLE_TYPE_BLUR              CONSTANT VARCHAR2(4) := 'Blur';
	 
	 STYLE_EASING_ELASTIC         CONSTANT VARCHAR2(7) := 'elastic';
	 STYLE_EASING_BOUNCE          CONSTANT VARCHAR2(6) := 'bounce';
	 STYLE_EASING_REGULAR         CONSTANT VARCHAR2(7) := 'regular';
	 STYLE_EASING_STRONG          CONSTANT VARCHAR2(6) := 'strong';
	 STYLE_EASING_NONE            CONSTANT VARCHAR2(4) := 'none';
	 
	 STYLE_ANIMPROP_X             CONSTANT VARCHAR2(2) := '_x';
	 STYLE_ANIMPROP_Y             CONSTANT VARCHAR2(2) := '_y';
	 STYLE_ANIMPROP_XSCALE        CONSTANT VARCHAR2(7) := '_xScale';
	 STYLE_ANIMPROP_YSCALE        CONSTANT VARCHAR2(7) := '_yScale';
	 STYLE_ANIMPROP_ALPHA         CONSTANT VARCHAR2(6) := '_alpha';
	 STYLE_ANIMPROP_ROTATION      CONSTANT VARCHAR2(9) := '_rotation';
	 
	 STYLE_ANIMACRO_CHARTSTARTX   CONSTANT VARCHAR2(12) := '$chartStartX';
	 STYLE_ANIMACRO_CHARTSTARTY   CONSTANT VARCHAR2(12) := '$chartStartY';
	 STYLE_ANIMACRO_CHARTWIDTH    CONSTANT VARCHAR2(11) := '$chartWidth';
     STYLE_ANIMACRO_CHARTHEIGHT   CONSTANT VARCHAR2(12) := '$chartHeight';
     STYLE_ANIMACRO_CHARTENDX     CONSTANT VARCHAR2(10) := '$chartEndX';
     STYLE_ANIMACRO_CHARTENDY     CONSTANT VARCHAR2(10) := '$chartEndY';
	 STYLE_ANIMACRO_CHARTCENTERX  CONSTANT VARCHAR2(13) := '$chartCenterX';
	 STYLE_ANIMACRO_CHARTCENTERY  CONSTANT VARCHAR2(13) := '$chartCenterY';
	 STYLE_ANIMACRO_CANVASSTARTX  CONSTANT VARCHAR2(13) := '$canvasStartX';
	 STYLE_ANIMACRO_CANVASSTARTY  CONSTANT VARCHAR2(13) := '$canvasStartY';
	 STYLE_ANIMACRO_CANVASWIDTH   CONSTANT VARCHAR2(12) := '$canvasWidth';
	 STYLE_ANIMACRO_CANVASHEIGHT  CONSTANT VARCHAR2(13) := '$canvasHeight';
	 STYLE_ANIMACRO_CANVASENDX    CONSTANT VARCHAR2(11) := '$canvasEndX';
	 STYLE_ANIMACRO_CANVASENDY    CONSTANT VARCHAR2(11) := '$canvasEndY';
	 STYLE_ANIMACRO_CANVASCENTERX CONSTANT VARCHAR2(14) := '$canvasCenterX';
	 STYLE_ANIMACRO_CANVASCENTERY CONSTANT VARCHAR2(14) := '$canvasCenterY';
	 
	 
	 STYLE_CHARTOBJ_BACKGROUND    CONSTANT VARCHAR2(10) := 'Background';
	 STYLE_CHARTOBJ_CANVAS        CONSTANT VARCHAR2(6)  := 'Canvas';
	 STYLE_CHARTOBJ_CAPTION       CONSTANT VARCHAR2(7)  := 'Caption';
	 STYLE_CHARTOBJ_DATALABELS    CONSTANT VARCHAR2(10) := 'DataLabels';
	 STYLE_CHARTOBJ_DATAPLOT      CONSTANT VARCHAR2(8)  := 'DataPlot';
	 STYLE_CHARTOBJ_DATAVALUES    CONSTANT VARCHAR2(10) := 'DataValues';
	 STYLE_CHARTOBJ_DIVLINES      CONSTANT VARCHAR2(8)  := 'DivLines';
	 STYLE_CHARTOBJ_HGRID         CONSTANT VARCHAR2(5)  := 'HGrid';
	 STYLE_CHARTOBJ_SUBCAPTION    CONSTANT VARCHAR2(10) := 'SubCaption';
	 STYLE_CHARTOBJ_TOOLTIP       CONSTANT VARCHAR2(7)  := 'ToolTip';
	 STYLE_CHARTOBJ_TRENDLINES    CONSTANT VARCHAR2(10) := 'TrendLines';
	 STYLE_CHARTOBJ_TRENDVALUES   CONSTANT VARCHAR2(11) := 'TrendValues';
	 STYLE_CHARTOBJ_VLINES        CONSTANT VARCHAR2(6)  := 'VLines';
	 STYLE_CHARTOBJ_XAXISNAME     CONSTANT VARCHAR2(9)  := 'XAxisName';
	 STYLE_CHARTOBJ_YAXISNAME     CONSTANT VARCHAR2(9)  := 'YAxisName';
	 STYLE_CHARTOBJ_YAXISVALUES   CONSTANT VARCHAR2(11) := 'YAxisValues';

  /* 
      Upload a Flash Chart into the FLASH_CHARTS table.
      The p_directory parameter needs to reference a DIRECTORY
      object that points to a location containing the file you
      are attempting to upload.
  */
  PROCEDURE uploadChartFile(p_chart_code FLASH_CHARTS.chart_code%TYPE := NULL,
                            p_chart_name FLASH_CHARTS.chart_name%TYPE := NULL,
                            p_chart_desc FLASH_CHARTS.chart_desc%TYPE := NULL,
                            p_directory  VARCHAR2 := NULL,
                            p_file_name  VARCHAR2 := NULL);



  /* 
      Upload a Javascript file into the FLASH_JAVASCRIPT table.
      The p_directory parameter needs to reference a DIRECTORY
      object that points to a location containing the file you
      are attempting to upload.
  */
  PROCEDURE uploadJavascriptFile(p_script_code FLASH_JAVASCRIPT.script_code%TYPE := NULL,
                                 p_script_desc FLASH_JAVASCRIPT.script_desc%TYPE := NULL,
                                 p_directory  VARCHAR2 := NULL,
                                 p_file_name  VARCHAR2 := NULL);


  PROCEDURE js(p_script_code VARCHAR2 := 'FUSN');


  PROCEDURE swf(p_chart_code VARCHAR2 := NULL);

  PROCEDURE streamDataSet(p_data_set XMLType := NULL);


  PROCEDURE addChart(p_chart_id     VARCHAR2 := NULL,
                     p_chart_type   VARCHAR2 := NULL,
                     p_chart_width  VARCHAR2 := NULL,
                     p_chart_height VARCHAR2 := NULL,
                     p_data_xml     VARCHAR2 := NULL,
                     p_data_url     VARCHAR2 := NULL);

  FUNCTION concatTagSets(p_current_set     XMLType,
                         p_additional_set  XMLType) RETURN XMLType;

  -- FCF
  FUNCTION createSingleSeriesDataSet(p_graph_attributes FlashChartGraphAttrType,
                                     p_rowset           FlashChartRowSetType) RETURN XMLType;


  -- FFV3
  FUNCTION createSingleSeriesDataSet(p_chart_attributes FlashChartAttrType,
                                     p_rowset           FlashChartRowSetType,
                                     p_trendline_set    FlashTrendLineSet := NULL) RETURN XMLType;



  FUNCTION createCategorySet(p_categories_attr FlashMSCategoriesType,
                             p_category_set    FlashMSCategorySet) RETURN XMLType;


  FUNCTION createMSSetData(p_dataset_attr FlashMSDataSetType,
                           p_rowset       FlashChartRowSetType) RETURN XMLType;


  FUNCTION createMultiSeriesDataSet(p_graph_attributes FlashChartGraphAttrType,
                                    p_category_set     XMLType,
                                    p_ms_data_set      XMLType,
                                    p_trendline_set    FlashTrendLineSet := NULL) RETURN XMLType;

  -- FFV3
  FUNCTION createMultiSeriesDataSet(p_chart_attributes FlashChartAttrType,
                                    p_category_set     XMLType,
                                    p_ms_data_set      XMLType,
                                    p_trendline_set    FlashTrendLineSet := NULL) RETURN XMLType;

  FUNCTION createCandleStickDataSet(p_graph_attributes FlashChartGraphAttrType,
                                    p_category_set     XMLType,
                                    p_rowset           FlashChartRowSetType,
                                    p_trendline_set    FlashTrendLineSet := NULL) RETURN XMLType;

  FUNCTION createFunnelDataSet(p_chart_attributes FlashChartAttrType,
                               p_rowset           FlashChartRowSetType) RETURN XMLType;


  -- Styles

  FUNCTION createStyleDataSet(p_style_set      FlashStyleSet,
                              p_applystyle_set FlashApplyStyleSet) RETURN XMLType;


  FUNCTION addStylesData(p_data_set   XMLType,
                         p_styles_set XMLType) RETURN XMLType;


  /*=============================================================*/
  /* PIPELINE FUNCTIONS USED TO QUERY DATA TYPES and COLLECTIONS */
  /* Each of these relates to a Fusion Free Chart XML data set   */
  /* XML tag.                                                    */
  /*=============================================================*/

  FUNCTION pipelineGraphData(p_graph_attr FlashChartGraphAttrType) RETURN FlashChartGraphAttrSet PIPELINED;

  FUNCTION pipelineSetData(p_rowset FlashChartRowSetType) RETURN FlashChartRowSetType PIPELINED;

  FUNCTION pipelineCatgoriesData(p_categories FlashMSCategoriesType) RETURN FlashMSCategoriesSet PIPELINED;

  FUNCTION pipelineCategoryData(p_category_set FlashMSCategorySet) RETURN FlashMSCategorySet PIPELINED;

  FUNCTION pipelineMSDataSetData(p_msdataset FlashMSDataSetType) RETURN FlashMSDataSet PIPELINED;

  FUNCTION pipelineTrendLineData(p_line_set FlashTrendLineSet) RETURN FlashTrendLineSet PIPELINED;

  FUNCTION pipelineChartData(p_chart_data FlashChartAttrType) RETURN FlashChartAttrSet PIPELINED;

  FUNCTION pipelineStyleData(p_style_set FlashStyleSet) RETURN FlashStyleSet PIPELINED;

  FUNCTION pipelineApplyStyleData(p_applystyle_set FlashApplyStyleSet) RETURN FlashApplyStyleSet PIPELINED;

  /*===============================*/
  /* Utility Function to Generate  */
  /* a Random Hex Color            */
  /*===============================*/

  FUNCTION generateRandomHexColor RETURN VARCHAR2;


END;
/
