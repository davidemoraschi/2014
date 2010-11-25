CREATE OR REPLACE PACKAGE BODY CDM.ORDCOM AS
   dblVal double precision;
   inArgTable OAArgTable := OAArgTable();
   inArgTypeTable OAArgTypeTable := OAArgTypeTable();
   outArgTable OAArgTable := OAArgTable();
   outArgTableIdx binary_integer := 1;
   i binary_integer;
   j binary_integer;
   str VARCHAR2(32767);
   strl binary_integer;
   temp VARCHAR2(32767);

   PROCEDURE NextOutArg(arg out VARCHAR2) IS
   BEGIN
      arg := NULL;
      IF (outArgTableIdx >= outArgTable.FIRST) AND (outArgTableIdx <= outArgTable.LAST) THEN
         arg := outArgTable(outArgTableIdx);
         outArgTableIdx := outArgTableIdx + 1;
      END IF;
   END NextOutArg;

   FUNCTION GetProperty (
	token binary_integer,
	PropName VARCHAR2,
	argCount binary_integer,
	retVal out double precision) RETURN binary_integer IS
   BEGIN
   	i:=OAgetNumber(token, PropName, inArgTable, inArgTypeTable, dblVal, argCount);
	retval:=dblVal;
	RETURN i;
   END GetProperty;

   FUNCTION GetProperty (
	token binary_integer,
	PropName VARCHAR2,
	argCount binary_integer,
	retVal out VARCHAR2) RETURN binary_integer IS
   BEGIN
   	i:=OAgetStr(token, PropName, inArgTable, inArgTypeTable, temp, argCount);
      retVal := temp;
	RETURN i;
   END GetProperty;


   FUNCTION GetProperty (
	token binary_integer,
	PropName VARCHAR2,
	argCount binary_integer,
	retVal out DATE) RETURN binary_integer IS
	tempstr varchar2(20);
   BEGIN
   	i:=OAgetStr(token, PropName, inArgTable, inArgTypeTable, tempstr, argCount);
	retVal:=TO_DATE(tempstr, 'DD MM YYYY HH24 MI SS');
	RETURN i;
   END GetProperty;

   FUNCTION GetProperty (
	token binary_integer,
	PropName VARCHAR2,
	argCount binary_integer,
	retVal out boolean) RETURN binary_integer IS
   BEGIN
   	i:=OAgetBool(token, PropName, inArgTable, inArgTypeTable, retVal, argCount);
	RETURN i;
   END GetProperty;


   FUNCTION SetProperty (
	token binary_integer,
	PropName VARCHAR2,
	inVal double precision,
	Datatype VARCHAR2) RETURN binary_integer IS
   BEGIN
   	i:=OAsetNumber(token, PropName, inVal, Datatype);
	RETURN i;
   END SetProperty;

   FUNCTION SetProperty (
	token binary_integer,
	PropName VARCHAR2,
	inVal VARCHAR2,
	Datatype VARCHAR2) RETURN binary_integer IS
   BEGIN
   	i:=OAsetString(token, PropName, inVal, Datatype);
	RETURN i;
   END SetProperty;

   FUNCTION SetProperty (
	token binary_integer,
	PropName VARCHAR2,
	inVal boolean,
	Datatype VARCHAR2) RETURN binary_integer IS
   BEGIN
   	i:=OAsetBoolean(token, PropName, inVal, Datatype);
	RETURN i;
   END SetProperty;

   FUNCTION SetProperty (
	token binary_integer,
	PropName VARCHAR2,
	inVal DATE,
	Datatype VARCHAR2) RETURN binary_integer IS
	OLEDate VARCHAR2(50);
   BEGIN
    OLEDate:=TO_CHAR(inVal,'DD MM YYYY HH24 MI SS');
   	i:=OAsetString(token, PropName, OLEDate, Datatype);
	RETURN i;
   END SetProperty;

   PROCEDURE InitArg IS
   BEGIN
      inArgTable := OAArgTable();
      inArgTypeTable := OAArgTypeTable();
      outArgTable := OAArgTable();
      outArgTableIdx := 1;
   END InitArg;

   PROCEDURE SetArg(
	data double precision,
	type VARCHAR2) IS
   BEGIN
      inArgTable.EXTEND;
      inArgTypeTable.EXTEND;
      inArgTable(inArgTable.LAST) := TO_CHAR(data);
      inArgTypeTable(inArgTypeTable.LAST) := type;
   END SetArg;

   PROCEDURE SetArg(
	data boolean,
	type VARCHAR2) IS
   BEGIN
      inArgTable.EXTEND;
      inArgTypeTable.EXTEND;
      IF data THEN
         inArgTable(inArgTable.LAST) := '-1';
      ELSE
         inArgTable(inArgTable.LAST) := '0';
      END IF;
      inArgTypeTable(inArgTypeTable.LAST) := type;
   END SetArg;

   PROCEDURE SetPtrArg(
	data out double precision,
	type VARCHAR2) IS
   BEGIN
      data := 0;
   END SetPtrArg;

   PROCEDURE SetPtrArg(
	data out VARCHAR2,
	type VARCHAR2) IS
   BEGIN
      data := '';
   END SetPtrArg;

   PROCEDURE SetArg(
	data VARCHAR2,
	type VARCHAR2) IS
   BEGIN
      inArgTable.EXTEND;
      inArgTypeTable.EXTEND;
      inArgTable(inArgTable.LAST) := data;
      inArgTypeTable(inArgTypeTable.LAST) := type;
   END SetArg;

   PROCEDURE SetArg(
	data DATE,
	type VARCHAR2) IS
   BEGIN
      inArgTable.EXTEND;
      inArgTypeTable.EXTEND;
      inArgTable(inArgTable.LAST) := TO_CHAR(data,'DD MM YYYY HH24 MI SS');
      inArgTypeTable(inArgTypeTable.LAST) := type;
   END SetArg;

   PROCEDURE InitOutArg IS
   BEGIN
      outArgTableIdx := 1;
   END InitOutArg;

   PROCEDURE GetArg(
	data out double precision,
      type VARCHAR2) IS
   BEGIN
      data := 0;
      NextOutArg(str);
      IF NOT (str IS NULL) THEN
         data := TO_NUMBER(str);
      END IF;
   END GetArg;

   PROCEDURE GetArg(
	data out boolean,
	type VARCHAR2) IS
   BEGIN
      data := FALSE;
      NextOutArg(str);
      IF NOT (str IS NULL) THEN
         IF TO_NUMBER(str) != 0 THEN
            data := TRUE;
         END IF;
      END IF;
   END GetArg;

   PROCEDURE GetArg(
	data out VARCHAR2,
	type VARCHAR2) IS
   BEGIN
      NextOutArg(data);
   END GetArg;

   PROCEDURE GetArg(
	data out DATE,
	type VARCHAR2) IS
   BEGIN
      data := TO_DATE('01 01 0001 00 00 00', 'DD MM YYYY HH24 MI SS');
      NextOutArg(str);
      IF NOT (str IS NULL) THEN
         data := TO_DATE('01 01 0001 00 00 00', 'DD MM YYYY HH24 MI SS');
      END IF;
   END GetArg;

   FUNCTION Invoke (
     token binary_integer,
	 MethodName VARCHAR2,
	 argCount binary_integer,
	 retVal out double precision) RETURN binary_integer IS
    BEGIN
       i:=OAInvokeDouble(token, MethodName, inArgTable, inArgTypeTable, argCount, retVal, outArgTable);
       RETURN i;
   END Invoke;

   FUNCTION Invoke (
     token binary_integer,
	 MethodName VARCHAR2,
	 argCount binary_integer,
	 retVal out boolean) RETURN binary_integer IS
    BEGIN
       i:=OAInvokeBoolean(token, MethodName, inArgTable, inArgTypeTable, argCount, retVal, outArgTable);
       RETURN i;
   END Invoke;

   FUNCTION Invoke (
     token binary_integer,
	 MethodName VARCHAR2,
	 argCount binary_integer,
	 retVal out VARCHAR2) RETURN binary_integer IS
    BEGIN
       i:=OAInvokeString(token, MethodName, inArgTable, inArgTypeTable, argCount, temp, outArgTable);
       retVal := temp;
       RETURN i;
   END Invoke;

   FUNCTION Invoke (
     token binary_integer,
	 MethodName VARCHAR2,
	 argCount binary_integer,
	 retVal out DATE) RETURN binary_integer IS
       tempstr varchar2(20);
    BEGIN
       i:=OAInvokeString(token, MethodName, inArgTable, inArgTypeTable, argCount, tempstr, outArgTable);
       IF i = 0 THEN
         retVal:=TO_DATE(tempstr, 'DD MM YYYY HH24 MI SS');
       END IF;
       RETURN i;
   END Invoke;

   FUNCTION CreateObject(
	 ProgID VARCHAR2,
	 crtype binary_integer,
	 servername VARCHAR2,
	 token out binary_integer) RETURN binary_integer IS
   BEGIN
	  i:=OACreate(ProgID, crtype, servername, token);
	  RETURN i;
   END CreateObject;

  PROCEDURE GetLastError(
	 err_src out VARCHAR2,
	 err_desc out VARCHAR2,
	 err_help out VARCHAR2,
	 err_helpID out binary_integer) IS
       terr_src VARCHAR(1025);
       terr_desc VARCHAR(1025);
       terr_help VARCHAR(1025);
  BEGIN
	i:=OAGetLastError(terr_src, terr_desc, terr_help, err_helpID);
      err_src := terr_src;
      err_desc := terr_desc;
      err_help := terr_help;
  END GetLastError;

   FUNCTION DestroyObject(
     token binary_integer) RETURN binary_integer IS
   BEGIN
	  i:=OADestroy(token);
	  RETURN i;
   END DestroyObject;

END ORDCOM;
/
