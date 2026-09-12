#ifndef COPPER_H
#define COPPER_H


#include "../system/context.h"


void CopperInit(GameContext *ctx);


void CopperInstall(GameContext *ctx);


void CopperSetColor(
GameContext *ctx,
UBYTE index,
UWORD color);



void CopperEnableSprites(GameContext *ctx);


void CopperDisableSprites(GameContext *ctx);


#endif
