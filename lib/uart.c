#include "uart.h"
#include <cdefBF537.h>

void uart_send_char(char data)
{
	*pUART0_THR			= data; // Transmit 
	while (!(*pUART0_LSR & 0x20));
}

void uart_send_str(const char* str, int len)
{
    int i;
    
    for(i=0;i<len;i++)
    {
        uart_send_char(str[i]);
    }
}
