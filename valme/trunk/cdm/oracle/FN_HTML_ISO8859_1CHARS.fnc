CREATE OR REPLACE FUNCTION CDM.fn_html_iso8859_1chars (p_input IN VARCHAR2)
   RETURN VARCHAR2
AS
   r_output                      VARCHAR2 (4000);
BEGIN
   r_output := p_input;
   r_output := REPLACE (r_output, 'Espa�a', 'Spain');   -- Si no no encuentra Jerez de la frontera, tonto de un Google
   r_output := REPLACE (r_output, 'Alcal�', 'Alcala');  -- Si no no encuentra Alcal� de Henares, tonto de un Google
   r_output := REPLACE (r_output, 'Mor�n', 'Moron');    -- Si no no encuentra Moron de la Frontera, tonto de un Google
   r_output := REPLACE (r_output, '�', '&aacute;');
   r_output := REPLACE (r_output, '�', '&aacute;');
   r_output := REPLACE (r_output, '�', '&eacute;');
   r_output := REPLACE (r_output, '�', '&iacute;');
   r_output := REPLACE (r_output, '�', '&oacute;');
   r_output := REPLACE (r_output, '�', '&uacute;');
   r_output := REPLACE (r_output, ' ', '+');
   RETURN r_output;
END; 
/

