#ifndef SPRITE_H
#define SPRITE_H

#include "../system/context.h"


void SpriteInit(GameContext *ctx);


void SpriteMove(
GameContext *ctx,
UWORD x,
UWORD y);


void SpriteShow(GameContext *ctx);


void SpriteHide(GameContext *ctx);


void SpriteSetImage(GameContext *ctx);


#endif
