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
 * $Id: Menu.c,v 1.15 2002/06/17 09:51:20 dk Exp $
 */

#include "apricot.h"
#include "Window.h"
#include "Menu.h"
#include <Menu.inc>

#ifdef __cplusplus
extern "C" {
#endif


#undef  my
#define inherited CAbstractMenu->
#define my  ((( PMenu) self)-> self)
#define var (( PMenu) self)


void
Menu_update_sys_handle( Handle self, HV * profile)
{
   Handle xOwner = pexist( owner) ? pget_H( owner) : var-> owner;
   var-> system = true;
   if ( var-> owner && ( xOwner != var-> owner))
      ((( PWindow) var-> owner)-> self)-> set_menu( var-> owner, nilHandle);
   if ( !pexist( owner)) return;
   if ( !kind_of( xOwner, CWindow)) 
      croak("Illegal owner object reference passed to Menu::init");
   if ( !apc_menu_create( self, xOwner))
      croak("RTC0060: Cannot create menu");
   pdelete( owner);
}

Bool
Menu_selected( Handle self, Bool set, Bool selected)
{
   if ( !set)
       return CWindow( var-> owner)-> get_menu( var->  owner) == self;
   if ( var-> stage > csFrozen)
      return false;
   if ( selected)
      CWindow( var-> owner)-> set_menu( var-> owner, self);
   else if ( my-> get_selected( self))
      CWindow( var-> owner)-> set_menu( var-> owner, nilHandle);
   return false;
}

void
Menu_set( Handle self, HV * profile)
{
   if ( pexist( owner)) {
      if ( !kind_of( pget_H( owner), CWindow))
         croak("RTC0061: Illegal object reference passed to Menu::set_owner");
   }
   inherited set( self, profile);
}

#ifdef __cplusplus
}
#endif