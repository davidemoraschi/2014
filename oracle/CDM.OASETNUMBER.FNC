CREATE OR REPLACE FUNCTION CDM.OAsetNumber(
	x in binary_integer,
	a in varchar2,
	b in double precision,
	d in varchar2)
    return binary_integer as external
	library utils_lib
	name "OAsetNumber"
	language C;
/
