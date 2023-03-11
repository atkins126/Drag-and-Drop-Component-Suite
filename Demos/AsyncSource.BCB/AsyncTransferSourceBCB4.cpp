//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("AsyncTransferSourceBCB4.res");
USEFORM("main.cpp", FormMain);
USEFILE("..\AsyncSource\readme.txt");
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
	try
	{
		Application->Initialize();
		Application->CreateForm(__classid(TFormMain), &FormMain);
		Application->Run();
	}
	catch (Exception &exception)
	{
		Application->ShowException(&exception);
	}
	return 0;
}
//---------------------------------------------------------------------------
