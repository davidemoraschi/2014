CREATE OR REPLACE FUNCTION CDM.OADestroy(
	a binary_integer)
    return binary_integer as external
	library utils_lib
	name "OADestroy"
	language C;
/
