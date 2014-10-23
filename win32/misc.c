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
 *
 * $Id$
 */
/* Created by Dmitry Karasik <dk@plab.ku.dk> */
#include "win32\win32guts.h"
#include <stdio.h>
#include <stdarg.h>
#ifndef _APRICOT_H_
#include "apricot.h"
#endif
#include "Component.h"

#ifdef __cplusplus
extern "C" {
#endif


static Handle ctx_mb2MB[] =
{
   mbError       , MB_ICONHAND,
   mbQuestion    , MB_ICONQUESTION,
   mbInformation , MB_ICONASTERISK,
   mbWarning     , MB_ICONEXCLAMATION,
   endCtx
};


Bool
apc_beep( int style)
{
   if ( !MessageBeep( ctx_remap_def( style, ctx_mb2MB, true, MB_OK))) apiErrRet;
   return true;
}

Bool
apc_beep_tone( int freq, int duration)
{
   if ( IS_NT) {
      if ( !Beep( freq, duration)) apiErrRet;
   } else {
      SYSTEM_INFO si;
      GetSystemInfo( &si);
      if ( 
#if defined( __BORLANDC__) && ! ( defined( __cplusplus) || defined( _ANONYMOUS_STRUCT))
           si. u. s. wProcessorArchitecture
#else
           si. wProcessorArchitecture
#endif
          != PROCESSOR_ARCHITECTURE_INTEL) {
         if ( !Beep( freq, duration)) apiErrRet;
         return true;
      }   
      if (( duration % 0x1234DC) == 0) return false;
      if ( freq < 20 || freq > 22000) {
         Sleep( duration);
         return true;
      }   
#if defined(_MSC_VER) && defined (_M_IX86)
      // Nastiest hack ever - Beep() doesn't work under W9X.
      __asm {
        in      al,0x61                  ;Stop sound, if any
        and     al, 0xfc
        out     0x61, al
        
        mov     ebx, freq
        mov     ax, 0x34DC
        mov     dx, 0x12
        div     bx                       ;Count (AX) = 0x1234DC div Hz
        mov     bx,ax                    ;Save Count in BX
        in      al,0x61                  ;Check the value in port 0x61
        test    al,3                     ;Bits 0 and 1 set if speaker is on
        jnz     SetCount                 ;If they are already on, continue

                                         ;Turn on speaker
        or      al,3                     ;Set bits 0 and 1
        out     0x61,al                  ;Change the value
        mov     al,182                   ;Tell the timer that the count is coming
        out     0x43,al                  ;by sending 182 to port 0x43

SetCount:
        mov     al,bl                    ;Low byte into AL
        out     0x42,al                  ;Load low order byte into port 0x42
        mov     al,bh                    ;High byte into AL
        out     0x42,al                  ;Load high order byte into port 0x42
      }   
      Sleep( duration);
      __asm {
         in     al, 0x61                ; Stop sound
         and    al, 0xfc
         out    0x61, al
      }    
#endif
   }   
   return true;
}

Bool
apc_query_drives_map( const char *firstDrive, char *map, int len)
{
   char *m = map;
   int beg;
   DWORD driveMap;
   int i;

#ifdef __CYGWIN__
   if ( !map || len <= 0) return true;
   *map = 0;
   return true;
#endif   
   if ( !map) return false;

   beg = toupper( *firstDrive);
   if (( beg < 'A') || ( beg > 'Z') || ( firstDrive[1] != ':'))
      return false;

   beg -= 'A';

   if ( !( driveMap = GetLogicalDrives()))
      apiErr;
   for ( i = beg; i < 26 && m - map + 3 < len; i++)
   {
      if ((driveMap << ( 31 - i)) >> 31)
      {
         *m++ = i + 'A';
         *m++ = ':';
         *m++ = ' ';
      }
   }

   *m = '\0';
   return true;
}

static Handle ctx_dt2DRIVE[] =
{
   dtUnknown  , 0               ,
   dtNone     , 1               ,
   dtFloppy   , DRIVE_REMOVABLE ,
   dtHDD      , DRIVE_FIXED     ,
   dtNetwork  , DRIVE_REMOTE    ,
   dtCDROM    , DRIVE_CDROM     ,
   dtMemory   , DRIVE_RAMDISK   ,
   endCtx
};

int
apc_query_drive_type( const char *drive)
{
   char buf[ 256];                        //  Win95 fix
#ifdef __CYGWIN__
   return false;
#endif   
   strncpy( buf, drive, 256);             //     sometimes D: isn't enough for 95,
   if ( buf[1] == ':' && buf[2] == 0) {   //     but ok for D:\.
      buf[2] = '\\';                      //
      buf[3] = 0;                         //
   }                                      //
   return ctx_remap_def( GetDriveType( buf), ctx_dt2DRIVE, false, dtNone);
}

static char userName[ 1024];

char *
apc_get_user_name()
{
   DWORD maxSize = 1024;

   if ( !GetUserName( userName, &maxSize)) apiErr;
   return userName;
}

PList
apc_getdir( const char *dirname)
{
#ifdef __CYGWIN__   
   DIR *dh;
   struct dirent *de;
   PList dirlist = nil;
   char *type, *dname;
   char path[ 2048];
   struct stat s;

   if ( *dirname == '/' && dirname[1] == '/') dirname++;
   if ( strcmp( dirname, "/") == 0)
      dname = "";
   else
      dname = ( char*) dirname;
      

   if (( dh = opendir( dirname)) && (dirlist = plist_create( 50, 50))) {
      while (( de = readdir( dh))) {
	 list_add( dirlist, (Handle)duplicate_string( de-> d_name));
         snprintf( path, 2047, "%s/%s", dname, de-> d_name);
         type = nil;
         if ( stat( path, &s) == 0) {
            switch ( s. st_mode & S_IFMT) {
            case S_IFIFO:        type = "fifo";  break;
            case S_IFCHR:        type = "chr";   break;
            case S_IFDIR:        type = "dir";   break;
            case S_IFBLK:        type = "blk";   break;
            case S_IFREG:        type = "reg";   break;
            case S_IFLNK:        type = "lnk";   break;
            case S_IFSOCK:       type = "sock";  break;
            }
         }
         if ( !type) type = "reg";
	 list_add( dirlist, (Handle)duplicate_string( type));
      }
      closedir( dh);
   }
   return dirlist;
#else   
    long		len;
    char		scanname[MAX_PATH+3];
    WIN32_FIND_DATA	FindData;
    HANDLE		fh;

    DWORD               fattrs;
    PList               ret;
    Bool                wasDot = false, wasDotDot = false;

#define add_entry(file,info)  {                         \
    list_add( ret, ( Handle) duplicate_string(file));   \
    list_add( ret, ( Handle) duplicate_string(info));   \
}

#define add_fentry  {                                                         \
    add_entry( FindData.cFileName,                                            \
       ( FindData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) ? DIR : FILE); \
    if ( strcmp( ".", FindData.cFileName) == 0)                               \
       wasDot = true;                                                         \
    else if ( strcmp( "..", FindData.cFileName) == 0)                         \
       wasDotDot = true;                                                      \
}


#define DIR  "dir"
#define FILE "reg"

    len = strlen(dirname);
    if (len > MAX_PATH)
	return NULL;

    /* check to see if filename is a directory */
    fattrs = GetFileAttributes( dirname);
    if ( fattrs == 0xFFFFFFFF || ( fattrs & FILE_ATTRIBUTE_DIRECTORY) == 0)
       return NULL;

    /* Create the search pattern */
    strcpy(scanname, dirname);
    if (scanname[len-1] != '/' && scanname[len-1] != '\\')
	scanname[len++] = '/';
    scanname[len++] = '*';
    scanname[len] = '\0';

    /* do the FindFirstFile call */
    fh = FindFirstFile(scanname, &FindData);
    if (fh == INVALID_HANDLE_VALUE) {
	/* FindFirstFile() fails on empty drives! */
	if (GetLastError() != ERROR_FILE_NOT_FOUND)
	   return NULL;
        ret = plist_create( 2, 16);
        add_entry( ".",  DIR);
        add_entry( "..", DIR);
        return ret;
    }

    ret = plist_create( 16, 16);
    add_fentry;
    while ( FindNextFile(fh, &FindData))
       add_fentry;
    FindClose(fh);

    if ( !wasDot)
       add_entry( ".",  DIR);
    if ( !wasDotDot)
       add_entry( "..", DIR);

#undef FILE
#undef DIR
    return ret;
#endif    
}

Bool
apc_show_message( const char * message, Bool utf8)
{
   Bool ret;
   if ( HAS_WCHAR && utf8 && (message = ( char*)alloc_utf8_to_wchar( message, -1))) {
      ret = MessageBoxW( NULL, ( WCHAR*) message, (WCHAR*) const_char2wchar( "Prima"), MB_OK | MB_TASKMODAL | MB_SETFOREGROUND) != 0;
      free(( void*) message); 
   } else
      ret = MessageBox( NULL, message, "Prima", MB_OK | MB_TASKMODAL | MB_SETFOREGROUND) != 0;
   return ret;
}

Bool
apc_sys_get_insert_mode()
{
   return guts. insertMode;
}

Bool
apc_sys_set_insert_mode( Bool insMode)
{
   guts. insertMode = insMode;
   return true;
}

Point
get_window_borders( int borderStyle)
{
   Point ret = { 0, 0};
   switch ( borderStyle)
   {
      case bsSizeable:
         ret. x = GetSystemMetrics( SM_CXFRAME);
         ret. y = GetSystemMetrics( SM_CYFRAME);
         break;
      case bsSingle:
         ret. x = GetSystemMetrics( SM_CXBORDER);
         ret. y = GetSystemMetrics( SM_CYBORDER);
         break;
      case bsDialog:
         ret. x = GetSystemMetrics( SM_CXDLGFRAME);
         ret. y = GetSystemMetrics( SM_CYDLGFRAME);
         break;
   }
   return ret;
}

int
apc_sys_get_value( int sysValue)
{
   HKEY hKey;
   DWORD valSize = 256, valType = REG_SZ;
   char buf[ 256] = "";

   switch ( sysValue) {
   case svYMenu          :
       return guts. ncmData. iMenuHeight;
   case svYTitleBar      :
       return guts. ncmData. iCaptionHeight;
   case svMousePresent   :
       return GetSystemMetrics( SM_MOUSEPRESENT);
   case svMouseButtons   :
       return GetSystemMetrics( SM_CMOUSEBUTTONS);
   case svSubmenuDelay   :
       RegOpenKeyEx( HKEY_CURRENT_USER, "Control Panel\\Desktop", 0, KEY_READ, &hKey);
       RegQueryValueEx( hKey, "MenuShowDelay", nil, &valType, ( LPBYTE) buf, &valSize);
       RegCloseKey( hKey);
       return atol( buf);
   case svFullDrag       :
       RegOpenKeyEx( HKEY_CURRENT_USER, "Control Panel\\Desktop", 0, KEY_READ, &hKey);
       RegQueryValueEx( hKey, "DragFullWindows", nil, &valType, ( LPBYTE)buf, &valSize);
       RegCloseKey( hKey);
       return atol( buf);
   case svDblClickDelay   :
       RegOpenKeyEx( HKEY_CURRENT_USER, "Control Panel\\Mouse", 0, KEY_READ, &hKey);
       RegQueryValueEx( hKey, "DoubleClickSpeed", nil, &valType, ( LPBYTE)buf, &valSize);
       RegCloseKey( hKey);
       return atol( buf);
   case svWheelPresent    : return GetSystemMetrics( SM_MOUSEWHEELPRESENT);
   case svXIcon           : return guts. iconSizeLarge. x;
   case svYIcon           : return guts. iconSizeLarge. y;
   case svXSmallIcon      : return guts. iconSizeSmall. x;
   case svYSmallIcon      : return guts. iconSizeSmall. y;
   case svXPointer        : return guts. pointerSize. x;
   case svYPointer        : return guts. pointerSize. y;
   case svXScrollbar      : return GetSystemMetrics( SM_CXHSCROLL);
   case svYScrollbar      : return GetSystemMetrics( SM_CYVSCROLL);
   case svXCursor         : return GetSystemMetrics( SM_CXBORDER);
   case svAutoScrollFirst : return 200;
   case svAutoScrollNext  : return 50;
   case svInsertMode      : return guts. insertMode;
   case svXbsNone         : return 0;
   case svYbsNone         : return 0;
   case svXbsSizeable     : return GetSystemMetrics( SM_CXFRAME);
   case svYbsSizeable     : return GetSystemMetrics( SM_CYFRAME);
   case svXbsSingle       : return GetSystemMetrics( SM_CXBORDER);
   case svYbsSingle       : return GetSystemMetrics( SM_CYBORDER);
   case svXbsDialog       : return GetSystemMetrics( SM_CXDLGFRAME);
   case svYbsDialog       : return GetSystemMetrics( SM_CYDLGFRAME);
   case svShapeExtension  : return 1;
   case svColorPointer    : return guts. displayBMInfo. bmiHeader. biBitCount > 4;
   case svCanUTF8_Input   : return HAS_WCHAR;
   case svCanUTF8_Output  : return HAS_WCHAR;
   default:
      return -1;
   }
   return 0;
}

PFont
apc_sys_get_msg_font( PFont copyTo)
{
   *copyTo = guts. msgFont;
   copyTo-> pitch = fpDefault;
   return copyTo;
}

PFont
apc_sys_get_caption_font( PFont copyTo)
{
   *copyTo = guts. capFont;
   copyTo-> pitch = fpDefault;
   return copyTo;
}

Bool
hwnd_check_limits( int x, int y, Bool uint)
{
   if ( x > 16383 || y > 16383) return false;
   if ( uint && ( x < -16383 || y < -16383)) return false;
   return true;
}

#define rgxExists      1
#define rgxNotExists   2
#define rgxHasSubkeys  4
#define rgxHasValues   8
#define rgxInUser      16
#define rgxInSys       32

static Bool
prf_exists( HKEY hk, char * path, int * info)
{
   HKEY hKey;
   Handle cache;
   if (( cache = ( Handle) hash_fetch( regnodeMan, path, strlen( path)))) {
      if ( info) *info = cache;
      return cache & rgxExists;
   }

   if ( RegOpenKeyEx( hk, path, 0,
                      KEY_READ, &hKey) != ERROR_SUCCESS) {
       hash_store( regnodeMan, path, strlen( path), (void*) rgxNotExists);
       return false;
   }

   cache |= rgxExists;
   if ( info) {
      char buf[ MAXREGLEN];
      DWORD len = MAXREGLEN, subkeys = 0, msk, mc, values, mvn, mvd, sd;
      FILETIME ft;
      RegQueryInfoKey( hKey, buf, &len, NULL, &subkeys, &msk, &mc, &values,
         &mvn, &mvd, &sd, &ft);
      if ( subkeys > 0) cache |= rgxHasSubkeys;
      if ( values  > 0) cache |= rgxHasValues;
      *info = cache;
   }
   hash_store( regnodeMan, path, strlen( path), (void*) cache);
   RegCloseKey( hKey);
   return true;
}

static Bool
prf_find( HKEY hk, char * path, List * ids, int firstName, char * result)
{
   char buf[ MAXREGLEN];
   int j = 2, info;

   while ( j--) {
      snprintf( buf, MAXREGLEN, "%s\\%s", path, ( char*) ids[j].items[ firstName]);
      if ( prf_exists( hk, buf, nil)) {
         if ( ids[j].count > firstName + 1) {
            if ( prf_find( hk, buf, ids, firstName + 1, result))
               return true;
         } else {
            strcpy( result, buf);
            return true;
         }
      }
   }

   j = 2;
   while ( j--) {
      snprintf( buf, MAXREGLEN, "%s\\*", path);
      if ( prf_exists( hk, buf, &info)) {
         if ( info & rgxHasSubkeys) {
            int i;
            for ( i = ids[j].count - 1; i >= firstName; i--) {
               if ( prf_find( hk, buf, ids, i, result))
                  return true;
            }
         }
         if (( info & rgxHasValues) == 0)
            return false;
         strcpy( result, buf);
         return true;
      }
   }
   return false;
}


Bool
apc_fetch_resource( const char *className, const char *name,
                    const char *resClass, const char *resName,
                    Handle owner, int resType,
                    void *val)
{
   Bool res = true;
   HKEY hKey;
   char buf[ MAXREGLEN];
   DWORD type, size, i;
   List ids[ 2];

   i = 2; while( i--) list_create(&ids[i], 8, 8);

   list_add(&ids[1], ( Handle) duplicate_string( name));
   list_add(&ids[0], ( Handle) duplicate_string( className));

   while ( owner) {
      list_insert_at(&ids[1],   ( Handle) prima_normalize_resource_string(
         duplicate_string( PComponent( owner)-> name), false), 0);
      list_insert_at(&ids[0], ( Handle) prima_normalize_resource_string(
         duplicate_string(
            ( owner == application) ? "Prima" : CComponent( owner)-> className
         ), true), 0);
      owner = PComponent( owner)-> owner;
   }

   if (!( res = prf_find( HKEY_CURRENT_USER, REG_STORAGE, ( List *) &ids, 0, buf)))
      goto FINALIZE;

   if ( RegOpenKeyEx( HKEY_CURRENT_USER, buf, 0, KEY_READ, &hKey) != ERROR_SUCCESS) {
      res = false;
      goto FINALIZE;
   }

   switch ( resType) {
   case frString:
      type = REG_SZ;
      size = MAXREGLEN;
      if ( RegQueryValueEx( hKey, resName, NULL,
           &type, ( LPBYTE) buf, &size) == ERROR_SUCCESS) {
         char **x = ( char **) val;
         *x = duplicate_string( buf);
      } else
      if ( RegQueryValueEx( hKey, resClass, NULL,
           &type, ( LPBYTE) buf, &size) == ERROR_SUCCESS) {
         char **x = ( char **) val;
         *x = duplicate_string( buf);
      } else
         res = false;
      break;
   case frFont:
      type = REG_SZ;
      size = MAXREGLEN;
      if ( RegQueryValueEx( hKey, resName, NULL,
           &type, ( LPBYTE) buf, &size) == ERROR_SUCCESS)
         font_pp2font( buf, ( Font *) val);
      else
      if ( RegQueryValueEx( hKey, resClass, NULL,
           &type, ( LPBYTE) buf, &size) == ERROR_SUCCESS)
         font_pp2font( buf, ( Font *) val);
      else
         res = false;
      break;
   case frColor:
      type = REG_DWORD;
      size = sizeof( DWORD);
      if ( RegQueryValueEx( hKey, resName, NULL,
           &type, ( LPBYTE) val, &size) != ERROR_SUCCESS)
         res = ( RegQueryValueEx( hKey, resClass, NULL,
           &type, ( LPBYTE) val, &size) == ERROR_SUCCESS);
      else
         res = false;
   }

   RegCloseKey( hKey);

FINALIZE:

   i = 2;
   while( i--) {
      list_delete_all( &ids[i], true);
      list_destroy( &ids[i]);
   }
   return res;
}

Bool
apc_dl_export(char *path)
{
   return LoadLibrary( path) != NULL;
}   

void
utf8_to_wchar( const char * utf8, WCHAR * u16, int length)
{
   STRLEN charlen;
   while ( length--) {
      register UV u = ( utf8_to_uvchr(( U8*) utf8, &charlen));
      *(u16++) = ( u < 0x10000) ? u : 0xffff;
      utf8 += charlen;
   }
}

WCHAR *
alloc_utf8_to_wchar( const char * utf8, int length)
{
   WCHAR * ret;
   if ( utf8 == NULL ) utf8 = "";
   if ( length < 0) length = prima_utf8_length( utf8) + 1;
   if ( !( ret = malloc( length * sizeof( WCHAR)))) return nil;
   utf8_to_wchar( utf8, ret, length);
   return ret;
}

void 
wchar2char( char * dest, WCHAR * src, int lim)
{
   if ( lim < 1) return;
   while ( lim-- && *src) *(dest++) = *((char*)src++);
   if ( lim < 0) dest--;
   *dest = 0;
}

void 
char2wchar( WCHAR * dest, char * src, int lim)
{
   int l = strlen( src) + 1;
   if ( lim < 0) lim = l;
   if ( lim == 0) return;
   if ( lim > l) lim = l;
   src  += lim - 2;
   dest += lim - 1;
   *(dest--) = 0;
   while ( --lim) *(dest--) = *(src--);
}

static WCHAR wbuf[256];

const WCHAR *
const_char2wchar( const char * src)
{
    char2wchar( wbuf, (char*)src, 256);
    return wbuf;
}

WCHAR *
alloc_char_to_wchar( const char * text, int length)
{
   WCHAR * ret;
   if ( text == NULL ) text = "";
   if ( length < 0) length = strlen( text) + 1;
   if ( !( ret = malloc( length * sizeof( WCHAR)))) return nil;
   char2wchar( ret, (char*) text, length);
   return ret;
}

#ifdef __cplusplus
}
#endif
