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
 * $Id: apc_misc.c,v 1.74 2002/01/18 22:13:55 dk Exp $
 */

/***********************************************************/
/*                                                         */
/*  System dependent miscellaneous routines (unix, x11)    */
/*                                                         */
/***********************************************************/

#include <sys/stat.h>
#include "unix/guts.h"
#include "Application.h"
#include "File.h"
#include "Icon.h"
#define XK_MISCELLANY
#include <X11/keysymdef.h>

/* Miscellaneous system-dependent functions */

#define X_COLOR_TO_RGB(xc)     (ARGB(((xc).red>>8),((xc).green>>8),((xc).blue>>8)))

Bool
log_write( const char *format, ...)
{
   return false;
}

static XrmQuark
get_class_quark( const char *name)
{
   XrmQuark quark;
   char *s, *t;

   t = s = prima_normalize_resource_string( duplicate_string( name), true);
   if ( t && *t == 'P' && strncmp( t, "Prima__", 7) == 0)
      s = t + 7;
   if ( s && *s == 'A' && strcmp( s, "Application") == 0)
      strcpy( s, "Prima"); /* we have enough space */
   quark = XrmStringToQuark( s);
   free( t);
   return quark;
}

static XrmQuark
get_instance_quark( const char *name)
{
   XrmQuark quark;
   char *s;

   s = duplicate_string( name);
   quark = XrmStringToQuark( prima_normalize_resource_string( s, false));
   free( s);
   return quark;
}

static Bool
update_quarks_cache( Handle self)
{
   PComponent me = PComponent( self);
   XrmQuark qClass, qInstance;
   int n;
   DEFXX;
   PDrawableSysData UU;

   if (!XX)
      return false;

   qClass = get_class_quark( self == application ? "Prima" : me-> self-> className);
   qInstance = get_instance_quark( me-> name ? me-> name : "noname");

   free( XX-> q_class_name); XX-> q_class_name = nil;
   free( XX-> q_instance_name); XX-> q_instance_name = nil;

   if ( me-> owner && me-> owner != self && PComponent(me-> owner)-> sysData && X(PComponent( me-> owner))-> q_class_name) {
      UU = X(PComponent( me-> owner));
      XX-> n_class_name = n = UU-> n_class_name + 1;
      if (( XX-> q_class_name = malloc( sizeof( XrmQuark) * (n + 3))))
         memcpy( XX-> q_class_name, UU-> q_class_name, sizeof( XrmQuark) * n);
      XX-> q_class_name[n-1] = qClass;
      XX-> n_instance_name = n = UU-> n_instance_name + 1;
      if (( XX-> q_instance_name = malloc( sizeof( XrmQuark) * (n + 3))))
         memcpy( XX-> q_instance_name, UU-> q_instance_name, sizeof( XrmQuark) * n);
      XX-> q_instance_name[n-1] = qInstance;
   } else {
      XX-> n_class_name = n = 1;
      if (( XX-> q_class_name = malloc( sizeof( XrmQuark) * (n + 3))))
         XX-> q_class_name[n-1] = qClass;
      XX-> n_instance_name = n = 1;
      if (( XX-> q_instance_name = malloc( sizeof( XrmQuark) * (n + 3))))
         XX-> q_instance_name[n-1] = qInstance;
   }
   return true;
}

int
unix_rm_get_int( Handle self, XrmQuark class_detail, XrmQuark name_detail, int default_value)
{
   DEFXX;
   XrmRepresentation type;
   XrmValue value;
   long int r;
   char *end;

   if ( XX && guts.db && XX-> q_class_name && XX-> q_instance_name) {
      XX-> q_class_name[XX-> n_class_name] = class_detail;
      XX-> q_class_name[XX-> n_class_name + 1] = 0;
      XX-> q_instance_name[XX-> n_instance_name] = name_detail;
      XX-> q_instance_name[XX-> n_instance_name + 1] = 0;
      if ( XrmQGetResource( guts.db,
			    XX-> q_instance_name,
			    XX-> q_class_name,
			    &type, &value)) {
	 if ( type == guts.qString) {
	    r = strtol((char *)value. addr, &end, 0);
	    if (*(value. addr) && !*end)
	       return (int)r;
	 }
      }
   }
   return default_value;
}

void
prima_font_pp2font( char * ppFontNameSize, PFont font)
{
   char * p = strchr( ppFontNameSize, '.');
   int i;

   memset( font, 0, sizeof( Font));
   if ( p)
   {
      font-> size = atoi( ppFontNameSize);
      p++;
   } else {
      font-> size = 16;
      p = "Helv";
   }
   font-> width = font-> height = C_NUMERIC_UNDEF;
   font-> direction = 0;
   font-> pitch = fpDefault;
   font-> style = fsNormal;
   strcpy( font-> name, p);
   p = font-> name;
   for ( i = strlen( p) - 1; i >= 0; i--)
   {
      if ( p[ i] == '.')
      {
         if ( strcmp( "Italic",     &p[ i + 1]) == 0) font-> style |= fsItalic;
         if ( strcmp( "Underscore", &p[ i + 1]) == 0) font-> style |= fsUnderlined;
         if ( strcmp( "Strikeout",  &p[ i + 1]) == 0) font-> style |= fsStruckOut;
         if ( strcmp( "Bold",       &p[ i + 1]) == 0) font-> style |= fsBold;
         p[ i] = 0;
      }
   }
   apc_font_pick( application, font, font);
   font-> pitch = fpDefault;
}

Bool
apc_fetch_resource( const char *className, const char *name,
                    const char *resClass, const char *res,
                    Handle owner, int resType,
                    void *result)
{
   PDrawableSysData XX;
   XrmQuark *classes, *instances, backup_classes[3], backup_instances[3];
   XrmRepresentation type;
   XrmValue value;
   int nc, ni;
   char *s;
   XColor clr;

   if ( owner == nilHandle) {
      classes           = backup_classes;
      instances         = backup_instances;
      nc = ni = 0;
   } else {
      if (!update_quarks_cache( owner)) return false;
      XX                   = X(owner);
      if (!XX) return false;
      classes              = XX-> q_class_name;
      instances            = XX-> q_instance_name;
      if ( classes == nil || instances == nil) return false;
      nc                   = XX-> n_class_name;
      ni                   = XX-> n_instance_name;
   }
   classes[nc++]        = get_class_quark( className);
   instances[ni++]      = get_instance_quark( name);
   classes[nc++]        = get_class_quark( resClass);
   instances[ni++]      = get_instance_quark( res);
   classes[nc]          = 0;
   instances[ni]        = 0;

   /*
   if (0) {
      int i;
      fprintf( stderr, "inst: ");
      for ( i = 0; i < ni; i++) {
         fprintf( stderr, "%s ", XrmQuarkToString( instances[i]));
      }
      fprintf( stderr, "\nclas: ");
      for ( i = 0; i < nc; i++) {
         fprintf( stderr, "%s ", XrmQuarkToString( classes[i]));
      }
      fprintf( stderr, "\n");
   }
   */
   
   if ( XrmQGetResource( guts.db,
                         instances,
                         classes,
                         &type, &value)) {
      if ( type == guts.qString) {
         s = (char *)value.addr;
         switch ( resType) {
         case frString:
            *((char**)result) = duplicate_string( s);
            break;
         case frColor:
            if (!XParseColor( DISP, DefaultColormap( DISP, SCREEN), s, &clr))
               return false;
            *((Color*)result) = X_COLOR_TO_RGB(clr);
            break;
         case frFont:
            prima_font_pp2font( s, ( Font *) result);
            break;
         default:
            return false;
         }
         return true;
      }
   }

   return false;
}

/* Component-related functions */

Bool
apc_component_create( Handle self)
{
   if ( !PComponent( self)-> sysData) {
      if ( !( PComponent( self)-> sysData = malloc( sizeof( UnixSysData))))
         return false;
      bzero( PComponent( self)-> sysData, sizeof( UnixSysData));
      ((PUnixSysData)(PComponent(self)->sysData))->component. self = self;
   }
   return true;
}

Bool
apc_component_destroy( Handle self)
{
   free( PComponent( self)-> sysData);
   PComponent( self)-> sysData = nil;
   X_WINDOW = nilHandle;
   return true;
}

Bool
apc_component_fullname_changed_notify( Handle self)
{
   Handle *list;
   PComponent me = PComponent( self);
   int i, n;

   if ( self == nilHandle) return false;
   if (!update_quarks_cache( self)) return false;

   if ( me-> components && (n = me-> components-> count) > 0) {
      if ( !( list = allocn( Handle, n))) return false;
      memcpy( list, me-> components-> items, sizeof( Handle) * n);

      for ( i = 0; i < n; i++) {
	 apc_component_fullname_changed_notify( list[i]);
      }
      free( list);
   }

   return true;
}

/* Cursor support */

void
prima_no_cursor( Handle self)
{
   if ( self && guts.focused == self && X(self)
	&& X(self)-> flags. cursor_visible
	&& guts. cursor_save)
   {
      DEFXX;
      int x, y, w, h;

      h = XX-> cursor_size. y;
      y = XX-> size. y - (h + XX-> cursor_pos. y);
      x = XX-> cursor_pos. x;
      w = XX-> cursor_size. x;

      prima_get_gc( XX);
      XChangeGC( DISP, XX-> gc, VIRGIN_GC_MASK, &guts. cursor_gcv);
      XCHECKPOINT;
      XCopyArea( DISP, guts. cursor_save, XX-> udrawable, XX-> gc,
		 0, 0, w, h, x, y);
      XCHECKPOINT;
      prima_release_gc( XX);
      guts. cursor_shown = false;
   }
}

void
prima_update_cursor( Handle self)
{
   if ( guts.focused == self) {
      DEFXX;
      int x, y, w, h;

      h = XX-> cursor_size. y;
      y = XX-> size. y - (h + XX-> cursor_pos. y);
      x = XX-> cursor_pos. x;
      w = XX-> cursor_size. x;

      if ( !guts. cursor_save || !guts. cursor_xor
	   || w > guts. cursor_pixmap_size. x
	   || h > guts. cursor_pixmap_size. y)
      {
	 if ( !guts. cursor_save) {
	    guts. cursor_gcv. background = 0;
	    guts. cursor_gcv. foreground = 0xffffffff;
	 }
	 if ( guts. cursor_save) {
	    XFreePixmap( DISP, guts. cursor_save);
	    guts. cursor_save = 0;
	 }
	 if ( guts. cursor_xor) {
	    XFreePixmap( DISP, guts. cursor_xor);
	    guts. cursor_xor = 0;
	 }
	 if ( guts. cursor_pixmap_size. x < w)
	    guts. cursor_pixmap_size. x = w;
	 if ( guts. cursor_pixmap_size. y < h)
	    guts. cursor_pixmap_size. y = h;
	 if ( guts. cursor_pixmap_size. x < 16)
	    guts. cursor_pixmap_size. x = 16;
	 if ( guts. cursor_pixmap_size. y < 64)
	    guts. cursor_pixmap_size. y = 64;
	 guts. cursor_save = XCreatePixmap( DISP, XX-> udrawable,
					    guts. cursor_pixmap_size. x,
					    guts. cursor_pixmap_size. y,
					    guts. depth);
	 guts. cursor_xor  = XCreatePixmap( DISP, XX-> udrawable,
					    guts. cursor_pixmap_size. x,
					    guts. cursor_pixmap_size. y,
					    guts. depth);
      }

      prima_get_gc( XX);
      XChangeGC( DISP, XX-> gc, VIRGIN_GC_MASK, &guts. cursor_gcv);
      XCHECKPOINT;
      XCopyArea( DISP, XX-> udrawable, guts. cursor_save, XX-> gc,
		 x, y, w, h, 0, 0);
      XCHECKPOINT;
      XCopyArea( DISP, guts. cursor_save, guts. cursor_xor, XX-> gc,
		 0, 0, w, h, 0, 0);
      XCHECKPOINT;
      XSetFunction( DISP, XX-> gc, GXxor);
      XCHECKPOINT;
      XFillRectangle( DISP, guts. cursor_xor, XX-> gc, 0, 0, w, h);
      XCHECKPOINT;
      prima_release_gc( XX);

      if ( XX-> flags. cursor_visible) {
	 guts. cursor_shown = false;
	 prima_cursor_tick();
      } else {
	 apc_timer_stop( CURSOR_TIMER);
      }
   }
}

void
prima_cursor_tick( void)
{
   if ( guts. focused && X(guts. focused)-> flags. cursor_visible) {
      PDrawableSysData selfxx = X(guts. focused);
      Pixmap pixmap;
      int x, y, w, h;

      if ( guts. cursor_shown) {
	 guts. cursor_shown = false;
	 apc_timer_set_timeout( CURSOR_TIMER, guts. invisible_timeout);
	 pixmap = guts. cursor_save;
      } else {
	 guts. cursor_shown = true;
	 apc_timer_set_timeout( CURSOR_TIMER, guts. visible_timeout);
	 pixmap = guts. cursor_xor;
      }

      h = XX-> cursor_size. y;
      y = XX-> size. y - (h + XX-> cursor_pos. y);
      x = XX-> cursor_pos. x;
      w = XX-> cursor_size. x;

      prima_get_gc( XX);
      XChangeGC( DISP, XX-> gc, VIRGIN_GC_MASK, &guts. cursor_gcv);
      XCHECKPOINT;
      XCopyArea( DISP, pixmap, XX-> udrawable, XX-> gc, 0, 0, w, h, x, y);
      XCHECKPOINT;
      prima_release_gc( XX);
      XFlush( DISP);
      XCHECKPOINT;
   } else {
      apc_timer_stop( CURSOR_TIMER);
      guts. cursor_shown = !guts. cursor_shown;
   }
}

Bool
apc_cursor_set_pos( Handle self, int x, int y)
{
   DEFXX;
   prima_no_cursor( self);
   XX-> cursor_pos. x = x;
   XX-> cursor_pos. y = y;
   prima_update_cursor( self);
   return true;
}

Bool
apc_cursor_set_size( Handle self, int x, int y)
{
   DEFXX;
   prima_no_cursor( self);
   XX-> cursor_size. x = x;
   XX-> cursor_size. y = y;
   prima_update_cursor( self);
   return true;
}

Bool
apc_cursor_set_visible( Handle self, Bool visible)
{
   DEFXX;
   if ( XX-> flags. cursor_visible != visible) {
      prima_no_cursor( self);
      XX-> flags. cursor_visible = visible;
      prima_update_cursor( self);
   }
   return true;
}

Point
apc_cursor_get_pos( Handle self)
{
   return X(self)-> cursor_pos;
}

Point
apc_cursor_get_size( Handle self)
{
   return X(self)-> cursor_size;
}

Bool
apc_cursor_get_visible( Handle self)
{
   return X(self)-> flags. cursor_visible;
}

/* File */

void
prima_rebuild_watchers( void)
{
   int i;
   PFile f;

   FD_ZERO( &guts.read_set);
   FD_ZERO( &guts.write_set);
   FD_ZERO( &guts.excpt_set);
   FD_SET( guts.connection, &guts.read_set);
   guts.max_fd = guts.connection;
   for ( i = 0; i < guts.files->count; i++) {
      f = (PFile)list_at( guts.files,i);
      if ( f-> eventMask & feRead) {
	 FD_SET( f->fd, &guts.read_set);
	 if ( f->fd > guts.max_fd)
	    guts.max_fd = f->fd;
      }
      if ( f-> eventMask & feWrite) {
	 FD_SET( f->fd, &guts.write_set);
	 if ( f->fd > guts.max_fd)
	    guts.max_fd = f->fd;
      }
      if ( f-> eventMask & feException) {
	 FD_SET( f->fd, &guts.excpt_set);
	 if ( f->fd > guts.max_fd)
	    guts.max_fd = f->fd;
      }
   }
}

Bool
apc_file_attach( Handle self)
{
   if ( list_index_of( guts.files, self) >= 0) {
      prima_rebuild_watchers();
      return true;
   }
   protect_object( self);
   list_add( guts.files, self);
   prima_rebuild_watchers();
   return true;
}

Bool
apc_file_detach( Handle self)
{
   int i;
   if (( i = list_index_of( guts.files, self)) >= 0) {
      list_delete_at( guts.files, i);
      unprotect_object( self);
      prima_rebuild_watchers();
   }
   return true;
}

Bool
apc_file_change_mask( Handle self)
{
   return apc_file_attach( self);
}

int
apc_pointer_get_state( Handle self)
{
   XWindow foo;
   int bar, mask;
   XQueryPointer( DISP, guts.root,  &foo, &foo, &bar, &bar, &bar, &bar, &mask);
   return
      (( mask & Button1Mask) ? mb1 : 0) |
      (( mask & Button2Mask) ? mb2 : 0) |
      (( mask & Button3Mask) ? mb3 : 0) |
      (( mask & Button4Mask) ? mb4 : 0) |
      (( mask & Button5Mask) ? mb5 : 0);
}

int
apc_kbd_get_state( Handle self)
{
   XWindow foo;
   int bar, mask;
   XQueryPointer( DISP, guts.root, &foo, &foo, &bar, &bar, &bar, &bar, &mask);
   return
      (( mask & ShiftMask)   ? kmShift : 0) |
      (( mask & ControlMask) ? kmCtrl  : 0) |
      (( mask & Mod1Mask)    ? kmAlt   : 0);
}

/* Help */

Bool
apc_help_open_topic( Handle self, long command)
{
   DOLBUG( "apc_help_open_topic()\n");
   return false;
}

Bool
apc_help_close( Handle self)
{
   DOLBUG( "apc_help_close()\n");
   return true;
}

Bool
apc_help_set_file( Handle self, const char* helpFile)
{
   DOLBUG( "apc_help_set_file()\n");
   return true;
}


/* Messages */

Bool
prima_simple_message( Handle self, int cmd, Bool is_post)
{
   Event e;

   bzero( &e, sizeof(e));
   e. cmd = cmd;
   e. gen. source = self;
   return apc_message( self, &e, is_post);
}

Bool
apc_message( Handle self, PEvent e, Bool is_post)
{
   PendingEvent *pe;

   switch ( e-> cmd) {
   /* XXX  insert more messages here */
   case cmPost:
      /* FALLTHROUGH */
   default:
      if ( is_post) {
         if (!( pe = alloc1(PendingEvent))) return false;
         memcpy( &pe->event, e, sizeof(pe->event));
         pe-> recipient = self;
         TAILQ_INSERT_TAIL( &guts.peventq, pe, peventq_link);
      } else {
         CComponent(self)->message( self, e);
      }
      break;
   }
   return true;
}

static void 
close_msgdlg( struct MsgDlg * md)
{
   md-> active  = false;
   md-> pressed = false;
   if ( md-> grab) 
      XUngrabPointer( DISP, CurrentTime);
   md-> grab    = false;
   XUnmapWindow( DISP, md-> w);
   XFlush( DISP);
   if ( md-> next == nil) {
      XSetInputFocus( DISP, md-> focus, md-> focus_revertTo, CurrentTime);
      XCHECKPOINT;
   }   
}   

void
prima_msgdlg_event( XEvent * ev, struct MsgDlg * md)
{
   XWindow w = ev-> xany. window;
   switch ( ev-> type) {
   case ConfigureNotify:
      md-> winSz. x = ev-> xconfigure. width;
      md-> winSz. y = ev-> xconfigure. height;
      break;   
   case Expose:
      {
         int i, y = md-> textPos. y;
         int d = md-> pressed ? 2 : 0;
         XSetForeground( DISP, md-> gc, md-> bg. primary); 
         if ( md-> bg. balance > 0) {
            Pixmap p = prima_get_hatch( &guts. ditherPatterns[ md-> bg. balance]);
            if ( p) {
               XSetStipple( DISP, md-> gc, p);
               XSetFillStyle( DISP, md-> gc, FillOpaqueStippled);
               XSetBackground( DISP, md-> gc, md-> bg. secondary);
            } 
         } 
         XFillRectangle( DISP, w, md-> gc, 0, 0, md-> winSz.x, md-> winSz.y);
         if ( md-> bg. balance > 0) 
            XSetFillStyle( DISP, md-> gc, FillSolid);
         XSetForeground( DISP, md-> gc, md-> fg); 
         for ( i = 0; i < md-> wrappedCount; i++) {
            XDrawString( DISP, w, md-> gc, 
              ( md-> winSz.x - md-> widths[i]) / 2, y, 
                md-> wrapped[i], md-> lengths[i]);
            y += md-> font-> height + md-> font-> externalLeading;
         }   
         XDrawRectangle( DISP, w, md-> gc, 
            md-> btnPos.x-1, md-> btnPos.y-1, md-> btnSz.x+2, md-> btnSz.y+2);
         XDrawString( DISP, w, md-> gc, 
            md-> btnPos.x + ( md-> btnSz.x - md-> OKwidth) / 2 + d,
            md-> btnPos.y + md-> font-> height + md-> font-> externalLeading +
              ( md-> btnSz.y - md-> font-> height - md-> font-> externalLeading) / 2 - 2 + d,
            "OK", 2);
         XSetForeground( DISP, md-> gc, 
            md-> pressed ? md-> d3d : md-> l3d); 
         XDrawLine( DISP, w, md-> gc,
            md-> btnPos.x, md-> btnPos.y + md-> btnSz.y - 1, 
            md-> btnPos.x, md-> btnPos. y);
         XDrawLine( DISP, w, md-> gc,
            md-> btnPos.x + 1, md-> btnPos. y,
            md-> btnPos.x + md-> btnSz.x - 1, md-> btnPos. y);
         XSetForeground( DISP, md-> gc, 
            md-> pressed ? md-> l3d : md-> d3d); 
         XDrawLine( DISP, w, md-> gc,
            md-> btnPos.x, md-> btnPos.y + md-> btnSz.y, 
            md-> btnPos.x + md-> btnSz.x, md-> btnPos.y + md-> btnSz.y);
         XDrawLine( DISP, w, md-> gc,
            md-> btnPos.x + md-> btnSz.x, md-> btnPos.y + md-> btnSz.y - 1,
            md-> btnPos.x + md-> btnSz.x, md-> btnPos.y + 1);
      }
      break;
   case ButtonPress:
      if ( !md-> grab && 
         ( ev-> xbutton. button == Button1) &&
         ( ev-> xbutton. x >= md-> btnPos. x ) &&
         ( ev-> xbutton. x < md-> btnPos. x + md-> btnSz.x) &&
         ( ev-> xbutton. y >= md-> btnPos. y ) &&
         ( ev-> xbutton. y < md-> btnPos. y + md-> btnSz.y)) {
         md-> pressed = true;
         md-> grab = true;
         XClearArea( DISP, w, md-> btnPos.x, md-> btnPos.y,
             md-> btnSz.x, md-> btnSz.y, true); 
         XGrabPointer( DISP, w, false, 
             ButtonReleaseMask | PointerMotionMask | ButtonMotionMask,
	     GrabModeAsync, GrabModeAsync, None, None, CurrentTime);
      }   
      break;   
   case MotionNotify:
      if ( md-> grab) {
         Bool np = 
           (( ev-> xmotion. x >= md-> btnPos. x ) &&
            ( ev-> xmotion. x < md-> btnPos. x + md-> btnSz.x) &&
            ( ev-> xmotion. y >= md-> btnPos. y ) &&
            ( ev-> xmotion. y < md-> btnPos. y + md-> btnSz.y));
         if ( np != md-> pressed) {
            md-> pressed = np;
            XClearArea( DISP, w, md-> btnPos.x, md-> btnPos.y,
                md-> btnSz.x, md-> btnSz.y, true); 
         }
      }      
      break;
   case KeyPress:
      {
         char str_buf[256];
         KeySym keysym;
         int str_len = XLookupString( &ev-> xkey, str_buf, 256, &keysym, nil);
         if (
              ( keysym == XK_Return) ||
              ( keysym == XK_Escape) ||
              ( keysym == XK_KP_Enter) ||
              ( keysym == XK_KP_Space) ||
              (( str_len == 1) && ( str_buf[0] == ' '))
            ) 
            close_msgdlg( md);
      }   
      break;   
   case ButtonRelease:
      if ( md-> grab && 
         ( ev-> xbutton. button == Button1)) {
         md-> grab = false;
         XUngrabPointer( DISP, CurrentTime);
         if ( md-> pressed) close_msgdlg( md);
      }   
      break;
   case ClientMessage:
      if (( ev-> xclient. message_type == guts. wm_data-> protocols) &&
         (( Atom) ev-> xclient. data. l[0] == guts. wm_data-> deleteWindow)) 
         close_msgdlg( md);
      break;   
   }
}   
     
extern char ** Drawable_do_text_wrap( Handle, TextWrapRec *, PFontABC);

Bool
apc_show_message( const char * message)
{
   char ** wrapped;
   Font f;
   Point appSz; 
   Point textSz;
   Point winSz;
   TextWrapRec twr;
   int i;
   struct MsgDlg md, **storage;
   Bool ret = true;

   if ( !DISP) {
      warn( message);
      return true;
   }   
  
   appSz = apc_application_get_size( nilHandle);
   /* acquiring message font and wrapping message text */
   {
      PCachedFont cf;
      PFontABC abc;
      XFontStruct *fs;
      int max;
      
      apc_sys_get_msg_font( &f);
      apc_font_pick( nilHandle, &f, &f);
      cf = prima_find_known_font( &f, false, false);
      if ( !cf || !cf-> id) {
         warn( "UAF_007: internal error (cf:%08x)", (IV)cf); /* the font was not cached, can't be */
         warn( message);
         return false;
      }
      fs = XQueryFont( DISP, cf-> id);
      if (!fs) {
         warn( message);
         return false;
      }   
      abc = prima_xfont2abc( fs, 0, 255);
      
      twr. text      = ( char *) message;
      twr. textLen   = strlen( message);
      twr. width     = appSz. x * 2 / 3;
      twr. tabIndent = 3;
      twr. options   = twNewLineBreak | twWordBreak | twReturnLines;
      wrapped = Drawable_do_text_wrap( nilHandle, &twr, abc);
      free( abc);

      if ( !( md. widths  = malloc( twr. count * sizeof(int)))) {
         XFreeFontInfo( nil, fs, 1);
         warn( message);
         return false;
      }
         
      if ( !( md. lengths = malloc( twr. count * sizeof(int)))) {
         free( md. widths);
         XFreeFontInfo( nil, fs, 1);
         warn( message);
         return false;
      }

      /* find text extensions */
      max = 0;
      for ( i = 0; i < twr. count; i++) {
         md. widths[i] = XTextWidth( fs, wrapped[i], 
            md. lengths[i] = strlen( wrapped[i]));
         if ( md. widths[i] > max) max = md. widths[i];
      }   
      textSz. x = max;
      textSz. y = twr. count * ( f. height + f. externalLeading);
      
      md. wrapped       = wrapped;
      md. wrappedCount  = twr. count;
      md. font          = &f;
      md. fontId        = cf-> id;
      md. OKwidth       = XTextWidth( fs, "OK", 2);
      md. btnSz.x       = md. OKwidth + 2 + 10;
      if ( md. btnSz. x < 56) md. btnSz. x = 56;
      md. btnSz.y       = f. height + f. externalLeading + 2 + 12;
         
      winSz. x = textSz. x + 4;
      if ( winSz. x < md. btnSz. x + 2) winSz. x = md. btnSz.x + 2;
      winSz. x += f. width * 4;
      winSz. y = textSz. y + 2 + 12 + md. btnSz. y + f. height;
      while ( winSz. y + 12 >= appSz.y) {
         winSz. y -= f. height + f. externalLeading;
         md. wrappedCount--;
      }      
      md. btnPos. x = ( winSz. x - md. btnSz. x) / 2;
      md. btnPos. y = winSz. y - 2 - md. btnSz. y - f. height / 2;
      md. textPos. x = 2;
      md. textPos. y = f. height * 3 / 2 + 2;
      md. winSz = winSz;
      
      XFreeFontInfo( nil, fs, 1);
   }

   md. active  = true;
   md. next    = nil;
   md. pressed = false;
   md. grab    = false;
   XGetInputFocus( DISP, &md. focus, &md. focus_revertTo);
   XCHECKPOINT;
   {
      char * prima = "Prima";
      XTextProperty p;
      XSizeHints xs;
      XSetWindowAttributes attrs;
      attrs. event_mask = 0
	 | KeyPressMask
	 | ButtonPressMask
	 | ButtonReleaseMask
	 | ButtonMotionMask
	 | PointerMotionMask
         | StructureNotifyMask
	 | ExposureMask;
      attrs. override_redirect = false;
      attrs. do_not_propagate_mask = attrs. event_mask;
         
      md. w = XCreateWindow( DISP, guts. root,
         ( appSz.x - winSz.x) / 2, ( appSz.y - winSz.y) / 2,
         winSz.x, winSz.y, 0, CopyFromParent, InputOutput, 
         CopyFromParent, CWEventMask | CWOverrideRedirect, &attrs);  
      XCHECKPOINT;
      if ( !md. w) {
         ret = false;
         goto EXIT;
      }   
      XSetWMProtocols( DISP, md. w, &guts. wm_data-> deleteWindow, 1);
      XCHECKPOINT;
      xs. flags = PMinSize | PMaxSize | USPosition;
      xs. min_width  = xs. max_width  = winSz.x;
      xs. min_height = xs. max_height = winSz. y;
      xs. x = ( appSz.x - winSz.x) / 2;
      xs. y = ( appSz.y - winSz.y) / 2;
      XSetWMNormalHints( DISP, md. w, &xs);
      if ( XStringListToTextProperty( &prima, 1, &p) != 0) {
         XSetWMIconName( DISP, md. w, &p);
         XSetWMName( DISP, md. w, &p);
         XFree( p. value);
      }
   }

   storage = &guts. message_boxes;
   while ( *storage) storage = &((*storage)-> next);
   *storage = &md;

   {
#define CLR(x) prima_allocate_color( nilHandle,prima_map_color(x,nil),nil)
      XGCValues gcv;
      gcv. font = md. fontId;
      md. gc = XCreateGC( DISP, md. w, GCFont, &gcv);
      md. fg  = CLR(clFore | wcDialog);
      prima_allocate_color( nilHandle, prima_map_color(clBack | wcDialog,nil), &md. bg);
      md. l3d = CLR(clLight3DColor | wcDialog);
      md. d3d = CLR(clDark3DColor  | wcDialog);
#undef CLR      
   }
   
   
   XMapWindow( DISP, md. w);
   XMoveResizeWindow( DISP, md. w, 
      ( appSz.x - winSz.x) / 2, ( appSz.y - winSz.y) / 2, winSz.x, winSz.y);
   XNoOp( DISP);
   XFlush( DISP);
   while ( md. active && !guts. applicationClose) 
      prima_one_loop_round( true, false);
   
   XFreeGC( DISP, md. gc);
   XDestroyWindow( DISP, md. w);
   *storage = md. next;
EXIT:   
   free( md. widths);
   free( md. lengths);
   for ( i = 0; i < twr. count; i++)
      free( wrapped[i]);
   free( wrapped);
   
   return ret;
}

/* system metrics */

Bool
apc_sys_get_insert_mode( void)
{
   return guts. insert;
}

PFont
apc_sys_get_msg_font( PFont f)
{
   memcpy( f, &guts. default_msg_font, sizeof( Font));
   return f;
}

PFont
apc_sys_get_caption_font( PFont f)
{
   memcpy( f, &guts. default_caption_font, sizeof( Font));
   return f;
}

int
apc_sys_get_value( int v)  /* XXX one big XXX */
{
   switch ( v) {
   case svYMenu: {
      Font f;
      apc_menu_default_font( &f);
      return f. height + MENU_ITEM_GAP * 2;
   } 
   case svYTitleBar: /* XXX */ return 20;
   case svMousePresent:		return guts. mouse_buttons > 0;
   case svMouseButtons:		return guts. mouse_buttons;
   case svSubmenuDelay:  /* XXX ? */ return guts. menu_timeout;
   case svFullDrag: /* XXX ? */ return false;
   case svWheelPresent:		return guts.mouse_wheel_up || guts.mouse_wheel_down;
   case svXIcon: 
   case svYIcon: 
   case svXSmallIcon: 
   case svYSmallIcon: 
       {
          int ret[4], n;
          XIconSize * sz = nil; 
          if ( XGetIconSizes( DISP, guts.root, &sz, &n) && ( n > 0)) {
             ret[0] = sz-> max_width; 
             ret[1] = sz-> max_height;
             ret[2] = sz-> min_width; 
             ret[3] = sz-> min_height;
          } else {
             ret[0] = ret[1] = 64;
             ret[2] = ret[3] = 20;
          }
          if ( sz) XFree( sz);
          return ret[v - svXIcon];
       }
       break;
   case svXPointer:		return guts. cursor_width;
   case svYPointer:		return guts. cursor_height;
   case svXScrollbar:		return 16;
   case svYScrollbar:		return 16;
   case svXCursor:		return 1;
   case svAutoScrollFirst:	return guts. scroll_first;
   case svAutoScrollNext:	return guts. scroll_next;
   case svXbsNone:		return 0;
   case svYbsNone:		return 0;
   case svXbsSizeable:		return 3; /* XXX */
   case svYbsSizeable:		return 3; /* XXX */
   case svXbsSingle:		return 1; /* XXX */
   case svYbsSingle:		return 1; /* XXX */
   case svXbsDialog:		return 2; /* XXX */
   case svYbsDialog:		return 2; /* XXX */
   case svShapeExtension:	return guts. shape_extension;
   case svDblClickDelay:        return guts. double_click_time_frame;
   case svColorPointer:         return 0;                                
   default:
      warn( "apc_sys_get_value(): illegal query: %d", v);
   }
   return 0;
}

Bool
apc_sys_set_insert_mode( Bool insMode)
{
   guts. insert = !!insMode;
   return true;
}

/* etc */

Bool
apc_beep( int style)
{
   /* XXX - mbError, mbQuestion, mbInformation, mbWarning */
   if ( DISP)
      XBell( DISP, 0);
   return true;
}

Bool
apc_beep_tone( int freq, int duration)
{
   XKeyboardControl xkc;
   XKeyboardState   xks;
   struct timeval timeout;
   
   if ( !DISP) return false;
   
   XGetKeyboardControl( DISP, &xks);
   xkc. bell_pitch    = freq;
   xkc. bell_duration = duration;
   XChangeKeyboardControl( DISP, KBBellPitch | KBBellDuration, &xkc);
   
   XBell( DISP, 100);
   
   xkc. bell_pitch    = xks. bell_pitch;
   xkc. bell_duration = xks. bell_duration;
   XChangeKeyboardControl( DISP, KBBellPitch | KBBellDuration, &xkc);
   
   timeout. tv_sec  = duration / 1000;
   timeout. tv_usec = 1000 * (duration % 1000);
   select( 0, nil, nil, nil, &timeout);

   return true;
}

char *
apc_system_action( const char *s)
{
   int l = strlen( s);
   switch (*s) {
   case 'b':
      if ( l == 7 && strcmp( s, "browser") == 0)
         return duplicate_string("netscape");
      break;
   case 'c':
      if ( l == 19 && strcmp( s, "can.shape.extension") == 0 && guts.shape_extension)
         return duplicate_string( "yes");
      else if ( l == 26 && strcmp( s, "can.shared.image.extension") == 0 && guts.shared_image_extension)
         return duplicate_string( "yes");
      break;
   case 'D':
      if ( l == 7 && ( strcmp( s, "Display") == 0)) {
         char * c = malloc(19);
         if ( c) snprintf( c, 18, "0x%p", DISP);
         return c;
      }
      break;
   case 'g':
      if ( l > 15 && strncmp( "get.frame.info ", s, 15) == 0) {
         char *end;
         XWindow w = strtoul( s + 15, &end, 0);
         Handle self;
         Rect r;
         char buf[ 80];

         if (*end == '\0' &&
             ( self = prima_xw2h( w)) && 
             prima_get_frame_info( self, &r) &&
             snprintf( buf, sizeof(buf), "%d %d %d %d", r.left, r.bottom, r.right, r.top) < sizeof(buf))
            return duplicate_string( buf);
         return duplicate_string("");
      }
      break;
   case 's':
      if ( strcmp( "synchronize", s) == 0) {
         XSynchronize( DISP, true);
         return nil;
      }   
      if ( strncmp( "setfont ", s, 8) == 0) {
          Handle self = nilHandle;
          char font[1024];
          XWindow win;
          int i = sscanf( s + 8, "%lu %s", &win, font);
          if ( i != 2 || !(self = prima_xw2h( win)))  {
             warn( "Bad parameters to sysaction setfont");
             return 0;
          }
          if ( !opt_InPaint) return 0;
          XSetFont( DISP, X(self)-> gc, XLoadFont( DISP, font));
          return nil;
      }
      break;
   case 't':
      if ( strncmp( "textout16 ", s, 10) == 0) {
          Handle self = nilHandle;
          unsigned char text[1024];
          XWindow win;
          int x, y, len;
          int i = sscanf( s + 10, "%lu %d %d %s", &win, &x, &y, text);
          if ( i != 4 || !(self = prima_xw2h( win)))  {
             warn( "Bad parameters to sysaction textout16");
             return 0;
          }
          if ( !opt_InPaint) return 0;
          len = strlen( text);
          for ( i = 0; i < len; i++) if ( text[i]==255) text[i] = 0;
          XDrawString16( DISP, win, X(self)-> gc, x, y, ( XChar2b *) text, len / 2);
          return nil;
      }
      break;
   }
   warn("Unknow sysaction:%s", s);
   return nil;
}

Bool
apc_query_drives_map( const char* firstDrive, char *result, int len)
{
   if ( !result || len <= 0) return true;
   *result = 0;
   return true;
}

int
apc_query_drive_type( const char *drive)
{
   return dtNone;
}

char *
apc_get_user_name( void)
{
   return getlogin();
}

Bool
apc_dl_export(char *path)
{
   /* XXX */
   return true;
}

PList
apc_getdir( const char *dirname)
{
   DIR *dh;
   struct dirent *de;
   PList dirlist = nil;
   char *type;
   char path[ 2048];
   struct stat s;

   if (( dh = opendir( dirname)) && (dirlist = plist_create( 50, 50))) {
      while (( de = readdir( dh))) {
	 list_add( dirlist, (Handle)duplicate_string( de-> d_name));
#if defined(DT_REG) && defined(DT_DIR)
	 switch ( de-> d_type) {
	 case DT_FIFO:	type = "fifo";	break;
	 case DT_CHR:	type = "chr";	break;
	 case DT_DIR:	type = "dir";	break;
	 case DT_BLK:	type = "blk";	break;
	 case DT_REG:	type = "reg";	break;
	 case DT_LNK:	type = "lnk";	break;
	 case DT_SOCK:	type = "sock";	break;
#ifdef DT_WHT
	 case DT_WHT:	type = "wht";	break;
#endif
	 default:
#endif 
                        snprintf( path, 2047, "%s/%s", dirname, de-> d_name);
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
#ifdef S_IFWHT
                           case S_IFWHT:        type = "wht";   break;
#endif
                           }
                        }
                        if ( !type)     type = "unknown";
#if defined(DT_REG) && defined(DT_DIR)
	 }
#endif
	 list_add( dirlist, (Handle)duplicate_string( type));
      }
      closedir( dh);
   }
   return dirlist;
}

void
prima_rect_union( XRectangle *t, const XRectangle *s)
{
   XRectangle r;

   if ( t-> x < s-> x) r. x = t-> x; else r. x = s-> x;
   if ( t-> y < s-> y) r. y = t-> y; else r. y = s-> y;
   if ( t-> x + t-> width > s-> x + s-> width)
      r. width = t-> x + t-> width - r. x;
   else
      r. width = s-> x + s-> width - r. x;
   if ( t-> y + t-> height > s-> y + s-> height)
      r. height = t-> y + t-> height - r. y;
   else
      r. height = s-> y + s-> height - r. y;
   *t = r;
}

void
prima_rect_intersect( XRectangle *t, const XRectangle *s)
{
   XRectangle r;
   int w, h;

   if ( t-> x > s-> x) r. x = t-> x; else r. x = s-> x;
   if ( t-> y > s-> y) r. y = t-> y; else r. y = s-> y;
   if ( t-> x + t-> width < s-> x + s-> width)
      w = t-> x + (int)t-> width - r. x;
   else
      w = s-> x + (int)s-> width - r. x;
   if ( t-> y + t-> height < s-> y + s-> height)
      h = t-> y + (int)t-> height - r. y;
   else
      h = s-> y + (int)s-> height - r. y;
   if ( w < 0 || h < 0) {
      r. x = 0; r. y = 0; r. width = 0; r. height = 0;
   } else {
      r. width = w; r. height = h;
   }
   *t = r;
}



/* printer stubs */

Bool   apc_prn_create( Handle self) { return false; }
Bool   apc_prn_destroy( Handle self) { return true; }
Bool   apc_prn_select( Handle self, const char* printer) { return false; }
char * apc_prn_get_selected( Handle self) { return nil; }
Point  apc_prn_get_size( Handle self) { Point r = {0,0}; return r; }
Point  apc_prn_get_resolution( Handle self) { Point r = {0,0}; return r; }
char * apc_prn_get_default( Handle self) { return nil; }
Bool   apc_prn_setup( Handle self) { return false; }
Bool   apc_prn_begin_doc( Handle self, const char* docName) { return false; }
Bool   apc_prn_begin_paint_info( Handle self) { return false; }
Bool   apc_prn_end_doc( Handle self) { return true; } 
Bool   apc_prn_end_paint_info( Handle self) { return true; } 
Bool   apc_prn_new_page( Handle self) { return true; }
Bool   apc_prn_abort_doc( Handle self) { return true; }
ApiHandle   apc_prn_get_handle( Handle self) { return ( ApiHandle) 0; }

PrinterInfo * 
apc_prn_enumerate( Handle self, int * count) 
{
   *count = 0;
   return nil;
}

