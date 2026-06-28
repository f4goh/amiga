#include <exec/types.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
//#include <graphics/rastport.h>

//#include <stdlib.h>



static struct NewWindow newwin = {
    20, 20, 300, 100, 0, 1,
    IDCMP_CLOSEWINDOW,
    WFLG_CLOSEGADGET | WFLG_SMART_REFRESH | WFLG_ACTIVATE |
    WFLG_SIZEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET,
    NULL, NULL, "A simple Window",
    NULL, NULL, 0, 0, 0, 0,
    WBENCHSCREEN
};


int main(int argc, char **argv)
{
    struct Window *Window;


    if ((Window = (struct Window *) OpenWindow(&newwin)) == NULL) {
        return 0;
    }

    Wait(1 << Window->UserPort->mp_SigBit);
    CloseWindow(Window);

    return 0;
}

