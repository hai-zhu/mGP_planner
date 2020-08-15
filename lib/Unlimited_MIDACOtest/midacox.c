#include "mex.h"
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC */
/*
   This is the MIDACO-MEX file 'midacox.c' for using MIDACO 3.0 in Matlab.
   Put this file in the 'current directory' of Matlab and type:
   
   'mex midacox.c' 
   
   in the command window and press ENTER/RETURN. This will generate some 
   library file (e.g. midacox.dll, midacox.mexw32 or midacox.mexglx), that  
   is called by 'midaco.m'. If you experience any problems during the mex-
   process, please contact the author.

   Author: Martin Schlueter           
           Theoretical and Computational Optimization Group,
           School of Mathematics, University of Birmingham (UK)

   Email:  info@midaco-solver.com
   URL:    www.midaco-solver.com
*/
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC */
/* 
	Allocating LMAX and LXM
	-----------------------
	Here the user can manually allocate the array length parameters LMAX
	and LXM, in case MIDACO returned the error messages IFAIL=801 or
	IFAIL=802. To resolve the error messages, set LMAX >= L and LXM >= L*M+1,
	where L is the desired parallelization factor and M is the total number
	of constraints. 
	
	IMPORTANT: Also adjust the array lengths of a[], b[] and gm[] manually
	---------- according to LMAX and LXM.	
*/
	static long int LMAX = 100;
	static double        a[100];   /* Array a[] must be of length LMAX */
	static double        b[100];   /* Array b[] must be of length LMAX */

	static long int LXM = 1000;
	static double      gm[1000];   /* Array gm[] must be of length LXM */

/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC */
static double *RW = NULL;
static long int LRW = 0;
static long int *IW = NULL;
static long int LIW = 0;
static long int PRINTCOUNT = 0;
static long int EVAL = 0;
static long int KF = 0;
static long int KR = 0;
static long int KX = 0;
static long int WF = 0;
static long int WR = 0;
static long int WX = 0;
static long int LOC =0;
static char *LIC = NULL;
void workspace(long int L, long int N, long int M) 
{
  long int i;  
  LRW = 2*N*N+23*N+2*M+70; 
  LIW = 2*N+L+100; 
  RW = (  double*)mxMalloc(sizeof(  double)*LRW);
  IW = (long int*)mxMalloc(sizeof(long int)*LIW);
  mexMakeMemoryPersistent(RW); 
  mexMakeMemoryPersistent(IW);
  for (i=0; i<LRW; i++) RW[i] = 0.0; 
  for (i=0; i<LIW; i++) IW[i] = 0;
}
void freeworkspace(){mxFree(RW);mxFree(IW);LRW=0;LIW=0;}
int XQRZ(double *f, double *g, double *h, double *i, double *j, double *k, long int *l,
		 long int *m, double *n, double *o, long int *p,long int *q, long int *r, char *s,
		 long int *t, long int *u, long int *v, long int *y,long int *z);
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 
  long int SIZE0,SIZE1,SIZE2,SIZE3,SIZE4,SIZE5,SIZE6,SIZE7,SIZE8,SIZE9,SIZE10,SIZE11,SIZE12,SIZE13,SIZE14, SIZE15;
  double    *IN0, *IN1, *IN2, *IN3, *IN4, *IN5, *IN6, *IN7, *IN8, *IN9, *IN10, *IN11, *IN12, *IN13, *IN14;
  double   *OUT0,*OUT1,*OUT2,*OUT3,*OUT4,*OUT5,*OUT6,*OUT7,*OUT8,*OUT9,*OUT10,*OUT11,*OUT12,*OUT13, *OUT14,*OUT15,*OUT16,*OUT17;
  long int L,N,NINT,M,ME,IFAIL,ISTOP,R;
  long int PRINTEVAL;
  long int i;
  char *IN15;
  SIZE0  = mxGetNumberOfElements(prhs[ 0]); 
  SIZE1  = mxGetNumberOfElements(prhs[ 1]); 
  SIZE2  = mxGetNumberOfElements(prhs[ 2]); 
  SIZE3  = mxGetNumberOfElements(prhs[ 3]); 
  SIZE4  = mxGetNumberOfElements(prhs[ 4]); 
  SIZE5  = mxGetNumberOfElements(prhs[ 5]); 
  SIZE6  = mxGetNumberOfElements(prhs[ 6]); 
  SIZE7  = mxGetNumberOfElements(prhs[ 7]); 
  SIZE8  = mxGetNumberOfElements(prhs[ 8]); 
  SIZE9  = mxGetNumberOfElements(prhs[ 9]); 
  SIZE10 = mxGetNumberOfElements(prhs[10]); 
  SIZE11 = mxGetNumberOfElements(prhs[11]); 
  SIZE12 = mxGetNumberOfElements(prhs[12]); 
  SIZE13 = mxGetNumberOfElements(prhs[13]); 
  SIZE14 = mxGetNumberOfElements(prhs[14]); 
  SIZE15 = mxGetNumberOfElements(prhs[15]);
  IN0  = (double*)mxGetPr(prhs[ 0]);
  IN1  = (double*)mxGetPr(prhs[ 1]);
  IN2  = (double*)mxGetPr(prhs[ 2]);
  IN3  = (double*)mxGetPr(prhs[ 3]);
  IN4  = (double*)mxGetPr(prhs[ 4]);
  IN5  = (double*)mxGetPr(prhs[ 5]);
  IN6  = (double*)mxGetPr(prhs[ 6]);
  IN7  = (double*)mxGetPr(prhs[ 7]);
  IN8  = (double*)mxGetPr(prhs[ 8]);
  IN9  = (double*)mxGetPr(prhs[ 9]);
  IN10 = (double*)mxGetPr(prhs[10]);
  IN11 = (double*)mxGetPr(prhs[11]);
  IN12 = (double*)mxGetPr(prhs[12]);
  IN13 = (double*)mxGetPr(prhs[13]);
  IN14 = (double*)mxGetPr(prhs[14]);
  plhs[ 0] = mxCreateDoubleMatrix(1, SIZE0  ,0);
  plhs[ 1] = mxCreateDoubleMatrix(1, SIZE1  ,0);
  plhs[ 2] = mxCreateDoubleMatrix(1, SIZE2  ,0);
  plhs[ 3] = mxCreateDoubleMatrix(1, SIZE3  ,0);
  plhs[ 4] = mxCreateDoubleMatrix(1, SIZE4  ,0);
  plhs[ 5] = mxCreateDoubleMatrix(1, SIZE5  ,0);
  plhs[ 6] = mxCreateDoubleMatrix(1, SIZE6  ,0);
  plhs[ 7] = mxCreateDoubleMatrix(1, SIZE7  ,0);
  plhs[ 8] = mxCreateDoubleMatrix(1, SIZE8  ,0);
  plhs[ 9] = mxCreateDoubleMatrix(1, SIZE9  ,0);
  plhs[10] = mxCreateDoubleMatrix(1, SIZE10 ,0);
  plhs[11] = mxCreateDoubleMatrix(1, SIZE11 ,0);
  plhs[12] = mxCreateDoubleMatrix(1, SIZE12 ,0);
  plhs[13] = mxCreateDoubleMatrix(1, SIZE13 ,0);
  plhs[14] = mxCreateDoubleMatrix(1,      1 ,0); 
  plhs[15] = mxCreateDoubleMatrix(1,      1 ,0);
  plhs[16] = mxCreateDoubleMatrix(1,  SIZE5 ,0); 
  plhs[17] = mxCreateDoubleMatrix(1,      1 ,0); 
  OUT0  = mxGetPr(plhs[ 0]);
  OUT1  = mxGetPr(plhs[ 1]);
  OUT2  = mxGetPr(plhs[ 2]);
  OUT3  = mxGetPr(plhs[ 3]);
  OUT4  = mxGetPr(plhs[ 4]);
  OUT5  = mxGetPr(plhs[ 5]);
  OUT6  = mxGetPr(plhs[ 6]);
  OUT7  = mxGetPr(plhs[ 7]);
  OUT8  = mxGetPr(plhs[ 8]);
  OUT9  = mxGetPr(plhs[ 9]);
  OUT10 = mxGetPr(plhs[10]);
  OUT11 = mxGetPr(plhs[11]);
  OUT12 = mxGetPr(plhs[12]);
  OUT13 = mxGetPr(plhs[13]);
  OUT14 = mxGetPr(plhs[14]); 
  OUT15 = mxGetPr(plhs[15]); 
  OUT16 = mxGetPr(plhs[16]); 
  OUT17 = mxGetPr(plhs[17]); 
  for (i= 0;i< SIZE0  ;i++){ OUT0[i]  =  IN0[i];  }
  for (i= 0;i< SIZE1  ;i++){ OUT1[i]  =  IN1[i];  }
  for (i= 0;i< SIZE2  ;i++){ OUT2[i]  =  IN2[i];  }
  for (i= 0;i< SIZE3  ;i++){ OUT3[i]  =  IN3[i];  }
  for (i= 0;i< SIZE4  ;i++){ OUT4[i]  =  IN4[i];  }
  for (i= 0;i< SIZE5  ;i++){ OUT5[i]  =  IN5[i];  }
  for (i= 0;i< SIZE6  ;i++){ OUT6[i]  =  IN6[i];  }
  for (i= 0;i< SIZE7  ;i++){ OUT7[i]  =  IN7[i];  }
  for (i= 0;i< SIZE8  ;i++){ OUT8[i]  =  IN8[i];  }
  for (i= 0;i< SIZE9  ;i++){ OUT9[i]  =  IN9[i];  }
  for (i= 0;i< SIZE10 ;i++){ OUT10[i] =  IN10[i]; }
  for (i= 0;i< SIZE11 ;i++){ OUT11[i] =  IN11[i]; }
  for (i= 0;i< SIZE12 ;i++){ OUT12[i] =  IN12[i]; }
  for (i= 0;i< SIZE13 ;i++){ OUT13[i] =  IN13[i]; }
  L     = (long int)  OUT0[0];
  N     = (long int)  OUT1[0];
  NINT  = (long int)  OUT2[0];
  M     = (long int)  OUT3[0];
  ME    = (long int)  OUT4[0];
  IFAIL = (long int) OUT11[0];
  ISTOP = (long int) OUT12[0];
  if(LRW == 0)
  {
	  IN15 = mxArrayToString(prhs[15]);
      LOC = 60; LIC = (char*)mxMalloc(sizeof(char)*LOC);
      mexMakeMemoryPersistent(LIC); 
      for (i= 0;i< 60  ;i++){ LIC[i]  =  (char) IN15[i];  }
	  workspace(L,N,M);
  }
  XQRZ(&*OUT5,&*OUT6,&*OUT7,&*OUT8,&*OUT9,&*OUT10,&IFAIL,&ISTOP,
	   &*OUT13,&*RW,&LRW,&*IW,&LIW,&*LIC,&L,&N,&NINT,&M,&ME);
  OUT11[0] = (double) IFAIL;
  OUT12[0] = (double) ISTOP;
  EVAL = EVAL + 1;
  if(EVAL == 1)
  {
	  R  = 2*N+M+(N+5)*(2*N+10)+8;
	  KF = 1+N;
	  KR = 2+N+M;
	  KX = 1;
	  WF = R+N;
	  WR = R+1+N+M;
	  WX = R;
  }
  OUT17[0] = 0.0;   
  PRINTEVAL = (long int) IN14[0];
  PRINTCOUNT = PRINTCOUNT + L; 
  if((PRINTCOUNT >= PRINTEVAL)||(EVAL==1)||(IFAIL>=0))
  {
	  OUT17[0] = 1.0; 

	  if(EVAL > 1){ PRINTCOUNT = 0; }

      if((RW[KR] == RW[WR])&&(IFAIL != -300)&&(IFAIL < 1))
	  {	
		  if(RW[KF] <= RW[WF])
		  {
	  OUT14[0] = RW[KF];
      OUT15[0] = RW[KR];
	  for (i= 0;i< SIZE5 ;i++){OUT16[i] =  RW[KX+i];}
		  }
		  else
		  {
		  OUT14[0] = RW[WF];
		  OUT15[0] = RW[WR]; 
		  for (i= 0;i< SIZE5 ;i++) {OUT16[i] =  RW[WX+i];}
		  }
	  }
	  if((RW[KR] != RW[WR])&&(IFAIL != -300)&&(IFAIL < 1))
	  {
		  if(RW[KR] <= RW[WR])
		  {
	  OUT14[0] = RW[KF];
      OUT15[0] = RW[KR];
	  for (i= 0;i< SIZE5 ;i++){OUT16[i] =  RW[KX+i];}
		  }
		  else
		  {
		  OUT14[0] = RW[WF];
		  OUT15[0] = RW[WR]; 
		  for (i= 0;i< SIZE5 ;i++) {OUT16[i] =  RW[WX+i];}
		  }

	  }
	  if((IFAIL == -300)||(IFAIL >= 1))
	  {
		  OUT14[0] = RW[WF];
		  OUT15[0] = RW[WR]; 
		  for (i= 0;i< SIZE5 ;i++) {OUT16[i] =  RW[WX+i];}
	  }    
  }
  if(ISTOP == 1)
  {
	  freeworkspace();
  }
}
#ifndef F2C_INCLUDE
#define F2C_INCLUDE
typedef long int integer;
typedef char *address;
typedef short int shortint;
typedef float real;
typedef double doublereal;
typedef struct { real r, i; } complex;
typedef struct { doublereal r, i; } doublecomplex;
typedef long int logical;
typedef short int shortlogical;
typedef char logical1;
typedef char integer1;
#define TRUE_ (1)
#define FALSE_ (0)
#ifndef Extern
#define Extern extern
#endif
#ifdef f2c_i2
typedef short flag;
typedef short ftnlen;
typedef short ftnint;
#else
typedef long flag;
typedef long ftnlen;
typedef long ftnint;
#endif
typedef struct
{	flag cierr;
	ftnint ciunit;
	flag ciend;
	char *cifmt;
	ftnint cirec;
} cilist;
typedef struct
{	flag icierr;
	char *iciunit;
	flag iciend;
	char *icifmt;
	ftnint icirlen;
	ftnint icirnum;
} icilist;
typedef struct
{	flag oerr;
	ftnint ounit;
	char *ofnm;
	ftnlen ofnmlen;
	char *osta;
	char *oacc;
	char *ofm;
	ftnint orl;
	char *oblnk;
} olist;
typedef struct
{	flag cerr;
	ftnint cunit;
	char *csta;
} cllist;
typedef struct
{	flag aerr;
	ftnint aunit;
} alist;
typedef struct
{	flag inerr;
	ftnint inunit;
	char *infile;
	ftnlen infilen;
	ftnint	*inex;	
	ftnint	*inopen;
	ftnint	*innum;
	ftnint	*innamed;
	char	*inname;
	ftnlen	innamlen;
	char	*inacc;
	ftnlen	inacclen;
	char	*inseq;
	ftnlen	inseqlen;
	char 	*indir;
	ftnlen	indirlen;
	char	*infmt;
	ftnlen	infmtlen;
	char	*inform;
	ftnint	informlen;
	char	*inunf;
	ftnlen	inunflen;
	ftnint	*inrecl;
	ftnint	*innrec;
	char	*inblank;
	ftnlen	inblanklen;
} inlist;
#define VOID void
union Multitype {	
	shortint h;
	integer i;
	real r;
	doublereal d;
	complex c;
	doublecomplex z;
	};
typedef union Multitype Multitype;
typedef long Long;	
struct Vardesc {	
	char *name;
	char *addr;
	ftnlen *dims;
	int  type;
	};
typedef struct Vardesc Vardesc;
struct Namelist {
	char *name;
	Vardesc **vars;
	int nvars;
	};
typedef struct Namelist Namelist;
#define abs(x) ((x) >= 0 ? (x) : -(x))
#define dabs(x) (doublereal)abs(x)
#define min(a,b) ((a) <= (b) ? (a) : (b))
#define max(a,b) ((a) >= (b) ? (a) : (b))
#define dmin(a,b) (doublereal)min(a,b)
#define dmax(a,b) (doublereal)max(a,b)
#define F2C_proc_par_types 1
#ifdef __cplusplus
typedef int (*U_fp)(...);
typedef shortint (*J_fp)(...);
typedef integer (*I_fp)(...);
typedef real (*R_fp)(...);
typedef doublereal (*D_fp)(...), (*E_fp)(...);
typedef VOID (*C_fp)(...);
typedef VOID (*Z_fp)(...);
typedef logical (*L_fp)(...);
typedef shortlogical (*K_fp)(...);
typedef VOID (*H_fp)(...);
typedef int (*S_fp)(...);
#else
typedef int (*U_fp)();
typedef shortint (*J_fp)();
typedef integer (*I_fp)();
typedef real (*R_fp)();
typedef doublereal (*D_fp)(), (*E_fp)();
typedef VOID (*C_fp)();
typedef VOID (*Z_fp)();
typedef logical (*L_fp)();
typedef shortlogical (*K_fp)();
typedef VOID (*H_fp)();
typedef int (*S_fp)();
#endif
typedef VOID C_f;	
typedef VOID H_f;	
typedef VOID Z_f;	
typedef doublereal E_f;
#ifndef Skip_f2c_Undefs
#undef cray
#undef gcos
#undef mc68010
#undef mc68020
#undef mips
#undef pdp11
#undef sgi
#undef sparc
#undef sun
#undef sun2
#undef sun3
#undef sun4
#undef u370
#undef u3b
#undef u3b2
#undef u3b5
#undef unix
#undef vax
#endif
#endif
#ifdef _WIN32
#define huge huged
#define near neard
#endif
static integer c__2 = 2;
static doublereal c_b10 = 10.;
static integer c__100 = 100;
static doublereal c_b13 = 10.;
int XQRZ(doublereal *x, doublereal *f, doublereal *g, 
	doublereal *xl, doublereal *xu, doublereal *acc, integer *ifail, 
	integer *istop, doublereal *param, doublereal *rw, integer *lrw, 
	integer *iw, integer *liw, char *license_key__,integer *l, 
	integer *n, integer *nint, integer *m, integer *me)
{   integer i__1;static integer i__;extern int midaco_code__(integer *, integer *, integer *,
	integer *, integer *, doublereal *, doublereal *, doublereal *,doublereal *, 
	doublereal *, doublereal *, integer *, integer *, 
	doublereal *, doublereal *, integer *, integer *, integer *, char *, integer *, 
	doublereal *, doublereal *, ftnlen);--f;--xu;--xl;--x;--g;--param;--rw;--iw;
    if (*ifail == 0) {	if (*l > LMAX) {	    *ifail = 801;	    return 0;	}	
	if (*l * *m + 1 > LXM) {	    *ifail = 802;	    return 0;	}    }
    if (*m > 0) {	i__1 = *l * *m;	for (i__ = 1; i__ <= i__1; ++i__) {	    
		gm[i__ - 1] = g[i__];	}    }    gm[*l * *m] = 0.;    midaco_code__(l, n, 
			nint, m, me, &x[1], &f[1], gm, &xl[1], &xu[1], acc, 
	    ifail, istop, &param[1], &rw[1], lrw, &iw[1], liw, license_key__, 	    
		&LMAX, a, b, (ftnlen)60);    return 0;
} 

/* Subroutine */ int o8971310_(integer *n, integer *k, doublereal *j2, 
	integer *lj2, integer *i37, integer *i98, integer *i2462, integer *
	i13, doublereal *x, doublereal *f, doublereal *i11, doublereal *p, 
	doublereal *z__)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Local variables */
    static integer i__, j, i4271;

    /* Parameter adjustments */
    --x;
    --j2;

    /* Function Body */
    i4271 = 0;
    if (*z__ == 0.) {
	if (*p >= j2[*i13 + *k - 1]) {
	    return 0;
	}
    } else {
	if (*p > j2[*i13 + *k - 1]) {
	    return 0;
	}
    }
    i__1 = *k;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (*p <= j2[*i13 + *k - i__]) {
	    i4271 = *k - i__ + 1;
	} else {
	    goto L567;
	}
    }
L567:
    i__1 = *k - i4271;
    for (j = 1; j <= i__1; ++j) {
	i__2 = *n;
	for (i__ = 1; i__ <= i__2; ++i__) {
	    j2[*i37 + (*k - j) * *n + i__ - 1] = j2[*i37 + (*k - j - 1) * *n 
		    + i__ - 1];
	}
	j2[*i98 + *k - j] = j2[*i98 + *k - j - 1];
	j2[*i2462 + *k - j] = j2[*i2462 + *k - j - 1];
	j2[*i13 + *k - j] = j2[*i13 + *k - j - 1];
    }
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	j2[*i37 + (i4271 - 1) * *n + i__ - 1] = x[i__];
    }
    j2[*i98 + i4271 - 1] = *f;
    j2[*i2462 + i4271 - 1] = *i11;
    j2[*i13 + i4271 - 1] = *p;
    return 0;
} /* o8971310_ */

/* Subroutine */ int o9953052_(doublereal *f, doublereal *g, integer *m)
{
    /* System generated locals */
    integer i__1;

    /* Local variables */
    static integer i__;

    /* Parameter adjustments */
    --g;

    /* Function Body */
    if (*f != *f) {
	*f = 1e16;
    }
    i__1 = *m;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (g[i__] != g[i__]) {
	    g[i__] = -1e16;
	}
    }
    return 0;
} /* o9953052_ */

/* Subroutine */ int o329519_(integer *j6, integer *lj6, integer *i64, 
	integer *i03s, integer *bi03, integer *di03, integer *di64)
{
    /* Parameter adjustments */
    --j6;

    /* Function Body */
    if (j6[*i64] == 1 && j6[*di64] == 1) {
	j6[*i03s] = j6[*di03];
    } else {
	j6[*i03s] = j6[*bi03];
    }
    if (j6[*i64] <= j6[*di64] && j6[*di64] > 1) {
	j6[*i03s] = j6[*bi03] + (j6[*di03] - j6[*bi03]) * (integer) ((
		doublereal) (j6[*i64] - 1) / (doublereal) (j6[*di64] - 1));
    }
    if (j6[*i64] > j6[*di64] && j6[*i64] < j6[*di64] << 1) {
	j6[*i03s] = j6[*di03] + (j6[*bi03] - j6[*di03]) * (integer) ((
		doublereal) j6[*i64] / (doublereal) (j6[*di64] << 1)) << 1;
    }
    return 0;
} /* o329519_ */

/* Subroutine */ int i074206156_(integer *l, integer *n, integer *nint, 
	integer *m, integer *me, doublereal *x, doublereal *f, doublereal *g, 
	doublereal *j7, doublereal *j9, doublereal *j13, integer *i3108, 
	integer *i4108, doublereal *i7193, doublereal *j2, integer *lj2, 
	integer *j6, integer *lj6, integer *i813, integer *i0009, integer *
	i5308, doublereal *k1, doublereal *k2, char *i31032, integer *
	i31579907326, ftnlen i31032_len)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    double d_nint(doublereal *);

    /* Local variables */
    static integer i__;
    extern /* Subroutine */ int o027659163250219005_(char *, integer *, 
	    integer *, ftnlen);
    static integer i0621, i7904, i47029, i007002, i429103;
    extern /* Subroutine */ int o3261853008_(integer *, char *, ftnlen);

    /* Parameter adjustments */
    --f;
    --j9;
    --j7;
    --x;
    --g;
    --i7193;
    --j2;
    --j6;

    /* Function Body */
    o027659163250219005_(i31032, &i0621, i3108, (ftnlen)60);
    if (*l <= 0) {
	*i3108 = 101;
	goto L701;
    }
    if (*n <= 0) {
	*i3108 = 102;
	goto L701;
    }
    if (*nint < 0) {
	*i3108 = 103;
	goto L701;
    }
    if (*nint > *n) {
	*i3108 = 104;
	goto L701;
    }
    if (*m < 0) {
	*i3108 = 105;
	goto L701;
    }
    if (*me < 0) {
	*i3108 = 106;
	goto L701;
    }
    if (*me > *m) {
	*i3108 = 107;
	goto L701;
    }
L1:
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (x[i__] != x[i__]) {
	    *i3108 = 201;
	    goto L701;
	}
	if (j7[i__] != j7[i__]) {
	    *i3108 = 202;
	    goto L701;
	}
	if (j9[i__] != j9[i__]) {
	    *i3108 = 203;
	    goto L701;
	}
	if (x[i__] < j7[i__] - 1e-6) {
	    *i3108 = 204;
	    goto L701;
	}
	if (x[i__] > j9[i__] + 1e-6) {
	    *i3108 = 205;
	    goto L701;
	}
	if (j7[i__] > j9[i__] + 1e-6) {
	    *i3108 = 206;
	    goto L701;
	}
    }
    o3261853008_(&j6[i0621], i31032, (ftnlen)60);
    if (*j13 < 0. || *j13 != *j13) {
	*i3108 = 301;
	goto L701;
    }
    if (i7193[1] < 0.) {
	*i3108 = 302;
	goto L701;
    }
    if (i7193[2] < 0. || i7193[2] > 0. && i7193[2] < 1.) {
	*i3108 = 303;
	goto L701;
    }
    if (i7193[3] < 0.) {
	*i3108 = 304;
	goto L701;
    }
    if (i7193[5] < 0.) {
	*i3108 = 305;
	goto L701;
    }
    if (i7193[6] < 0. || i7193[6] > 0. && i7193[6] < 2.) {
	*i3108 = 306;
	goto L701;
    }
    if (i7193[6] >= i7193[5] && i7193[6] > 0.) {
	*i3108 = 307;
	goto L701;
    }
    if (i7193[5] > 0. && i7193[6] == 0.) {
	*i3108 = 308;
	goto L701;
    }
    if (i7193[6] > (doublereal) (*n) * 2 + 10.) {
	*i3108 = 309;
	goto L701;
    }
    if (i7193[7] < 0. || i7193[7] > 3.) {
	*i3108 = 310;
	goto L701;
    }
    for (i__ = 1; i__ <= 6; ++i__) {
	if (i7193[i__] != i7193[i__]) {
	    *i3108 = 311;
	    goto L701;
	}
    }
    if (*i4108 < 0 || *i4108 > 1) {
	*i3108 = 401;
	goto L701;
    }
    i7904 = 0;
    for (i__ = 1; i__ <= 20; ++i__) {
	i7904 += j6[i0621 + i__ - 1];
    }
    i429103 = 535;
    if (i7904 != i429103) {
	goto L1;
    }
    o3261853008_(&j6[1], i31032, (ftnlen)60);
    i47029 = 1;
    for (i__ = 1; i__ <= 60; ++i__) {
	i47029 += j6[i__];
    }
    i007002 = 2124;
    if (i47029 != i007002) {
	goto L1;
    }
    *i813 = (integer) (*k1) * *n + (integer) (*k2);
    *i0009 = (*n << 1) + *m + (*n + 5) * *i813 + 8;
    *i5308 = *l + 31 + *n + *n;
    if (*lj2 < *i0009 + 5 + *n + *m) {
	*i3108 = 501;
	goto L701;
    }
    if (*lj6 < *i5308 + 69) {
	*i3108 = 601;
	goto L701;
    }
    i__1 = *i0009 + 5 + *n + *m;
    for (i__ = 1; i__ <= i__1; ++i__) {
	j2[i__] = 0.;
    }
    i__1 = *i5308 + 69;
    for (i__ = 1; i__ <= i__1; ++i__) {
	j6[i__] = 0;
    }
    *i31579907326 = 0;
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (x[i__] > 1e12 || x[i__] < -1e12) {
	    *i3108 = 51;
	    goto L702;
	}
	if (j7[i__] > 1e12 || j7[i__] < -1e12) {
	    *i3108 = 52;
	    goto L702;
	}
	if (j9[i__] > 1e12 || j9[i__] < -1e12) {
	    *i3108 = 53;
	    goto L702;
	}
	if (j7[i__] == j9[i__]) {
	    *i3108 = 71;
	    goto L702;
	}
    }
    i__1 = *n;
    for (i__ = *n - *nint + 1; i__ <= i__1; ++i__) {
	if ((d__1 = x[i__] - d_nint(&x[i__]), abs(d__1)) > 1e-6) {
	    *i3108 = 61;
	    goto L702;
	}
	if ((d__1 = j7[i__] - d_nint(&j7[i__]), abs(d__1)) > 1e-6) {
	    *i3108 = 62;
	    goto L702;
	}
	if ((d__1 = j9[i__] - d_nint(&j9[i__]), abs(d__1)) > 1e-6) {
	    *i3108 = 63;
	    goto L702;
	}
    }
    if (f[1] != f[1]) {
	*i3108 = 81;
	goto L702;
    }
    i__1 = *m;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (g[i__] != g[i__]) {
	    *i3108 = 82;
	    goto L702;
	}
    }
    return 0;
L701:
    *i4108 = 1;
    return 0;
L702:
    *i31579907326 = 1;
    return 0;
} 
int o61867290_(integer *n, integer *nint, doublereal *j2, 
	integer *lj2, integer *i8087, integer *i37, integer *j6, integer *lj6,
	 integer *k, integer *i64, doublereal *z__)
{
    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    double sqrt(doublereal);

    /* Local variables */
    static integer i__, j;
    static doublereal i140, i809, i346031, i6132006, i5510871;

    /* Parameter adjustments */
    --j2;
    --j6;

    /* Function Body */
    i346031 = sqrt((doublereal) j6[*i64]);
    i6132006 = *z__ / i346031;
    i5510871 = (1. - 1. / sqrt((doublereal) (*nint) + .1)) / 2.;
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i809 = j2[*i37 + i__ - 1];
	i140 = j2[*i37 + i__ - 1];
	i__2 = j6[*k];
	for (j = 2; j <= i__2; ++j) {
	    if (j2[*i37 + (j - 1) * *n + i__ - 1] > i809) {
		i809 = j2[*i37 + (j - 1) * *n + i__ - 1];
	    }
	    if (j2[*i37 + (j - 1) * *n + i__ - 1] < i140) {
		i140 = j2[*i37 + (j - 1) * *n + i__ - 1];
	    }
	}
	j2[*i8087 + i__ - 1] = (i809 - i140) / i346031;
	if (i__ > *n - *nint) {
	    if (j2[*i8087 + i__ - 1] < i6132006) {
		j2[*i8087 + i__ - 1] = i6132006;
	    }
	    if (j2[*i8087 + i__ - 1] < i5510871) {
		j2[*i8087 + i__ - 1] = i5510871;
	    }
	}
    }
    return 0;
} /* o61867290_ */

/* Subroutine */ int o83517_(integer *n, integer *nint, doublereal *j2, 
	integer *lj2, integer *j6, integer *lj6, integer *i86x, doublereal *x,
	 doublereal *j7, doublereal *j9, doublereal *z__, doublereal *y, 
	doublereal *i13509)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1, d__2;

    /* Builtin functions */
    double sqrt(doublereal), pow_dd(doublereal *, doublereal *), d_nint(
	    doublereal *);

    /* Local variables */
    static integer i__;
    extern doublereal o89_(doublereal *);
    static doublereal i130;
    extern doublereal i9042677836_(doublereal *, doublereal *);

    /* Parameter adjustments */
    --j9;
    --j7;
    --x;
    --j2;
    --j6;

    /* Function Body */
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i130 = (j9[i__] - j7[i__]) / (doublereal) j6[10];
	if (i__ > *n - *nint && i130 < *z__) {
	    i130 = *z__;
	}
	if (*i13509 > 0.) {
	    if (i130 > (j9[i__] - j7[i__]) / *i13509) {
		i130 = (j9[i__] - j7[i__]) / *i13509;
	    }
	    if (i__ > *n - *nint) {
		if (i130 < 1. / sqrt(*i13509)) {
		    i130 = 1. / sqrt(*i13509);
		}
	    }
	}
	d__1 = o89_(&j2[1]);
	d__2 = o89_(&j2[1]);
	x[i__] = j2[*i86x + i__ - 1] + i130 * i9042677836_(&d__1, &d__2);
	if (x[i__] < j7[i__]) {
	    x[i__] = j7[i__] + (j7[i__] - x[i__]) / pow_dd(&c_b13, y);
	    if (x[i__] < j7[i__]) {
		x[i__] = j7[i__];
	    }
	    if (x[i__] > j9[i__]) {
		x[i__] = j9[i__];
	    }
	}
	if (x[i__] > j9[i__]) {
	    x[i__] = j9[i__] - (x[i__] - j9[i__]) / pow_dd(&c_b13, y);
	    if (x[i__] < j7[i__]) {
		x[i__] = j7[i__];
	    }
	    if (x[i__] > j9[i__]) {
		x[i__] = j9[i__];
	    }
	}
	if (i__ > *n - *nint) {
	    x[i__] = d_nint(&x[i__]);
	}
    }
    return 0;
} /* o83517_ */

/* Subroutine */ int o21_(doublereal *i11, doublereal *g, integer *m, integer 
	*me, doublereal *j13)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Local variables */
    static integer i__;

    /* Parameter adjustments */
    --g;

    /* Function Body */
    *i11 = 0.;
    i__1 = *me;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if ((d__1 = g[i__], abs(d__1)) > *j13) {
	    if ((d__1 = g[i__], abs(d__1)) > *i11) {
		*i11 = (d__1 = g[i__], abs(d__1));
	    }
	}
    }
    i__1 = *m;
    for (i__ = *me + 1; i__ <= i__1; ++i__) {
	if (g[i__] < -(*j13)) {
	    if (-g[i__] > *i11) {
		*i11 = -g[i__];
	    }
	}
    }
    return 0;
} /* o21_ */

/* Subroutine */ int o2840_(integer *n, integer *m, integer *i86x, integer *
	i472, integer *i315, integer *i86i11, integer *i4296, integer *i813, 
	integer *i37, integer *i98, integer *i2462, integer *i13, integer *w, 
	integer *i8087, integer *pt, integer *i3, integer *i4, integer *i110)
{
    *i86x = 2;
    *i472 = *i86x + *n;
    *i315 = *i472 + 1;
    *i86i11 = *i315 + *m;
    *i4296 = *i86i11 + 1;
    *i37 = *i4296 + 1;
    *i98 = *i37 + *n * *i813;
    *i2462 = *i98 + *i813;
    *i13 = *i2462 + *i813;
    *pt = *i13 + *i813;
    *w = *pt + *i813 + 1;
    *i8087 = *w + *i813;
    *i3 = *i8087 + *n;
    *i4 = *i3 + 1;
    *i110 = *i4 + 1;
    return 0;
} /* o2840_ */

/* Subroutine */ int o027659163250219005_(char *i31032, integer *i0621, 
	integer *i3108, ftnlen i31032_len)
{
    extern /* Subroutine */ int o6288601_(char *, integer *, ftnlen);

    if (*i3108 == 0) {
	*i0621 = 1;
    }
    if (*i0621 <= 0) {
	*i0621 = 1;
    }
    o6288601_(i31032 + (*i0621 - 1), i0621, (ftnlen)1);
    if (*i0621 <= 0) {
	*i0621 = 1;
    }
    if (*i0621 >= 60) {
	*i0621 = 2;
    }
/* L50: */
    return 0;
} /* o027659163250219005_ */

/* Subroutine */ int o953814_(integer *n, integer *i813, doublereal *j2, 
	integer *lj2, integer *i472, integer *i86i11, integer *i4296, 
	doublereal *j13, integer *i37, integer *i98, integer *i2462, integer *
	i13, integer *j6, integer *lj6, integer *i81, integer *k, integer *
	bi03, integer *di03, integer *di64, doublereal *i87621, integer *
	i41981820, doublereal *i78923, doublereal *i78913, doublereal *i7193, 
	integer *i5308, char *i31032, ftnlen i31032_len)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;

    /* Builtin functions */
    double pow_di(doublereal *, integer *), pow_dd(doublereal *, doublereal *)
	    ;

    /* Local variables */
    static integer i__, j;
    static doublereal f1;
    static integer p1, p2, p3;
    static doublereal q1, q2, z1, z2;
    static integer i662, i55117, i46i022;
    extern /* Subroutine */ int o3261853008_(integer *, char *, ftnlen);

    /* Parameter adjustments */
    --j2;
    --j6;
    --i78923;
    --i78913;
    --i7193;

    /* Function Body */
    f1 = i78923[2];
    q1 = i78923[3];
    q2 = i78923[4];
    z1 = i78923[9];
    z2 = i78923[10];
    p1 = (integer) i78913[10];
    p2 = (integer) i78913[11];
    p3 = (integer) i78913[12];
    i662 = 0;
    i55117 = 0;
    i46i022 = 0;
    o3261853008_(&j6[*i5308 + 1], i31032, (ftnlen)60);
    if (j6[*i81] <= 1) {
	j6[10] = 0;
	j6[12] = 0;
    } else {
	j6[12] += p1;
	j6[10] = 1;
	i__1 = j6[12];
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j6[10] *= p2;
	}
	if ((doublereal) j6[10] > pow_di(&c_b13, &p3)) {
	    j6[10] = 0;
	    j6[12] = 0;
	}
    }
    if ((integer) i7193[5] > 0) {
	goto L101;
    }
    if (j6[*i81] <= 1) {
	j6[9] = 0;
    }
L567:
    j6[*bi03] = (integer) (z1 * (doublereal) (*n) / 2. + z2 * j6[9] * (
	    doublereal) (*n) / 2.);
    if (j6[*bi03] < 3) {
	j6[*bi03] = 3;
    }
    i55117 = 0;
    for (i__ = 1; i__ <= 5; ++i__) {
	i55117 += j6[*i5308 + i__];
    }
    j6[*k] = (integer) (f1 * (doublereal) j6[*bi03]);
    if (j6[*k] < 2) {
	j6[*k] = 2;
    }
    ++i662;
    if (i662 > 100) {
	j6[*bi03] = 3;
	j6[*k] = 2;
	goto L100;
    }
    if (j6[*k] > *i813) {
	j6[9] = 1;
	goto L567;
    } else {
	++j6[9];
    }
    for (i__ = 5; i__ <= 15; ++i__) {
	i55117 -= j6[*i5308 + i__];
    }
    i46i022 = -214;
L100:
    d__1 = (doublereal) j6[*bi03];
    j6[*di03] = *i41981820 * (integer) pow_dd(&d__1, &q1);
    j6[*di64] = (integer) (q2 * (doublereal) j6[*k]);
L101:
    if ((integer) i7193[5] > 0) {
	j6[*bi03] = (integer) i7193[5];
	j6[*k] = (integer) i7193[6];
	j6[*di03] = j6[*bi03];
	j6[*di64] = j6[*k];
    }
    if (i55117 != i46i022) {
	j6[*bi03] = (integer) i7193[5];
	j6[*k] = (integer) i7193[4];
	j6[*di03] = j6[*k];
	j6[*di64] = j6[*bi03];
    }
    j2[*i4296] = *i87621;
    if (j2[*i86i11] <= *j13 && j2[*i472] < *i87621) {
	j2[*i4296] = j2[*i472];
    }
    i__1 = j6[*k];
    for (j = 1; j <= i__1; ++j) {
	i__2 = *n;
	for (i__ = 1; i__ <= i__2; ++i__) {
	    j2[*i37 + (j - 1) * *n + i__ - 1] = 1e16;
	}
	j2[*i2462 + j - 1] = 1e16;
	j2[*i98 + j - 1] = 1e16;
	j2[*i13 + j - 1] = 1e16;
    }
    return 0;
} /* o953814_ */

/* Subroutine */ int o732_(doublereal *p, doublereal *f, doublereal *i11, 
	doublereal *i4296, doublereal *j13)
{
    /* Builtin functions */
    double sqrt(doublereal);

    /* Local variables */
    static doublereal i1437;

    if (*f <= *i4296 && *i11 <= *j13) {
	*p = *f - *i4296;
	return 0;
    } else {
	if (*f <= *i4296) {
	    *p = *i11;
	    return 0;
	} else {
	    i1437 = 0.;
	    if (*i11 < (*f - *i4296) / 3.) {
		i1437 = ((*f - *i4296) * 8.0754991 - *i11) / (*f - *i4296 - *
			i11);
		goto L1;
	    }
	    if (*i11 >= (*f - *i4296) / 3. && *i11 <= *f - *i4296) {
		i1437 = 1. - .5 / sqrt((*f - *i4296) / *i11);
		goto L1;
	    }
	    if (*i11 > *f - *i4296) {
		i1437 = sqrt((*f - *i4296) / *i11) * .5;
		goto L1;
	    }
L1:
	    *p = i1437 * (*f - *i4296) + (1. - i1437) * *i11;
	    return 0;
	}
    }
    return 0;
} /* o732_ */

/* Subroutine */ int o6288601_(char *i50315, integer *i82431, ftnlen 
	i50315_len)
{
    *i82431 = 0;
    if (*(unsigned char *)i50315 == 'A') {
	*i82431 = 52;
    }
    if (*(unsigned char *)i50315 == 'B') {
	*i82431 = 28;
    }
    if (*(unsigned char *)i50315 == 'C') {
	*i82431 = 49;
    }
    if (*(unsigned char *)i50315 == 'D') {
	*i82431 = 30;
    }
    if (*(unsigned char *)i50315 == 'E') {
	*i82431 = 31;
    }
    if (*(unsigned char *)i50315 == 'F') {
	*i82431 = 32;
    }
    if (*(unsigned char *)i50315 == 'G') {
	*i82431 = 33;
    }
    if (*(unsigned char *)i50315 == 'H') {
	*i82431 = 34;
    }
    if (*(unsigned char *)i50315 == 'I') {
	*i82431 = 35;
    }
    if (*(unsigned char *)i50315 == 'J') {
	*i82431 = 36;
    }
    if (*(unsigned char *)i50315 == 'K') {
	*i82431 = 37;
    }
    if (*(unsigned char *)i50315 == 'L') {
	*i82431 = 38;
    }
    if (*(unsigned char *)i50315 == 'M') {
	*i82431 = 39;
    }
    if (*(unsigned char *)i50315 == 'N') {
	*i82431 = 40;
    }
    if (*(unsigned char *)i50315 == 'O') {
	*i82431 = 41;
    }
    if (*(unsigned char *)i50315 == 'P') {
	*i82431 = 42;
    }
    if (*(unsigned char *)i50315 == 'Q') {
	*i82431 = 43;
    }
    if (*(unsigned char *)i50315 == 'R') {
	*i82431 = 44;
    }
    if (*(unsigned char *)i50315 == 'S') {
	*i82431 = 45;
    }
    if (*(unsigned char *)i50315 == 'T') {
	*i82431 = 46;
    }
    if (*(unsigned char *)i50315 == 'U') {
	*i82431 = 47;
    }
    if (*(unsigned char *)i50315 == 'V') {
	*i82431 = 48;
    }
    if (*(unsigned char *)i50315 == 'W') {
	*i82431 = 29;
    }
    if (*(unsigned char *)i50315 == 'X') {
	*i82431 = 50;
    }
    if (*(unsigned char *)i50315 == 'Y') {
	*i82431 = 51;
    }
    if (*(unsigned char *)i50315 == 'Z') {
	*i82431 = 27;
    }
    if (*(unsigned char *)i50315 == '0') {
	*i82431 = 53;
    }
    if (*(unsigned char *)i50315 == '1') {
	*i82431 = 54;
    }
    if (*(unsigned char *)i50315 == '2') {
	*i82431 = 55;
    }
    if (*(unsigned char *)i50315 == '3') {
	*i82431 = 56;
    }
    if (*(unsigned char *)i50315 == '4') {
	*i82431 = 57;
    }
    if (*(unsigned char *)i50315 == '5') {
	*i82431 = 58;
    }
    if (*(unsigned char *)i50315 == '6') {
	*i82431 = 59;
    }
    if (*(unsigned char *)i50315 == '7') {
	*i82431 = 60;
    }
    if (*(unsigned char *)i50315 == '8') {
	*i82431 = 61;
    }
    if (*(unsigned char *)i50315 == '9') {
	*i82431 = 62;
    }
    if (*(unsigned char *)i50315 == 'a') {
	*i82431 = 23;
    }
    if (*(unsigned char *)i50315 == 'b') {
	*i82431 = 2;
    }
    if (*(unsigned char *)i50315 == 'c') {
	*i82431 = 3;
    }
    if (*(unsigned char *)i50315 == 'd') {
	*i82431 = 16;
    }
    if (*(unsigned char *)i50315 == 'e') {
	*i82431 = 5;
    }
    if (*(unsigned char *)i50315 == 'f') {
	*i82431 = 13;
    }
    if (*(unsigned char *)i50315 == 'g') {
	*i82431 = 7;
    }
    if (*(unsigned char *)i50315 == 'h') {
	*i82431 = 8;
    }
    if (*(unsigned char *)i50315 == 'i') {
	*i82431 = 9;
    }
    if (*(unsigned char *)i50315 == 'j') {
	*i82431 = 10;
    }
    if (*(unsigned char *)i50315 == 'k') {
	*i82431 = 11;
    }
    if (*(unsigned char *)i50315 == 'l') {
	*i82431 = 12;
    }
    if (*(unsigned char *)i50315 == 'm') {
	*i82431 = 6;
    }
    if (*(unsigned char *)i50315 == 'n') {
	*i82431 = 14;
    }
    if (*(unsigned char *)i50315 == 'o') {
	*i82431 = 15;
    }
    if (*(unsigned char *)i50315 == 'p') {
	*i82431 = 4;
    }
    if (*(unsigned char *)i50315 == 'q') {
	*i82431 = 17;
    }
    if (*(unsigned char *)i50315 == 'r') {
	*i82431 = 18;
    }
    if (*(unsigned char *)i50315 == 's') {
	*i82431 = 19;
    }
    if (*(unsigned char *)i50315 == 't') {
	*i82431 = 20;
    }
    if (*(unsigned char *)i50315 == 'u') {
	*i82431 = 21;
    }
    if (*(unsigned char *)i50315 == 'v') {
	*i82431 = 22;
    }
    if (*(unsigned char *)i50315 == 'w') {
	*i82431 = 1;
    }
    if (*(unsigned char *)i50315 == 'x') {
	*i82431 = 24;
    }
    if (*(unsigned char *)i50315 == 'y') {
	*i82431 = 25;
    }
    if (*(unsigned char *)i50315 == 'z') {
	*i82431 = 26;
    }
    if (*(unsigned char *)i50315 == '_') {
	*i82431 = 64;
    }
    if (*(unsigned char *)i50315 == '(') {
	*i82431 = 65;
    }
    if (*(unsigned char *)i50315 == ')') {
	*i82431 = 66;
    }
    if (*(unsigned char *)i50315 == '+') {
	*i82431 = 67;
    }
    if (*(unsigned char *)i50315 == '-') {
	*i82431 = 68;
    }
    if (*(unsigned char *)i50315 == '&') {
	*i82431 = 69;
    }
    if (*(unsigned char *)i50315 == '.') {
	*i82431 = 70;
    }
    if (*(unsigned char *)i50315 == ',') {
	*i82431 = 71;
    }
    if (*(unsigned char *)i50315 == ':') {
	*i82431 = 72;
    }
    if (*(unsigned char *)i50315 == ';') {
	*i82431 = 73;
    }
    if (*(unsigned char *)i50315 == '*') {
	*i82431 = 74;
    }
    if (*(unsigned char *)i50315 == '=') {
	*i82431 = 75;
    }
    if (*(unsigned char *)i50315 == '/') {
	*i82431 = 76;
    }
    if (*(unsigned char *)i50315 == '!') {
	*i82431 = 80;
    }
    if (*(unsigned char *)i50315 == '[') {
	*i82431 = 83;
    }
    if (*(unsigned char *)i50315 == ']') {
	*i82431 = 84;
    }
    return 0;
} /* o6288601_ */

/* Subroutine */ int o53_(doublereal *i11, doublereal *g, integer *m, integer 
	*me, doublereal *j13)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Local variables */
    static integer i__;

    /* Parameter adjustments */
    --g;

    /* Function Body */
    *i11 = 0.;
    i__1 = *me;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if ((d__1 = g[i__], abs(d__1)) > *j13) {
	    *i11 += (d__1 = g[i__], abs(d__1));
	}
    }
    i__1 = *m;
    for (i__ = *me + 1; i__ <= i__1; ++i__) {
	if (g[i__] < -(*j13)) {
	    *i11 -= g[i__];
	}
    }
    return 0;
} /* o53_ */

/* Subroutine */ int o213659807013_(integer *l, integer *n, integer *nint, 
	integer *m, integer *me, doublereal *x, doublereal *f, doublereal *g, 
	doublereal *j7, doublereal *j9, doublereal *j13, integer *i09410, 
	integer *i725, integer *i3108, logical *i4108, integer *i5542, 
	doublereal *j2, integer *lj2, integer *j6, integer *lj6, integer *
	i813, doublereal *i87621, integer *i41981820, doublereal *i78923, 
	doublereal *i78913, doublereal *i7193, doublereal *p, doublereal *i11,
	 integer *j609, integer *i5308, char *i31032, ftnlen i31032_len)
{
    /* Initialized data */

    static integer i9025120 = 0;
    static integer i86x = 0;
    static integer i472 = 0;
    static integer i315 = 0;
    static integer i86i11 = 0;
    static integer i4296 = 0;
    static integer i37 = 0;
    static integer i98 = 0;
    static integer i2462 = 0;
    static integer i13 = 0;
    static integer pt = 0;
    static integer w = 0;
    static integer i8087 = 0;
    static integer i3 = 0;
    static integer i4 = 0;
    static integer i110 = 0;
    static integer k = 0;
    static integer i81 = 0;
    static integer i64 = 0;
    static integer i03s = 0;
    static integer i03 = 0;
    static integer bi03 = 0;
    static integer di03 = 0;
    static integer di64 = 0;

    /* System generated locals */
    integer i__1, i__2;

    /* Local variables */
    static integer c__, i__, j;
    extern doublereal o89_(doublereal *);
    extern /* Subroutine */ int o732_(doublereal *, doublereal *, doublereal *
	    , doublereal *, doublereal *), o319_(doublereal *, doublereal *, 
	    integer *, integer *, doublereal *), o158_(integer *, integer *, 
	    integer *, doublereal *, doublereal *, doublereal *, integer *, 
	    integer *, integer *, doublereal *, integer *, integer *, integer 
	    *, integer *, integer *, doublereal *, doublereal *, doublereal *)
	    , o7100_(integer *, integer *, integer *, integer *, integer *, 
	    integer *, integer *, integer *), o1309_(integer *, integer *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, integer *)
	    , o2840_(integer *, integer *, integer *, integer *, integer *, 
	    integer *, integer *, integer *, integer *, integer *, integer *, 
	    integer *, integer *, integer *, integer *, integer *, integer *, 
	    integer *);
    static integer i21123, i08091;
    extern /* Subroutine */ int o32481_(integer *, integer *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, integer *, integer *, 
	    doublereal *), o95420_(integer *, integer *, integer *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, integer *,
	     integer *, integer *, integer *, doublereal *), o24318_(integer *
	    , integer *, doublereal *, doublereal *, doublereal *, doublereal 
	    *, integer *, integer *), o83517_(integer *, integer *, 
	    doublereal *, integer *, integer *, integer *, integer *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *), o26919_(integer *, doublereal *, 
	    integer *, integer *);
    static integer i821013, j046789;
    extern /* Subroutine */ int o953814_(integer *, integer *, doublereal *, 
	    integer *, integer *, integer *, integer *, doublereal *, integer 
	    *, integer *, integer *, integer *, integer *, integer *, integer 
	    *, integer *, integer *, integer *, integer *, doublereal *, 
	    integer *, doublereal *, doublereal *, doublereal *, integer *, 
	    char *, ftnlen), o329519_(integer *, integer *, integer *, 
	    integer *, integer *, integer *, integer *), o8971310_(integer *, 
	    integer *, doublereal *, integer *, integer *, integer *, integer 
	    *, integer *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *), o61867290_(integer *, integer *, 
	    doublereal *, integer *, integer *, integer *, integer *, integer 
	    *, integer *, integer *, doublereal *), o275315065_(integer *, 
	    integer *, integer *, doublereal *, integer *, integer *, integer 
	    *, integer *, integer *, integer *, integer *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, integer *, integer *, 
	    doublereal *, doublereal *, doublereal *), o3261853008_(integer *,
	     char *, ftnlen);

    /* Parameter adjustments */
    --f;
    --j9;
    --j7;
    --x;
    --g;
    --j2;
    --j6;
    --i78923;
    --i78913;
    --i7193;
    --i11;
    --p;

    /* Function Body */
    if (*i3108 >= 0) {
	o2840_(n, m, &i86x, &i472, &i315, &i86i11, &i4296, i813, &i37, &i98, &
		i2462, &i13, &w, &i8087, &pt, &i3, &i4, &i110);
	o7100_(&i81, &i03s, &k, &i64, &i03, &bi03, &di03, &di64);
	j2[1] = 1200.;
	i__1 = *i5542;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j2[1] = o89_(&j2[1]);
	}
	o3261853008_(&j6[*i5308 + 2], i31032, (ftnlen)60);
	o319_(&i11[1], &g[1], m, me, j13);
	j2[i472] = f[1];
	j2[i86i11] = i11[1];
	i__1 = *n;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j2[i86x + i__ - 1] = x[i__];
	}
	i__1 = *m;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j2[i315 + i__ - 1] = g[i__];
	}
	i21123 = 0;
	for (i__ = 1; i__ <= 15; ++i__) {
	    i21123 += j6[*i5308 + 1 + i__ * 3];
	}
	j046789 = 455;
	if (i21123 != j046789) {
	    goto L11;
	}
	goto L101;
    }
    i__1 = *l;
    for (c__ = 1; c__ <= i__1; ++c__) {
	o319_(&i11[c__], &g[(c__ - 1) * *m + 1], m, me, j13);
	if (*m > 0) {
	    o732_(&p[c__], &f[c__], &i11[c__], &j2[i4296], j13);
	}
	if (*m == 0) {
	    p[c__] = f[c__];
	}
	if (*i3108 > -30 || *i3108 < -40) {
	    o8971310_(n, &j6[k], &j2[1], lj2, &i37, &i98, &i2462, &i13, &x[(
		    c__ - 1) * *n + 1], &f[c__], &i11[c__], &p[c__], &i78913[
		    14]);
	}
	if (*i3108 <= -30 && *i3108 >= -40) {
	    o275315065_(l, &c__, n, &j2[1], lj2, &j6[1], lj6, &i37, &i98, &
		    i2462, &i13, &x[(c__ - 1) * *n + 1], &f[c__], &i11[c__], &
		    p[c__], &i64, i3108, &i78913[15], &i78913[4], &i78913[5]);
	}
	if (i11[c__] < j2[i86i11]) {
	    goto L123;
	}
	if (i11[c__] == j2[i86i11] && f[c__] < j2[i472]) {
	    goto L123;
	}
	goto L100;
L123:
	j2[i472] = f[c__];
	j2[i86i11] = i11[c__];
	i__2 = *n;
	for (i__ = 1; i__ <= i__2; ++i__) {
	    j2[i86x + i__ - 1] = x[(c__ - 1) * *n + i__];
	}
	i__2 = *m;
	for (i__ = 1; i__ <= i__2; ++i__) {
	    j2[i315 + i__ - 1] = g[(c__ - 1) * *m + i__];
	}
L100:
	;
    }
L101:
    if (*i4108) {
	goto L999;
    }
    if (*i3108 <= -90) {
	if (j2[i110] > *j13 && j2[i2462] < j2[i110]) {
	    goto L81;
	}
	if (j2[i110] <= *j13 && j2[i2462] <= *j13 && j2[i98] < j2[i4]) {
	    goto L81;
	}
	goto L82;
L81:
	j6[11] = 1;
	goto L83;
L82:
	j6[11] = 0;
L83:
	;
    }
    if (*i3108 == -10) {
	if (j2[i13] < j2[i3]) {
	    goto L84;
	}
	j6[13] = 0;
	goto L85;
L84:
	j6[13] = 1;
	j2[i3] = j2[i13];
L85:
	;
    }
L1000:
    if (*i09410 > 0) {
    }
    if (j6[i64] >= (integer) i78913[3]) {
	*i3108 = -95;
    }
    if (*i4108) {
	goto L3;
    }
    if (*i3108 == -1) {
	goto L13;
    }
    if (*i3108 == -2) {
	*i3108 = -1;
	goto L13;
    }
    if (*i3108 == -3) {
	if (j6[i03] >= j6[i03s]) {
	    *i3108 = -30;
	    goto L14;
	}
	*i3108 = -1;
	goto L13;
    }
    if (*i3108 == -30) {
	*i3108 = -31;
	goto L14;
    }
    if (*i3108 <= -31 && *i3108 >= -39) {
	*i3108 = *i3108;
	goto L14;
    }
    if (*i3108 == -40) {
	*i3108 = -2;
	goto L12;
    }
    if (*i3108 == -10) {
	*i3108 = -30;
	goto L14;
    }
    if (*i3108 <= -90) {
	*i3108 = -3;
	goto L11;
    }
    if (*i3108 == 0) {
	*i3108 = -3;
	goto L11;
    }
L11:
    ++j6[i81];
    j6[i64] = 0;
    i821013 = 3466;
    o953814_(n, i813, &j2[1], lj2, &i472, &i86i11, &i4296, j13, &i37, &i98, &
	    i2462, &i13, &j6[1], lj6, &i81, &k, &bi03, &di03, &di64, i87621, 
	    i41981820, &i78923[1], &i78913[1], &i7193[1], i5308, i31032, (
	    ftnlen)60);
    o26919_(&j6[k], &j2[1], lj2, &w);
    o3261853008_(&j6[*i5308 + 1], i31032, (ftnlen)60);
    j2[pt] = 0.;
    i__1 = j6[k];
    for (j = 1; j <= i__1; ++j) {
	j2[pt + j] = j2[pt + j - 1] + j2[w + j - 1];
    }
    j2[i4] = j2[i472];
    j2[i110] = j2[i86i11];
    i9025120 = 0;
/* Computing 2nd power */
    i__1 = j6[*i5308 + 1];
    i08091 = i__1 * i__1;
    for (i__ = 0; i__ <= 40; ++i__) {
	i08091 += j6[*i5308 + i__ + 10];
    }
    if (i08091 != i821013) {
	i__1 = *lj6;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j6[i__] = (integer) j2[*lj6 + i__];
	}
    }
    if (j6[i81] == 1) {
	if (*m > 0) {
	    o732_(&p[1], &f[1], &i11[1], &j2[i4296], j13);
	}
	if (*m == 0) {
	    p[1] = f[1];
	}
	o8971310_(n, &j6[k], &j2[1], lj2, &i37, &i98, &i2462, &i13, &x[1], &f[
		1], &i11[1], &p[1], &i78913[14]);
    }
L12:
    ++j6[i64];
    j6[i03] = 0;
    o61867290_(n, nint, &j2[1], lj2, &i8087, &i37, &j6[1], lj6, &k, &i64, &
	    i78923[8]);
    if (i7193[5] > 0.) {
	j6[i03s] = j6[bi03];
    } else {
	o329519_(&j6[1], lj6, &i64, &i03s, &bi03, &di03, &di64);
    }
    if (j6[i64] == 1) {
	j2[i3] = 1e16;
    }
    if (j6[i64] > 1) {
	j2[i3] = j2[i13];
    }
L13:
    i__1 = *l;
    for (c__ = 1; c__ <= i__1; ++c__) {
	++j6[i03];
	if (j6[i64] == 1) {
	    if (j6[10] <= 1) {
		if (i7193[2] > 0. && j6[i81] == 1) {
		    o32481_(n, nint, &x[(c__ - 1) * *n + 1], &j7[1], &j9[1], &
			    j2[1], lj2, &i86x, &i7193[2]);
		} else {
		    if (i7193[2] > 0.) {
			o32481_(n, nint, &x[(c__ - 1) * *n + 1], &j7[1], &j9[
				1], &j2[1], lj2, &i86x, &i7193[2]);
		    } else {
			o1309_(n, nint, &x[(c__ - 1) * *n + 1], &j7[1], &j9[1]
				, &j2[1], lj2);
		    }
		}
	    }
	    if (j6[10] > 1) {
		o83517_(n, nint, &j2[1], lj2, &j6[1], lj6, &i86x, &x[(c__ - 1)
			 * *n + 1], &j7[1], &j9[1], &i78923[1], &i78913[16], &
			i7193[2]);
	    }
	}
	if (j6[i64] > 1) {
	    o95420_(n, nint, &j6[k], &x[(c__ - 1) * *n + 1], &j7[1], &j9[1], &
		    j2[1], lj2, &i37, &i8087, &pt, &i78923[5]);
	}
    }
    if (j6[i03] >= j6[i03s] && *i3108 != -3) {
	*i3108 = -10;
    }
L3:
    return 0;
L14:
    o3261853008_(&j6[*i5308 + 1], i31032, (ftnlen)60);
    if (j6[13] == 1 || j6[i64] == 1) {
	*i3108 = -2;
	goto L12;
    } else {
	if (*i3108 < -30 && j6[31] == 1) {
	    *i3108 = -2;
	    goto L12;
	}
	if (*i3108 == -39) {
	    i9025120 = 1;
	    *i3108 = -99;
	    goto L101;
	}
	i__1 = *l;
	for (c__ = 1; c__ <= i__1; ++c__) {
	    if (*l > 1) {
		j6[31] = 0;
	    }
	    o158_(l, n, nint, &x[(c__ - 1) * *n + 1], &j7[1], &j9[1], &i37, &
		    i8087, i5308, &j2[1], lj2, &j6[1], lj6, i3108, &i9025120, 
		    &i78923[6], &i78923[7], &i78913[13]);
	    if (*i3108 == -30 && *l > 1) {
		*i3108 = -31;
	    }
	    if (i9025120 == 1 && c__ > 1) {
		if (o89_(&j2[1]) >= .33) {
		    o24318_(n, nint, &x[(c__ - 1) * *n + 1], &j7[1], &j9[1], &
			    j2[1], lj2, &i37);
		} else {
		    o95420_(n, nint, &j6[k], &x[(c__ - 1) * *n + 1], &j7[1], &
			    j9[1], &j2[1], lj2, &i37, &i8087, &pt, &i78923[5])
			    ;
		}
		i9025120 = 0;
		*i3108 = -39;
	    }
	}
	if (i9025120 == 1) {
	    goto L101;
	}
	goto L3;
    }
L999:
    f[1] = j2[i472];
    i11[1] = j2[i86i11];
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	x[i__] = j2[i86x + i__ - 1];
    }
    i__1 = *m;
    for (j = 1; j <= i__1; ++j) {
	g[j] = j2[i315 + j - 1];
    }
    if (i11[1] <= *j13) {
	*i3108 = 0;
    } else {
	*i3108 = 1;
    }
    if (*i09410 > 0) {
	goto L1000;
    }
    return 0;
} /* o213659807013_ */

/* Subroutine */ int o275315065_(integer *l, integer *c__, integer *n, 
	doublereal *j2, integer *lj2, integer *j6, integer *lj6, integer *i37,
	 integer *i98, integer *i2462, integer *i13, doublereal *x, 
	doublereal *f, doublereal *i11, doublereal *p, integer *i64, integer *
	i3108, doublereal *o1, doublereal *r1, doublereal *r2)
{
    /* Initialized data */

    static doublereal oo = 0.;
    static doublereal ooo = 0.;

    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    double sqrt(doublereal);

    /* Local variables */
    static integer i__;

    /* Parameter adjustments */
    --x;
    --j2;
    --j6;

    /* Function Body */
    if (*i3108 == -30) {
	oo = *o1 + *r1 * sqrt((doublereal) j6[*i64]) + (doublereal) (*n);
	ooo = *o1 + *r2 * sqrt((doublereal) j6[*i64]);
    }
    if (*i11 <= 0. && j2[*i2462] <= 0.) {
	if (*f >= j2[*i98] - (d__1 = j2[*i98], abs(d__1)) / oo) {
	    j6[*c__ + 31] = 0;
	    goto L1;
	}
    } else {
	if (*p >= j2[*i13] - (d__1 = j2[*i13], abs(d__1)) / ooo) {
	    j6[*c__ + 31] = 0;
	    goto L1;
	}
    }
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	j2[*i37 + i__ - 1] = x[i__];
    }
    j2[*i2462] = *i11;
    j2[*i98] = *f;
    j2[*i13] = *p;
    j6[*c__ + 31] = 1;
L1:
    if (*c__ == *l) {
	j6[31] = 0;
	i__1 = *l;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j6[31] += j6[i__ + 31];
	}
	if (j6[31] > 1) {
	    j6[31] = 1;
	}
    }
    return 0;
} /* o275315065_ */

/* Subroutine */ int o62886010_(char *i50315, integer *i82431, ftnlen 
	i50315_len)
{
    *i82431 = 0;
    if (*(unsigned char *)i50315 == 'A') {
	*i82431 = 52;
    }
    if (*(unsigned char *)i50315 == 'B') {
	*i82431 = 28;
    }
    if (*(unsigned char *)i50315 == 'C') {
	*i82431 = 49;
    }
    if (*(unsigned char *)i50315 == 'D') {
	*i82431 = 30;
    }
    if (*(unsigned char *)i50315 == 'E') {
	*i82431 = 31;
    }
    if (*(unsigned char *)i50315 == 'F') {
	*i82431 = 32;
    }
    if (*(unsigned char *)i50315 == 'G') {
	*i82431 = 33;
    }
    if (*(unsigned char *)i50315 == 'H') {
	*i82431 = 34;
    }
    if (*(unsigned char *)i50315 == 'I') {
	*i82431 = 35;
    }
    if (*(unsigned char *)i50315 == 'J') {
	*i82431 = 36;
    }
    if (*(unsigned char *)i50315 == 'K') {
	*i82431 = 37;
    }
    if (*(unsigned char *)i50315 == 'L') {
	*i82431 = 38;
    }
    if (*(unsigned char *)i50315 == 'M') {
	*i82431 = 39;
    }
    if (*(unsigned char *)i50315 == 'N') {
	*i82431 = 40;
    }
    if (*(unsigned char *)i50315 == 'O') {
	*i82431 = 41;
    }
    if (*(unsigned char *)i50315 == 'P') {
	*i82431 = 42;
    }
    if (*(unsigned char *)i50315 == 'Q') {
	*i82431 = 43;
    }
    if (*(unsigned char *)i50315 == 'R') {
	*i82431 = 44;
    }
    if (*(unsigned char *)i50315 == 'S') {
	*i82431 = 45;
    }
    if (*(unsigned char *)i50315 == 'T') {
	*i82431 = 46;
    }
    if (*(unsigned char *)i50315 == 'U') {
	*i82431 = 47;
    }
    if (*(unsigned char *)i50315 == 'V') {
	*i82431 = 48;
    }
    if (*(unsigned char *)i50315 == 'W') {
	*i82431 = 29;
    }
    if (*(unsigned char *)i50315 == 'X') {
	*i82431 = 50;
    }
    if (*(unsigned char *)i50315 == 'Y') {
	*i82431 = 51;
    }
    if (*(unsigned char *)i50315 == 'Z') {
	*i82431 = 27;
    }
    if (*(unsigned char *)i50315 == '0') {
	*i82431 = 53;
    }
    if (*(unsigned char *)i50315 == '1') {
	*i82431 = 54;
    }
    if (*(unsigned char *)i50315 == '2') {
	*i82431 = 55;
    }
    if (*(unsigned char *)i50315 == '3') {
	*i82431 = 56;
    }
    if (*(unsigned char *)i50315 == '4') {
	*i82431 = 57;
    }
    if (*(unsigned char *)i50315 == '5') {
	*i82431 = 58;
    }
    if (*(unsigned char *)i50315 == '6') {
	*i82431 = 59;
    }
    if (*(unsigned char *)i50315 == '7') {
	*i82431 = 60;
    }
    if (*(unsigned char *)i50315 == '8') {
	*i82431 = 61;
    }
    if (*(unsigned char *)i50315 == '9') {
	*i82431 = 62;
    }
    if (*(unsigned char *)i50315 == 'a') {
	*i82431 = 23;
    }
    if (*(unsigned char *)i50315 == 'b') {
	*i82431 = 2;
    }
    if (*(unsigned char *)i50315 == 'c') {
	*i82431 = 3;
    }
    if (*(unsigned char *)i50315 == 'd') {
	*i82431 = 16;
    }
    if (*(unsigned char *)i50315 == 'e') {
	*i82431 = 5;
    }
    if (*(unsigned char *)i50315 == 'f') {
	*i82431 = 13;
    }
    if (*(unsigned char *)i50315 == 'g') {
	*i82431 = 7;
    }
    if (*(unsigned char *)i50315 == 'h') {
	*i82431 = 8;
    }
    if (*(unsigned char *)i50315 == 'i') {
	*i82431 = 9;
    }
    if (*(unsigned char *)i50315 == 'j') {
	*i82431 = 10;
    }
    if (*(unsigned char *)i50315 == 'k') {
	*i82431 = 11;
    }
    if (*(unsigned char *)i50315 == 'l') {
	*i82431 = 12;
    }
    if (*(unsigned char *)i50315 == 'm') {
	*i82431 = 6;
    }
    if (*(unsigned char *)i50315 == 'n') {
	*i82431 = 14;
    }
    if (*(unsigned char *)i50315 == 'o') {
	*i82431 = 15;
    }
    if (*(unsigned char *)i50315 == 'p') {
	*i82431 = 4;
    }
    if (*(unsigned char *)i50315 == 'q') {
	*i82431 = 17;
    }
    if (*(unsigned char *)i50315 == 'r') {
	*i82431 = 18;
    }
    if (*(unsigned char *)i50315 == 's') {
	*i82431 = 19;
    }
    if (*(unsigned char *)i50315 == 't') {
	*i82431 = 20;
    }
    if (*(unsigned char *)i50315 == 'u') {
	*i82431 = 21;
    }
    if (*(unsigned char *)i50315 == 'v') {
	*i82431 = 22;
    }
    if (*(unsigned char *)i50315 == 'w') {
	*i82431 = 1;
    }
    if (*(unsigned char *)i50315 == 'x') {
	*i82431 = 24;
    }
    if (*(unsigned char *)i50315 == 'y') {
	*i82431 = 25;
    }
    if (*(unsigned char *)i50315 == 'z') {
	*i82431 = 26;
    }
    if (*(unsigned char *)i50315 == '_') {
	*i82431 = 64;
    }
    if (*(unsigned char *)i50315 == '(') {
	*i82431 = 65;
    }
    if (*(unsigned char *)i50315 == ')') {
	*i82431 = 66;
    }
    if (*(unsigned char *)i50315 == '+') {
	*i82431 = 67;
    }
    if (*(unsigned char *)i50315 == '-') {
	*i82431 = 68;
    }
    if (*(unsigned char *)i50315 == '&') {
	*i82431 = 69;
    }
    if (*(unsigned char *)i50315 == '.') {
	*i82431 = 70;
    }
    if (*(unsigned char *)i50315 == ',') {
	*i82431 = 71;
    }
    if (*(unsigned char *)i50315 == ':') {
	*i82431 = 72;
    }
    if (*(unsigned char *)i50315 == ';') {
	*i82431 = 73;
    }
    if (*(unsigned char *)i50315 == '*') {
	*i82431 = 74;
    }
    if (*(unsigned char *)i50315 == '=') {
	*i82431 = 75;
    }
    if (*(unsigned char *)i50315 == '/') {
	*i82431 = 76;
    }
    if (*(unsigned char *)i50315 == '!') {
	*i82431 = 80;
    }
    if (*(unsigned char *)i50315 == '[') {
	*i82431 = 83;
    }
    if (*(unsigned char *)i50315 == ']') {
	*i82431 = 84;
    }
    return 0;
} /* o62886010_ */

doublereal o89_(doublereal *s)
{
    /* Initialized data */

    static doublereal a = 0.;
    static doublereal b = 0.;
    static doublereal c__ = 0.;

    /* System generated locals */
    doublereal ret_val;

    if (*s == 1200.) {
	a = .485414306917525406604;
	b = .564807209834307433205;
	c__ = .180868201858223220935;
    }
    *s = a + b + c__;
    if (b < .5) {
	*s += .493127909786063800546;
    }
    if (*s >= 1.) {
	*s += -1.;
    }
    if (*s >= 1.) {
	*s += -1.;
    }
    a = b;
    b = c__;
    c__ = *s;
    *s = a;
    ret_val = *s;
    return ret_val;
} /* o89_ */

/* Subroutine */ int o7100_(integer *i81, integer *i03s, integer *k, integer *
	i64, integer *i03, integer *bi03, integer *di03, integer *di64)
{
    *k = 1;
    *i81 = 2;
    *i03s = 3;
    *i64 = 4;
    *i03 = 5;
    *bi03 = 6;
    *di03 = 7;
    *di64 = 8;
    return 0;
} /* o7100_ */

/* Subroutine */ int o3261853008_(integer *i82431s, char *i6232, ftnlen 
	i6232_len)
{
    static integer i__;
    extern /* Subroutine */ int o6288601_(char *, integer *, ftnlen);

    /* Parameter adjustments */
    --i82431s;

    /* Function Body */
    for (i__ = 1; i__ <= 60; ++i__) {
	o6288601_(i6232 + (i__ - 1), &i82431s[i__], (ftnlen)1);
    }
    return 0;
} /* o3261853008_ */

/* Subroutine */ int o319_(doublereal *i11, doublereal *g, integer *m, 
	integer *me, doublereal *j13)
{
    extern /* Subroutine */ int o21_(doublereal *, doublereal *, integer *, 
	    integer *, doublereal *), o53_(doublereal *, doublereal *, 
	    integer *, integer *, doublereal *);

    /* Parameter adjustments */
    --g;

    /* Function Body */
    *i11 = 0.;
    if (*m == 0) {
	return 0;
    }
    o21_(i11, &g[1], m, me, j13);
    if (*i11 > *j13) {
	o53_(i11, &g[1], m, me, j13);
    }
    return 0;
} /* o319_ */

/* Subroutine */ int o26919_(integer *k, doublereal *j2, integer *lj2, 
	integer *w)
{
    /* System generated locals */
    integer i__1;

    /* Local variables */
    static integer j, i73;

    /* Parameter adjustments */
    --j2;

    /* Function Body */
    i73 = 0;
    i__1 = *k;
    for (j = 1; j <= i__1; ++j) {
	i73 += j;
    }
    i__1 = *k;
    for (j = 1; j <= i__1; ++j) {
	j2[*w + j - 1] = (*k - j + 1) / (doublereal) i73;
    }
    return 0;
} /* o26919_ */

/* Subroutine */ int o24318_(integer *n, integer *nint, doublereal *x, 
	doublereal *j7, doublereal *j9, doublereal *j2, integer *lj2, integer 
	*i37)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1, d__2;

    /* Builtin functions */
    double pow_dd(doublereal *, doublereal *);

    /* Local variables */
    static integer i__;
    extern doublereal o89_(doublereal *);
    static doublereal i130, i82431;
    extern doublereal i9042677836_(doublereal *, doublereal *);

    /* Parameter adjustments */
    --j9;
    --j7;
    --x;
    --j2;

    /* Function Body */
    i__1 = *n - *nint;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i82431 = o89_(&j2[1]);
	if (i82431 <= .5) {
	    x[i__] = j2[*i37 + i__ - 1];
	} else {
	    d__1 = i82431 * 6.;
	    i130 = (j9[i__] - j7[i__]) / pow_dd(&c_b13, &d__1);
	    d__1 = o89_(&j2[1]);
	    d__2 = o89_(&j2[1]);
	    x[i__] = j2[*i37 + i__ - 1] + i130 * i9042677836_(&d__1, &d__2);
	}
    }
    i__1 = *n;
    for (i__ = *n - *nint + 1; i__ <= i__1; ++i__) {
	i82431 = o89_(&j2[1]);
	if (i82431 <= .5) {
	    x[i__] = j2[*i37 + i__ - 1];
	} else {
	    if (i82431 <= .75) {
		x[i__] = j2[*i37 + i__ - 1] + 1.;
	    } else {
		x[i__] = j2[*i37 + i__ - 1] - 1.;
	    }
	}
    }
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (x[i__] < j7[i__]) {
	    x[i__] = j7[i__] + (j7[i__] - x[i__]) / (o89_(&j2[1]) * 1e6);
	    if (x[i__] < j7[i__]) {
		x[i__] = j7[i__];
	    }
	    if (x[i__] > j9[i__]) {
		x[i__] = j9[i__];
	    }
	}
	if (x[i__] > j9[i__]) {
	    x[i__] = j9[i__] - (x[i__] - j9[i__]) / (o89_(&j2[1]) * 1e6);
	    if (x[i__] < j7[i__]) {
		x[i__] = j7[i__];
	    }
	    if (x[i__] > j9[i__]) {
		x[i__] = j9[i__];
	    }
	}
    }
    return 0;
} /* o24318_ */

doublereal i9042677836_(doublereal *i87z679, doublereal *i650012)
{
    /* Initialized data */

    static doublereal i65087210034[30] = { 0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,
	    0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0. };
    static doublereal i087660126578[30] = { 0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,
	    0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0. };
    static integer i__ = 0;

    /* System generated locals */
    doublereal ret_val;

    /* Local variables */
    static integer j;

    if (i__ == 0) {
	i65087210034[0] = .260390290432194637659791;
	i087660126578[0] = .20791169081775939808665;
	i65087210034[1] = .371464322612418407221213;
	i087660126578[1] = .406736643075800319291346;
	i65087210034[2] = .459043605026420720172098;
	i087660126578[2] = .587785252292473248125759;
	i65087210034[3] = .534978211968811456777928;
	i087660126578[3] = .743144825477394466162195;
	i65087210034[4] = .603856865149274613102648;
	i087660126578[4] = .866025403784438818632907;
	i65087210034[5] = .668047230836577465851178;
	i087660126578[5] = .951056516295153642204241;
	i65087210034[6] = .728976221468170537676201;
	i087660126578[6] = .994521895368273400883652;
	i65087210034[7] = .7875975219664415050147;
	i087660126578[7] = .994521895368273178839047;
	i65087210034[8] = .84460043090059155890259;
	i087660126578[8] = .951056516295153198115031;
	i65087210034[9] = .900516638500549193580014;
	i087660126578[9] = .866025403784437819432185;
	i65087210034[10] = .955780730602699413189782;
	i087660126578[10] = .743144825477393355939171;
	i65087210034[11] = 1.01076765259478973391083;
	i087660126578[11] = .587785252292471804835827;
	i65087210034[12] = 1.06581803100335958944811;
	i087660126578[12] = .406736643075798820490263;
	i65087210034[13] = 1.12125702621867584518611;
	i087660126578[13] = .20791169081775756621866;
	i65087210034[14] = 1.17741002251547466350701;
	i087660126578[14] = -.0165389215948551511930853;
	i65087210034[15] = 1.23461739178329787947064;
	i087660126578[15] = -.207911690817760813621007;
	i65087210034[16] = 1.29325018786050716101954;
	i087660126578[16] = -.40673664307580181809243;
	i65087210034[17] = 1.35372872605567096115919;
	i087660126578[17] = -.587785252292474469371086;
	i65087210034[18] = 1.41654658155938162344967;
	i087660126578[18] = -.743144825477395465362918;
	i65087210034[19] = 1.48230380736751121695249;
	i087660126578[19] = -.866025403784440150900537;
	i65087210034[20] = 1.55175565365552059482468;
	i087660126578[20] = -.951056516295154086293451;
	i65087210034[21] = 1.62588796660921230952113;
	i087660126578[21] = -.994521895368273622928257;
	i65087210034[22] = 1.70604058135018687991646;
	i087660126578[22] = -.994521895368273067816745;
	i65087210034[23] = 1.79412257799410146397179;
	i087660126578[23] = -.951056516295152531981216;
	i65087210034[24] = 1.89301847282484558832039;
	i087660126578[24] = -.866025403784437264320673;
	i65087210034[25] = 2.00743768049833359867762;
	i087660126578[25] = -.743144825477392245716146;
	i65087210034[26] = 2.1459660262893471838197;
	i087660126578[26] = -.587785252292470472568198;
	i65087210034[27] = 2.3272516843273356457189;
	i087660126578[27] = -.40673664307579687759997;
	i65087210034[28] = 2.60814009656772682888004;
	i087660126578[28] = -.207911690817756372728908;
	i65087210034[29] = 2.90814009656772682888004;
	i087660126578[29] = -.107911690817756372728908;
    }
    i__ = (integer) (*i87z679 * 30);
    j = (integer) (*i650012 * 30);
    if (i__ < 1) {
	i__ = 1;
    }
    if (j < 1) {
	j = 1;
    }
    ret_val = i65087210034[i__ - 1] * i087660126578[j - 1];
    return ret_val;
} /* i9042677836_ */

/* Subroutine */ int midaco_code__(integer *l, integer *n, integer *nint, 
	integer *m, integer *me, doublereal *x, doublereal *f, doublereal *g, 
	doublereal *j7, doublereal *j9, doublereal *j13, integer *i3108, 
	integer *i4108, doublereal *i7193, doublereal *j2, integer *lj2, 
	integer *j6, integer *lj6, char *i31032, integer *j609, doublereal *p,
	 doublereal *i11, ftnlen i31032_len)
{
    /* Initialized data */

    static integer i6193 = 0;
    static integer i0311 = 0;
    static integer i432i11 = 0;
    static integer i2098473 = 0;
    static integer i3655401800 = 0;
    static integer i2310315 = 0;
    static integer i321i1403 = 0;
    static integer i31579907326 = 0;
    static doublereal i78923[11] = { 0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0. };
    static doublereal i78913[18] = { 0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,
	    0.,0.,0.,0.,0. };
    static doublereal i8250 = 0.;
    static doublereal i083261 = 0.;
    static integer i813 = 0;
    static integer i41981820 = 0;
    static integer i03629661 = 0;
    static integer i48213 = 0;
    static integer i824 = 0;
    static integer i2419 = 0;
    static integer i2134 = 0;
    static integer i87621 = 0;
    static integer i0009 = 0;
    static integer i5308 = 0;
    static integer i81i1403 = 0;
    static integer i30251 = 0;
    static integer i3193 = 0;

    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1, d__2;

    /* Builtin functions */
    double pow_dd(doublereal *, doublereal *), sqrt(doublereal), d_nint(
	    doublereal *);

    /* Local variables */
    static integer c__, i__, j;
    extern doublereal o89_(doublereal *);
    static doublereal i130;
    extern /* Subroutine */ int o319_(doublereal *, doublereal *, integer *, 
	    integer *, doublereal *);
    static logical i0087;
    static integer i5542, i71904, i98320, i619307, ii30919;
    extern /* Subroutine */ int o9953052_(doublereal *, doublereal *, integer 
	    *), o62886010_(char *, integer *, ftnlen), i074206156_(integer *, 
	    integer *, integer *, integer *, integer *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, integer *, integer *, doublereal *, doublereal *, 
	    integer *, integer *, integer *, integer *, integer *, integer *, 
	    doublereal *, doublereal *, char *, integer *, ftnlen);
    static integer i087676578;
    extern /* Subroutine */ int o3261853008_(integer *, char *, ftnlen);
    extern doublereal i9042677836_(doublereal *, doublereal *);
    extern /* Subroutine */ int o213659807013_(integer *, integer *, integer *
	    , integer *, integer *, doublereal *, doublereal *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, integer *, integer *, 
	    integer *, logical *, integer *, doublereal *, integer *, integer 
	    *, integer *, integer *, doublereal *, integer *, doublereal *, 
	    doublereal *, doublereal *, doublereal *, doublereal *, integer *,
	     integer *, char *, ftnlen);

    /* Parameter adjustments */
    --f;
    --j9;
    --j7;
    --x;
    --g;
    --i7193;
    --j2;
    --j6;
    --i11;
    --p;

    /* Function Body */
    if (*i3108 >= 0) {
	i48213 = 0;
	i824 = 0;
	if (*i3108 > 10 && *i3108 < 100) {
	    *i3108 = -3;
	    i31579907326 = 0;
	    goto L79;
	}
	for (i__ = 1; i__ <= 60; ++i__) {
	    o62886010_(i31032 + (i__ - 1), &j6[i__], (ftnlen)1);
	}
	i71904 = 0;
	for (i__ = 1; i__ <= 10; ++i__) {
	    i71904 -= j6[i__];
	}
	for (i__ = 10; i__ <= 60; ++i__) {
	    i71904 += j6[i__];
	}
	i619307 = 1687;
	if (i71904 != i619307) {
	    *i3108 = 900;
	    return 0;
	}
	o3261853008_(&j6[1], i31032, (ftnlen)60);
	if ((integer) i7193[7] == 1) {
	    goto L51;
	}
	if ((integer) i7193[7] == 2) {
	    goto L52;
	}
	if ((integer) i7193[7] == 3) {
	    goto L53;
	}
L51:
	if (*nint == *n || (integer) i7193[7] > 0) {
	    if (*n <= 50) {
		i78923[0] = .389078763191433141;
		i78923[1] = .114860512107443344;
		i78923[2] = 1.13443339033864277;
		i78923[3] = .518799365371665044;
		i78923[4] = 432539059.007058501;
		i78923[5] = .00100089252383195868;
		i78923[6] = .999999999459014188;
		i78923[7] = 39.783101606317949;
		i78923[8] = .00389801369146012405;
		i78923[9] = 1.55844656119642398e-7;
		i78923[10] = .623332071588316938;
		i78913[0] = 2.;
		i78913[1] = 10.;
		i78913[2] = 99.;
		i78913[3] = 148.;
		i78913[4] = 49.;
		i78913[5] = 5.;
		i78913[6] = 11.;
		i78913[7] = 8.;
		i78913[8] = 89.;
		i78913[9] = 4.;
		i78913[10] = 2.;
		i78913[11] = 8.;
		i78913[12] = 9.;
		i78913[13] = 0.;
		i78913[14] = 276507832.;
		i78913[15] = 2.;
		i78913[16] = 1.;
		i78913[17] = 124764362584.;
	    } else {
		i78923[0] = .24215815586423689;
		i78923[1] = .703454504998440644;
		i78923[2] = 1.07467917008615577;
		i78923[3] = .758136520883294196;
		i78923[4] = 588648485.98217082;
		i78923[5] = 151.615115132434426;
		i78923[6] = .882788933354880179;
		i78923[7] = 31.8417239075448286;
		i78923[8] = 1.00000000583138296e-8;
		i78923[9] = 1.39392038646105073e-7;
		i78923[10] = .548565908377584011;
		i78913[0] = 2.;
		i78913[1] = 10.;
		i78913[2] = 575.;
		i78913[3] = 10.;
		i78913[4] = 1e3;
		i78913[5] = 4.;
		i78913[6] = 6.;
		i78913[7] = 11.;
		i78913[8] = 94.;
		i78913[9] = 1.;
		i78913[10] = 3.;
		i78913[11] = 8.;
		i78913[12] = 12.;
		i78913[13] = 1.;
		i78913[14] = 421740554.;
		i78913[15] = 72.;
		i78913[16] = 18.;
		i78913[17] = 32537675213.;
	    }
	    goto L54;
	}
L52:
	if (*nint == 0 || (integer) i7193[7] > 0) {
	    if (*n <= 50) {
		i78923[0] = 2.49122144659019495;
		i78923[1] = .844388223088001766;
		i78923[2] = 1.00153091583909348;
		i78923[3] = 1.43961720122020398;
		i78923[4] = 25832469.9287332147;
		i78923[5] = 943.969219703401563;
		i78923[6] = 9.73372517527523608e-8;
		i78923[7] = .694079968011245829;
		i78923[8] = .0842177534294979019;
		i78923[9] = 2.75806030201900532;
		i78923[10] = .324049619462284;
		i78913[0] = 2.;
		i78913[1] = 10.;
		i78913[2] = 343.;
		i78913[3] = 315.;
		i78913[4] = 401.;
		i78913[5] = 2.;
		i78913[6] = 9.;
		i78913[7] = 5.;
		i78913[8] = 16.;
		i78913[9] = 1.;
		i78913[10] = 2.;
		i78913[11] = 6.;
		i78913[12] = 4.;
		i78913[13] = 0.;
		i78913[14] = 983025185.;
		i78913[15] = 6.;
		i78913[16] = 27.;
		i78913[17] = 904969100.;
	    } else {
		i78923[0] = 1.18876691512506394;
		i78923[1] = .60754462362992212;
		i78923[2] = 1.23970349748770015;
		i78923[3] = 1.18509064728880364;
		i78923[4] = 34869975.8754453659;
		i78923[5] = 997.16196017831146;
		i78923[6] = 6.02039328669455594e-8;
		i78923[7] = 5.05753968641715979;
		i78923[8] = .790696417057785483;
		i78923[9] = 2.10656581785541874;
		i78923[10] = .349012629457182089;
		i78913[0] = 2.;
		i78913[1] = 10.;
		i78913[2] = 490.;
		i78913[3] = 13.;
		i78913[4] = 649.;
		i78913[5] = 2.;
		i78913[6] = 25.;
		i78913[7] = 11.;
		i78913[8] = 4.;
		i78913[9] = 1.;
		i78913[10] = 2.;
		i78913[11] = 6.;
		i78913[12] = 7.;
		i78913[13] = 0.;
		i78913[14] = 603379230.;
		i78913[15] = 5.;
		i78913[16] = 29.;
		i78913[17] = 800782976.;
	    }
	    goto L54;
	}
L53:
	if (*nint > 0 && *nint < *n || (integer) i7193[7] > 0) {
	    if (*n <= 50) {
		i78923[0] = .739291508632072047;
		i78923[1] = .633998424333021782;
		i78923[2] = 1.03299237259922405;
		i78923[3] = 1.46764290556402521;
		i78923[4] = 687162903.769587874;
		i78923[5] = 20.5802915797508632;
		i78923[6] = 6.4639580093497828e-9;
		i78923[7] = .63296163789172033;
		i78923[8] = 1.65635296752857508;
		i78923[9] = .0107013907618447555;
		i78923[10] = .697751367495330399;
		i78913[0] = 2.;
		i78913[1] = 10.;
		i78913[2] = 136.;
		i78913[3] = 161.;
		i78913[4] = 18.;
		i78913[5] = 2.;
		i78913[6] = 10.;
		i78913[7] = 2.;
		i78913[8] = 40.;
		i78913[9] = 2.;
		i78913[10] = 2.;
		i78913[11] = 5.;
		i78913[12] = 5.;
		i78913[13] = 1.;
		i78913[14] = 364827196.;
		i78913[15] = 13.;
		i78913[16] = 23.;
		i78913[17] = 886844425.;
	    } else {
		i78923[0] = .977028227081946476;
		i78923[1] = .817716107310876406;
		i78923[2] = 1.02176946317372175;
		i78923[3] = 1.41568482802071527;
		i78923[4] = 507710667.821344793;
		i78923[5] = 2.48657903658426616;
		i78923[6] = 4.42148199129617578e-8;
		i78923[7] = 1.96339623453502687;
		i78923[8] = 2.26706133235036811;
		i78923[9] = 1.21920904983831223e-7;
		i78923[10] = .30500886716797565;
		i78913[0] = 2.;
		i78913[1] = 10.;
		i78913[2] = 332.;
		i78913[3] = 863.;
		i78913[4] = 23.;
		i78913[5] = 3.;
		i78913[6] = 12.;
		i78913[7] = 2.;
		i78913[8] = 16.;
		i78913[9] = 1.;
		i78913[10] = 4.;
		i78913[11] = 6.;
		i78913[12] = 7.;
		i78913[13] = 1.;
		i78913[14] = 705433041.;
		i78913[15] = 9.;
		i78913[16] = 21.;
		i78913[17] = 843575111.;
	    }
	    goto L54;
	}
L54:
	i98320 = 1000;
	ii30919 = -365;
	for (i__ = 30; i__ <= 60; ++i__) {
	    i98320 -= j6[i__];
	}
	if (i98320 != ii30919) {
	    *i3108 = -1;
	    return 0;
	}
	i03629661 = 0;
	i074206156_(l, n, nint, m, me, &x[1], &f[1], &g[1], &j7[1], &j9[1], 
		j13, i3108, i4108, &i7193[1], &j2[1], lj2, &j6[1], lj6, &i813,
		 &i0009, &i5308, i78913, &i78913[1], i31032, &i31579907326, (
		ftnlen)60);
	if (*i3108 >= 100) {
	    goto L86;
	}
	if (i31579907326 == 1) {
	    i087676578 = *i3108;
	    *i3108 = 0;
	}
	i03629661 = 1;
	i5542 = (integer) i7193[1];
	i2310315 = (integer) i7193[3];
	i8250 = 1e16;
	i083261 = 1e16;
	i3193 = 1;
	i6193 = i3193 + *n;
	i0311 = i6193 + 1;
	i432i11 = i0311 + *m;
	i87621 = i432i11 + 1;
	i__1 = *n;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j2[i0009 + i3193 + i__ - 1] = x[i__];
	}
	i__1 = *m;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j2[i0009 + i0311 + i__ - 1] = g[i__];
	}
	j2[i0009 + i6193] = f[1];
	o319_(&j2[i0009 + i432i11], &g[1], m, me, j13);
	i81i1403 = 0;
	i3655401800 = 0;
	i2134 = i5542;
	i2419 = 0;
	i41981820 = 1;
	if (j2[i0009 + i432i11] > *j13) {
	    if (i7193[4] == 0.) {
		j2[i0009 + i87621] = j2[i0009 + i6193] + 1e9;
	    } else {
		j2[i0009 + i87621] = i7193[4];
	    }
	} else {
	    j2[i0009 + i87621] = j2[i0009 + i6193];
	}
    } else {
	if (i03629661 != 1) {
	    *i3108 = 701;
	    *i4108 = 1;
	    return 0;
	}
	i__1 = *l;
	for (c__ = 1; c__ <= i__1; ++c__) {
	    o9953052_(&f[c__], &g[(c__ - 1) * *m + 1], m);
	}
    }
L79:
    if (*i3108 == -300) {
	i2419 = 0;
	++i2134;
    }
    if (*i4108 == 0) {
	i0087 = FALSE_;
    } else {
	i0087 = TRUE_;
    }
    o213659807013_(l, n, nint, m, me, &x[1], &f[1], &g[1], &j7[1], &j9[1], 
	    j13, &i48213, &i824, &i2419, &i0087, &i2134, &j2[1], lj2, &j6[1], 
	    lj6, &i813, &j2[i0009 + i87621], &i41981820, i78923, i78913, &
	    i7193[1], &p[1], &i11[1], j609, &i5308, i31032, (ftnlen)60);
    *i3108 = i2419;
    if (*i3108 == 801) {
	return 0;
    }
    if (i0087) {
	if (j2[i0009 + i432i11] > *j13 && j2[*n + 3 + *m] < j2[i0009 + 
		i432i11]) {
	    goto L1;
	}
	if (j2[i0009 + i432i11] <= *j13 && j2[*n + 3 + *m] <= *j13 && j2[*n + 
		2] < j2[i0009 + i6193]) {
	    goto L1;
	}
	goto L3;
    }
    if (i2419 == -3) {
	++i81i1403;
    }
    i30251 = (integer) i78913[5] * *n + (integer) i78913[6];
    if (i81i1403 >= i30251) {
	++i3655401800;
	if (j2[i0009 + i432i11] > *j13 && j2[*n + 3 + *m] < j2[i0009 + 
		i432i11]) {
	    goto L11;
	}
	if (j2[i0009 + i432i11] <= *j13 && j2[*n + 3 + *m] <= *j13 && j2[*n + 
		2] < j2[i0009 + i6193]) {
	    goto L11;
	}
	goto L12;
L11:
	j2[i0009 + i6193] = j2[*n + 2];
	j2[i0009 + i432i11] = j2[*n + 3 + *m];
	i__1 = *n;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j2[i0009 + i3193 + i__ - 1] = j2[i__ + 1];
	}
	i__1 = *m;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j2[i0009 + i0311 + i__ - 1] = j2[*n + 3 + i__ - 1];
	}
	if (j2[i0009 + i432i11] <= *j13) {
	    j2[i0009 + i87621] = j2[i0009 + i6193];
	}
	i2098473 = 1;
	goto L13;
L12:
	i2098473 = 0;
L13:
	i__1 = i0009;
	for (i__ = 2; i__ <= i__1; ++i__) {
	    j2[i__] = 0.;
	}
	i__1 = i5308;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j6[i__] = 0;
	}
	i__1 = *l;
	for (c__ = 1; c__ <= i__1; ++c__) {
	    i__2 = *n;
	    for (i__ = 1; i__ <= i__2; ++i__) {
		if (*n <= *n - *nint) {
		    i130 = (j9[i__] - j7[i__]) / (o89_(&j2[1]) * pow_dd(&
			    c_b13, &i78913[16]));
		}
		if (*n > *n - *nint) {
		    i130 = (j9[i__] - j7[i__]) / i78913[17];
		}
		if (i__ > *n - *nint && i130 < i78923[10]) {
		    i130 = i78923[10];
		}
		if (i7193[2] > 0.) {
		    if (i__ <= *n - *nint) {
			i130 = (j9[i__] - j7[i__]) / i7193[2];
		    } else {
			i130 = 1. / sqrt(i7193[2]);
		    }
		}
		d__1 = o89_(&j2[1]);
		d__2 = o89_(&j2[1]);
		x[i__] = j2[i0009 + i3193 + i__ - 1] + i130 * i9042677836_(&
			d__1, &d__2);
		if (x[i__] < j7[i__]) {
		    x[i__] = j7[i__] + (j7[i__] - x[i__]) / i78923[4];
		}
		if (x[i__] > j9[i__]) {
		    x[i__] = j9[i__] - (x[i__] - j9[i__]) / i78923[4];
		}
		if (x[i__] < j7[i__]) {
		    x[i__] = j7[i__];
		}
		if (x[i__] > j9[i__]) {
		    x[i__] = j9[i__];
		}
		if (i__ > *n - *nint) {
		    x[i__] = d_nint(&x[i__]);
		}
	    }
	}
	i41981820 *= (integer) i78913[7];
	if (i41981820 > (integer) i78913[8]) {
	    i41981820 = 1;
	}
	*i3108 = -300;
	i81i1403 = 0;
	if (i2310315 > 0) {
	    if (i8250 == 1e16) {
		i321i1403 = 0;
		i8250 = j2[i0009 + i6193];
		i083261 = j2[i0009 + i432i11];
	    } else {
		if (j2[i0009 + i432i11] <= i083261) {
		    if (i083261 <= *j13) {
			if (j2[i0009 + i6193] < i8250 - (d__1 = i8250 / 1e6, 
				abs(d__1))) {
			    i8250 = j2[i0009 + i6193];
			    i083261 = j2[i0009 + i432i11];
			    i321i1403 = 0;
			} else {
			    ++i321i1403;
			    goto L76;
			}
		    } else {
			i321i1403 = 0;
			i8250 = j2[i0009 + i6193];
			i083261 = j2[i0009 + i432i11];
		    }
		} else {
		    ++i321i1403;
		    goto L76;
		}
	    }
L76:
	    if (i321i1403 >= i2310315) {
		if (j2[i0009 + i432i11] <= *j13) {
		    *i3108 = 3;
		} else {
		    *i3108 = 4;
		}
		goto L3;
	    }
	}
    }
    if (i31579907326 == 1) {
	*i3108 = i087676578;
    }
L4:
    return 0;
L1:
    j2[i0009 + i6193] = j2[*n + 2];
    j2[i0009 + i432i11] = j2[*n + 3 + *m];
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	j2[i0009 + i3193 + i__ - 1] = j2[i__ + 1];
    }
    i__1 = *m;
    for (i__ = 1; i__ <= i__1; ++i__) {
	j2[i0009 + i0311 + i__ - 1] = j2[*n + 3 + i__ - 1];
    }
    if (j2[i0009 + i432i11] <= *j13) {
	j2[i0009 + i87621] = j2[i0009 + i6193];
    }
    i2098473 = 1;
L3:
    f[1] = j2[i0009 + i6193];
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	x[i__] = j2[i0009 + i3193 + i__ - 1];
    }
    i__1 = *m;
    for (i__ = 1; i__ <= i__1; ++i__) {
	g[i__] = j2[i0009 + i0311 + i__ - 1];
    }
    if (*i3108 != 3 && *i3108 != 4) {
	if (j2[i0009 + i432i11] <= *j13) {
	    *i3108 = 1;
	} else {
	    *i3108 = 2;
	}
    }
    *i4108 = 1;
L86:
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (x[i__] > j9[i__]) {
	    j7[i__] = 91.;
	    goto L87;
	}
	if (x[i__] < j7[i__]) {
	    j7[i__] = 92.;
	    goto L87;
	}
	if (j7[i__] > j9[i__]) {
	    j7[i__] = 93.;
	    goto L87;
	}
	if (j7[i__] == j9[i__]) {
	    j7[i__] = 90.;
	    goto L87;
	}
	if ((d__1 = x[i__] - j7[i__], abs(d__1)) <= (j9[i__] - j7[i__]) / 1e3)
		 {
	    j7[i__] = 0.;
	    goto L87;
	}
	if ((d__1 = x[i__] - j9[i__], abs(d__1)) <= (j9[i__] - j7[i__]) / 1e3)
		 {
	    j7[i__] = 22.;
	    goto L87;
	}
	for (j = 1; j <= 21; ++j) {
	    if (x[i__] <= j7[i__] + j * (j9[i__] - j7[i__]) / 21.) {
		j7[i__] = (doublereal) j;
		goto L87;
	    }
	}
L87:
	;
    }
    if (*i3108 > 100) {
	goto L4;
    }
    j9[1] = -123861.;
    i__1 = *n;
    for (i__ = 2; i__ <= i__1; ++i__) {
	j9[i__] = j9[1] * 2. * o89_(&j2[1]);
    }
    goto L4;
} /* midaco_code__ */

/* Subroutine */ int o1309_(integer *n, integer *nint, doublereal *x, 
	doublereal *j7, doublereal *j9, doublereal *j2, integer *lj2)
{
    /* System generated locals */
    integer i__1;

    /* Builtin functions */
    double d_nint(doublereal *);

    /* Local variables */
    static integer i__;
    extern doublereal o89_(doublereal *);

    /* Parameter adjustments */
    --j9;
    --j7;
    --x;
    --j2;

    /* Function Body */
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	x[i__] = j7[i__] + o89_(&j2[1]) * (j9[i__] - j7[i__]);
	if (i__ > *n - *nint) {
	    x[i__] = d_nint(&x[i__]);
	}
    }
    return 0;
} /* o1309_ */

/* Subroutine */ int o95420_(integer *n, integer *nint, integer *k, 
	doublereal *x, doublereal *j7, doublereal *j9, doublereal *j2, 
	integer *lj2, integer *i37, integer *i8087, integer *pt, doublereal *
	u1)
{
    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1;

    /* Builtin functions */
    double d_nint(doublereal *);

    /* Local variables */
    static integer i__, j;
    extern doublereal o89_(doublereal *);
    static doublereal i82431;
    extern doublereal i9042677836_(doublereal *, doublereal *);

    /* Parameter adjustments */
    --j9;
    --j7;
    --x;
    --j2;

    /* Function Body */
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i82431 = o89_(&j2[1]);
	i__2 = *k;
	for (j = 1; j <= i__2; ++j) {
	    if (i82431 > j2[*pt + j - 1]) {
	    } else {
		goto L456;
	    }
	}
L456:
	d__1 = o89_(&j2[1]);
	x[i__] = j2[*i37 + (j - 2) * *n + i__ - 1] + j2[*i8087 + i__ - 1] * 
		i9042677836_(&i82431, &d__1);
	if (x[i__] < j7[i__]) {
	    x[i__] = j7[i__] + (j7[i__] - x[i__]) / *u1;
	    if (x[i__] < j7[i__]) {
		x[i__] = j7[i__];
	    }
	    if (x[i__] > j9[i__]) {
		x[i__] = j9[i__];
	    }
	}
	if (x[i__] > j9[i__]) {
	    x[i__] = j9[i__] - (x[i__] - j9[i__]) / *u1;
	    if (x[i__] < j7[i__]) {
		x[i__] = j7[i__];
	    }
	    if (x[i__] > j9[i__]) {
		x[i__] = j9[i__];
	    }
	}
	if (i__ > *n - *nint) {
	    x[i__] = d_nint(&x[i__]);
	}
    }
    return 0;
} /* o95420_ */

/* Subroutine */ int o32481_(integer *n, integer *nint, doublereal *x, 
	doublereal *j7, doublereal *j9, doublereal *j2, integer *lj2, integer 
	*i86x, doublereal *i13509)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1, d__2;

    /* Builtin functions */
    double sqrt(doublereal), d_nint(doublereal *);

    /* Local variables */
    static integer i__;
    extern doublereal o89_(doublereal *);
    static doublereal i130;
    extern doublereal i9042677836_(doublereal *, doublereal *);

    /* Parameter adjustments */
    --j9;
    --j7;
    --x;
    --j2;

    /* Function Body */
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	i130 = (j9[i__] - j7[i__]) / *i13509;
	if (i__ > *n - *nint) {
	    if (i130 < 1. / sqrt(*i13509)) {
		i130 = 1. / sqrt(*i13509);
	    }
	}
	d__1 = o89_(&j2[1]);
	d__2 = o89_(&j2[1]);
	x[i__] = j2[*i86x + i__ - 1] + i130 * i9042677836_(&d__1, &d__2);
	if (x[i__] < j7[i__]) {
	    x[i__] = j7[i__] + (j7[i__] - x[i__]) / (o89_(&j2[1]) * 1e6);
	    if (x[i__] < j7[i__]) {
		x[i__] = j7[i__];
	    }
	    if (x[i__] > j9[i__]) {
		x[i__] = j9[i__];
	    }
	}
	if (x[i__] > j9[i__]) {
	    x[i__] = j9[i__] - (x[i__] - j9[i__]) / (o89_(&j2[1]) * 1e6);
	    if (x[i__] < j7[i__]) {
		x[i__] = j7[i__];
	    }
	    if (x[i__] > j9[i__]) {
		x[i__] = j9[i__];
	    }
	}
	if (i__ > *n - *nint) {
	    x[i__] = d_nint(&x[i__]);
	}
    }
    return 0;
} /* o32481_ */

/* Subroutine */ int o158_(integer *l, integer *n, integer *nint, doublereal *
	x, doublereal *j7, doublereal *j9, integer *i37, integer *i8087, 
	integer *i5308, doublereal *j2, integer *lj2, integer *j6, integer *
	lj6, integer *i3108, integer *i9025120, doublereal *da, doublereal *
	db, doublereal *ca)
{
    /* Initialized data */

    static integer i21 = 0;
    static integer i8250 = 0;
    static integer i507 = 0;
    static integer i209081 = 0;
    static integer i4102 = 0;
    static integer i0814 = 0;
    static integer i13408 = 0;
    static integer i325 = 0;
    static integer i86 = 0;
    static integer i70319301 = 0;
    static doublereal i130 = 0.;

    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    double sqrt(doublereal), d_nint(doublereal *);

    /* Local variables */
    static integer i__, j;
    extern doublereal o89_(doublereal *);
    extern integer o13218_(doublereal *);
    static integer i41096533;

    /* Parameter adjustments */
    --j9;
    --j7;
    --x;
    --j2;
    --j6;

    /* Function Body */
    if (*i3108 == -30) {
	i21 = 0;
	i8250 = *l + 32;
	i209081 = 873;
	i__1 = *n;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    d__1 = i__ * o89_(&j2[1]);
	    j = o13218_(&d__1) + 1;
	    j6[i8250 + i__ - 1] = j6[i8250 + j - 1];
	    j6[i8250 + j - 1] = i__;
	}
	i4102 = j6[*i5308 + 1];
	for (i__ = 1; i__ <= 25; ++i__) {
	    i4102 += j6[*i5308 + (i__ << 1)];
	}
	j6[31] = 1;
	i70319301 = i8250 + *n;
	i325 = i70319301;
	i70319301 = 1007;
	i__1 = *n;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    j6[i325 + i__ - 1] = 0;
	}
    }
    i41096533 = 0;
    if (j6[31] == 0) {
	i86 = j6[i8250 + i21 - 1];
	j6[30] = i86;
	++i0814;
	i507 = -i507;
	i130 /= *da;
	if (i130 < *db) {
	    i130 = *db;
	}
	if (i86 > *n - *nint && i0814 > i13408) {
	    j6[i325 + i86 - 1] = 1;
	    if (i21 >= *n) {
		goto L2;
	    }
	    i41096533 = 1;
	}
	if (i86 <= *n - *nint && i0814 > (integer) (*ca)) {
	    j6[i325 + i86 - 1] = 1;
	    if (i21 >= *n) {
		goto L2;
	    }
	    i41096533 = 1;
	}
	if ((d__1 = j7[i86] - j9[i86], abs(d__1)) <= 1e-12) {
	    j6[i325 + i86 - 1] = 1;
	    if (i21 >= *n) {
		goto L2;
	    }
	    i41096533 = 1;
	}
    }
    if (j6[31] == 1 || i41096533 == 1) {
	++i21;
	if (i21 > *n) {
	    goto L2;
	}
	i86 = j6[i8250 + i21 - 1];
	j6[30] = i86;
	i0814 = 1;
	if (i86 > *n - *nint) {
	    if (j2[*i37 + i86 - 1] == j7[i86] || j2[*i37 + i86 - 1] == j9[i86]
		    ) {
		i13408 = 1;
	    } else {
		i13408 = 2;
	    }
	}
	if (o89_(&j2[1]) >= .5) {
	    i507 = 1;
	} else {
	    i507 = -1;
	}
	i130 = sqrt(j2[*i8087 + i86 - 1]);
    }
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	x[i__] = j2[*i37 + i__ - 1];
    }
    if (i86 <= *n - *nint) {
	x[i86] += i507 * i130;
    } else {
	x[i86] += i507;
	if (x[i86] < j7[i86]) {
	    x[i86] = j7[i86] + 1;
	}
	if (x[i86] > j9[i86]) {
	    x[i86] = j9[i86] - 1;
	}
    }
    if (i209081 != i4102) {
	i__1 = *n;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    d__1 = i__ * o89_(&j2[1]);
	    j = o13218_(&d__1) + 1;
	    j6[i__ + 1] = j6[j + 1];
	    j6[j + 1] = i__;
	}
    }
    if (x[i86] < j7[i86]) {
	x[i86] = j7[i86];
    }
    if (x[i86] > j9[i86]) {
	x[i86] = j9[i86];
    }
    if (i86 > *n - *nint) {
	x[i86] = d_nint(&x[i86]);
    }
    if (i21 == 1 && i0814 == 1) {
	*i3108 = -30;
    } else {
	*i3108 = -31;
    }
    return 0;
L2:
    *i3108 = -40;
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	if (j6[i325 + i__ - 1] == 0) {
	    goto L22;
	}
    }
    *i9025120 = 1;
    *i3108 = -99;
L22:
    return 0;
} /* o158_ */

integer o13218_(doublereal *x)
{
    /* System generated locals */
    integer ret_val;

    ret_val = (integer) (*x);
    if ((doublereal) ret_val > *x) {
	--ret_val;
    }
    return ret_val;
}
#ifdef KR_headers
double pow();
double pow_dd(ap, bp) doublereal *ap, *bp;
#else
#undef abs
#include "math.h"
#ifdef __cplusplus
extern "C" {
#endif
double pow_dd(doublereal *ap, doublereal *bp)
#endif
{
return(pow(*ap, *bp) );
}
#ifdef __cplusplus
}
#endif

double d_nint(x)
doublereal *x;
{
double floor();

return( (*x)>=0 ?
	floor(*x + .5) : -floor(.5 - *x) );
}

#ifdef __cplusplus
extern "C" {
#endif

#ifdef KR_headers
double pow_di(ap, bp) doublereal *ap; integer *bp;
#else
double pow_di(doublereal *ap, integer *bp)
#endif
{
double pow, x;
integer n;
unsigned long u;

pow = 1;
x = *ap;
n = *bp;

if(n != 0)
	{
	if(n < 0)
		{
		n = -n;
		x = 1/x;
		}
	for(u = n; ; )
		{
		if(u & 01)
			pow *= x;
		if(u >>= 1)
			x *= x;
		else
			break;
		}
	}
return(pow);
}
#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef KR_headers
integer pow_ii(ap, bp) integer *ap, *bp;
#else
integer pow_ii(integer *ap, integer *bp)
#endif
{
	integer pow, x, n;
	unsigned long u;

	x = *ap;
	n = *bp;

	if (n <= 0) {
		if (n == 0 || x == 1)
			return 1;
		if (x != -1)
			return x == 0 ? 1/x : 0;
		n = -n;
		}
	u = n;
	for(pow = 1; ; )
		{
		if(u & 01)
			pow *= x;
		if(u >>= 1)
			x *= x;
		else
			break;
		}
	return(pow);
	}
#ifdef __cplusplus
}
#endif












