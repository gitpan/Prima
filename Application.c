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
 * $Id: Application.c,v 1.50 2001/02/20 15:36:52 dk Exp $
 */

#include "apricot.h"
#include "Timer.h"
#include "Window.h"
#include "Image.h"
#include "Application.h"
#include <Application.inc>

#ifdef __cplusplus
extern "C" {
#endif


#undef  my
#define inherited CWidget->
#define my  ((( PApplication) self)-> self)
#define var (( PApplication) self)

static void Application_HintTimer_handle_event( Handle, PEvent);

void
Application_init( Handle self, HV * profile)
{
   int hintPause = pget_i( hintPause);
   Color hintColor = pget_i( hintColor), hintBackColor = pget_i( hintBackColor);
   SV * hintFont = pget_sv( hintFont);
   SV * sv;
   char * hintClass      = pget_c( hintClass);
   if ( application != nilHandle)
      croak( "RTC0010: Attempt to create more than one application instance");

   CDrawable-> init( self, profile);
   list_create( &var->  widgets, 16, 16);
   list_create( &var->  modalHorizons, 0, 8);
   application = self;
   if ( !apc_application_create( self))
      croak( "RTC0011: Error creating application");
// Widget init
   SvHV_Font( pget_sv( font), &Font_buffer, "Application::init");
   my-> set_font( self, Font_buffer);
   SvHV_Font( pget_sv( popupFont), &Font_buffer, "Application::init");
   my-> set_popup_font( self, Font_buffer);
   {
      AV * av = ( AV *) SvRV( pget_sv( designScale));
      SV ** holder = av_fetch( av, 0, 0);
      if ( holder)
         var->  designScale. x = SvNV( *holder);
      else
         warn("RTC0012: Array panic on 'designScale'");
      holder = av_fetch( av, 1, 0);
      if ( holder)
         var->  designScale. y = SvNV( *holder);
      else
         warn("RTC0012: Array panic on 'designScale'");
      pdelete( designScale);
   }
   var->  text = duplicate_string("");
   opt_set( optModalHorizon);

   // store printer info
   {
      HV * hv = ( HV *) SvRV( var-> mate);
      hv_store( hv, "PrinterClass",  12, newSVpv( pget_c( printerClass),  0), 0);
      hv_store( hv, "PrinterModule", 13, newSVpv( pget_c( printerModule), 0), 0);
   }
   
   {
      HV * profile = newHV();
      static Timer_vmt HintTimerVmt;

      pset_H( owner, self);
      pset_i( timeout, hintPause);
      pset_c( name, "HintTimer");
      var->  hintTimer = create_instance( "Prima::Timer");
      protect_object( var-> hintTimer);
      hv_clear( profile);
      memcpy( &HintTimerVmt, CTimer, sizeof( HintTimerVmt));
      HintTimerVmt. handle_event = Application_HintTimer_handle_event;
      (( PTimer) var->  hintTimer)-> self = &HintTimerVmt;

      pset_H( owner, self);
      pset_i( color, hintColor);
      pset_i( backColor, hintBackColor);
      pset_i( visible, 0);
      pset_i( selectable, 0);
      pset_i( showHint, 0);
      pset_c( name, "HintWidget");
      pset_sv( font, hintFont);
      var->  hintWidget = create_instance( hintClass);
      protect_object( var->  hintWidget);
      sv_free(( SV *) profile);
   }

   if ( SvTYPE( sv = pget_sv( accelItems)) != SVt_NULL)
      my-> set_accelItems( self, sv);
   if ( SvTYPE( sv = pget_sv( popupItems)) != SVt_NULL)
      my-> set_popupItems( self, sv);
   pdelete( accelTable);
   pdelete( accelItems);
   pdelete( popupItems);

   my-> set( self, profile);
}

void
Application_done( Handle self)
{
   unprotect_object( var-> hintTimer);
   unprotect_object( var-> hintWidget);
   list_destroy( &var->  modalHorizons);
   list_destroy( &var->  widgets);
   free( var-> helpFile);
   free( var-> text);
   free( var-> hint);
   var->  accelTable = 
      var-> hintWidget = var-> hintTimer = nilHandle;
   var->  helpFile   = var->  text    = var->  hint      = nil;
   apc_application_destroy( self);
   CDrawable-> done( self);
   application = nilHandle;
}

void
Application_cleanup( Handle self)
{
   my-> close_help( self);
   my-> first_that( self, kill_all, nil);
   if ( var-> icon)
      my-> detach( self, var-> icon, true);
   var-> icon = nilHandle;

   my-> first_that_component( self, kill_all, nil);

   CDrawable-> cleanup( self);
}


void
Application_set( Handle self, HV * profile)
{
   pdelete( bottom);
   pdelete( buffered);
   pdelete( capture);
   pdelete( centered);
   pdelete( clipOwner);
   pdelete( enabled);
   pdelete( focused);
   pdelete( growMode);
   pdelete( height);
   pdelete( hintClass);
   pdelete( hintVisible);
   pdelete( left);
   pdelete( modalHorizon);
   pdelete( origin);
   pdelete( owner);
   pdelete( ownerBackColor);
   pdelete( ownerColor);
   pdelete( ownerFont);
   pdelete( ownerPalette);
   pdelete( ownerShowHint);
   pdelete( palette);
   pdelete( printerClass);
   pdelete( printerModule);
   pdelete( rect);
   pdelete( rigth);
   pdelete( selectable);
   pdelete( shape);
   pdelete( size);
   pdelete( syncPaint);
   pdelete( tabOrder);
   pdelete( tabStop);
   pdelete( transparent);
   pdelete( text);
   pdelete( top);
   pdelete( visible);
   pdelete( width);
   inherited set( self, profile);
}

void Application_handle_event( Handle self, PEvent event)
{
   switch ( event-> cmd)
   {
      case cmPost:
      if ( event-> gen. H != self)
      {
         ((( PComponent) event-> gen. H)-> self)-> message( event-> gen. H, event);
         event-> cmd = 0;
         if ( var->  stage > csNormal) return;
      }
      break;
   }
   inherited handle_event ( self, event);
}

void
Application_yield( char * dummy)
{
   apc_application_yield();
}

Bool
Application_begin_paint( Handle self)
{
   Bool ok;
   if ( !CDrawable-> begin_paint( self))
      return false;
   if ( !( ok = apc_application_begin_paint( self)))
      CDrawable-> end_paint( self);
   return ok;
}

Bool
Application_begin_paint_info( Handle self)
{
   Bool ok;
   if ( is_opt( optInDraw))     return true;
   if ( !CDrawable-> begin_paint_info( self))
      return false;
   if ( !( ok = apc_application_begin_paint_info( self)))
      CDrawable-> end_paint_info( self);
   return ok;
}

void
Application_detach( Handle self, Handle objectHandle, Bool kill)
{
   inherited detach( self, objectHandle, kill);
   if ( var->  autoClose &&
        ( var->  widgets. count == 1) &&
        kind_of( objectHandle, CWidget) &&
        ( objectHandle != var->  hintWidget)
       ) my-> close( self);
}

void
Application_end_paint( Handle self)
{
   if ( !is_opt( optInDraw)) return;
   apc_application_end_paint( self);
   CDrawable-> end_paint( self);
}

void
Application_end_paint_info( Handle self)
{
   if ( !is_opt( optInDrawInfo)) return;
   apc_application_end_paint_info( self);
   CDrawable-> end_paint_info( self);
}

Bool
Application_focused( Handle self, Bool set, Bool focused)
{
   if ( set) return false;
   return inherited focused( self, set, focused);
}

void Application_bring_to_front( Handle self) {}
void Application_show( Handle self) {}
void Application_hide( Handle self) {}
void Application_insert_behind( Handle self, Handle view) {}
void Application_send_to_back( Handle self) {}

SV*
Application_fonts( Handle self, char * name)
{
   int count, i;
   AV * glo = newAV();
   PFont fmtx = apc_fonts( self, strlen( name) ? name : nil, &count);
   for ( i = 0; i < count; i++) {
      SV * sv      = sv_Font2HV( &fmtx[ i]);
      HV * profile = ( HV*) SvRV( sv);
      pdelete( resolution);
      pdelete( codepage);
      av_push( glo, sv);
   }
   free( fmtx);
   return newRV_noinc(( SV *) glo);
}

Font
Application_get_default_font( char * dummy)
{
   Font font;
   apc_font_default( &font);
   return font;
}

Font
Application_get_message_font( char * dummy)
{
   Font font;
   apc_sys_get_msg_font( &font);
   return font;
}

Font
Application_get_caption_font( char * dummy)
{
   Font font;
   apc_sys_get_caption_font( &font);
   return font;
}


int
Application_get_default_cursor_width( char * dummy)
{
   return apc_sys_get_value( svXCursor);
}

Point
Application_get_default_scrollbar_metrics( char * dummy)
{
   Point ret;
   ret. x = apc_sys_get_value( svXScrollbar);
   ret. y = apc_sys_get_value( svYScrollbar);
   return ret;
}

Point
Application_get_default_window_borders( char * dummy, int borderStyle)
{
   Point ret = { 0,0};
   switch ( borderStyle) {
   case bsNone:
      ret.x = svXbsNone;
      ret.y = svYbsNone;
      break;
   case bsSizeable:
      ret.x = svXbsSizeable;
      ret.y = svYbsSizeable;
      break;
   case bsSingle:
      ret.x = svXbsSingle;
      ret.y = svYbsSingle;
      break;
   case bsDialog:
      ret.x = svXbsDialog;
      ret.y = svYbsDialog;
      break;
   default:
      return ret;
   }
   ret. x = apc_sys_get_value( ret. x);
   ret. y = apc_sys_get_value( ret. y);
   return ret;
}

int
Application_get_system_value( char * dummy, int sysValue)
{
   return apc_sys_get_value( sysValue);
}

SV *
Application_get_system_info( char * dummy)
{
   HV * profile = newHV();
   char system   [ 1024];
   char release  [ 1024];
   char vendor   [ 1024];
   char arch     [ 1024];
   char gui_desc [ 1024];
   int  os, gui;

   os  = apc_application_get_os_info( system, sizeof( system),
                                      release, sizeof( release),
                                      vendor, sizeof( vendor),
                                      arch, sizeof( arch));
   gui = apc_application_get_gui_info( gui_desc, sizeof( gui_desc));

   pset_i( apc,            os);
   pset_i( gui,            gui);
   pset_c( system,         system);
   pset_c( release,        release);
   pset_c( vendor,         vendor);
   pset_c( architecture,   arch);
   pset_c( guiDescription, gui_desc);

   return newRV_noinc(( SV *) profile);
}

Handle
Application_get_widget_from_handle( Handle self, SV * handle)
{
   ApiHandle apiHandle;
   if ( SvIOK( handle))
           apiHandle = SvUVX( handle);
   else
      apiHandle = sv_2uv( handle);
   return apc_application_get_handle( self, apiHandle);
}

Handle
Application_get_hint_widget( Handle self)
{
   return var->  hintWidget;
}

static Bool
icon_notify ( Handle self, Handle child, Handle icon)
{
    if ( kind_of( child, CWindow) && (( PWidget) child)-> options. optOwnerIcon) {
       CWindow( child)-> set_icon( child, icon);
       PWindow( child)-> options. optOwnerIcon = 1;
    }
    return false;
}

Handle
Application_icon( Handle self, Bool set, Handle icon)
{
   if ( var-> stage > csFrozen) return nilHandle;

   if ( !set)
      return var-> icon;

   if ( icon && !kind_of( icon, CImage)) {
       warn("RTC0013: Illegal object reference passed to Application::icon");
       return nilHandle;
   }
   if ( icon) {
      icon = ((( PImage) icon)-> self)-> dup( icon);
      ++SvREFCNT( SvRV((( PAnyObject) icon)-> mate));
   }
   my-> first_that( self, icon_notify, (void*)icon);
   if ( var-> icon)
      my-> detach( self, var-> icon, true);
   var-> icon = icon;
   if ( icon)
      my-> attach( self, icon);
   return nilHandle;
}

char *
Application_helpFile( Handle self, Bool set, char * helpFile)
{
   if ( var-> stage > csFrozen) return "";
   if ( !set)
      return var-> helpFile ? var-> helpFile : "";

   if ( var-> helpFile && ( strcmp( var->  helpFile, helpFile) == 0)) return "";
   free( var-> helpFile);
   var-> helpFile = duplicate_string( helpFile);
   apc_help_set_file( self, helpFile);
   return "";
}

Handle
Application_get_focused_widget( Handle self)
{
   return apc_widget_get_focused();
}

Handle
Application_get_active_window( Handle self)
{
   return apc_window_get_active();
}

Bool
Application_autoClose( Handle self, Bool set, Bool autoClose)
{
   if ( !set)
      return var->  autoClose;
   return var-> autoClose = autoClose;
}

SV *
Application_sys_action( char * dummy, char * params)
{
   char * i = apc_system_action( params);
   SV * ret = i ? newSVpv( i, 0) : nilSV;
   free( i);
   return ret;
}

typedef struct _SingleColor
{
   Color color;
   int   index;
} SingleColor, *PSingleColor;


Color
Application_colorIndex( Handle self, Bool set, int index, Color color)
{
   if ( var->  stage > csFrozen) return clInvalid;
   if (( index < 0) || ( index > ciMaxId)) return clInvalid;
   if ( !set) {
      switch ( index) {
        case ciFore:
           return opt_InPaint ?
              CDrawable-> get_color ( self) : var-> colors[ index];
        case ciBack:
           return opt_InPaint ?
              CDrawable-> get_backColor ( self) : var-> colors[ index];
        default:
           return  var->  colors[ index];
      }
   } else {
      SingleColor s;
      s. color = color;
      s. index = index;
      if ( !opt_InPaint) my-> first_that( self, single_color_notify, &s);
      if ( opt_InPaint) switch ( index) {
         case ciFore:
            CDrawable-> set_color ( self, color);
            break;
         case ciBack:
            CDrawable-> set_backColor ( self, color);
            break;
       }
       var-> colors[ index] = color;
   }
   return clInvalid;
}

void
Application_set_font( Handle self, Font font)
{
   if ( !opt_InPaint) my-> first_that( self, font_notify, &font);
   apc_font_pick( self, &font, & var-> font);
   if ( opt_InPaint) apc_gp_set_font ( self, &var-> font);
}


Bool
Application_close( Handle self)
{
   if ( var->  stage > csNormal) return true;
   return my-> can_close( self) ? ( apc_application_close( self), true) : false;
}

Bool
Application_insertMode( Handle self, Bool set, Bool insMode)
{
   if ( !set)
      return apc_sys_get_insert_mode();
   return apc_sys_set_insert_mode( insMode);
}

Handle
Application_get_parent( Handle self)
{
   return nilHandle;
}

Point
Application_get_scroll_rate( Handle self)
{
   Point ret;
   ret. x = apc_sys_get_value( svAutoScrollFirst);
   ret. y = apc_sys_get_value( svAutoScrollNext);
   return ret;
}

static void hshow( Handle self)
{
   PWidget_vmt hintUnder = CWidget( var->  hintUnder);
   char * text = hintUnder-> get_hint( var->  hintUnder);
   Point size  = hintUnder-> get_size( var->  hintUnder);
   Point s = my-> get_size( self);
   Point fin = {0,0};
   Point pos = fin;
   Point mouse = my-> get_pointerPos( self);
   Point hintSize;
   PWidget_vmt hintWidget = CWidget( var->  hintWidget);

   apc_widget_map_points( var-> hintUnder, true, 1, &pos);

   hintWidget-> set_text( var->  hintWidget, text);
   hintSize = hintWidget-> get_size( var->  hintWidget);

   fin. x = mouse. x - 16;
   fin. y = pos. y - hintSize. y - 1;
   if ( fin. y > mouse. y - hintSize. y - 32) fin. y = mouse. y - hintSize. y - 32;

   if ( fin. x + hintSize. x >= s. x) fin. x = pos. x - hintSize. x;
   if ( fin. x < 0) fin. x = 0;
   if ( fin. y + hintSize. y >= s. y) fin. y = pos. y - hintSize. y;
   if ( fin. y < 0) fin. y = pos. y + size. y + 1;
   if ( fin. y < 0) fin. y = 0;

   hintWidget-> set_origin( var->  hintWidget, fin);
   hintWidget-> show( var->  hintWidget);
   hintWidget-> bring_to_front( var->  hintWidget);
}

void
Application_HintTimer_handle_event( Handle timer, PEvent event)
{
   CComponent-> handle_event( timer, event);
   if ( event-> cmd == cmTimer) {
      Handle self = application;
      CTimer(timer)-> stop( timer);
      if ( var->  hintActive == 1) {
         Event ev = {cmHint};
         if (   !var->hintUnder
             || apc_application_get_widget_from_point( self,
                   my-> get_pointerPos(self)) != var->hintUnder
             || PObject( var-> hintUnder)-> stage != csNormal)
            return;
         ev. gen. B = true;
         ev. gen. H = var->  hintUnder;
         var->  hintVisible = 1;
         if (( PWidget( var->  hintUnder)-> stage == csNormal) &&
             ( CWidget( var->  hintUnder)-> message( var->  hintUnder, &ev)))
             hshow( self);
      } else if ( var->  hintActive == -1)
         var->  hintActive = 0;
   }
}

void
Application_set_hint_action( Handle self, Handle view, Bool show, Bool byMouse)
{
   if ( show && !is_opt( optShowHint)) return;
   if ( show)
   {
      var->  hintUnder = view;
      if ( var->  hintActive == -1)
      {
         Event ev = {cmHint};
         ev. gen. B = true;
         ev. gen. H = view;
         ((( PTimer) var->  hintTimer)-> self)-> stop( var-> hintTimer);
         var->  hintVisible = 1;
         if (( PWidget( view)-> stage == csNormal) &&
             ( CWidget( view)-> message( view, &ev)))
             hshow( self);
      } else {
         if ( !byMouse && var->  hintActive == 1) return;
         CTimer( var->  hintTimer)-> start( var-> hintTimer);
      }
      var->  hintActive = 1;
   } else {
      int oldHA = var->  hintActive;
      int oldHV = var->  hintVisible;
      if ( oldHA != -1)
         ((( PTimer) var-> hintTimer)-> self)-> stop( var-> hintTimer);
      if ( var->  hintVisible)
      {
         Event ev = {cmHint};
         ev. gen. B = false;
         ev. gen. H = view;
         var->  hintVisible = 0;
         if (( PWidget( view)-> stage != csNormal) ||
              ( CWidget( view)-> message( view, &ev)))
            CWidget( var->  hintWidget)-> hide( var->  hintWidget);
      }
      if ( oldHA != -1) var->  hintActive = 0;
      if ( byMouse && oldHV) {
         var->  hintActive = -1;
         CTimer( var->  hintTimer)-> start( var->  hintTimer);
      }
   }
}

Color
Application_hintColor( Handle self, Bool set, Color hintColor)
{
   if ( !set)
      return CWidget( var-> hintWidget)-> get_color( var->  hintWidget);
   return CWidget( var->  hintWidget)-> set_color( var->  hintWidget, hintColor);
}

Color
Application_hintBackColor( Handle self, Bool set, Color hintBackColor)
{
   if ( !set)
      return CWidget( var->  hintWidget)-> get_backColor( var-> hintWidget);
   return CWidget( var->  hintWidget)-> set_backColor( var->  hintWidget, hintBackColor);
}

int
Application_hintPause( Handle self, Bool set, int hintPause)
{
   if ( !set)
      return CTimer( var->  hintTimer)-> get_timeout( var->  hintTimer);
   return CTimer( var->  hintTimer)-> set_timeout( var->  hintTimer, hintPause);
}

void
Application_set_hint_font( Handle self, Font hintFont)
{
   CWidget( var-> hintWidget)-> set_font( var->  hintWidget, hintFont);
}


Font
Application_get_hint_font( Handle self)
{
   return CWidget( var->  hintWidget)-> get_font( var->  hintWidget);
}

Bool
Application_showHint( Handle self, Bool set, Bool showHint)
{
   if ( !set)
      return inherited showHint( self, set, showHint);
   opt_assign( optShowHint, showHint);
   return false;
}

Handle Application_next( Handle self) { return self;}
Handle Application_prev( Handle self) { return self;}

SV *
Application_palette( Handle self, Bool set, SV * palette)
{
   return CDrawable-> palette( self, set, palette);
}

Handle
Application_top_frame( Handle self, Handle from)
{
   while ( from) {
      if ( kind_of( from, CWindow) && 
             (( PWidget( from)-> owner == application) || !CWidget( from)-> get_clipOwner(from))                           
         )                              
         return from;
      from = PWidget( from)-> owner;
   }
   return application;
}

Handle
Application_get_image( Handle self, int x, int y, int xLen, int yLen)
{
   HV * profile;
   Handle i;
   Bool ret;
   if ( var->  stage > csFrozen) return nilHandle;
   if ( xLen <= 0 || yLen <= 0) return nilHandle;

   profile = newHV();
   i = Object_create( "Prima::Image", profile);
   sv_free(( SV *) profile);
   ret = apc_application_get_bitmap( self, i, x, y, xLen, yLen);
   --SvREFCNT( SvRV((( PAnyObject) i)-> mate));
   return ret ? i : nilHandle;
}

/*
 * Cannot return nilHandle.
 */
Handle
Application_map_focus( Handle self, Handle from)
{
   Handle topFrame = my-> top_frame( self, from);
   Handle topShared;

   if ( var->  topExclModal)
      return ( topFrame == var->  topExclModal) ? from : var->  topExclModal;

   if ( !var->  topSharedModal && var->  modalHorizons. count == 0)
      return from; // return from if no shared modals active

  if ( topFrame == self) {
      if ( !var->  topSharedModal) return from;
      topShared = var->  topSharedModal;
   } else {
      Handle horizon =
         ( !CWindow( topFrame)-> get_modalHorizon( topFrame)) ?
         CWindow( topFrame)-> get_horizon( topFrame) : topFrame;
      if ( horizon == self)
         topShared = var->  topSharedModal;
      else
         topShared = PWindow( horizon)-> topSharedModal;
   }

   return ( !topShared || ( topShared == topFrame)) ? from : topShared;
}

static Handle
popup_win( Handle xTop)
{
   PWindow_vmt top = CWindow( xTop);
   if ( !top-> get_visible( xTop))
      top-> set_visible( xTop, 1);
   if ( top-> get_windowState( xTop) == wsMinimized)
      top-> set_windowState( xTop, wsNormal);
   top-> set_selected( xTop, 1);
   return xTop;
}

Handle
Application_popup_modal( Handle self)
{
   Handle ha = apc_window_get_active();
   Handle xTop;

   if ( var->  topExclModal) {
   // checking exclusive modal chain
      xTop = ( !ha || ( PWindow(ha)->modal == 0)) ? var->  exclModal : ha;
      while ( xTop) {
         if ( PWindow(xTop)-> nextExclModal) {
            CWindow(xTop)-> bring_to_front( xTop);
            xTop = PWindow(xTop)-> nextExclModal;
         } else {
            return popup_win( xTop);
         }
      }
   } else {
      if ( !var->  topSharedModal && var->  modalHorizons. count == 0)
         return nilHandle; // return from if no shared modals active
      // checking shared modal chains
      if ( ha) {
         xTop = ( PWindow(ha)->modal == 0) ? CWindow(ha)->get_horizon(ha) : ha;
         if ( xTop == application) xTop = var->  sharedModal;
      } else
         xTop = var->  sharedModal ? var->  sharedModal : var->  modalHorizons. items[ 0];

      while ( xTop) {
         if ( PWindow(xTop)-> nextSharedModal) {
            CWindow(xTop)-> bring_to_front( xTop);
            xTop = PWindow(xTop)-> nextSharedModal;
         } else {
            return popup_win( xTop);
         }
      }
   }

   return nilHandle;
}

long int
Application_helpContext( Handle self, Bool set, long int context)
{
   if ( set && ( context == hmpOwner)) context = hmpNone;
   return inherited helpContext( self, set, context);
}

Bool
Application_pointerVisible( Handle self, Bool set, Bool pointerVisible)
{
   if ( !set)
      return apc_pointer_get_visible( self);
   return apc_pointer_set_visible( self, pointerVisible);
}

Point
Application_size( Handle self, Bool set, Point size)
{
   if ( set) return size;
   return apc_application_get_size( self);
}

Point
Application_origin( Handle self, Bool set, Point origin)
{
   Point p = { 0, 0};
   return p;
}

Bool
Application_modalHorizon( Handle self, Bool set, Bool modalHorizon)
{
   return true;
}

void   Application_update_sys_handle( Handle self, HV * profile) {}
Bool   Application_get_capture( Handle self) { return false; }
void   Application_set_capture( Handle self, Bool capture, Handle confineTo) {}
void   Application_set_centered( Handle self, Bool x, Bool y) {}

Bool   Application_tabStop( Handle self, Bool set, Bool tabStop)       { return false; }
Bool   Application_selectable( Handle self, Bool set, Bool selectable) { return false; }
Handle Application_shape( Handle self, Bool set, Handle mask)          { return nilHandle; }
Bool   Application_syncPaint( Handle self, Bool set, Bool syncPaint)   { return false; }
Bool   Application_visible( Handle self, Bool set, Bool visible)       { return true; }
Bool   Application_buffered( Handle self, Bool set, Bool buffered)     { return false; }
Bool   Application_enabled( Handle self, Bool set, Bool enable)        { return true;}
int    Application_growMode( Handle self, Bool set, int flags)         { return 0; }
Bool   Application_hintVisible( Handle self, Bool set, Bool visible)   { return false; }
Handle Application_owner( Handle self, Bool set, Handle owner)         { return nilHandle; }
Bool   Application_ownerColor( Handle self, Bool set, Bool ownerColor) { return false; }
Bool   Application_ownerBackColor( Handle self, Bool set, Bool ownerBackColor) { return false; }
Bool   Application_ownerFont( Handle self, Bool set, Bool ownerFont)   { return false; }
Bool   Application_ownerShowHint( Handle self, Bool set, Bool ownerShowHint) { return false; }
Bool   Application_ownerPalette( Handle self, Bool set, Bool ownerPalette) { return false; }
Bool   Application_clipOwner( Handle self, Bool set, Bool clipOwner)   { return true; }
int    Application_tabOrder( Handle self, Bool set, int tabOrder)      { return 0; }
char * Application_text    ( Handle self, Bool set, char * text)       { return ""; }
Bool   Application_transparent( Handle self, Bool set, Bool transparent) { return false; }

#ifdef __cplusplus
}
#endif
