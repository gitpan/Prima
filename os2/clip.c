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
 * $Id: clip.c,v 1.16 2002/05/14 13:22:31 dk Exp $
 */
/* Created by Dmitry Karasik <dk@plab.ku.dk> */
/* apc.c --- apc/ api for os/2 */
#include <limits.h>
#define INCL_GPIBITMAPS
#define INCL_GPICONTROL
#define INCL_DOSFILEMGR
#define INCL_DOSERRORS
#define INCL_DOSDEVIOCTL
#include "os2/os2guts.h"
#include "Image.h"
#include "Application.h"
#include "Clipboard.h"
#define  sys (( PDrawableData)(( PComponent) self)-> sysData)->
#define  dsys( view) (( PDrawableData)(( PComponent) view)-> sysData)->
#define var (( PWidget) self)->
#define HANDLE  (( sys className == WC_FRAME) ? WinQueryWindow( var handle, QW_PARENT) : var handle)
#define DHANDLE( view) (((( PDrawableData)(( PComponent) view)-> sysData)->className == WC_FRAME) ? WinQueryWindow((( PWidget) view)->handle, QW_PARENT) : (( PWidget) view)->handle)

PList
apc_get_standard_clipboards( void)
{
   PList l = plist_create( 1, 1);
   if (!l) return nil;
   list_add( l, (Handle)duplicate_string( "Clipboard"));
   return l;
}

Bool
apc_clipboard_create( Handle self)
{
   if ( !((PClipboard)self)-> name
        || strlen(((PClipboard)self)-> name) != 9
        || ((PClipboard)self)-> name[0] != 'C'
        || strcmp(((PClipboard)self)-> name, "Clipboard") != 0) {
      return false;
   }
   return true;
}

Bool
apc_clipboard_destroy( Handle self)
{
   return true;
}

Bool
apc_clipboard_open( Handle self)
{
   Bool ok;
   Bool oad = appDead;
   appDead = true;
   ok = WinOpenClipbrd( guts. anchor);
   appDead = oad;
   if ( !ok) apiErr;
   return ok;
}

Bool
apc_clipboard_close( Handle self)
{
   if ( !WinCloseClipbrd( guts. anchor)) apiErrRet;
   return true;
}

Bool
apc_clipboard_clear( Handle self)
{
   if ( !WinEmptyClipbrd( guts. anchor)) apiErrRet;
   return true;
}


static long cf2CF( long id)
{
   if ( id == cfText)   return CF_TEXT;
   if ( id == cfBitmap) return CF_BITMAP;
   return id - cfCustom;
}

Bool
apc_clipboard_has_format( Handle self, long id)
{
   ULONG flags;
   return WinQueryClipbrdFmtInfo( guts. anchor, cf2CF( id), &flags);
}

void *
apc_clipboard_get_data( Handle self, long id, STRLEN * length)
{
   id = cf2CF( id);
   switch( id)
   {
      case CF_BITMAP:
         {
             /* XXX palette operations */
             PImage image      = ( PImage) *length;
             Handle self       = ( Handle) image;
             HBITMAP b = WinQueryClipbrdData( guts. anchor, id);
             HBITMAP b2, bsave;
             BITMAPINFOHEADER bh;
             PBITMAPINFO2 bi;
             int type;
             POINTL pt [4] = {{0,0},{0,0},{0,0},{0,0}};
             if ( b == nilHandle) {
                apcErr( errInvClipboardData);
                return nil;
             }
             if ( !GpiQueryBitmapParameters( b, &bh)) apiErr;
             if (bh. cBitCount > 8) bh. cBitCount = 24;
             image_begin_query( bh. cBitCount, &type);
             bh. cBitCount = type;
             image-> self-> create_empty( self, bh. cx, bh. cy, bh. cBitCount);
             pt[ 1]. x = pt[ 3]. x = bh. cx;
             pt[ 1]. y = pt[ 3]. y = bh. cy;
             pt[ 1]. x--;
             pt[ 1]. y--;
             if ( !( bi = get_binfo( self))) return nil;
             b2 = GpiCreateBitmap( guts. ps, ( PBITMAPINFOHEADER2)bi, 0, nil, nil);
             if ( b2 == nilHandle) { apiErr; return nil; }
             free( bi);
             bsave = GpiSetBitmap( guts. ps, b2);
             if ( bsave == HBM_ERROR) apiErr;
             if ( GpiWCBitBlt( guts. ps, b, 4, pt, ROP_SRCCOPY, BBO_IGNORE) == GPI_ERROR) apiErr;
             image_query( self, guts. ps);
             if ( GpiSetBitmap( guts. ps, bsave) == HBM_ERROR) apiErr;
             if ( !GpiDeleteBitmap( b2)) apiErr;
             return (void*)*length;
         }
         break;
      case CF_TEXT:
         {
             char * ptr = (char*) WinQueryClipbrdData( guts. anchor, id);
             char * ret;
             STRLEN i, len = *length = strlen( ptr);
             len++;
             if ( ptr == nil) {
                apcErr( errInvClipboardData);
                return nil;
             }
             if ( !( ret = malloc( *length)))
                return nil;
             memcpy( ret, ptr, *length);
             for ( i = 0; i < len - 1; i++)
                if ( ret[ i] == '\r') {
                   memcpy( ret + i, ret + i + 1, len - i + 1);
                   (*length)--;
                }
             return ret;
         }
         break;
      default:
         {
            char * ptr = (char*) WinQueryClipbrdData( guts. anchor, id);
            void * ret;
            if ( ptr == nil) {
               apcErr( errInvClipboardData);
               return nil;
            }
            *length = *(( int*) ptr);
            ptr += sizeof( int);
            ret = malloc( *length);
            if ( ret) memcpy( ret, ptr, *length);
            return ret;
         }
   }
   return nil;
}

Bool
apc_clipboard_set_data( Handle self, long id, void * data, STRLEN length)
{
   id = cf2CF( id);
   if ( data == nil)
   {
      if ( !WinEmptyClipbrd( guts. anchor)) apiErr;
      return true;
   }
   switch ( id)
   {
      case CF_BITMAP:
         {
            /* XXX palette operations */
            HBITMAP b = ( HBITMAP) bitmap_make_handle(( Handle) data );
            if ( b == nilHandle) apiErrRet;
            if ( !WinSetClipbrdData( guts. anchor, b, id, CFI_HANDLE)) apiErrRet;
         }
         break;
      case CF_TEXT:
         {
             char * ptr;
             rc = DosAllocSharedMem(( PVOID) &ptr, nil, length + 1, PAG_WRITE|PAG_COMMIT|OBJ_GIVEABLE);
             if ( rc != 0) { apiAltErr( rc); return false; };
             memcpy( ptr, data, length);
             ptr[length] = 0;
             if ( !WinSetClipbrdData( guts. anchor, (ULONG)ptr, id, CFI_POINTER)) apiErrRet;
         }
         break;
      default:
         {
             char * ptr;
             rc = DosAllocSharedMem(( PPVOID) &ptr, nil, length+sizeof(int), PAG_WRITE|PAG_COMMIT|OBJ_GIVEABLE);
             if ( rc != 0) { apiAltErr( rc); return false; };
             memcpy( ptr+sizeof(int), data, length);
             memcpy( ptr, &length, sizeof(int));
             if ( !WinSetClipbrdData( guts. anchor, (ULONG)ptr, id, CFI_POINTER)) apiErrRet;
         }
    }
    return true;
}

long
apc_clipboard_register_format( Handle self, const char * format)
{
   ATOM atom;
   if (( atom = WinAddAtom( WinQuerySystemAtomTable(), format)) == 0) apiErrRet;
   return atom + cfCustom;
}

Bool
apc_clipboard_deregister_format( Handle self, long id)
{
   WinDeleteAtom( WinQuerySystemAtomTable(), (ATOM)( id - cfCustom));
   return true;
}

ApiHandle
apc_clipboard_get_handle( Handle self)
{
   return nilHandle;
}