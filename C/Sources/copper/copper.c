//https://github.com/weiju/amiga_hardware_in_c/blob/master/episode-002/startup.c
#include <exec/types.h>
#include <intuition/intuition.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <hardware/custom.h>
#include <clib/graphics_protos.h>
#include <graphics/gfxbase.h>
#include <stdio.h>

// 20 instead of 127 because of input.device priority
#define TASK_PRIORITY           (20)
#define COLOR00                 (0x180)
#define BPLCON0                 (0x100)
#define PRA_FIR0_BIT            (1 << 6)
#define BPLCON0_COMPOSITE_COLOR (1 << 9)

// copper instruction macros
#define COP_MOVE(addr, data) addr, data
#define COP_WAIT_END  0xffff, 0xfffe

extern struct GfxBase *GfxBase;
extern struct Custom custom;

static UWORD __chip coplist_pal[] = {
    COP_MOVE(BPLCON0, BPLCON0_COMPOSITE_COLOR),
    COP_MOVE(COLOR00, 0x00f),
    0x7c07, 0xfffe,            // wait for 1/3 (0x07, 0x7c)
    COP_MOVE(COLOR00, 0xfff),
    0xda07, 0xfffe,            // wait for 2/3 (0x07, 0xda)
    COP_MOVE(COLOR00, 0xf00), 
    COP_WAIT_END
};


BOOL init_display(void)
{
    LoadView(0);  // clear display, reset hardware registers
    WaitTOF();       // 2 WaitTOFs to wait for 1. long frame and
    WaitTOF();       // 2. short frame copper lists to finish (if interlaced)
    return (((struct GfxBase *) GfxBase)->DisplayFlags & PAL) == PAL;
}

void reset_display(void)
{
    LoadView(((struct GfxBase *) GfxBase)->ActiView);
    WaitTOF();
    WaitTOF();
    custom.cop1lc = (ULONG) ((struct GfxBase *) GfxBase)->copinit;
    RethinkDisplay();
}

void waitmouse(void)
{
    volatile UBYTE *ciaa_pra = (volatile UBYTE *) 0xbfe001;
    while ((*ciaa_pra & PRA_FIR0_BIT) != 0) ;
}


int main(int argc, char **argv)
{
    SetTaskPri(FindTask(NULL), TASK_PRIORITY);
    BOOL is_pal = init_display();
    printf("PAL display: %d\n", is_pal);
    custom.cop1lc = (ULONG) coplist_pal;
    waitmouse();  // replace with logic
    reset_display();
    return 0;
}
