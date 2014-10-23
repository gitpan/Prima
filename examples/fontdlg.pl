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
#  $Id: fontdlg.pl,v 1.8 2000/10/18 11:58:06 tobez Exp $
#
package fontdlg;

use strict;
use Carp;
use Prima;
use Prima::Classes;
use Prima::Application name => "Font Dialog";
use Prima::Lists;
use Prima::Sliders;
use Prima::Buttons;

sub run {
my $w = 0;

my @fontItems = ();
my %fontList  = ();
my $displayRes;


my $fs = 0;
my $fd = 0;
my $fpitch = fp::Default;
my $fwidth = 0;

my $re_sample = sub {
   return if $w-> {exampleFontSet};
   my $fn = $fontList{ $w-> NameList-> get_item_text($w-> NameList-> focusedItem)}{name};
   $w-> {exampleFontSet} = 1;
   my $i = $w-> SizeList-> focusedItem;

   $w-> Example-> lock;
   my %font = (
      name        => $fn,
      size        => $w-> SizeList-> get_item_text( $i),
      style       => $fs,
      direction   => $fd,
      pitch       => $fpitch,
   );

   $w-> Example-> font( %font,
      width => 0,
   );

   $w-> Example-> font( %font,
      width => $w-> Example-> font-> width * $fwidth,
   ) if $fwidth;

   $w-> Example-> unlock;

   $w-> {exampleFontSet} = undef;
};

my $lastSizeSel = 12;

my $re_size = sub {
   my $fn = $fontList{ $w-> NameList-> get_item_text( $w-> NameList-> focusedItem)}{name};
   my @sizes = ();
   my @list = @{$::application-> fonts( $fn)};
   for ( @list)
   {
      if ( $_->{ vector})
      {
         @sizes = qw( 8 9 10 11 12 14 16 18 20 22 24 26 28 32 48 72);
         last;
      } else {
         push ( @sizes, $_->{size});
      }
   }
   @sizes = sort { $a <=> $b } keys %{{(map { $_ => 1 } @sizes)}};

   my $i;
   my $found = 0;
   for ( $i = 0; $i < scalar @sizes; $i++)
   {
      if ( $sizes[$i] == $lastSizeSel)
      {
         $found = 1;
         last;
      }
   }
   unless ( $found)
   {
      for ( $i = 0; $i < scalar @sizes; $i++)
      {
          last if ( $sizes[$i] > $lastSizeSel);
      }
      $i-- if $i = scalar @sizes;
   }
   $w-> SizeList-> set_items(\@sizes);
   $w-> SizeList-> set_focused_item($i);
};

$w = Prima::Window-> create( text => "Font Window",
   origin => [ 200, 200],
   size   => [ 500, 530],
   onDestroy => sub{ $::application-> close},
   borderStyle => bs::Dialog,
);

$displayRes = ($w->resolution)[1];
for ( sort { $a->{name} cmp $b->{name}} @{$::application-> fonts})
{
   $fontList{$_->{name}} = $_;
   push ( @fontItems, $_->{name});
}

$w-> insert( ListBox =>
   name   => "NameList",
   origin => [25, 25],
   size   => [ 225, 315],
   items => [@fontItems],
   onSelectItem => sub {
       &$re_size;
       &$re_sample;
   },
);

$w-> insert( ListBox =>
   name   => 'SizeList',
   origin => [ 270, 220],
   size   => [ 200, 120],
   onSelectItem => sub {
      $lastSizeSel = $_[0]-> get_item_text( $_[0]-> focusedItem);
       &$re_sample;
   },
);

$w-> insert( Button =>
  origin => [ 24, 348],
  size   => [ 32, 32],
  text   => 'B',
  name   => 'Bold',
  selectable => 0,
  font   => {
     height => 20,
     style  => fs::Bold,
  },
  checkable => 1,
  onClick   => sub {
     $fs = ( $fs & fs::Bold ? $fs & ~fs::Bold : $fs | fs::Bold);
     &$re_sample;
  },
);

$w-> insert( Button =>
  origin => [ 60, 348],
  size   => [ 32, 32],
  text   => 'I',
  name   => 'Italic',
  selectable => 0,
  font   => {
     height => 20,
     style  => fs::Italic,
  },
  checkable => 1,
  onClick   => sub {
     $fs = (( $fs & fs::Italic) ? ($fs & ~fs::Italic) : ($fs | fs::Italic));
     &$re_sample;
  },
);

$w-> insert( Button =>
  origin => [ 96, 348],
  size   => [ 32, 32],
  text   => 'U',
  selectable => 0,
  name   => 'Underlined',
  font   => {
     height => 20,
     style  => fs::Underlined,
  },
  checkable => 1,
  onClick   => sub {
     $fs = (( $fs & fs::Underlined) ? ($fs & ~fs::Underlined) : ($fs | fs::Underlined));
     &$re_sample;
  },
);

$w-> insert( Button =>
  origin => [ 142, 348],
  size   => [ 32, 32],
  text   => 'i',
  selectable => 0,
  name   => 'Info',
  color  => cl::Blue,
  font   => { height => 28, style => fs::Bold, name => "Tms Rmn"},
  onClick   => sub {
     my $f = $w-> Example-> font;
     Prima::Window-> create(
        size => [ 500, 500],
        font => $f,
        text => $f-> size.'.['.$f->height.'x'.$f->width.']'.$f-> name,
        onPaint => sub {
           my ( $self, $p) = @_;
           my @size = $p-> size;
           $p-> color( cl::White);
           $p-> bar( 0, 0, @size);
           $p-> color( cl::Black);

           $p-> font-> direction(0);

           my $m = $p-> get_font;
           my $s = $size[1] - $m->{height} - $m->{externalLeading} - 20;
           my $w = $p-> get_text_width("�Mg") + 66;
           $p-> textOutBaseline(1);
           $p-> text_out("�Mg", 20, $s);

           my $cachedFacename = $p-> font-> name;
           my $hsf = $p-> font-> height / 6;
           $hsf = 10 if $hsf < 10;
           $p-> font-> set(
              height => $hsf,
              style  => fs::Italic,
              name   => '',
           );

           $p-> line( 2, $s, $w, $s);
           $p-> textOutBaseline(0);
           $p-> text_out( "Baseline", $w - 8, $s);
           my $sd = $s - $m->{descent};
           $p-> line( 2, $sd, $w, $sd);
           $p-> text_out( "Descent",  $w - 8, $sd);
           $sd = $s + $m->{ascent};
           $p-> line( 2, $sd, $w, $sd);
           $p-> text_out( "Ascent",  $w - 8, $sd);
           $sd = $s + $m->{ascent} + $m->{externalLeading};

           if ( $m->{ascent} > 4) {
             $p-> line( $w - 12, $s + 1, $w - 12, $s + $m->{ascent});
             $p-> line( $w - 12, $s + $m->{ascent}, $w - 14, $s + $m->{ascent} - 2);
             $p-> line( $w - 12, $s + $m->{ascent}, $w - 10, $s + $m->{ascent} - 2);
           }
           if ( ($m->{ascent}-$m->{internalLeading}) > 4) {
             my $pt = $m->{ascent}-$m->{internalLeading};
             $p-> line( $w - 16, $s + 1, $w - 16, $s + $pt);
             $p-> line( $w - 16, $s + $pt, $w - 18, $s + $pt - 2);
             $p-> line( $w - 16, $s + $pt, $w - 14, $s + $pt - 2);
           }
           if ( $m->{descent} > 4) {
              $p-> line( $w - 13, $s - 1, $w - 13, $s - $m->{descent});
              $p-> line( $w - 13, $s - $m->{descent}, $w - 15, $s - $m->{descent} + 2);
              $p-> line( $w - 13, $s - $m->{descent}, $w - 11, $s - $m->{descent} + 2)
           }

           my $str;
           $p-> text_out( "External Leading",  2, $sd);
           $p-> line( 2, $sd, $w, $sd);
           $sd = $s + $m->{ascent} - $m->{internalLeading};
           $str = "Point size in device units";
           $p-> text_out( $str,  $w - 16 - $p-> get_text_width( $str), $sd);
           $p-> linePattern( lp::Dash);
           $p-> line( 2, $sd, $w, $sd);


           $p-> font-> set(
              height => 16,
              pitch  => fp::Fixed,
           );
           my $fh = $p-> font-> height;
           $sd = $s - $m->{descent} - $fh * 3;
           $p-> text_out( 'nominal size        : '.$m->{size}, 2, $sd); $sd -= $fh;
           $p-> text_out( 'cell height         : '.$m->{height   }, 2, $sd); $sd -= $fh;
           $p-> text_out( 'average width       : '.$m->{width    }, 2, $sd); $sd -= $fh;
           $p-> text_out( 'ascent              : '.$m->{ascent   }, 2, $sd); $sd -= $fh;
           $p-> text_out( 'descent             : '.$m->{descent  }, 2, $sd); $sd -= $fh;
           $p-> text_out( 'weight              : '.$m->{weight   }, 2, $sd); $sd -= $fh;
           $p-> text_out( 'internal leading    : '.$m->{internalLeading}, 2, $sd); $sd -= $fh;
           $p-> text_out( 'external leading    : '.$m->{externalLeading}, 2, $sd); $sd -= $fh;
           $p-> text_out( 'maximal width       : '.$m->{maximalWidth}, 2, $sd); $sd -= $fh;
           $p-> text_out( 'horizontal dev.res. : '.$m->{xDeviceRes}, 2, $sd); $sd -= $fh;
           $p-> text_out( 'vertical dev.res.   : '.$m->{yDeviceRes}, 2, $sd); $sd -= $fh;
           $p-> text_out( 'first char          : '.$m->{firstChar}, 2, $sd); $sd -= $fh;
           $p-> text_out( 'last char           : '.$m->{lastChar }, 2, $sd); $sd -= $fh;
           $p-> text_out( 'break char          : '.$m->{breakChar}, 2, $sd); $sd -= $fh;
           $p-> text_out( 'default char        : '.$m->{defaultChar}, 2, $sd); $sd -= $fh;
           $p-> text_out( 'family              : '.$m->{family   }, 2, $sd); $sd -= $fh;
           $p-> text_out( 'face name           : '.$cachedFacename, 2, $sd); $sd -= $fh;
        },
     )-> select;
  },
);


my $csl = $w-> insert( CircularSlider =>
   origin      => [ 370, 348],
   size        => [ 100, 100],
   name        => 'Angle',
   buttons     => 0,
   font        => {size => 5},
   min         => -180,
   max         => 180,
   scheme      => ss::Axis,
   increment   => 30,
   step        => 10,
   onChange    => sub {  $fd = $_[0]-> value * 10; &$re_sample; },
);

$csl-> insert( Button =>
   origin => [ 10, 10],
   size   => [ 14, 14],
   text   => 'o',
   onClick => sub { $_[0]-> owner-> value(0); },
);

my $rg = $w-> insert( RadioGroup =>
   origin      => [ 25, 460],
   size        => [ 445, 58],
   name        => 'Pitch',
);

$rg-> insert( Radio =>
   name   => 'Default',
   origin => [ 15, 5],
   onClick =>  sub { $fpitch = fp::Default;  &$re_sample; },
   checked => 1,
);

$rg-> insert( Radio =>
   name   => 'Fixed',
   origin => [ 160, 5],
   onClick =>  sub { $fpitch = fp::Fixed;  &$re_sample; },
   font    => { style => fs::Bold, pitch => fp::Fixed},
);

$rg-> insert( Radio =>
   name   => 'Variable',
   origin => [ 305, 5],
   font    => { style => fs::Bold|fs::Italic, pitch => fp::Variable},
   onClick =>  sub { $fpitch = fp::Variable; &$re_sample; },
);

$w-> insert( Slider =>
   name     => 'Stretcher',
   origin   => [ 25, 382],
   size     => [ 225, 58],
   vertical => 0,
   min      => -5,
   max      => 5,
   scheme   => ss::Axis,
   step     => 0.5,
   increment=> 5,
   value    => 0,
   onChange => sub {
      $fwidth = $_[0]-> value;
      if ( $fwidth > 0) {
         $fwidth += 1;
      } elsif ( $fwidth < 0) {
         $fwidth = -1 / ( $fwidth - 1);
      }
      &$re_sample;
   },
);

$w-> insert( Button =>
   origin => [ 130, 440],
   size   => [ 14, 14],
   text   => 'o',
   font   => {size => 5},
   onClick => sub { $w-> Stretcher-> value(0); },
);


$w-> insert( Widget =>
   name      => 'Example',
   origin    => [ 270, 85],
   size      => [ 200, 120],
   backColor => cl::White,
   onPaint   => sub {
      my ($fore, $back, $x, $y) = ($_[0]-> color, $_[0]-> backColor, $_[1]-> width, $_[1]-> height);
      $_[1]-> color( $back);
      $_[1]-> bar( 0, 0, $x, $y);
      $_[1]-> color( $fore);
      my $probe = "AaBbCcZz";
      $probe = $_[1]-> font-> size.".".$_[1]-> font-> name;
      my $width = $_[1]-> get_text_width( $probe);
      $_[1]-> text_out( $probe, ( $x - $width) / 2, ( $y - $_[1]-> font-> height) / 2);
   },
   onFontChanged => sub {
      unless ( defined $w-> {exampleFontSet})
      {
         my $font = $_[0]-> font;
         my $name = $font-> name;
         my $size = $font-> size;
         $fs = $font-> style;
         $fd = $font-> direction / 10;
         my ( $i, $j);
         for ( $i = 0; $i < scalar @fontItems; $i++)
         {
            last if $name eq $fontItems[ $i];
         }
         $w-> NameList-> set_focused_item( $i);
         my @sizes = @{$w-> SizeList-> items};
         for ( $j = 0; $j < scalar @sizes; $j++)
         {
            last if $size == $sizes[ $j];
         }
         $w-> SizeList-> set_focused_item( $j);
         $w-> Bold-> checked( $fs & fs::Bold);
         $w-> Italic-> checked( $fs & fs::Italic);
         $w-> Underlined-> checked( $fs & fs::Underlined);
         $w-> Angle-> value( $fd);
      }
   },
   onMouseDown => sub {
      return if $_[0]->{drag};
      $_[0]->{drag} = 1;
      $_[0]->capture(1);
      $_[0]->pointer( cr::Invalid)
   },
   onMouseUp   => sub {
      return unless $_[0]->{drag};
      $_[0]->capture(0);
      $_[0]->{drag} = 0;
      $_[0]->pointer( cr::Default);
      my $x = $::application-> get_widget_from_point( $_[0]-> client_to_screen( $_[3], $_[4]));
      return unless $x;
      $x-> font( $_[0]-> font);
   },
);

$w-> insert( Button =>
   origin      => [ 270, 25],
   text        => '~Ok',
   modalResult => cm::OK,
);

$w-> insert( Button =>
   origin      => [ 374, 25],
   text        => 'Cancel',
   modalResult => cm::Cancel,
);

&$re_size;
&$re_sample;
}

run;
run Prima;


