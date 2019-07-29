#include <cdefBF537.h>

void main(void)
{
	
	*pPORTF_FER 		= 0x0000;  // Enable GPIO mode for all Port F pins
	*pPORTFIO_DIR		= 0x0040;  // Set Port F Pin 6 (LED1) as an output
	
	
	while(1)
	{
	    volatile int i;
	    for (i=0;i<25000000;i++);
	    
		
		*pPORTFIO_TOGGLE	= 0x0040;
	}
}

