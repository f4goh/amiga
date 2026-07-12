#include <exec/types.h>
#include <intuition/intuition.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <hardware/custom.h>
#include <clib/graphics_protos.h>
#include <graphics/gfxbase.h>
#include <ahpc_registers.h>
#include <stdio.h>

#include "montagne.h"

#define NB_PLAN        5
#define HAUTEUR_IMAGE  256
#define BYTES_PER_LINE 40

// 20 instead of 127 because of input.device priority
#define TASK_PRIORITY           (20)
#define PRA_FIR0_BIT            (1 << 6)

// copper instruction macros
#define COP_MOVE(addr, data) addr, data
#define COP_WAIT_END  0xffff, 0xfffe

extern struct GfxBase *GfxBase;
extern struct Custom custom;

static UWORD __chip coplist_pal[] = {
    //BPLCON0, 0x0000,
    FMODE,   0,
    DIWSTRT, 0x2C81, DIWSTOP, 0x2CC1, DDFSTRT, 0x0038, DDFSTOP, 0x00D0,
    BPLCON1, 0x0000, BPLCON2, 0x0000, BPL1MOD, 0x0000, BPL2MOD, 0x0000,

    BPL1PTH, 0x0000, BPL1PTL, 0x0000,
    BPL2PTH, 0x0000, BPL2PTL, 0x0000,
    BPL3PTH, 0x0000, BPL3PTL, 0x0000,
    BPL4PTH, 0x0000, BPL4PTL, 0x0000,
    BPL5PTH, 0x0000, BPL5PTL, 0x0000,

    0x2E01, 0xFFFE,
    BPLCON0, 0x5200,
    
    COLOR00, 0x0000,
    COLOR01, 0x0FFF,
    COLOR02, 0x0ACD,
    COLOR03, 0x0121,
    COLOR04, 0x0120,
    COLOR05, 0x0789,
    COLOR06, 0x08AA,
    COLOR07, 0x0478,
    COLOR08, 0x0444,
    COLOR09, 0x0469,
    COLOR10, 0x0456,
    COLOR11, 0x069B,
    COLOR12, 0x0146,
    COLOR13, 0x0684,
    COLOR14, 0x047A,
    COLOR15, 0x0365,

    COLOR16, 0x0774,
    COLOR17, 0x0351,
    COLOR18, 0x0135,
    COLOR19, 0x0445,
    COLOR20, 0x0662,
    COLOR21, 0x09A5,
    COLOR22, 0x0772,
    COLOR23, 0x08A6,

    COLOR24, 0x0167,
    COLOR25, 0x0322,
    COLOR26, 0x0A99,
    COLOR27, 0x0042,
    COLOR28, 0x0874,
    COLOR29, 0x0474,
    COLOR30, 0x0797,
    COLOR31, 0x0434,
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

void installPlans(void)
{
    ULONG addr = (ULONG)montagne_raw;
    UWORD *cop = &coplist_pal[18];   // début de bmap (0x00E0)

    for (int i = 0; i < NB_PLAN; i++)
    {
        cop[1] = (UWORD)(addr >> 16);    // BPLxPTH
        cop[3] = (UWORD)(addr & 0xFFFF); // BPLxPTL

        addr += BYTES_PER_LINE * HAUTEUR_IMAGE;
        cop += 4;   // passe au couple de registres suivant (E0/E2 -> E4/E6 ...)
    }
}

void affiche(void)
{
    int i;
    for (i = 0; i < 40; i++)
    {
        printf("%04X ", coplist_pal[i]);

        if ((i & 7) == 7)   // 8 mots par ligne
            printf("\n");
    }

}



int main(int argc, char **argv)
{
    SetTaskPri(FindTask(NULL), TASK_PRIORITY);
    BOOL is_pal = init_display();
    //printf("PAL display: %d\n", is_pal);
    installPlans();
    //printf("%08lx\n", (ULONG)montagne_raw);
    //printf("%lu\n", (unsigned long)sizeof(montagne_raw));
    custom.dmacon = 0x7FFF;
    custom.cop1lc = (ULONG)coplist_pal;
    custom.copjmp1 = 0;
    custom.dmacon = 0x83C0;
    waitmouse();  // replace with logic
    reset_display();
    return 0;
}
