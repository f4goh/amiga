#include <exec/types.h>
#include <intuition/intuition.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <hardware/custom.h>
#include <clib/graphics_protos.h>
#include <graphics/gfxbase.h>
#include <ahpc_registers.h>
#include <stdio.h>

#include "tileset.h"

#define NB_PLAN        5
#define HAUTEUR_IMAGE  256
#define BYTES_PER_LINE 40

// 20 instead of 127 because of input.device priority
#define TASK_PRIORITY           (20)
#define PRA_FIR0_BIT            (1 << 6)

// copper instruction macros
#define COP_MOVE(addr, data) addr, data
#define COP_WAIT_END  0xffff, 0xfffe
#define COPLIST_IDX_SPR0_PTH_VALUE (3)
#define COPLIST_IDX_COLOR00_VALUE 18+32+25
#define SPR6_IDX (COPLIST_IDX_SPR0_PTH_VALUE + 6 * 4)
 

extern struct GfxBase *GfxBase;
extern struct Custom custom;

UBYTE level[9][20] =
{
    {255,255, 2, 0, 0, 7, 2,255,255,255,255,255,255,255,255,255,255,255,255,255},
    {255, 2, 7, 5, 5, 5, 0, 2,255,255,255,255,255,255,255,255,255,255,255,255},
    {255, 2, 5, 5, 5, 5, 6, 2,255,255,255,255,255,255,255,255,255,255,255,255},
    { 2, 0,11, 5,10,11, 6, 2,255,255, 2, 0, 0, 2,255,255,255,255,255,255},
    { 2, 5,16, 5,15,16, 6, 0, 0, 7, 1, 5, 3, 2,255,255,255,255,255,255},
    { 2, 8, 6, 5,12,12, 5, 5,18,18, 5, 5, 3, 2,255,255,255,255,255,255},
    { 7, 0, 2, 6,24,24, 6, 2,18, 5, 5, 5, 3, 2,255,255,255,255,255,255},
    {255,255, 2, 6, 6,13, 6, 2, 0, 0, 0, 0, 0, 0,255,255,255,255,255,255},
    {255,255, 1, 0, 7, 0, 0, 1,255,255,255,255,255,255,255,255,255,255,255,255}
};

// null sprite data for sprites that are supposed to be inactive
static UWORD __chip NULL_SPRITE_DATA[] = {
    0x0000, 0x0000,
    0x0000, 0x0000
};

static UWORD nemo_palette[] = {
  0x0672, 0x0100, 0x0fff, 0x0d40
};

static UWORD __chip nemo_data[] = {
  0x0008, 0x0000,
  0x0300, 0x0000,
  0x1f80, 0x1fe0,
  0x6f30, 0x7ff0,
  0xec78, 0xdff8,
  0x6e78, 0x7dfc,
  0x1ef7, 0x1bfe,
  0x0ee7, 0x07fe,
  0x0466, 0x0004,
  0x0000, 0x0000
};


static UBYTE __chip ecran[BYTES_PER_LINE*HAUTEUR_IMAGE*NB_PLAN];

static UWORD __chip coplist[] = {
    //BPLCON0, 0x0000,
    FMODE,   0,

    SPR0PTH, 0, SPR0PTL, 0,
    SPR1PTH, 0, SPR1PTL, 0,
    SPR2PTH, 0, SPR2PTL, 0,
    SPR3PTH, 0, SPR3PTL, 0,
    SPR4PTH, 0, SPR4PTL, 0,
    SPR5PTH, 0, SPR5PTL, 0,
    SPR6PTH, 0, SPR6PTL, 0,
    SPR7PTH, 0, SPR7PTL, 0,

    DIWSTRT, 0x2C81, DIWSTOP, 0x2CC1, DDFSTRT, 0x0038, DDFSTOP, 0x00D0,
    BPLCON1, 0x0000, BPLCON2, 0x0020, BPL1MOD, 0x0000, BPL2MOD, 0x0000,

    BPL1PTH, 0x0000, BPL1PTL, 0x0000,
    BPL2PTH, 0x0000, BPL2PTL, 0x0000,
    BPL3PTH, 0x0000, BPL3PTL, 0x0000,
    BPL4PTH, 0x0000, BPL4PTL, 0x0000,
    BPL5PTH, 0x0000, BPL5PTL, 0x0000,

    0x2E01, 0xFFFE,
    BPLCON0, 0x5200,
    
    COLOR00,0x000,
    COLOR01,0x567,
    COLOR02,0x9AA,
    COLOR03,0x446,
    COLOR04,0x778,
    COLOR05,0xD52,
    COLOR06,0x792,
    COLOR07,0xA32,
    COLOR08,0x582,
    COLOR09,0x334,
    COLOR10,0xCCC,
    COLOR11,0xBBB,
    COLOR12,0x362,
    COLOR13,0xC84,
    COLOR14,0x963,
    COLOR15,0xD83,
    COLOR16,0xF93,
    COLOR17,0xCA6,
    COLOR18,0x753,
    COLOR19,0xA43,
    COLOR20,0x257,
    COLOR21,0x079,
    COLOR22,0x089,
    COLOR23,0x733,
    COLOR24,0x323,
    COLOR25,0x673,
    COLOR26,0xC62,
    COLOR27,0x443,
    COLOR28,0x653,
    COLOR29,0x000,
    COLOR30,0x000,
    COLOR31,0x000,
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
    ULONG addr = (ULONG)ecran;
    UWORD *cop = &coplist[18+32];   // début de bmap (0x00E0)

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
        printf("%04X ", coplist[i]);

        if ((i & 7) == 7)   // 8 mots par ligne
            printf("\n");
    }
}



void cpyBlocBlitter(UWORD numBloc, UWORD posx, UWORD posy)
{
    UWORD tileX = numBloc % 5;
    UWORD tileY = numBloc / 5;

    for (int plan = 0; plan < NB_PLAN; plan++)
    {
        UBYTE *src =
            tileset_raw
            + plan * (80 * 10)
            + tileY * 16 * 10
            + tileX * 2;

        UBYTE *dst =
            ecran
            + plan * (HAUTEUR_IMAGE * BYTES_PER_LINE)
            + posy * 16 * BYTES_PER_LINE
            + posx * 2;

        WaitBlit();

        custom.bltcon0 = 0x09F0;      // D = A
        custom.bltcon1 = 0x0000;

        custom.bltapt = (APTR)src;
        custom.bltdpt = (APTR)dst;

        custom.bltamod = 8;           // 10 - 2
        custom.bltdmod = 38;          // 40 - 2

        custom.bltafwm = 0xFFFF;
        custom.bltalwm = 0xFFFF;

        custom.bltsize = (16 << 6) | 1;
    }
}


void dessineLevel(void)
{
    for (UWORD y = 0; y < 9; y++)
    {
        for (UWORD x = 0; x < 20; x++)
        {
            UBYTE bloc = level[y][x];
            if (bloc != 255)
            {
                cpyBlocBlitter((UWORD)bloc, x, y);
            }
        }
    }
}

void clearSprite(){
  // point sprites 0-7 to nothing
    for (int i = 0; i < 8; i++) {
        coplist[COPLIST_IDX_SPR0_PTH_VALUE + i * 4] = (((ULONG) NULL_SPRITE_DATA) >> 16) & 0xffff;
        coplist[COPLIST_IDX_SPR0_PTH_VALUE + i * 4 + 2] = ((ULONG) NULL_SPRITE_DATA) & 0xffff;
    }
}

static void set_sprite_pos(UWORD *sprite_data, UWORD hstart, UWORD vstart, UWORD vstop)
{
    sprite_data[0] = ((vstart & 0xff) << 8) | ((hstart >> 1) & 0xff);
    // vstop + high bit of vstart + low bit of hstart
    sprite_data[1] = ((vstop & 0xff) << 8) |  // vstop 8 low bits
        ((vstart >> 8) & 1) << 2 |  // vstart high bit
        ((vstop >> 8) & 1) << 1 |   // vstop high bit
        (hstart & 1) |              // hstart low bit
        sprite_data[1] & 0x80;      // preserve attach bit
}


#define SPRITE_X_OFFSET 128
#define SPRITE_Y_OFFSET 44

void positionneSprite(UWORD *sprite, UWORD blocX, UWORD blocY, UWORD hauteur)
{
    UWORD pixelX = blocX * 16 + SPRITE_X_OFFSET;
    UWORD pixelY = blocY * 16 + SPRITE_Y_OFFSET;

    set_sprite_pos(sprite, pixelX, pixelY, pixelY + hauteur);
}


int main(int argc, char **argv)
{
    SetTaskPri(FindTask(NULL), TASK_PRIORITY);
    BOOL is_pal = init_display();
    //printf("PAL display: %d\n", is_pal);
    installPlans();
    //printf("%08lx\n", (ULONG)montagne_raw);
    //printf("%lu\n", (unsigned long)sizeof(montagne_raw));
    clearSprite();

    // Set SPRITE DATA START
    // now point sprite 0 to the nemo data
    coplist[SPR6_IDX]     = (((ULONG)nemo_data) >> 16) & 0xFFFF;
    coplist[SPR6_IDX + 2] = ((ULONG)nemo_data) & 0xFFFF;


     // set sprite color
    coplist[COPLIST_IDX_COLOR00_VALUE + (29 << 1)] = nemo_palette[1];
    coplist[COPLIST_IDX_COLOR00_VALUE + (30 << 1)] = nemo_palette[2];
    coplist[COPLIST_IDX_COLOR00_VALUE + (31 << 1)] = nemo_palette[3];


    positionneSprite(nemo_data,5,5,8);

    OwnBlitter();
    dessineLevel();
    DisownBlitter();
    custom.dmacon = 0x7FFF;
    custom.cop1lc = (ULONG)coplist;
    custom.copjmp1 = 0;
    //custom.dmacon = 0x83C0;
    custom.dmacon =0x83E0;
    waitmouse();  // replace with logic
    reset_display();
    return 0;
}
