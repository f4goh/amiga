#ifndef LEVELS_H
#define LEVELS_H

#include "../system/context.h"


void LevelLoad(
GameContext *ctx,
UBYTE num);


void RestartLevel(GameContext *ctx);


void NextLevel(GameContext *ctx);


void DrawLevel(GameContext *ctx);


#endif
