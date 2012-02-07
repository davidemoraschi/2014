CREATE OR REPLACE PROCEDURE CDM.test_mcml
IS
   s_mime_type                   VARCHAR2 (48) := 'text/xml';
BEGIN
   OWA_UTIL.mime_header (NVL (s_mime_type, 'application/octet'), FALSE);
   HTP.p ('Cache-Control: no-cache');
   HTP.p ('Pragma: no-cache');
   OWA_UTIL.http_header_close;
--   HTP.PRINT ('<?xml version="1.0"?>');
   HTP.p
      ('<Mcml xmlns="http://schemas.microsoft.com/2008/mcml">

              <!-- Only the image size itself is considered when laying         -->
              <!-- out an image and *not* the acquiring/error image sizes.      -->
              <!-- If the image does not have a minimum size specified on it    -->
              <!-- it will receive zero size in layout, and thus you will never -->
              <!-- see them even though the acquiring image may download first. -->
              <!-- Therefore, in order to see the AcquiringImage the graphic    -->
              <!-- must have a MinimumSize attribute.                           -->

              <UI Name="Center">
                <Content>
                  <Graphic Content="http://fraterno:8181/cdm_dad/load_google_chart_from_url?p_url=http%3A%2F%2Fchart.apis.google.com%2Fchart%3Fcht%3Dp3%26chd%3Dt%3A60,40%26chs%3D500x200%26chl%3DHola%7CMundo"
                           MaximumSize="1000,1000"
                       MinimumSize="200,200"/>
                </Content>
              </UI>

            </Mcml>
'     );
END test_mcml; 
/

