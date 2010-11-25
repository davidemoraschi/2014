CREATE OR REPLACE FUNCTION CDM.OACreate(
	x in varchar2,
	a in binary_integer,
	b in varchar2,
	c out binary_integer)
    return binary_integer as external
	library utils_lib
	name "OACreate"
	language C
	with context;
/
