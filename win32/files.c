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
 * $Id: files.c,v 1.8 2002/05/14 13:22:36 dk Exp $
 */
/* Created by Dmitry Karasik <dk@plab.ku.dk> */
#include <winsock.h>

void __inline my_fd_zero( fd_set* f)           { FD_ZERO( f); }
void __inline my_fd_set( HANDLE fd, fd_set* f) { FD_SET((unsigned int) fd, f); }

#include "win32\win32guts.h"
#ifndef _APRICOT_H_
#include "apricot.h"
#endif
#include "Component.h"
#include "File.h"
#define var (( PFile) self)->
#define  sys (( PDrawableData)(( PComponent) self)-> sysData)->
#define  dsys( view) (( PDrawableData)(( PComponent) view)-> sysData)->

#ifdef __cplusplus
extern "C" {
#endif


#undef  select
#undef  fd_set
#undef  FD_ZERO
#define FD_ZERO my_fd_zero
#undef  FD_SET
#define FD_SET my_fd_set

static Bool            socketThreadStarted = false;
static Bool            socketSetChanged    = false;
static struct timeval  socketTimeout       = {0, 200000};
static char            socketErrBuf [ 256];

static fd_set socketSet1[3];
static fd_set socketSet2[3];
static int    socketCommands[3] = { feRead, feWrite, feException};

void
socket_select( void *dummy)
{
   int count;
   while ( !appDead) {
      if ( socketSetChanged) {
         // updating  handles
         int i;
         if ( WaitForSingleObject( guts. socketMutex, INFINITE) != WAIT_OBJECT_0) {
             strcpy( socketErrBuf, "Failed to obtain socket mutex ownership for thread #2");
             PostThreadMessage( guts. mainThreadId, WM_CROAK, 1, ( LPARAM) &socketErrBuf);
             break;
         }
         for ( i = 0; i < 3; i++)
            memcpy( socketSet1+i, socketSet2+i, sizeof( fd_set));
         socketSetChanged = false;
         ReleaseMutex( guts. socketMutex);
      }

      // calling select()
      count = socketSet1[0]. fd_count + socketSet1[1]. fd_count + socketSet1[2]. fd_count;
      if ( count > 0) {
         int i, j, result = select( 0, &socketSet1[0], &socketSet1[1], &socketSet1[2], &socketTimeout);
         socketSetChanged = true;
         if ( result == 0) continue;
         if ( result < 0) {
            if ( WSAGetLastError() == WSAENOTSOCK) {
               // possibly some socket was closed
               guts. socketPostSync = 1;
               PostThreadMessage( guts. mainThreadId, WM_SOCKET_REHASH, 0, 0);
               while( guts. socketPostSync) Sleep(1);
            } else
               // some error
               PostThreadMessage( guts. mainThreadId, WM_CROAK, 0,
                  ( LPARAM) err_msg( WSAGetLastError(), socketErrBuf));
            continue;
         }
         // posting select() results
         for ( j = 0; j < 3; j++)
            for ( i = 0; i < socketSet1[j]. fd_count; i++) {
               guts. socketPostSync = 1;
               PostThreadMessage( guts. mainThreadId, WM_SOCKET,
                   socketCommands[j], ( LPARAM) socketSet1[j]. fd_array[i]);
               while( guts. socketPostSync) Sleep(1);
            }
      } else
         // nothing to 'select', sleeping
         Sleep( socketTimeout. tv_sec * 1000 + socketTimeout. tv_usec / 1000);
   }

   // if somehow failed, making restart possible
   socketThreadStarted = false;
}


static void
reset_sockets( void)
{
   int i;

   // enter section
   if ( socketThreadStarted) {
      if ( WaitForSingleObject( guts. socketMutex, INFINITE) != WAIT_OBJECT_0)
          croak("Failed to obtain socket mutex ownership for thread #1");
   }

   // copying handles
   for ( i = 0; i < 3; i++)
      FD_ZERO( &socketSet2[i]);

   for ( i = 0; i < guts. sockets. count; i++) {
      Handle self = guts. sockets. items[i];
      if ( var eventMask & feRead)
         FD_SET( sys s. file. object, &socketSet2[0]);
      if ( var eventMask & feWrite)
         FD_SET( sys s. file. object, &socketSet2[1]);
      if ( var eventMask & feException)
         FD_SET( sys s. file. object, &socketSet2[2]);
   }

   socketSetChanged = true;

   // leave section and start the thread, if needed
   if ( !socketThreadStarted) {
      if ( !( guts. socketMutex = CreateMutex( NULL, FALSE, NULL))) {
         apiErr;
         croak("Failed to create socket mutex object");
      }
      guts. socketThread = ( HANDLE) _beginthread( socket_select, 40960, NULL);
      socketThreadStarted = true;
   } else
      ReleaseMutex( guts. socketMutex);
}

void
socket_rehash( void)
{
   int i;
   for ( i = 0; i < guts. sockets. count; i++) {
      Handle self = guts. sockets. items[i];
      CFile( self)-> is_active( self, true);
   }
}


Bool
apc_file_attach( Handle self)
{
   int fhtype;
   objCheck false;

   if ( guts. socket_version == 0) {
      int  _data, _sz = sizeof( int);
#ifdef PERL_OBJECT     // init perl socket library, if any
      PL_piSock-> Htons( 80);
#else
      win32_htons(80);
#endif
      if ( getsockopt(( SOCKET) INVALID_SOCKET, SOL_SOCKET, SO_OPENTYPE, (char*)&_data, &_sz) != 0)
         guts. socket_version = -1; // no sockets available
      else
         guts. socket_version = ( _data == SO_SYNCHRONOUS_NONALERT) ? 1 : 2;
   }

   if ( SOCKETS_NONE)
      return false;

   sys s. file. object = SOCKETS_AS_HANDLES ?
      (( HANDLE) _get_osfhandle( var fd)) :
      (( HANDLE) var fd);

   {
      int  _data, _sz = sizeof( int);
      int result = SOCKETS_AS_HANDLES ?
          WSAAsyncSelect((SOCKET) sys s. file. object, nilHandle, 0, 0) :
          getsockopt(( SOCKET) sys s. file. object, SOL_SOCKET, SO_TYPE, (char*)&_data, &_sz);
      if ( result != 0)
         fhtype = ( WSAGetLastError() == WSAENOTSOCK) ? FHT_OTHER : FHT_SOCKET;
      else
         fhtype = FHT_SOCKET;
   }

   sys s. file. type = fhtype;

   switch ( fhtype) {
   case FHT_SOCKET:
      list_add( &guts. sockets, self);
      reset_sockets();
      break;
   default:
      if ( guts. files. count == 0)
         PostMessage( NULL, WM_FILE, 0, 0);
      list_add( &guts. files, self);
      break;
   }

   return true;
}

Bool
apc_file_detach( Handle self)
{
   switch ( sys s. file. type) {
   case FHT_SOCKET:
      list_delete( &guts. sockets, self);
      reset_sockets();
      break;
   default:
      list_delete( &guts. files, self);
   }
   return true;
}

Bool
apc_file_change_mask( Handle self)
{
   switch ( sys s. file. type) {
   case FHT_SOCKET:
      reset_sockets();
      break;
   default:;
   }
   return true;
}

#ifdef __cplusplus
}
#endif