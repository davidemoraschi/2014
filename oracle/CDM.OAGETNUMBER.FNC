CREATE OR REPLACE FUNCTION CDM.OAgetNumber(
	x in binary_integer,
	a in varchar2,
	plist in OAArgTable,
	ptype in OAArgTypeTable,
	d out double precision,
	count in binary_integer)
	return binary_integer as external
	library utils_lib
	name "OAgetNumber"
	language C;
/
