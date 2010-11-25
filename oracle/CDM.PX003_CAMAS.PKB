CREATE OR REPLACE PACKAGE BODY CDM.PX003_CAMAS
AS
   PROCEDURE HTML (p_UF_CODIGO IN VARCHAR2 := '0')
   IS
      v_UNIDAD_FUNCIONAL   VARCHAR2 (100);
   BEGIN
      IF p_UF_CODIGO <> '0'
      THEN
         SELECT DISTINCT unidad_funcional
           INTO v_UNIDAD_FUNCIONAL
           FROM GC_MV_0012
          WHERE uf_codigo = p_UF_CODIGO;

         OWA_UTIL.mime_header ('text/html', FALSE);
         OWA_UTIL.http_header_close;
         HTP.htmlopen;
         HTP.headopen;
         HTP.LINKREL ('Stylesheet', '/public/css/camas.css', 'text/css');
         HTP.title ('VALME en directo 1.0.9 Camas');
         HTP.p ('<meta http-equiv="content-type" content="text/html; charset=utf-8" />');
         HTP.headclose;
         HTP.bodyopen;
         HTP.TABLEOPEN (cborder => 'border="0"');
         HTP.TABLEROWOPEN ();
         HTP.P ('<td class="rowcaption">Libres</td>');
         HTP.TABLEROWCLOSE;
         HTP.TABLEROWOPEN ();
         HTP.P ('<td>');

         FOR c1 IN (  SELECT UBI_NOMBRE, ESTADO
                        FROM GC_MV_0012
                       WHERE UF_CODIGO = p_UF_CODIGO AND ESTADO = 'Libre'
                    ORDER BY 1)
         LOOP
            HTP.P (
                  '<div class="bed"><img class="flip" alt="" src="/public/img/117654.png" /><div class="caption">'
               || c1.UBI_NOMBRE
               || '</div></div>');
         END LOOP;

         HTP.P ('</TD>');
         HTP.TABLEROWCLOSE;
         HTP.TABLEROWOPEN ();
         HTP.P ('<td class="rowcaption">Ocupadas</td>');
         HTP.TABLEROWCLOSE;
         HTP.TABLEROWOPEN ();
         HTP.P ('<td>');

         FOR c1 IN (  SELECT UBI_NOMBRE, ESTADO
                        FROM GC_MV_0012
                       WHERE UF_CODIGO = p_UF_CODIGO AND ESTADO = 'Ocupada'
                    ORDER BY 1)
         LOOP
            HTP.P (
                  '<div class="bed"><img class="flip" alt="" src="/public/img/129300.png" /><div class="caption">'
               || c1.UBI_NOMBRE
               || '</div></div>');
         END LOOP;

         HTP.P ('</TD>');
         HTP.TABLEROWCLOSE;
         HTP.TABLEROWOPEN ();
         HTP.P ('<td class="rowcaption">En limpieza</td>');
         HTP.TABLEROWCLOSE;
         HTP.TABLEROWOPEN ();
         HTP.P ('<td>');

         FOR c1 IN (  SELECT UBI_NOMBRE, ESTADO
                        FROM GC_MV_0012
                       WHERE UF_CODIGO = p_UF_CODIGO AND ESTADO = 'En limpieza'
                    ORDER BY 1)
         LOOP
            HTP.P (
                  '<div class="bed"><img class="flip" alt="" src="/public/img/106008.png" /><div class="caption">'
               || c1.UBI_NOMBRE
               || '</div></div>');
         END LOOP;

         HTP.P ('</TD>');
         HTP.TABLEROWCLOSE;

         HTP.TABLEROWOPEN ();
         HTP.P ('<td class="rowcaption">Reservadas</td>');
         HTP.TABLEROWCLOSE;
         HTP.TABLEROWOPEN ();
         HTP.P ('<td>');

         FOR c1 IN (  SELECT UBI_NOMBRE, ESTADO
                        FROM GC_MV_0012
                       WHERE UF_CODIGO = p_UF_CODIGO AND ESTADO = 'Reservada'
                    ORDER BY 1)
         LOOP
            HTP.P (
                  '<div class="bed"><img class="flip" alt="" src="/public/img/121536.png" /><div class="caption">'
               || c1.UBI_NOMBRE
               || '</div></div>');
         END LOOP;

         HTP.P ('</TD>');
         HTP.TABLEROWCLOSE;
         HTP.TABLECLOSE;

         HTP.bodyclose;
         HTP.htmlclose;
      ELSE
         HTP.htmlopen;
         HTP.headopen;
         HTP.title ('VALME en directo 1.0.9 Camas');
         HTP.headclose;
         HTP.bodyopen;
         HTP.header (1, 'Parameter error');
         HTP.PRINT ('El parámetro p_UF_CODIGO es obligatorio.');
         HTP.bodyclose;
         HTP.htmlclose;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         HTP.htmlopen;
         HTP.headopen;
         HTP.title ('VALME en directo 1.0.9 Camas');
         HTP.headclose;
         HTP.bodyopen;
         HTP.header (1, 'Oracle error');
         HTP.PRINT (SQLERRM);
         HTP.bodyclose;
         HTP.htmlclose;
   END HTML;

   PROCEDURE HTM (p_UF_CODIGO IN VARCHAR2 := '0')
   IS
      v_UNIDAD_FUNCIONAL   VARCHAR2 (100);
      v_SQL_STRING         VARCHAR2 (2000)
                              := 'SELECT TO_CHAR(SYSDATE,''dy, dd mon yyyy "a las" HH24"h"MI'') SERVER_TIME FROM DUAL';
      v_rowclass           VARCHAR2 (15) := '>'; --c1                   SYS_REFCURSOR;
      v_tipo               VARCHAR2 (100) := 'N/A';
   BEGIN
      IF p_UF_CODIGO <> '0'
      THEN
         v_SQL_STRING :=
            'SELECT TUBI_DESCRIPCION AS "Tipo", UBI_NOMBRE AS "Nombre", UBI_DESCRIPCION AS "Donde" FROM GC_MV_0014 JOIN GC_MV_0014_T ON (UBI_TIP_UBICACION = TUBI_CODIGO) WHERE ROOT = '''
            || p_UF_CODIGO
            || ''' AND L = 2';

         --OPEN c1 FOR v_SQL_STRING;

         OWA_UTIL.mime_header ('text/html', FALSE);
         OWA_UTIL.http_header_close;
         HTP.htmlopen;
         HTP.headopen;
         HTP.LINKREL ('Stylesheet', '/public/css/liquid_table.css', 'text/css');
         HTP.title ('VALME en directo 1.0.9 Camas');
         HTP.p ('<meta http-equiv="content-type" content="text/html; charset=utf-8" />');
         HTP.headclose;
         HTP.bodyopen;


         --HTP.PRINT (gen_html_table (c1));

         FOR c1 IN (  SELECT TUBI_DESCRIPCION AS "Tipo", UBI_NOMBRE AS "Nombre", UBI_DESCRIPCION AS "Donde"
                        FROM GC_MV_0014 JOIN GC_MV_0014_T ON (UBI_TIP_UBICACION = TUBI_CODIGO)
                       WHERE ROOT_UBI_CODIGO = p_UF_CODIGO AND L = 2
                    ORDER BY 1, 2)
         LOOP
            IF v_tipo <> c1."Tipo"
            THEN
               IF v_tipo <> 'N/A'
               THEN
                  HTP.TABLECLOSE;
                  HTP.P ('</div>');
               END IF;

               HTP.P ('<div style="float: left; margin-top: 1%; margin-left: 1%;">');
               HTP.TABLEOPEN (cborder => 'border="0"', cattributes => 'cellspacing="0"');
               HTP.TABLEROWOPEN ();
               HTP.TABLEHEADER (cvalue => c1."Tipo");
               HTP.TABLEROWCLOSE;
               --            HTP.TABLEROWOPEN ();
               v_tipo := c1."Tipo";
            END IF;

            HTP.TABLEROWOPEN ();
            --HTP.P ('<td' || v_rowclass || c1."Tipo" || '</td>');
            --HTP.P ('<td' || v_rowclass || c1."Nombre" || '</td>');

            HTP.P ('<td' || v_rowclass || '<INPUT TYPE=BUTTON VALUE="'||c1."Nombre"||'" />' || '</td>');
            --HTP.P ('<td' || v_rowclass || '<img class="flip" alt="" src="/public/img/125443.png" />' || '</td>');

            IF v_rowclass = '>'
            THEN
               v_rowclass := ' class="alt">';
            ELSE
               v_rowclass := '>';
            END IF;

            HTP.TABLEROWCLOSE;
         --
         END LOOP;

         HTP.TABLECLOSE;
         HTP.P ('</div>');
         HTP.bodyclose;
         HTP.htmlclose;
      --CLOSE c1;
      ELSE
         HTP.htmlopen;
         HTP.headopen;
         HTP.title ('VALME en directo 1.0.9 Camas');
         HTP.headclose;
         HTP.bodyopen;
         HTP.header (1, 'Parameter error');
         HTP.PRINT ('El parámetro p_UF_CODIGO es obligatorio.');
         HTP.bodyclose;
         HTP.htmlclose;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         HTP.htmlopen;
         HTP.headopen;
         HTP.title ('VALME en directo 1.0.9 Camas');
         HTP.headclose;
         HTP.bodyopen;
         HTP.header (1, 'Oracle error');
         HTP.PRINT (SQLERRM);
         HTP.bodyclose;
         HTP.htmlclose;
   END HTM;

   FUNCTION gen_html_table (rf IN SYS_REFCURSOR)
      RETURN VARCHAR2
   AS
      lhtmloutput   XMLTYPE;
      lxsl          LONG;
      lxmldata      XMLTYPE;
      lcontext      DBMS_XMLGEN.ctxhandle;
   BEGIN
      lcontext := DBMS_XMLGEN.newcontext (rf);
      -- setNullHandling to 1 (or 2) to allow null columns
      -- to be displayed
      DBMS_XMLGEN.setnullhandling (lcontext, 1);
      -- create XML from ref cursor --
      lxmldata := DBMS_XMLGEN.getxmltype (lcontext, DBMS_XMLGEN.NONE);
      -- this is a generic XSL for Oracle's default
      -- XML row and rowset tags --
      -- " " is a non-breaking space --
      lxsl := '<?xml version="1.0" encoding="ISO-8859-1"?>
            <xsl:stylesheet version="1.0"
              xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
            <xsl:output method="html"/>
            <xsl:template match="/">
            <html xmlns="http://www.w3.org/1999/xhtml">
             <head>
            <meta http-equiv="content-type" content="text/html; charset=utf-8" />
            <link rel="Stylesheet" href="/public/css/liquid_table.css" type="text/css" />
            <title>VALME en directo</title>
              </head>
              <body bgcolor="White">
               <table cellspacing="1">
                 <tr class="th">
                  <xsl:for-each select="/ROWSET/ROW[1]/*">
                   <th><xsl:value-of select="name()"/></th>
                  </xsl:for-each>
                 </tr>
                 <xsl:for-each select="/ROWSET/*">
                 <xsl:if test="position()  mod 2 = 1">
                  <tr>
                   <xsl:for-each select="./*">                    
                    <td><xsl:value-of select="text()"/></td>
                   </xsl:for-each>
                  </tr>
                  </xsl:if>
                  <xsl:if test="position()  mod 2 = 0">
                  <tr>
                   <xsl:for-each select="./*">                    
                    <td class="alt"><xsl:value-of select="text()"/></td>
                   </xsl:for-each>
                  </tr>
                  </xsl:if>
                 </xsl:for-each>
               </table>
               </body>
            </html>
              </xsl:template>
            </xsl:stylesheet>'; --  <link rel="stylesheet" href="http://rufiano/almagesto/css/Azul.css" type="text/css" />
      -- XSL transformation to convert XML to HTML --
      lhtmloutput := lxmldata.transform (XMLTYPE (lxsl));
      -- convert XMLType to Clob --
      DBMS_XMLGEN.closecontext (lcontext);
      RETURN DBMS_LOB.SUBSTR (lhtmloutput.getclobval ());
   END gen_html_table;
END PX003_CAMAS;
/
