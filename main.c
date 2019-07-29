#include <cdefBF537.h>
#include <sys\exception.h>

EX_INTERRUPT_HANDLER(Timer0_ISR)
{
	// confirm interrupt handling
	*pTIMER_STATUS = 0x0001;

	*pPORTFIO_TOGGLE	= 0x0040;
	
}

void main(void)
{
	
	*pPORTF_FER 		= 0x0000;  // Enable GPIO mode for all Port F pins
	*pPORTFIO_DIR		= 0x0040;  // Set Port F Pin 6 (LED1) as an output
	
	*pTIMER0_CONFIG		= 0x0019;
	*pTIMER0_PERIOD		= 0x01600000;
	*pTIMER0_WIDTH		= 0x00800000;
	*pTIMER_ENABLE		= 0x0001;
	
	*pSIC_IAR0 			= 0xffffffff;
	*pSIC_IAR1 			= 0xffffffff;
	*pSIC_IAR2 			= 0xffff4fff; // Timer0 interrupt enabled with priority of VG11 
	*pSIC_IAR3 			= 0xffffffff;
	
	// assign ISRs to interrupt vectors
	register_handler(ik_ivg11, Timer0_ISR);		// Timer0 ISR -> IVG 11

	// enable Timer0 interrupt
	*pSIC_IMASK = 0x00080000;
	
	while(1);
}

