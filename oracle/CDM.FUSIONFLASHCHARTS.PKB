CREATE OR REPLACE PACKAGE BODY CDM.FusionFlashCharts AS

      NL_CHAR  CONSTANT  CHAR(1) := '
';


/*====================*/
/* Get BLOB from file */
/*====================*/

FUNCTION getFileBLOB(p_file_name VARCHAR2 := NULL,
                     p_file_dir  VARCHAR2 := NULL) RETURN BLOB
IS

   v_blob BLOB  := EMPTY_BLOB();
   v_file BFILE := BFILENAME(p_file_dir, p_file_name);

BEGIN

      DBMS_LOB.createTemporary(v_blob,FALSE,DBMS_LOB.CALL);

      DBMS_LOB.OPEN(v_file, DBMS_LOB.LOB_READONLY); 

      IF   DBMS_LOB.GETLENGTH(v_file) > 0 THEN
    
         DBMS_LOB.LOADFROMFILE(dest_lob => v_blob,                          
                               src_lob  => v_file,                          
                               amount   => DBMS_LOB.GETLENGTH(v_file)); 
      END IF;
   
      DBMS_LOB.CLOSE(v_file);  

   RETURN v_blob;

EXCEPTION 
      WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('FILE UPLOAD ERROR: '||sqlerrm);
          DBMS_LOB.CLOSE(v_file);

END;

/*=======================================================================================================================================*/

/*====================*/
/* Get CLOB from file */
/*====================*/

FUNCTION getFileCLOB(p_file_name VARCHAR2 := NULL,
                     p_file_dir  VARCHAR2 := NULL) RETURN CLOB
IS

   v_clob CLOB  := EMPTY_CLOB();
   v_file BFILE := BFILENAME(p_file_dir, p_file_name);

BEGIN

      DBMS_LOB.createTemporary(v_clob,FALSE,DBMS_LOB.CALL);

      DBMS_LOB.OPEN(v_file, DBMS_LOB.LOB_READONLY); 

      IF   DBMS_LOB.GETLENGTH(v_file) > 0 THEN
    
         DBMS_LOB.LOADFROMFILE(dest_lob => v_clob,                          
                               src_lob  => v_file,                          
                               amount   => DBMS_LOB.GETLENGTH(v_file)); 
      END IF;
   
      DBMS_LOB.CLOSE(v_file);  

   RETURN v_clob;

EXCEPTION 
      WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('FILE UPLOAD ERROR: '||sqlerrm);
          DBMS_LOB.CLOSE(v_file);

END;


/*=======================================================================================================================================*/

PROCEDURE uploadChartFile(p_chart_code FLASH_CHARTS.chart_code%TYPE := NULL,
                          p_chart_name FLASH_CHARTS.chart_name%TYPE := NULL,
                          p_chart_desc FLASH_CHARTS.chart_desc%TYPE := NULL,
                          p_directory  VARCHAR2 := NULL,
                          p_file_name  VARCHAR2 := NULL)
IS


   v_sql VARCHAR2(500) := 'INSERT INTO FLASH_CHARTS(chart_code,chart_name,chart_desc,chart_blob) VALUES (:1,:2,:3,:4)';

BEGIN

   EXECUTE IMMEDIATE v_sql
   USING 
          p_chart_code,
          p_chart_name,
          p_chart_desc,
          getFileBLOB(p_file_name,UPPER(p_directory));


END;

/*=======================================================================================================================================*/

PROCEDURE uploadJavascriptFile(p_script_code FLASH_JAVASCRIPT.script_code%TYPE := NULL,
                               p_script_desc FLASH_JAVASCRIPT.script_desc%TYPE := NULL,
                               p_directory  VARCHAR2 := NULL,
                               p_file_name  VARCHAR2 := NULL)
IS


   v_sql VARCHAR2(500) := 'INSERT INTO FLASH_JAVASCRIPT(script_code,script_desc,script_data) VALUES (:1,:2,:3)';

BEGIN

   EXECUTE IMMEDIATE v_sql
   USING 
          p_script_code,
          p_script_desc,
          getFileCLOB(p_file_name,UPPER(p_directory));


END;

/*=====================================================================================================================================================================*/

PROCEDURE js(p_script_code VARCHAR2 := 'FUSN')
IS

    v_script_clob CLOB := NULL;

    v_sql VARCHAR2(500) := 'SELECT script_data FROM flash_javascript WHERE script_code = :code';

BEGIN


   EXECUTE IMMEDIATE v_sql INTO v_script_clob USING p_script_code;

   -- Prepare Headers
   owa_util.mime_header('application/javascript',FALSE);
   htp.p('Content-Length: '||dbms_lob.getLength(v_script_clob)||NL_CHAR);
   owa_util.http_header_close;
   --Download Image
   wpg_docload.download_file(v_script_clob); 

END;

/*=====================================================================================================================================================================*/

PROCEDURE swf(p_chart_code VARCHAR2 := NULL)
IS

    v_chart_blob BLOB := NULL;

    v_sql VARCHAR2(500) := 'SELECT chart_blob FROM flash_charts WHERE chart_code = :code';

BEGIN


   EXECUTE IMMEDIATE v_sql INTO v_chart_blob USING p_chart_code;

   -- Prepare Headers
   owa_util.mime_header('application/x-shockwave-flash',FALSE);
   htp.p('Content-Length: '||dbms_lob.getLength(v_chart_blob)||NL_CHAR);
   owa_util.http_header_close;
   --Download File
   wpg_docload.download_file(v_chart_blob); 

END;

/*==================================================================================================================================================================*/
PROCEDURE streamDataSet(p_data_set XMLType := NULL)
IS

  v_data_blob BLOB := NULL;

  v_doc_clob  CLOB := p_data_set.getClobVal();

 l_blob blob;
 l_clob clob;
 l_len number;
 l_offset number := 1;
 l_amount NUMBER := 16000;
 l_buffer VARCHAR2(32767);
 l_buffer_raw RAW(32767);

BEGIN

   DBMS_LOB.createTemporary(v_data_blob,FALSE,DBMS_LOB.CALL);

 --     FOR pos IN 1 .. dbms_lob.getLength(v_doc_clob) LOOP
 --      DBMS_LOB.writeappend(v_data_blob,1,utl_raw.cast_to_raw(substr(v_doc_clob,pos,1)));
 --   END LOOP;

 l_len := dbms_lob.getlength(v_doc_clob);
 l_offset:=1;

 WHILE l_offset < l_len
 LOOP
 
    DBMS_LOB.read(v_doc_clob, l_amount, l_offset, l_buffer);
    l_buffer_raw := UTL_RAW.cast_to_raw(l_buffer);
    DBMS_LOB.writeappend(v_data_blob, UTL_RAW.length(l_buffer_raw), l_buffer_raw);

    l_offset := l_offset + l_amount;
	
    IF l_len - l_offset < 16000 THEN
       l_amount := l_len - l_offset;
    END IF;

 END LOOP;

   -- Prepare Headers
   owa_util.mime_header('text/xml',FALSE);
   htp.p('Content-Length: '||dbms_lob.getLength(v_data_blob)||NL_CHAR);
   owa_util.http_header_close;
   --Download Data

   wpg_docload.download_file(v_data_blob);


END;


/*==================================================================================================================================================================*/

FUNCTION concatTagSets(p_current_set     XMLType,
                       p_additional_set  XMLType) RETURN XMLType
IS

   v_sql VARCHAR2(500) := 'SELECT XMLCONCAT(:1,:2) FROM DUAL';

   v_XMLType XMLType := NULL;

BEGIN

   EXECUTE IMMEDIATE v_sql INTO v_XMLType USING p_current_set,p_additional_set;

   RETURN v_XMLType;

END;

/*==================================================================================================================================================================*/

PROCEDURE addChart(p_chart_id     VARCHAR2 := NULL,
                   p_chart_type   VARCHAR2 := NULL,
                   p_chart_width  VARCHAR2 := NULL,
                   p_chart_height VARCHAR2 := NULL,
                   p_data_xml     VARCHAR2 := NULL,
                   p_data_url     VARCHAR2 := NULL)
IS

   v_chart_object VARCHAR2(32000) := '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase=http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0" width="<width>" height="<height>" id="<chart_id>" >'||NL_CHAR||
                                    '<param id="movie_<chart_id>" name="movie" value="<chart_url>" />'||NL_CHAR||
                                    '<param id="FlashVars_<chart_id>" name="FlashVars" value="&dataURL=<data_url>&dataXML=<data_xml>&chartWidth=<width>&chartHeight=<height>">'||NL_CHAR||
                                    '<param id="quality_<chart_id>" name="quality" value="high" />'||NL_CHAR||
                                    '<embed id="embed_<chart_id>" src="<chart_url>" flashVars="&dataURL=<data_url>&dataXML=<data_xml>&chartWidth=<width>&chartHeight=<height>" quality="high" width="<width>" height="<height>" name="<chart_id>" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />'||NL_CHAR||
                                    '</object>';

   -- We probably want do not want to hard code the package name ... probably needs to be a variable ...
   v_chart_url VARCHAR2(100) := 'FusionFlashCharts.swf?p_chart_code=';

BEGIN

    IF p_chart_id IS NOT NULL AND p_chart_type IS NOT NULL THEN

       v_chart_object := REPLACE(v_chart_object,'<chart_id>',p_chart_id);
       v_chart_object := REPLACE(v_chart_object,'<chart_url>',v_chart_url||p_chart_type);

       IF p_data_url IS NULL THEN
          v_chart_object := REPLACE(v_chart_object,'&dataURL=<data_url>',NULL);
       ELSE
          v_chart_object := REPLACE(v_chart_object,'<data_url>',REPLACE(REPLACE(p_data_url,'&','%26'),'?','%3F'));
       END IF;
       
       IF p_data_xml IS NULL THEN
          v_chart_object := REPLACE(v_chart_object,'&dataXML=<data_xml>',NULL);
       ELSE
          -- Double quotes in the XML need to be escaped.
          v_chart_object := REPLACE(v_chart_object,'<data_xml>',REPLACE(p_data_xml,'"','%22'));
       END IF;
       
       v_chart_object := REPLACE(v_chart_object,'<data_xml>',p_data_xml);
       v_chart_object := REPLACE(v_chart_object,'<width>',p_chart_width);
       v_chart_object := REPLACE(v_chart_object,'<height>',p_chart_height);

       htp.p(v_chart_object);

    ELSE

       htp.p('<p><font color="red">Error generating chart object. Chart Id and Chart Type are required.</font></p>');

    END IF;

END;

/*=======================================================================================================================================================*/
FUNCTION generateRandomHexColor RETURN VARCHAR2
IS


   TYPE hex_varray IS VARRAY(6) OF VARCHAR2(2);

   v_color VARCHAR2(7) := NULL;

   v_hex_vals hex_varray := hex_varray('00','33','66','99','CC','FF');


BEGIN

   v_color := v_hex_vals(DBMS_RANDOM.VALUE(1,6))||v_hex_vals(DBMS_RANDOM.VALUE(1,6))||v_hex_vals(DBMS_RANDOM.VALUE(1,6));

   RETURN v_color;

END;

/*=======================================================================================================================================================*/

FUNCTION pipelineSetData(p_rowset FlashChartRowSetType) RETURN FlashChartRowSetType PIPELINED
IS
BEGIN

  FOR i IN 1 .. p_rowset.COUNT LOOP

    PIPE ROW(p_rowset(i));

  END LOOP;

  RETURN;

END;

/*=======================================================================================================================================================*/

FUNCTION pipelineGraphData(p_graph_attr FlashChartGraphAttrType) RETURN FlashChartGraphAttrSet PIPELINED
IS
BEGIN

  PIPE ROW(p_graph_attr);

  RETURN;

END;


/*=======================================================================================================================================================*/

FUNCTION pipelineCatgoriesData(p_categories FlashMSCategoriesType) RETURN FlashMSCategoriesSet PIPELINED
IS
BEGIN

  PIPE ROW(p_categories);

  RETURN;

END;


/*=======================================================================================================================================================*/

FUNCTION pipelineCategoryData(p_category_set FlashMSCategorySet) RETURN FlashMSCategorySet PIPELINED
IS
BEGIN

  FOR i IN 1 .. p_category_set.COUNT LOOP

    PIPE ROW(p_category_set(i));

  END LOOP;

  RETURN;

END;

/*=======================================================================================================================================================*/

FUNCTION pipelineMSDataSetData(p_msdataset FlashMSDataSetType) RETURN FlashMSDataSet PIPELINED
IS
BEGIN

  PIPE ROW(p_msdataset);

  RETURN;

END;

/*=======================================================================================================================================================*/

FUNCTION pipelineTrendLineData(p_line_set FlashTrendLineSet) RETURN FlashTrendLineSet PIPELINED
IS
BEGIN

  FOR i IN 1 .. p_line_set.COUNT LOOP

    PIPE ROW(p_line_set(i));

  END LOOP;

  RETURN;

END;

/*=======================================================================================================================================================*/

FUNCTION pipelineChartData(p_chart_data FlashChartAttrType) RETURN FlashChartAttrSet PIPELINED
IS
BEGIN

  PIPE ROW(p_chart_data);

  RETURN;

END;

/*=======================================================================================================================================================*/

FUNCTION pipelineStyleData(p_style_set FlashStyleSet) RETURN FlashStyleSet PIPELINED
IS
BEGIN

  FOR i IN 1 .. p_style_set.COUNT LOOP

    PIPE ROW(p_style_set(i));

  END LOOP;

  RETURN;

END;

/*=======================================================================================================================================================*/

FUNCTION pipelineApplyStyleData(p_applystyle_set FlashApplyStyleSet) RETURN FlashApplyStyleSet PIPELINED
IS
BEGIN

  FOR i IN 1 .. p_applystyle_set.COUNT LOOP

    PIPE ROW(p_applystyle_set(i));

  END LOOP;

  RETURN;

END;

/*=======================================================================================================================================================*/

FUNCTION createGraphTag(p_graph_attributes FlashChartGraphAttrType) RETURN XMLType
IS
   CURSOR crsrGraphData(cv_graph_attributes FlashChartGraphAttrType) IS
   SELECT
           XMLAgg(XMLElement("graph",
                XMLAttributes(x.bgColor                 AS "bgColor",
                              x.bgAlpha                 AS "bgAlpha",
                              x.bgSWF                   AS "bgSWF",
                              x.palette                 AS "palette",
                              x.canvasBgColor           AS "canvasBgColor",
                              x.canvasBgAlpha           AS "canvasBgAlpha",
                              x.canvasBorderColor       AS "canvasBorderColor",
                              x.canvasBorderThickness   AS "canvasBorderThickness",
                              x.caption                 AS "caption",
                              x.subCaption              AS "subCaption",
                              x.xAxisName               AS "xAxisName",
                              x.yAxisName               AS "yAxisName",
                              x.yAxisMinValue           AS "yAxisMinValue",
                              x.yAxisMaxValue           AS "yAxisMaxValue",
                              x.shownames               AS "shownames",
                              x.showValues              AS "showValues",
                              x.showPercentageValues    AS "showPercentageValues",
                              x.showPercentageInLabel   AS "showPercentageInLabel", 
                              x.showLimits              AS "showLimits",
                              x.showSecondaryLimits     AS "showSecondaryLimits",
                              x.rotateNames             AS "rotateNames",
                              x.animation               AS "animation",
                              x.showLegend              AS "showLegend",
                              x.showColumnShadow        AS "showColumnShadow",
                              x.baseFont                AS "baseFont",
                              x.baseFontSize            AS "baseFontSize",
                              x.baseFontColor           AS "baseFontColor",
                              x.outCnvBaseFont          AS "outCnvBaseFont",
                              x.outCnvBaseFontSze       AS "outCnvBaseFontSze",
                              x.outCnvBaseFontColor     AS "outCnvBaseFontColor",
                              x.numberPrefix            AS "numberPrefix",
                              x.numberSuffix            AS "numberSuffix",
                              x.formatNumber            AS "formatNumber",
                              x.formatNumberScale       AS "formatNumberScale",
                              x.decimalSeparator        AS "decimalSeparator",
                              x.thousandSeparator       AS "thousandSeparator",
                              x.decimalPrecision        AS "decimalPrecision",
                              x.divLineDecimalPrecision AS "divLineDecimalPrecision",
                              x.limitsDecimalPrecision  AS "limitsDecimalPrecision",
                              x.zeroPlaneThickness      AS "zeroPlaneThickness",
                              x.zeroPlaneColor          AS "zeroPlaneColor",
                              x.zeroPlaneAlpha          AS "zeroPlaneAlpha",
                              x.numdivlines             AS "numdivlines",
                              x.divlinecolor            AS "divlinecolor",
                              x.divLineThickness        AS "divLineThickness",
                              x.divLineAlpha            AS "divLineAlpha",
                              x.showDivLineValue        AS "showDivLineValue",
                              x.showAlternateHGridColor AS "showAlternateHGridColor",
                              x.alternateHGridColor     AS "alternateHGridColor",
                              x.alternateHGridAlpha     AS "alternateHGridAlpha",
                              x.numVDivLines            AS "numVDivLines",
                              x.VDivlinecolor           AS "VDivLines",
                              x.VDivLineThickness       AS "VDivLineThickness",
                              x.VDivLineAlpha           AS "VDivLineAlpha",
                              x.showAlternateVGridColor AS "showAlternateVGridColor",
                              x.alternateVGridColor     AS "alternateVGridColor",
                              x.alternateVGridAlpha     AS "alternateVGridAlpha",
                              x.showhovercap            AS "showhovercap",
                              x.hoverCapBgColor         AS "hoverCapBgColor",
                              x.hoverCapBorderColor     AS "hoverCapBorderColor",
                              x.hoverCapSepChar         AS "hoverCapSepChar",
                              x.chartLeftMargin         AS "chartLeftMargin",
                              x.chartRightMargin        AS "chartRightMargin",
                              x.chartTopMargin          AS "chartTopMargin",
                              x.chartBottomMargin       AS "chartBottomMargin",
                              x.pieRadius               AS "pieRadius",
                              x.pieSliceDepth           AS "pieSliceDepth",
                              x.pieYScale               AS "pieYScale",
                              x.pieBorderThickness      AS "pieBorderThickness",
                              x.pieBorderAlpha          AS "pieBorderAlpha",
                              x.pieFillAlpha            AS "pieFillAlpha",
                              x.lineColor               AS "lineColor",
                              x.lineThickness           AS "lineThickness",
                              x.lineAlpha               AS "lineAlpha",
                              x.showShadow              AS "showShadow",
                              x.shadowColor             AS "shadowColor",
                              x.shadowThickness         AS "shadowThickness",
                              x.shadowAlpha             AS "shadowAlpha",
                              x.shadowXShift            AS "shadowXShift",
                              x.shadowYShift            AS "shadowYShift",
                              x.showAnchors             AS "showAnchors",
                              x.anchorSides             AS "anchorSides",
                              x.anchorRadius            AS "anchorRadius",
                              x.anchorBorderColor       AS "anchorBorderColor",
                              x.anchorBorderThickness   AS "anchorBorderThickness",
                              x.anchorBgColor           AS "anchorBgColor",
                              x.anchorBgAlpha           AS "anchorBgAlpha",
                              x.anchorAlpha             AS "anchorAlpha",
                              x.showAreaBorder          AS "showAreaBorder",
                              x.areaBorderThickness     AS "areaBorderThickness",
                              x.areaBorderColor         AS "areaBorderColor",
                              x.areaBgColor             AS "areaBgColor",
                              x.areaAlpha               AS "areaAlpha",
                              x.nameTBDistance          AS "nameTBDistance",
                              x.PYAxisName              AS "PYAxisName",
                              x.SYAxisName              AS "SYAxisName",
                              x.PYAxisMaxValue          AS "PYAxisMaxValue",
                              x.PYAxisMinValue          AS "PYAxisMinValue",
                              x.SYAxisMaxValue          AS "SYAxisMaxValue",
                              x.SYAxisMinValue          AS "SyAxisMinValue",
                              x.showAsBars              AS "showAsBars",
                              x.candleWidth             AS "candleWidth",
                              x.bearBorderColor         AS "bearBorderColor",
                              x.bearFillColor           AS "bearFillColor",
                              x.bullBorderColor         AS "bullBorderColor",
                              x.bullFillColor           AS "bullFillColor"))) graphTag
   FROM
         TABLE(pipelineGraphData(cv_graph_attributes)) x;

   v_XMLType  XMLType := NULL;

BEGIN

   FOR data_rec IN crsrGraphData(p_graph_attributes) LOOP

     v_XMLType := data_rec.graphTag;

   END LOOP;


   RETURN v_XMLType;

END;

/*=======================================================================================================================================================*/

FUNCTION createSetTags(p_rowset FlashChartRowSetType) RETURN XMLType
IS

   CURSOR crsrSetData(cv_rowset  FlashChartRowSetType) IS
   SELECT
           XMLAgg(XMLElement("set",
                XMLAttributes( name                AS "name",            
                               label               AS "label", 
                               value               AS "value",
                               displayValue        AS "displayValue",
                               color               AS "color",
                               hoverText           AS "hoverText",
                               link                AS "link",
                               alpha               AS "alpha",
                               toolText            AS "toolText",
                               showLabel           AS "showLabel",
                               showName            AS "showName",
                               isSliced            AS "isSliced",
                               dashed              AS "dashed",
                               borderColor         AS "borderColor",
                               borderThickness     AS "borderThickness",
                               borderAlpha         AS "borderAlpha",
                               open                AS "open",
                               high                AS "high",
                               low                 AS "low",
                               close               AS "close",
                               xIndex              AS "xIndex",
                               x                   AS "x",
                               y                   AS "y",
                               z                   AS "z"))) sets
   FROM
         TABLE(pipelineSetData(cv_rowset)) a;

   v_XMLType  XMLType := NULL;


BEGIN


   FOR data_rec IN crsrSetData(p_rowset) LOOP

     v_XMLType := data_rec.sets;

   END LOOP;


   RETURN v_XMLType;

END;

/*=======================================================================================================================================================*/

FUNCTION createCategoriesTag(p_categories FlashMSCategoriesType) RETURN XMLType
IS

   CURSOR crsrCategoriesData(cv_categories FlashMSCategoriesType) IS
   SELECT
           XMLAgg(XMLElement("categories",
                XMLAttributes(
                               x.font                  AS "font",
                               x.fontSize              AS "fontSize",
                               x.fontColor             AS "fontColor",
                               x.verticalLineColor     AS "verticalLineColor",
                               x.verticalLineThickness AS "verticalLineThickness",
                               x.verticalLineAlpha     AS "verticalLineAlpha" ))) categories
   FROM
         TABLE(pipelineCatgoriesData(cv_categories)) x;


   v_XMLType XMLType := NULL;

BEGIN

   FOR data_rec IN crsrCategoriesData(p_categories) LOOP

     v_XMLType := data_rec.categories;

   END LOOP;


   RETURN v_XMLType;

END;

/*=======================================================================================================================================================*/

FUNCTION createCategoryTags(p_category_set FlashMSCategorySet) RETURN XMLType
IS

   CURSOR crsrCategoryData(cv_category_set FlashMSCategorySet) IS
   SELECT
           XMLAgg(XMLElement("category",
                XMLAttributes(
                               name      AS "name",
                               label     AS "label",
                               showLabel AS "showLabel",
                               toolTip   AS "toolTip",
                               hoverText AS "hoverText",
                               showName  AS "showName",
                               x         AS  "x"))) category
   FROM
         TABLE(pipelineCategoryData(cv_category_set)) x;

   v_XMLType XMLType := NULL;

BEGIN

   FOR data_rec IN crsrCategoryData(p_category_set) LOOP

     v_XMLType := data_rec.category;

   END LOOP;

   RETURN v_XMLType;

END; 

/*=======================================================================================================================================================*/

FUNCTION createMSDataSetTag(p_msdataset FlashMSDataSetType) RETURN XMLType
IS

   CURSOR crsrMSDataSet(cv_msdataset FlashMSDataSetType) IS
   SELECT
           XMLAgg(XMLElement("dataset",
                XMLAttributes(
                               seriesName      AS "seriesName",
                               color           AS "color",
                               showValues      AS "showValues",
                               alpha           AS "alpha",
                               parentYAxis     AS "parentYAxis",
                               numberPrefix    AS "numberPrefix",
                               numberSuffix    AS "numberSuffix",
                               includeInLegend AS "includeInLegend" ))) dataset
   FROM
         TABLE(pipelineMSDataSetData(cv_msdataset)) x;

   v_XMLType XMLType := NULL;

BEGIN

   FOR data_rec IN crsrMSDataSet(p_msdataset) LOOP

     v_XMLType := data_rec.dataset;

   END LOOP;

   RETURN v_XMLType;

END;

/*=======================================================================================================================================================*/

FUNCTION createTrendLineTags(p_line_set FlashTrendLineSet) RETURN XMLType
IS

   CURSOR crsrTrendLineSet(cv_line_set FlashTrendLineSet) IS
   SELECT
         XMLElement("trendLines",
           XMLAgg(XMLElement("line",
                XMLAttributes(
                               x.startValue   AS "startValue",
                               x.endValue     AS "endValue",
                               x.color        AS "color",
                               x.displayValue AS "displayValue",
                               x.thickness    AS "thickNess",
                               x.isTrendZone  AS "isTrendZone",
                               x.showOnTop    AS "showOnTop",
                               x.alpha        AS "alpha" )))) trendlines
   FROM
         TABLE(pipelineTrendLineData(cv_line_set)) x;

   v_XMLType XMLType := NULL;

BEGIN

   FOR data_rec IN crsrTrendLineSet(p_line_set) LOOP

     v_XMLType := data_rec.trendlines;

   END LOOP;

   RETURN v_XMLType;

END;


/*=======================================================================================================================================================*/

FUNCTION createChartTag(p_chart_data FlashChartAttrType) RETURN XMLType
IS

   CURSOR crsrChartTagData(cv_chart_data FlashChartAttrType) IS
   SELECT
           XMLAgg(XMLElement("chart",
                XMLAttributes(
                                bgColor                 AS "bgColor",
                                bgAlpha                 AS "bgAlpha",
                                bgSWF                   AS "bgSWF",
                                bgSWFAlpha              AS "bgSWFAlpha",      
                                bgRatio                 AS "bgRatio",      
                                bgAngle                 AS "bgAngle",      
                                canvasBgColor           AS "canvasBgColor",    
                                canvasBgAlpha           AS "canvasBgAlpha",      
                                canvasBgRatio           AS "canvasBgRatio",      
                                canvasBgAngle           AS "canvasBgAngle",      
                                canvasBorderColor       AS "canvasBorderColor",    
                                canvasBorderThickness   AS "canvasBorderThickness",      
                                canvasBorderAlpha       AS "canvasBorderAlpha",      
                                showBorder              AS "showBorder",
                                borderColor             AS "borderColor",
                                borderThickness         AS "borderThickness",
                                borderAlpha             AS "borderAlpha",
                                showVLineLabelBorder    AS "showVLineLabelBorder",      
                                logoURL                 AS "logoURL",  
                                logoPosition            AS "logoPosition",    
                                logoAlpha               AS "logoAlpha",      
                                logoScale               AS "logoScale",      
                                logoLink                AS "logoLink",  
                                useRoundEdges           AS "useRoundEdges",      
                                showPlotBorder          AS "showPlotBorder",      
                                plotBorderColor         AS "plotBorderColor",    
                                plotBorderThickness     AS "plotBorderThickness",      
                                plotBorderAlpha         AS "plotBorderAlpha",      
                                plotBorderDashed        AS "plotBorderDashed",      
                                plotBorderDashLen       AS "plotBorderDashLen",      
                                plotBorderDashGap       AS "plotBorderDashGap",      
                                plotFillAngle           AS "plotFillAngle",      
                                plotFillRatio           AS "plotFillRatio",      
                                plotFillAlpha           AS "plotFillAlpha",      
                                plotGradientColor       AS "plotGradientColor",    
                                use3DLighting           AS "use3DLighting",      
                                numDivLines             AS "numDivLines",      
                                divLineColor            AS "divLineColor",    
                                divLineThickness        AS "divLineThickness",      
                                divLineAlpha            AS "divLineAlpha",      
                                divLineIsDashed         AS "divLineIsDashed",      
                                divLineDashLen          AS "divLineDashLen",      
                                divLineDashGap          AS "divLineDashGap",      
                                zeroPlaneColor          AS "zeroPlaneColor",    
                                zeroPlaneThickness      AS "zeroPlaneThickness",      
                                zeroPlaneAlpha          AS "zeroPlaneAlpha",      
                                showAlternateHGridColor AS "showAlternateHGridColor",      
                                alternateHGridColor     AS "alternateHGridColor",    
                                alternateHGridAlpha     AS "alternateHGridAlpha",      
                                slicingDistance         AS "slicingDistance",      
                                pieRadius               AS "pieRadius",      
                                startingAngle           AS "startingAngle",      
                                enableRotation          AS "enableRotation",      
                                pieInnerFaceAlpha       AS "pieInnerFaceAlpha",      
                                pieOuterFaceAlpha       AS "pieOuterFaceAlpha",      
                                pieYScale               AS "pieYScale",      
                                pieSliceDepth           AS "pieSliceDepth",      
                                enableSmartLabels       AS "enableSmartLabels",      
                                skipOverlapLabels       AS "skipOverlapLabels",      
                                isSmartLineSlanted      AS "isSmartLineSlanted",      
                                smartLineColor          AS "smartLineColor",    
                                smartLineThickness      AS "smartLineThickness",      
                                smartLineAlpha          AS "smartLineAlpha",      
                                labelDistance           AS "labelDistance",      
                                smartLabelClearance     AS "smartLabelClearance",                 
                                showNames               AS "showNames",
                                showValues              AS "showValues",
                                animation               AS "animation",
                                palette                 AS "palette",      
                                paletteColors           AS "paletteColors",    
                                showAboutMenuItem       AS "showAboutMenuItem",      
                                aboutMenuItemLabel      AS "aboutMenuItemLabel",  
                                aboutMenuItemLink       AS "aboutMenuItemLink",  
                                showLabels              AS "showLabels",      
                                labelDisplay            AS "labelDisplay",   
                                rotateLabels            AS "rotateLabels", 
                                slantLabels             AS "slantLabels",      
                                labelStep               AS "labelStep",      
                                staggerLines            AS "staggerLines",      
                                rotateValues            AS "rotateValues",      
                                placeValuesInside       AS "placeValuesInside",      
                                showYAxisValues         AS "showYAxisValues",      
                                showDivLineValues       AS "showDivLineValues",      
                                yAxisValuesStep         AS "yAxisValuesStep",      
                                showShadow              AS "showShadow",      
                                adjustDiv               AS "adjustDiv",      
                                rotateYAxisName         AS "rotateYAxisName",  
                                rotateXAxisName         AS "rotateXAxisName",    
                                yAxisNameWidth          AS "yAxisNameWidth",      
                                clickURL                AS "clickURL",  
                                defaultAnimation        AS "defaultAnimation",      
                                yAxisMinValue           AS "yAxisMinValue",      
                                yAxisMaxValue           AS "yAxisMaxValue",      
                                setAdaptiveYMin         AS "setAdaptiveYMin",      
                                caption                 AS "caption",  
                                subCaption              AS "subCaption",  
                                xAxisName               AS "xAxisName",  
                                yAxisName               AS "yAxisName",  
                                formatNumber            AS "formatNumber",
                                formatNumberScale       AS "formatNumberScale",
                                defaultNumberScale      AS "defaultNumberScale",  
                                numberScaleUnit         AS "numberScaleUnit",  
                                numberScaleValue        AS "numberScaleValue",   
                                numberPrefix            AS "numberPrefix",
                                numberSuffix            AS "numberSuffix", 
                                decimalSeparator        AS "decimalSeparator",
                                thousandSeparator       AS "thousandSeparator",
                                inDecimalSeparator      AS "inDecimalSeparator",    
                                inThousandSeparator     AS "inThousandSeparator",    
                                decimals                AS "decimals",      
                                forceDecimals           AS "forceDecimals",      
                                yAxisValueDecimals      AS "yAxisValueDecimals",      
                                fillAlpha               AS "fillAlpha",
                                funnelBaseWidth         AS "funnelBaseWidth",
                                funnelBaseHeight        AS "funnelBaseHeight",
                                baseFont                AS "baseFont",
                                baseFontSize            AS "baseFontSize",
                                baseFontColor           AS "baseFontColor",
                                outCnvBaseFont          AS "outCnvBaseFont",   
                                outCnvBaseFontSize      AS "outCnvBaseFontSize",      
                                outCnvBaseFontColor     AS "outCnvBaseFontColor",    
                                showToolTip             AS "showToolTip",      
                                toolTipBgColor          AS "toolTipBgColor",    
                                toolTipBorderColor      AS "toolTipBorderColor",    
                                toolTipSepChar          AS "toolTipSepChar",    
                                showToolTipShadow       AS "showToolTipShadow",      
                                captionPadding          AS "captionPadding",      
                                xAxisNamePadding        AS "xAxisNamePadding",      
                                yAxisNamePadding        AS "yAxisNamePadding",      
                                yAxisValuesPadding      AS "yAxisValuesPadding",      
                                labelPadding            AS "labelPadding",      
                                valuePadding            AS "valuePadding",      
                                legendPadding           AS "legendPadding",      
                                plotSpacePercent        AS "plotSpacePercent",      
                                chartLeftMargin         AS "chartLeftMargin",
                                chartRightMargin        AS "chartRightMargin",
                                chartTopMargin          AS "chartTopMargin",
                                chartBottomMargin       AS "chartBottomMargin",  
                                showhovercap            AS "showhovercap",
                                hoverCapBgColor         AS "hoverCapBgColor",
                                hoverCapBorderColor     AS "hoverCapBorderColor",
                                hoverCapSepChar         AS "hoverCapSepChar",
                                showLegend              AS "showLegend",      
                                legendPosition          AS "legendPosition",    
                                legendCaption           AS "legendCaption",  
                                legendMarkerCircle      AS "legendMarkerCircle",      
                                legendBgColor           AS "legendBgColor",    
                                legendBgAlpha           AS "legendBgAlpha",      
                                legendBorderColor       AS "legendBorderColor",    
                                legendBorderThickness   AS "legendBorderThickness",      
                                legendBorderAlpha       AS "legendBorderAlpha",      
                                legendShadow            AS "legendShadow",      
                                legendAllowDrag         AS "legendAllowDrag",      
                                legendScrollBgColor     AS "legendScrollBgColor",    
                                legendScrollBarColor    AS "legendScrollBarColor",    
                                legendScrollBtnColor    AS "legendScrollBtnColor",    
                                reverseLegend           AS "reverseLegend" ))) chartdata
   FROM
         TABLE(pipelineChartData(cv_chart_data)) x;

   v_XMLType XMLType := NULL;

BEGIN

   FOR data_rec IN crsrChartTagData(p_chart_data) LOOP

     v_XMLType := data_rec.chartdata;

   END LOOP;

   RETURN v_XMLType;


END;


/*=======================================================================================================================================================*/

FUNCTION createStyleTags(p_style_set FlashStyleSet) RETURN XMLType
IS

   CURSOR crsrStyleSet(cv_style_set FlashStyleSet) IS
   SELECT
         XMLElement("definition",
           XMLAgg(XMLElement("style",
                XMLAttributes(
                               name           AS   "name",  
                               type           AS   "type",
                               font           AS   "font",
                               color          AS   "color",
                               fsize          AS   "size",
                               bold           AS   "bold",
                               italic         AS   "italic",
                               underline      AS   "underline",
                               bgColor        AS   "bgColor",
                               borderColor    AS   "borderColor",
                               isHTML         AS   "isHTML",
                               leftMargin     AS   "leftMargin",
                               letterSpacing  AS   "letterSpacing",
                               paramObj       AS   "param",
                               startpos       AS   "start",  
                               duration       AS   "duration",
                               easing         AS   "easing",
                               distance       AS   "distance",
                               angle          AS   "angle",
                               alpha          AS   "alpha",
                               blurX          AS   "blurX",
                               blurY          AS   "blurY",
                               quality        AS   "quality", 
                               strength       AS   "strength",
                               shadowColor    AS   "shadowColor",
                               shadowAlpha    AS   "shadowAlpha",
                               highlightColor AS   "highlightColor",
                               highlightAlpha AS   "highlightAlpha" )))) styles
   FROM
         TABLE(pipelineStyleData(cv_style_set)) x;

   v_XMLType XMLType := NULL;

BEGIN

   FOR data_rec IN crsrStyleSet(p_style_set) LOOP

     v_XMLType := data_rec.styles;

   END LOOP;

   RETURN v_XMLType;

END;

/*=======================================================================================================================================================*/

FUNCTION createApplyStyleTags(p_applystyle_set FlashApplyStyleSet) RETURN XMLType
IS

   CURSOR crsrApplyStyleSet(cv_applystyle_set FlashApplyStyleSet) IS
   SELECT
         XMLElement("application",
           XMLAgg(XMLElement("apply",
                XMLAttributes(
                               toObject AS "toObject",
                               styles   AS "styles" )))) applystyles
   FROM
         TABLE(pipelineApplyStyleData(cv_applystyle_set)) x;

   v_XMLType XMLType := NULL;

BEGIN

   FOR data_rec IN crsrApplyStyleSet(p_applystyle_set) LOOP

     v_XMLType := data_rec.applystyles;

   END LOOP;

   RETURN v_XMLType;

END;

/*=======================================================================================================================================================*/

FUNCTION createSingleSeriesDataSet(p_graph_attributes FlashChartGraphAttrType,
                                   p_rowset           FlashChartRowSetType) RETURN XMLType
IS

   v_graphTag XMLType := NULL;
   v_setTags  XMLType := NULL;

BEGIN


   v_graphTag := createGraphTag(p_graph_attributes);
   v_setTags  := createSetTags(p_rowset);


   v_graphTag := XMLType.appendChildXML(v_graphTag,'//graph',v_setTags);

   RETURN v_graphTag;

END;

/*=====================================================================================================================================================*/
-- Full (Non-Free) Version of Fusion Charts
FUNCTION createSingleSeriesDataSet(p_chart_attributes FlashChartAttrType,
                                   p_rowset           FlashChartRowSetType,
                                   p_trendline_set    FlashTrendLineSet := NULL) RETURN XMLType
IS

   v_chartTag XMLType := NULL;
   v_setTags  XMLType := NULL;
   v_trendLinesTagSet  XMLType;

BEGIN


   v_chartTag := createChartTag(p_chart_attributes);
   v_setTags  := createSetTags(p_rowset);

  IF p_trendline_set IS NOT NULL THEN
     v_trendLinesTagSet  := createTrendLineTags(p_trendline_set);
  END IF;


   v_chartTag := XMLType.appendChildXML(v_chartTag,'//chart',v_setTags);
   v_chartTag := XMLType.appendChildXML(v_chartTag,'//chart',v_trendLinesTagSet);   

   RETURN v_chartTag;

END;
/*=====================================================================================================================================================*/

FUNCTION createCategorySet(p_categories_attr FlashMSCategoriesType,
                           p_category_set    FlashMSCategorySet) RETURN XMLType
IS

    v_categoriesTag XMLType := NULL;
    v_categoryTags  XMLType := NULL;

BEGIN

    v_categoriesTag := createCategoriesTag(p_categories_attr);
    v_categoryTags  := createCategoryTags(p_category_set);

    v_categoriesTag := XMLType.appendChildXML(v_categoriesTag,'//categories',v_categoryTags);

    RETURN v_categoriesTag;

END;

/*=====================================================================================================================================================*/

FUNCTION createMSSetData(p_dataset_attr FlashMSDataSetType,
                         p_rowset       FlashChartRowSetType) RETURN XMLType
IS

   v_dataSetTag XMLType := NULL;
   v_setTags    XMLType := NULL;

BEGIN

   v_dataSetTag := createMSDataSetTag(p_dataset_attr);
   v_setTags    := createSetTags(p_rowset);

   v_dataSetTag := XMLType.appendChildXML(v_dataSetTag,'//dataset',v_setTags);

   RETURN v_dataSetTag;

END;

/*====================================================================================================================================================*/

FUNCTION createMultiSeriesDataSet(p_graph_attributes FlashChartGraphAttrType,
                                  p_category_set     XMLType,
                                  p_ms_data_set      XMLType,
                                  p_trendline_set    FlashTrendLineSet := NULL) RETURN XMLType
IS

   v_graphTag          XMLType;
   v_trendLinesTagSet  XMLType;

   v_innerSets         XMLType;

BEGIN

  v_graphTag          := createGraphTag(p_graph_attributes);

  IF p_trendline_set IS NOT NULL THEN
     v_trendLinesTagSet  := createTrendLineTags(p_trendline_set);
  END IF;

  v_innerSets         := concatTagSets(v_innerSets,p_category_set);
  v_innerSets         := concatTagSets(v_innerSets,p_ms_data_set);

  v_innerSets         := concatTagSets(v_innerSets,v_trendLinesTagSet);

  v_graphTag          := XMLType.appendChildXML(v_graphTag,'//graph',v_innerSets);

  RETURN v_graphTag;

END;

/*====================================================================================================================================================*/

FUNCTION createMultiSeriesDataSet(p_chart_attributes FlashChartAttrType,
                                  p_category_set     XMLType,
                                  p_ms_data_set      XMLType,
                                  p_trendline_set    FlashTrendLineSet := NULL) RETURN XMLType
IS

   v_chartTag          XMLType;
   v_trendLinesTagSet  XMLType;

   v_innerSets         XMLType;

BEGIN

  v_chartTag          := createchartTag(p_chart_attributes);

  IF p_trendline_set IS NOT NULL THEN
     v_trendLinesTagSet  := createTrendLineTags(p_trendline_set);
  END IF;

  v_innerSets         := concatTagSets(v_innerSets,p_category_set);
  v_innerSets         := concatTagSets(v_innerSets,p_ms_data_set);

  v_innerSets         := concatTagSets(v_innerSets,v_trendLinesTagSet);

  v_chartTag          := XMLType.appendChildXML(v_chartTag,'//chart',v_innerSets);

  RETURN v_chartTag;

END;

/*==================================================================================================================================================*/

FUNCTION createCandleStickDataSet(p_graph_attributes FlashChartGraphAttrType,
                                  p_category_set     XMLType,
                                  p_rowset           FlashChartRowSetType,
                                  p_trendline_set    FlashTrendLineSet := NULL) RETURN XMLType
IS

   v_graphTag          XMLType;
   v_setTags           XMLType;
   v_trendLinesTagSet  XMLType;
   
   v_dataTag           XMLType := XMLType('<data/>');

   v_innerSets         XMLType;

BEGIN

  v_graphTag          := createGraphTag(p_graph_attributes);
  v_setTags           := createSetTags(p_rowset);

  IF p_trendline_set IS NOT NULL THEN
     v_trendLinesTagSet  := createTrendLineTags(p_trendline_set);
  END IF;

  v_setTags           := XMLType.appendChildXML(v_dataTag,'//data',v_setTags);

  v_innerSets         := concatTagSets(v_innerSets,v_setTags);
  v_innerSets         := concatTagSets(v_innerSets,v_trendLinesTagSet);

  v_graphTag          := XMLType.appendChildXML(v_graphTag,'//graph',v_innerSets);

  RETURN v_graphTag;

END;

/*================================================================================================================================================*/

FUNCTION createFunnelDataSet(p_chart_attributes FlashChartAttrType,
                               p_rowset         FlashChartRowSetType) RETURN XMLType
IS

   v_chartTag XMLType := NULL;
   v_setTags  XMLType := NULL;

BEGIN

   v_chartTag := createChartTag(p_chart_attributes);
   v_setTags  := createSetTags(p_rowset);


   v_chartTag := XMLType.appendChildXML(v_chartTag,'//chart',v_setTags);

   RETURN v_chartTag;



END;

/*================================================================================================================================================*/

FUNCTION createStyleDataSet(p_style_set      FlashStyleSet,
                            p_applystyle_set FlashApplyStyleSet) RETURN XMLType
IS

   v_styles_tag        XMLType := NULL;
   v_styleTagSet       XMLType := NULL; 
   v_applyStyleTagSet  XMLType := NULL;

BEGIN

   
  v_styles_tag       := XMLType('<styles/>');

  v_styleTagSet      := createStyleTags(p_style_set);
  v_applyStyleTagSet := createApplyStyleTags(p_applystyle_set);

  v_styles_tag := XMLType.appendChildXML(v_styles_tag,'//styles',v_styleTagSet);
  v_styles_tag := XMLType.appendChildXML(v_styles_tag,'//styles',v_applyStyleTagSet);
 
  RETURN v_styles_tag;

END;

/*==================================================================================================================================================================*/

FUNCTION addStylesData(p_data_set   XMLType,
                       p_styles_set XMLType) RETURN XMLType
IS

  v_styles_append XMLType := p_data_set;

BEGIN

  v_styles_append := XMLType.appendChildXML(v_styles_append,'//'||v_styles_append.getRootElement(),p_styles_set);

  RETURN v_styles_append;

END;


/*-------------*/
/* END PACKAGE */
/*-------------*/
END;
/
