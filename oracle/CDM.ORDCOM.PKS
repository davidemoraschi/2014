CREATE OR REPLACE PACKAGE CDM.ORDCOM AS


   /* Declare externally callable subprograms. */

   FUNCTION GetProperty (
	token binary_integer,
	PropName VARCHAR2,
	argCount binary_integer,
	retVal out double precision) return binary_integer;

   FUNCTION GetProperty (
	token binary_integer,
	PropName VARCHAR2,
	argCount binary_integer,
	retVal out VARCHAR2) return binary_integer;

   FUNCTION GetProperty (
	token binary_integer,
	PropName VARCHAR2,
	argCount binary_integer,
	retVal out boolean) return binary_integer;

   FUNCTION GetProperty (
	token binary_integer,
	PropName VARCHAR2,
	argCount binary_integer,
	retVal out DATE) return binary_integer;

   FUNCTION SetProperty (
	token binary_integer,
	PropName VARCHAR2,
	inVal double precision,
	DataType VARCHAR2) return binary_integer;

   FUNCTION SetProperty (
	token binary_integer,
	PropName VARCHAR2,
	inVal VARCHAR2,
	DataType VARCHAR2) return binary_integer;


   FUNCTION SetProperty (
	token binary_integer,
	PropName VARCHAR2,
	inVal boolean,
	DataType VARCHAR2) return binary_integer;

   FUNCTION SetProperty (
	token binary_integer,
	PropName VARCHAR2,
	inVal DATE,
	DataType VARCHAR2) return binary_integer;

   PROCEDURE InitArg;

   PROCEDURE SetArg(
	data double precision,
	type VARCHAR2);

   PROCEDURE SetArg(
	data VARCHAR2,
	type VARCHAR2);

   PROCEDURE SetArg(
	data DATE,
	type VARCHAR2);

   PROCEDURE SetArg(
	data BOOLEAN,
	type VARCHAR2);

   PROCEDURE SetPtrArg(
	data out double precision,
	type VARCHAR2);

   PROCEDURE SetPtrArg(
	data out VARCHAR2,
	type VARCHAR2);

   PROCEDURE InitOutArg;

   PROCEDURE GetArg(
	data out double precision,
      type VARCHAR2);

   PROCEDURE GetArg(
	data out VARCHAR2,
	type VARCHAR2);

   PROCEDURE GetArg(
	data out DATE,
	type VARCHAR2);

   PROCEDURE GetArg(
	data out BOOLEAN,
	type VARCHAR2);

   PROCEDURE GetLastError(
	 err_src out VARCHAR2,
	 err_desc out VARCHAR2,
	 err_help out VARCHAR2,
	 err_helpID out binary_integer);

   FUNCTION Invoke (
     token binary_integer,
	 MethodName VARCHAR2,
	 argCount binary_integer,
	 retVal  out double precision) return binary_integer;

   FUNCTION Invoke (
     token binary_integer,
	 MethodName VARCHAR2,
	 argCount binary_integer,
	 retVal  out boolean) return binary_integer;

   FUNCTION Invoke (
     token binary_integer,
	 MethodName VARCHAR2,
	 argCount binary_integer,
	 retVal  out VARCHAR2) return binary_integer;

   FUNCTION Invoke (
     token binary_integer,
	 MethodName VARCHAR2,
	 argCount binary_integer,
	 retVal  out DATE) return binary_integer;

   FUNCTION CreateObject(
	 ProgID VARCHAR2,
	 crtype binary_integer,
	 servername VARCHAR2,
	 token out binary_integer) return binary_integer;


   FUNCTION DestroyObject(
     token binary_integer) return binary_integer;

END ORDCOM;
/
