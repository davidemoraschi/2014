CREATE OR REPLACE PROCEDURE CDM.data  AS 
 BEGIN NULL;
owa_util.mime_header('text/html'); htp.prn('¿');
htp.prn('
');
htp.prn('
');
htp.prn('
');
htp.prn('
google.visualization.Query.setResponse(
{
   status:''ok'',
   table:
   {
      cols:
      [
         {id:''Col1'',label:'''',type:''string''},
         {id:''Col2'',label:''Label1'',type:''number''},
         {id:''Col3'',label:''Label2'',type:''number''},
         {id:''Col4'',label:''Label3'',type:''number''}
      ],
      rows:
      [
         {c:[{v:''a'',f:''a''},{v:1.0,f:''1''},{v:1.0,f:''1''},{v:1,f:''1''}]},
         {c:[{v:''b'',f:''b''},{v:2.0,f:''2''},{v:1.5,f:''1''},{v:1,f:''1''}]},
         {c:[{v:''c'',f:''c''},{v:3.0,f:''3''},{v:2.5,f:''1''},{v:1,f:''1''}]},
         {c:[{v:''d'',f:''d''},{v:4.0,f:''1''},{v:2.0,f:''1''},{v:2,f:''1''}]}
      ]
   }
});
');
 END;
/

