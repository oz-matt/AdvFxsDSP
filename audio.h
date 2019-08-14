#ifndef  __Talkthrough_DEFINED
	#define __Talkthrough_DEFINED

//--------------------------------------------------------------------------//
// Header files																//
//--------------------------------------------------------------------------//
#include <sys\exception.h>
#include <cdefBF537.h>

//--------------------------------------------------------------------------//
// Symbolic constants														//
//--------------------------------------------------------------------------//
// names for registers in AD1854/AD187 converters
#define INTERNAL_ADC_L0			0
#define INTERNAL_ADC_R0			1
#define INTERNAL_DAC_L0			0
#define INTERNAL_DAC_R0			1


#define delay 0xf00

// SPORT0 word length
#define SLEN_24	0x0017

// DMA flow mode
#define FLOW_1					0x1000


//--------------------------------------------------------------------------//
// Global variables															//
//--------------------------------------------------------------------------//
extern int iChannel0LeftIn;
extern int iChannel0RightIn;
extern int iChannel0LeftOut;
extern int iChannel0RightOut;

extern int iRxBuffer1[];
extern int iTxBuffer1[];

//--------------------------------------------------------------------------//
// Prototypes																//
//--------------------------------------------------------------------------//

void Init_Flags(void);
void Audio_Reset(void);
void Init_Sport0(void);
void Init_DMA(void);
void Init_Interrupts(void);
void Enable_DMA_Sport0(void);

EX_INTERRUPT_HANDLER(Sport0_RX_ISR);

#endif //__Talkthrough_DEFINED
