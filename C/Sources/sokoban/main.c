#include "system/context.h"

#include "engine/engine.h"

#include "game/menu.h"
#include "game/levels.h"
#include "game/input.h"
#include "game/player.h"
#include "game/animation.h"


int main(void)
{

    GameContext ctx;


    EngineInit(&ctx);


    MenuShow(&ctx);


    LevelLoad(&ctx,0);



    while(ctx.running)
    {

        InputUpdate(&ctx);


        PlayerUpdate(&ctx);


        AnimationUpdate(&ctx);


        RenderFrame(&ctx);

    }



    EngineShutdown(&ctx);


    return 0;
}
