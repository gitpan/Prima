/*-
 * Copyright (c) 1997-2002 The Protein Laboratory, University of Copenhagen
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/* $Id$ */

#ifndef _APRICOT_H_
#define _APRICOT_H_

#define PRIMA_CORE 1
#ifdef PRIMA_CORE
#define POLLUTE_NAME_SPACE 1
#endif

#if defined( HAVE_CONFIG_H)
#include "generic/config.h"
#endif

#if (PERL_PATCHLEVEL < 4 || (( PERL_PATCHLEVEL == 4) && ( PERL_SUBVERSION <= 4)))
#error "Prima require at least perl 5.005"
#endif

/* #define PARANOID_MALLOC */

#ifdef _MSC_VER
   #define BROKEN_COMPILER       1
   #define BROKEN_PERL_PLATFORM  1
   #define snprintf              _snprintf
   #define vsnprintf             _vsnprintf
   #define stricmp               _stricmp
   #define strnicmp              _strnicmp
   #define HAVE_SNPRINTF         1
   #define HAVE_STRICMP          1
   #define HAVE_STRNICMP         1
#elif defined( __BORLANDC__)
   #define BROKEN_PERL_PLATFORM  1
   #define BROKEN_COMPILER       1
#elif defined(WIN32)
   #define BROKEN_PERL_PLATFORM  1
#endif

#ifdef WORD
#error "Reconsider the order in which you #include files"
#endif

#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif
#ifdef HAVE_SYS_BITYPES_H
#include <sys/bitypes.h>
#endif
#ifdef HAVE_SYS_INTTYPES_H
#include <sys/inttypes.h>
#endif
#ifdef HAVE_STDINT_H
#include <stdint.h>
#endif
#define __XSlock_h__ 28
#include <EXTERN.h>
#include <perl.h>
#ifdef REMOVE_dTHR_FROM_dSP
#undef dSP
#define dSP                djSP
#endif
#include <XSUB.h>

#ifdef PERL_OBJECT
   #define XS_STARTPARAMS   CV* cv, CPerlObj* pPerl
   #define XS_CALLPARAMS    cv, pPerl
#else
   #define XS_STARTPARAMS   CV* cv
   #define XS_CALLPARAMS    cv
#endif

#if defined(_MSC_VER) && defined(PERL_OBJECT)
class XSLockManager
{
public:
        XSLockManager() { InitializeCriticalSection(&cs); };
        ~XSLockManager() { DeleteCriticalSection(&cs); };
        void Enter(void) { EnterCriticalSection(&cs); };
        void Leave(void) { LeaveCriticalSection(&cs); };
protected:
        CRITICAL_SECTION cs;
};

extern XSLockManager g_XSLock;
extern CPerlObj* pPerl;

class XSLock
{
public:
        XSLock(CPerlObj *p) {
            g_XSLock.Enter();
            ::pPerl = p;
        };
        ~XSLock() { g_XSLock.Leave(); };
};

/* PERL_CAPI does its own locking in xs_handler() */
#if defined(PERL_OBJECT) && !defined(PERL_CAPI)
#undef dXSARGS
#define dXSARGS \
        XSLock localLock(pPerl);                        \
        dSP; dMARK;                                     \
        I32 ax = mark - PL_stack_base + 1;              \
        I32 items = sp - mark
#endif  /* PERL_OBJECT && !PERL_CAPI */
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*
#undef realloc
#undef malloc
#undef free
*/


#if defined (package)
   #undef mod
   #undef list
   #undef package
   #undef ref
#endif

#if defined(WORD) && (WORD==257)
#undef WORD
#endif
#include <stdlib.h>

#ifdef BROKEN_PERL_PLATFORM
   #undef open
   #undef fopen
   #undef vfprintf
   #undef fclose
   #undef feof
   #undef ferror
   #undef environ
   #undef strerror
   #undef fread
   #undef fwrite
   #undef fopen
   #undef fdopen
   #undef freopen
   #undef fclose
   #undef fputc
   #undef ungetc
   #undef getc
   #undef fileno
   #undef clearerr
   #undef fflush
   #undef ftell
   #undef fseek
   #undef fgetpos
   #undef fsetpos
   #undef rewind
   #undef tmpfile
   #undef abort
   #undef fstat
   #undef stat
   #undef rename
   #undef setmode
   #undef lseek
   #undef tell
   #undef dup
   #undef dup2
   #undef open
   #undef close
   #undef eof
   #undef read
   #undef write
   #undef _open_osfhandle
   #undef _get_osfhandle
   #undef spawnvp
   #undef mkdir
   #undef rmdir
   #undef chdir
   #undef flock
   #undef execv
   #undef execvp
   #undef perror
   #undef setbuf
   #undef setvbuf
   #undef flushall
   #undef fcloseall
   #undef fgets
   #undef gets
   #undef fgetc
   #undef putc
   #undef puts
   #undef getchar
   #undef putchar
   #undef close
   #undef dup
   #ifdef win32_close
      #define close  win32_close
      #define dup    win32_dup
   #endif
   #ifdef PerlIO_stderr    /* ActiveState quirks */
      #if (PERL_VERSION == 8) /* broken stderr definition */
         #undef stderr
         #define stderr PerlIO_stderr()
      #endif
      #if (PERL_VERSION >= 6) /* broken fprintf definition */
         #define fprintf PerlIO_printf
      #else
      #endif
   #elif (PERL_VERSION == 7)
      #define fprintf PerlIO_printf
   #else
      #undef fprintf
      #ifdef win32_stderr
         #undef stderr
         #define stderr win32_stderr()
      #endif
   #endif
#endif

#ifdef PTRV
#undef PTR2UV
#define PTR2UV(x) ((UV)(PTRV)(x))
#undef PTR2IV
#define PTR2IV(x) ((IV)(PTRV)(x))
#undef INT2PTR
#define INT2PTR(type,x) ((type)((PTRV)x))
#endif

#ifndef SvPV_nolen
#define SvPV_nolen(_sv)  SvPV(_sv,na)
#endif

#define PERL_CALL_SV_DIE_BUG_AWARE 1

#ifdef PERL_CALL_SV_DIE_BUG_AWARE
#define PERL_CALL_METHOD   clean_perl_call_method
#define PERL_CALL_PV       clean_perl_call_pv
#else
#define PERL_CALL_METHOD   perl_call_method
#define PERL_CALL_PV       perl_call_pv
#endif

#ifndef HAVE_BZERO
extern void bzero(void*,size_t);
#endif
#ifdef HAVE_STRICMP
#ifndef HAVE_STRCASECMP
#define strcasecmp(a,b) stricmp((a),(b))
#endif
#else
#ifdef HAVE_STRCASECMP
#define stricmp(a,b) strcasecmp((a),(b))
#else
#define strcasecmp(a,b) stricmp((a),(b))
#define PRIMA_NEED_OWN_STRICMP 1
extern int
stricmp(const char *s1, const char *s2);
#endif
#ifdef HAVE_STRNICMP
#ifndef HAVE_STRNCASECMP
#define strncasecmp(a,b,c) strnicmp((a),(b),(c))
#endif
#else
#ifdef HAVE_STRNCASECMP
#define strnicmp(a,b,c) strncasecmp((a),(b),(c))
#else
#define strncasecmp(a,b) strnicmp((a),(b))
#define PRIMA_NEED_OWN_STRNICMP 1
extern int
strnicmp(const char *s1, const char *s2, size_t count);
#endif
#endif
#endif
#ifndef HAVE_STRCASESTR
char * strcasestr( const char * s, const char * find);
#endif
#ifndef HAVE_REALLOCF
extern void *
reallocf(void *ptr, size_t size);
#endif

#ifdef HAVE_STRINGS_H
#include <strings.h>
#endif
#ifdef HAVE_PMPRINTF_H
#define printf PmPrintf
extern unsigned long PmPrintf(char *, ...);
#endif


#if ! ( defined( HAVE_SNPRINTF) || defined( HAVE__SNPRINTF))
extern int
snprintf( char *, size_t, const char *, ...);

extern int
vsnprintf( char *, size_t, const char *, va_list);
#endif

#define alloc1(typ)     ((typ*)malloc(sizeof(typ)))
#define allocn(typ,n)   ((typ*)malloc((n)*sizeof(typ)))
#define allocs(n)       ((char*)malloc(n))
#define allocb(n)       ((Byte*)malloc(n))
#define alloc1z(typ)    ((typ*)prima_mallocz(sizeof(typ)))
#define allocnz(typ,n)  ((typ*)prima_mallocz((n)*sizeof(typ)))

extern void *
prima_mallocz( size_t sz);

typedef I32 Bool;
#if PTRSIZE==LONGSIZE
typedef unsigned long Handle;
#elif PTRSIZE==INTSIZE
typedef unsigned int Handle;
#elif PTRSIZE==SHORTSIZE
typedef unsigned short Handle;
#elif defined(HAS_LONG_LONG) && PTRSIZE==LONGLONGSIZE
typedef unsigned long long Handle;
#elif defined(HAS_QUAD) && PTRSIZE==8
typedef Uquad_t Handle;
#else
#error "Cannot find adequate integer type"
#endif
typedef Handle ApiHandle;

#include "Types.h"

#if !defined(HAVE_INT8_T)
typedef I8 int8_t;
#endif
#if !defined(HAVE_INT16_T)
typedef I16  int16_t;
#endif
#if !defined(HAVE_INT32_T)
typedef I32  int32_t;
#endif
#if !defined(HAVE_UINT8_T)
#if defined(HAVE_U_INT8_T)
typedef u_int8_t        uint8_t;
#else
typedef U8 uint8_t;
#endif
#endif
#if !defined(HAVE_UINT16_T)
#if defined(HAVE_U_INT16_T)
typedef u_int16_t       uint16_t;
#else
typedef U16 uint16_t;
#endif
#endif
#if !defined(HAVE_UINT32_T)
#if defined(HAVE_U_INT32_T)
typedef u_int32_t       uint32_t;
#else
typedef U32 uint32_t;
#endif
#endif
#if !defined(HAVE_UINT64_T)
#if defined(HAVE_U_INT64_T)
typedef u_int64_t       uint64_t;
#elif defined U64
typedef U64 uint64_t;
#else
typedef unsigned long uint64_t;
#endif
#endif

typedef uint32_t        Color;

typedef uint8_t         Byte;
typedef int16_t         Short;
typedef int32_t         Long;

#undef INT16_MIN
#undef INT16_MAX
#undef INT32_MIN
#undef INT32_MAX
#define INT16_MIN (-32768)
#define INT16_MAX 32768
#define INT32_MIN  (-2147483647L-1)
#define INT32_MAX 2147483647L

typedef struct _RGBColor
{
   unsigned char b;
   unsigned char g;
   unsigned char r;
} RGBColor, *PRGBColor;

typedef struct { float  re, im; } Complex;
typedef struct { double re, im; } DComplex;
typedef struct { float  r,  ph; } TrigComplex;
typedef struct { double r,  ph; } TrigDComplex;

#ifdef __cplusplus
#define nil       NULL
#else
#define nil       Null(void*)
#endif
#define nilHandle Null(Handle)
#define nilSV     &PL_sv_undef
#define true TRUE
#define false FALSE

/* Event structures */

#ifdef KeyEvent
#undef KeyEvent
#endif

typedef struct _KeyEvent {
   int    cmd;
   int    subcmd;
   Handle source;
   int    code;
   int    key;
   int    mod;
   int    repeat;
} KeyEvent, *PKeyEvent;

#ifdef PositionalEvent
#undef PositionalEvent
#endif

typedef struct _PositionalEvent {
   int    cmd;
   int    subcmd;
   Handle source;
   Point  where;
   int    button;
   int    mod;
   Bool   dblclk;
} PositionalEvent, *PPositionalEvent;

#ifdef GenericEvent
#undef GenericEvent
#endif

typedef struct _GenericEvent {
   int    cmd;
   int    subcmd;
   Handle source;
   int    i;
   long   l;
   Bool   B;
   Point  P;
   Rect   R;
   void*  p;
   Handle H;
} GenericEvent, *PGenericEvent;

typedef union _Event {
  int             cmd;
  GenericEvent    gen;
  PositionalEvent pos;
  KeyEvent        key;
} Event, *PEvent;

typedef struct _PostMsg {
   int     msgId;
   Handle  h;
   SV   *  info1;
   SV   *  info2;
} PostMsg, *PPostMsg;

/* hashes support */
/* It's a mere coincidence that hashes in Prima guts implemented */
/* by means of Perl hashes */

#ifdef POLLUTE_NAME_SPACE
#define hash_create        prima_hash_create
#define hash_destroy       prima_hash_destroy
#define hash_fetch         prima_hash_fetch
#define hash_delete        prima_hash_delete
#define hash_store         prima_hash_store
#define hash_count         prima_hash_count
#define hash_first_that    prima_hash_first_that
#endif

typedef HV *PHash;
typedef Bool HashProc( void * item, int keyLen, void * key, void * params);
typedef HashProc *PHashProc;

extern PHash primaObjects;

extern PHash
prima_hash_create( void);

extern void
prima_hash_destroy( PHash self, Bool killAll);

extern void*
prima_hash_fetch( PHash self, const void *key, int keyLen);

extern void*
prima_hash_delete( PHash self, const void *key, int keyLen, Bool kill);

extern Bool
prima_hash_store( PHash self, const void *key, int keyLen, void *val);

#define prima_hash_count(hash) (HvKEYS(( HV*) hash))

extern void*
prima_hash_first_that( PHash self, void *action, void *params,
                       int *pKeyLen, void **pKey);

extern char *
prima_normalize_resource_string( char *name, Bool isClass);

/* tables of constants support */

#ifdef GENERATE_TABLE_GENERATOR
#ifndef TABLE_GENERATOR_NEWSVSTRING
#define TABLE_GENERATOR_NEWSVSTRING
static SV*
newSVstring( char *s)
{
   return newSVpv( s, 0);
}
#endif
#define START_TABLE(package,type) \
typedef struct { \
   char *name;   \
   type value;  \
} ConstTable_##package; \
ConstTable_##package Prima_Autoload_##package##_constants[] = {
#define CONSTANT(package,const_name) \
   { #const_name , package##const_name },
#define CONSTANT2(package,const_name,string_name) \
   { #string_name , package##const_name },
#define END_TABLE4(package,type,suffix,conversion) \
}; /* end of table */ \
static SV* newSVstring( char *s); \
XS(prima_autoload_##package##_constant) \
{ \
   static PHash table = nil; \
   dXSARGS; \
   char *name; \
   int i; \
   type *r; \
 \
   if (!table) { \
      table = hash_create(); \
      if (!table) croak( #package "::constant: cannot create hash"); \
      for ( i = 0; i < sizeof( Prima_Autoload_##package##_constants) \
               / sizeof( ConstTable_##package); i++) \
         hash_store( table, \
                     Prima_Autoload_##package##_constants[i]. name, \
                     (I32) strlen( Prima_Autoload_##package##_constants[i]. name), \
                     &Prima_Autoload_##package##_constants[i]. value); \
   } \
 \
   if ( items != 1) croak( "invalid call to " #package "::constant"); \
   name = SvPV_nolen( ST( 0)); \
   SPAGAIN; \
   SP -= items; \
   r = (type *)hash_fetch( table, name, (I32) strlen( name)); \
   if ( !r) croak( "invalid value: " #package "::%s", name); \
   XPUSHs( sv_2mortal( newSV##suffix((conversion)*r))); \
   PUTBACK; \
   return; \
} \
void register_##package##_constants( void) { \
   HV *unused_hv; \
   GV *unused_gv; \
   SV *sv; \
   CV *cv; \
   int i; \
 \
   newXS( #package "::constant", prima_autoload_##package##_constant, #package); \
   sv = newSVpv("", 0); \
   for ( i = 0; i < sizeof( Prima_Autoload_##package##_constants) \
            / sizeof( ConstTable_##package); i++) { \
      sv_setpvf( sv, "%s::%s", #package, Prima_Autoload_##package##_constants[i]. name); \
      cv = sv_2cv(sv, &unused_hv, &unused_gv, true); \
      sv_setpv((SV*)cv, ""); \
   } \
   sv_free( sv); \
}
#else
#define START_TABLE(package,type) \
typedef struct { \
   char *name;   \
   type value;  \
} ConstTable_##package;
#define CONSTANT(package,const_name) /* nothing */
#define CONSTANT2(package,const_name,string_name) /* nothing */
#define END_TABLE4(package,type,suffix,conversion) /* nothing */
#endif
#define END_TABLE(package,type) END_TABLE4(package,type,iv,IV)
#define END_TABLE_CHAR(package,type) END_TABLE4(package,type,string,char*)

/* Object life stages */
#define csDeadInInit    -2         /* dead before any init() code */
#define csConstructing  -1         /* before create() finished */
#define csNormal         0         /* normal during life stage */
#define csDestroying     1         /* destroy() started */
#define csFrozen         2         /* cleanup() started - no messages
                                      available at this point */
#define csFinalizing     3         /* done() started */
#define csDead           4         /* destroy() finished - no methods
                                      available at this point */

/* Notification types */
#define NT(const_name) CONSTANT(nt,const_name)
START_TABLE(nt,UV)
#define ntPrivateFirst   0x0
NT(PrivateFirst)
#define ntCustomFirst    0x1
NT(CustomFirst)
#define ntSingle         0x0
NT(Single)
#define ntMultiple       0x2
NT(Multiple)
#define ntEvent          0x4
NT(Event)
#define ntFluxNormal     0x0
NT(FluxNormal)
#define ntFluxReverse    0x8
NT(FluxReverse)
#define ntSMASK         ntMultiple | ntEvent
NT(SMASK)
#define ntDefault       ntPrivateFirst | ntMultiple | ntFluxReverse
NT(Default)
#define ntProperty      ntPrivateFirst | ntSingle   | ntFluxNormal
NT(Property)
#define ntRequest       ntPrivateFirst | ntEvent    | ntFluxNormal
NT(Request)
#define ntNotification  ntCustomFirst  | ntMultiple | ntFluxReverse
NT(Notification)
#define ntAction        ntCustomFirst  | ntSingle   | ntFluxReverse
NT(Action)
#define ntCommand       ntCustomFirst  | ntEvent    | ntFluxReverse
NT(Command)

END_TABLE(nt,UV)
#undef NT

/* Modality types */
#define MT(const_name) CONSTANT(mt,const_name)
START_TABLE(mt,UV)
#define mtNone           0
MT(None)
#define mtShared         1
MT(Shared)
#define mtExclusive      2
MT(Exclusive)

END_TABLE(mt,UV)
#undef MT


/* Command event types */
#define ctQueueMask      0x00070000     /* masks bits that defines behavior
                                           in !csNormal stages: */
#define ctCacheable      0x00000000     /* Command caches in the queue */
#define ctDiscardable    0x00010000     /* Command should be discarded */
#define ctPassThrough    0x00020000     /* Command passes as normal */
#define ctSingle         0x00040000     /* Command caches in the queue only
                                           once, then changes ct bits to */
#define ctSingleResponse 0x00050000     /* ctSingleResponse */
#define ctNoInhibit      0x00080000     /* Valid for csDestroying and csFrozen */

/* Apricot events */
/* commands */
#define CM(const_name) CONSTANT(cm,const_name)
START_TABLE(cm,UV)
#define cmClose         (0x00000005|ctDiscardable)
CM(Close)
#define cmChangeOwner   (0x00000006|ctDiscardable)
CM(ChangeOwner)
#define cmChildEnter    (0x00000007|ctDiscardable)
CM(ChildEnter)         
#define cmChildLeave    (0x00000008|ctDiscardable)
CM(ChildLeave)         
#define cmCreate        (0x00000009|ctPassThrough)
CM(Create)
#define cmDestroy       (0x0000000B|ctPassThrough|ctNoInhibit)
CM(Destroy)
#define cmHide          (0x0000000C|ctDiscardable) /* visible flag aware */
CM(Hide)
#define cmShow          (0x0000000D|ctDiscardable) /*           commands */
CM(Show)
#define cmReceiveFocus  (0x0000000E|ctDiscardable) /* focused flag aware */
CM(ReceiveFocus)
#define cmReleaseFocus  (0x0000000F|ctDiscardable) /*           commands */
CM(ReleaseFocus)
#define cmPaint         (0x00000010|ctSingle)      /* WM_PAINT analog */
CM(Paint)
#define cmRepaint       (0x00000010|ctSingleResponse) /* and it's response
                                                         action */
CM(Repaint)
#define cmSize          (0x00000011|ctPassThrough) /* WM_SIZE analog */
CM(Size)
#define cmMove          (0x00000012|ctPassThrough) /* WM_MOVE analog */
CM(Move)
#define cmColorChanged  (0x00000013|ctDiscardable) /* generates when color
                                                      changed */
CM(ColorChanged)
#define cmZOrderChanged (0x00000014|ctDiscardable) /* z-order change command */
CM(ZOrderChanged)
#define cmEnable        (0x00000015|ctDiscardable) /* enabled flag aware */
CM(Enable)
#define cmDisable       (0x00000016|ctDiscardable) /*           commands */
CM(Disable)
#define cmActivate      (0x00000017|ctDiscardable) /* commands for window */
CM(Activate)
#define cmDeactivate    (0x00000018|ctDiscardable) /* active stage change */
CM(Deactivate)
#define cmFontChanged   (0x00000019|ctDiscardable) /* generates when font
                                                      changed */
CM(FontChanged)
#define cmWindowState   (0x0000001A|ctDiscardable) /* generates when window
                                                      state changed */
CM(WindowState)
#define cmTimer          0x0000001C                /* WM_TIMER analog */
CM(Timer)
#define cmClick          0x0000001D                /* common click */
CM(Click)
#define cmCalcBounds    (0x0000001E|ctPassThrough) /* query on change size */
CM(CalcBounds)
#define cmPost           0x0000001F                /* posted message */
CM(Post)
#define cmPopup          0x00000020                /* interactive popup
                                                      request */
CM(Popup)
#define cmExecute        0x00000021                /* dialog execution start */
CM(Execute)
#define cmSetup          0x00000022                /* first message for alive
                                                      and active widget */
CM(Setup)
#define cmHint           0x00000023                /* hint show/hide message */
CM(Hint)
#define cmDragDrop       0x00000024                /* Drag'n'drop aware */
CM(DragDrop)
#define cmDragOver       0x00000025                /*         constants */
CM(DragOver)
#define cmEndDrag        0x00000026                /* * */
CM(EndDrag)
#define cmMenu          (0x00000027|ctDiscardable) /* send when menu going to be activated */
CM(Menu)
#define cmEndModal       0x00000028                /* dialog execution end */
CM(EndModal)

#define cmMenuCmd        0x00000050                /* interactive menu command */
CM(MenuCmd)
#define cmKeyDown        0x00000051                /* generic key down handler cmd */
CM(KeyDown)
#define cmKeyUp          0x00000052                /* generic key up handler cmd (rare used) */
CM(KeyUp)
#define cmMouseDown      0x00000053                /* WM_BUTTONxDOWN & WM_BUTTONxDBLCLK analog */
CM(MouseDown)
#define cmMouseUp        0x00000054                /* WM_BUTTONxUP analog */
CM(MouseUp)
#define cmMouseMove      0x00000055                /* WM_MOUSEMOVE analog */
CM(MouseMove)
#define cmMouseWheel     0x00000056                /* WM_MOUSEWHEEL analog */
CM(MouseWheel)
#define cmMouseClick     0x00000057                /* click response command */
CM(MouseClick)
#define cmMouseEnter     0x00000058                /* mouse entered window area */
CM(MouseEnter)
#define cmMouseLeave     0x00000059                /* mouse left window area */
CM(MouseLeave)
#define cmTranslateAccel 0x0000005A                /* key event spred to non-focused windows */
CM(TranslateAccel)
#define cmDelegateKey    0x0000005B                /* reserved for key mapping */
CM(DelegateKey)
#define cmFileRead       0x00000070
#define cmFileWrite      0x00000071
#define cmFileException  0x00000072

#define cmImageHeaderReady 0x00000073
#define cmImageDataReady 0x00000074
END_TABLE(cm,UV)
#undef CM

/* mouse buttons & message box constants */
#define MB(const_name) CONSTANT(mb,const_name)
#define MB2(const_name,string_name) CONSTANT2(mb,const_name,string_name)
START_TABLE(mb,UV)
#define mb1             1
MB2(1,b1)
#define mb2             2
MB2(2,b2)
#define mb3             4
MB2(3,b3)
#define mb4             8
MB2(4,b4)
#define mb5             16
MB2(5,b5)
#define mb6             32
MB2(6,b6)
#define mb7             64
MB2(7,b7)
#define mb8             128
MB2(8,b8)
#define mbLeft          mb1
MB(Left)
#define mbRight         mb3
MB(Right)
#define mbMiddle        mb2
MB(Middle)
#define mbOK            0x0001
MB(OK)
#define mbOk            mbOK
MB(Ok)
#define mbYes           0x0002
MB(Yes)
#define mbCancel        0x0004
MB(Cancel)
#define mbNo            0x0008
MB(No)
#define mbAbort         0x0010
MB(Abort)
#define mbRetry         0x0020
MB(Retry)
#define mbIgnore        0x0040
MB(Ignore)
#define mbHelp          0x0080
MB(Help)
#define mbOKCancel      (mbOK|mbCancel)
MB(OKCancel)
#define mbOkCancel      mbOKCancel
MB(OkCancel)
#define mbYesNo         (mbYes|mbNo)
MB(YesNo)
#define mbYesNoCancel   (mbYes|mbNo|mbCancel)
MB(YesNoCancel)
#ifdef Error
#undef Error
#endif
#define mbError         0x0100
MB(Error)
#define mbWarning       0x0200
MB(Warning)
#define mbInformation   0x0400
MB(Information)
#define mbQuestion      0x0800
MB(Question)
#define mbNoSound       0x1000
MB(NoSound)
END_TABLE(mb,UV)
#undef MB
#undef MB2

/* keyboard modifiers */
#define KM(const_name) CONSTANT(km,const_name)
START_TABLE(km,UV)
#define kmShift         0x01000000
KM(Shift)
#define kmCtrl          0x04000000
KM(Ctrl)
#define kmAlt           0x08000000
KM(Alt)
#define kmUnicode       0x10000000
KM(Unicode)
#define kmKeyPad        0x40000000
KM(KeyPad)
#define kmDeadKey       0x80000000
KM(DeadKey)
END_TABLE(km,UV)
#undef KM

#define KB(const_name) CONSTANT(kb,const_name)
START_TABLE(kb,UV)
/* keyboard masks */
#define kbCharMask      0x000000ff
KB(CharMask)
#define kbCodeMask      0x00ffff00
KB(CodeMask)
#define kbModMask       0xff000000
KB(ModMask)

/* bad key or no key code */
#define kbNoKey         0x00FFFF00
KB(NoKey)

/* virtual keys which are modifiers at the same time */
#define kbShiftL        0x00010100
KB(ShiftL)
#define kbShiftR        0x00010200
KB(ShiftR)
#define kbCtrlL         0x00010300
KB(CtrlL)
#define kbCtrlR         0x00010400
KB(CtrlR)
#define kbAltL          0x00010500
KB(AltL)
#define kbAltR          0x00010600
KB(AltR)
#define kbMetaL         0x00010700
KB(MetaL)
#define kbMetaR         0x00010800
KB(MetaR)
#define kbSuperL        0x00010900
KB(SuperL)
#define kbSuperR        0x00010a00
KB(SuperR)
#define kbHyperL        0x00010b00
KB(HyperL)
#define kbHyperR        0x00010c00
KB(HyperR)
#define kbCapsLock      0x00010d00
KB(CapsLock)
#define kbNumLock       0x00010e00
KB(NumLock)
#define kbScrollLock    0x00010f00
KB(ScrollLock)
#define kbShiftLock     0x00011000
KB(ShiftLock)

/* Virtual keys which have character code at the same time */
#define kbBackspace     0x00020800
KB(Backspace)
#define kbTab           0x00020900
KB(Tab)
#define kbKPTab         (kmKeyPad | kbTab)      /* C-only */
#define kbLinefeed      0x00020a00
KB(Linefeed)
#define kbEnter         0x00020d00
KB(Enter)
#define kbReturn        kbEnter
KB(Return)
#define kbKPEnter       (kmKeyPad | kbEnter)    /* C-only */
#define kbKPReturn      kbKPEnter               /* C-only */
#define kbEscape        0x00021b00
KB(Escape)
#define kbEsc           kbEscape
KB(Esc)
#define kbSpace         0x00022000
KB(Space)
#define kbKPSpace       (kmKeyPad | kbSpace)    /* C-only */

#define kbKPEqual       (kmKeyPad | '=')        /* C-only */
#define kbKPMultiply    (kmKeyPad | '*')        /* C-only */
#define kbKPAdd         (kmKeyPad | '+')        /* C-only */
#define kbKPSeparator   (kmKeyPad | ',')        /* C-only */
#define kbKPSubtract    (kmKeyPad | '-')        /* C-only */
#define kbKPDecimal     (kmKeyPad | '.')        /* C-only */
#define kbKPDivide      (kmKeyPad | '/')        /* C-only */
#define kbKP0           (kmKeyPad | '0')        /* C-only */
#define kbKP1           (kmKeyPad | '1')        /* C-only */
#define kbKP2           (kmKeyPad | '2')        /* C-only */
#define kbKP3           (kmKeyPad | '3')        /* C-only */
#define kbKP4           (kmKeyPad | '4')        /* C-only */
#define kbKP5           (kmKeyPad | '5')        /* C-only */
#define kbKP6           (kmKeyPad | '6')        /* C-only */
#define kbKP7           (kmKeyPad | '7')        /* C-only */
#define kbKP8           (kmKeyPad | '8')        /* C-only */
#define kbKP9           (kmKeyPad | '9')        /* C-only */

/* Other virtual keys */
#define kbClear         0x00040100
KB(Clear)
#define kbPause         0x00040200
#ifdef Pause
#undef Pause
#endif
KB(Pause)
#define kbSysRq         0x00040300
KB(SysRq)
#define kbSysReq        kbSysRq
KB(SysReq)
#define kbDelete        0x00040400
KB(Delete)
#define kbKPDelete      (kmKeyPad | kbDelete)   /* C-only */
#define kbHome          0x00040500
KB(Home)
#define kbKPHome        (kmKeyPad | kbHome)     /* C-only */
#define kbLeft          0x00040600
KB(Left)
#define kbKPLeft        (kmKeyPad | kbLeft)     /* C-only */
#define kbUp            0x00040700
KB(Up)
#define kbKPUp          (kmKeyPad | kbUp)       /* C-only */
#define kbRight         0x00040800
KB(Right)
#define kbKPRight       (kmKeyPad | kbRight)    /* C-only */
#define kbDown          0x00040900
KB(Down)
#define kbKPDown        (kmKeyPad | kbDown)     /* C-only */
#define kbPgUp          0x00040a00
KB(PgUp)
#define kbPrior         kbPgUp
KB(Prior)
#define kbPageUp        kbPgUp
KB(PageUp)
#define kbKPPgUp        (kmKeyPad | kbPgUp)     /* C-only */
#define kbKPPrior       kbKPPgUp                /* C-only */
#define kbKPPageUp      kbKPPgUp                /* C-only */
#define kbPgDn          0x00040b00
KB(PgDn)
#define kbNext          kbPgDn
KB(Next)
#define kbPageDown      kbPgDn
KB(PageDown)
#define kbKPPgDn        (kmKeyPad | kbPgDn)     /* C-only */
#define kbKPNext        kbKPPgDn                /* C-only */
#define kbKPPageDown    kbKPPgDn                /* C-only */
#define kbEnd           0x00040c00
KB(End)
#define kbKPEnd         (kmKeyPad | kbEnd)      /* C-only */
#define kbBegin         0x00040d00
KB(Begin)
#define kbKPBegin       (kmKeyPad | kbBegin)    /* C-only */
#define kbSelect        0x00040e00
KB(Select)
#define kbPrint         0x00040f00
KB(Print)
#define kbPrintScr      kbPrint
KB(PrintScr)
#define kbExecute       0x00041000
KB(Execute)
#define kbInsert        0x00041100
KB(Insert)
#define kbKPInsert      (kmKeyPad | kbInsert)   /* C-only */
#define kbUndo          0x00041200
KB(Undo)
#define kbRedo          0x00041300
KB(Redo)
#define kbMenu          0x00041400
KB(Menu)
#define kbFind          0x00041500
KB(Find)
#define kbCancel        0x00041600
KB(Cancel)
#define kbHelp          0x00041700
KB(Help)
#define kbBreak         0x00041800
KB(Break)
#define kbBackTab       0x00041900
KB(BackTab)

/* Virtual function keys */
#define kbF1            0x00080100
KB(F1)
#define kbKPF1          (kmKeyPad | kbF1)       /* C-only */
#define kbF2            0x00080200
KB(F2)
#define kbKPF2          (kmKeyPad | kbF2)       /* C-only */
#define kbF3            0x00080300
KB(F3)
#define kbKPF3          (kmKeyPad | kbF3)       /* C-only */
#define kbF4            0x00080400
KB(F4)
#define kbKPF4          (kmKeyPad | kbF4)       /* C-only */
#define kbF5            0x00080500
KB(F5)
#define kbF6            0x00080600
KB(F6)
#define kbF7            0x00080700
KB(F7)
#define kbF8            0x00080800
KB(F8)
#define kbF9            0x00080900
KB(F9)
#define kbF10           0x00080a00
KB(F10)
#define kbF11           0x00080b00
KB(F11)
#define kbL1            kbF11
KB(L1)
#define kbF12           0x00080c00
KB(F12)
#define kbL2            kbF12
KB(L2)
#define kbF13           0x00080d00
KB(F13)
#define kbL3            kbF13
KB(L3)
#define kbF14           0x00080e00
KB(F14)
#define kbL4            kbF14
KB(L4)
#define kbF15           0x00080f00
KB(F15)
#define kbL5            kbF15
KB(L5)
#define kbF16           0x00081000
KB(F16)
#define kbL6            kbF16
KB(L6)
#define kbF17           0x00081100
KB(F17)
#define kbL7            kbF17
KB(L7)
#define kbF18           0x00081200
KB(F18)
#define kbL8            kbF18
KB(L8)
#define kbF19           0x00081300
KB(F19)
#define kbL9            kbF19
KB(L9)
#define kbF20           0x00081400
KB(F20)
#define kbL10           kbF20
KB(L10)
#define kbF21           0x00081500
KB(F21)
#define kbR1            kbF21
KB(R1)
#define kbF22           0x00081600
KB(F22)
#define kbR2            kbF22
KB(R2)
#define kbF23           0x00081700
KB(F23)
#define kbR3            kbF23
KB(R3)
#define kbF24           0x00081800
KB(F24)
#define kbR4            kbF24
KB(R4)
#define kbF25           0x00081900
KB(F25)
#define kbR5            kbF25
KB(R5)
#define kbF26           0x00081a00
KB(F26)
#define kbR6            kbF26
KB(R6)
#define kbF27           0x00081b00
KB(F27)
#define kbR7            kbF27
KB(R7)
#define kbF28           0x00081c00
KB(F28)
#define kbR8            kbF28
KB(R8)
#define kbF29           0x00081d00
KB(F29)
#define kbR9            kbF29
KB(R9)
#define kbF30           0x00081e00
KB(F30)
#define kbR10           kbF30
KB(R10)
END_TABLE(kb,UV)
#undef KB

#define TA(const_name) CONSTANT(ta,const_name)
START_TABLE(ta,UV)
#define taLeft      1
TA(Left)
#define taRight     2
TA(Right)
#define taCenter    3
TA(Center)
#define taTop       4
TA(Top)
#define taBottom    8
TA(Bottom)
#define taMiddle    12
TA(Middle)
END_TABLE(ta,UV)
#undef TA

/* Please, please, PLEASE!  Do not use directly! */

typedef struct _VmtPatch
{
   void *vmtAddr;
   void *procAddr;
   char *name;
} VmtPatch;

typedef struct _VMT {         /* Whatever VMT */
   char *className;
   struct _VMT *super;
   struct _VMT *base;
   int instanceSize;
   VmtPatch *patch;
   int patchLength;
   int vmtSize;
} VMT, *PVMT;

typedef struct _AnyObject {   /* Whatever Object */
   PVMT self;
   PVMT *super;
   SV   *mate;
   struct _AnyObject *killPtr;
} AnyObject, *PAnyObject;

extern FillPattern fillPatterns[];

/* gencls rtl support */

#define C_NUMERIC_UNDEF   -90909090
#define C_STRING_UNDEF    "__C_CHAR_UNDEF__"
#define C_POINTER_UNDEF   nilSV

/* run-time class information functions */

extern Bool
kind_of( Handle object, void *cls);

/* debugging functions */
extern int
debug_write( const char *format, ...);

/* perl links */
#if (PERL_PATCHLEVEL < 5)
/* ...(perl stinks)... */
#undef  SvREFCNT_inc
#define SvREFCNT_inc(sv) ((Sv = (SV*)(sv)),             \
                          (void)(Sv && ++SvREFCNT(Sv)), \
                          (SV*)Sv)
#endif

#ifdef PERL_CALL_SV_DIE_BUG_AWARE
extern I32
clean_perl_call_method( char* methname, I32 flags);

extern I32
clean_perl_call_pv( char* subname, I32 flags);
#endif

extern void
build_static_vmt( void *vmt);

extern Bool
build_dynamic_vmt( void *vmt, const char *ancestorName, int ancestorVmtSize);

extern PVMT
gimme_the_vmt( const char *className);

extern Handle
gimme_the_mate( SV *perlObject);

extern Handle
create_mate( SV *perlObject);

extern SV*
eval( char* string);

extern CV*
sv_query_method( SV * object, char *methodName, Bool cacheIt);

extern CV*
query_method( Handle object, char *methodName, Bool cacheIt);

extern SV*
call_perl_indirect( Handle self, char *subName, const char *format,
                    Bool cdecl, Bool coderef, va_list params);

extern SV*
call_perl( Handle self, char *subName, const char *format, ...);

extern SV*
sv_call_perl( SV * mate, char *subName, const char *format, ...);

extern SV*
notify_perl( Handle self, char *methodName, const char *format, ...);

extern SV*
cv_call_perl( SV * mate, SV * coderef, const char *format, ...);

extern Handle
Object_create( char * className, HV * profile);

extern void
Object_destroy( Handle self);

extern void
protect_object( Handle obj);

extern void
unprotect_object( Handle obj);

extern void
kill_zombies( void);

extern HV*
parse_hv( I32 ax, SV **sp, I32 items, SV **mark,
          int expected, const char *methodName);

extern void
push_hv( I32 ax, SV **sp, I32 items, SV **mark, int callerReturns, HV *hv);

extern SV**
push_hv_for_REDEFINED( SV **sp, HV *hv);

extern int
pop_hv_for_REDEFINED( SV **sp, int count, HV *hv, int shouldBe);

extern void
perl_error(void);

extern void*
create_object( const char *objClass, const char *types, ...);

#ifdef __GNUC__
#define SvBOOL(sv) ({ SV *svsv = sv; SvTRUE(svsv);})
#else
__INLINE__ Bool
SvBOOL( SV *sv)
{
   return SvTRUE(sv);
}
#endif

#define pexist( key) hv_exists( profile, # key, (I32) strlen( #key))
#define pdelete( key) (void) hv_delete( profile, # key, (I32) strlen( #key), G_DISCARD)
#define dPROFILE  SV ** temporary_prf_Sv
#define pget_sv( key) ((( temporary_prf_Sv = hv_fetch( profile, # key, (I32) strlen( # key), 0)) == nil) ? croak( "Panic: bad profile key (``%s'') requested in ``%s'', line %d\n", # key, __FILE__, __LINE__ ), &PL_sv_undef : *temporary_prf_Sv)
#define pget_i( key)  ( pget_sv( key), SvIV( *temporary_prf_Sv))
#define pget_f( key)  ( pget_sv( key), SvNV( *temporary_prf_Sv))
#define pget_c( key)  ( pget_sv( key), SvPV_nolen( *temporary_prf_Sv))
#define pget_H( key)  gimme_the_mate( pget_sv( key))
#define pget_B( key)  ( SvTRUE( pget_sv( key)))

#define pset_sv_noinc( key, value) (void)hv_store( profile, # key, (I32) strlen( # key), value, 0)
#define pset_sv( key, value) pset_sv_noinc( key, newSVsv( value))
#define pset_i( key, value)  pset_sv_noinc( key, newSViv( value))
#define pset_f( key, value)  pset_sv_noinc( key, newSVnv( value))
#define pset_c( key, value)  pset_sv_noinc( key, newSVpv( value, 0))
#define pset_b( key, value, len)  pset_sv_noinc( key, newSVpv( value, ( len)))
#define pset_H( key, value)  pset_sv_noinc( key, (value) ? newSVsv((( PAnyObject) (value))-> mate) : nilSV)

#define create_instance( obj)  (                                   \
   temporary_prf_Sv = ( SV **) Object_create( obj, profile),       \
   ( temporary_prf_Sv ?                                            \
       --SvREFCNT( SvRV((( PAnyObject) temporary_prf_Sv)-> mate))  \
       : 0),                                                       \
   ( Handle) temporary_prf_Sv                                      \
   )

#ifdef POLLUTE_NAME_SPACE
#define TransmogrifyHandle(c,h)         ((P##c)(h))
#define PAbstractMenu(h)                TransmogrifyHandle(AbstractMenu,(h))
#define CAbstractMenu(h)                (PAbstractMenu(h)->self)
#define PApplication(h)                 TransmogrifyHandle(Application,(h))
#define CApplication(h)                 (PApplication(h)-> self)
#define PComponent(h)                   TransmogrifyHandle(Component,(h))
#define CComponent(h)                   (PComponent(h)-> self)
#define PDrawable(h)                    TransmogrifyHandle(Drawable,(h))
#define CDrawable(h)                    (PDrawable(h)-> self)
#define PFile(h)                        TransmogrifyHandle(File,(h))
#define CFile(h)                        (PFile(h)-> self)
#define PIcon(h)                        TransmogrifyHandle(Icon,(h))
#define CIcon(h)                        (PIcon(h)-> self)
#define PImage(h)                       TransmogrifyHandle(Image,(h))
#define CImage(h)                       (PImage(h)-> self)
#define PObject(h)                      TransmogrifyHandle(Object,(h))
#define CObject(h)                      (PObject(h)-> self)
#define PMenu(h)                        TransmogrifyHandle(Menu,(h))
#define CMenu(h)                        (PMenu(h)-> self)
#define PPopup(h)                       TransmogrifyHandle(Popup,(h))
#define CPopup(h)                       (PPopup(h)-> self)
#define PPrinter(h)                     TransmogrifyHandle(Printer,(h))
#define CPrinter(h)                     (PPrinter(h)-> self)
#define PTimer(h)                       TransmogrifyHandle(Timer,(h))
#define CTimer(h)                       (PTimer(h)-> self)
#define PWidget(h)                      TransmogrifyHandle(Widget,(h))
#define CWidget(h)                      (PWidget(h)-> self)
#define PWindow(h)                      TransmogrifyHandle(Window,(h))
#define CWindow(h)                      (PWindow(h)-> self)
#endif


/* mapping functions */

#define endCtx          0x19740108

extern Handle
ctx_remap_def ( Handle value, Handle * table, Bool direct, Handle default_value);

#define ctx_remap_end(a,b,c)    ctx_remap_def((a),(b),(c), endCtx)
#define ctx_remap(a,b,c)        ctx_remap_def((a),(b),(c), 0)

/* utility functions */

extern char *
duplicate_string( const char *);

/* lists support */

typedef struct _List
{
   Handle * items;
   int    count;
   int    size;
   int    delta;
} List, *PList;

typedef Bool ListProc ( Handle item, void * params);
typedef ListProc *PListProc;

extern void
list_create( PList self, int size, int delta);

extern PList
plist_create( int size, int delta);

extern void
list_destroy( PList self);

extern void
plist_destroy( PList self);

extern int
list_add( PList self, Handle item);

extern int
list_insert_at( PList self, Handle item, int pos);

extern Handle
list_at( PList self, int index);

extern void
list_delete( PList self, Handle item);

extern void
list_delete_at( PList self, int index);

extern void
list_delete_all( PList self, Bool kill);

extern int
list_first_that( PList self, void * action, void * params);

extern int
list_index_of( PList self, Handle item);

/* utf8 */
#if PERL_PATCHLEVEL > 5
#define PERL_SUPPORTS_UTF8  1
#if (PERL_PATCHLEVEL == 6)
#define utf8_to_uvchr utf8_to_uv_simple
#define utf8_to_uvuni utf8_to_uv_simple
#define uvchr_to_utf8 uv_to_utf8
#define uvuni_to_utf8 uv_to_utf8
#endif
#else
/* dummy utf8 functionality */
#undef utf8_hop
#undef utf8_length
#undef  PERL_SUPPORTS_UTF8
#define IN_BYTES            1
#define DO_UTF8(sv)         0
#define SvUTF8(sv)          0
#define utf8_length(s,e)    ((U8*)(e)-(U8*)(s))
#define utf8_hop(s,off)     ((U8*)((s)+(off)))
#define SvUTF8_on(sv)       {}
#define SvUTF8_off(sv)      {}

#define utf8_to_uvchr       prima_utf8_to_uv
#define utf8_to_uvuni       prima_utf8_to_uv
#define uvchr_to_utf8        prima_uv_to_utf8
#define uvuni_to_utf8        prima_uv_to_utf8
extern UV
prima_utf8_to_uv( U8 * utf8, STRLEN * len);

extern U8 *
prima_uv_to_utf8( U8 * utf8, UV uv);

#endif

extern int
prima_utf8_length( const char * utf8);

/* OS types */
#define APC(const_name) CONSTANT(apc,const_name)
START_TABLE(apc,UV)
#define apcOs2                  1
APC(Os2)
#define apcWin32                2
APC(Win32)
#define apcUnix                 3
APC(Unix)
END_TABLE(apc,UV)
#undef APC

/* GUI types */
#define GUI(const_name) CONSTANT(gui,const_name)
START_TABLE(gui,UV)
#define guiDefault              0
GUI(Default)
#define guiPM                   1
GUI(PM)
#define guiWindows              2
GUI(Windows)
#define guiXLib                 3
GUI(XLib)
#define guiGTK2                 4
GUI(GTK2)
END_TABLE(gui,UV)
#undef GUI

/* drives types (for platforms which have 'em) */
/* also, text justification constants for draw_text */
#define DT(const_name) CONSTANT(dt,const_name)
START_TABLE(dt,UV)
#define dtUnknown               0
DT(Unknown)
#define dtNone                  1
DT(None)
#define dtFloppy                2
DT(Floppy)
#define dtHDD                   3
DT(HDD)
#define dtNetwork               4
DT(Network)
#define dtCDROM                 5
DT(CDROM)
#define dtMemory                6
DT(Memory)

#define dtLeft                     0x0000
DT(Left)
#define dtRight                    0x0001
DT(Right)
#define dtCenter                   0x0002
DT(Center)
#define dtTop                      0x0000
DT(Top)
#define dtBottom                   0x0004
DT(Bottom)
#define dtVCenter                  0x0008
DT(VCenter)
#define dtDrawMnemonic             0x0010
DT(DrawMnemonic)
#define dtDrawSingleChar           0x0020
DT(DrawSingleChar)
#define dtDrawPartial              0x0040
DT(DrawPartial)
#define dtNewLineBreak             0x0080
DT(NewLineBreak)
#define dtSpaceBreak               0x0100
DT(SpaceBreak)
#define dtWordBreak                0x0200
DT(WordBreak)
#define dtExpandTabs               0x0400
DT(ExpandTabs)
#define dtUseExternalLeading       0x0800
DT(UseExternalLeading)
#define dtUseClip                  0x1000
DT(UseClip)
#define dtQueryHeight              0x2000
DT(QueryHeight)
#define dtQueryLinesDrawn          0x0000
DT(QueryLinesDrawn)
#define dtNoWordWrap               0x4000
DT(NoWordWrap)
#define dtWordWrap                 0x0000
DT(WordWrap)
#define dtDefault                  (dtNewLineBreak|dtWordBreak|dtExpandTabs|dtUseExternalLeading)
DT(Default)

END_TABLE(dt,UV)
#undef DT

/* apc error constants */
#define errOk                    0x0000
#define errApcError              0x0001
#define errInvObject             0x0002
#define errInvParams             0x0003
#define errInvWindowIcon         0x0100
#define errInvClipboardData      0x0101
#define errInvPrinter            0x0102
#define errNoPrinters            0x0103
#define errNoPrnSettableOptions  0x0103
#define errUserCancelled         0x0104


/* system-independent object option flags */
typedef struct _ObjectOptions_ {
   unsigned optInDestroyList       : 1;   /* Object */
   unsigned optcmDestroy           : 1;   /* Component */
   unsigned optUTF8_name           : 1;
   unsigned optInDraw              : 1;   /* Drawable */
   unsigned optInDrawInfo          : 1;
   unsigned optTextOutBaseLine     : 1;
   unsigned optAutoEnableChildren  : 1;   /* Widget */
   unsigned optBriefKeys           : 1;
   unsigned optBuffered            : 1;
   unsigned optModalHorizon        : 1;
   unsigned optOwnerBackColor      : 1;
   unsigned optOwnerColor          : 1;
   unsigned optOwnerFont           : 1;
   unsigned optOwnerHint           : 1;
   unsigned optOwnerShowHint       : 1;
   unsigned optOwnerPalette        : 1;
   unsigned optPackPropagate       : 1;
   unsigned optSetupComplete       : 1;
   unsigned optSelectable          : 1;
   unsigned optShowHint            : 1;
   unsigned optSystemSelectable    : 1;
   unsigned optTabStop             : 1;
   unsigned optScaleChildren       : 1;
   unsigned optUTF8_helpContext    : 1;
   unsigned optUTF8_hint           : 1;
   unsigned optUTF8_text           : 1;
   unsigned optPreserveType        : 1;   /* Image */
   unsigned optVScaling            : 1;
   unsigned optHScaling            : 1;
   unsigned optAutoPopup           : 1;   /* Popup */
   unsigned optActive              : 1;   /* Timer */
   unsigned optOwnerIcon           : 1;   /* Window */
} ObjectOptions;

#define opt_set( option)           (PObject(self)-> options. option = 1)
#define opt_clear( option)         (PObject(self)-> options. option = 0)
#define is_opt( option)            (PObject(self)-> options. option)
#define opt_assign( option, value) (PObject(self)->options. option = \
                                    (value) ? 1 : 0)
#define opt_InPaint                ( is_opt( optInDraw) \
                                     || is_opt( optInDrawInfo))

/* apc class constants */
#define WC(const_name) CONSTANT(wc,const_name)
START_TABLE(wc,UV)
#define wcUndef               0x0000000
WC(Undef)
#define wcButton              0x0010000
WC(Button)
#define wcCheckBox            0x0020000
WC(CheckBox)
#define wcCombo               0x0030000
WC(Combo)
#define wcDialog              0x0040000
WC(Dialog)
#define wcEdit                0x0050000
WC(Edit)
#define wcInputLine           0x0060000
WC(InputLine)
#define wcLabel               0x0070000
WC(Label)
#define wcListBox             0x0080000
WC(ListBox)
#define wcMenu                0x0090000
WC(Menu)
#define wcPopup               0x00A0000
WC(Popup)
#define wcRadio               0x00B0000
WC(Radio)
#define wcScrollBar           0x00C0000
WC(ScrollBar)
#define wcSlider              0x00D0000
WC(Slider)
#define wcWidget              0x00E0000
WC(Widget)
#define wcCustom              wcWidget
WC(Custom)
#define wcWindow              0x00F0000
WC(Window)
#define wcApplication         0x0100000
WC(Application)
#define wcMask                0xFFF0000
WC(Mask)
END_TABLE(wc,UV)
#undef WC

/* geometry manager types */
#define GT(const_name) CONSTANT(gt,const_name)
START_TABLE(gt,UV)
#define gtDefault          0
GT(Default)
#define gtGrowMode         0
GT(GrowMode)
#define gtPack             1
GT(Pack)
#define gtPlace            2
GT(Place)
#define gtMax              2
GT(Max)
END_TABLE(gt,UV)
#undef GT

/* widget grow constats */
#define GM(const_name) CONSTANT(gm,const_name)
START_TABLE(gm,UV)
#define gmGrowLoX             0x001
GM(GrowLoX)
#define gmGrowLoY             0x002
GM(GrowLoY)
#define gmGrowHiX             0x004
GM(GrowHiX)
#define gmGrowHiY             0x008
GM(GrowHiY)
#define gmGrowAll             0x00F
GM(GrowAll)
#define gmXCenter             0x010
GM(XCenter)
#define gmYCenter             0x020
GM(YCenter)
#define gmCenter              (gmXCenter|gmYCenter)
GM(Center)
#define gmDontCare            0x040
GM(DontCare)
/* shortcuts */
#define gmClient              (gmGrowHiX|gmGrowHiY)
GM(Client)
#define gmRight               (gmGrowLoX|gmGrowHiY)
GM(Right)
#define gmLeft                gmGrowHiY
GM(Left)
#define gmFloor               gmGrowHiX
GM(Floor)
#define gmCeiling             (gmGrowHiX|gmGrowLoY)
GM(Ceiling)
END_TABLE(gm,UV)
#undef GM

/* border icons */
#define BI(const_name) CONSTANT(bi,const_name)
START_TABLE(bi,UV)
#define    biSystemMenu    1
BI(SystemMenu)
#define    biMinimize      2
BI(Minimize)
#define    biMaximize      4
BI(Maximize)
#define    biTitleBar      8
BI(TitleBar)
#define    biAll           (biSystemMenu|biMinimize|biMaximize|biTitleBar)
BI(All)
END_TABLE(bi,UV)
#undef BI

/* border styles */
#define BS(const_name) CONSTANT(bs,const_name)
START_TABLE(bs,UV)
#define   bsNone           0
BS(None)
#define   bsSizeable       1
BS(Sizeable)
#define   bsSingle         2
BS(Single)
#define   bsDialog         3
BS(Dialog)
END_TABLE(bs,UV)
#undef BS

/* window states */
#define WS(const_name) CONSTANT(ws,const_name)
START_TABLE(ws,UV)
#define   wsNormal         0
WS(Normal)
#define   wsMinimized      1
WS(Minimized)
#define   wsMaximized      2
WS(Maximized)
END_TABLE(ws,UV)
#undef WS

/* z-order query constants */
#define   zoFirst          0
#define   zoLast           1
#define   zoNext           2
#define   zoPrev           3

/* system values */
#define SV(const_name) CONSTANT(sv,const_name)
START_TABLE(sv,UV)
#define   svYMenu           0
SV(YMenu)
#define   svYTitleBar       1
SV(YTitleBar)
#define   svXIcon           2
SV(XIcon)
#define   svYIcon           3
SV(YIcon)
#define   svXSmallIcon      4
SV(XSmallIcon)
#define   svYSmallIcon      5
SV(YSmallIcon)
#define   svXPointer        6
SV(XPointer)
#define   svYPointer        7
SV(YPointer)
#define   svXScrollbar      8
SV(XScrollbar)
#define   svYScrollbar      9
SV(YScrollbar)
#define   svXCursor         10
SV(XCursor)
#define   svAutoScrollFirst 11
SV(AutoScrollFirst)
#define   svAutoScrollNext  12
SV(AutoScrollNext)
#define   svInsertMode      13
SV(InsertMode)
#define   svXbsNone         14
SV(XbsNone)
#define   svYbsNone         15
SV(YbsNone)
#define   svXbsSizeable     16
SV(XbsSizeable)
#define   svYbsSizeable     17
SV(YbsSizeable)
#define   svXbsSingle       18
SV(XbsSingle)
#define   svYbsSingle       19
SV(YbsSingle)
#define   svXbsDialog       20
SV(XbsDialog)
#define   svYbsDialog       21
SV(YbsDialog)
#define   svMousePresent    22
SV(MousePresent)
#define   svMouseButtons    23
SV(MouseButtons)
#define   svWheelPresent    24
SV(WheelPresent)
#define   svSubmenuDelay    25
SV(SubmenuDelay)
#define   svFullDrag        26
SV(FullDrag)
#define   svDblClickDelay   27
SV(DblClickDelay)
#define   svShapeExtension  28
SV(ShapeExtension)
#define   svColorPointer    29
SV(ColorPointer)
#define   svCanUTF8_Input   30
SV(CanUTF8_Input)
#define   svCanUTF8_Output  31
SV(CanUTF8_Output)
END_TABLE(sv,UV)
#undef SV

extern Handle application;
extern long   apcError;

/* *****************
*  apc functions   *
***************** */

extern char *
apc_last_error();

extern Handle
apc_get_application(void);

/* Application management */
extern Bool
apc_application_begin_paint( Handle self);

extern Bool
apc_application_begin_paint_info( Handle self);

extern Bool
apc_application_create( Handle self);

extern Bool
apc_application_close( Handle self);

extern Bool
apc_application_destroy( Handle self);

extern Bool
apc_application_end_paint( Handle self);

extern Bool
apc_application_end_paint_info( Handle self);

extern Bool
apc_application_get_bitmap( Handle self, Handle image, int x, int y, int xLen, int yLen);

extern int
apc_application_get_gui_info( char * description, int len);

extern Handle
apc_application_get_widget_from_point( Handle self, Point point);

extern Handle
apc_application_get_handle( Handle self, ApiHandle apiHandle);

extern Rect
apc_application_get_indents( Handle self);

extern int
apc_application_get_os_info( char *system, int slen,
                             char *release, int rlen,
                             char *vendor, int vlen,
                             char *arch, int alen);

extern Point
apc_application_get_size( Handle self);

extern Bool
apc_application_go( Handle self);

extern Bool
apc_application_lock( Handle self);

extern Bool
apc_application_sync( void);

extern Bool
apc_application_unlock( Handle self);

extern Bool
apc_application_yield( void);

/* Component */
extern Bool
apc_component_create( Handle self);

extern Bool
apc_component_destroy( Handle self);

extern Bool
apc_component_fullname_changed_notify( Handle self);

/* Window */
extern Bool
apc_window_create( Handle self, Handle owner, Bool syncPaint, int borderIcons, int borderStyle,
                   Bool taskList, int windowState, int onTop, Bool useOrigin, Bool useSize);

extern Bool
apc_window_activate( Handle self);

extern Bool
apc_window_is_active( Handle self);

extern Bool
apc_window_close( Handle self);

extern Handle
apc_window_get_active( void);

extern int
apc_window_get_border_icons( Handle self);

extern int
apc_window_get_border_style( Handle self);

extern ApiHandle
apc_window_get_client_handle( Handle self);

extern Point
apc_window_get_client_pos( Handle self);

extern Point
apc_window_get_client_size( Handle self);

extern Bool
apc_window_get_icon( Handle self, Handle icon);

extern Bool
apc_window_get_on_top( Handle self);

extern int
apc_window_get_window_state( Handle self);

extern Bool
apc_window_get_task_listed( Handle self);

extern Bool
apc_window_set_caption( Handle self, const char* caption, Bool utf8);

extern Bool
apc_window_set_client_pos( Handle self, int x, int y);

extern Bool
apc_window_set_client_rect( Handle self, int x, int y, int width, int height);

extern Bool
apc_window_set_client_size( Handle self, int x, int y);

extern Bool
apc_window_set_menu( Handle self, Handle menu);

extern Bool
apc_window_set_icon( Handle self, Handle icon);

extern Bool
apc_window_set_window_state( Handle self, int state);

extern Bool
apc_window_execute( Handle self, Handle insertBefore);

extern Bool
apc_window_execute_shared( Handle self, Handle insertBefore);

extern Bool
apc_window_end_modal( Handle self);


/* Widget management */

typedef struct {
   /* common geometry fields */
   Handle         next;           /* dynamically filled linked list of pack slaves */
   Handle         in;             /* 'in' option */
   /* pack */
   Point          pad;            /* border padding */
   Point          ipad;           /* size increaze */
   Handle         order;          /* if non-nil, BEFORE or AFTER a widget */
   /* place */ 
   int x, y;
   float relX, relY;
   float relWidth, relHeight;

   /* bitwise fields */
   /* common */
   unsigned int   anchorx    : 2; /* 0 - left, 1 - center, 2 - right */
   unsigned int   anchory    : 2; /* 0 - bottom, 1 - center, 2 - top */
   /* pack */
   unsigned int   after      : 1; /* 0 - order is BEFORE; 1 - order is AFTER */
   unsigned int   expand     : 1; /* causes the allocation rectange to fill all remaining space */
   unsigned int   fillx      : 1; /* fill horizontal extent */
   unsigned int   filly      : 1; /* fill vertical extent */ 
   unsigned int   side       : 2; /* 0 - left, 1 - bottom, 2 - right, 3 - top */
   /* place */ 
   unsigned int   use_x      : 1;
   unsigned int   use_y      : 1;
   unsigned int   use_w      : 1;
   unsigned int   use_h      : 1;
   unsigned int   use_rx     : 1;
   unsigned int   use_ry     : 1;
   unsigned int   use_rw     : 1;
   unsigned int   use_rh     : 1;
} GeomInfo, *PGeomInfo;

extern Bool
apc_widget_create( Handle self, Handle owner, Bool syncPaint,
                   Bool clipOwner, Bool transparent, ApiHandle parentHandle);

extern Bool
apc_widget_begin_paint( Handle self, Bool insideOnPaint);

extern Bool
apc_widget_begin_paint_info( Handle self);

extern Bool
apc_widget_destroy( Handle self);

extern PFont
apc_widget_default_font( PFont copyTo);

extern Bool
apc_widget_end_paint( Handle self);

extern Bool
apc_widget_end_paint_info( Handle self);

extern Bool
apc_widget_get_clip_owner( Handle self);

extern Color
apc_widget_get_color( Handle self, int index);

extern Bool
apc_widget_get_first_click( Handle self);

extern Handle
apc_widget_get_focused( void);

extern ApiHandle
apc_widget_get_handle( Handle self);

extern Rect
apc_widget_get_invalid_rect( Handle self);

extern Handle
apc_widget_get_z_order( Handle self, int zOrderId);

extern ApiHandle
apc_widget_get_parent_handle( Handle self);

extern Point
apc_widget_get_pos( Handle self);

extern Bool
apc_widget_get_shape( Handle self, Handle mask);

extern Point
apc_widget_get_size( Handle self);

extern Bool
apc_widget_get_sync_paint( Handle self);

extern Bool
apc_widget_get_transparent( Handle self);

extern Bool
apc_widget_is_captured( Handle self);

extern Bool
apc_widget_is_enabled( Handle self);

extern Bool
apc_widget_is_exposed( Handle self);

extern Bool
apc_widget_is_focused( Handle self);

extern Bool
apc_widget_is_responsive( Handle self);

extern Bool
apc_widget_is_showing( Handle self);

extern Bool
apc_widget_is_visible( Handle self);

extern Bool
apc_widget_invalidate_rect( Handle self, Rect * rect);

extern Color
apc_widget_map_color( Handle self, Color color);

extern Bool
apc_widget_map_points( Handle self, Bool toScreen, int count, Point * points);

extern Bool
apc_widget_scroll( Handle self, int horiz, int vert,
                   Rect *confine, Rect *clip,
                   Bool scrollChildren);

extern Bool
apc_widget_set_capture( Handle self, Bool capture, Handle confineTo);

extern Bool
apc_widget_set_color( Handle self, Color color, int index);

extern Bool
apc_widget_set_enabled( Handle self, Bool enable);

extern Bool
apc_widget_set_first_click( Handle self, Bool firstClick);

extern Bool
apc_widget_set_focused( Handle self);

extern Bool
apc_widget_set_font( Handle self, PFont font);

extern Bool
apc_widget_set_palette( Handle self);

extern Bool
apc_widget_set_pos( Handle self, int x, int y);

extern Bool
apc_widget_set_rect( Handle self, int x, int y, int width, int height);

extern Bool
apc_widget_set_shape( Handle self, Handle mask);

extern Bool
apc_widget_set_size( Handle self, int width, int height);

extern Bool
apc_widget_set_size_bounds( Handle self, Point min, Point max);

extern Bool
apc_widget_set_visible( Handle self, Bool show);

extern Bool
apc_widget_set_z_order( Handle self, Handle behind, Bool top);

extern Bool
apc_widget_update( Handle self);

extern Bool
apc_widget_validate_rect( Handle self, Rect rect);

/* standard system pointers */
#define CR(const_name) CONSTANT(cr,const_name)
START_TABLE(cr,IV)
#define crDefault      -1
CR(Default)
#define crArrow        0
CR(Arrow)
#define crText         1
CR(Text)
#define crWait         2
CR(Wait)
#define crSize         3
CR(Size)
#define crMove         4
CR(Move)
#define crSizeWest     5
CR(SizeWest)
#define crSizeW        crSizeWest
CR(SizeW)
#define crSizeEast     6
CR(SizeEast)
#define crSizeE        crSizeEast
CR(SizeE)
#define crSizeWE       7
CR(SizeWE)
#define crSizeNorth    8
CR(SizeNorth)
#define crSizeN        crSizeNorth
CR(SizeN)
#define crSizeSouth    9
CR(SizeSouth)
#define crSizeS        crSizeSouth
CR(SizeS)
#define crSizeNS       10
CR(SizeNS)
#define crSizeNW       11
CR(SizeNW)
#define crSizeSE       12
CR(SizeSE)
#define crSizeNE       13
CR(SizeNE)
#define crSizeSW       14
CR(SizeSW)
#define crInvalid      15
CR(Invalid)
#define crUser         16
CR(User)
END_TABLE(cr,UV)
#undef CR

/* Widget attributes */
extern Bool
apc_cursor_set_pos( Handle self, int x, int y);

extern Bool
apc_cursor_set_size( Handle self, int x, int y);

extern Bool
apc_cursor_set_visible( Handle self, Bool visible);

extern Point
apc_cursor_get_pos( Handle self);

extern Point
apc_cursor_get_size( Handle self);

extern Bool
apc_cursor_get_visible( Handle self);

extern Point
apc_pointer_get_hot_spot( Handle self);

extern Point
apc_pointer_get_pos( Handle self);

extern int
apc_pointer_get_shape( Handle self);

extern Point
apc_pointer_get_size( Handle self);

extern Bool
apc_pointer_get_bitmap( Handle self, Handle icon);

extern Bool
apc_pointer_get_visible( Handle self);

extern Bool
apc_pointer_set_pos( Handle self, int x, int y);

extern Bool
apc_pointer_set_shape( Handle self, int sysPtrId);

extern Bool
apc_pointer_set_user( Handle self, Handle icon, Point hotSpot);

extern Bool
apc_pointer_set_visible( Handle self, Bool visible);

extern int
apc_pointer_get_state( Handle self);

extern int
apc_kbd_get_state( Handle self);

/* Clipboard */
#define cfText     0
#define cfBitmap   1
#define cfImage    cfBitmap
#define cfUTF8     2
#define cfCustom   3

typedef struct {
   Handle image;
   Byte * data;
   STRLEN length;
} ClipboardDataRec, *PClipboardDataRec;

extern PList
apc_get_standard_clipboards( void);

extern Bool
apc_clipboard_create( Handle self);

extern Bool
apc_clipboard_destroy( Handle self);

extern Bool
apc_clipboard_open( Handle self);

extern Bool
apc_clipboard_close( Handle self);

extern Bool
apc_clipboard_clear( Handle self);

extern Bool
apc_clipboard_has_format( Handle self, Handle id);

extern Bool
apc_clipboard_get_data( Handle self, Handle id, PClipboardDataRec c);

extern ApiHandle
apc_clipboard_get_handle( Handle self);

extern Bool
apc_clipboard_set_data( Handle self, Handle id, PClipboardDataRec c);

extern Handle
apc_clipboard_register_format( Handle self, const char *format);

extern Bool
apc_clipboard_deregister_format( Handle self, Handle id);

/* Menus & popups */

typedef struct _MenuItemReg {   /* Menu item registration record */
   char * variable;             /* perl variable name */
   char * text;                 /* menu text */
   char * accel;                /* accelerator text */
   int    key;                  /* accelerator key, kbXXX */
   int    id;                   /* unique id */
   char * perlSub;              /* sub name */
   Handle bitmap;               /* bitmap if not nil */
   SV *   code;                 /* code if not nil */
   SV *   data;                 /* use data if not nil */
   struct _MenuItemReg* down;   /* pointer to submenu */
   struct _MenuItemReg* next;   /* pointer to next item */
   struct {
      unsigned int checked       : 1;  /* true if item is checked */
      unsigned int disabled      : 1;  /* true if item is disabled */
      unsigned int rightAdjust   : 1;  /* true if right adjust ordered */
      unsigned int divider       : 1;  /* true if it's line divider */
      unsigned int utf8_variable : 1;
      unsigned int utf8_text     : 1;
      unsigned int utf8_accel    : 1;
      unsigned int utf8_perlSub  : 1;
   } flags;
} MenuItemReg, *PMenuItemReg;

extern Bool
apc_menu_create( Handle self, Handle owner);

extern Bool
apc_menu_update( Handle self, PMenuItemReg oldBranch, PMenuItemReg newBranch);

extern Bool
apc_menu_destroy( Handle self);

extern PFont
apc_menu_default_font( PFont font);

extern Color
apc_menu_get_color( Handle self, int index);

extern PFont
apc_menu_get_font( Handle self, PFont font);

extern Bool
apc_menu_set_color( Handle self, Color color, int index);

extern Bool
apc_menu_set_font( Handle self, PFont font);

extern Bool
apc_menu_item_delete( Handle self, PMenuItemReg m);

extern Bool
apc_menu_item_set_accel( Handle self, PMenuItemReg m);

extern Bool
apc_menu_item_set_check( Handle self, PMenuItemReg m);

extern Bool
apc_menu_item_set_enabled( Handle self, PMenuItemReg m);

extern Bool
apc_menu_item_set_image( Handle self, PMenuItemReg m);

extern Bool
apc_menu_item_set_key( Handle self, PMenuItemReg m);

extern Bool
apc_menu_item_set_text( Handle self, PMenuItemReg m);

extern ApiHandle
apc_menu_get_handle( Handle self);

extern Bool
apc_popup_create( Handle self, Handle owner);

extern PFont
apc_popup_default_font( PFont font);

extern Bool
apc_popup( Handle self, int x, int y, Rect * anchor);

/* Timer */
extern Bool
apc_timer_create( Handle self, Handle owner, int timeout);

extern Bool
apc_timer_destroy( Handle self);

extern int
apc_timer_get_timeout( Handle self);

extern Bool
apc_timer_set_timeout( Handle self, int timeout);

extern Bool
apc_timer_start( Handle self);

extern Bool
apc_timer_stop( Handle self);

extern ApiHandle
apc_timer_get_handle( Handle self);

/* Messages */
#define mbError        0x0100
#define mbWarning      0x0200
#define mbInformation  0x0400
#define mbQuestion     0x0800

extern Bool
apc_message( Handle self, PEvent ev, Bool post);

extern Bool
apc_show_message( const char* message, Bool utf8);


/* graphics constants */
#define ARGB(r,g,b) ((uint32_t)(((unsigned char)(b)|((uint32_t)((unsigned char)(g))<<8))|(((uint32_t)((unsigned char)(r)))<<16)))

/* colors */
#define CL(const_name) CONSTANT(cl,const_name)
START_TABLE(cl,UV)
#define    clBlack            ARGB(0,0,0)
CL(Black)
#define    clBlue             ARGB(0,0,128)
CL(Blue)
#define    clGreen            ARGB(0,128,0)
CL(Green)
#define    clCyan             ARGB(0,128,128)
CL(Cyan)
#define    clRed              ARGB(128,0,0)
CL(Red)
#define    clMagenta          ARGB(128,0,128)
CL(Magenta)
#define    clBrown            ARGB(128,128,0)
CL(Brown)
#define    clLightGray        ARGB(192,192,192)
CL(LightGray)
#define    clDarkGray         ARGB(63,63,63)
CL(DarkGray)
#define    clLightBlue        ARGB(0,0,255)
CL(LightBlue)
#define    clLightGreen       ARGB(0,255,0)
CL(LightGreen)
#define    clLightCyan        ARGB(0,255,255)
CL(LightCyan)
#define    clLightRed         ARGB(255,0,0)
CL(LightRed)
#define    clLightMagenta     ARGB(255,0,255)
CL(LightMagenta)
#define    clYellow           ARGB(255,255,0)
CL(Yellow)
#define    clWhite            ARGB(255,255,255)
CL(White)
#define    clGray             ARGB(128,128,128)
CL(Gray)
#define    clSysFlag          (uint32_t)(0x10000000)
CL(SysFlag)
#define    clSysMask          (uint32_t)(0xEFFFFFFF)
CL(SysMask)
#define    clInvalid          (uint32_t)(0x10000000)
CL(Invalid)
#define    clNormalText       (uint32_t)(0x10000001)
CL(NormalText)
#define    clFore             (uint32_t)(0x10000001)
CL(Fore)
#define    clNormal           (uint32_t)(0x10000002)
CL(Normal)
#define    clBack             (uint32_t)(0x10000002)
CL(Back)
#define    clHiliteText       (uint32_t)(0x10000003)
CL(HiliteText)
#define    clHilite           (uint32_t)(0x10000004)
CL(Hilite)
#define    clDisabledText     (uint32_t)(0x10000005)
CL(DisabledText)
#define    clDisabled         (uint32_t)(0x10000006)
CL(Disabled)
#define    clLight3DColor     (uint32_t)(0x10000007)
CL(Light3DColor)
#define    clDark3DColor      (uint32_t)(0x10000008)
CL(Dark3DColor)
#define    clSet              (uint32_t)(0x10000009)
CL(Set)
#define    clClear            (uint32_t)(0x1000000A)
CL(Clear)
#define    clMaxSysColor      (uint32_t)(0x1000000A)
CL(MaxSysColor)
END_TABLE(cl,UV)
#undef CL

/* color indices */
#define CI(const_name) CONSTANT(ci,const_name)
START_TABLE(ci,UV)
#define    ciNormalText    0
CI(NormalText)
#define    ciFore          0
CI(Fore)
#define    ciNormal        1
CI(Normal)
#define    ciBack          1
CI(Back)
#define    ciHiliteText    2
CI(HiliteText)
#define    ciHilite        3
CI(Hilite)
#define    ciDisabledText  4
CI(DisabledText)
#define    ciDisabled      5
CI(Disabled)
#define    ciLight3DColor  6
CI(Light3DColor)
#define    ciDark3DColor   7
CI(Dark3DColor)
#define    ciMaxId         7
CI(MaxId)
END_TABLE(ci,UV)
#undef CI

typedef Color ColorSet[ ciMaxId + 1];

/* raster operations */
typedef enum {
   ropCopyPut = 0,      /* dest  = src */
   ropXorPut,           /* dest ^= src */
   ropAndPut,           /* dest &= src */
   ropOrPut,            /* dest |= src */
   ropNotPut,           /* dest = !src */
   ropInvert,           /* dest = !dest*/
   ropBlackness,        /* dest = 0 */
   ropNotDestAnd,       /* dest = (!dest) & src */
   ropNotDestOr,        /* dest = (!dest) | src */
   ropWhiteness,        /* dest = 1 */
   ropNotSrcAnd,        /* dest &= !src */
   ropNotSrcOr,         /* dest |= !src */
   ropNotXor,           /* dest = !(src ^ dest) */
   ropNotAnd,           /* dest = !(src & dest) */
   ropNotOr,            /* dest = !(src | dest) */
   ropNoOper            /* dest = dest */
} ROP;


#define ropNotSrcXor  ropNotXor    /* dest ^= !src */
#define ropNotDestXor ropNotXor    /* dest  = !dest ^ src */

#define ROP(const_name) CONSTANT(rop,const_name)

START_TABLE(rop,UV)
ROP(Blackness) ROP(NotOr) ROP(NotSrcAnd) ROP(NotPut) ROP(NotDestAnd)
ROP(Invert) ROP(XorPut) ROP(NotAnd) ROP(AndPut) ROP(NotXor) ROP(NoOper)
ROP(NotSrcOr) ROP(CopyPut) ROP(NotDestOr) ROP(OrPut) ROP(Whiteness)
ROP(NotSrcXor) ROP(NotDestXor)
END_TABLE(rop,UV)
#undef ROP

/* line ends */
#define LE(const_name) CONSTANT(le,const_name)
START_TABLE(le,UV)
#define    leFlat           0
LE(Flat)
#define    leSquare         1
LE(Square)
#define    leRound          2
LE(Round)
END_TABLE(le,UV)
#undef LE

/* line joins */
#define LJ(const_name) CONSTANT(lj,const_name)
START_TABLE(lj,UV)
#define    ljRound          0
LJ(Round)
#define    ljBevel          1
LJ(Bevel)
#define    ljMiter          2
LJ(Miter)
END_TABLE(lj,UV)
#undef LJ

/* line patterns */
#define LP(const_name) CONSTANT(lp,const_name)
START_TABLE(lp,unsigned char*)
#define    lpNull           (unsigned char*) ""              /* */
LP(Null)
#define    lpSolid          (unsigned char*) "\1"            /* ___________  */
LP(Solid)
#define    lpDash           (unsigned char*) "\x9\3"         /* __ __ __ __  */
LP(Dash)
#define    lpLongDash       (unsigned char*) "\x16\6"        /* _____ _____  */
LP(LongDash)
#define    lpShortDash      (unsigned char*) "\3\3"          /* _ _ _ _ _ _  */
LP(ShortDash)
#define    lpDot            (unsigned char*) "\1\3"          /* . . . . . .  */
LP(Dot)
#define    lpDotDot         (unsigned char*) "\1\1"          /* ............ */
LP(DotDot)
#define    lpDashDot        (unsigned char*) "\x9\6\1\3"     /* _._._._._._  */
LP(DashDot)
#define    lpDashDotDot     (unsigned char*) "\x9\3\1\3\1\3" /* _.._.._.._.. */
LP(DashDotDot)
END_TABLE_CHAR(lp,unsigned char*)
#undef LP

/* font styles */
#define FS(const_name) CONSTANT(fs,const_name)
START_TABLE(fs,UV)
#define    fsNormal         0x0000
FS(Normal)
#define    fsBold           0x0001
FS(Bold)
#define    fsThin           0x0002
FS(Thin)
#define    fsItalic         0x0004
FS(Italic)
#define    fsUnderlined     0x0008
FS(Underlined)
#define    fsStruckOut      0x0010
FS(StruckOut)
#define    fsOutline        0x0020
FS(Outline)
END_TABLE(fs,UV)
#undef FS

/* font pitches */
#define FP(const_name) CONSTANT(fp,const_name)
START_TABLE(fp,UV)
#define    fpDefault        0x0000
FP(Default)
#define    fpVariable       0x0001
FP(Variable)
#define    fpFixed          0x0002
FP(Fixed)

/* fill constants */
#define    fpEmpty          0 /*   Uses background color */
FP(Empty)
#define    fpSolid          1 /*   Uses draw color fill */
FP(Solid)
#define    fpLine           2 /*   --- */
FP(Line)
#define    fpLtSlash        3 /*   /// */
FP(LtSlash)
#define    fpSlash          4 /*   /// thick */
FP(Slash)
#define    fpBkSlash        5 /*   \\\ thick */
FP(BkSlash)
#define    fpLtBkSlash      6 /*   \\\ light */
FP(LtBkSlash)
#define    fpHatch          7 /*   Light hatch */
FP(Hatch)
#define    fpXHatch         8 /*   Heavy cross hatch */
FP(XHatch)
#define    fpInterleave     9 /*   Interleaving line */
FP(Interleave)
#define    fpWideDot       10 /*   Widely spaced dot */
FP(WideDot)
#define    fpCloseDot      11 /*   Closely spaced dot */
FP(CloseDot)
#define    fpSimpleDots    12 /*   . . . . . . . . . . */
FP(SimpleDots)
#define    fpBorland       13 /*   #################### */
FP(Borland)
#define    fpParquet       14 /*   \/\/\/\/\/\/\/\/\/\/ */
FP(Parquet)
#define    fpCritters      15 /*   critters */
FP(Critters)
#define    fpMaxId         15
FP(MaxId)
END_TABLE(fp,UV)
#undef FP

/* font weigths */
#define FW(const_name) CONSTANT(fw,const_name)
START_TABLE(fw,UV)
#define    fwUltraLight     1
FW(UltraLight)
#define    fwExtraLight     2
FW(ExtraLight)
#define    fwLight          3
FW(Light)
#define    fwSemiLight      4
FW(SemiLight)
#define    fwMedium         5
FW(Medium)
#define    fwSemiBold       6
FW(SemiBold)
#define    fwBold           7
FW(Bold)
#define    fwExtraBold      8
FW(ExtraBold)
#define    fwUltraBold      9
FW(UltraBold)
END_TABLE(fw,UV)
#undef FW

#define FONT_UTF8_NAME           0x001
#define FONT_UTF8_FAMILY         0x002
#define FONT_UTF8_ENCODING       0x004

#define IM(const_name) CONSTANT(im,const_name)
START_TABLE(im,UV)
#define    imNone                0
IM(None)
#define    imbpp1                0x001
IM(bpp1)
#define    imbpp4                0x004
IM(bpp4)
#define    imbpp8                0x008
IM(bpp8)
#define    imbpp16               0x010
IM(bpp16)
#define    imbpp24               0x018
IM(bpp24)
#define    imbpp32               0x020
IM(bpp32)
#define    imbpp64               0x040
IM(bpp64)
#define    imbpp128              0x080
IM(bpp128)
#define    imBPP                 0x0FF
IM(BPP)

#define    imColor               0x0000
IM(Color)
#define    imGrayScale           0x1000
IM(GrayScale)
#define    imRealNumber          0x2000
IM(RealNumber)
#define    imComplexNumber       0x4000
IM(ComplexNumber)
#define    imTrigComplexNumber   0x8000
IM(TrigComplexNumber)
#define    imCategory            0xFF00
IM(Category)


#define    imFMT                 0xFF0000
 IM(FMT)

/* imbpp24 subformats */
#define    imfmtRGB              0x000000
 IM(fmtRGB)
#define    imfmtBGR              0x010000
 IM(fmtBGR)

/* imbpp32 subformats */
#define    imfmtRGBI             0x000000
 IM(fmtRGBI)
#define    imfmtIRGB             0x010000
 IM(fmtIRGB)
#define    imfmtBGRI             0x020000
 IM(fmtBGRI)
#define    imfmtIBGR             0x030000
 IM(fmtIBGR)

/* Shortcuts and composites */
#define    imMono           imbpp1
IM(Mono)
#define    imBW             (imMono|imGrayScale)
IM(BW)
#define    im16             imbpp4
IM(16)
#define    imNibble         im16
IM(Nibble)
#define    im256            imbpp8
IM(256)
#define    imRGB            imbpp24
IM(RGB)
#define    imTriple         imRGB
IM(Triple)
#define    imByte           (imbpp8|imGrayScale)
IM(Byte)
#define    imShort          (imbpp16|imGrayScale)
IM(Short)
#define    imLong           (imbpp32|imGrayScale)
IM(Long)
#define    imFloat          ((sizeof(float)*8)|imGrayScale|imRealNumber)
IM(Float)
#define    imDouble         ((sizeof(double)*8)|imGrayScale|imRealNumber)
IM(Double)
#define    imComplex        ((sizeof(float)*8*2)|imGrayScale|imComplexNumber)
IM(Complex)
#define    imDComplex       ((sizeof(double)*8*2)|imGrayScale|imComplexNumber)
IM(DComplex)
#define    imTrigComplex    ((sizeof(float)*8*2)|imGrayScale|imTrigComplexNumber)
IM(TrigComplex)
#define    imTrigDComplex   ((sizeof(double)*8*2)|imGrayScale|imTrigComplexNumber)
IM(TrigDComplex)
END_TABLE(im,UV)
#undef IM

/* Image statistics constants */
#define IS(const_name) CONSTANT(is,const_name)
START_TABLE(is,UV)
#define isRangeLo        0
IS(RangeLo)
#define isRangeHi        1
IS(RangeHi)
#define isMean           2
IS(Mean)
#define isVariance       3
IS(Variance)
#define isStdDev         4
IS(StdDev)
#define isSum            5
IS(Sum)
#define isSum2           6
IS(Sum2)
#define isMaxIndex       6
IS(MaxIndex)
END_TABLE(is,UV)
#undef IS

/* Image conversion types */
#define ICT(const_name) CONSTANT(ict,const_name)
START_TABLE(ict,UV)
#define    ictNone               0
ICT(None)
#define    ictOrdered            1
ICT(Ordered)
#define    ictErrorDiffusion     2
ICT(ErrorDiffusion)
#define    ictOptimized          3
ICT(Optimized)
END_TABLE(ict,UV)
#undef ICT

/* Icon auto masking types */
#define AM(const_name) CONSTANT(am,const_name)
START_TABLE(am,UV)
#define    amNone               0
AM(None)
#define    amMaskColor           1
AM(MaskColor)
#define    amAuto                2
AM(Auto)
#define    amMaskIndex           3
AM(MaskIndex)
END_TABLE(am,UV)
#undef AM

/* image & bitmaps */
extern Bool
apc_image_create( Handle self);

extern Bool
apc_image_destroy( Handle self);

extern Bool
apc_image_begin_paint( Handle self);

extern Bool
apc_image_begin_paint_info( Handle self);

extern Bool
apc_image_end_paint( Handle self);

extern Bool
apc_image_end_paint_info( Handle self);

extern Bool
apc_image_update_change( Handle self);

extern const char *
apc_image_get_error_message( char *errorMsgBuf, int bufLen);

extern ApiHandle
apc_image_get_handle( Handle self);


extern Bool
apc_dbm_create( Handle self, Bool monochrome);

extern Bool
apc_dbm_destroy( Handle self);

extern ApiHandle
apc_dbm_get_handle( Handle self);

/* text wrap options */
#define TW(const_name) CONSTANT(tw,const_name)
START_TABLE(tw,UV)
#define twCalcMnemonic    0x001    /* calculate first ~ entry */
TW(CalcMnemonic)
#define twCalcTabs        0x002    /* calculate tabs */
TW(CalcTabs)
#define twBreakSingle     0x004    /* return single empty line if text cannot be fitted in */
TW(BreakSingle)
#define twNewLineBreak    0x008    /* break line at \n */
TW(NewLineBreak)
#define twSpaceBreak      0x010    /* break line at spaces */
TW(SpaceBreak)
#define twReturnLines     0x000    /* return wrapped lines */
TW(ReturnLines)
#define twReturnChunks    0x020    /* return array of offsets & lengths */
TW(ReturnChunks)
#define twWordBreak       0x040    /* break line at word boundary, if necessary */
TW(WordBreak)
#define twExpandTabs      0x080    /* expand tabs */
TW(ExpandTabs)
#define twCollapseTilde   0x100    /* remove ~ from line */
TW(CollapseTilde)
#define twReturnFirstLineLength 0x220
TW(ReturnFirstLineLength)
#define twDefault         (twNewLineBreak|twCalcTabs|twExpandTabs|twReturnLines|twWordBreak)
TW(Default)
END_TABLE(tw,UV)
#undef TW

/* find/replace dialog scope type */
#define FDS(const_name) CONSTANT(fds,const_name)
START_TABLE(fds,UV)
#define fdsCursor             0
FDS(Cursor)
#define fdsTop                1
FDS(Top)
#define fdsBottom             2
FDS(Bottom)
END_TABLE(fds,UV)
#undef FDS

/* find/replace dialog options */
#define FDO(const_name) CONSTANT(fdo,const_name)
START_TABLE(fdo,UV)
#define fdoMatchCase                0x01
FDO(MatchCase)
#define fdoWordsOnly                0x02
FDO(WordsOnly)
#define fdoRegularExpression        0x04
FDO(RegularExpression)
#define fdoBackwardSearch           0x08
FDO(BackwardSearch)
#define fdoReplacePrompt            0x10
FDO(ReplacePrompt)
END_TABLE(fdo,UV)
#undef FDO

/* System bitmaps index */
#define SBMP(const_name) CONSTANT(sbmp,const_name)
START_TABLE(sbmp,UV)
#define sbmpLogo                         0
SBMP(Logo)
#define sbmpCheckBoxChecked              1
SBMP(CheckBoxChecked)
#define sbmpCheckBoxCheckedPressed       2
SBMP(CheckBoxCheckedPressed)
#define sbmpCheckBoxUnchecked            3
SBMP(CheckBoxUnchecked)
#define sbmpCheckBoxUncheckedPressed     4
SBMP(CheckBoxUncheckedPressed)
#define sbmpRadioChecked                 5
SBMP(RadioChecked)
#define sbmpRadioCheckedPressed          6
SBMP(RadioCheckedPressed)
#define sbmpRadioUnchecked               7
SBMP(RadioUnchecked)
#define sbmpRadioUncheckedPressed        8
SBMP(RadioUncheckedPressed)
#define sbmpWarning                      9
SBMP(Warning)
#define sbmpInformation                 10
SBMP(Information)
#define sbmpQuestion                    11
SBMP(Question)
#define sbmpOutlineCollaps              12
SBMP(OutlineCollaps)
#define sbmpOutlineExpand               13
SBMP(OutlineExpand)
#define sbmpError                       14
SBMP(Error)
#define sbmpSysMenu                     15
SBMP(SysMenu)
#define sbmpSysMenuPressed              16
SBMP(SysMenuPressed)
#define sbmpMax                         17
SBMP(Max)
#define sbmpMaxPressed                  18
SBMP(MaxPressed)
#define sbmpMin                         19
SBMP(Min)
#define sbmpMinPressed                  20
SBMP(MinPressed)
#define sbmpRestore                     21
SBMP(Restore)
#define sbmpRestorePressed              22
SBMP(RestorePressed)
#define sbmpClose                       23
SBMP(Close)
#define sbmpClosePressed                24
SBMP(ClosePressed)
#define sbmpHide                        25
SBMP(Hide)
#define sbmpHidePressed                 26
SBMP(HidePressed)
#define sbmpDriveUnknown                27
SBMP(DriveUnknown)
#define sbmpDriveFloppy                 28
SBMP(DriveFloppy)
#define sbmpDriveHDD                    29
SBMP(DriveHDD)
#define sbmpDriveNetwork                30
SBMP(DriveNetwork)
#define sbmpDriveCDROM                  31
SBMP(DriveCDROM)
#define sbmpDriveMemory                 32
SBMP(DriveMemory)
#define sbmpGlyphOK                     33
SBMP(GlyphOK)
#define sbmpGlyphCancel                 34
SBMP(GlyphCancel)
#define sbmpSFolderOpened               35
SBMP(SFolderOpened)
#define sbmpSFolderClosed               36
SBMP(SFolderClosed)
#define sbmpLast                        36
SBMP(Last)
END_TABLE(sbmp,UV)
#undef SBMP

typedef struct _FontABC
{
   float a;
   float b;
   float c;
} FontABC, *PFontABC;

typedef struct _TextWrapRec {
   char * text;                        /* text to be wrapped */
   Bool   utf8_text;                   /* is utf8 */
   int    textLen;                     /* text length in bytes */
   int    utf8_textLen;                /* text length in characters */
   int    width;                       /* width to wrap with */
   int    tabIndent;                   /* \t replace to tabIndent spaces */
   int    options;                     /* twXXX constants */
   int    count;                       /* count of lines returned */
   int    t_start;                     /* ~ starting point */
   int    t_end;                       /* ~ ending point */
   int    t_line;                      /* ~ line */
   char * t_char;                      /* letter next to ~ */

   PFontABC * ascii;                   /* eventual abc caches, to be freed after call. */
   PList    * unicode;                 /* NB - .ascii can be present in .unicode ! */
} TextWrapRec, *PTextWrapRec;

/* gpi functions underplace */
extern Bool
apc_gp_init( Handle self);

extern Bool
apc_gp_done( Handle self);

extern Bool
apc_gp_arc( Handle self, int x, int y, int dX, int dY,
            double angleStart, double angleEnd);

extern Bool
apc_gp_bar( Handle self, int x1, int y1, int x2, int y2);

extern Bool
apc_gp_clear( Handle self, int x1, int y1, int x2, int y2);

extern Bool
apc_gp_chord( Handle self, int x, int y, int dX, int dY,
              double angleStart, double angleEnd);

extern Bool
apc_gp_draw_poly( Handle self, int numPts, Point * points);

extern Bool
apc_gp_draw_poly2( Handle self, int numPts, Point * points);

extern Bool
apc_gp_ellipse( Handle self, int x, int y, int dX, int dY);

extern Bool
apc_gp_fill_chord( Handle self, int x, int y, int dX, int dY,
                   double angleStart, double angleEnd);

extern Bool
apc_gp_fill_ellipse( Handle self, int x, int y, int dX, int dY);

extern Bool
apc_gp_fill_poly( Handle self, int numPts, Point * points);

extern Bool
apc_gp_fill_sector( Handle self, int x, int y, int dX, int dY,
                    double angleStart, double angleEnd);

extern Bool
apc_gp_flood_fill( Handle self, int x, int y, Color borderColor,
                   Bool singleBorder);

extern Color
apc_gp_get_pixel( Handle self, int x, int y);

extern Bool
apc_gp_line( Handle self, int x1, int y1, int x2, int y2);

extern Bool
apc_gp_put_image( Handle self, Handle image, int x, int y,
                  int xFrom, int yFrom, int xLen, int yLen, int rop);
extern Bool
apc_gp_rectangle( Handle self, int x1, int y1, int x2, int y2);

extern Bool
apc_gp_sector( Handle self, int x, int y, int dX, int dY,
               double angleStart, double angleEnd);

extern Bool
apc_gp_set_pixel( Handle self, int x, int y, Color color);

extern Bool
apc_gp_stretch_image( Handle self, Handle image,
                      int x, int y, int xFrom, int yFrom,
                      int xDestLen, int yDestLen, int xLen, int yLen,
                      int rop);

extern Bool
apc_gp_text_out( Handle self, const char * text, int x, int y, int len, Bool utf8);

/* gpi settings */
extern Color
apc_gp_get_back_color( Handle self);

extern int
apc_gp_get_bpp( Handle self);

extern Color
apc_gp_get_color( Handle self);

extern Rect
apc_gp_get_clip_rect( Handle self);

extern PFontABC
apc_gp_get_font_abc( Handle self, int firstChar, int lastChar, Bool unicode);

extern unsigned long *
apc_gp_get_font_ranges( Handle self, int * count);

extern Bool
apc_gp_get_fill_winding( Handle self);

extern FillPattern *
apc_gp_get_fill_pattern( Handle self);

extern ApiHandle
apc_gp_get_handle( Handle self);

extern int
apc_gp_get_line_end( Handle self);

extern int
apc_gp_get_line_join( Handle self);

extern int
apc_gp_get_line_width( Handle self);

extern int
apc_gp_get_line_pattern( Handle self, unsigned char * buffer);

extern Color
apc_gp_get_nearest_color( Handle self, Color color);

extern PRGBColor
apc_gp_get_physical_palette( Handle self, int * colors);

extern Bool
apc_gp_get_region( Handle self, Handle mask);

extern Point
apc_gp_get_resolution( Handle self);

extern int
apc_gp_get_rop( Handle self);

extern int
apc_gp_get_rop2( Handle self);

extern Point*
apc_gp_get_text_box( Handle self, const char * text, int len, Bool utf8);

extern Bool
apc_gp_get_text_opaque( Handle self);

extern int
apc_gp_get_text_width( Handle self, const char * text, int len, Bool addOverhang, Bool utf8);

extern Bool
apc_gp_get_text_out_baseline( Handle self);

extern Point
apc_gp_get_transform( Handle self);

extern Bool
apc_gp_set_back_color( Handle self, Color color);

extern Bool
apc_gp_set_clip_rect( Handle self, Rect clipRect);

extern Bool
apc_gp_set_color( Handle self, Color color);

extern Bool
apc_gp_set_fill_winding( Handle self, Bool fillWinding);

extern Bool
apc_gp_set_fill_pattern( Handle self, FillPattern pattern);

extern Bool
apc_gp_set_font( Handle self, PFont font);

extern Bool
apc_gp_set_line_end( Handle self, int lineEnd);

extern Bool
apc_gp_set_line_join( Handle self, int lineJoin);

extern Bool
apc_gp_set_line_width( Handle self, int lineWidth);

extern Bool
apc_gp_set_line_pattern( Handle self, unsigned char * pattern, int len);

extern Bool
apc_gp_set_palette( Handle self);

extern Bool
apc_gp_set_region( Handle self, Handle mask);

extern Bool
apc_gp_set_rop( Handle self, int rop);

extern Bool
apc_gp_set_rop2( Handle self, int rop);

extern Bool
apc_gp_set_transform( Handle self, int x, int y);

extern Bool
apc_gp_set_text_opaque( Handle self, Bool opaque);

extern Bool
apc_gp_set_text_out_baseline( Handle self, Bool baseline);

/* printer */
extern Bool
apc_prn_create( Handle self);

extern Bool
apc_prn_destroy( Handle self);

extern PrinterInfo*
apc_prn_enumerate( Handle self, int * count);

extern Bool
apc_prn_select( Handle self, const char* printer);

extern ApiHandle
apc_prn_get_handle( Handle self);

extern char*
apc_prn_get_selected( Handle self);

extern Point
apc_prn_get_size( Handle self);

extern Point
apc_prn_get_resolution( Handle self);

extern char*
apc_prn_get_default( Handle self);

extern Bool
apc_prn_setup( Handle self);

extern Bool
apc_prn_begin_doc( Handle self, const char* docName);

extern Bool
apc_prn_begin_paint_info( Handle self);

extern Bool
apc_prn_end_doc( Handle self);

extern Bool
apc_prn_end_paint_info( Handle self);

extern Bool
apc_prn_new_page( Handle self);

extern Bool
apc_prn_abort_doc( Handle self);

extern Bool
apc_prn_enum_options( Handle self, int * count, char *** options);

extern Bool
apc_prn_get_option( Handle self, char * option, char ** value);

extern Bool
apc_prn_set_option( Handle self, char * option, char * value);

/* fonts */
extern PFont
apc_font_default( PFont font);

extern int
apc_font_load( const char* filename);

extern Bool
apc_font_pick( Handle self, PFont source, PFont dest);

extern PFont
apc_fonts( Handle self, const char *facename, const char *encoding, int *retCount);

extern PHash
apc_font_encodings( Handle self);

/* system metrics */
extern Bool
apc_sys_get_insert_mode( void);

extern PFont
apc_sys_get_msg_font( PFont copyTo);

extern PFont
apc_sys_get_caption_font( PFont copyTo);

extern int
apc_sys_get_value( int sysValue);

extern Bool
apc_sys_set_insert_mode( Bool insMode);

/* file */
#define FE(const_name) CONSTANT(fe,const_name)
START_TABLE(fe,UV)
#define feRead      1
FE(Read)
#define feWrite     2
FE(Write)
#define feException 4
FE(Exception)
END_TABLE(fe,UV)
#undef FE

extern Bool
apc_file_attach( Handle self);

extern Bool
apc_file_detach( Handle self);

extern Bool
apc_file_change_mask( Handle self);

/* etc */
extern Bool
apc_beep( int style);

extern Bool
apc_beep_tone( int freq, int duration);

/* fetch resource constants */
#define FR(const_name) CONSTANT(fr,const_name)
START_TABLE(fr,UV)
#define frString    0
FR(String)
#define frColor     1
FR(Color)
#define frFont      2
FR(Font)
END_TABLE(fr,UV)
#undef FR

extern Bool
apc_fetch_resource( const char *className, const char *name,
                    const char *resClass, const char *res,
                    Handle owner, int resType,
                    void *val);

extern Color
apc_lookup_color( const char *colorName);

extern char *
apc_system_action( const char *params);

extern Bool
apc_query_drives_map( const char *firstDrive, char *result, int len);

extern int
apc_query_drive_type( const char *drive);

extern char*
apc_get_user_name( void);
extern PList
apc_getdir( const char *dirname);

extern Bool
apc_dl_export(char *path);


#define HOOK_EVENT_LOOP 0

typedef Bool PrimaHookProc( void * message);

extern  Bool
apc_register_hook( int hookType, void * hookProc);

extern  Bool
apc_deregister_hook( int hookType, void * hookProc);

extern  Bool
apc_register_event( void * sysMessage);

extern  Bool
apc_deregister_event( void * sysMessage);



/* Memory bugs debugging tools */
#ifdef PARANOID_MALLOC
extern void *
_test_malloc( size_t size, int ln, char *fil, Handle self);

extern void *
_test_realloc( void * ptr, size_t size, int ln, char *fil, Handle self);

extern void
_test_free( void *ptr, int ln, char *fil, Handle self);

#define plist_create( sz, delta) paranoid_plist_create( sz, delta, __FILE__, __LINE__)
#define list_create( slf, sz, delta) paranoid_list_create( slf, sz, delta, __FILE__, __LINE__)
extern PList
paranoid_plist_create( int, int, char *, int);

extern void
paranoid_list_create( PList, int, int, char *, int);

extern Handle self;

#undef malloc
#undef realloc
#undef free
#define realloc(ptr,sz) _test_realloc((ptr),(sz),__LINE__,__FILE__,self)
#define malloc(sz) _test_malloc((sz),__LINE__,__FILE__,self)
#define free(ptr) _test_free((ptr),__LINE__,__FILE__,self)
#endif /* PARANOID_MALLOC */

#if defined( USE_GC)
#if defined( HAVE_GC_H)
#define GC_DEBUG 1
#include <gc.h>
#undef malloc
#undef free
#undef realloc
#define malloc( sz) GC_MALLOC( sz)
#define free( p) GC_FREE( p)
#define realloc( old, sz) GC_REALLOC( old, sz)
#define CHECK_LEAKS GC_gcollect()
#else
#warning USE_GC requires presence of gc.h
#define CHECK_LEAKS
#endif /* HAVE_GC_H */
#else
#define CHECK_LEAKS
#endif /* USE_GC */

#ifdef __cplusplus
}
#endif

#endif

