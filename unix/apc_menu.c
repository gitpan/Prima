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
 * $Id: apc_menu.c,v 1.33 2003/01/02 11:24:27 dk Exp $
 */

/***********************************************************/
/*                                                         */
/*  System dependent menu routines (unix, x11)             */
/*                                                         */
/***********************************************************/

#include "unix/guts.h"
#include "Menu.h"
#include "Image.h"
#include "Window.h"
#include "Application.h"
#define XK_MISCELLANY
#define XK_LATIN1
#define XK_XKB_KEYS
#include <X11/keysymdef.h>

#define TREE            (PAbstractMenu(self)->tree)

static PMenuWindow
get_menu_window( Handle self, XWindow xw)
{
   DEFMM;
   PMenuWindow w = XX-> w;
   while (w && w->w != xw)
      w = w->  next;
   return w;
}

extern Cursor predefined_cursors[];

static PMenuWindow
get_window( Handle self, PMenuItemReg m)
{
   DEFMM;
   PMenuWindow w, wx;
   XSetWindowAttributes attrs;
   
   if ( !( w = malloc( sizeof( MenuWindow)))) return nil;
   bzero(w, sizeof( MenuWindow));
   w-> self = self;
   w-> m = m;
   w-> sz.x = -1;
   w-> sz.y = -1;
   attrs. event_mask = 0
      | KeyPressMask
      | KeyReleaseMask
      | ButtonPressMask
      | ButtonReleaseMask
      | EnterWindowMask
      | LeaveWindowMask
      | PointerMotionMask
      | ButtonMotionMask
      | KeymapStateMask
      | ExposureMask
      | VisibilityChangeMask
      | StructureNotifyMask
      | FocusChangeMask
      | PropertyChangeMask
      | ColormapChangeMask
      | OwnerGrabButtonMask;
   attrs. override_redirect = true;
   attrs. do_not_propagate_mask = attrs. event_mask;
   w->w = XCreateWindow( DISP, guts. root,
                         0, 0, 1, 1, 0, CopyFromParent,
                         InputOutput, CopyFromParent,
                         0
                         | CWOverrideRedirect
                         | CWEventMask
                         , &attrs);
   if (!w->w) {
      free(w);
      return nil;
   }
   XCHECKPOINT;
   hash_store( guts.menu_windows, &w->w, sizeof(w->w), (void*)self);
   wx = XX-> w;
   if ( predefined_cursors[crArrow] == None) {
      XCreateFontCursor( DISP, XC_left_ptr);
      XCHECKPOINT;
   }
   XDefineCursor( DISP, w-> w, predefined_cursors[crArrow]);
   if ( wx) {
      while ( wx-> next ) wx = wx-> next;
      w-> prev = wx;
      wx-> next = w;
   } else
      XX-> w = w;
   return w;
}

static int
item_count( PMenuWindow w)
{
   int i = 0;
   PMenuItemReg m = w->m;

   while (m) {
      i++; m=m->next;
   }
   return i;
}

static void
free_unix_items( PMenuWindow w)
{
   int i;
   if ( w-> um) {
      if ( w-> first < 0) {
         for ( i = 0; i < w->num; i++) 
            if ( w-> um[i].pixmap)
               XFreePixmap( DISP, w-> um[i].pixmap);
         free( w-> um);
      }
      w-> um = nil;
   }
   w-> num = 0;
}

static void
menu_window_delete_downlinks( PMenuSysData XX, PMenuWindow wx)
{
   PMenuWindow w = wx-> next;
   {
      XRectangle r;
      Region rgn;
      r. x = 0;
      r. y = 0;
      r. width  = guts. displaySize. x; 
      r. height = guts. displaySize. y; 
      rgn = XCreateRegion();
      XUnionRectWithRegion( &r, rgn, rgn);
      XSetRegion( DISP, guts. menugc, rgn);
      XDestroyRegion( rgn);
      XSetForeground( DISP, guts. menugc, XX->c[ciBack]);
   }
   while ( w) {
      PMenuWindow xw = w-> next;
      hash_delete( guts. menu_windows, &w-> w, sizeof( w-> w), false);
      XFillRectangle( DISP, w-> w, guts. menugc, 0, 0, w-> sz. x, w-> sz. y);
      XDestroyWindow( DISP, w-> w);
      XFlush( DISP);
      free_unix_items( w);
      free( w);
      w = xw;
   }
   wx-> next = nil;
   XX-> focused = wx;
}

#define MENU_XOFFSET 5
#define MENU_CHECK_XOFFSET 10

static void
update_menu_window( PMenuSysData XX, PMenuWindow w)
{
   int x, y = 2 + 2, startx;
   Bool vertical = w != &XX-> wstatic;
   PMenuItemReg m = w->m;
   PUnixMenuItem ix;
   int lastIncOk = 1;
   
   free_unix_items( w);
   w-> num = item_count( w);
   ix = w-> um = malloc( sizeof( UnixMenuItem) * w-> num);
   if ( !ix) return;
   bzero( w-> um, sizeof( UnixMenuItem) * w-> num);

   startx = x = vertical ? MENU_XOFFSET * 4 + MENU_CHECK_XOFFSET * 2 : 0; 
   
   if ( vertical) w-> last = -1;
   w-> selected = -100;
   while ( m) {
      if ( m-> flags. divider) {
         ix-> height = vertical ? MENU_ITEM_GAP * 2 : 0;
      } else {
         int l = 0;
         if ( m-> text) {
            int i, ntildas = 0;
            char * t = m-> text;
            ix-> height = MENU_ITEM_GAP * 2 + XX-> font-> font. height;
            for ( i = 0; t[i]; i++) {
               if ( t[i] == '~' && t[i+1]) {
                  ntildas++;
                  if ( t[i+1] == '~') 
                     i++;
               }   
            }  
            if ( m-> flags. utf8_text) {
               int len = utf8_length(( U8*) m-> text, m-> text + i);
               XChar2b * xc = prima_alloc_utf8_to_wchar( m-> text, len);
               if ( xc) {
                  ix-> width += startx + XTextWidth16( XX-> font-> fs, xc, len);
                  free( xc);
               }
            } else {
               ix-> width += startx + XTextWidth( XX-> font-> fs, m-> text, i);
            }
            if ( ntildas) {
               char c = '~';
               ix-> width -= prima_char_struct( XX-> font-> fs, &c, 0)-> width * ntildas; 
            }
         } else if ( m-> bitmap && PObject( m-> bitmap)-> stage < csDead) {
            Pixmap px = prima_std_pixmap( m-> bitmap, CACHE_LOW_RES);
            if ( px) {
               PImage i = ( PImage) m-> bitmap;
               ix-> height += ( i-> h < XX-> font-> font. height) ?  XX-> font-> font. height : i-> h +
                  MENU_ITEM_GAP * 2;
               if ( ix-> height > guts. displaySize. y - XX-> font-> font. height - MENU_ITEM_GAP * 3 - 4) 
                 ix-> height = guts. displaySize. y - XX-> font-> font. height - MENU_ITEM_GAP * 3 - 4;
               ix-> width  += i-> w + startx;
               ix-> pixmap = px;
            }
         }
         if ( m-> accel && ( l = strlen( m-> accel))) {
            if ( m-> flags. utf8_accel) {
               int len = utf8_length(( U8*) m-> accel, m-> accel + l);
               XChar2b * xc = prima_alloc_utf8_to_wchar( m-> accel, len);
               if ( xc) {
                  ix-> accel_width = XTextWidth16( XX-> font-> fs, xc, len);
                  free( xc);
               }
            } else {
               ix-> accel_width = XTextWidth( XX-> font-> fs, m-> accel, l);
            }
         }
         if ( ix-> accel_width + ix-> width > x) x = ix-> accel_width + ix-> width;
      }

      if ( vertical && lastIncOk && 
           y + ix-> height + MENU_ITEM_GAP * 2 + XX-> font-> font. height > guts. displaySize. y) {
         lastIncOk = 0;
         y += MENU_ITEM_GAP * 2 + XX-> font-> font. height;
      }
      m = m-> next;
      if ( lastIncOk) {
         y += ix-> height;
         w-> last++;
      }
      ix++;
      if ( !lastIncOk) break;
   }
   
   if ( vertical) {
      if ( x > guts. displaySize. x - 64) x = guts. displaySize. x - 64;
      w-> sz.x = x;
      w-> sz.y = y;
      XResizeWindow( DISP, w-> w, x, y);
   }
}

static int
menu_point2item( PMenuSysData XX, PMenuWindow w, int x, int y, PMenuItemReg * m_ptr)
{
   int l = 0, r = 0, index = 0;
   PMenuItemReg m;
   PUnixMenuItem ix;
   if ( !w) return -1;
   m = w-> m;
   ix = w-> um;
   if ( !ix) return -1;
   if ( w == &XX-> wstatic) {
      int right = w-> right;
      l = r = 0;
      if ( x < l) return -1;
      while ( m) {
         if ( m-> flags. divider) {
            if ( right > 0) {
               r += right;
               right = 0;
            }
            if ( x < r) return -1;
         } else {
            if ( index <= w-> last) {
               r += MENU_XOFFSET * 2 + ix-> width;
               if ( m-> accel) r += MENU_XOFFSET/2 + ix-> accel_width;
            } else
               r += MENU_XOFFSET * 2 + XX-> guillemots;
            if (x >= l && x <= r) {
               if ( m_ptr) *m_ptr = m;
               return index;
            }
            if ( index > w-> last) return -1;
         }
         l = r;
         index++;
         ix++;
         m = m-> next;
      }
   } else {
      l = r = 2;
      if ( y < l) return -1;
      while ( m) {
         if ( index > w-> last) {
            r += MENU_ITEM_GAP * 2 + XX-> font-> font. height;
            goto CHECK;
         } else if ( m-> flags. divider) {
            r += MENU_ITEM_GAP * 2;
            if ( y < r) return -1;
         } else {
            r += ix-> height;
         CHECK:   
            if ( y >= l && y <= r) {
               if ( m_ptr) *m_ptr = m;
               return index;
            }
            if ( index > w-> last) return -1;
         }
         l = r;
         index++;
         ix++;
         m = m-> next;
      }
   }
   return -1;
}

static Point
menu_item_offset( PMenuSysData XX, PMenuWindow w, int index)
{
   Point ret = {0,0};
   PMenuItemReg m = w-> m;
   PUnixMenuItem ix = w-> um;
   if ( index < 0 || !ix || !m) return ret;
   if ( w == &XX-> wstatic) {
      int right = w-> right;
      while ( m && index--) {
         if ( m-> flags. divider) {
            if ( right > 0) {
               ret. x += right;
               right = 0;
            }
         } else {
            ret. x += MENU_XOFFSET * 2 + ix-> width;
            if ( m-> accel) ret. x += MENU_XOFFSET / 2 + ix-> accel_width;
         }
         ix++;
         m = m-> next;
      }
   } else {
      ret. y = 2;
      ret. x = 2;
      while ( m && index--) {
         ret. y += ix-> height;
         ix++;
         m = m-> next;
      }
   }
   return ret;
}

static Point
menu_item_size( PMenuSysData XX, PMenuWindow w, int index)
{
   PMenuItemReg m = w-> m;
   PUnixMenuItem ix;
   Point ret = {0,0};
   if ( index < 0 || !w-> um || !m) return ret;
   if ( w == &XX-> wstatic) {
      if ( index >= 0 && index <= w-> last) {
         ix = w-> um + index; 
         while ( index--) m = m-> next; 
         if ( m-> flags. divider) return ret;
         ret. x = MENU_XOFFSET * 2 + ix-> width;
         if ( m-> accel) ret. x += MENU_XOFFSET / 2+ ix-> accel_width;
      } else if ( index == w-> last + 1) {
         ret. x = MENU_XOFFSET * 2 + XX-> guillemots;
      } else
         return ret;
      ret. y = XX-> font-> font. height + MENU_ITEM_GAP * 2; 
   } else {
      if ( index >= 0 && index <= w-> last) {
         ix = w-> um + index; 
         ret. y = ix-> height;
      } else if ( index == w-> last + 1) {
         ret. y = 2 * MENU_ITEM_GAP + XX-> font-> font. height;
      } else
         return ret;
      ret. x = w-> sz. x - 4;
   }
   return ret;
}

static void
menu_select_item( PMenuSysData XX, PMenuWindow w, int index)
{
   if ( index != w-> selected) {
      XRectangle r;
      Point p1 = menu_item_offset( XX, w, index);
      Point p2 = menu_item_offset( XX, w, w-> selected );
      Point s1 = menu_item_size( XX, w, index);
      Point s2 = menu_item_size( XX, w, w-> selected );
      if ( s1.x == 0 && s1.y == 0) {
         if ( s2.x == 0 && s2.y == 0) return;
         r.x = p2.x; r.y = p2.y;
         r.width = s2.x; r.height = s2.y;
      } else if ( s2.x == 0 && s2.y == 0) {
         r.x = p1.x; r.y = p1.y;
         r.width = s1.x; r.height = s1.y;
      } else {
         r. x = ( p1. x < p2. x) ? p1. x : p2. x;
         r. y = ( p1. y < p2. y) ? p1. y : p2. y;
         r. width  = ( p1.x + s1.x > p2.x + s2.x) ? p1.x + s1.x - r.x : p2.x + s2.x - r.x;
         r. height = ( p1.y + s1.y > p2.y + s2.y) ? p1.y + s1.y - r.y : p2.y + s2.y - r.y;
      }
      w-> selected = ( index < 0) ? -100 : index;
      XClearArea( DISP, w-> w, r.x, r.y, r.width, r.height, true);
      XX-> paint_pending = true;
   }
}

static Bool
send_cmMenu( Handle self, PMenuItemReg m)
{
    Event ev;
    Handle owner = PComponent( self)-> owner;
    bzero( &ev, sizeof( ev));
    ev. cmd = cmMenu;
    ev. gen. H = self;
    ev. gen. p = m ? m-> variable : ""; 
    CComponent(owner)-> message( owner, &ev);
    if ( PComponent( owner)-> stage == csDead ||
         PComponent( self)->  stage == csDead) return false;
    if ( self != guts. currentMenu) return false;
    return true;
}

static Bool
menu_enter_item( PMenuSysData XX, PMenuWindow w, int index, int type)
{
   PMenuItemReg m = w-> m;
   int index2 = index, div = 0;

   XX-> focused = w;
   
   if ( index < 0 || index > w-> last + 1 || !w-> um || !m) return false;
   while ( index2--) {
      if ( m-> flags. divider) div = 1;
      m = m-> next;
   }
   if ( index == w-> last + 1) div = 0;
   
   if ( m-> flags. disabled && index <= w-> last) return false;
        
   if ( m-> down || index == w-> last + 1) {
      PMenuWindow w2;
      Point p, s, n = w-> pos;

      if ( w-> next && w-> next-> m == m-> down) {
         XX-> focused = w-> next;
         return true;
      }
      
      if ( index != w-> last + 1) {
         if ( !send_cmMenu( w-> self, m)) return false;
         m = m-> down;
      }

      menu_window_delete_downlinks( XX, w);
      w2 = get_window( w-> self, m); 
      if ( !w2) return false;
      
      update_menu_window( XX, w2);
      p = menu_item_offset( XX, w, index);
      s = menu_item_size( XX, w, index);
      
      if ( &XX-> wstatic == w) {
         XWindow dummy;
         XTranslateCoordinates( DISP, w->w, guts. root, 0, 0, &n.x, &n.y, &dummy);
         w-> pos = n;
      }
      
      n. x += p. x;
      n. y += p. y;
      p. x += w-> pos. x;
      p. y += w-> pos. y;
      if ( &XX-> wstatic == w) {
         if ( div) n. x -= w2-> sz. x - s. x;
         if ( p.y + s.y + w2-> sz.y <= guts. displaySize.y)
            n. y = p. y + s. y;
         else if ( w2-> sz.y <= p. y)
            n. y = p. y - w2-> sz. y;
         else 
            n. y = 0;
         if ( n. x + w2-> sz. x > guts. displaySize. x)
            n. x = guts. displaySize. x - w2-> sz. x;
         else if ( n. x < 0)
            n. x = 0;
      } else {
         div = 0;
         if ( p.y + w2-> sz.y <= guts. displaySize.y)
            n. y = p. y;
         else if ( w2-> sz.y <= p. y + s. y)
            n. y = p. y + s. y - w2-> sz. y;
         else 
            n. y = 0;
         if ( p.x + s. x + w2-> sz.x <= guts. displaySize.x)
            n. x = p. x + s. x;
         else if ( w2-> sz.x <= p.x)
            n. x = p. x - w2-> sz. x;
         else {
            n. x = 0;
            if ( p.y + w2-> sz.y + s.y <= guts. displaySize.y)
               n. y += s.y;
            else if ( w2-> sz.y <= p. y)
               n. y -= s.y;
         }
      }
      XMoveWindow( DISP, w2-> w, n. x, n. y);
      XMapRaised( DISP, w2-> w);
      w2-> pos = n;
      XX-> focused = w2;
   } else {
      Handle self = w-> self;
      if (( &XX-> wstatic == w) && ( type == 0)) {
         menu_window_delete_downlinks( XX, w);
         return true;
      }
      prima_end_menu();
      CAbstractMenu( self)-> sub_call( self, m);
      return false;
   }
   return true;
}

void
prima_handle_menu_event( XEvent *ev, XWindow win, Handle self)
{
   switch ( ev-> type) {
   case Expose: {
      DEFMM;
      PMenuWindow w;
      PUnixMenuItem ix;
      PMenuItemReg m;
      GC gc = guts. menugc;
      int mx, my;
      Bool vertical;
      int sz = 1024, l, i, x, y;
      char *s;
      char *t;
      int right, last = 0;
      int xtoffs;
      
      XX-> paint_pending = false;
      if ( XX-> wstatic. w == win) {
         w = XX-> w;
         vertical = false;
      } else {
         if ( !( w = get_menu_window( self, win))) return;
         vertical = true;
      }
      right  = vertical ? 0 : w-> right;
      xtoffs = vertical ? MENU_CHECK_XOFFSET : 0;
      m  = w-> m;
      mx = w-> sz.x - 1;
      my = w-> sz.y - 1;
      ix = w-> um;
      if ( !ix) return;
       
      {
         XRectangle r;
         Region rgn;
         r. x = ev-> xexpose. x;
	 r. y = ev-> xexpose. y;
	 r. width = ev-> xexpose. width;
	 r. height = ev-> xexpose. height;
         rgn = XCreateRegion();
	 XUnionRectWithRegion( &r, rgn, rgn);
         XSetRegion( DISP, gc, rgn);
         XDestroyRegion( rgn);
      }

      XSetFont( DISP, gc, XX-> font-> id);
      XSetForeground( DISP, gc, XX->c[ciBack]);
      XSetBackground( DISP, gc, XX->c[ciBack]);
      if ( vertical) {
         XFillRectangle( DISP, win, gc, 2, 2, mx-1, my-1);
         XSetForeground( DISP, gc, XX->c[ciDark3DColor]);
         XDrawLine( DISP, win, gc, 0, 0, 0, my);
         XDrawLine( DISP, win, gc, 0, 0, mx-1, 0);
         XDrawLine( DISP, win, gc, mx-1, my-1, 2, my-1);
         XDrawLine( DISP, win, gc, mx-1, my-1, mx-1, 1);
         XSetForeground( DISP, gc, guts. monochromeMap[0]);
         XDrawLine( DISP, win, gc, mx, my, 1, my);
         XDrawLine( DISP, win, gc, mx, my, mx, 0);
         XSetForeground( DISP, gc, XX->c[ciLight3DColor]);
         XDrawLine( DISP, win, gc, 1, 1, 1, my-1);
         XDrawLine( DISP, win, gc, 1, 1, mx-2, 1);
      } else
         XFillRectangle( DISP, win, gc, 0, 0, w-> sz.x, w-> sz.y);
      y = vertical ? 2 : 0;
      x = 0;
      if ( !( s = malloc( sz))) goto EXIT;
      while ( m) {
         int clr; 
         Bool selected = false;

         /* printf("%d %d %d %s\n", last, w-> selected, w-> last, m-> text); */
         if ( last == w-> selected) { 
            Point sz = menu_item_size( XX, w, last);
            Point p = menu_item_offset( XX, w, last);
            XSetForeground( DISP, gc, XX-> c[ciHilite]);
            XFillRectangle( DISP, win, gc, p.x, p.y, sz. x, sz.y);
            clr = XX-> c[ciHiliteText];
            selected = true;
         } else
            clr = XX-> c[ciFore];

         if ( last > w-> last) {
            XSetForeground( DISP, gc, clr);
            XDrawString( DISP, win, gc, 
                x + MENU_XOFFSET + xtoffs, 
                y + MENU_ITEM_GAP + XX-> font-> font. height - XX-> font-> font. descent, ">>", 2);   
            break;
         }

         if ( m-> flags. divider) {
            if ( vertical) {
               y += MENU_ITEM_GAP - 1;
               XSetForeground( DISP, gc, XX->c[ciDark3DColor]);
               XDrawLine( DISP, win, gc, 1, y, mx-1, y);
               y++;
               XSetForeground( DISP, gc, XX->c[ciLight3DColor]);
               XDrawLine( DISP, win, gc, 1, y, mx-1, y);
               y += MENU_ITEM_GAP;
            } else if ( right > 0) {
               x += right;
               right = 0;
            }
         } else {
            int deltaY = 0;

            if ( m-> flags. disabled) clr = XX-> c[ciDisabledText];

            deltaY = ix-> height;
            if ( m-> text) {
               XFontStruct * xs = XX-> font-> fs;
               int lineStart = -1, lineEnd = 0, haveDash = 0;
               int ay = y + deltaY - MENU_ITEM_GAP - XX-> font-> font. descent;

               t = m-> text;
               for (;;) {
                  l = 0; i = 0;
                  while ( l < sz - 1 && t[i]) {
                     STRLEN len = 1;
                     UV uv = m-> flags. utf8_text ? utf8_to_uvchr(( U8*) t + i, &len) : *((U8*)t+i);
                     if (t[i] == '~' && t[i+1]) {
                        if ( t[i+1] == '~') {
                           if ( m-> flags. utf8_text) {
                              (( XChar2b*)(s+l))-> byte1 = 0;
                              (( XChar2b*)(s+l))-> byte2 = '~';
                              l += 2;
                           } else
                              s[l++] = '~'; 
                           i += 2;
                        } else {
                           if ( !haveDash) {
                              char buf[2];
                              if ( m-> flags. utf8_text)
                                 prima_utf8_to_wchar( t+i+1, ( XChar2b*) buf, 1);
                              else
                                 buf[0] = t[i+1];
                              haveDash = 1;
                              lineEnd = lineStart + 
                                 prima_char_struct( xs, buf, m-> flags. utf8_text)-> width;
                           }
                           i++;
                        }   
                     } else {
                        if ( !haveDash) {
                           char buf[2];
                           XCharStruct * cs;
                           if ( m-> flags. utf8_text)
                              prima_utf8_to_wchar( t+i, ( XChar2b*) buf, 1);
                           else
                              buf[0] = t[i];
                           cs = prima_char_struct( xs, ( XChar2b*) buf, m-> flags. utf8_text);
                           if ( lineStart < 0)
                              lineStart = ( cs-> lbearing < 0) ? - cs-> lbearing : 0;
                           lineStart += cs-> width;
                        }   
                        if ( m-> flags. utf8_text) {
                           (( XChar2b*)(s+l))-> byte1 = uv >> 8;
                           (( XChar2b*)(s+l))-> byte2 = uv & 0xff;
                           l += 2;
                           i += len;
                        } else 
                           s[l++] = t[i++];
                     }
                  }
                  if ( t[i]) {
                     free(s); 
                     if ( !( s = malloc( sz *= 2))) goto EXIT;
                  } else
                     break;
               }
               if ( m-> flags. disabled && !selected) {
                  XSetForeground( DISP, gc, XX->c[ciLight3DColor]); 
                  if ( m-> flags. utf8_text)
                     XDrawString16( DISP, win, gc, x+MENU_XOFFSET+xtoffs+1, ay+1, ( XChar2b*) s, l / 2);   
                  else
                     XDrawString( DISP, win, gc, x+MENU_XOFFSET+xtoffs+1, ay+1, s, l);   
               } 
               XSetForeground( DISP, gc, clr);
               if ( m-> flags. utf8_text)
                  XDrawString16( DISP, win, gc, x+MENU_XOFFSET+xtoffs, ay, ( XChar2b*) s, l / 2);   
               else
                  XDrawString( DISP, win, gc, x+MENU_XOFFSET+xtoffs, ay, s, l);
               if ( haveDash) {
                  if ( m-> flags. disabled && !selected) {
                      XSetForeground( DISP, gc, XX->c[ciLight3DColor]); 
                      XDrawLine( DISP, win, gc, x+MENU_XOFFSET+xtoffs+lineStart+1, ay+xs->max_bounds.descent-1+1, 
                         x+MENU_XOFFSET+xtoffs+lineEnd+1, ay+xs->max_bounds.descent-1+1);
                  } 
                  XSetForeground( DISP, gc, clr);
                  XDrawLine( DISP, win, gc, x+MENU_XOFFSET+xtoffs+lineStart, ay+xs->max_bounds.descent-1, 
                     x+MENU_XOFFSET+xtoffs+lineEnd, ay+xs->max_bounds.descent-1);
               }  
            } else if ( m-> bitmap && ix-> pixmap) {
               if ( selected) XSetFunction( DISP, gc, GXcopyInverted);
               XCopyArea( DISP, ix-> pixmap, win, gc, 0, 0, ix-> width, ix-> height, x+MENU_XOFFSET+xtoffs, y + MENU_ITEM_GAP);
               if ( selected) XSetFunction( DISP, gc, GXcopy);
            }
            if ( !vertical) x += ix-> width + MENU_XOFFSET;

            if ( m-> accel) {
               int ul = 0;
               int zx = vertical ? 
                  mx - MENU_XOFFSET - MENU_CHECK_XOFFSET - ix-> accel_width : 
                  x + MENU_XOFFSET/2;
               int zy = vertical ? 
                  y + ( deltaY + XX-> font-> font. height) / 2 - XX-> font-> font. descent: 
                  y + deltaY - MENU_ITEM_GAP - XX-> font-> font. descent;
               l = strlen( m-> accel);
               if ( m-> flags. utf8_accel) {
                  ul = prima_utf8_length( m-> accel);
                  if ( ul * 2 < sz) {
                     free(s); 
                     if ( !( s = malloc( sz = (ul * 2 + 2)))) goto EXIT;
                  }
                  prima_utf8_to_wchar( m-> accel, ( XChar2b*)s, ul);
               }
               if ( m-> flags. disabled && !selected) {
                  XSetForeground( DISP, gc, XX->c[ciLight3DColor]); 
                  if ( m-> flags. utf8_accel) 
                     XDrawString16( DISP, win, gc, zx + 1, zy + 1, ( XChar2b*) s, ul);
                  else
                     XDrawString( DISP, win, gc, zx + 1, zy + 1, m-> accel, l);
               } 
               XSetForeground( DISP, gc, clr);
               if ( m-> flags. utf8_accel) 
                  XDrawString16( DISP, win, gc, zx, zy, ( XChar2b*) s, ul);
               else
                  XDrawString( DISP, win, gc, zx, zy, m-> accel, l);
               if ( !vertical)
                  x += ix-> accel_width + MENU_XOFFSET/2;
            }
            if ( !vertical) x += MENU_XOFFSET;

            if ( vertical && m-> down) {
               int ave    = XX-> font-> font. height * 0.4;
               int center = y + deltaY / 2;
               XPoint p[3];
               p[0].x = mx - MENU_CHECK_XOFFSET/2;
               p[0].y = center;
               p[1].x = mx - ave - MENU_CHECK_XOFFSET/2;
               p[1].y = center - ave * 0.6;
               p[2].x = mx - ave - MENU_CHECK_XOFFSET/2;
               p[2].y = center + ave * 0.6 + 1;
               if ( m-> flags. disabled && !selected) {
                  int i;
                  XSetForeground( DISP, gc, XX->c[ciLight3DColor]); 
                  for ( i = 0; i < 3; i++) { 
                     p[i].x++;
                     p[i].y++;
                  }   
                  XFillPolygon( DISP, win, gc, p, 3, Nonconvex, CoordModeOrigin);   
                  for ( i = 0; i < 3; i++) { 
                     p[i].x--;
                     p[i].y--;
                  }   
               } 
               XSetForeground( DISP, gc, clr);
               XFillPolygon( DISP, win, gc, p, 3, Nonconvex, CoordModeOrigin);
            } 
            if ( m-> flags. checked && vertical) { 
               /* don't draw check marks on horizontal menus - they look ugly */
               int bottom = y + deltaY - MENU_ITEM_GAP - ix-> height * 0.2;
               int ax = x + MENU_XOFFSET / 2;
               XGCValues gcv;
               gcv. line_width = 3;
               XChangeGC( DISP, gc, GCLineWidth, &gcv); 
               if ( m-> flags. disabled && !selected) {
                  XSetForeground( DISP, gc, XX->c[ciLight3DColor]); 
                  XDrawLine( DISP, win, gc, ax + 1 + 1 , y + deltaY / 2 + 1, ax + MENU_XOFFSET - 2 + 1, bottom - 1);
                  XDrawLine( DISP, win, gc, ax + MENU_XOFFSET - 2 + 1, bottom + 1, ax + MENU_CHECK_XOFFSET + 1, y + MENU_ITEM_GAP + ix-> height * 0.2);
               } 
               XSetForeground( DISP, gc, clr);
               XDrawLine( DISP, win, gc, ax + 1, y + deltaY / 2, ax + MENU_XOFFSET - 2, bottom);
               XDrawLine( DISP, win, gc, ax + MENU_XOFFSET - 2, bottom, ax + MENU_CHECK_XOFFSET, y + MENU_ITEM_GAP + ix-> height * 0.2);
               gcv. line_width = 1;
               XChangeGC( DISP, gc, GCLineWidth, &gcv); 
            } 
            if ( vertical) y += deltaY;
         }
         m = m-> next;
         ix++;
         last++;
      }
      free(s);
   EXIT:; 
   }
   break;
   case ConfigureNotify: {
      DEFMM;
      if ( XX-> wstatic. w == win) {
         PMenuWindow  w = XX-> w;
         PMenuItemReg m;
         PUnixMenuItem ix;
         int x = 0;
         int stage = 0;
         if ( w-> sz. x == ev-> xconfigure. width &&
              w-> sz. y == ev-> xconfigure. height) return;
         if ( guts. currentMenu == self) prima_end_menu();
         w-> sz. x = ev-> xconfigure. width;
         w-> sz. y = ev-> xconfigure. height;

AGAIN:             
         w-> last = -1;
         m = w-> m;
         ix = w-> um;
         while ( m) { 
            int dx = 0;
            if ( !m-> flags. divider) {
               dx += MENU_XOFFSET * 2 + ix-> width; 
               if ( m-> accel) dx += MENU_XOFFSET / 2 + ix-> accel_width;
            }
            if ( x + dx >= w-> sz.x) {
               if ( stage == 0) { /* now we are sure that >> should be drawn - check again */
                  x = MENU_XOFFSET * 2 + XX-> guillemots;
                  stage++;
                  goto AGAIN;
               } 
               break;
            }
            x += dx;
            w-> last++;
            m = m-> next;
            ix++; 
         }
         m = w-> m;
         ix = w-> um;
         w-> right = 0;
         if ( w-> last >= w-> num - 1) {
            Bool hit = false;
            x = 0;
            while ( m) {
               if ( m-> flags. divider) {
                  hit = true;
                  break;
               } else {
                  x += MENU_XOFFSET * 2 + ix-> width; 
                  if ( m-> accel) x += MENU_XOFFSET / 2 + ix-> accel_width;
               }
               m = m-> next; 
               ix++;
            }
            if ( hit) {
               w-> right = 0;
               while ( m) {
                  if ( !m-> flags. divider) {
                     w-> right += MENU_XOFFSET * 2 + ix-> width; 
                     if ( m-> accel) w-> right += MENU_XOFFSET / 2 + ix-> accel_width;
                  }
                  m = m-> next;
                  ix++;
               }
               w-> right = w-> sz.x - w-> right - x;
            }
         }
      }
   }
   break;
   case ButtonPress: 
   case ButtonRelease: {
      DEFMM;
      int px, first = 0;
      PMenuWindow w;
      XWindow focus = nilHandle;
      if ( prima_no_input( X(PComponent(self)->owner), false, true)) return;
      if ( ev-> xbutton. button != Button1) return;

      if ( XX-> wstatic. w == win) {
         Handle x = guts. focused, owner = PComponent(self)-> owner;
         while ( x && !X(x)-> type. window) x = PComponent( x)-> owner;
         if ( x != owner) {
            XSetInputFocus( DISP, focus = PComponent( owner)-> handle, 
               RevertToNone, ev-> xbutton. time);
         }
      }
      
      if ( !( w = get_menu_window( self, win))) {
         prima_end_menu();
         return;
      }
      px = menu_point2item( XX, w, ev-> xbutton. x, ev-> xbutton.y, nil);
      if ( px < 0) {
         if ( XX-> wstatic. w == win) 
            prima_end_menu();
         return;
      }
      if ( guts. currentMenu != self) {
         int rev;
         if ( ev-> type == ButtonRelease) return;
         if ( guts. currentMenu) 
            prima_end_menu();
         if ( focus)
            XX-> focus = focus;
         else
            XGetInputFocus( DISP, &XX-> focus, &rev);
         if ( !XX-> type. popup) {
            Handle topl = PComponent( self)-> owner;
            Handle who  = ( Handle) hash_fetch( guts.windows, (void*)&XX-> focus, sizeof(XX-> focus));
            while ( who) {
               if ( XT_IS_WINDOW(X(who))) {
                  if ( who != topl) XX-> focus = PComponent( topl)-> handle;
                  break;
               }
               who = PComponent( who)-> owner;
            }
         } 
         first = 1;
      }
      XSetInputFocus( DISP, XX-> w-> w, RevertToNone, CurrentTime);
      guts. currentMenu = self;
      if ( first && ( ev-> type == ButtonPress) && ( !send_cmMenu( self, nil)))
         return;
      apc_timer_stop( MENU_TIMER);
      menu_select_item( XX, w, px);
      if ( !ev-> xbutton. send_event) {
         if ( !menu_enter_item( XX, w, px, ( ev-> type == ButtonPress) ? 0 : 1))
            return;
      } else
         XX-> focused = w;
      
      ev-> xbutton. x += w-> pos. x;
      ev-> xbutton. y += w-> pos. y;
      if ( w-> next && 
           ev-> xbutton. x >= w-> next-> pos.x &&
           ev-> xbutton. y >= w-> next-> pos.y &&
           ev-> xbutton. x <  w-> next-> pos.x + w-> next-> sz.x &&
           ev-> xbutton. y <  w-> next-> pos.y + w-> next-> sz.y)
           { /* simulate mouse move, as X are stupid enough to not do it  */
         int x = ev-> xbutton.x, y = ev-> xbutton. y;
         ev-> xmotion. x = x - w-> next-> pos. x;
         ev-> xmotion. y = y - w-> next-> pos. y;
         win = w-> next-> w;
         goto MOTION_NOTIFY;
      }
   }
   break;       
   MOTION_NOTIFY:
   case MotionNotify: if ( guts. currentMenu == self) {
      DEFMM;
      PMenuItemReg m;
      PMenuWindow w = get_menu_window( self, win);
      int px = menu_point2item( XX, w, ev-> xmotion.x, ev-> xmotion.y, nil);
      menu_select_item( XX, w, px);
      m = w-> m;
      if ( px >= 0) {
         int x = px;
         while ( x--) m = m-> next;
         if ( px != w-> last + 1) m = m-> down;
         if ( !w-> next || w-> next-> m != m) {
            apc_timer_set_timeout( MENU_TIMER, (XX-> wstatic. w == win) ? 2 : guts. menu_timeout);
            XX-> focused = w;
         }
      }
      while ( w-> next) {
         menu_select_item( XX, w-> next, -1);
         w = w-> next;
      }
   }
   break;
   case FocusOut:
      if ( self == guts. currentMenu) {
         switch ( ev-> xfocus. detail) {
         case NotifyVirtual:
         case NotifyPointer:
         case NotifyPointerRoot: 
         case NotifyDetailNone: 
         case NotifyNonlinearVirtual: 
            return;
         }
         apc_timer_stop( MENU_UNFOCUS_TIMER);
         apc_timer_start( MENU_UNFOCUS_TIMER);
         guts. unfocusedMenu = self;
      }
      break;
   case FocusIn:
      if ( guts. unfocusedMenu && self == guts. unfocusedMenu && self == guts. currentMenu) {
         switch ( ev-> xfocus. detail) {
         case NotifyVirtual:
         case NotifyPointer:
         case NotifyPointerRoot: 
         case NotifyDetailNone: 
         case NotifyNonlinearVirtual: 
            return;
         }
         apc_timer_stop( MENU_UNFOCUS_TIMER);
         guts. unfocusedMenu = nilHandle;
      }
      break;
   case KeyPress: {
      DEFMM;                     
      char str_buf[ 256];
      KeySym keysym;
      int str_len, d = 0, piles = 0;
      PMenuWindow w;
      PMenuItemReg m;

      str_len = XLookupString( &ev-> xkey, str_buf, 256, &keysym, nil);
      if ( prima_handle_menu_shortcuts( PComponent(self)-> owner, ev, keysym) != 0)
         return;
      
      if ( self != guts. currentMenu) return;
      apc_timer_stop( MENU_TIMER);
      if ( !XX-> focused) return;
      /* navigation */
      w = XX-> focused;
      m = w-> m;
      switch (keysym) {
      case XK_Left:
      case XK_KP_Left:
         if ( w == &XX-> wstatic) { /* horizontal menu */
            d--; 
         } else if ( w != XX-> w) { /* not a popup root */
            if ( w-> prev) menu_window_delete_downlinks( XX, w-> prev);
            if ( w-> prev == &XX-> wstatic) {
               d--;
               piles = 1;
            } else
               return;
         }
         break;
      case XK_Right:
      case XK_KP_Right:
         if ( w == &XX-> wstatic) { /* horizontal menu */
            d++; 
         } else if ( w-> selected >= 0) {
            int sel;
            sel = w-> selected;
            if ( sel >= 0) {
               while ( sel--) m = m-> next;
            }
            if ( m-> down || w-> selected == w-> last + 1) {
               if ( menu_enter_item( XX, w, w-> selected, 1) && w-> next)
                  menu_select_item( XX, w-> next, 0);
            } else if ( w-> prev == &XX-> wstatic) {
               menu_window_delete_downlinks( XX, XX-> w);
               piles = 1;
               d++;
            } else
               return;
         }
         break;
      case XK_Up:
      case XK_KP_Up:
         if ( w != &XX-> wstatic) d--;
         break;
      case XK_Down:
      case XK_KP_Down:
         if ( w == &XX-> wstatic) {
            int sel = w-> selected;
            if ( sel >= 0) {
               while ( sel--) m = m-> next;
            }
            if ( m-> down || w-> selected == w-> last + 1) {
               if ( menu_enter_item( XX, w, w-> selected, 1) && w-> next) 
                  menu_select_item( XX, w-> next, 0);
            }
         } else
            d++;
         break;
      case XK_KP_Enter:
      case XK_Return:
         menu_enter_item( XX, w, w-> selected, 1);
         return;
      case XK_Escape:
         if ( w-> prev) 
            menu_window_delete_downlinks( XX, w-> prev);
         else
            prima_end_menu();
         return;
      default:
         goto NEXT_STAGE;
      }

      if ( piles) w = XX-> focused = w-> prev;
      
      if ( d != 0) {
         int sel = w-> selected;
         PMenuItemReg m;
         int z, last = w-> last + (( w-> num == w-> last + 1) ? 0 : 1);

         if ( sel < -1) sel = -1;
         while ( 1) {
            if ( d > 0) {
               sel = ( sel >= last) ? 0 : sel + 1;
            } else {
               sel = ( sel <= 0) ? last : sel - 1;
            }
            m = w-> m;
            z = sel;
            while ( z--) m = m-> next;
            if ( sel == w-> last + 1 || !m-> flags. divider) {
               menu_select_item( XX, w, sel);
               menu_window_delete_downlinks( XX, w);
               if ( piles) {
                  if ( menu_enter_item( XX, w, sel, 0) && w-> next)
                     menu_select_item( XX, w-> next, 0);
               }
               break;
            }
         }
        
      }
      return;
NEXT_STAGE:

      if ( str_len == 1) {
         int i;
	 char c = tolower( str_buf[0]);
         for ( i = 0; i <= w-> last; i++) {
            if ( m-> text) {
               int j = 0;
               char * t = m-> text, z = 0;
               while ( t[j]) {
                  if ( t[j] == '~' && t[j+1]) {
                     if ( t[j+1] == '~')
                        j += 2;
                     else {
                        z = tolower(t[j+1]);
                        break;
                     }
                  }
                  j++;
               }
               if ( z == c) {
                  menu_enter_item( XX, w, i, 1);
                  return;
               }
            }
            m = m-> next;
         }
      }
   }
   break;
   case MenuTimerMessage: 
   if ( self == guts. currentMenu) {
      DEFMM;
      PMenuWindow w;
      PMenuItemReg m;
      int s;
     
      if ( !( w = XX-> focused)) return;
      m = w-> m;
      s = w-> selected;
      if ( s < 0) return;
      while ( s--) m = m-> next;
      if ( m-> down || w-> selected == w-> last + 1) 
         menu_enter_item( XX, w, w-> selected, 0);
      else
         menu_window_delete_downlinks( XX, w);
   } 
   break;
   }
}

/* local menu access hacks; it's good idea to have
   hot keys changeable through resources, but have no
   idea ( and desire :) how to plough throgh it */
int
prima_handle_menu_shortcuts( Handle self, XEvent * ev, KeySym keysym)
{
   int ret = 0;
   int mod = 
      (( ev-> xkey. state & ShiftMask)	? kmShift : 0) |
      (( ev-> xkey. state & ControlMask)? kmCtrl  : 0) |
      (( ev-> xkey. state & Mod1Mask)	? kmAlt   : 0);

   if ( mod == kmShift && keysym == XK_F9) {
      Event e;
      bzero( &e, sizeof(e));
      e. cmd    = cmPopup; 
      e. gen. B = false;
      e. gen. P = apc_pointer_get_pos( application); 
      e. gen. H = self;
      apc_widget_map_points( self, false, 1, &e. gen. P);
      CComponent( self)-> message( self, &e);
      if ( PObject( self)-> stage == csDead) return -1;
      ret = 1;
   }

   if ( mod == 0 && keysym == XK_F10) {
      Handle ps = self;
      while ( PComponent( self)-> owner) {
         ps = self;
         if ( XT_IS_WINDOW(X(self))) break;
         self = PComponent( self)-> owner;
      }
      self = ps;

      if ( XT_IS_WINDOW(X(self)) && PWindow(self)-> menu) {
         if ( !guts. currentMenu) {
            XEvent ev;
            bzero( &ev, sizeof( ev));
            ev. type = ButtonPress;
            ev. xbutton. button = Button1; 
            ev. xbutton. send_event = true;
            prima_handle_menu_event( &ev, M(PWindow(self)-> menu)-> w-> w, PWindow(self)-> menu);
         } else 
            prima_end_menu();
         ret = 1;
      }
   }
   return ret;
}

void
prima_end_menu(void)
{
   PMenuSysData XX;
   PMenuWindow w;
   apc_timer_stop( MENU_TIMER);
   apc_timer_stop( MENU_UNFOCUS_TIMER);
   guts. unfocusedMenu = nilHandle; 
   if ( !guts. currentMenu) return;
   XX = M(guts. currentMenu);
   {
      XRectangle r;
      Region rgn;
      r. x = 0;
      r. y = 0;
      r. width  = guts. displaySize. x; 
      r. height = guts. displaySize. y; 
      rgn = XCreateRegion();
      XUnionRectWithRegion( &r, rgn, rgn);
      XSetRegion( DISP, guts. menugc, rgn);
      XDestroyRegion( rgn);
      XSetForeground( DISP, guts. menugc, XX->c[ciBack]);
   }
   w = XX-> w;
   if ( XX-> focus)
      XSetInputFocus( DISP, XX-> focus, RevertToNone, CurrentTime);
   menu_window_delete_downlinks( XX, XX-> w);
   XX-> focus = nilHandle;
   XX-> focused = nil; 
   if ( XX-> w != &XX-> wstatic) {
      hash_delete( guts. menu_windows, &w-> w, sizeof( w-> w), false);
      XDestroyWindow( DISP, w-> w);
      free_unix_items( w);
      free( w);
      XX-> w = nil;
   } else {
      XX-> w-> next = nil;
      menu_select_item( XX, XX-> w, -100);
   }
   guts. currentMenu = nilHandle;
}

Bool
apc_menu_create( Handle self, Handle owner)
{
   DEFMM;
   int i;
   apc_menu_destroy( self);
   XX-> type.menu = true;
   XX-> w         = &XX-> wstatic;
   XX-> w-> self  = self; 
   XX-> w-> m     = TREE;
   XX-> w-> first = 0;
   for ( i = 0; i <= ciMaxId; i++)
      XX-> c[i] = prima_allocate_color( 
          nilHandle, 
          prima_map_color( PWindow(owner)-> menuColor[i], nil), 
          nil);
   apc_menu_set_font( self, &PWindow(owner)-> menuFont);
   return true;
}

Bool
apc_menu_destroy( Handle self)
{
   if ( guts. currentMenu == self) prima_end_menu();
   return true;
}

PFont
apc_menu_default_font( PFont f)
{
   memcpy( f, &guts. default_menu_font, sizeof( Font));
   return f;
}

Color
apc_menu_get_color( Handle self, int index)
{
   Color c;
   if ( index < 0 || index > ciMaxId) return clInvalid;
   c = M(self)-> c[index];
   if ( guts. palSize > 0) 
       return guts. palette[c]. composite;
   return
      ((((c & guts. visual. blue_mask)  >> guts. blue_shift) << 8) >> guts. blue_range) |
     (((((c & guts. visual. green_mask) >> guts. green_shift) << 8) >> guts. green_range) << 8) |
     (((((c & guts. visual. red_mask)   >> guts. red_shift)   << 8) >> guts. red_range) << 16);
}

PFont
apc_menu_get_font( Handle self, PFont font)
{
   DEFMM;
   if ( !XX-> font)
      return apc_menu_default_font( font);
   memcpy( font, &XX-> font-> font, sizeof( Font));
   return font;
}

Bool
apc_menu_set_color( Handle self, Color color, int i)
{
   DEFMM;
   if ( i < 0 || i > ciMaxId) return false;
   if ( !XX-> type.popup) {
      if ( X(PWidget(self)-> owner)-> menuColorImmunity) {
         X(PWidget(self)-> owner)-> menuColorImmunity--;
         return true;
      }
      if ( X_WINDOW) {
         prima_palette_replace( PWidget(self)-> owner, false);
         if ( !XX-> paint_pending) {
            XClearArea( DISP, X_WINDOW, 0, 0, XX-> w-> sz.x, XX-> w-> sz.y, true);
            XX-> paint_pending = true;
         }
      }
   } else 
      XX-> c[i] = prima_allocate_color( nilHandle, prima_map_color( color, nil), nil);
   return true;
}

/* apc_menu_set_font is in apc_font.c */

void
menu_touch( Handle self, PMenuItemReg who, Bool kill)
{
   DEFMM;
   PMenuWindow w, lw = nil;

   if ( guts. currentMenu != self) return;

   w = XX-> w;
   while ( w) {
      if ( w-> m == who) {
         if ( kill || lw == nil)
            prima_end_menu(); 
         else
            menu_window_delete_downlinks( M(self), lw);
         return;
      }
      lw = w;
      w = w-> next;
   }
}

static void 
menu_reconfigure( Handle self)
{
   XEvent ev;
   ev. type = ConfigureNotify;
   ev. xconfigure. width  = X(PComponent(self)-> owner)-> size.x;
   ev. xconfigure. height = X(PComponent(self)-> owner)-> size.y;
   prima_handle_menu_event( &ev, PMenu(self)-> handle, self);
}

Bool
apc_menu_update( Handle self, PMenuItemReg oldBranch, PMenuItemReg newBranch)
{
   DEFMM;
   if ( !XT_IS_POPUP(XX) && XX-> w-> m == oldBranch) {
      if ( guts. currentMenu == self) prima_end_menu();
      XX-> w-> m = newBranch;
      if ( PMenu(self)-> handle) {
         update_menu_window( XX, XX-> w);
         menu_reconfigure( self);
         XClearArea( DISP, X_WINDOW, 0, 0, XX-> w-> sz.x, XX-> w-> sz.y, true);
         XX-> paint_pending = true;
      }
   }
   menu_touch( self, oldBranch, true);
   return true;
}

Bool
apc_menu_item_delete( Handle self, PMenuItemReg m)
{
   DEFMM;
   if ( !XT_IS_POPUP(XX) && XX-> w-> m == m) {
      if ( guts. currentMenu == self) prima_end_menu();
      XX-> w-> m = TREE;
      if ( PMenu(self)-> handle) {
         update_menu_window( XX, XX-> w);
         menu_reconfigure( self);
         XClearArea( DISP, X_WINDOW, 0, 0, XX-> w-> sz.x, XX-> w-> sz.y, true);
         XX-> paint_pending = true;
      }
   }
   menu_touch( self, m, true);
   return true;
}

Bool
apc_menu_item_set_accel( Handle self, PMenuItemReg m)
{
   menu_touch( self, m, false);
   return true;
}

Bool
apc_menu_item_set_check( Handle self, PMenuItemReg m)
{
   menu_touch( self, m, false);
   return true;
}

Bool
apc_menu_item_set_enabled( Handle self, PMenuItemReg m)
{
   menu_touch( self, m, false);
   return true;
}

Bool
apc_menu_item_set_image( Handle self, PMenuItemReg m)
{
   menu_touch( self, m, false);
   return true;
}

Bool
apc_menu_item_set_key( Handle self, PMenuItemReg m)
{
   menu_touch( self, m, false);
   return true;
}

Bool
apc_menu_item_set_text( Handle self, PMenuItemReg m)
{
   menu_touch( self, m, false);
   return true;
}

ApiHandle
apc_menu_get_handle( Handle self)
{
   return nilHandle;
}

Bool
apc_popup_create( Handle self, Handle owner)
{
   DEFMM;
   apc_menu_destroy( self);
   XX-> type.menu = true;
   XX-> type.popup = true;
   return true;
}

PFont
apc_popup_default_font( PFont f)
{
   memcpy( f, &guts. default_menu_font, sizeof( Font));
   return f;
}

Bool
apc_popup( Handle self, int x, int y, Rect *anchor)
{
   DEFMM;
   PMenuItemReg m;
   PMenuWindow w;
   XWindow dummy;
   PDrawableSysData owner;
   int dx, dy;

   prima_end_menu();
   if (!(m=TREE)) return false;
   guts. currentMenu = self;
   if ( !send_cmMenu( self, nil)) return false;
   if (!(w = get_window(self,m))) return false;
   update_menu_window(XX, w);
   if ( anchor-> left == 0 && anchor-> right == 0 && anchor-> top == 0 && anchor-> bottom == 0) {
      anchor-> left = anchor-> right = x;
      anchor-> top = anchor-> bottom = y;
   } else {
      if ( x < anchor-> left)   anchor-> left   = x;
      if ( x > anchor-> right)  anchor-> right  = x;
      if ( y < anchor-> bottom) anchor-> bottom = y;
      if ( y > anchor-> top)    anchor-> top    = y;
   }
   owner = X(PComponent(self)->owner);
   y = owner-> size. y - y + owner-> menuHeight;
   anchor-> bottom = owner-> size. y - anchor-> bottom + owner-> menuHeight;
   anchor-> top = owner-> size. y - anchor-> top + owner-> menuHeight;
   dx = dy = 0;
   XTranslateCoordinates( DISP, owner->udrawable, guts. root, dx, dy, &dx, &dy, &dummy);
   x += dx;
   y += dy;
   anchor-> left   += dx;
   anchor-> right  += dx;
   anchor-> top    += dy;
   anchor-> bottom += dy;
   if ( anchor-> bottom + w-> sz.y <= guts. displaySize.y)
      y = anchor-> bottom;
   else if ( w-> sz. y < anchor-> top)
      y = anchor-> top - w-> sz. y;
   else
      y = 0;
   if ( anchor-> right + w-> sz.x <= guts. displaySize.x)
      x = anchor-> right;
   else if ( w-> sz.x < anchor-> left)
      x = anchor-> left - w-> sz. x;
   else
      x = 0;
   w-> pos. x = x;
   w-> pos. y = y;
   XX-> focused = w;
   XGetInputFocus( DISP, &XX-> focus, &dx);
   XMoveWindow( DISP, w->w, x, y);
   XMapRaised( DISP, w->w);
   XSetInputFocus( DISP, w->w, RevertToNone, CurrentTime);
   XFlush( DISP);
   XCHECKPOINT;
   return true;
}

Bool
apc_window_set_menu( Handle self, Handle menu)
{
   DEFXX;
   int y = XX-> menuHeight;
   Bool repal = false;
   
   if ( XX-> menuHeight > 0) {
      PMenu m = ( PMenu) PWindow( self)-> menu;
      PMenuWindow w = M(m)-> w;
      if ( m-> handle == guts. currentMenu) prima_end_menu();
      hash_delete( guts. menu_windows, &w-> w, sizeof( w-> w), false);
      XDestroyWindow( DISP, w-> w);
      free_unix_items( w);
      m-> handle = nilHandle;
      M(m)-> paint_pending = false;
      M(m)-> focused = nil;
      y = 0;
      repal = true;
   }

   if ( menu) {
      PMenu m = ( PMenu) menu;
      XSetWindowAttributes attrs;
      attrs. event_mask =           KeyPressMask | ButtonPressMask  | ButtonReleaseMask
         | EnterWindowMask     | LeaveWindowMask | ButtonMotionMask | ExposureMask
         | StructureNotifyMask | FocusChangeMask | OwnerGrabButtonMask
         | PointerMotionMask;
      attrs. do_not_propagate_mask = attrs. event_mask;
      attrs. win_gravity = NorthWestGravity;
      y = PWindow(self)-> menuFont. height + MENU_ITEM_GAP * 2;
      M(m)-> w-> w = m-> handle = XCreateWindow( DISP, X_WINDOW, 
         0, 0, 1, 1, 0, CopyFromParent, 
         InputOutput, CopyFromParent, CWWinGravity| CWEventMask, &attrs);
      hash_store( guts. menu_windows, &m-> handle, sizeof( m-> handle), m);
      XResizeWindow( DISP, m-> handle, XX-> size.x, y);
      XMapRaised( DISP, m-> handle);
      M(m)-> paint_pending = true;
      M(m)-> focused = nil;
      update_menu_window(M(m), M(m)-> w);
      menu_reconfigure( menu);
      repal = true;
      /* make it immune to necessary color change calls */
      XX-> menuColorImmunity = ciMaxId + 1;
   }
   prima_window_reset_menu( self, y);
   if ( repal) prima_palette_replace( self, false); 
   if ( menu) {
      int i;
      for ( i = 0; i <= ciMaxId; i++) {
         M(menu)-> c[i] = prima_allocate_color( self, 
             prima_map_color( PWindow(self)-> menuColor[i], nil), nil);
      }
   }
   return true;
}
