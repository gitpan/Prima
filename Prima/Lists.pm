##
#  Copyright (c) 1997-2002 The Protein Laboratory, University of Copenhagen
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#  SUCH DAMAGE.
#
#  Created by:
#     Dmitry Karasik <dk@plab.ku.dk> 
#     Anton Berezin  <tobez@tobez.org>
#
#  $Id: Lists.pm,v 1.47 2004/08/19 22:04:57 dk Exp $
package Prima::Lists;

# contains:
#   AbstractListViewer
#   AbstractListBox
#   ListViewer
#   ListBox
#   ProtectedListBox

use Carp;
use Prima::Const;
use Prima::Classes;
use Prima::ScrollBar;
use strict;
use Prima::StdBitmap;
use Prima::IntUtils;
use Cwd;

package ci;

BEGIN {
  eval 'use constant Grid => 1 + MaxId;' unless exists $ci::{Grid};
}

package Prima::AbstractListViewer;
use vars qw(@ISA);
@ISA = qw(Prima::Widget Prima::MouseScroller Prima::GroupScroller);

use Prima::Classes;

{
my %RNT = (
   %{Prima::Widget->notification_types()},
   SelectItem  => nt::Default,
   DrawItem    => nt::Action,
   Stringify   => nt::Action,
   MeasureItem => nt::Action,
);

sub notification_types { return \%RNT; }
}

sub profile_default
{
   my $def = $_[ 0]-> SUPER::profile_default;
   my %prf = (
      autoHeight     => 1,
      autoHScroll    => 1,
      autoVScroll    => 1,
      borderWidth    => 2,
      extendedSelect => 0,
      focusedItem    => -1,
      gridColor      => cl::Black,
      hScroll        => 0,
      integralHeight => 0,
      itemHeight     => $def->{font}->{height},
      itemWidth      => $def->{width} - 2,
      multiSelect    => 0,
      multiColumn    => 0,
      offset         => 0,
      topItem        => 0,
      scaleChildren  => 0,
      selectable     => 1,
      selectedItems  => [],
      vScroll        => 1,
      widgetClass    => wc::ListBox,
   );
   @$def{keys %prf} = values %prf;
   return $def;
}

sub profile_check_in
{
   my ( $self, $p, $default) = @_;
   $self-> SUPER::profile_check_in( $p, $default);
   $p-> { multiSelect}    = 1 if exists $p-> { extendedSelect} && $p-> {extendedSelect};
   $p-> { autoHeight}     = 0 if exists $p-> { itemHeight} && !exists $p->{autoHeight};
   $p-> {autoHScroll} = 0 if exists $p-> {hScroll};
   $p-> {autoVScroll} = 0 if exists $p-> {vScroll};
}

sub init
{
   my $self = shift;
   for ( qw( lastItem topItem focusedItem))
      { $self->{$_} = -1; }
   for ( qw( autoHScroll autoVScroll scrollTransaction gridColor dx dy hScroll vScroll 
             itemWidth offset multiColumn count autoHeight multiSelect extendedSelect borderWidth))
      { $self->{$_} = 0; }
   for ( qw( itemHeight integralHeight))
      { $self->{$_} = 1; }
   $self->{selectedItems} = {};
   my %profile = $self-> SUPER::init(@_);
   $self-> setup_indents;
   $self->{selectedItems} = {} unless $profile{multiSelect};
   for ( qw( autoHScroll autoVScroll gridColor hScroll vScroll offset multiColumn 
             itemHeight autoHeight itemWidth multiSelect extendedSelect integralHeight 
             focusedItem topItem selectedItems borderWidth))
      { $self->$_( $profile{ $_}); }
   $self-> reset;
   $self-> reset_scrolls;
   return %profile;
}


sub draw_items
{
   my ($self, $canvas) = (shift, shift);
   my ( $notifier, @notifyParms) = $self-> get_notify_sub(q(DrawItem));
   $self-> push_event;
   for ( @_) { $notifier->( @notifyParms, $canvas, @$_); }
   $self-> pop_event;
}

sub item2rect
{
   my ( $self, $item, @size) = @_;
   my @a = $self-> get_active_area( 0, @size);

   if ( $self->{multiColumn})
   {
      $item -= $self->{topItem};
      my ($j,$i,$ih,$iw) = (
         $self->{rows} ? int( $item / $self->{rows} - (( $item < 0) ? 1 : 0)) : -1,
         $item % ( $self->{rows} ? $self->{rows} : 1),
         $self->{itemHeight},
         $self->{itemWidth}
      );
      return $a[0] + $j * ( $iw + 1),
             $a[3] - $ih * ( $i + 1),
             $a[0] + $j * ( $iw + 1) + $iw,
             $a[3] - $ih * ( $i + 1) + $ih;
   } else {
      my ($i,$ih) = ( $item - $self->{topItem}, $self->{itemHeight});
      return $a[0], $a[3] - $ih * ( $i + 1), $a[2], $a[3] - $ih * $i;
   }
}

sub on_paint
{
   my ($self,$canvas)   = @_;
   my @size   = $canvas-> size;
   unless ( $self-> enabled) {
      $self-> color( $self-> disabledColor);
      $self-> backColor( $self-> disabledBackColor);
   }
   my ( $bw, $ih, $iw, @a) = (
     $self-> {borderWidth}, $self->{ itemHeight}, $self->{ itemWidth},
     $self-> get_active_area( 1, @size));
   my $i;
   my $j;
   my $locWidth = $a[2] - $a[0] + 1;
   my @invalidRect = $canvas-> clipRect;
   $canvas-> rect3d( 0, 0, $size[0]-1, $size[1]-1, $bw, $self-> dark3DColor, $self-> light3DColor);
   if ( defined $self->{uncover})
   {
      if ( $self->{multiColumn})
      {
         my $xstart = $a[0] + $self->{activeColumns} * ( $iw + 1) - 2;
         $canvas-> clear( $xstart - $iw + 1, $self->{yedge} + $a[1],
            (( $xstart > $a[2]) ? $a[2] : $xstart),
            $self->{yedge} + $self->{uncover} - 1) if $xstart > $a[0];
      } else {
         $canvas-> clear( @a[0..2], $self->{uncover} - 1);
      }
   }
   if ( $self->{multiColumn})
   {
       my $xstart = $a[0] + $self->{activeColumns} * ( $iw + 1);
       if ( $self->{activeColumns} < $self->{columns})
       {
          for ( $i = $self->{activeColumns}; $i < $self->{columns}; $i++)
          {
             $canvas-> clear(
                $xstart, $self->{yedge} + $a[1],
                ( $xstart + $iw - 1 > $a[2]) ? $a[2] : $xstart + $iw - 1,
                $a[3],
             );
             $xstart += $iw + 1;
          }
       }
       $canvas-> clear( @a[0..2], $a[1] + $self->{yedge} - 1)
          if $self->{yedge};
       my $c = $canvas-> color;
       $canvas-> color( $self-> {gridColor});
       for ( $i = 1; $i < $self->{columns}; $i++)
       {
          $canvas-> line( $a[0] + $i * ( $iw + 1) - 1, $a[1],
                          $a[0] + $i * ( $iw + 1) - 1, $a[3]);
       }
       $canvas-> color( $c);
   }
   my $focusedState = $self-> focused ? ( exists $self->{unfocState} ? 0 : 1) : 0;
   $self-> {unfocVeil} = ( $focusedState && $self-> {focusedItem} < 0 && $locWidth > 0) ? 1 : 0;
   my $foci = $self-> {focusedItem};
   if ( $self->{count} > 0 && $locWidth > 0)
   {
      $canvas-> clipRect( @a);
      my @paintArray;
      my $rows = $self->{rows} ? $self->{rows} : 1;
      my $item = $self->{topItem};
      if ( $self->{multiColumn})
      {
         my $rows = $self->{rows} ? $self->{rows} : 1;
         MAIN:for ( $j = 0; $j < $self->{activeColumns}; $j++)
         {
            for ( $i = 0; $i < $rows; $i++)
            {
               last MAIN if $item > $self->{lastItem};
               my @itemRect = (
                   $a[0] + $j * ( $iw + 1),
                   $a[3] - $ih * ( $i + 1) + 1,
                   $a[0] + $j * ( $iw + 1) + $iw,
                   $a[3] - $ih * ( $i + 1) + $ih + 1
               );
               $item++, next if $itemRect[3] < $invalidRect[1] ||
                                $itemRect[1] > $invalidRect[3] ||
                                $itemRect[2] < $invalidRect[0] ||
                                $itemRect[0] > $invalidRect[2];
               my $sel = $self->{multiSelect} ?
               exists $self->{selectedItems}->{$item} :
               (( $self->{focusedItem} == $item) ? 1 : 0);
               my $foc = ( $foci == $item) ? $focusedState : 0;
               $foc = 1 if $item == 0 && $self-> {unfocVeil};
               push( @paintArray, [
                 $item,                                              # item number
                 $itemRect[0], $itemRect[1],
                 $itemRect[2]-1, $itemRect[3]-1,
                 $sel, $foc, # selected and focused state
                 $j                                                   # column
               ]);
               $item++;
            }
         }
      } else {
         for ( $i = 0; $i < $self->{rows} + $self-> {tailVisible}; $i++)
         {
            last if $item > $self->{lastItem};
            my @itemRect = (
               $a[0], $a[3] - $ih * ( $i + 1) + 1,
               $a[2], $a[3] - $ih * $i
            );
            $item++, next if ( $itemRect[3] < $invalidRect[1] || $itemRect[1] > $invalidRect[3]);
            my $sel = $self->{multiSelect} ?
              exists $self->{selectedItems}->{$item} :
              (( $foci == $item) ? 1 : 0);
            my $foc = ( $foci == $item) ? $focusedState : 0;
            $foc = 1 if $item == 0 && $self-> {unfocVeil};
            push( @paintArray, [
               $item,                                               # item number
               $itemRect[0] - $self->{offset}, $itemRect[1],        # logic rect
               $itemRect[2], $itemRect[3],                          #
               $sel, $foc, # selected and focused state
               0 #column
            ]);
            $item++;
         }
      }
      $self-> draw_items( $canvas, @paintArray);
   }
}

sub is_default_selection
{
   return $_[0]-> {unfocVeil};
}

sub on_enable  { $_[0]-> repaint; }
sub on_disable { $_[0]-> repaint; }
sub on_enter   { $_[0]-> redraw_items( $_[0]-> focusedItem); }

sub on_keydown
{
   my ( $self, $code, $key, $mod) = @_;
   return if $mod & km::DeadKey;
   $mod &= ( km::Shift|km::Ctrl|km::Alt);
   $self->notify(q(MouseUp),0,0,0) if defined $self->{mouseTransaction};
   if ( $mod & km::Ctrl && $self->{multiSelect})
   {
      my $c = chr ( $code & 0xFF);
      if ( $c eq '/' || $c eq chr(ord('\\')-ord('@')))
      {
         $self-> selectedItems(( $c eq '/') ? [0..$self->{count}-1] : []);
         $self-> clear_event;
         return;
      }
   }
   return if ( $code & 0xFF) && ( $key == kb::NoKey);

   if ( scalar grep { $key == $_ } (kb::Left,kb::Right,kb::Up,kb::Down,kb::Home,kb::End,kb::PgUp,kb::PgDn))
   {
      my $newItem = $self->{focusedItem};
      my $doSelect = 0;
      if ( $mod == 0 || ( $mod & km::Shift && $self->{ extendedSelect}))
      {
         my $pgStep  = $self->{rows} - 1;
         $pgStep = 1 if $pgStep <= 0;
         my $cols = $self->{multiColumn} ? $self->{columns} - $self->{xTailVisible} : 1;
         my $mc = $self->{multiColumn};
         if ( $key == kb::Up)   { $newItem--; };
         if ( $key == kb::Down) { $newItem++; };
         if ( $key == kb::Left) { $newItem -= $self->{rows} if $self->{multiColumn}};
         if ( $key == kb::Right){ $newItem += $self->{rows} if $self->{multiColumn} };
         if ( $key == kb::Home) { $newItem = $self->{topItem} };
         if ( $key == kb::End)  { $newItem = $mc ?
           $self->{topItem} + $self->{rows} * $cols - 1
           : $self->{topItem} + $pgStep; };
         if ( $key == kb::PgDn) { $newItem += $mc ? $self->{rows} * $cols : $pgStep };
         if ( $key == kb::PgUp) { $newItem -= $mc ? $self->{rows} * $cols : $pgStep};
         $doSelect = $mod & km::Shift;
      }
      if (( $mod & km::Ctrl) ||
         ((( $mod & ( km::Shift|km::Ctrl))==(km::Shift|km::Ctrl)) && $self->{ extendedSelect}))
      {
         if ( $key == kb::PgUp || $key == kb::Home) { $newItem = 0};
         if ( $key == kb::PgDn || $key == kb::End)  { $newItem = $self->{count} - 1};
         $doSelect = $mod & km::Shift;
      }
      if ( $doSelect )
      {
         my ( $a, $b) = ( defined $self->{anchor} ? $self->{anchor} : $self->{focusedItem}, $newItem);
         ( $a, $b) = ( $b, $a) if $a > $b;
         $self-> selectedItems([$a..$b]);
         $self->{anchor} = $self->{focusedItem} unless defined $self->{anchor};
      } else {
         $self-> selectedItems([$self-> focusedItem]) if exists $self->{anchor};
         delete $self->{anchor};
      }
      $self-> offset( $self->{offset} + 5 * (( $key == kb::Left) ? -1 : 1))
         if !$self->{multiColumn} && ($key == kb::Left || $key == kb::Right);
      $self-> focusedItem( $newItem >= 0 ? $newItem : 0);
      $self-> clear_event;
      return;
   } else {
      delete $self->{anchor};
   }

   if ( $mod == 0 && ( $key == kb::Space || $key == kb::Enter))
   {
      $self-> toggle_item( $self->{focusedItem}) if $key == kb::Space &&
          $self->{multiSelect} && !$self->{extendedSelect};
      $self-> clear_event;
      $self-> notify(q(Click)) if $key == kb::Enter && ($self->focusedItem >= 0);
      return;
   }
}

sub on_leave
{
   my $self = $_[0];
   if ( $self->{mouseTransaction})
   {
      $self-> capture(0) if $self->{mouseTransaction};
      $self->{mouseTransaction} = undef;
   }
   $self-> redraw_items( $self-> focusedItem);
}

sub point2item
{
   my ( $self, $x, $y) = @_;
   my ( $ih, $iw, @a) = ( $self-> {itemHeight}, $self->{itemWidth}, $self-> get_active_area);

   if ( $self->{multiColumn})
   {
      my ( $r, $t, $l, $c) = ( $self->{rows}, $self->{topItem}, $self->{lastItem}, $self->{columns});
      $c-- if $self->{multiColumn} && $self->{xTailVisible};
      $x -= $a[0];                          # a[2]???
      $y -= $a[1] + $self->{yedge};
      $x /= $iw + 1;
      $y /= $ih;
      $y = $r - $y;
      $x = int( $x - (( $x < 0) ? 1 : 0));
      $y = int( $y - (( $y < 0) ? 1 : 0));
      return $t - $r                if $y < 0   && $x < 1;
      return $t + $r * $x,  -1      if $y < 0   && $x >= 0 && $x < $c;
      return $t + $r * $c           if $y < 0   && $x >= $c;
      return $l + $y + 1 - (($c && $self->{xTailVisible} && ( $l < $self->{count}-1))?$r:0), $self->{activeColumns} <= $self->{columns} - $self->{xTailVisible} ? 0 :$r
         if $x > $c && $y >= 0 && $y < $r;
      return $t + $y - $r           if $x < 0   && $y >= 0 && $y < $r;
      return $l + $r                if $x >= $c - 1 && $y >= $r;
      return $t + $r * ($x + 1)-1,1 if $y >= $r && $x >= 0 && $x < $c;
      return $t + $r - 1            if $x < 0   && $y >= $r;
      return $x * $r + $y + $t;
   } else {
      return $self->{topItem} - 1 if $y >= $a[3];
      return $self->{lastItem} + !$self->{tailVisible} if $y <= $a[1];
      my $h = $a[3];

      my $i = $self->{topItem};
      while ( $y > 0)
      {
         return $i if $y <= $h && $y > $h - $ih;
         $h -= $ih;
         $i++;
      }
   }
}

sub on_mousedown
{
   my ( $self, $btn, $mod, $x, $y) = @_;
   my $bw = $self-> { borderWidth};
   $self-> clear_event;
   return if $btn != mb::Left;
   my @a = $self-> get_active_area;
   return if defined $self->{mouseTransaction} ||
      $y < $a[1] || $y >= $a[3] ||
      $x < $a[0] || $x >= $a[2];

   my $item = $self-> point2item( $x, $y);
   if (( $self->{multiSelect} && !$self->{extendedSelect}) ||
       ( $self->{extendedSelect} && ( $mod & (km::Ctrl|km::Shift))))
   {
      $self-> toggle_item( $item);
      return if $self->{extendedSelect};
   } else {
      $self-> {anchor} = $item if $self->{extendedSelect};
   }
   $self-> {mouseTransaction} = 1;
   my $foc = $item >= 0 ? $item : 0;
   $self-> selectedItems([$foc]) if $self->{extendedSelect};
   $self-> focusedItem( $foc);
   $self-> capture(1);
}

sub on_mouseclick
{
   my ( $self, $btn, $mod, $x, $y, $dbl) = @_;
   $self-> clear_event;
   return if $btn != mb::Left || !$dbl;
   $self-> notify(q(Click)) if $self-> focusedItem >= 0;
}

sub on_mousemove
{
   my ( $self, $mod, $x, $y) = @_;
   return unless defined $self->{mouseTransaction};
   my $bw = $self-> { borderWidth};
   my ($item, $aux) = $self-> point2item( $x, $y);
   my @a = $self-> get_active_area;
   if ( $y >= $a[3] || $y < $a[1] || $x >= $a[2] || $x < $a[0])
   {
      $self-> scroll_timer_start unless $self-> scroll_timer_active;
      return unless $self->scroll_timer_semaphore;
      $self->scroll_timer_semaphore(0);
   } else {
      $self-> scroll_timer_stop;
   }

   if ( $aux)
   {
      my $top = $self-> {topItem};
      $self-> topItem( $self-> {topItem} + $aux);
      $item += (( $top != $self-> {topItem}) ? $aux : 0);
   }

   if ( $self-> {extendedSelect} && exists $self->{anchor})
   {
       my ( $a, $b, $c) = ( $self->{anchor}, $item, $self->{focusedItem});
       my $globSelect = 0;
       if (( $b <= $a && $c > $a) || ( $b >= $a && $c < $a)) { $globSelect = 1
       } elsif ( $b > $a) {
          if ( $c < $b) { $self-> add_selection([$c + 1..$b], 1) }
          elsif ( $c > $b) { $self-> add_selection([$b + 1..$c], 0) }
          else { $globSelect = 1 }
       } elsif ( $b < $a) {
          if ( $c < $b) { $self-> add_selection([$c..$b], 0) }
          elsif ( $c > $b) { $self-> add_selection([$b..$c], 1) }
          else { $globSelect = 1 }
       } else { $globSelect = 1 }
       if ( $globSelect )
       {
          ( $a, $b) = ( $b, $a) if $a > $b;
          $self-> selectedItems([$a..$b]);
       }
   }
   $self-> focusedItem( $item >= 0 ? $item : 0);
   $self-> offset( $self->{offset} + 5 * (( $x < $a[0]) ? -1 : 1)) if $x >= $a[2] || $x < $a[0];
}

sub on_mouseup
{
   my ( $self, $btn, $mod, $x, $y) = @_;
   return if $btn != mb::Left;
   return unless defined $self->{mouseTransaction};
   delete $self->{mouseTransaction};
   delete $self->{mouseHorizontal};
   delete $self->{anchor};
   $self-> capture(0);
   $self-> clear_event;
}

sub on_mousewheel
{
   my ( $self, $mod, $x, $y, $z) = @_;
   $z = int( $z/120);
   $z *= $self-> {rows} if $mod & km::Ctrl;
   my $newTop = $self-> topItem - $z;
   my $cols = $self->{multiColumn} ? $self->{columns} - $self->{xTailVisible} : 1;
   my $maxTop = $self-> {count} - $self-> {rows} * $cols;
   $self-> topItem( $newTop > $maxTop ? $maxTop : $newTop);
}

sub on_size
{
   my $self = $_[0];
   $self-> offset( $self-> offset) if $self->{multiColumn};
   $self-> reset;
   $self-> reset_scrolls;
}

sub reset
{
   my $self = $_[0];
   my @a    = $self-> indents;
   my @size = $self-> get_active_area( 2);
   my $ih   = $self-> {itemHeight};
   my $iw   = $self-> {itemWidth};
   $self->{rows}  = int( $size[1]/$ih);
   $self->{rows}  = 0 if $self->{rows} < 0;
   $self->{yedge} = $size[1] - $self->{rows} * $ih;
   if ( $self->{multiColumn})
   {
      $self->{tailVisible} = 0;
      $self->{columns}     = 0;
      my $w = 0;
      $self->{lastItem}      = $self->{topItem};
      $self->{activeColumns} = 0;
      my $top = $self->{topItem};
      my $max = $self->{count} - 1;
      $self->{uncover} = undef;
      if ( $self->{rows} == 0)
      {
         $self->{activeColumns}++, $self->{columns}++, $w += $iw + 1 while ( $w < $size[0]);
      } else {
         while ( $w <= $size[0])
         {
             $self->{columns}++;
             if ( $top + $self->{rows} - 1 < $max)
             {
                $self->{activeColumns}++;
                $self->{lastItem} = $top + $self->{rows} - 1;
             } elsif ( $top + $self->{rows} - 1 == $max) {
                $self->{activeColumns}++;
                $self->{lastItem} = $max;
             } elsif ( $top <= $max) {
                $self->{lastItem} = $max;
                $self->{activeColumns}++;
                $self->{uncover} = $ih * ( $self->{rows} - $max + $top - 1) + $a[1];
             }
             $w   += $iw + 1;
             $top += $self->{rows};
         }
      }
      $self->{xTailVisible} = $size[0] + 1 < $self->{columns} * ( $iw + 1);
   } else {
      $self->{columns}     = 1;
      my ($x,$z) = ( $self->{count} - 1, $self->{topItem} + $self->{rows} - 1);
      $self->{lastItem} = $x > $z ? $z : $x;
      $self->{uncover} = ( $self->{count} == 0) ? $size[1] :
                         $size[1] - ( $self->{lastItem} - $self->{topItem} + 1) * $ih;
      $self->{uncover} += $a[1];
      $self->{tailVisible} = 0;
      my $integralHeight = ( $self->{integralHeight} && ( $self-> {rows} > 0)) ? 1 : 0;
      if ( $self->{count} > 0 && $self->{lastItem} < $self->{count}-1 && !$integralHeight && $self->{yedge} > 0)
      {
         $self->{tailVisible} = 1;
         $self->{lastItem}++;
         $self->{uncover} = undef;
      }
      $self->{uncover} = undef if $size[0] <= 0 || $size[1] <= 0;
   }
}

sub reset_scrolls
{
   my $self = $_[0];
   if ( $self-> {scrollTransaction} != 1) {
      $self-> vScroll( $self-> {columns} * $self->{rows} < $self-> {count}) 
         if $self-> {autoVScroll};
      $self-> {vScrollBar}-> set(
         max      => $self-> {count} -  $self->{rows} *
         ( $self-> {multiColumn} ?
           ( $self->{columns} - $self->{xTailVisible}) : 1),
         pageStep => $self-> {rows},
         whole    => $self-> {count},
         partial  => $self-> {columns} * $self->{rows},
         value    => $self-> {topItem},
      ) if $self-> {vScroll};
   }
   if ( $self->{scrollTransaction} != 2) {
      if ( $self->{multiColumn})
      {
         $self-> hScroll( $self-> {columns} * $self->{rows} < $self-> {count}) 
            if $self-> {autoHScroll};
         $self-> {hScrollBar}-> set(
            max      => $self-> {count} - $self->{rows} * ( $self->{columns} - $self->{xTailVisible}),
            step     => $self-> {rows},
            pageStep => $self-> {rows} * $self-> {columns},
            whole    => $self-> {count},
            partial  => $self-> {columns} * $self->{rows},
            value    => $self-> {topItem},
         ) if $self-> {hScroll};
      } else {
         my @sz = $self-> get_active_area( 2);
         my $iw = $self->{itemWidth};
         if ( $self-> {autoHScroll}) {
            my $hs = ( $sz[0] < $iw) ? 1 : 0;
            if ( $hs != $self-> {hScroll}) {
               $self-> hScroll( $hs);
               @sz = $self-> get_active_area( 2);
            }
         }
         $self-> {hScrollBar}-> set(
            max      => $iw - $sz[0],
            whole    => $iw,
            value    => $self-> {offset},
            partial  => $sz[0],
            pageStep => $iw / 5,
         ) if $self-> {hScroll};
      }
   }
}

sub select_all {
   my $self = $_[0];
   $self-> selectedItems([0..$self->{count}-1]);
}

sub deselect_all {
   my $self = $_[0];
   $self-> selectedItems([]);
}

sub set_auto_height
{
   my ( $self, $auto) = @_;
   $self-> itemHeight( $self-> font-> height) if $auto;
   $self->{autoHeight} = $auto;
}

sub set_border_width
{
   my ( $self, $bw) = @_;
   $bw = 0 if $bw < 0;
   $bw = 1 if $bw > $self-> height / 2;
   $bw = 1 if $bw > $self-> width  / 2;
   return if $bw == $self-> {borderWidth};
   $self-> SUPER::set_border_width( $bw);
   $self-> reset;
   $self-> reset_scrolls;
   $self-> repaint;
}


sub set_count
{
   my ( $self, $count) = @_;
   $count = 0 if $count < 0;
   my $oldCount = $self->{count};
   $self-> { count} = $count;
   my $doFoc = undef;
   if ( $oldCount > $count)
   {
      for ( keys %{$self->{selectedItems}})
      {
         delete $self->{selectedItems}->{$_} if $_ >= $count;
      }
   }
   $self-> reset;
   $self-> reset_scrolls;
   $self-> focusedItem( -1) if $self->{focusedItem} >= $count;
   $self-> repaint;
}

sub set_extended_select
{
   my ( $self, $esel) = @_;
   if ( $self-> {extendedSelect} = $esel)
   {
      $self-> multiSelect( 1);
      $self-> selectedItems([$self-> {focusedItem}]);
   }
}

sub set_focused_item
{
   my ( $self, $foc) = @_;
   my $oldFoc = $self->{focusedItem};
   $foc = $self->{count} - 1 if $foc >= $self->{count};
   $foc = -1 if $foc < -1;
   return if $self->{focusedItem} == $foc;
   return if $foc < -1;
   $self->{focusedItem} = $foc;
   $self-> selectedItems([$foc]) if $self->{extendedSelect} && ! exists $self->{anchor};
   $self-> notify(q(SelectItem), [ $foc], 1) if $foc >= 0 && !exists $self-> {selectedItems}-> {$foc};
   my $topSet = undef;
   if ( $foc >= 0)
   {
      my $rows = $self->{rows} ? $self->{rows} : 1;
      my $mc   = $self->{multiColumn};
      my $cols = $mc ? $self->{columns} - $self->{xTailVisible} : 1;
      $cols++ unless $cols;
      if ( $foc < $self->{topItem}) {
         $topSet = $mc ? $foc - $foc % $rows : $foc;
      } elsif ( $foc >= $self->{topItem} + $rows * $cols) {
         $topSet = $mc ? $foc - $foc % $rows - $rows * ( $cols - 1) : $foc - $rows + 1;
      }
   }
   $oldFoc = 0 if $oldFoc < 0;
   $self-> redraw_items( $foc, $oldFoc);
   $self-> topItem( $topSet) if defined $topSet;
}

sub colorIndex
{
   my ( $self, $index, $color) = @_;
   return ( $index == ci::Grid) ?
      $self-> {gridColor} : $self-> SUPER::colorIndex( $index)
        if $#_ < 2;
   ( $index == ci::Grid) ?
      ( $self-> gridColor( $color), $self-> notify(q(ColorChanged), ci::Grid)) :
      ( $self-> SUPER::colorIndex( $index, $color));
}

sub set_grid_color
{
   my ( $self, $gc) = @_;
   return if $gc == $self->{gridColor};
   $self->{gridColor} = $gc;
   $self-> repaint;
}


sub set_integral_height
{
  my ( $self, $ih) = @_;
  return if $self->{multiColumn} || $self->{ integralHeight} == $ih;
  $self->{ integralHeight} = $ih;
  $self-> reset;
  $self-> reset_scrolls;
  $self-> repaint;
}

sub set_item_height
{
   my ( $self, $ih) = @_;
   $ih = 1 if $ih < 1;
   $self-> autoHeight(0);
   return if $ih == $self->{itemHeight};
   $self->{itemHeight} = $ih;
   $self->reset;
   $self-> reset_scrolls;
   $self->repaint;
}

sub set_item_width
{
   my ( $self, $iw) = @_;
   $iw = 1 if $iw < 1;
   return if $iw == $self->{itemWidth};
   $self->{itemWidth} = $iw;
   $self->reset;
   $self->reset_scrolls;
   $self->repaint;
}

sub set_multi_column
{
   my ( $self, $mc) = @_;
   return if $mc == $self->{multiColumn};
   $self-> offset(0) if $self->{multiColumn} = $mc;
   $self-> reset;
   $self-> reset_scrolls;
   $self-> repaint;
}

sub set_multi_select
{
   my ( $self, $ms) = @_;
   return if $ms == $self->{multiSelect};
   unless ( $self-> {multiSelect} = $ms)
   {
      $self-> extendedSelect( 0);
      $self-> selectedItems([]);
      $self-> repaint;
   } else {
      $self-> selectedItems([$self-> focusedItem]);
   }
}

sub set_offset
{
   my ( $self, $offset) = @_;
   $self->{offset} = 0, return if $self->{multiColumn};
   my @sz = $self-> size;
   my ( $iw, @a) = ( $self->{itemWidth}, $self-> get_active_area( 0, @sz));
   my $lc = $a[2] - $a[0];
   if ( $iw > $lc) {
      $offset = $iw - $lc if $offset > $iw - $lc;
      $offset = 0 if $offset < 0;
   } else {
      $offset = 0;
   }
   return if $self->{offset} == $offset;
   my $oldOfs = $self->{offset};
   $self-> {offset} = $offset;
   my $dt = $offset - $oldOfs;
   $self-> reset;
   if ( $self->{hScroll} && !$self->{multiColumn} && $self->{scrollTransaction} != 2) {
      $self->{scrollTransaction} = 2;
      $self-> {hScrollBar}-> value( $offset);
      $self->{scrollTransaction} = 0;
   }
   $self-> scroll( -$dt, 0,
                     clipRect => \@a);
   if ( $self-> focused) {
      my $focId = ( $self-> {focusedItem} >= 0) ? $self-> {focusedItem} : 0;
      $self-> invalidate_rect( $self-> item2rect( $focId, @sz));
   }
}

sub redraw_items
{
   my $self = shift;
   my @sz = $self-> size;
   $self-> invalidate_rect( $self-> item2rect( $_, @sz)) for @_;
}

sub set_selected_items
{
   my ( $self, $items) = @_;
   return if !$self->{ multiSelect} && ( scalar @{$items} > 0);
   my $ptr = $::application-> pointer;
   $::application-> pointer( cr::Wait)
      if scalar @{$items} > 500;
   my $sc = $self->{count};
   my %newItems;
   for (@{$items}) { $newItems{$_}=1 if $_>=0 && $_<$sc; }
   my @stateChangers; # $#stateChangers = scalar @{$items};
   my $k;
   while (defined($k = each %{$self->{selectedItems}})) {
      next if exists $newItems{$k};
      push( @stateChangers, $k);
   };
   my @indices;
   my $sel = $self->{selectedItems};
   $self->{selectedItems} = \%newItems;
   $self-> notify(q(SelectItem), [@stateChangers], 0) if scalar @stateChangers;
   while (defined($k = each %newItems)) {
      next if exists $sel->{$k};
      push( @stateChangers, $k);
      push( @indices, $k);
   };
   $self-> notify(q(SelectItem), [@indices], 1) if scalar @indices;
   $::application-> pointer( $ptr);
   return unless scalar @stateChangers;
   $self-> redraw_items( @stateChangers);
}

sub get_selected_items
{
    return $_[0]->{multiSelect} ?
       [ sort { $a<=>$b } keys %{$_[0]->{selectedItems}}] :
       (
         ( $_[0]->{focusedItem} < 0) ? [] : [$_[0]->{focusedItem}]
       );
}

sub get_selected_count
{
   return scalar keys %{$_[0]->{selectedItems}};
}

sub is_selected
{
   return exists($_[0]->{selectedItems}->{$_[1]}) ? 1 : 0;
}

sub set_item_selected
{
   my ( $self, $index, $sel) = @_;
   return unless $self->{multiSelect};
   return if $index < 0 || $index >= $self->{count};
   return if $sel == exists $self->{selectedItems}->{$index};
   $sel ? $self->{selectedItems}->{$index} = 1 : delete $self->{selectedItems}->{$index};
   $self-> notify(q(SelectItem), [ $index], $sel);
   $self-> invalidate_rect( $self-> item2rect( $index));
}

sub select_item   {  $_[0]-> set_item_selected( $_[1], 1); }
sub unselect_item {  $_[0]-> set_item_selected( $_[1], 0); }
sub toggle_item   {  $_[0]-> set_item_selected( $_[1], $_[0]-> is_selected( $_[1]) ? 0 : 1)}

sub add_selection
{
   my ( $self, $items, $sel) = @_;
   return unless $self->{multiSelect};
   my @notifiers;
   my $count = $self->{count};
   my @sz = $self-> size;
   for ( @{$items})
   {
      next if $_ < 0 || $_ >= $count;
      next if exists $self->{selectedItems}->{$_} == $sel;
      $sel ? $self->{selectedItems}->{$_} = 1 : delete $self->{selectedItems}->{$_};
      push ( @notifiers, $_);
      $self-> invalidate_rect( $self-> item2rect( $_, @sz));
   }
   return unless scalar @notifiers;
   $self-> notify(q(SelectItem), [ @notifiers], $sel) if scalar @notifiers;
}

sub set_top_item
{
   my ( $self, $topItem) = @_;
   $topItem = 0 if $topItem < 0;   # first validation
   $topItem = $self-> {count} - 1 if $topItem >= $self-> {count};
   $topItem = 0 if $topItem < 0;   # count = 0 case
   return if $topItem == $self->{topItem};
   my $oldTop = $self->{topItem};
   $self->{topItem} = $topItem;
   my ( $ih, $iw, @a) = ( $self->{itemHeight}, $self->{itemWidth}, $self-> get_active_area);
   my $dt = $topItem - $oldTop;
   $self-> reset;
   if ( $self->{scrollTransaction} != 1 && $self->{vScroll}) {
      $self->{scrollTransaction} = 1;
      $self-> {vScrollBar}-> value( $topItem);
      $self->{scrollTransaction} = 0;
   }

   if ( $self->{scrollTransaction} != 2 && $self->{hScroll} && $self->{multiColumn}) {
      $self->{scrollTransaction} = 2;
      $self-> {hScrollBar}-> value( $topItem);
      $self->{scrollTransaction} = 0;
   }

   if ( $self->{ multiColumn}) {
      if (( $self->{rows} != 0) && ( $dt % $self->{rows} == 0)) {
         $self-> scroll( -( $dt / $self->{rows}) * ($iw + 1), 0,
                         clipRect => \@a);
      } else {
         $a[1] += $self->{yedge};
         $self-> scroll( 0, $ih * $dt,
                         clipRect => \@a);

      }
   } else {
      $a[1] += $self-> {yedge} if $self-> {integralHeight};
      $self-> scroll( 0, $dt * $ih,
                      clipRect => \@a);
   }
   $self-> update_view;
}


sub VScroll_Change
{
   my ( $self, $scr) = @_;
   return if $self-> {scrollTransaction};
   $self-> {scrollTransaction} = 1;
   $self-> topItem( $scr-> value);
   $self-> {scrollTransaction} = 0;
}

sub HScroll_Change
{
   my ( $self, $scr) = @_;
   return if $self-> {scrollTransaction};
   $self-> {scrollTransaction} = 2;
   $self-> {multiColumn} ?
      $self-> topItem( $scr-> value) :
      $self-> offset( $scr-> value);
   $self-> {scrollTransaction} = 0;
}


sub set_h_scroll
{
   my ( $self, $hs) = @_;
   return if $hs == $self->{hScroll};
   $self-> SUPER::set_h_scroll( $hs);
   $self-> reset;
   $self-> reset_scrolls;
   $self-> repaint;
}

sub set_v_scroll
{
   my ( $self, $vs) = @_;
   return if $vs == $self->{vScroll};
   $self-> SUPER::set_v_scroll( $vs);
   $self-> reset;
   $self-> reset_scrolls;
   $self-> repaint;
}


#sub on_drawitem
#{
#   my ($self, $canvas, $itemIndex, $x, $y, $x2, $y2, $selected, $focused) = @_;
#}

#sub on_selectitem
#{
#   my ($self, $itemIndex, $selectState) = @_;
#}

sub autoHeight    {($#_)?$_[0]->set_auto_height    ($_[1]):return $_[0]->{autoHeight}     }
sub count         {($#_)?$_[0]->set_count          ($_[1]):return $_[0]->{count}          }
sub extendedSelect{($#_)?$_[0]->set_extended_select($_[1]):return $_[0]->{extendedSelect} }
sub gridColor     {($#_)?$_[0]->set_grid_color     ($_[1]):return $_[0]->{gridColor}      }
sub focusedItem   {($#_)?$_[0]->set_focused_item   ($_[1]):return $_[0]->{focusedItem}    }
sub integralHeight{($#_)?$_[0]->set_integral_height($_[1]):return $_[0]->{integralHeight} }
sub itemHeight    {($#_)?$_[0]->set_item_height    ($_[1]):return $_[0]->{itemHeight}     }
sub itemWidth     {($#_)?$_[0]->set_item_width     ($_[1]):return $_[0]->{itemWidth}      }
sub multiSelect   {($#_)?$_[0]->set_multi_select   ($_[1]):return $_[0]->{multiSelect}    }
sub multiColumn   {($#_)?$_[0]->set_multi_column   ($_[1]):return $_[0]->{multiColumn}    }
sub offset        {($#_)?$_[0]->set_offset         ($_[1]):return $_[0]->{offset}         }
sub selectedCount {($#_)?$_[0]->raise_ro("selectedCount") :return $_[0]->get_selected_count;}
sub selectedItems {($#_)?shift->set_selected_items    (@_):return $_[0]->get_selected_items;}
sub topItem       {($#_)?$_[0]->set_top_item       ($_[1]):return $_[0]->{topItem}        }

# section for item text representation 

sub get_item_text
{
   my ( $self, $index) = @_;
   my $txt = '';
   $self-> notify(q(Stringify), $index, \$txt);
   return $txt;
}

sub get_item_width
{
   my ( $self, $index) = @_;
   my $w = 0;
   $self-> notify(q(MeasureItem), $index, \$w);
   return $w;
}

sub on_stringify
{
   my ( $self, $index, $sref) = @_;
   $$sref = '';
}


sub on_measureitem
{
   my ( $self, $index, $sref) = @_;
   $$sref = 0;
}

sub draw_text_items
{
   my ( $self, $canvas, $first, $last, $x, $y, $textShift, $clipRect) = @_;
   my $i;
   for ( $i = $first; $i <= $last; $i++)
   {
       next if $self-> get_item_width( $i) + 
               $self->{offset} + $x + 1 < $clipRect->[0];
       $canvas-> text_out( $self-> get_item_text( $i), 
          $x, $y + $textShift - ($i-$first+1) * $self->{itemHeight} + 1);
   }
}

sub std_draw_text_items
{
   my ($self,$canvas) = (shift,shift);
   my @clrs = (
      $self-> color,
      $self-> backColor,
      $self-> colorIndex( ci::HiliteText),
      $self-> colorIndex( ci::Hilite)
   );
   my @clipRect = $canvas-> clipRect;
   my $i;
   my $drawVeilFoc = -1;
   my $atY    = ( $self-> {itemHeight} - $canvas-> font-> height) / 2;
   my $ih     = $self->{itemHeight};
   my $offset = $self->{offset};

   my @colContainer;
   for ( $i = 0; $i < $self->{columns}; $i++){ push ( @colContainer, [])};
   for ( $i = 0; $i < scalar @_; $i++) {
      push ( @{$colContainer[ $_[$i]->[7]]}, $_[$i]);
      $drawVeilFoc = $i if $_[$i]->[6];
   }
   my ( $lc, $lbc) = @clrs[0,1];
   for ( @colContainer)
   {
      my @normals;
      my @selected;
      my ( $lastNormal, $lastSelected) = (undef, undef);
      my $isSelected = 0;
      # sorting items in single column
      { $_ = [ sort { $$a[0]<=>$$b[0] } @$_]; }
      # calculating conjoint bars
      for ( $i = 0; $i < scalar @$_; $i++)
      {
         my ( $itemIndex, $x, $y, $x2, $y2, $selected, $focusedItem) = @{$$_[$i]};
         if ( $selected)
         {
            if ( defined $lastSelected && ( $y2 + 1 == $lastSelected) &&
               ( ${$selected[-1]}[3] - $lastSelected < 100))
            {
               ${$selected[-1]}[1] = $y;
               ${$selected[-1]}[5] = $$_[$i]->[0];
            } else {
               push ( @selected, [ $x, $y, $x2, $y2, $$_[$i]->[0], $$_[$i]->[0], 1]);
            }
            $lastSelected = $y;
            $isSelected = 1;
         } else {
            if ( defined $lastNormal && ( $y2 + 1 == $lastNormal) &&
               ( ${$normals[-1]}[3] - $lastNormal < 100))
            {
               ${$normals[-1]}[1] = $y;
               ${$normals[-1]}[5] = $$_[$i]->[0];
            } else {
               push ( @normals, [ $x, $y, $x2, $y2, $$_[$i]->[0], $$_[$i]->[0], 0]);
            }
            $lastNormal = $y;
         }
      }
      for ( @selected) { push ( @normals, $_); }
      # draw items

      for ( @normals)
      {
         my ( $x, $y, $x2, $y2, $first, $last, $selected) = @$_;
         my $c = $clrs[ $selected ? 3 : 1];
         if ( $c != $lbc) {
            $canvas-> backColor( $c);
            $lbc = $c;
         }
         $canvas-> clear( $x, $y, $x2, $y2);

         $c = $clrs[ $selected ? 2 : 0];
         if ( $c != $lc) {
            $canvas-> color( $c);
            $lc = $c;
         }
        
         $self-> draw_text_items( $canvas, $first, $last, 
              $x, $y2, $atY, \@clipRect);
      }
   }
   # draw veil
   if ( $drawVeilFoc >= 0)
   {
      my ( $itemIndex, $x, $y, $x2, $y2) = @{$_[$drawVeilFoc]};
      $canvas-> rect_focus( $x + $self->{offset}, $y, $x2, $y2);
   }
}

package Prima::AbstractListBox;
use vars qw(@ISA);
@ISA = qw(Prima::AbstractListViewer);

sub draw_items
{
   shift-> std_draw_text_items(@_);
}

sub on_measureitem
{
   my ( $self, $index, $sref) = @_;
   $$sref = $self-> get_text_width( $self-> get_item_text( $index));
}

package Prima::ListViewer;
use vars qw(@ISA);
@ISA = qw(Prima::AbstractListViewer);

sub profile_default
{
   my $def = $_[ 0]-> SUPER::profile_default;
   my %prf = (
       items         => [],
       autoWidth     => 1,
   );
   @$def{keys %prf} = values %prf;
   return $def;
}

sub init
{
   my $self = shift;
   $self->{items}      = [];
   $self->{widths}     = [];
   $self->{maxWidth}   = 0;
   $self->{autoWidth}  = 0;
   my %profile = $self-> SUPER::init(@_);
   $self->autoWidth( $profile{autoWidth});
   $self->items    ( $profile{items});
   $self->focusedItem  ( $profile{focusedItem});
   return %profile;
}


sub calibrate
{
   my $self = $_[0];
   $self-> recalc_widths;
   $self-> itemWidth( $self-> {maxWidth}) if $self->{autoWidth};
   $self-> offset( $self-> offset);
}

sub get_item_width
{
   return $_[0]->{widths}->[$_[1]];
}

sub on_fontchanged
{
   my $self = $_[0];
   $self-> itemHeight( $self-> font-> height), $self->{autoHeight} = 1 if $self-> { autoHeight};
   $self-> calibrate;
}

sub recalc_widths
{
   my $self = $_[0];
   my @w;
   my $maxWidth = 0;
   my $i;
   my ( $notifier, @notifyParms) = $self-> get_notify_sub(q(MeasureItem));
   $self-> push_event;
   $self-> begin_paint_info;
   for ( $i = 0; $i < scalar @{$self->{items}}; $i++)
   {
      my $iw = 0;
      $notifier->( @notifyParms, $i, \$iw);
      $maxWidth = $iw if $maxWidth < $iw;
      push ( @w, $iw);
   }
   $self-> end_paint_info;
   $self-> pop_event;
   $self->{widths}    = [@w];
   $self-> {maxWidth} = $maxWidth;
}

sub set_items
{
   my ( $self, $items) = @_;
   return unless ref $items eq q(ARRAY);
   my $oldCount = $self-> {count};
   $self->{items} = [@{$items}];
   $self-> recalc_widths;
   $self-> reset;
   scalar @$items == $oldCount ? $self->repaint : $self-> SUPER::count( scalar @$items);
   $self-> itemWidth( $self-> {maxWidth}) if $self->{autoWidth};
   $self-> offset( $self-> offset);
   $self-> selectedItems([]);
}

sub get_items
{
   my $self = shift;
   my @inds = (@_ == 1 and ref($_[0]) eq q(ARRAY)) ? @{$_[0]} : @_;
   my ($c,$i) = ($self->{count}, $self->{items});
   for ( @inds) { $_ = ( $_ >= 0 && $_ < $c) ? $i->[$_] : undef; }
   return wantarray ? @inds : $inds[0];
}

sub insert_items
{
   my ( $self, $where) = ( shift, shift);
   $where = $self-> {count} if $where < 0;
   my ( $is, $iw, $mw) = ( $self-> {items}, $self-> {widths}, $self->{maxWidth});
   if (@_ == 1 and ref($_[0]) eq q(ARRAY)) {
      return unless scalar @{$_[0]};
      $self->{items} = [@{$_[0]}];
   } else {
      return unless scalar @_;
      $self->{items} = [@_];
   }
   $self->{widths} = [];
   my $num = scalar @{$self->{items}};
   $self-> recalc_widths;
   splice( @{$is}, $where, 0, @{$self->{items}});
   splice( @{$iw}, $where, 0, @{$self->{widths}});
   ( $self->{items}, $self->{widths}) = ( $is, $iw);
   $self-> itemWidth( $self->{maxWidth} = $mw)
     if $self->{autoWidth} && $self->{maxWidth} < $mw;
   $self-> SUPER::count( scalar @{$self->{items}});
   $self-> itemWidth( $self-> {maxWidth}) if $self->{autoWidth};
   $self-> focusedItem( $self->{focusedItem} + $num)
      if $self->{focusedItem} >= 0 && $self->{focusedItem} >= $where;
   $self-> offset( $self-> offset);

   my @shifters;
   for ( keys %{$self->{selectedItems}})
   {
       next if $_ < $where;
       push ( @shifters, $_);
   }
   for ( @shifters) { delete $self->{selectedItems}->{$_};     }
   for ( @shifters) { $self->{selectedItems}->{$_ + $num} = 1; }
   $self-> repaint if scalar @shifters;
}

sub replace_items
{
   my ( $self, $where) = ( shift, shift);
   return if $where < 0;
   my ( $is, $iw) = ( $self-> {items}, $self-> {widths});
   my $new;
   if (@_ == 1 and ref($_[0]) eq q(ARRAY)) {
      return unless scalar @{$_[0]};
      $new = [@{$_[0]}];
   } else {
      return unless scalar @_;
      $new = [@_];
   }
   my $num = scalar @$new;
   if ( $num + $where >= $self-> {count}) {
      $num = $self->{count} - $where;
      return if $num <= 0;
      splice @$new, $num;
   }
   $self->{items} = $new;
   $self->{widths} = [];
   $self-> recalc_widths;
   splice( @{$is}, $where, $num, @{$self->{items}});
   splice( @{$iw}, $where, $num, @{$self->{widths}});
   ( $self->{items}, $self->{widths}) = ( $is, $iw);
   if ( $self->{autoWidth}) {
      my $mw = 0;
      for (@{$iw}) {
	 $mw = $_ if $mw < $_;
      }
      $self-> itemWidth( $self->{maxWidth} = $mw);
      $self-> offset( $self-> offset);
   }
   if ( $where <= $self-> {lastItem} && $where + $num >= $self-> {topItem}) {
      $self-> redraw_items( $where .. $where + $num);
   }
}

sub add_items { shift-> insert_items( -1, @_); }

sub delete_items
{
   my $self = shift;
   my ( $is, $iw, $mw) = ( $self-> {items}, $self-> {widths}, $self->{maxWidth});
   my %indices;
   if (@_ == 1 and ref($_[0]) eq q(ARRAY)) {
      return unless scalar @{$_[0]};
      %indices = map{$_=>1}@{$_[0]};
   } else {
      return unless scalar @_;
      %indices = map{$_=>1}@_;
   }
   my @removed;
   my $wantarray = wantarray;
   my @newItems;
   my @newWidths;
   my $i;
   my $num = scalar keys %indices;
   my ( $items, $widths) = ( $self->{items}, $self-> {widths});
   $self-> focusedItem( -1) if exists $indices{$self->{focusedItem}};
   for ( $i = 0; $i < scalar @{$self->{items}}; $i++)
   {
      unless ( exists $indices{$i})
      {
         push ( @newItems,  $$items[$i]);
         push ( @newWidths, $$widths[$i]);
      } else {
         push ( @removed, $$items[$i]) if $wantarray;
      }
   }
   my $newFoc = $self->{focusedItem};
   for ( keys %indices) { $newFoc-- if $newFoc >= 0 && $_ < $newFoc; }

   my @selected = sort {$a<=>$b} keys %{$self->{selectedItems}};
   $i = 0;
   my $dec = 0;
   my $d;
   for $d ( sort {$a<=>$b} keys %indices)
   {
      while ($i < scalar(@selected) and $d > $selected[$i]) { $selected[$i] -= $dec; $i++; }
      last if $i >= scalar @selected;
      $selected[$i++] = -1 if $d == $selected[$i];
      $dec++;
   }
   while ($i < scalar(@selected)) { $selected[$i] -= $dec; $i++; }
   $self->{selectedItems} = {};
   for ( @selected) {$self->{selectedItems}->{$_} = 1;}
   delete $self->{selectedItems}->{-1};

   ( $self->{items}, $self-> {widths}) = ([@newItems], [@newWidths]);
   my $maxWidth = 0;
   for ( @newWidths) { $maxWidth = $_ if $maxWidth < $_; }
   $self-> lock;
   $self-> itemWidth( $self->{maxWidth} = $maxWidth)
     if $self->{autoWidth} && $self->{maxWidth} > $maxWidth;
   $self-> SUPER::count( scalar @{$self->{items}});
   $self-> focusedItem( $newFoc);
   $self-> unlock;
   return @removed if $wantarray;
}

sub on_keydown
{
   my ( $self, $code, $key, $mod) = @_;
   $self->notify(q(MouseUp),0,0,0) if defined $self->{mouseTransaction};
   return if $mod & km::DeadKey;
   if ((( $code & 0xFF) >= ord(' ')) && ( $key == kb::NoKey) && !($mod & ~km::Shift) && $self->{count})
   {
      my $i;
      my ( $c, $hit, $items) = ( lc chr ( $code & 0xFF), undef, $self->{items});
      for ( $i = $self->{focusedItem} + 1; $i < $self->{count}; $i++)
      {
         my $fc = substr( $self-> get_item_text($i), 0, 1);
         next unless defined $fc;
         $hit = $i, last if lc $fc eq $c;
      }
      unless ( defined $hit) {
         for ( $i = 0; $i < $self->{focusedItem}; $i++)
         {
            my $fc = substr( $self-> get_item_text($i), 0, 1);
            next unless defined $fc;
            $hit = $i, last if lc $fc eq $c;
         }
      }
      if ( defined $hit)
      {
         $self-> focusedItem( $hit);
         $self-> clear_event;
         return;
      }
   }
   $self-> SUPER::on_keydown( $code, $key, $mod);
}

sub autoWidth     {($#_)?$_[0]->{autoWidth} = $_[1]       :return $_[0]->{autoWidth}      }
sub count         {($#_)?$_[0]->raise_ro('count')         :return $_[0]->{count}          }
sub items         {($#_)?$_[0]->set_items( $_[1])         :return $_[0]->{items}          }

package Prima::ProtectedListBox;
use vars qw(@ISA);
@ISA = qw(Prima::ListViewer);

BEGIN {
   for ( qw(font color backColor rop rop2 linePattern lineWidth lineEnd textOutBaseline fillPattern clipRect))
   {
      my $sb = $_;
      $sb =~ s/([A-Z]+)/"_\L$1"/eg;
      $sb = "set_$sb";
      eval <<PROC;
      sub $sb
      {
         my \$self = shift;
         \$self->SUPER::$sb(\@_);
         \$self->{protect}->{$_} = 1 if exists \$self->{protect};
      }
PROC
   }
}

sub draw_items
{
   my ( $self, $canvas, @items) = @_;
   return if $canvas != $self;   # this does not support 'uncertain' drawings due that
   my %protect;                  # it's impossible to override $canvas's methods dynamically
   for ( qw(font color backColor rop rop2 linePattern lineWidth lineEnd textOutBaseline fillPattern))
        { $protect{$_} = $canvas-> $_(); }
   my @clipRect = $canvas-> clipRect;
   $self->{protect} = {};

   my ( $notifier, @notifyParms) = $self-> get_notify_sub(q(DrawItem));
   $self-> push_event;
   for ( @items)
   {
      $notifier->( @notifyParms, $canvas, @$_);

      $canvas-> clipRect( @clipRect), delete $self->{protect}->{clipRect}
         if exists $self->{protect}->{clipRect};
      for ( keys %{$self->{protect}}) { $self->$_($protect{$_}); }
      $self->{protect} = {};
   }
   $self-> pop_event;
   delete $self->{protect};
}

package Prima::ListBox;
use vars qw(@ISA);
@ISA = qw(Prima::ListViewer);

sub get_item_text  { return $_[0]->{items}->[$_[1]]; }

sub on_stringify
{
   my ( $self, $index, $sref) = @_;
   $$sref = $self->{items}->[$index];
}

sub on_measureitem
{
   my ( $self, $index, $sref) = @_;
   $$sref = $self-> get_text_width( $self->{items}->[$index]);
}

sub draw_items
{
   shift-> std_draw_text_items(@_)
}

1;

__DATA__

=pod

=head1 NAME

Prima::Lists - user-selectable item list widgets

=head1 DESCRIPTION

The module provides classes for several abstraction layers
of item representation. The hierarchy of classes is as follows:

  AbstractListViewer
     AbstractListBox
     ListViewer
        ProtectedListBox
        ListBox

The root class, C<Prima::AbstractListViewer>, provides common
interface, while by itself it is not directly usable.
The main differences between classes
are centered around the way the item list is stored. The simplest
organization of a text-only item list, provided by C<Prima::ListBox>,
stores an array of text scalars in a widget. More elaborated storage
and representation types are not realized, and the programmer is urged
to use the more abstract classes to derive own mechanisms. 
For example, for a list of items that contain text strings and icons
see L<Prima::FileDialog/"Prima::DirectoryListBox">.
To organize an item storage, different from C<Prima::ListBox>, it is
usually enough to overload either the C<Stringify>, C<MeasureItem>, 
and C<DrawItem> events, or their method counterparts: C<get_item_text>,
C<get_item_width>, and C<draw_items>.

=head1 Prima::AbstractListViewer

C<Prima::AbstractListViewer> is a descendant of C<Prima::GroupScroller>,
and some properties are not described here. See L<Prima::IntUtils/"Prima::GroupScroller">.

The class provides interface to generic list browsing functionality,
plus functionality for text-oriented lists. The class is not usable directly.

=head2 Properties

=over

=item autoHeight BOOLEAN

If 1, the item height is changed automatically
when the widget font is changed; this is useful for text items. 
If 0, item height is not changed; this is useful for non-text items.

Default value: 1

=item count INTEGER

An integer property, destined to reflect number of items in the list.
Since it is tied to the item storage organization, and hence,
to possibility of changing the number of items, this property
is often declared as read-only in descendants of C<Prima::AbstractListViewer>.

=item extendedSelect BOOLEAN

Regards the way the user selects multiple items and is only actual
when C<multiSelect> is 1. If 0, the user must click each item
in order to mark as selected. If 1, the user can drag mouse
or use C<Shift> key plus arrow keys to perform range selection.

Default value: 0

=item focusedItem INDEX

Selects the focused item index. If -1, no item is focused.
It is mostly a run-time property, however, it can be set
during the widget creation stage given that the item list is 
accessible on this stage as well.

Default value: -1

=item gridColor COLOR

Color, used for drawing vertical divider lines for multi-column 
list widgets. The list classes support also the indirect way
of setting the grid color, as well as widget does, via
the C<colorIndex> property. To achieve this, C<ci::Grid> constant
is declared ( for more detail see L<Prima::Widget/colorIndex> ).

Default value: C<cl::Black>.

=item integralHeight BOOLEAN

If 1, only the items that fit vertically in the widget interiors
are drawn. If 0, the items that are partially visible are drawn also.

Default value: 0

=item itemHeight INTEGER

Selects the height of the items in pixels. Since the list classes do 
not support items with different dimensions, changes to this property 
affect all items.

Default value: default font height

=item itemWidth INTEGER

Selects the width of the items in pixels. Since the list classes do 
not support items with different dimensions, changes to this property 
affect all items.
 
Default value: default widget width

=item multiSelect BOOLEAN

If 0, the user can only select one item, and it is reported by
the C<focusedItem> property. If 1, the user can select more than one item. 
In this case, C<focusedItem>'th item is not necessarily selected.
To access selected item list, use C<selectedItems> property.

Default value: 0

=item multiColumn BOOLEAN

If 0, the items are arrayed vertically in one column, and the main scroll bar 
is vertical. If 1, the items are arrayed in several columns, C<itemWidth>
pixels wide each. In this case, the main scroll bar is horizontal.

=item offset INTEGER

Horizontal offset of an item list in pixels.

=item topItem INTEGER

Selects the first item drawn.

=item selectedCount INTEGER

A read-only property. Returns number of selected items.

=item selectedItems ARRAY

ARRAY is an array of integer indices of selected items.

=back

=head2 Methods

=over

=item add_selection ARRAY, FLAG

Sets item indices from ARRAY in selected
or deselected state, depending on FLAG value, correspondingly 1 or 0.

Only for multi-select mode.

=item deselect_all

Removes selection from all items.

Only for mult-select mode.

=item draw_items CANVAS, ITEMS

Called from within C<Paint> notification to draw
items. The default behavior is to call C<DrawItem>
notification for every item in ITEMS array. ITEMS
is an array or arrays, where each array consists
of parameters, passed to C<DrawItem> notification.

This method is overridden in some descendant classes,
to increase the speed of drawing routine. For example,
C<std_draw_text_items> is the optimized routine for
drawing unified text-based items. It is used in 
C<Prima::ListBox> class.

See L<DrawItem> for parameters description.

=item draw_text_items CANVAS, FIRST, LAST, X, Y, OFFSET, CLIP_RECT

Called by C<std_draw_text_items> to draw sequence of text items with 
indices from FIRST to LAST on CANVAS, starting at point X, Y, and
incrementing the vertical position with OFFSET. CLIP_RECT is a reference
to array of four integers with inclusive-inclusive coordinates of the active 
clipping rectangle.

=item get_item_text INDEX

Returns text string assigned to INDEXth item.
Since the class does not assume the item storage organization,
the text is queried via C<Stringify> notification.

=item get_item_width INDEX

Returns width in pixels of INDEXth item.
Since the class does not assume the item storage organization,
the value is queried via C<MeasureItem> notification.

=item is_selected INDEX

Returns 1 if INDEXth item is selected, 0 if it is not.

=item item2rect INDEX, [ WIDTH, HEIGHT ]

Calculates and returns four integers with rectangle coordinates
of INDEXth item within the widget. WIDTH and HEIGHT are optional
parameters with pre-fetched dimension of the widget; if not set,
the dimensions are queried by calling C<size> property. If set, however,
the C<size> property is not called, thus some speed-up can be achieved.

=item point2item X, Y

Returns the index of an item that contains point (X,Y). If the point 
belongs to the item outside the widget's interior, returns the index
of the first item outside the widget's interior in the direction of the point.

=item redraw_items ITEMS

Redraws all items in ITEMS array.

=item select_all

Selects all items.

Only for mult-select mode.

=item set_item_selected INDEX, FLAG

Sets selection flag of INDEXth item.
If FLAG is 1, the item is selected. If 0, it is deselected.

Only for mult-select mode.

=item select_item INDEX

Selects INDEXth item.

Only for mult-select mode.

=item std_draw_text_items CANVAS, ITEMS

An optimized method, draws unified text-based items.
It is fully compatible to C<draw_items> interface,
and is used in C<Prima::ListBox> class.

The optimization is derived from the assumption that items
maintain common background and foreground colors, that differ 
in selected and non-selected states only. The routine groups
drawing requests for selected and non-selected items, and
draws items with reduced number of calls to C<color> property.
While the background is drawn by the routine itself, the foreground
( usually text ) is delegated to the C<draw_text_items> method, so
the text positioning and eventual decorations would not require
full rewrite of code. 

ITEMS is an array of arrays of scalars, where each array
contains parameters of C<DrawItem> notification.
See L<DrawItem> for parameters description.

=item toggle_item INDEX

Toggles selection of INDEXth item.

Only for mult-select mode.

=item unselect_item INDEX

Deselects INDEXth item.

Only for mult-select mode.

=back

=head2 Events

=over

=item Click

Called when the user presses return key or double-clicks on
an item. The index of the item is stored in C<focusedItem>.

=item DrawItem CANVAS, INDEX, X1, Y1, X2, Y2, SELECTED, FOCUSED

Called when an INDEXth item is to be drawn on CANVAS. 
X1, Y1, X2, Y2 designate the item rectangle in widget coordinates,
where the item is to be drawn. SELECTED and FOCUSED are boolean
flags, if the item must be drawn correspondingly in selected and
focused states.

=item MeasureItem INDEX, REF

Puts width in pixels of INDEXth item into REF
scalar reference. This notification must be called 
from within C<begin_paint_info/end_paint_info> block.

=item SelectItem INDEX, FLAG

Called when the item changed its selection state.
INDEX is the index of the item, FLAG is its new selection
state: 1 if it is selected, 0 if it is not.

=item Stringify INDEX, TEXT_REF

Puts text string, assigned to INDEXth item into TEXT_REF
scalar reference.

=back

=head1 Prima::AbstractListBox

Exactly the same as its ascendant, C<Prima::AbstractListViewer>,
except that it does not propagate C<DrawItem> message, 
assuming that the items must be drawn as text. 

=head1 Prima::ListViewer

The class implements items storage mechanism, but leaves
the items format to the programmer. The items are accessible via
C<items> property and several other helper routines.

The class also defines the user navigation, by accepting character
keyboard input and jumping to the items that have text assigned
with the first letter that match the input.

C<Prima::ListViewer> is derived from C<Prima::AbstractListViewer>.

=head2 Properties

=over

=item autoWidth BOOLEAN

Selects if the gross item width must be recalculated automatically 
when either the font changes or item list is changed.

Default value: 1

=item count INTEGER

A read-only property; returns number of items.

=item items ARRAY

Accesses the storage array of items. The format of items is not
defined, it is merely treated as one scalar per index.

=back

=head2 Methods

=over

=item add_items ITEMS

Appends array of ITEMS to the end of the list.

=item calibrate

Recalculates all item widths and adjusts C<itemWidth> if
C<autoWidth> is set.

=item delete_items ITEMS

Deletes items from the list. ITEMS can be either an array,
or a reference to an array of item indices.

=item get_item_width INDEX

Returns width in pixels of INDEXth item from internal cache.

=item get_items ITEMS

Returns array of items. ITEMS can be either an array,
or a reference to an array of item indices.
Depending on the caller context, the results are different:
in array context the item list is returned; in scalar -
only the first item from the list. The semantic of the last
call is naturally usable only for single item retrieval.

=item insert_items OFFSET, ITEMS

Inserts array of items at OFFSET index in the list.
Offset must be a valid index; to insert items at the end of
the list use C<add_items> method.

ITEMS can be either an array, or a reference to an array of 
item indices.

=item replace_items OFFSET, ITEMS

Replaces existing items at OFFSET index in the list.
Offset must be a valid index.

ITEMS can be either an array, or a reference to an array of 
item indices.

=back

=head1 Prima::ProtectedListBox

A semi-demonstrational class, derived from C<Prima::ListViewer>,
that applies certain protection for every item drawing session.
Assuming that several item drawing routines can be assembled in one
widget, C<Prima::ProtectedListBox> provides a safety layer between
these, so, for example, one drawing routine that selects a font
or a color and does not care to restore the old value back, 
does not affect the outlook of the other items. 

This functionality is implementing by overloading C<draw_items> 
method and also all graphic properties.

=head1 Prima::ListBox

Descendant of C<Prima::ListViewer>, declares format of items 
as a single text string. Incorporating all of functionality of
its predecessors, provides a standard listbox widget.

=head2 Synopsis

   my $lb = Prima::ListBox-> create(
      items       => [qw(First Second Third)],
      focusedItem => 2,
      onClick     => sub { 
         print $_[0]-> get_items( $_[0]-> focusedItem), " is selected\n";
      }
   );

=head2 Methods

=over

=item get_item_text INDEX

Returns text string assigned to INDEXth item.
Since the item storage organization is implemented, does
so without calling C<Stringify> notification.

=back

=head1 AUTHOR

Dmitry Karasik, E<lt>dmitry@karasik.eu.orgE<gt>.

=head1 SEE ALSO

L<Prima>, L<Prima::Widget>, L<Prima::ComboBox>, L<Prima::FileDialog>, F<examples/editor.pl>

=cut
