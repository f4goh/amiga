#ifndef CONTEXT_H
#define CONTEXT_H

#include <exec/types.h>


typedef struct
{
    UWORD *coplist;

    UBYTE *screen;


    UWORD screenWidth;
    UWORD screenHeight;


    UBYTE level[9][20];


    UBYTE playerX;
    UBYTE playerY;


    UBYTE currentLevel;


    BOOL running;


} GameContext;


#endif
