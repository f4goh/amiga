#include "engine.h"

#include "display.h"
#include "copper.h"
#include "sprite.h"



void EngineInit(GameContext *ctx)
{

    init_display();


    CopperInit(ctx);


    SpriteInit(ctx);


    ctx->running = TRUE;

}



void EngineShutdown(GameContext *ctx)
{

    reset_display();

}



void RenderFrame(GameContext *ctx)
{

}
