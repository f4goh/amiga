#ifndef BLITTER_H
#define BLITTER_H

#include "../system/context.h"


void BlitTile(
GameContext *ctx,
UWORD tile,
UWORD x,
UWORD y);


void BlitImage(GameContext *ctx);


void BlitRect(GameContext *ctx);


void ClearScreen(GameContext *ctx);


#endif
