#ifndef PLAYER_H
#define PLAYER_H

#include "../system/context.h"


void PlayerUpdate(GameContext *ctx);


void PlayerMoveLeft(GameContext *ctx);

void PlayerMoveRight(GameContext *ctx);

void PlayerMoveUp(GameContext *ctx);

void PlayerMoveDown(GameContext *ctx);


#endif
