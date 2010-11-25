CREATE OR REPLACE FUNCTION CDM.OAgetbool(
	x in binary_integer,
	a in varchar2,
	plist in OAArgTable,
	ptype in OAArgTypeTable,
	b out boolean,
	count in binary_integer)
	return binary_integer as external
	library utils_lib
	name "OAgetBool"
	language C;
/
