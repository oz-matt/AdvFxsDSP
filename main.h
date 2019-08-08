/* =============================================================================
 *
 *  Description: This is a C++ to C Thread Header file for Thread main
 *
 * -----------------------------------------------------------------------------
 *  Comments:
 *
 * ===========================================================================*/

#ifndef _main_H_
#define _main_H_

#pragma diag(push)
#pragma diag(suppress: 177,401,451,826,831,1462)

#include "VDK.h"
#pragma diag(pop)

#ifdef __ECC__	/* for C/C++ access */
#ifdef __cplusplus
extern "C" void main_InitFunction(void**, VDK::Thread::ThreadCreationBlock *);
#else
extern "C" void main_InitFunction(void**, VDK_ThreadCreationBlock *);
#endif
extern "C" void main_DestroyFunction(void**);
extern "C" int  main_ErrorFunction(void**);
extern "C" void main_RunFunction(void**);
#endif /* __ECC__ */

#ifdef __cplusplus
#include <new>

class main_Wrapper : public VDK::Thread
{
public:
    main_Wrapper(VDK::ThreadCreationBlock &t)
        : VDK::Thread(t)
    { main_InitFunction(&m_DataPtr, &t); }

    ~main_Wrapper()
    { main_DestroyFunction(&m_DataPtr); }

    int ErrorHandler()
    { 
      return main_ErrorFunction(&m_DataPtr);
     }

    void Run()
    { main_RunFunction(&m_DataPtr); }

    static VDK::Thread* Create(VDK::Thread::ThreadCreationBlock &t)
    { return new (t) main_Wrapper(t); }
};

#endif /* __cplusplus */
#endif /* _main_H_ */

/* ========================================================================== */
