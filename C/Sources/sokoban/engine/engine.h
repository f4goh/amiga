#ifndef ENGINE_H
#define ENGINE_H

#include "../system/context.h"


void EngineInit(GameContext *ctx);

void EngineShutdown(GameContext *ctx);

void RenderFrame(GameContext *ctx);


#endif
