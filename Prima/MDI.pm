#
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
#  Created by Dmitry Karasik <dk@plab.ku.dk>
#
#  $Id: MDI.pm,v 1.22 2002/05/14 13:22:21 dk Exp $
package Prima::MDI;

# contains:
#   MDI
#   MDIOwner
#   MDIWindow
#   MDIExternalDockerShuttle

use strict;
use Prima::Classes;


package Prima::MDIMethods;

sub mdi_activate
{
   my $self = $_[0];
   my @m    = $self-> mdis;
   for ( @m) {
      next unless $_->visible;
      $_->repaint_title;
   }
}

sub mdis
{
   return grep {$_->isa('Prima::MDI')?$_:0} $_[0]-> widgets
}

sub arrange_icons
{
   my @m = $_[0]-> mdis;
   $m[0]->arrange_icons if $m[0];
}

sub cascade
{
   my @m = $_[0]-> mdis;
   $m[0]->cascade if $m[0];
}

sub tile
{
   my @m = $_[0]-> mdis;
   $m[0]->tile if $m[0];
}

package Prima::MDIWindowOwner;
use vars qw(@ISA);
@ISA = qw( Prima::Window Prima::MDIMethods);

package Prima::MDIOwner;
use vars qw(@ISA);
@ISA = qw( Prima::Widget Prima::MDIMethods);

sub profile_default
{
   my $def = $_[ 0]-> SUPER::profile_default;
   my %prf = (
      growMode    => gm::Client,
   );
   @$def{keys %prf} = values %prf;
   return $def;
}

package mbi;

use constant SystemMenu => bi::SystemMenu;
use constant Minimize   => bi::Minimize;
use constant Maximize   => bi::Maximize;
use constant TitleBar   => bi::TitleBar;
use constant Close      => bi::TitleBar << 1;
use constant All        => bi::All | Close;

package Prima::MDI;
use vars qw(@ISA);
@ISA = qw(Prima::Widget);

use Prima::StdBitmap;

{
my %RNT = (
   %{Prima::Widget->notification_types()},
   Activate      => nt::Default,
   Deactivate    => nt::Default,
   WindowState   => nt::Default,
);

sub notification_types { return \%RNT; }
}

use constant cMIN        => 0;
use constant cMAX        => 1;
use constant cCLOSE      => 2;
use constant cRESTORE    => 3;
use constant pMIN        => 4;
use constant pMAX        => 5;
use constant pCLOSE      => 6;
use constant pRESTORE    => 7;


sub profile_default
{
   my $def = $_[ 0]-> SUPER::profile_default;
   my %prf = (
      width                 => 150,
      heigth                => 150,
      selectable            => 1,
      borderIcons           => mbi::All,
      borderStyle           => bs::Sizeable,
      font                  => Prima::Application-> get_caption_font,
      selectingButtons      => 0,
      icon                  => 0,
      iconMin               => Prima::StdBitmap::image( sbmp::Min),
      iconMax               => Prima::StdBitmap::image( sbmp::Max),
      iconClose             => Prima::StdBitmap::image( sbmp::Close),
      iconRestore           => Prima::StdBitmap::image( sbmp::Restore),
      iconMinPressed        => Prima::StdBitmap::image( sbmp::MinPressed),
      iconMaxPressed        => Prima::StdBitmap::image( sbmp::MaxPressed),
      iconClosePressed      => Prima::StdBitmap::image( sbmp::ClosePressed),
      iconRestorePressed    => Prima::StdBitmap::image( sbmp::RestorePressed),
      ownerFont             => 0,
      dragMode              => undef,
      tabStop               => 0,
      tileable              => 1,
      titleHeight           => 0, # use system-default
      transparent           => 0,
      widgetClass           => wc::Window,
      windowState           => ws::Normal,
      clientClass           => 'Prima::Widget',
      clientProfile         => {},
      firstClick            => 1,
      popupItems            => [
         [ restore => '~Restore'  => 'Ctrl+F5' => '^F5' => q(restore)],
         [ min     => 'Mi~nimize' => q(minimize)],
         [ max     => 'Ma~ximize' => 'Ctrl+F10' => '^F10' => q(maximize)],
         [ move    => '~Move' => q(keyMove)],
         [ size    => '~Size' => q(keySize)],
         [],
         [ close   => '~Close' => 'Ctrl+F4' => '^F4' => q(close)],
      ],
   );
   @$def{keys %prf} = values %prf;
   return $def;
}


sub init
{
   my $self = shift;
   for ( qw( borderStyle borderIcons icon windowState))
      { $self->{$_} = -1; }
   for ( qw( pressState iconsAtRight border tileable titleHeight titleY))
      { $self->{$_} = 0; }
   my %profile = $self-> SUPER::init(@_);
   $self->{zoomGrowMode} = $profile{growMode};
   for ( qw( titleHeight borderStyle borderIcons icon tileable windowState dragMode
      iconMin iconMax iconClose iconRestore iconMinPressed iconMaxPressed
      iconClosePressed iconRestorePressed
      ))
      { $self->$_( $profile{ $_}); }
   $self-> {zoomRect} = [ $self->rect];
   $self-> {miniRect} = [ 0, 0, $self-> sizeMin];
   $self-> popup-> autoPopup(0) if $self-> popup;
   $self-> {client} = $self-> insert( $profile{clientClass},
      rect         => [ $self-> get_client_rect],
      growMode     => gm::Client,
      pointerType  => cr::Arrow,
      name         => 'MDIClient',
      delegations  => ['Destroy'],
      %{$profile{clientProfile}},
   );
   return %profile;
}

sub on_paint
{
   my ( $self, $canvas) = @_;
   my @cl  = ( $self-> color, $self-> backColor);
   my @c3d   = ( $self-> light3DColor, $self-> dark3DColor);
   my @size  = $canvas-> size;
   my @csize = @size;
   my $dy    = $self-> {titleY};
   my ( $bs, $bi, $bb, $bp) =
      ( $self->{borderStyle}, $self->{borderIcons},$self->{border},$self->{pressState});
   my @ct = ($self-> hiliteColor, $self-> hiliteBackColor);

   $bi = 0 unless $bi & mbi::TitleBar;

   $canvas-> rect3d( 0, 0, $size[0]-1, $size[1]-1, 1, $c3d[1], cl::Black) if $bb > 0;
   $canvas-> rect3d( 1, 1, $size[0]-2, $size[1]-2, 1, $c3d[0], $c3d[1]) if $bb > 1;
   $canvas-> rect3d( 2, 2, $size[0]-3, $size[1]-3, $bb - 2, cl::Back|wc::Window, cl::Back|wc::Window) if $bb > 2;

   $csize[0] -= $bb * 2;
   $csize[1] -= $bb * 2;
   $csize[1] -= $dy if $bi & mbi::TitleBar;

   my $ico = $self->{icon} ? $self->{icon} : Prima::StdBitmap::image( sbmp::SysMenu);

   my $dicon = 4;
   my $icos = $self-> { iconsAtRight};

   my $tyStart = $size[1] - $bb - $dy;

   if ( $bi & mbi::TitleBar) {
      my $xAt  = $bb + 4;
      $xAt += $dy if $bi & mbi::SystemMenu;
      my $tx = $self-> text;
      my $w  = $size[0] - $bb - $icos * $dy - 1 - $xAt;
      if ( $canvas-> get_text_width( $tx) > $w) {
         $w -= $canvas-> get_text_width( '...');
         $tx = $canvas-> text_wrap( $tx, $w, 0)->[0].'...';
      }

      my $dbmw =  $size[0] - $bb * 2 - $icos * $dy;
      if ( $dbmw > 0 && $dy > 0) {
         my $dbm = Prima::DeviceBitmap-> create(
            width  => $dbmw,
            height => $dy,
            font   => $canvas-> font,
         );
         my $x = $canvas-> font;
         $dbm-> color( $ct[1]);
         $dbm-> bar( 0, 0, $dbm-> size);
         $dbm-> color( $ct[0]);
         $dbm-> text_out( $tx, $xAt, ( $dy - $canvas-> font-> height) / 2);
         $dbm-> stretch_image( 0, 0, $dy, $dy, $ico) if $bi & mbi::SystemMenu;
         $canvas-> put_image( $bb, $tyStart, $dbm);
         $dbm-> destroy;
      }
   }

   my $tx = $size[0] - $bb - $icos * $dy;
   my $bbi = $bi;
   while ( $icos) {
      my $di;
      if ( $bbi & mbi::Minimize) {
         my $wmin = $self->{windowState} == ws::Minimized;
         $di  = ( $bp & mbi::Minimize) ?
            $self-> {icons}-> [ $wmin ? pRESTORE : pMIN] :
            $self-> {icons}-> [ $wmin ? cRESTORE : cMIN];
         $bbi &= ~mbi::Minimize;
      } elsif ( $bbi & mbi::Maximize) {
         my $wmax = $self->{windowState} == ws::Maximized;
         $di = ( $bp & mbi::Maximize) ?
            $self-> {icons}-> [ $wmax ? pRESTORE : pMAX] :
            $self-> {icons}-> [ $wmax ? cRESTORE : cMAX];
         $bbi &= ~mbi::Maximize;
      } elsif ( $bbi & mbi::Close) {
         $di =  $self-> {icons}-> [( $bp & mbi::Close) ? pCLOSE : cCLOSE];
         $bbi &= ~mbi::Close;
      }
      $canvas-> stretch_image( $tx, $tyStart, $dy, $dy, $di);
      $tx += $dy;
      $icos--;
   }

   $canvas-> color( $cl[1]);
   $canvas-> bar( $bb, $bb, $bb + $csize[0] - 1, $bb + $csize[1] - 1);
}

sub get_client_rect
{
   my ( $self, $x, $y) = @_;
   ( $x, $y) = $self-> size unless defined $x;
   my $bw = $self-> { border};
   my @r = ( $bw, $bw, $x - $bw, $y - $bw);
   $r[3] -= $self->{titleY} + 1 if $self->{borderIcons} & mbi::TitleBar;
   $r[3] = $r[1] if $r[3] < $r[1];
   return @r;
}

sub client2frame
{
   my ( $self, $x1, $y1, $x2, $y2) = @_;
   my $bw = $self-> { border};
   my @r = ( $x1 - $bw, $y1 - $bw, $x2 + $bw, $y2 + $bw);
   $r[3] += $self->{titleY} + 1 if $self->{borderIcons} & mbi::TitleBar;
   return @r;
}

sub frame2client
{
   my ( $self, $x1, $y1, $x2, $y2) = @_;
   my $bw = $self-> { border};
   my @r = ( $x1 + $bw, $y1 + $bw, $x2 - $bw, $y2 - $bw);
   $r[3] -= $self->{titleY} + 1 if $self->{borderIcons} & mbi::TitleBar;
   $r[3] = $r[1] if $r[3] < $r[1];
   return @r;
}

sub sync_client
{
   return unless $_[0]-> {client};
   $_[0]-> {client}-> rect( $_[0]-> get_client_rect);
}

sub client
{
   return $_[0]-> {client} unless $#_;
   my ( $self, $c) = @_;
   $c-> owner( $self);
   $c-> clipOwner(1);
   $c-> rect( $self-> get_client_rect);
   $self-> {client} = $c;
}   

sub mdis
{
   return grep {$_-> isa('Prima::MDI') ? $_ : 0} $_[0]-> owner-> widgets
}

sub arrange_icons
{
   my $self = $_[0]-> owner;
   my @mdis = grep { ($_->windowState == ws::Minimized && $_-> clipOwner) ? $_ : 0} $_[0]-> mdis;
   return unless scalar @mdis;
   my @szMin = $mdis[0]-> sizeMin;
   my $szx  = $self-> width / $szMin[0];
   my $szy  = int( $self-> height / $szMin[1]);
   $szx ++ if $szx > int($szx) and scalar @mdis > $szx * $szy;
   $szx = int( $szx);
   my $i = 0;
   $_->lock for @mdis;
   for ( @mdis) {
      $_->origin( $i % $szx * $szMin[0], int($i / $szx) * $szMin[1]);
      $i++;
   }
   $_->unlock for @mdis;
}

sub cascade
{
   my $self = $_[0]-> owner;
   my @mdis = grep { (($_->windowState != ws::Minimized) and $_->tileable && $_-> clipOwner) ? $_ : 0} $_[0]-> mdis;
   return unless scalar @mdis;
   my $i = 0;
   for ( @mdis) {
      last if $_->selected;
      $i++;
   }
   if ( $i < scalar @mdis) {
     $i = splice( @mdis, $i, 1);
     push( @mdis, $i);
   }
   $_->lock for @mdis;
   my @r = (0,0,$self-> size);
   for ( @mdis) {
      $_->restore if $_->windowState != ws::Normal;
      $_->rect( @r);
      my @radd = $_->get_client_rect;
      $r[2]  = $r[0] + $radd[2];
      $r[3]  = $r[1] + $radd[3];
      $r[0] += $radd[0];
      $r[1] += $radd[1];
      $_->bring_to_front;
   }
   $_->unlock for @mdis;
}

sub tile
{
   my $self = $_[0]-> owner;
   my @mdis = grep { (($_->windowState != ws::Minimized) and $_->tileable && $_-> clipOwner) ? $_ : 0} $_[0]-> mdis;
   return unless scalar @mdis;
   my $n = scalar @mdis;
   my $i = int( sqrt( $n));
   $i++ if $n % $i and (( $n % ( $i + 1)) == 0);
   $i = int($n / $i) if $i < int( $n / $i);
   my ( $col, $row) = ( int($n / $i), $i);
   my @sz = $self-> size;
   return if $sz[0] < $col or $sz[1] < $row;
   ( $i, $n) = ( scalar @mdis % $col, $#mdis);
   $_->lock for @mdis;
   for ( @mdis) {
      my $a = ( $col - $i) * $row;
      my $x = ( $n < $a) ? int( $n / $row) : int(( $n - $a) / ( $row + 1)) + ( $col - $i);
      my $y = ( $n < $a) ? $n % $row : int(( $n - $a) % ( $row + 1));
      $_->rect(
         $sz[0] * $x / $col,
         $sz[1] * $y / ( $row + (( $n >= $a) ? 1 : 0)),
         $sz[0] * ( $x + 1) / $col,
         $sz[1] * ( $y + 1) / ( $row + (( $n >= $a) ? 1 : 0))
      );
      $n--;
   }
   $_->unlock for @mdis;
}

sub xy2part
{
   my ( $self, $x, $y) = @_;
   my @size = $self-> size;
   my $bw   = $self-> { border};
   my $bwx  = $bw + 16;
   my $bi   = $self-> { borderIcons};
   my $bs   = $self-> { borderStyle};
   my $icos = $self-> { iconsAtRight};
   my $move = $self-> {windowState} != ws::Maximized;
   my $size = ( $bs == bs::Sizeable) && ( $self->{windowState} == ws::Normal);
   my $dy   = ( $bi & mbi::TitleBar) ? $self-> {titleY} : 0;

   if ( $x < $bw) {
      return q(border) unless $size;
      return q(SizeSW) if $y < $bwx;
      return q(SizeNW) if $y >= $size[1] - $bwx;
      return q(SizeW);
   } elsif ( $x >= $size[0] - $bw) {
      return q(border) unless $size;
      return q(SizeSE) if $y < $bwx;
      return q(SizeNE) if $y >= $size[1] - $bwx;
      return $size ? q(SizeE) : q(border);
   } elsif (( $y < $bw) or ( $y >= $size[1] - $bw)) {
      return q(border) unless $size;
      return ( $y < $bw) ? q(SizeSW) : q(SizeNW) if $x < $bwx;
      return ( $y < $bw) ? q(SizeSE) : q(SizeNE) if $x >= $size[0] - $bwx;
      return ($y < $bw) ? q(SizeS) : q(SizeN);
   } elsif ( $y < $size[1] - $bw - $dy) {
      return q(client);
   } elsif ( $x < $dy + $bw) {
      return ( $bi & mbi::SystemMenu) ? q(menu) : ( $move ? q(caption) : q(title));
   } elsif ( $x <= $size[0] - $bw - $icos * $dy) {
      return $move ? q(caption) : q(title);
   } elsif ( $x >= $size[0] - $bw - $dy) {
      return ( $bi & mbi::Close) ? q(close) :
             (( $bi & mbi::Maximize)  ? (
                ($self->{windowState} == ws::Maximized) ? q(restore) : q(max)
             ) : (
                ($self->{windowState} == ws::Minimized) ? q(restore) : q(min)
             ));
   } elsif ( $x >= $size[0] - $bw - $dy * 2) {
      return (( $bi & ( mbi::Close | mbi::Maximize)) == (mbi::Close | mbi::Maximize))
         ? (
            ($self->{windowState} == ws::Maximized) ? q(restore) : q(max)
         ) : (
            ($self->{windowState} == ws::Minimized) ? q(restore) : q(min)
         );
   } else {
      return ($self->{windowState} == ws::Minimized) ? q(restore) : q(min);
   }
   return q(desktop);
}

sub post_action
{
   my ( $self, $action) = @_;
   $self-> post_message(q(cmMDI), $action);
}

sub repaint_title
{
   my ( $self, $area) = @_;
   my @size = $self-> size;
   my $bw = $self-> {border};
   my $dy = $self-> {titleY};
   $area ||= '';
   return unless $self->{ borderIcons} & mbi::TitleBar;
   if ( $area eq 'right') {
      $self-> invalidate_rect(
         $size[0] - $bw - $self->{iconsAtRight} * $dy, $size[1] - $bw,
         $size[0] - $bw, $size[1] - $bw - $dy
      );
   } elsif ( $area eq 'left') {
      $self-> invalidate_rect(
         $bw, $size[1] - $bw - $dy,
         $bw + $dy, $size[1] - $bw,
      );
   } else {
      my $dx = (( $self->{borderIcons} & mbi::SystemMenu) and ( !defined $self->{icon})) ? $dy : 0;
      $self-> invalidate_rect(
         $bw + $dx, $size[1] - $bw - $dy,
         $size[0] - $bw - $self->{iconsAtRight} * $dy, $size[1] - $bw,
      );
   }
}

sub sizemove_cancel
{
   my $self = $_[0];
   my $ok;
   return unless $self-> {mouseTransaction};
   if ( $self-> {mouseTransaction} eq q(caption)) {
      if ( $self-> {fullDrag}) {
         $self-> origin( @{$self-> {trackSaveData}});
      } else {
         $self-> xorrect( @{$self-> {prevRect}});
      }
      $ok = 1;
   } elsif ( $self-> {mouseTransactionArea} eq q(size)) {
      if ( $self-> {fullDrag}) {
         $self-> rect( @{$self-> {trackSaveData}});
      } else {
         $self-> xorrect( @{$self-> {prevRect}});
      }
      $ok = 1;
   } elsif ( $self-> {mouseTransaction} eq q(keyMove)) {
      if ( $self-> {fullDrag}) {
         $self-> origin( @{$self-> {trackSaveData}});
      } else {
         $self-> xorrect( @{$self-> {prevRect}});
      }
      $self-> select;
      $ok = 1;
   } elsif ( $self-> {mouseTransaction} eq q(keySize)) {
      if ( $self-> {fullDrag}) {
         $self-> rect( @{$self-> {trackSaveData}});
      } else {
         $self-> xorrect( @{$self-> {prevRect}});
      }
      $self-> select;
      $ok = 1;
   }
   if ( $ok) {
     $self-> {mouseTransaction} =
     $self-> {mouseTransactionArea} =
     $self-> {dirData} =
     $self-> {spotX} = $self-> {spotY} = undef;
     $self-> pointer( cr::Default);
     $self-> capture(0);
   }
   return $ok;
}

sub check_drag
{
   my $self = $_[0];
   if ( defined $self-> {dragMode}) {
      $self-> {fullDrag} = $self-> {dragMode};
   } else {
      $self-> {fullDrag} = $::application-> get_system_value( sv::FullDrag);
   }
}

sub keyMove
{
   my $self = $_[0];
   $self-> { mouseTransaction} = $self-> { mouseTransactionArea} = q(keyMove);
   ($self-> {spotX}, $self-> {spotY}) = $self-> pointerPos;
   $self-> {trackSaveData} = [$self-> origin];
   $self-> pointer( cr::Move);
   $self-> focus;
   $self-> capture(1, $self-> clipOwner ? $self-> owner : ());
   $self-> check_drag;
   unless ($self-> {fullDrag}) {
      $self-> {prevRect} = [$self-> client_to_screen(0,0,$self-> size)];
      $self-> xorrect( @{$self-> {prevRect}});
   };
}

sub keySize
{
   my $self = $_[0];
   $self-> { mouseTransaction} = $self-> { mouseTransactionArea} = q(keySize);
   $self-> {trackSaveData} = [$self-> rect];
   $self-> pointer( cr::Size);
   $self-> focus;
   $self-> capture(1, $self-> clipOwner ? $self-> owner : ());
   $self-> check_drag;
   unless ($self-> {fullDrag}) {
      $self-> {prevRect} = [$self-> client_to_screen(0,0,$self-> size)];
      $self-> xorrect( @{$self-> {prevRect}});
   };
}


sub on_postmessage
{
   my ( $self, $cm, $cm2) = @_;
   return if $cm ne q(cmMDI);

   if ( $cm2 eq q(min)) {
      $self-> windowState( ws::Minimized);
   } elsif ( $cm2 eq q(max)) {
      $self-> windowState( ws::Maximized);
   } elsif ( $cm2 eq q(restore)) {
      $self-> windowState( ws::Normal);
   } elsif ( $cm2 eq q(close)) {
      $self-> close;
   }
}

sub xorrect
{
   my ( $self, @r) = @_;
   $r[2]--;
   $r[3]--;
   my $o = $::application;
   $o-> begin_paint;
   my $oo = $self-> clipOwner ? $self-> owner : $::application;
   $o-> clipRect( $oo-> client_to_screen( 0,0,$oo->size));
   $o-> rect_focus( @r, $self-> {border});
   $o-> end_paint;
}

sub on_mousedown
{
   my ( $self, $btn, $mod, $x, $y) = @_;
   $self-> clear_event;
   return if $self-> {mouseTransaction};

   my $part = $self-> xy2part( $x, $y);
   $self-> bring_to_front;
   $self-> select;
   return if
      $part eq q(client) or
      $part eq q(border) or
      $btn != mb::Left;

   if ( $part eq q(menu)) {
      # Win32 test results - we won't get on_click( double=1) after 'cancelling'
      # on_mousedown with popup - the system says it's no more double clicks,
      # just click to popup. Moreover, in general it's right. But we could
      # catch second on_mousedown in system-defined timeout interval, but,
      # this popup-cancelling on_mousedown won't come to us also.
      my $delay = Prima::Application-> get_system_value( sv::DblClickDelay);
      $delay = 250 if $delay > 250;
      $self-> {exTimer} = Prima::Timer-> create(
         owner   => $self,
         timeout => $delay,
         onTick  => sub {
            my $self = $_[0]-> owner;
            $_[0]-> destroy;
            delete $self-> {exTimer};
            return unless $self-> alive || ! defined ( $self-> popup);
            my $w  = $self-> height;
            my $y  = $self-> {titleY};
            my $bw = $self-> {border};
            $self-> popup-> popup( $self->{border}, $self->height - $self->{border} - $self->{titleY},
               $bw, $w - $y - $bw, $bw + $y, $w - $bw
            );
         },
      );
      $self-> {exTimer}-> start;
      return;
   }

   if ( $part eq q(caption)) {
      $self-> {mouseTransaction} = $part;
      $self-> {spotX} = $x;
      $self-> {spotY} = $y;
      $self-> {trackSaveData} = [$self-> origin];
      $self-> capture(1, $self-> clipOwner ? $self-> owner : ());
      $self-> check_drag;
      unless ($self-> {fullDrag}) {
         $self-> {prevRect} = [$self-> client_to_screen(0,0,$self-> size)];
         $self-> xorrect( @{$self-> {prevRect}});
         my @r = @{$self->{prevRect}};
      };
      return;
   }

   if ( $part =~ /Size/) {
      $self-> {mouseTransaction} = $part;
      $self-> {mouseTransactionArea} = 'size';
      $self-> {spotX} = $x;
      $self-> {spotY} = $y;
      $self-> {trackSaveData} = [$self-> rect];
      $part =~ s/Size//;
      my ( $xa, $ya);
      if    ( $part eq q(S))   { ( $xa, $ya) = ( 0,-1); }
      elsif ( $part eq q(N))   { ( $xa, $ya) = ( 0, 1); }
      elsif ( $part eq q(W))   { ( $xa, $ya) = (-1, 0); }
      elsif ( $part eq q(E))   { ( $xa, $ya) = ( 1, 0); }
      elsif ( $part eq q(SW)) { ( $xa, $ya) = (-1,-1); }
      elsif ( $part eq q(NE)) { ( $xa, $ya) = ( 1, 1); }
      elsif ( $part eq q(NW)) { ( $xa, $ya) = (-1, 1); }
      elsif ( $part eq q(SE)) { ( $xa, $ya) = ( 1,-1); }
      $self-> {dirData} = [$xa, $ya];
      $self-> capture(1, $self-> clipOwner ? $self-> owner : ());
      $self-> check_drag;
      unless ($self-> {fullDrag}) {
         $self-> {prevRect} = [$self-> client_to_screen(0,0,$self-> size)];
         $self-> xorrect( @{$self-> {prevRect}});
      };
      return;
   }

   $self-> {mouseTransaction} = $part;
   $self-> {mouseTransactionArea} = 'right';
   $self-> {pressState} = 0 |
      ( $part eq q(min)     ? mbi::Minimize : 0)  |
      ( $part eq q(max)     ? mbi::Maximize : 0)  |
      ( $part eq q(close)   ? mbi::Close    : 0)|
      ( $part eq q(restore) ? (
         ($self-> {windowState} == ws::Minimized) ? mbi::Minimize : mbi::Maximize
      ) : 0)
   ;
   $self-> {lastMouseOver} = 1;
   $self-> repaint_title(q(right));
   $self-> capture(1, $self-> clipOwner ? $self-> owner : ());
}

sub on_mouseclick
{
   my ( $self, $btn, $mod, $x, $y, $dbl) = @_;
   $self-> clear_event;
   return if $self-> {mouseTransaction} or !$dbl;
   my $part = $self-> xy2part( $x, $y);

   if ( $part eq q(caption)) {
      $self-> post_action(( $self->{windowState} == ws::Normal) ? q(max) : q(restore));
      return;
   }

   if ( $part eq q(title)) {
      $self-> post_action( q(restore));
      return;
   }

   if ( $part eq q(menu)) {
      if ( $self-> {exTimer}) {
         $self-> {exTimer}-> destroy;
         delete $self-> {exTimer};
      }
      $self-> post_action(q(close));
      return;
   }
}

sub on_translateaccel
{
   my ( $self, $code, $key, $mod) = @_;
   if ( !$self-> {mouseTransaction}) {
      if (( $key == kb::Tab) && ( $mod & km::Ctrl)) {
         my $x    = $self-> first;
         my $mdix = $x-> isa('Prima::MDI') ? $x : undef;
         while ( $x) {
            $x = $x-> next;
            $mdix = $x if $x && $x-> isa('Prima::MDI');
         }
         unless ( $x) {
            $x = $self-> last;
            $mdix = $x if $x && $x-> isa('Prima::MDI');
         }
         if ( $mdix) {
            $mdix-> bring_to_front;
            $mdix-> select;
         }
         $self-> clear_event;
      }
   }
}

sub on_keydown
{
   my ( $self, $code, $key, $mod) = @_;

   if ( $self-> {mouseTransaction} and ( $key == kb::Esc)) {
      $self-> sizemove_cancel;
      $self-> clear_event;
      return;
   }

   return unless $self-> {mouseTransaction};

   if ( $self-> {mouseTransaction} eq q(keyMove)) {
      my ( $dx, $dy) = (0,0);
      if ( $key == kb::Down)  { $dy -= 5; } elsif
         ( $key == kb::Up)    { $dy += 5; } elsif
         ( $key == kb::Left)  { $dx -= 5; } elsif
         ( $key == kb::Right) { $dx += 5; } elsif
         ( $key == kb::Enter) {
            $self-> pointer( cr::Default);
            $self-> capture(0);
            $self-> clear_event;
            unless ( $self-> {fullDrag}) {
               $self-> xorrect( @{$self-> {prevRect}});
               my $oo = $self-> clipOwner ? $self-> owner : $::application;
               $self-> origin( $oo-> screen_to_client(@{$self-> {prevRect}}[0,1]));
            }
            $self-> {mouseTransaction} = $self-> {mouseTransactionArea} = $self-> {dirData} =
               $self-> {spotX} = $self-> {spotY} = undef;
            return;
         }
      if ( $dx or $dy) {
         my @p = $self-> pointerPos;
         my @o = $self-> origin;
         $self-> pointerPos( $p[0] + $dx, $p[1] + $dy);
         $self-> clear_event;
         if ( $self-> {fullDrag}) {
            $self-> origin( $o[0] + $dx, $o[1] + $dy);
         } else {
            $self-> xorrect( @{$self-> {prevRect}});
            ${$self-> {prevRect}}[0] += $dx;
            ${$self-> {prevRect}}[1] += $dy;
            ${$self-> {prevRect}}[2] += $dx;
            ${$self-> {prevRect}}[3] += $dy;
            $self-> xorrect( @{$self-> {prevRect}});
         }
         return;
      }
   }

   if ( $self-> {mouseTransaction} eq q(keySize)) {
      my ( $dx, $dy) = (0,0);
      if ( $key == kb::Down)  { $dy += 5; } elsif
         ( $key == kb::Up)    { $dy -= 5; } elsif
         ( $key == kb::Left)  { $dx -= 5; } elsif
         ( $key == kb::Right) { $dx += 5; } elsif
         ( $key == kb::Enter) {
            $self-> {mouseTransaction} = $self-> {mouseTransactionArea} = undef;
            $self-> pointer( cr::Default);
            $self-> capture(0);
            $self-> clear_event;
            unless ( $self-> {fullDrag}) {
               $self-> xorrect( @{$self-> {prevRect}});
               my $oo = $self-> clipOwner ? $self-> owner : $::application;
               $self-> rect( $oo-> screen_to_client(@{$self-> {prevRect}}));
            }
            return;
         }
      if ( $dx or $dy) {
         if ( $self->{fullDrag}) {
            my @o = $self-> size;
            $self-> width( $o[0] + $dx) if $dx;
            if ( $dy) {
               my $b = $self-> bottom;
               $self-> height( $o[1] + $dy);
               $self-> bottom( $b - $dy) unless $self-> height != $o[1] + $dy;
            }
         } else {
            $self-> xorrect( @{$self-> {prevRect}});
            my @r = @{$self-> {prevRect}};
            $r[1] -= $dy;
            $r[2] += $dx;
            my @min = $self-> sizeMin;
            $r[1] = $r[3] - $min[1] if $r[3] - $r[1] < $min[1];
            $r[2] = $r[0] + $min[0] if $r[2] < $r[0] + $min[0];
            my @max = $self-> sizeMax;
            $r[1] = $r[3] - $max[1] if $r[3] - $r[1] > $max[1];
            $r[2] = $r[0] + $max[0] if $r[2] > $r[0] + $max[0];
            $self-> {prevRect} = \@r;
            $self-> xorrect( @r);
         }
         $self-> clear_event;
         return;
      }
   }
}

sub on_mouseup
{
   my ( $self, $btn, $mod, $x, $y) = @_;
   $self-> clear_event;
   return unless $self-> {mouseTransaction};

   my $tr = $self-> {mouseTransaction};
   $self-> {mouseTransaction} = undef;

   $self-> {lastMouseOver} = undef;
   $self-> capture(0);

   if ( $tr eq q(caption)) {
      unless ( $self-> {fullDrag}) {
         $self-> xorrect( @{$self-> {prevRect}});
         my @org = $_[0]-> origin;
         my @new = ( $org[0] + $x - $self->{spotX}, $org[1] + $y - $self->{spotY});
         $self-> origin( $new[0], $new[1]) if $org[1] != $new[1] || $org[0] != $new[0];
      }
      $self-> {spotX} = $self-> {spotY} = undef;
      return;
   }

   if ( $self-> {mouseTransactionArea} eq q(right)) {
      $self-> {pressState} = 0;
      $self-> {mouseTransactionArea} = undef;
      my $part = $self-> xy2part( $x, $y);
      if ( $part eq $tr) {
         $self-> repaint_title(q(right));
         $self-> post_action( $tr);
      }
      return;
   }

   if ( $self-> {mouseTransactionArea} eq q(size)) {
      unless ($self-> {fullDrag}) {
         my @r = @{$self-> {prevRect}};
         $self-> xorrect( @r);
         my $oo = $self-> clipOwner ? $self-> owner : $::application;
         $self-> rect( $oo-> screen_to_client(@r));
      };
      $self-> {mouseTransactionArea} = $self->{dirData} = undef;
      return;
   }
}

sub on_mousemove
{
   my ( $self, $mod, $x, $y) = @_;
   $self-> clear_event;

   if ( $self->{mouseTransaction}) {
       if ( $self-> {mouseTransaction} eq q(caption)) {
          if ( $self->{fullDrag}) {
             my @org = $_[0]-> origin;
             my @new = ( $org[0] + $x - $self->{spotX}, $org[1] + $y - $self->{spotY});
             $self-> origin( $new[0], $new[1]) if $org[1] != $new[1] || $org[0] != $new[0];
          } else {
             $self-> xorrect( @{$self-> {prevRect}});
             my @xorg = $self-> client_to_screen( $x - $self->{spotX}, $y - $self->{spotY});
             my @sz   = $self-> size;
             $self-> {prevRect} = [ @xorg, $sz[0] + $xorg[0], $sz[1] + $xorg[1]];
             $self-> xorrect( @{$self-> {prevRect}});
          }
          return;
       }

       if ( $self-> {mouseTransaction} eq q(keyMove)) {
          if ( $self->{fullDrag}) {
             my @org = $_[0]-> origin;
             my @new = ( $org[0] + $x - $self->{spotX}, $org[1] + $y - $self->{spotY});
             $self-> origin( $new[0], $new[1]) if $org[1] != $new[1] || $org[0] != $new[0];
          } else {
          #  It works, but confuses slightly
          #  $self-> xorrect( @{$self-> {prevRect}});
          #  my @xorg = $self-> client_to_screen( $x - $self->{spotX}, $y - $self->{spotY});
          #  my @sz   = $self-> size;
          #  $self-> {prevRect} = [ @xorg, $sz[0] + $xorg[0], $sz[1] + $xorg[1]];
          #  $self-> xorrect( @{$self-> {prevRect}});
          }
          return;
       }

       if ( $self-> {mouseTransactionArea} eq q(right)) {
          my $part = $self-> xy2part( $x, $y);
          my $mouseOver = $part eq $self-> {mouseTransaction};
          if ( $self-> { lastMouseOver} != $mouseOver) {
             $self-> {pressState} = $mouseOver ? ( 0 |
                ( $part eq q(min)     ? mbi::Minimize : 0)  |
                ( $part eq q(max)     ? mbi::Maximize : 0)  |
                ( $part eq q(close)   ? mbi::Close    : 0)|
                ( $part eq q(restore) ? (
                   ( $self-> {windowState} == ws::Minimized) ? mbi::Minimize : mbi::Maximize
                ) : 0)) : 0;
             $self-> { lastMouseOver} = $mouseOver;
             $self-> repaint_title(q(right));
          }
          return;
       }

       if ( $self-> {mouseTransactionArea} eq q(size)) {
          my @org = $_[0]-> rect;
          my @new = @org;
          my @min = $self-> sizeMin;
          my ( $xa, $ya) = @{$self->{dirData}};

          if ( $xa < 0) {
             $new[0] = $org[0] + $x - $self->{spotX};
             $new[0] = $org[2] - $min[0] if $new[0] > $org[2] - $min[0];
          } elsif ( $xa > 0) {
             $new[2] = $org[2] + $x - $self->{spotX};
             if ( $new[2] < $org[0] + $min[0]) {
                $new[2] = $org[0] + $min[0];
                $self->{spotX} = $min[0] if $self->{fullDrag};
             } else {
                $self->{spotX} = $x if $self->{fullDrag};
             }
          }

          if ( $ya < 0) {
             $new[1] = $org[1] + $y - $self->{spotY};
             $new[1] = $org[3] - $min[1] if $new[1] > $org[3] - $min[1];
          } elsif ( $ya > 0) {
             $new[3] = $org[3] + $y - $self->{spotY};
             if ( $new[3] < $org[1] + $min[1]) {
                $new[3] = $org[1] + $min[1];
                $self->{spotY} = $min[1] if $self->{fullDrag};
             } else {
                $self->{spotY} = $y if $self->{fullDrag};
             }
          }
          if ( $org[1] != $new[1] || $org[0] != $new[0] || $org[2] != $new[2] || $org[3] != $new[3]) {
             if ( $self-> {fullDrag}) {
                $self-> rect( @new)
             } else {
                $self-> xorrect( @{$self-> {prevRect}});
                my $oo = $self-> clipOwner ? $self-> owner : $::application;
                $self-> {prevRect} = [$oo-> client_to_screen( @new)];
                $self-> xorrect( @{$self-> {prevRect}});
             }
          }
          return;
       }
   } else {
      if (
           $self-> {borderStyle} == bs::Sizeable and
           $self-> {windowState} == ws::Normal
         ) {
         return if !$self-> enabled;
         my $part = $self-> xy2part( $x, $y);
         $self-> pointer( $part =~ /^Size/ ? &{$cr::{$part}} : cr::Arrow);
      } else {
         $self-> pointer( cr::Arrow);
      }
   }
}

sub on_enable { $_[0]-> repaint; }
sub on_disable { $_[0]-> repaint; }


sub text
{
   return $_[0]->SUPER::text unless $#_;
   $_[0]-> SUPER::text( $_[1]);
   $_[0]-> repaint_title(q(title));
}

sub update_size_min
{
   my $self = $_[0];
   my @a = Prima::Application-> get_default_window_borders( $self->{borderStyle});
   my $ic = $self-> { iconsAtRight} + 1 + (($self->{borderIcons} & mbi::SystemMenu) ? 1 : 0);
   $self-> sizeMin( $self-> {titleY} * $ic + $a[0] * 2, $self-> {titleY} + $a[1] * 2); 
}   

sub set_border_icons
{
   my ( $self, $bi) = @_;
   $bi &= mbi::All;
   return if $bi == $self->{borderIcons};
   $self->{borderIcons} = $bi;

   my $icos = 0;
   $icos++ if $bi & mbi::Minimize;
   $icos++ if $bi & mbi::Maximize;
   $icos++ if $bi & mbi::Close;

   $self-> { iconsAtRight} = $icos;

   $self-> update_size_min;
   $self-> sync_client;
   $self-> repaint;
}

sub set_border_style
{
   my ( $self, $bs) = @_;
   return if $bs == $self->{borderStyle} or $bs < bs::None or $bs > bs::Dialog;
   $self->{borderStyle} = $bs;
   my ( $bbx, $bby) = Prima::Application-> get_default_window_borders( $bs);
   $bbx = $bbx > 1 ? $bbx : (( $bbx > 0) ? 1 : 0);
   $bby = $bby > 1 ? $bby : (( $bby > 0) ? 1 : 0);
   $self-> {border} = $bbx > $bby ? $bby : $bbx;

   $self-> update_size_min;
   $self-> sync_client;
   $self-> repaint;
}

sub set_window_state
{
   my ( $self, $ws) = @_;
   return if $ws == $self->{windowState} or $ws < ws::Normal or $ws > ws::Maximized;
   my $ows = $self->{windowState};

   my $popup = $self-> popup;
   if ( $ws == ws::Minimized) {
      return unless $self->{borderIcons} & mbi::Minimize;
      $self-> {zoomRect} = [ $self->rect] if $ows == ws::Normal;
      $self-> growMode( $self-> {zoomGrowMode}) if $ows == ws::Maximized;
      my @szMin = $self-> sizeMin;
      my ($x, $y) = ( $self-> {miniRect}->[0], $self-> {miniRect}->[1]);
      $self-> clipOwner(1) unless ($self-> {saveClipOwner} = $self-> clipOwner);
      
      # start calculating position for min-widnow
      my @sz = $self-> clipOwner ? $self-> owner-> size : $::application-> size;
      $x = $sz[0] - $szMin[0] if $x > $sz[0] - $szMin[0];
      $y = $sz[1] - $szMin[1] if $y > $sz[1] - $szMin[1];
      my @mdis = grep {(( $_ ne $self) and ( $_->windowState == ws::Minimized)) ? $_ : 0} $self-> mdis;
      my @maps;
      my @szmaxids = ( int($sz[0] / $szMin[0]), int($sz[1] / $szMin[1]));
      $szmaxids[0] = 1 unless $szmaxids[0];
      $szmaxids[1] = 1 unless $szmaxids[1];

      for ( @mdis) {
         my ( $ax, $ay) = ( $_->left / $szMin[0], $_->bottom / $szMin[1]);
         my $id = int( $ay) * $szmaxids[0] + int( $ax);
         push ( @maps, $id);
         push ( @maps, $id + 1) if $ax > int( $ax);
         push ( @maps, $id + $szmaxids[0]) if $ay > int( $ay);
         push ( @maps, $id + $szmaxids[0] + 1) if $ay > int( $ay) and $ax > int( $ax);
      }
      my $id = int( $y / $szMin[1]) * $szmaxids[0] + int( $x / $szMin[0]);
      if ( scalar grep { $_ == $id ? 1 : 0} @maps) {
         my $i;
         my %hh = map {$_=>1} @maps;
         @maps = sort { $a <=> $b} keys %hh;
         my $newID = scalar @maps;
         for ( $i = 0; $i < scalar @maps; $i++) {
            $newID = $i, last if $i != $maps[ $i];
         }
         $x = ( $newID % $szmaxids[0]) * $szMin[0];
         $y = int ( $newID / $szmaxids[0]) * $szMin[1];
      }
      # end calculating position for min-widnow

      ($self-> {miniRect}->[0], $self-> {miniRect}->[1]) = ( $x, $y);
      $self-> {miniRect}->[2] = $self-> {miniRect}->[0] + $szMin[0];
      $self-> {miniRect}->[3] = $self-> {miniRect}->[1] + $szMin[1];
      $self-> rect( @{$self-> {miniRect}});
      $popup-> enable( $_)  for ( qw( max restore move));
      $popup-> disable( $_) for ( qw( min size));
   } elsif ( $ws == ws::Maximized) {
      return unless $self->{borderIcons} & mbi::Maximize;
      $self-> clipOwner(0) 
         if $ows == ws::Minimized && !$self->{saveClipOwner};
      delete $self->{saveClipOwner};
      $self-> {miniRect} = [ $self->rect] if $ows == ws::Minimized;
      $self-> {zoomRect} = [ $self->rect] if $ows == ws::Normal;
      $self-> rect( 0, 0, $self-> clipOwner ? $self-> owner-> size : $::application-> size);
      $self-> {zoomGrowMode} = $self-> growMode;
      $self-> growMode( gm::Client);
      $popup-> enable( $_)  for ( qw( min restore));
      $popup-> disable( $_) for ( qw( max move size));
   } else {
      $self-> {windowState} = ws::Normal;
      return unless $self->{borderIcons} & (mbi::Maximize|mbi::Minimize);
      $self-> clipOwner(0) 
         if $ows == ws::Minimized && !$self->{saveClipOwner};
      delete $self->{saveClipOwner};
      $self-> {miniRect} = [ $self->rect] if $ows == ws::Minimized;
      $self-> growMode( $self-> {zoomGrowMode}) if $ows == ws::Maximized;
      $self-> rect( @{$self->{zoomRect}});
      $popup-> enable( $_)  for ( qw( max min move size));
      $popup-> disable( $_) for ( qw( restore));
   }
   $self->{windowState} = $ws;
   $self-> notify(q(WindowState));
}


sub set_icon
{
   my ( $self, $icon) = @_;
   $self->{icon} = $icon;
   $self-> repaint_title(q('left'));
}

sub on_windowstate
{
#  my $self = $_[0];
}

sub on_activate
{
#  my $self = $_[0];
}

sub on_deactivate
{
#  my $self = $_[0];
}

sub MDIClient_Destroy
{
   $_[0]-> destroy;
}

sub titleHeight
{
   return $_[0]->{titleHeight} unless $#_;
   my ( $self, $th) = @_;
   $self-> {titleHeight} = $th;
   $th = Prima::Application-> get_system_value( sv::YTitleBar) unless $th;
   return if $self-> {titleY} == $th;
   $self-> {titleY} = $th;
   $self-> sync_client;
   $self-> repaint;
}   

sub __icon
{
   my ( $self, $id) = ( shift, shift);
   return $self->{icons}->[$id] unless @_;
   $self-> {icons}->[$id] = shift;
   $self-> repaint_title;
}   

sub iconMin            { return shift-> __icon( cMIN,     @_)};
sub iconMax            { return shift-> __icon( cMAX,     @_)};
sub iconClose          { return shift-> __icon( cCLOSE,   @_)};
sub iconRestore        { return shift-> __icon( cRESTORE, @_)};
sub iconMinPressed     { return shift-> __icon( pMIN,     @_)};
sub iconMaxPressed     { return shift-> __icon( pMAX,     @_)};
sub iconClosePressed   { return shift-> __icon( pCLOSE,   @_)};
sub iconRestorePressed { return shift-> __icon( pRESTORE, @_)};

sub maximize    { $_[0]-> windowState( ws::Maximized)}
sub minimize    { $_[0]-> windowState( ws::Minimized)}
sub restore     { $_[0]-> windowState( ws::Normal)}

sub borderIcons          {($#_)?$_[0]->set_border_icons($_[1])                        :return $_[0]->{borderIcons}}
sub borderStyle          {($#_)?$_[0]->set_border_style($_[1])                        :return $_[0]->{borderStyle}}
sub dragMode             {($#_)?($_[0]->{dragMode} = $_[1])                           :return $_[0]->{dragMode}; }
sub frameOrigin          {return shift-> origin( @_);}
sub frameSize            {return shift-> size( @_);}
sub frameWidth           {return shift-> width( @_);}
sub frameHeight          {return shift-> height( @_);}
sub tileable             {($#_)?$_[0]->{tileable}=$_[1]                               :return $_[0]->{tileable}; }
sub windowState          {($#_)?$_[0]->set_window_state($_[1])                        :return $_[0]->{windowState}    }
sub icon                 {($#_)?$_[0]->set_icon        ($_[1])  :                      return $_[0]->{icon}           }

package Prima::MDIExternalDockerShuttle;
use vars qw(@ISA);
@ISA = qw(Prima::MDI);

sub profile_default
{
   my $def = $_[ 0]-> SUPER::profile_default;
   my $fh = int($def->{font}->{height} / 1.5);
   my %prf = (
      titleHeight    => $fh + 4,
      borderIcons    => mbi::TitleBar | mbi::Close,
      clipOwner      => 0,
      shuttle        => undef,
   );
   @$def{keys %prf} = values %prf;
   $def->{font}->{height} = $fh;
   $def->{font}->{width}  = 0;
   return $def;   
}   

sub init
{
   my $self = shift;
   my %profile = $self-> SUPER::init(@_);
   $self->$_($profile{$_}) for qw(shuttle);
   return %profile;
}   

sub shuttle
{
   return $_[0]-> {shuttle} unless $#_;
   $_[0]-> {shuttle} = $_[1];
}   

sub on_mousedown
{
   my ( $self, $btn, $mod, $x, $y) = @_;
   if (q(caption) ne $self-> xy2part( $x, $y)) {
      $self-> SUPER::on_mousedown( $btn, $mod, $x, $y);
      return;
   }   
   $self-> clear_event;
   return if $self-> {mouseTransaction};
   $self-> bring_to_front;
   $self-> select;
   return if $btn != mb::Left;
   my $s = $self-> shuttle;
   if ( $s-> client) {
      $s-> rect( $s-> client2frame( $s-> client-> rect));
   } else {
      $s-> rect( $self-> frame2client( $self-> rect));
   }   
   $s-> drag( 1, [ $self-> rect], $s-> screen_to_client( $self-> client_to_screen($x, $y)));
   $self-> clear_event;
}   

sub on_mouseclick
{
   my ( $self, $btn, $mod, $x, $y, $dbl) = @_; 
   if (!$dbl || (q(caption) ne $self-> xy2part( $x, $y))) {
      $self-> SUPER::on_mouseclick( $btn, $mod, $x, $y, $dbl); 
      return;
   }   
   $self-> clear_event;
   $self-> shuttle-> dock_back;
}   

sub windowState
{
   return $_[0]->{windowState} unless $#_;
   my ( $self, $ws) = @_;
   if ( $ws == ws::Maximized) {
      $self-> shuttle-> dock_back;
   } else {
      $self-> SUPER::windowState( $ws);
   }   
}   

1;
