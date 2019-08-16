
#ifndef _RTC_H_
#define _RTC_H_


void start_real_time_clock(void);

#define WAIT_FOR_RTC_WRITE_COMPLETE()  { while (*pRTC_ISTAT & 0x8000); }


#endif

