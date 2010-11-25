CREATE OR REPLACE FUNCTION CDM.OAInvokeBoolean(
	x in binary_integer,
	a in varchar2,
	b in OAArgTable,
	c in OAArgTypeTable,
	d in binary_integer,
	e out boolean,
	f in out OAArgTable)
    return binary_integer as external
	library utils_lib
	name "OAInvokeBoolean"
	language C
	parameters (x, a, b, c, d, e, f, RETURN);
/
