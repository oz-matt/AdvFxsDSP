#include "audio.h"
#include "firc.h"

/*****************************************************************************
 Function:	Init_Flags													
																		
 Description:	Configure PORTF flags to control ADC and DAC RESETs
 													
******************************************************************************/
void Init_Flags(void)
{
	int temp;
	// configure programmable flags
	// set PORTF function enable register (need workaround)
	temp = *pPORTF_FER;
	temp++;
    *pPORTF_FER = 0x0000;
    *pPORTF_FER = 0x0003;

    // set PORTF direction register
    *pPORTFIO_DIR |= 0x1FC0;
        
   	// set PORTF input enable register
    *pPORTFIO_INEN |= 0x003C;
         
	// set PORTF clear register
    *pPORTFIO_CLEAR = 0x0FC0;
}


/*****************************************************************************
 Function:	Audio_Reset
					
 Description:	This function Resets the ADC and DAC. 
		
******************************************************************************/   
void Audio_Reset(void)
{
	int i;
	// give some time for reset to take affect
    for(i = 0; i< delay;i++){};
 	
    // set port f set register
    *pPORTFIO_SET = PF12;

}

//--------------------------------------------------------------------------//
// Function:	Init_Sport0													//
//																			//
// Description:	Configure Sport0 for I2S mode, to transmit/receive data 	//
//				to/from the ADC/DAC.Configure Sport for external clocks and //
//				frame syncs.												//
//--------------------------------------------------------------------------//
void Init_Sport0(void)
{
	// Sport0 receive configuration
	// External CLK, External Frame sync, MSB first, Active Low
	// 24-bit data, Secondary side enable, Stereo frame sync enable
// Users of ADSP-BF537 EZ-KIT Board Rev 1.0 must enable the internal clock and frame sync	
//	*pSPORT0_RCR1 = RFSR | LRFS | RCKFE | IRFS | IRCLK;
	*pSPORT0_RCR1 = RFSR | RCKFE;
	*pSPORT0_RCR2 = SLEN_24 | RSFSE;
//	*pSPORT0_RCLKDIV = 0x0013;
//	*pSPORT0_RFSDIV = 0x001F;
	
	// Sport0 transmit configuration
	// External CLK, External Frame sync, MSB first, Active Low
	// 24-bit data, Secondary side enable, Stereo frame sync enable
// Users of ADSP-BF537 EZ-KIT Board Rev 1.0 must enable the internal clock and frame sync
//	*pSPORT0_TCR1 = TFSR | LTFS | TCKFE | ITFS | ITCLK;
	*pSPORT0_TCR1 = TFSR | TCKFE;
	*pSPORT0_TCR2 = SLEN_24 | TSFSE;

//	*pSPORT0_TCLKDIV = 0x0013;
//	*pSPORT0_TFSDIV = 0x001F;
	
}

//--------------------------------------------------------------------------//
// Function:	Init_DMA													//
//																			//
// Description:	Initialize DMA3 in autobuffer mode to receive and DMA4 in	//
//				autobuffer mode to transmit									//
//--------------------------------------------------------------------------//
void Init_DMA(void)
{
	// Configure DMA3
	// 32-bit transfers, Interrupt on completion, Autobuffer mode
	*pDMA3_CONFIG = WNR | WDSIZE_32| DI_EN | FLOW_1 ;
	//*pDMA3_CONFIG = 0x10DA;
	// Start address of data buffer
	*pDMA3_START_ADDR = iRxBuffer1;
	// DMA loop count
	*pDMA3_X_COUNT = 2;
	// DMA loop address increment
	*pDMA3_X_MODIFY = 4;
	//*pDMA3_Y_MODIFY = 4;
	//*pDMA3_Y_COUNT = 16;
	

	// Configure DMA4
	// 32-bit transfers, Autobuffer mode
	*pDMA4_CONFIG = WDSIZE_32 | FLOW_1;
	// Start address of data buffer
	*pDMA4_START_ADDR = iTxBuffer1;
	// DMA loop count
	*pDMA4_X_COUNT = 2;
	// DMA loop address increment
	*pDMA4_X_MODIFY = 4;

}

//--------------------------------------------------------------------------//
// Function:	Enable_DMA_Sport											//
//																			//
// Description:	Enable DMA3, DMA4, Sport0 TX and Sport0 RX					//
//--------------------------------------------------------------------------//
void Enable_DMA_Sport0(void)
{
	// enable DMAs
	*pDMA4_CONFIG	= (*pDMA4_CONFIG | DMAEN);
	*pDMA3_CONFIG	= (*pDMA3_CONFIG | DMAEN);
	
	// enable Sport0 TX and RX
	*pSPORT0_TCR1 	= (*pSPORT0_TCR1 | TSPEN);
	*pSPORT0_RCR1 	= (*pSPORT0_RCR1 | RSPEN);
}

//--------------------------------------------------------------------------//
// Function:	Init_Interrupts												//
//																			//
// Description:	Initialize Interrupt for Sport0 RX							//
//--------------------------------------------------------------------------//
void Init_Interrupts(void)
{
	// Set Sport0 RX (DMA3) interrupt priority to 2 = IVG9 
	*pSIC_IAR0 = 0xff2fffff;
	//*pSIC_IAR1 = 0xffffffff;
	//*pSIC_IAR2 = 0xffffffff;
	//*pSIC_IAR3 = 0xffffffff;

	// assign ISRs to interrupt vectors
	// Sport0 RX ISR -> IVG 9
	register_handler(ik_ivg9, Sport0_RX_ISR);

	// enable Sport0 RX interrupt
	*pSIC_IMASK |= 0x00000020;
}


	

