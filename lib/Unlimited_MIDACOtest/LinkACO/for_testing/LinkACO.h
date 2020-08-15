//
// MATLAB Compiler: 5.1 (R2014a)
// Date: Mon Aug 15 23:11:30 2016
// Arguments: "-B" "macro_default" "-W" "cpplib:LinkACO" "-T" "link:lib" "-d"
// "D:\study\程序\非线性规划软件\Unlimited_MIDACOtest\LinkACO\for_testing" "-v"
// "D:\study\程序\非线性规划软件\Unlimited_MIDACOtest\LinkMIDACO.m"
// "class{Class1:D:\study\程序\非线性规划软件\Unlimited_MIDACOtest\LinkMIDACO.m}
// " "-a" "D:\study\程序\非线性规划软件\Unlimited_MIDACOtest\midacox.mexw64" 
//

#ifndef __LinkACO_h
#define __LinkACO_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__SUNPRO_CC)
/* Solaris shared libraries use __global, rather than mapfiles
 * to define the API exported from a shared library. __global is
 * only necessary when building the library -- files including
 * this header file to use the library do not need the __global
 * declaration; hence the EXPORTING_<library> logic.
 */

#ifdef EXPORTING_LinkACO
#define PUBLIC_LinkACO_C_API __global
#else
#define PUBLIC_LinkACO_C_API /* No import statement needed. */
#endif

#define LIB_LinkACO_C_API PUBLIC_LinkACO_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_LinkACO
#define PUBLIC_LinkACO_C_API __declspec(dllexport)
#else
#define PUBLIC_LinkACO_C_API __declspec(dllimport)
#endif

#define LIB_LinkACO_C_API PUBLIC_LinkACO_C_API


#else

#define LIB_LinkACO_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_LinkACO_C_API 
#define LIB_LinkACO_C_API /* No special import/export declaration */
#endif

extern LIB_LinkACO_C_API 
bool MW_CALL_CONV LinkACOInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_LinkACO_C_API 
bool MW_CALL_CONV LinkACOInitialize(void);

extern LIB_LinkACO_C_API 
void MW_CALL_CONV LinkACOTerminate(void);



extern LIB_LinkACO_C_API 
void MW_CALL_CONV LinkACOPrintStackTrace(void);

extern LIB_LinkACO_C_API 
bool MW_CALL_CONV mlxLinkMIDACO(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);


#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__BORLANDC__)

#ifdef EXPORTING_LinkACO
#define PUBLIC_LinkACO_CPP_API __declspec(dllexport)
#else
#define PUBLIC_LinkACO_CPP_API __declspec(dllimport)
#endif

#define LIB_LinkACO_CPP_API PUBLIC_LinkACO_CPP_API

#else

#if !defined(LIB_LinkACO_CPP_API)
#if defined(LIB_LinkACO_C_API)
#define LIB_LinkACO_CPP_API LIB_LinkACO_C_API
#else
#define LIB_LinkACO_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_LinkACO_CPP_API void MW_CALL_CONV LinkMIDACO(int nargout, mwArray& xxx, mwArray& ifail, mwArray& pf, mwArray& px, mwArray& pc, const mwArray& n, const mwArray& nint, const mwArray& m, const mwArray& me, const mwArray& xxx_in1, const mwArray& fff, const mwArray& ggg, const mwArray& xl, const mwArray& xu, const mwArray& acc, const mwArray& ifail_in1, const mwArray& istop, const mwArray& param, const mwArray& printeval);

#endif
#endif
