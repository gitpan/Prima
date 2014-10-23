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
#  $Id: drivecombo.pl,v 1.7 2001/10/25 11:21:10 dk Exp $
#

=pod 
=item NAME

File tree widgets

=item FEATURES

Use of standard file-listbox and drive-combo box ( the latter
is idle under *nix )

=cut

use strict;
use Carp;
use Prima::ComboBox;
use Prima::Classes;
use Prima::FileDialog;

package UserInit;
$::application = Prima::Application-> create( name => "DriveCombo.pm");

my $w = Prima::Window-> create(
   text   => "Combo box",
   left   => 100,
   bottom => 300,
   width  => 250,
   height => 250,
   onDestroy=> sub { $::application-> destroy},
);

$w-> insert( DriveComboBox =>
   origin => [ 10, 10],
   width  => 200,
   name => 'ComboBox1',
   onChange => sub { $w-> DirectoryListBox1->path( $_[0]->text); },
);

$w-> insert( DirectoryListBox =>
   origin => [ 10, 40],
   width  => 200,
   height => 160,
   growMode => gm::Client,
   onChange => sub { print $_[0]-> path."\n"},
   name => 'DirectoryListBox1',
);

run Prima;
