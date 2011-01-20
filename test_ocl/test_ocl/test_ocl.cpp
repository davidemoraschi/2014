
#include "stdafx.h"
#include "ocl.h"
#include <iostream>

using namespace ocl;
using namespace std;

int _tmain(int argc, _TCHAR* argv[])
{
	OraConnection connection;
	connection.setUsername("cdm");
	connection.setPassword("iPaddellaSamsung");
	connection.setServer("mti");
	connection.open();

	OraQuery query;
	query.setConnection(connection);
	query.setCommandText("SELECT * FROM HTML_RSS_NEW");
	try 
	{
		query.open();
	}
	catch (OraException& e) 
	{
		cout << e.message();
	}
	while (!query.isEOF()) {
		cout << "TITLE: " << query.field("TITLE").getString() << endl;
		query.next();
	}
	query.close();
	connection.close();
	system("PAUSE");
	return 0;
}

