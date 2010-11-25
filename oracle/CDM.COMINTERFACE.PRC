CREATE OR REPLACE PROCEDURE CDM.COMInterface
AS
   --OrdCom functions return the COM result code,
   --customarily known as HRESULT, as binary_integer
   hresult             BINARY_INTEGER := 0;
   --Some variables to hold our object tokens
   ApplicationHandle   BINARY_INTEGER := -1;
   ResultHandle        BINARY_INTEGER := -1;
   DummyHandle         BINARY_INTEGER := -1;
   error_src           VARCHAR2 (500);
   error_description   VARCHAR2 (500);
   error_helpfile      VARCHAR2 (500);
   error_helpID        BINARY_INTEGER;
BEGIN
   --Create the application object
   --and put its token in ApplicationHandle
   hresult := ORDCOM.CreateObject ('DSSDataSource.DSSDataSource.1', 0, '', ApplicationHandle);

   IF (hresult != 0)
   THEN
      ORDCOM.GetLastError (error_src, error_description, error_helpfile, error_helpID);
      DBMS_OUTPUT.put_line ('Error creating
                 application, aborting: ' || hresult);
      DBMS_OUTPUT.put_line (error_src);
      DBMS_OUTPUT.put_line (error_description);
      DBMS_OUTPUT.put_line (error_helpfile);
   END IF; --Invoke some methods

   --The following is equivalent to the pseudocode:
   --ResultHandle := ApplicationHandle.SomeMethodname
   hresult := OrdCom.Invoke (ApplicationHandle, 'SomeMethodName', 0, ResultHandle);

   --Invoke the "quit" method for Excel
   hresult := OrdCom.Invoke (ApplicationHandle, 'Quit', 0, DummyHandle);

   --Destroy the application object
   hresult := ORDCOM.DESTROYOBJECT (ApplicationHandle);
END;
/
