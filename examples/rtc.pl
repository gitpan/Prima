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
#  $Id: rtc.pl,v 1.5 2000/10/18 11:58:11 tobez Exp $
#
use Prima qw( Buttons ScrollBar);

package UserInit;

$::application = Prima::Application->create(name=> "rtc");
my $w = Prima::Window-> create(
  text=> "Test of RTC",
  origin => [ 200, 200],
  size   => [ 250, 300],
  onDestroy => sub {$::application-> close},
);

$w-> insert( "Button",
  origin  => [10, 10],
  width   => 220,
  text => "Change scrollbar direction",
  onClick=> sub {
    my $i = $_[0]-> owner-> govno;
    $i-> vertical( ! $i-> vertical);
  }
);

$w-> insert( "ScrollBar",
  name    => "govno",
  origin  => [ 40, 80],
  size    => [150, 150],
  onCreate => sub {
     Prima::Timer-> create(
         timeout=> 1000,
         timeout=> 200,
         owner  => $_[0],
         onTick => sub{
            # $_[0]-> owner-> vertical( !$_[0]-> owner-> vertical);
            my $t = $_[0]-> owner;
            my $v = $t-> partial;
            $t->partial( $v+1);
            $t->partial(1) if $t-> partial == $v;
            #$_[0]-> timeout( $_[0]-> timeout == 1000 ? 200 : 1000);
         },

     )-> start;
  },
);

run Prima;
