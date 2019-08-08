/* =============================================================================
 *
 *  Description: This is a C++ implementation for Thread main
 *
 * -----------------------------------------------------------------------------
 *  Comments:
 *
 * ===========================================================================*/

#include "main.h"
#include <new>

/******************************************************************************
 *  main Run Function (main's main{})
 */
 
void
main::Run()
{
    // TODO - Put the thread's "main" Initialization HERE

    while (1)
    {
        // TODO - Put the thread's "main" body HERE

        // Use a "break" instruction to exit the "while (1)" loop
    }

    // TODO - Put the thread's exit from "main" HERE
	// A thread is automatically Destroyed when it exits its run function
}

/******************************************************************************
 *  main Error Handler
 */
 
int
main::ErrorHandler()
{
    /* TODO - Put this thread's error handling code HERE */

    /* The default ErrorHandler (called below)  raises
     * a kernel panic and stops the system */
    return (VDK::Thread::ErrorHandler());
}

/******************************************************************************
 *  main Constructor
 */
 
main::main(VDK::Thread::ThreadCreationBlock &tcb)
    : VDK::Thread(tcb)
{
    /* This routine does NOT run in new thread's context.  Any non-static thread
     *   initialization should be performed at the beginning of "Run()."
     */

    // TODO - Put code to be executed when this thread has just been created HERE

}

/******************************************************************************
 *  main Destructor
 */
 
main::~main()
{
    /* This routine does NOT run in the thread's context.  Any VDK API calls
     *   should be performed at the end of "Run()."
     */

    // TODO - Put code to be executed just before this thread is destroyed HERE

}

/******************************************************************************
 *  main Externally Accessible, Pre-Constructor Create Function
 */
 
VDK::Thread*
main::Create(VDK::Thread::ThreadCreationBlock &tcb)
{
    /* This routine does NOT run in new thread's context.  Any non-static thread
     *   initialization should be performed at the beginning of "Run()."
     */

    	return new (tcb) main(tcb);
}

/* ========================================================================== */
