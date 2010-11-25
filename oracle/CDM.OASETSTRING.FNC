CREATE OR REPLACE FUNCTION CDM.OAsetString(
	x in binary_integer,
	a in varchar2,
	b in varchar2,
	d in varchar2)
    return binary_integer as external
	library utils_lib
	name "OAsetString"
	language C;
/
