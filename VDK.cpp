/* =============================================================================
 *
 *  Description: This VDK Configuration file is automatically generated 
 *               by the VisualDSP++ IDDE and should not be modified.
 *
 * ===========================================================================*/

#pragma diag(push)
#pragma diag(suppress: 177,401,451,826,831,1462)

#include "VDK.h"
#include <VDK_Internals.h>
#pragma diag(pop)

#ifndef NULL
#define NULL 0
#endif


#include "main.h"




INT_ASM_ROUT(_tmk_TimerISR)

namespace VDK
{

	/*************************************************************************
	 *	Thread Types:
	 */

	VDK::IDTableElement g_ThreadIDElements[10+1];
	VDK::ThreadTable g_ThreadTable = {g_ThreadIDElements, 10+1};
	

    VDK::ThreadTemplate	g_ThreadTemplates[] = 
	{
		INIT_THREADTEMPLATE_("kmain",kPriority5, 255,  ::main_Wrapper::Create  ,ksystem_heap ,ksystem_heap,false)
	};

 	// Number of thread templates
	unsigned int kNumThreadTemplates = sizeof(g_ThreadTemplates)/sizeof(ThreadTemplate);

#ifdef VDK_INCLUDE_IO_
	/***************************************************************************
	 * IO Templates: 
	 */

HeapID g_IOObjectHeap = ksystem_heap;

	VDK::IDTableElement g_DevIDElements[0];

	VDK::IODeviceTable g_IOdevTable = {g_DevIDElements, 0};

	extern const unsigned int kMaxNumIOObjects=0;
	VDK::IODeviceTemplate g_IOTemplates[] = 
	{
		0 // no I/O objects have been defined
	};
	unsigned int kNumIOTemplates = sizeof(g_IOTemplates)/sizeof(IODeviceTemplate);

#ifdef VDK_BOOT_OBJECTS_IO_

	BootIOObjectInfo g_BootIOObjects[] = 
	{

	};
	unsigned int kNumBootIOObjects = sizeof(g_BootIOObjects)/sizeof(BootIOObjectInfo);

#endif // VDK_BOOT_OBJECTS_IO_
#endif // VDK_INCLUDE_IO_


	/*************************************************************************
	 *	Idle Thread:
	 */
	VDK::ThreadTemplate g_IdleThreadTplate =  INIT_THREADTEMPLATE_("Idle Thread",static_cast<VDK::Priority>(0), 256 , NULL  ,ksystem_heap ,ksystem_heap,false);

	/*************************************************************************

	 *	Boot Threads:
	 */


	// The maximum number of running threads in a system
    unsigned int kMaxNumThreads = 10;

	// The list of threads to create at boot time
 	BootThreadInfo g_BootThreadInfo[] = 	
	{ 
		{ &g_ThreadTemplates[kmain], 0 }
	}; 

	unsigned int kNumBootThreads = sizeof( g_BootThreadInfo ) / sizeof( BootThreadInfo );

	/**************************************************************************
	 * Round Robin (time-slice) mode: 
	 * 
	 * Defines which priority levels will execute in round robin (time sliced) mode.
	 */
	
	unsigned int g_RoundRobinInitPriority = (

		0 );

	// If the priority is in round robin mode, set the period in Ticks.
	// For all priorities not in RR mode, the period MUST be set to 1.
	
	VDK::Ticks  g_RoundRobinInitPeriod[] = 		
	{
		1,			// The Idle thread priority
		1,		// kPriority30
		1,		// kPriority29
		1,		// kPriority28
		1,		// kPriority27
		1,		// kPriority26
		1,		// kPriority25
		1,		// kPriority24
		1,		// kPriority23
		1,		// kPriority22
		1,		// kPriority21
		1,		// kPriority20
		1,		// kPriority19
		1,		// kPriority18
		1,		// kPriority17
		1,		// kPriority16
		1,		// kPriority15
		1,		// kPriority14
		1,		// kPriority13
		1,		// kPriority12
		1,		// kPriority11
		1,		// kPriority10
		1,		// kPriority9
		1,		// kPriority8
		1,		// kPriority7
		1,		// kPriority6
		1,		// kPriority5
		1,		// kPriority4
		1,		// kPriority3
		1,		// kPriority2
		1,		// kPriority1
	};

#ifdef VDK_INCLUDE_MEMORYPOOLS_ 
	/*************************************************************************
	 *	Memory Pools:
	 */					
	extern const unsigned int kMaxNumActiveMemoryPools=0;

	VDK::IDTableElement g_MemIDElements[0];

	VDK::MemoryPoolTable g_MemoryPoolTable = {g_MemIDElements, 0};

	VDK::PoolID g_MessagePoolID;

#ifdef VDK_BOOT_MEMORYPOOLS_

	struct BootPoolInfo g_BootMemoryPools[] =
	{ 
 
	};

	unsigned int kNumBootPools = sizeof (g_BootMemoryPools)/sizeof(BootPoolInfo); 

#else

	unsigned int kNumBootPools = 0;    // Number of boot pools

#endif //VDK_BOOT_MEMORYPOOLS_
#endif // VDK_INCLUDE_MEMORYPOOLS_


	float g_TickPeriod = 0.1;

	unsigned int g_ClockFrequency = 270.000;

	unsigned int g_ClockPeriod = 27000;

	unsigned int g_StackAlignment   = VDK_STACK_ALIGNMENT_ ;
#if VDK_INSTRUMENTATION_LEVEL_==2
    // Setup the history buffer
    VDK::HistoryBuffer::HistoryEvent    g_HistoryEnums[256];
    VDK::HistoryBuffer                  g_History(256, g_HistoryEnums);
#endif

	/*************************************************************************
	 * Semaphores:
	 */
	
	extern const unsigned int kMaxNumActiveSemaphores=0;
	VDK::IDTableElement g_SemIDElements[0 + 1];
	SemaphoreTable g_SemaphoreTable = {g_SemIDElements, 0};

#ifdef VDK_INCLUDE_SEMAPHORES_
	HeapID g_SemaphoreHeap = ksystem_heap; 


#ifdef VDK_BOOT_SEMAPHORES_
    SemaphoreInfo  g_BootSemaphores[] = 
	{

	};
    unsigned int kNumBootSemaphores = sizeof (g_BootSemaphores)/sizeof(SemaphoreInfo);    // Number of boot semaphores

#endif // VDK_BOOT_SEMAPHORES_
#endif // VDK_INCLUDE_SEMAPHORES_

#ifdef VDK_MULTIPLE_HEAPS_
    HeapInfo g_Heaps[] =
	{
		{ 0, 0 }
	};

    unsigned int kNumHeaps = sizeof (g_Heaps)/sizeof(HeapInfo);    // Number of heaps
#endif

#ifdef VDK_INCLUDE_EVENTS_

	/*************************************************************************
	 * EventBits: 
	 */
	
	// Initialize the global system EventBit state.  This is a bitfield, so the
	// bit value needs to be shifted into position and OR'd to the total. 
	
	unsigned int  	g_EventBitState = (

		0 );
	
	// Allocate memory for EventBits using the same value as kNumEventBits.  
	
	unsigned int kNumEventBits = 0;	//  total number of entries in enum 
	VDK::EventBit g_EventBits[0];

	/*************************************************************************
	 * Events: 
	 */
	
	VDK::Event g_Events[] =		
	{

	};

	unsigned int kNumEvents = sizeof (g_Events)/sizeof(Event);

#endif // ifdef VDK_INCLUDE_EVENTS_

	/*************************************************************************
	 * Device Flags: 
	 */

#ifdef VDK_INCLUDE_DEVICE_FLAGS_
HeapID g_DeviceFlagHeap = ksystem_heap;

	extern const unsigned int kMaxNumActiveDevFlags=0;
	VDK::IDTableElement g_DevFlagsIDElements[0];
	VDK::DeviceFlagTable     g_DeviceFlagTable = {g_DevFlagsIDElements, 0};

#ifdef VDK_BOOT_DEVICE_FLAGS_
    unsigned int kNumBootDeviceFlags = 0;

#endif // VDK_BOOT_DEVICE_FLAGS_

#endif // VDK_INCLUDE_DEVICE_FLAGS_


	/*************************************************************************
	 * Messages: 
	 */

#ifdef VDK_INCLUDE_MESSAGES_
	extern const unsigned int kMaxNumActiveMessages=0;

	void MessageQueueCleanup(MessageQueue*);

	void (*g_MessageQueueCleanup)(VDK::MessageQueue *) = MessageQueueCleanup;
#else
	void (*g_MessageQueueCleanup)(VDK::MessageQueue *) = NULL;

#endif

	unsigned int g_localNode =0;

	unsigned short g_ChannelRoutingMask =0;


	ThreadID g_vRoutingThreads[]=
	{
		(ThreadID) 0
	};

	ThreadID g_vRoutingThreads2[]=
	{
		(ThreadID) 0
	};

    unsigned int kNumRoutingNodes = 0;    // Number of routing nodes

	MsgThreadEntry g_RoutingThreadInfo[] =
	{
		INIT_RTHREAD_(NULL, (VDK::Priority) 0, 0,  NULL   ,ksystem_heap ,ksystem_heap, false, (VDK::ThreadID) 0, (VDK::IOID) 0,"0", (VDK::RoutingDirection) 0)
	};

    unsigned int kNumRoutingThreads = 0; // Number of routing threads



	VDK::MarshallingEntry g_vMarshallingTable[] =
	{
		{0,0}
	};

    unsigned int kNumMarshalledTypes = 0 ;    // Number of marshalling message types



	/*************************************************************************
	 * Interrupt Service Routines
	 */

	IMASKStruct g_InitialISRMask = 
	{
		EVT_IVTMR | 

		EVT_IVG14 
	};

#ifdef __ADSP21000__
// this variable is only used in SHARC processors that have some interrupts in
// LIRPTL
	IMASKStruct g_InitialISRMask2 =
	{

	0
	};
#endif

	void UserDefinedInterruptServiceRoutines( void )
	{
		INTVECTOR(seg_EVT_IVTMR, _tmk_TimerISR)

	}

	BootFuncPointers g_InitBootFunctionP[] = 
	{ 
			VDK::InitBootThreads,
			VDK::SetTimer
 
	}; 


	unsigned int kNumBootEntries = sizeof (g_InitBootFunctionP)/sizeof(BootFuncPointers) ; 



}  // namespace VDK

/* ========================================================================== */
