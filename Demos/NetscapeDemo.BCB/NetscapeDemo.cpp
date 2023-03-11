//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("NetscapeDemo.res");
USEFORM("main.cpp", FormMain);
USE("..\NetscapeDemo\readme.txt", File);
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