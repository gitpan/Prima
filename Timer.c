/*-
 * Copyright (c) 1997-2000 The Protein Laboratory, University of Copenhagen
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
 * $Id: Timer.c,v 1.16 2000/05/17 10:28:25 tobez Exp $
 */

#include "apricot.h"
#include "Timer.h"
#include <Timer.inc>

#ifdef __cplusplus
extern "C" {
#endif


#undef  my
#define inherited CComponent->
#define my  ((( PTimer) self)-> self)
#define var (( PTimer) self)

void
Timer_init( Handle self, HV * profile)
{
   inherited init( self, profile);
   CComponent( var-> owner)-> attach( var-> owner, self);
   my-> update_sys_handle( self, profile);
}

void
Timer_update_sys_handle( Handle self, HV * profile)
{
   Handle xOwner = pexist( owner) ? pget_H( owner) : var-> owner;
   if ( var-> owner) my-> migrate( self, xOwner);
   if (!( pexist( owner))) return;
   if ( !apc_timer_create( self, xOwner, pexist( timeout)
                           ? pget_i( timeout)
                           : my-> get_timeout( self)))
      croak("RTC0063: cannot create timer");
   pdelete( owner);
   if ( pexist( timeout)) pdelete( timeout);
   var-> owner = xOwner;
}

void
Timer_handle_event( Handle self, PEvent event)
{
   inherited handle_event ( self, event);
   if ( event-> cmd == cmTimer) my-> notify( self, "<s", "Tick");
}

void
Timer_on_tick( Handle self)
{
}

Bool
Timer_start( Handle self)
{
   if ( is_opt( optActive)) return true;
   opt_assign( optActive, apc_timer_start( self));
   return is_opt( optActive);
}

void
Timer_stop( Handle self)
{
   if ( !is_opt( optActive)) return;
   apc_timer_stop( self);
   opt_clear( optActive);
}

void
Timer_done( Handle self)
{
   apc_timer_destroy( self);
   inherited done( self);
}

void
Timer_cleanup( Handle self)
{
   my-> stop( self);
   CComponent( var-> owner)-> detach( var-> owner, self, false);
   inherited cleanup( self);
}

Bool
Timer_get_active( Handle self)
{
   return is_opt( optActive);
}


SV *
Timer_get_handle( Handle self)
{
   char buf[ 256];
   snprintf( buf, 256, "0x%08lx", apc_timer_get_handle( self));
   return newSVpv( buf, 0);
}

int
Timer_timeout( Handle self, Bool set, int timeout)
{
   if ( !set)
      return apc_timer_get_timeout( self);
   return ( int) apc_timer_set_timeout( self, timeout);
}

#ifdef __cplusplus
}
#endif
