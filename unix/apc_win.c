/*
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
 * $Id: apc_win.c,v 1.44 2001/07/25 14:21:30 dk Exp $
 */

/***********************************************************/
/*                                                         */
/*  System dependent window management (unix, x11)         */
/*                                                         */
/***********************************************************/

#include "unix/guts.h"
#include "Menu.h"
#include "Icon.h"
#include "Window.h"
#include "Application.h"


Bool
apc_window_create( Handle self, Handle owner, Bool sync_paint, int border_icons,
		   int border_style, Bool task_list,
		   int window_state, Bool use_origin, Bool use_size)
{
   DEFXX;
   Handle real_owner;
   XSizeHints hints;
   XSetWindowAttributes attrs;
   XWindow parent = guts. root;
   Point p0 = {0,0};

   if ( border_style != bsSizeable) border_style = bsDialog;

   if ( X_WINDOW) { /* recreate request */
      XX-> flags. sizeable = ( border_style == bsSizeable) ? 1 : 0;
      apc_widget_set_size_bounds( self, PWidget(self)-> sizeMin, PWidget(self)-> sizeMax);
      return true; 
   }   

   /* create */
   attrs. event_mask = 0
      | KeyPressMask
      | KeyReleaseMask
      | ButtonPressMask
      | ButtonReleaseMask
      | EnterWindowMask
      | LeaveWindowMask
      | PointerMotionMask
      /* | PointerMotionHintMask */
      /* | Button1MotionMask */
      /* | Button2MotionMask */
      /* | Button3MotionMask */
      /* | Button4MotionMask */
      /* | Button5MotionMask */
      | ButtonMotionMask
      | KeymapStateMask
      | ExposureMask
      | VisibilityChangeMask
      | StructureNotifyMask
      /* | ResizeRedirectMask */
      /* | SubstructureNotifyMask */
      /* | SubstructureRedirectMask */
      | FocusChangeMask
      | PropertyChangeMask
      | ColormapChangeMask
      | OwnerGrabButtonMask;
   attrs. override_redirect = false;
   attrs. do_not_propagate_mask = attrs. event_mask;
   X_WINDOW = XCreateWindow( DISP, parent,
	                     0, 0, 1, 1, 0, CopyFromParent,
	                     InputOutput, CopyFromParent,
	                     0
	                     /* | CWBackPixmap */
	                     /* | CWBackPixel */
	                     /* | CWBorderPixmap */
	                     /* | CWBorderPixel */
	                     /* | CWBitGravity */
	                     /* | CWWinGravity */
	                     /* | CWBackingStore */
	                     /* | CWBackingPlanes */
	                     /* | CWBackingPixel */
	                     | CWOverrideRedirect
	                     /* | CWSaveUnder */
	                     | CWEventMask
	                     /* | CWDontPropagate */
	                     /* | CWColormap */
	                     /* | CWCursor */
	                     , &attrs);
   if (!X_WINDOW) return false;
   hash_store( guts.windows, &X_WINDOW, sizeof(X_WINDOW), (void*)self);
   XCHECKPOINT;
   XX-> flags. iconic = ( window_state == wsMinimized) ? 1 : 0;
   guts. wm_create_window( self, X_WINDOW);
   XCHECKPOINT;

   XX-> type.drawable = true;
   XX-> type.widget = true;
   XX-> type.window = true;

   real_owner = application;
   XX-> real_parent = XX-> parent = parent;
   XX-> udrawable = XX-> gdrawable = X_WINDOW;

   XX-> flags. clip_owner = false;
   XX-> flags. sync_paint = sync_paint;
   XX-> flags. process_configure_notify = true;

   XX-> above = nilHandle;
   XX-> owner = real_owner;
   apc_component_fullname_changed_notify( self);
   prima_send_create_event( X_WINDOW);
   if ( border_style == bsSizeable) XX-> flags. sizeable = 1;

   /* setting initial size */
   XX-> size = guts. displaySize;
   if ( window_state != wsMaximized) {
      XX-> zoomRect. right = XX-> size. x;
      XX-> zoomRect. top   = XX-> size. y;
      XX-> size. x /= 3;
      XX-> size. y /= 3;
   } else
      XX-> flags. zoomed = 1;
   XX-> origin. x = XX-> origin. y = 
   XX-> ackOrigin. x = XX-> ackOrigin. y = 
   XX-> ackSize. x = XX-> ackOrigin. y = 0;
   
   bzero( &hints, sizeof( XSizeHints));
   hints. flags  = PBaseSize;
   hints. width  = hints. base_width  = XX-> size. x;
   hints. height = hints. base_height = XX-> size. y;
   XSetWMNormalHints( DISP, X_WINDOW, &hints);
   XResizeWindow( DISP, X_WINDOW, XX-> size. x, XX-> size. y); 

   prima_send_cmSize( self, p0);
   
   return true;
}

Bool
apc_window_activate( Handle self)
{
   DEFXX;
   int rev;
   XWindow xfoc;
   XEvent ev;

   if ( !XX-> flags. mapped) return true;
   if ( guts. message_boxes) return false;
   if ( self && ( self != CApplication( application)-> map_focus( application, self)))
      return false;

   XMapRaised( DISP, X_WINDOW);
   if ( XX-> flags. iconic || XX-> flags. withdrawn)
      prima_wm_sync( self, MapNotify);
   XGetInputFocus( DISP, &xfoc, &rev);
   if ( xfoc == X_WINDOW) return true;
   XSetInputFocus( DISP, X_WINDOW, RevertToParent, CurrentTime);
   XCHECKPOINT;

   XSync( DISP, false);
   while ( XCheckMaskEvent( DISP, FocusChangeMask|ExposureMask, &ev))
      prima_handle_event( &ev, nil);
   return true;
}

Bool
apc_window_is_active( Handle self)
{
   return apc_window_get_active() == self;
   return false;
}

Bool
apc_window_close( Handle self)
{
   return prima_simple_message( self, cmClose, true);
}

Handle
apc_window_get_active( void)
{
   Handle x = guts. focused;
   while ( x && !X(x)-> type. window) x = PWidget(x)-> owner;
   return x;
}

int
apc_window_get_border_icons( Handle self)
{
   return X(self)-> flags. sizeable ? biAll : ( biAll & ~biMaximize);
}

int
apc_window_get_border_style( Handle self)
{
   return X(self)-> flags. sizeable ? bsSizeable : bsDialog;
}

Point
apc_window_get_client_pos( Handle self)
{
   if ( !X(self)-> flags. configured) prima_wm_sync( self, ConfigureNotify);
   return X(self)-> origin;
}

Point
apc_window_get_client_size( Handle self)
{
   if ( !X(self)-> flags. configured) prima_wm_sync( self, ConfigureNotify);
   return X(self)-> size;
}

Bool
apc_window_get_icon( Handle self, Handle icon)
{
   XWMHints * hints;
   Pixmap xor, and;
   int xx, xy, ax, ay, xd, ad;
   Bool ret;

   if ( !icon) 
      return X(self)-> flags. has_icon ? true : false;
   else
      if ( !X(self)-> flags. has_icon) return false;

   if ( !( hints = XGetWMHints( DISP, X_WINDOW))) return false;  
   if ( !icon || !hints-> icon_pixmap) {
      Bool ret = hints-> icon_pixmap != nilHandle;
      XFree( hints);
      return ret;
   }
   xor = hints-> icon_pixmap;
   and = hints-> icon_mask;
   XFree( hints); 

   {
      XWindow foo;
      int bar;
      if ( !XGetGeometry( DISP, xor, &foo, &bar, &bar, &xx, &xy, &bar, &xd))
         return false;
      if ( and && (!XGetGeometry( DISP, and, &foo, &bar, &bar, &ax, &ay, &bar, &ad)))
         return false;
   } 

   CImage( icon)-> create_empty( icon, xx, xy, ( xd == 1) ? 1 : guts. qdepth);
   if ( !prima_std_query_image( icon, xor)) return false;
   
   if ( and) {
      HV * profile = newHV();
      Handle mask = Object_create( "Prima::Image", profile);
      sv_free(( SV *) profile);
      CImage( mask)-> create_empty( mask, ax, ay, ( ad == 1) ? 1 : guts. qdepth);
      ret = prima_std_query_image( mask, and);
      if (( PImage( mask)-> type & imBPP) != 1)
         CImage( mask)-> type( mask, true, imBW);
      if ( ret) {
         int i; 
         Byte *d = PImage(mask)-> data;
         for ( i = 0; i < PImage(mask)-> dataSize; i++, d++)
            *d = ~(*d);
      } else
         bzero( PImage( mask)-> data, PImage( mask)-> dataSize);
      if ( xx != ax || xy != ay)  {
         Point p;
         p.x = xx;
         p.y = xy;
         CImage( mask)-> size( mask, true, p);
      }
      memcpy( PIcon( icon)-> mask, PImage( mask)-> data, PIcon( icon)-> maskSize);
      Object_destroy( mask);
   }

   return true;
}

int
apc_window_get_window_state( Handle self)
{
   return (X(self)-> flags. iconic != 0) ? wsMinimized :
     ((X(self)-> flags. zoomed != 0) ? wsMaximized : wsNormal);
}

Bool
apc_window_get_task_listed( Handle self)
{
   /* TransientForHint might be the closest definition to this */
   return true;
}

Bool
apc_window_set_caption( Handle self, const char *caption)
{
   XTextProperty p;
   if ( XStringListToTextProperty(( char **) &caption, 1, &p) == 0) 
      return false;
   XSetWMIconName( DISP, X_WINDOW, &p);
   XSetWMName( DISP, X_WINDOW, &p);
   XFree( p. value);
   return true;
}

XWindow
prima_find_frame_window( XWindow w)
{
   XWindow r, p, *c;
   int nc;

   if ( w == None)
      return None;
   while ( XQueryTree( DISP, w, &r, &p, &c, &nc)) {
      if (c)
         XFree(c);
      if ( p == r)
         return w;
      w = p;
   }
   return None;
}

Bool
prima_get_frame_info( Handle self, PRect r)
{
   DEFXX;
   XWindow p, dummy;
   int px, py;
   unsigned int pw, ph, pb, pd;

   bzero( r, sizeof( Rect));
   p = prima_find_frame_window( X_WINDOW);
   if ( p == nilHandle) {
      r-> left = XX-> decorationSize. x;
      r-> top  = XX-> decorationSize. y;
   } else if ( p != X_WINDOW) 
      if ( !XTranslateCoordinates( DISP, X_WINDOW, p, 0, 0, &r-> left, &r-> bottom, &dummy))
         warn( "error in XTranslateCoordinates()");
      if ( !XGetGeometry( DISP, p, &dummy, &px, &py, &pw, &ph, &pb, &pd)) {
         warn( "error in XGetGeometry()");
      r-> right = pw - r-> left  - XX-> size. x;
      r-> top   = ph - r-> right - XX-> size. y;
   }
   r-> top += XX-> menuHeight;
   return true;
}

static void
apc_SetWMNormalHints( Handle self, XSizeHints * hints)
{
   DEFXX;
   if ( XX-> flags. sizeable) {
      hints-> min_width  = PWidget(self)-> sizeMin.x;
      hints-> min_height = PWidget(self)-> sizeMin.y + XX-> menuHeight;
      hints-> max_width  = PWidget(self)-> sizeMax.x;
      hints-> max_height = PWidget(self)-> sizeMax.y + XX-> menuHeight;
   } else {   
      Point who; 
      who. x = ( hints-> flags & USSize) ? hints-> width  : XX-> size. x;
      who. y = ( hints-> flags & USSize) ? hints-> height : XX-> size. y + XX-> menuHeight;
      hints-> min_width  = who. x;
      hints-> min_height = who. y;
      hints-> max_width  = who. x;
      hints-> max_height = who. y;
   }
   hints-> flags |= PMinSize | PMaxSize;
   XSetWMNormalHints( DISP, X_WINDOW, hints);
   XCHECKPOINT;
}   


Bool
apc_window_set_client_pos( Handle self, int x, int y)
{
   DEFXX;
   XSizeHints hints;

   bzero( &hints, sizeof( XSizeHints));

   if ( XX-> flags. zoomed) {
      XX-> zoomRect. left = x;
      XX-> zoomRect. bottom = y;
      return true;
   }

   if ( x == XX-> origin. x && y == XX-> origin. y) return true;
   XX-> flags. position_determined = 1;

   if ( X_WINDOW == guts. grab_redirect) {
      XWindow rx;
      XTranslateCoordinates( DISP, X_WINDOW, guts. root, 0, 0, 
         &guts. grab_translate_mouse.x, &guts. grab_translate_mouse.y, &rx);
   }
  
   y = guts. displaySize.y - XX-> size.y - XX-> menuHeight - y;
   hints. flags = USPosition;
   hints. x = x - XX-> decorationSize. x;
   hints. y = y - XX-> decorationSize. y;
   apc_SetWMNormalHints( self, &hints);
   XMoveWindow( DISP, X_WINDOW, hints. x, hints. y);
          
   prima_wm_sync( self, ConfigureNotify);
   return true;
}

static Bool
window_set_client_size( Handle self, int width, int height)
{
   DEFXX;
   XSizeHints hints;
   PWidget widg = PWidget( self);
   
   if ( !XX-> flags. zoomed) {
      widg-> virtualSize. x = width;
      widg-> virtualSize. y = height;
  } 

   width = ( width > 0)
      ? (( width >= widg-> sizeMin. x)
	  ? (( width <= widg-> sizeMax. x)
              ? width 
	      : widg-> sizeMax. x)
	  : widg-> sizeMin. x)
      : 1; 
   height = ( height > 0)
      ? (( height >= widg-> sizeMin. y)
	  ? (( height <= widg-> sizeMax. y)
	      ? height
	      : widg-> sizeMax. y)
	  : widg-> sizeMin. y)
      : 1;

   if ( XX-> flags. zoomed) {
      XX-> zoomRect. right = width;
      XX-> zoomRect. top   = height;
      return true;
   }

   bzero( &hints, sizeof( XSizeHints));
   XX-> flags. size_determined = 1;
   hints. flags = USSize | ( XX-> flags. position_determined ? USPosition : 0);
   hints. x = XX-> origin. x - XX-> decorationSize. x;
   hints. y = guts. displaySize.y - height - XX-> menuHeight - XX-> origin. y - XX-> decorationSize.y + 1;
   hints. width = width;
   hints. height = height + XX-> menuHeight;
   apc_SetWMNormalHints( self, &hints);
   if ( XX-> flags. position_determined) {
      XMoveResizeWindow( DISP, X_WINDOW, hints. x, hints. y, width, height + XX-> menuHeight);
   } else {
      XResizeWindow( DISP, X_WINDOW, width, height + XX-> menuHeight);
   }
   XCHECKPOINT;
   prima_wm_sync( self, ConfigureNotify);
   return true;
}

Bool
apc_window_set_client_size( Handle self, int width, int height)
{
   DEFXX;
   if ( width == XX-> size. x && height == XX-> size. y) return true;
   return window_set_client_size( self, width, height);
}

Bool
prima_window_reset_menu( Handle self, int newMenuHeight)
{
   DEFXX;
   int ret = true;
   int oh = XX-> menuHeight;
   if ( newMenuHeight != XX-> menuHeight) {
      XX-> menuHeight = newMenuHeight;
      if ( PWindow(self)-> stage <= csNormal && XX-> flags. size_determined)
         ret = window_set_client_size( self, XX-> size.x, XX-> size.y);
      else
         XX-> size. y -= newMenuHeight + oh;
      
     if ( XX-> shape_extent. x != 0 || XX-> shape_extent. y != 0) {
        int ny = XX-> size. y + XX-> menuHeight - XX-> shape_extent. y;
        if ( XX-> shape_offset. y != ny) {
           XShapeOffsetShape( DISP, X_WINDOW, ShapeBounding, 0, ny - XX-> shape_offset. y);
           XX-> shape_offset. y = ny;
        }
     }
   }
   return ret;
}

Bool
apc_window_set_visible( Handle self, Bool show)
{
   DEFXX;

   if ( show) {
      if ( XX-> flags. mapped) return true;
   } else {
      if ( !XX-> flags. mapped) return true;
   }

   XX-> flags. want_visible = show;
   if ( show) {
      Bool iconic = XX-> flags. iconic;
      if ( XX-> flags. withdrawn) {
         XWMHints wh;
         wh. initial_state = iconic ? IconicState : NormalState;
         wh. flags = StateHint;
         XSetWMHints( DISP, X_WINDOW, &wh);
         XX-> flags. withdrawn = 0;
      }   
      XMapWindow( DISP, X_WINDOW);
      XX-> flags. iconic = iconic;
      prima_wm_sync( self, MapNotify);
   } else {
      if ( XX-> flags. iconic) {
         XWithdrawWindow( DISP, X_WINDOW, SCREEN);
         XX-> flags. withdrawn = 1;
      } else
         XUnmapWindow( DISP, X_WINDOW);
      prima_wm_sync( self, UnmapNotify);
   }   
   XCHECKPOINT;
   return true;
}

/* apc_window_set_menu is in apc_menu.c */

Bool
apc_window_set_icon( Handle self, Handle icon)
{
   DEFXX;
   PIcon i = ( PIcon) icon;
   XIconSize * sz = nil; 
   Pixmap xor, and;
   XWMHints wmhints;
   int n;

   if ( !icon) {
      if ( !XX-> flags. has_icon) return true;
      XX-> flags. has_icon = false;
      XDeleteProperty( DISP, X_WINDOW, XA_WM_HINTS);
      wmhints. flags = InputHint;
      wmhints. input = false; 
      XSetWMHints( DISP, X_WINDOW, &wmhints);
      return true;
   }

   if ( XGetIconSizes( DISP, guts.root, &sz, &n) && n > 0) {
      int zx = sz-> min_width, zy = sz-> min_height;
      while ( 1) {
         if ( i-> w <= zx || i-> h <= zy) break;
         zx += sz-> width_inc;
         zy += sz-> height_inc;
         if ( zx >= sz-> max_width || zy >= sz-> max_height) break;
      }
      if ( zx > sz-> max_width)  zx = sz-> max_width;
      if ( zy > sz-> max_height) zy = sz-> max_height;
      if (( zx != i-> w && zy != i-> h) || ( sz-> max_width != i-> w && sz-> max_height != i-> h)) {
         Point z;
         i = ( PIcon) i-> self-> dup( icon);
         z.x = zx;
         z.y = zy;
         i-> self-> size(( Handle) i, true, z);
      }
      XFree( sz);
   } 

   xor = prima_std_pixmap( icon, CACHE_LOW_RES);
   if ( !xor) goto FAIL;
   {
      GC gc;
      XGCValues gcv;
      
      and = XCreatePixmap( DISP, guts. root, i-> w, i-> h, 1);
      if ( !and) {
         XFreePixmap( DISP, xor);
         goto FAIL;
      }
      
      gc = XCreateGC( DISP, and, 0, &gcv);
      if ( X(icon)-> image_cache. icon) {
         XSetBackground( DISP, gc, 0xffffffff);
         XSetForeground( DISP, gc, 0x00000000);
         prima_put_ximage( and, gc, X(icon)-> image_cache. icon, 0, 0, 0, 0, i-> w, i-> h);
      } else {
         XSetForeground( DISP, gc, 0xffffffff);
         XFillRectangle( DISP, and, gc, 0, 0, i-> w + 1, i-> h + 1);
      }
      XFreeGC( DISP, gc);
   }
   if (( Handle) i != icon) Object_destroy(( Handle) i);

   wmhints. flags = InputHint | IconPixmapHint | IconMaskHint;
   wmhints. icon_pixmap = xor;
   wmhints. icon_mask   = and;
   wmhints. input       = false;
   XSetWMHints( DISP, X_WINDOW, &wmhints);
   XCHECKPOINT;

   XX-> flags. has_icon = true;
   
   return true;
FAIL:

   if (( Handle) i != icon) Object_destroy(( Handle) i);
   return false;
}

static void
apc_window_set_rect( Handle self, int x, int y, int szx, int szy)
{
    XSizeHints hints;

    bzero( &hints, sizeof( XSizeHints));
    hints. flags = USPosition | USSize;
    hints. x = x - X(self)-> decorationSize. x;
    hints. y = guts. displaySize. y - szy - X(self)-> menuHeight - y - X(self)-> decorationSize. y;
    hints. width  = szx;
    hints. height = szy + X(self)-> menuHeight;
    X(self)-> flags. size_determined = 1;
    X(self)-> flags. position_determined = 1;
    XMoveResizeWindow( DISP, X_WINDOW, hints. x, hints. y, hints. width, hints. height);
    apc_SetWMNormalHints( self, &hints);
    prima_wm_sync( self, ConfigureNotify);
}   

Bool
apc_window_set_window_state( Handle self, int state)
{
   DEFXX;
   Event e;
   XWMHints * wh;
   if ( state != wsMinimized && state != wsNormal && state != wsMaximized) return false; 

   switch ( state) {
   case wsMinimized:
       if ( XX-> flags. iconic) return false;
       break;
   case wsMaximized:
       break;
   case wsNormal:
       if ( !XX-> flags. iconic && !XX-> flags. zoomed) return false;
       break;
   default:
       return false;
   }   
   
   wh = XGetWMHints( DISP, X_WINDOW);
   if ( !wh) {
      warn("Error querying XGetWMHints");
      return false;
   }
   
   if ( state == wsMaximized && !XX-> flags. zoomed) {
      XX-> zoomRect. left   = XX-> origin.x;
      XX-> zoomRect. bottom = XX-> origin.y;
      XX-> zoomRect. right  = XX-> size.x;
      XX-> zoomRect. top    = XX-> size.y;
      apc_window_set_rect( self, 0, 0, guts. displaySize.x, guts. displaySize.y - XX-> menuHeight);
   }

   if ( !XX-> flags. withdrawn) {
      if ( state == wsMinimized) {
         XIconifyWindow( DISP, X_WINDOW, SCREEN);
         if ( XX-> flags. mapped) prima_wm_sync( self, UnmapNotify);
      } else {
         XMapWindow( DISP, X_WINDOW);
         if ( !XX-> flags. mapped) prima_wm_sync( self, MapNotify);
      }   
   }     
   XX-> flags. iconic = ( state == wsMinimized) ? 1 : 0;
   
   if ( XX-> flags. zoomed && state != wsMaximized) {
      XX-> flags. zoomed = 0;
      apc_window_set_rect( self, XX-> zoomRect. left, XX-> zoomRect. bottom, 
         XX-> zoomRect. right, XX-> zoomRect. top);
   }   
   XFree( wh); 
   

   switch ( state) {
   case wsMaximized:
      if ( XX-> flags. zoomed) return true;
      break;
   case wsMinimized:
      if ( XX-> flags. iconic) return true;
      break;
   case wsNormal:
      if ( !XX-> flags. zoomed && !XX-> flags. iconic) return true;
      break;
   }
   
   bzero( &e, sizeof(e));
   e. gen. source = self;
   e. cmd = cmWindowState;
   e. gen. i = state;
   apc_message( self, &e, false);
   return true;
}

static Bool
window_start_modal( Handle self, Bool shared, Handle insert_before)
{
   DEFXX;
   if (( XX-> preexec_focus = apc_widget_get_focused()))
      protect_object( XX-> preexec_focus);
   CWindow( self)-> exec_enter_proc( self, shared, insert_before);
   apc_widget_set_enabled( self, true);
   apc_widget_set_visible( self, true);
   apc_window_activate( self);
   prima_simple_message( self, cmExecute, true);
   guts. modal_count++;
   return true;
}

Bool
apc_window_execute( Handle self, Handle insert_before)
{
   X(self)-> flags.modal = true;
   if ( !window_start_modal( self, false, insert_before))
      return false;
   if (!application) return false;

   protect_object( self);

   XSync( DISP, false);
   while ( prima_one_loop_round( true, true) && X(self) && X(self)-> flags.modal)
      ;
   unprotect_object( self);
   return true;
}

Bool
apc_window_execute_shared( Handle self, Handle insert_before)
{
   return window_start_modal( self, true, insert_before);
}

Bool
apc_window_end_modal( Handle self)
{
   PWindow win = PWindow(self);
   Handle modal, oldfoc;
   DEFXX;
   XX-> flags.modal = false;
   CWindow( self)-> exec_leave_proc( self);
   apc_widget_set_visible( self, false);
   if ( application) {
      modal = CApplication(application)->popup_modal( application);
      if ( !modal && win->owner)
         CWidget( win->owner)-> set_selected( win->owner, true);
      if (( oldfoc = XX-> preexec_focus)) {
         if ( PWidget( oldfoc)-> stage == csNormal)
            CWidget( oldfoc)-> set_focused( oldfoc, true);
         unprotect_object( oldfoc);
      }
   }
   if ( guts. modal_count > 0)
      guts. modal_count--;
   return true;
}
