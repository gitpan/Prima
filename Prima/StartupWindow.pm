#
#  Copyright (c) 1997-2000 The Protein Laboratory, University of Copenhagen
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
#  Created by Anton Berezin  <tobez@tobez.org>
#
#  $Id: StartupWindow.pm,v 1.7 2000/10/18 11:57:59 tobez Exp $

package Prima::StartupWindow;
use strict;
use vars qw(@windowStack @pointersStack);

sub import {
   shift;
   my %profileDefault = (
      size        => [$::application-> width/5,$::application-> height/6],
      centered    => 1,
      widgetClass => wc::Dialog,
      borderIcons => 0,
      borderStyle => bs::Dialog,
      color       => cl::Cyan,
      text        => 'Loading...',
      onPaint     => sub {
         my ($me,$canvas) = @_;
         my $fore = $me-> color;
         $canvas-> color( $me-> backColor);
         $canvas-> bar( 0, 0, $me-> size);
         $canvas-> color( $fore);
         $canvas-> font( name => "Tms Rmn", size => 24, style => fs::Bold);
         my $txt = $me-> text;
         $canvas-> text_out( $txt, ($me-> width - $me-> get_text_width($txt))/2, ($me-> height - $me-> font-> height)/2);
      },
   );
   my %profile = (%profileDefault,@_);
   push @pointersStack, $::application-> pointer;
   $::application-> pointer( cr::Wait);
   my $w = Prima::Window-> create(%profile);
   push @windowStack, $w;
   $::application-> yield;
   $w-> repaint;
   $w-> update_view;
}

sub unimport {
   return unless defined @windowStack;
   return if @windowStack <= 0;
   my $w = pop @windowStack;
   my $oautoClose = $::application-> autoClose;
   $::application-> autoClose(0);
   $w-> destroy;
   $::application-> autoClose( $oautoClose);
   $::application-> pointer( pop @pointersStack);
}

1;
