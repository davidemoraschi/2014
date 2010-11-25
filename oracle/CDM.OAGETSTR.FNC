CREATE OR REPLACE FUNCTION CDM.OAgetStr(
	x in binary_integer,
	a in varchar2,
	plist in OAArgTable,
	ptype in OAArgTypeTable,
	b out varchar2,
	count in binary_integer)
	return binary_integer as external
	library utils_lib
	name "OAgetStr"
	language C
	parameters (x, a, plist, ptype, b, b MAXLEN, count, RETURN);
/
