//
// MATLAB Compiler: 5.1 (R2014a)
// Date: Mon Aug 15 23:11:30 2016
// Arguments: "-B" "macro_default" "-W" "cpplib:LinkACO" "-T" "link:lib" "-d"
// "D:\study\程序\非线性规划软件\Unlimited_MIDACOtest\LinkACO\for_testing" "-v"
// "D:\study\程序\非线性规划软件\Unlimited_MIDACOtest\LinkMIDACO.m"
// "class{Class1:D:\study\程序\非线性规划软件\Unlimited_MIDACOtest\LinkMIDACO.m}
// " "-a" "D:\study\程序\非线性规划软件\Unlimited_MIDACOtest\midacox.mexw64" 
//

#include <stdio.h>
#define EXPORTING_LinkACO 1
#include "LinkACO.h"

static HMCRINSTANCE _mcr_inst = NULL;


#if defined( _MSC_VER) || defined(__BORLANDC__) || defined(__WATCOMC__) || defined(__LCC__)
#ifdef __LCC__
#undef EXTERN_C
#endif
#include <windows.h>

static char path_to_dll[_MAX_PATH];

BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, void *pv)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        if (GetModuleFileName(hInstance, path_to_dll, _MAX_PATH) == 0)
            return FALSE;
    }
    else if (dwReason == DLL_PROCESS_DETACH)
    {
    }
    return TRUE;
}
#endif
#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_LinkACO_C_API
#define LIB_LinkACO_C_API /* No special import/export declaration */
#endif

LIB_LinkACO_C_API 
bool MW_CALL_CONV LinkACOInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
    int bResult = 0;
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!GetModuleFileName(GetModuleHandle("LinkACO"), path_to_dll, _MAX_PATH))
    return false;
    {
        mclCtfStream ctfStream = 
            mclGetEmbeddedCtfStream(path_to_dll);
        if (ctfStream) {
            bResult = mclInitializeComponentInstanceEmbedded(   &_mcr_inst,
                                                                error_handler, 
                                                                print_handler,
                                                                ctfStream);
            mclDestroyStream(ctfStream);
        } else {
            bResult = 0;
        }
    }  
    if (!bResult)
    return false;
  return true;
}

LIB_LinkACO_C_API 
bool MW_CALL_CONV LinkACOInitialize(void)
{
  return LinkACOInitializeWithHandlers(mclDefaultErrorHandler, mclDefaultPrintHandler);
}

LIB_LinkACO_C_API 
void MW_CALL_CONV LinkACOTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

LIB_LinkACO_C_API 
void MW_CALL_CONV LinkACOPrintStackTrace(void) 
{
  char** stackTrace;
  int stackDepth = mclGetStackTrace(&stackTrace);
  int i;
  for(i=0; i<stackDepth; i++)
  {
    mclWrite(2 /* stderr */, stackTrace[i], sizeof(char)*strlen(stackTrace[i]));
    mclWrite(2 /* stderr */, "\n", sizeof(char)*strlen("\n"));
  }
  mclFreeStackTrace(&stackTrace, stackDepth);
}


LIB_LinkACO_C_API 
bool MW_CALL_CONV mlxLinkMIDACO(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "LinkMIDACO", nlhs, plhs, nrhs, prhs);
}

LIB_LinkACO_CPP_API 
void MW_CALL_CONV LinkMIDACO(int nargout, mwArray& xxx, mwArray& ifail, mwArray& pf, 
                             mwArray& px, mwArray& pc, const mwArray& n, const mwArray& 
                             nint, const mwArray& m, const mwArray& me, const mwArray& 
                             xxx_in1, const mwArray& fff, const mwArray& ggg, const 
                             mwArray& xl, const mwArray& xu, const mwArray& acc, const 
                             mwArray& ifail_in1, const mwArray& istop, const mwArray& 
                             param, const mwArray& printeval)
{
  mclcppMlfFeval(_mcr_inst, "LinkMIDACO", nargout, 5, 14, &xxx, &ifail, &pf, &px, &pc, &n, &nint, &m, &me, &xxx_in1, &fff, &ggg, &xl, &xu, &acc, &ifail_in1, &istop, &param, &printeval);
}

