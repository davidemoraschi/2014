CREATE OR REPLACE FUNCTION CDM.OAInvokeString(
	x in binary_integer,
	a in varchar2,
	b in OAArgTable,
	c in OAArgTypeTable,
	d in binary_integer,
	e out varchar2,
	f in out OAArgTable)
    return binary_integer as external
	library utils_lib
	name "OAInvokeString"
	language C
	parameters (x, a, b, c, d, e, e MAXLEN, f, RETURN);
/
