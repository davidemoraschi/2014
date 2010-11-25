CREATE OR REPLACE FUNCTION CDM.OAsetBoolean(
	x in binary_integer,
	a in varchar2,
	b in boolean,
	d in varchar2)
    return binary_integer as external
	library utils_lib
	name "OAsetBoolean"
	language C;
/
