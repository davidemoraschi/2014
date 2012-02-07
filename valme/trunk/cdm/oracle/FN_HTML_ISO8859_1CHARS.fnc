CREATE OR REPLACE FUNCTION CDM.fn_html_iso8859_1chars (p_input IN VARCHAR2)
   RETURN VARCHAR2
AS
   r_output                      VARCHAR2 (4000);
BEGIN
   r_output := p_input;
   r_output := REPLACE (r_output, 'España', 'Spain');   -- Si no no encuentra Jerez de la frontera, tonto de un Google
   r_output := REPLACE (r_output, 'Alcalá', 'Alcala');  -- Si no no encuentra Alcalá de Henares, tonto de un Google
   r_output := REPLACE (r_output, 'Morón', 'Moron');    -- Si no no encuentra Moron de la Frontera, tonto de un Google
   r_output := REPLACE (r_output, 'á', '&aacute;');
   r_output := REPLACE (r_output, 'á', '&aacute;');
   r_output := REPLACE (r_output, 'é', '&eacute;');
   r_output := REPLACE (r_output, 'í', '&iacute;');
   r_output := REPLACE (r_output, 'ó', '&oacute;');
   r_output := REPLACE (r_output, 'ú', '&uacute;');
   r_output := REPLACE (r_output, ' ', '+');
   RETURN r_output;
END; 
/

