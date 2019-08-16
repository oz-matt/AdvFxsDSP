#include "rtc.h"
#include <cdefBF537.h>

void start_real_time_clock()
{
	if ( !*pRTC_PREN )
	{
		*pRTC_PREN = 1;
		WAIT_FOR_RTC_WRITE_COMPLETE();
	}
	
	*pRTC_STAT = 0;
	WAIT_FOR_RTC_WRITE_COMPLETE();
}
