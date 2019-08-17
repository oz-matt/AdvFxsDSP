#include "firc.h"
#include <fract.h>

fract32 frc[43];

INIT_FIR_FILTER_COEFFICIENTS;

void init_firc(void)
{
    int i;
    
    for(i=0;i<43;i++)
    {
        frc[i] = float_to_fr32(firc[i]);
    }
}

