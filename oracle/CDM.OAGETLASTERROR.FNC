CREATE OR REPLACE FUNCTION CDM.OAGetLastError(
	a out VARCHAR2,
	b out VARCHAR2,
	c out VARCHAR2,
	d out binary_integer)
    return binary_integer as external
	library utils_lib
	name "OAgetLastError"
	language C;
/
