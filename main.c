/* =============================================================================
 *
 *  Description: This is a C implementation for Thread main
 *
 * -----------------------------------------------------------------------------
 *  Comments:
 *
 * ===========================================================================*/

/* Get access to any of the VDK features & datatypes used */
#include "main.h"
#include "lib\uart.h"
#include <cdefBF537.h>
#include <sys\exception.h>

int flag = 0;

EX_INTERRUPT_HANDLER(Timer0_ISR)
{
	// confirm interrupt handling
	*pTIMER_STATUS = 0x0001;

	*pPORTFIO_TOGGLE	= 0x0040;
	uart_send_str("Hello World!\r\n", 15);
	//uart_send_char('y');
	//*pUART0_THR			= 0x79;
	//flag = 1;
}

void
main_RunFunction(void **inPtr)
{
    /* Put the thread's "main" Initialization HERE */
	*pPORTF_FER 		= 0x0003;  // Enable peripheral functions for PF2 and 3
	*pPORTFIO_DIR		= 0x0041;  // Set Port F Pin 6 (LED1) and Pin 3 (UART0TX) as an output
	*pPORT_MUX			= 0x0000;
	
	*pTIMER0_CONFIG		= 0x0019;
	*pTIMER0_PERIOD		= 0x01600000;
	*pTIMER0_WIDTH		= 0x00800000;
	*pTIMER_ENABLE		= 0x0001;
	
	*pSIC_IAR0 			= 0xffffffff;
	*pSIC_IAR1 			= 0xffffffff;
	*pSIC_IAR2 			= 0xffff4fff; // Timer0 interrupt enabled with priority of VG11 
	*pSIC_IAR3 			= 0xffffffff;
	
	// UART setup
	
	*pUART0_GCTL		= 0x01; // Enable UART1 clk
	*pUART0_LCR			= 0x83; // Enable access to the baud divisor, 8-bit word mode
	*pUART0_DLL			= 0x1B; // Set baud to 115200 (SCLK = 50MHz)
	*pUART0_DLH 		= 0x00;
	*pUART0_LCR			= 0x03; // Disable access to the baud divisor, 8-bit word mode
	
	// assign ISRs to interrupt vectors
	register_handler(ik_ivg11, Timer0_ISR);		// Timer0 ISR -> IVG 11

	// enable Timer0 interrupt
	*pSIC_IMASK = 0x00080000;
	
    while (1)
    {
        
        volatile int i = *pPORTFIO_DIR;
        volatile int j = *pPORTF_FER;
        
        i = j;
        /*if (flag)
        {
            flag = 0;
            uart_send_str("Hi", 2);
        }*/
        
        /* Put the thread's "main" body HERE */

        /* Use a "break" instruction to exit the "while (1)" loop */
    }

    /* Put the thread's exit from "main" HERE */
    /* A thread is automatically Destroyed when it exits its run function */
}

int
main_ErrorFunction(void **inPtr)
{

    /* TODO - Put this thread's error handling code HERE */

      /* The default ErrorHandler goes to KernelPanic */

	VDK_CThread_Error(VDK_GetThreadID());
	return 0;
}

void
main_InitFunction(void **inPtr, VDK_ThreadCreationBlock *pTCB)
{
    /* Put code to be executed when this thread has just been created HERE */

    /* This routine does NOT run in new thread's context.  Any non-static thread
     *   initialization should be performed at the beginning of "Run()."
     */
}

void
main_DestroyFunction(void **inPtr)
{
    /* Put code to be executed when this thread is destroyed HERE */

    /* This routine does NOT run in the thread's context.  Any VDK API calls
     *   should be performed at the end of "Run()."
     */
}

/* ========================================================================== */
