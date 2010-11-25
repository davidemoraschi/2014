CREATE OR REPLACE FUNCTION CDM.OAQueryMethods(
	a binary_integer,
	b out VARCHAR2)
    return binary_integer as external
	library utils_lib
	name "OAQueryMethods"
	language C;
/
