#ifndef TIMER_H
#define TIMER_H


#include "../system/context.h"


void WaitFrame(void);

ULONG GetFrame(void);

void DelayFrames(UWORD frames);


#endif
