#
#  Copyright (c) 1997-2003 The Protein Laboratory, University of Copenhagen
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

#  $Id$
#

=pod 

=item NAME

Interactive key selection and storage

=item FEATURES

Contains an example how to use standard key selection and conversion
features of Prima::KeySelector. A typical program with interactively
configurable keys reflects the changes of key assignments in menu
hot-keys and initialization file. In the example, changes are stored
in ~/.prima/keyselector INI-file.

=cut

use strict;
use Prima qw(Application KeySelector IniFile Outlines Buttons Label);

package SerializedKeys;

# creates new instance of SerializedKeys class,
# which maps ini-file section and keys storage
# 
# parameters:
#   keys: hash of key description pairs, each is in form CommandName => [DefaultKey, CommandDescription ]
#   ini_section: ini file section object
sub new
{
   my ( $class, $keys, $ini_section) = @_;
	my $self = {};
	bless $self, $class;
   for ( keys %$keys) {
	   my $k = "Key_$_";
		next if exists $ini_section->{$k};
	   $ini_section->{$k} = "'" . $keys->{$_}->[0] . "'";
	}
	$self-> {default_keys} = $keys;
	$self-> {ini_section}  = $ini_section;
	$self-> {gui} = undef;
   $self-> {keyMappings}  = { 
	    map { $_ => Prima::AbstractMenu-> translate_shortcut( eval($ini_section-> {$_})); } 
       grep { m/^Key_/  } 
		 keys %$ini_section };
   return $self;
}

# creates GUI layout for interactive key selection
# of fixed extent 380x290 at $x,$y. 
#
# this call is optional; all function does not depend on it
# when changes are to be applied, call apply. when copied
# to the menu, call update_menu.
sub gui_insert
{
   my ( $self, $w, $x, $y) = @_;
	$self-> {gui} = $w;
   my $optKeys = $self->{default_keys};
   my %o_items;
   for ( keys %$optKeys) {
      m/^([A-Z][a-z]*)/;
      push( @{$o_items{$1}}, [$_]);
   }
   $w-> insert( [ StringOutline  =>  
      origin => [ $x+10, $y+58],
      size   => [ 200, 222],
      name   => 'KeyList',
		# this (default) sorting scheme is responsible for setting 'Edit' before 'File' -
		# any other is applicable though.
      items  => [ map {[ $_, $o_items{$_}]} sort keys %o_items ],
      onSelectItem => sub {
         my ( $me, $foc) = @_;
         my ( $item, $lev) = $_[0]-> get_item( $foc);
         return unless $item;
         $self-> {keyMappings_change} = 1;
         unless ( ref($item->[1])) {
            my $key = $_[0]-> get_item_text( $item);
            my $x = $self-> {keyMappings}-> {"Key_$key"};
            $w-> KeySelector-> enabled(1);
            $w-> KeySelector-> key( $self-> {keyMappings}-> {"Key_$key"} );
            $w-> KeyDescription-> text( $optKeys-> {$key}-> [1] );
            $w-> KeySelector-> show;
         } else {
            $w-> KeySelector-> hide;
            $w-> KeySelector-> enabled(0);
            $w-> KeyDescription-> text( '');
         }
         delete $self-> {keyMappings_change};
      },
   ] , [ KeySelector =>  
   origin => [ $x+220, $y+110],
   size   => [ 150, 170],
   name   => 'KeySelector',
   visible => 0,
   onChange => sub {
      return if $self-> {keyMappings_change};
      my $kl = $w-> KeyList;
      my ( $item, $lev) = $kl-> get_item( $kl-> focusedItem);
      return unless $item;
      my $okey = $kl-> get_item_text( $item);
      my $key = "Key_$okey";
      my $value = $_[0]-> key; 
      if ( $value != kb::NoKey) {
         for ( keys %{$self-> {keyMappings}}) {
            next if $_ eq $key;
            next unless $value == $self-> {keyMappings}->{$_};
            s/^Key_//;
            $self-> {keyMappings_change} = 1;
            $_[0]-> key( $self-> {keyMappings}->{$key}); 
            delete $self-> {keyMappings_change};
            my $l = $w-> KeyDescription;
            $l-> backColor( cl::LightRed);
            $l-> color( cl::Yellow);
            $l-> text( "This key combination is already occupied by $_ and cannot be used");
            $l-> insert(  Timer => timeout => 100 => onTick => sub {
               $l-> backColor( cl::Back);
               $l-> color( cl::Fore);
               $_[0]-> destroy;
            })-> start;
            return;
         }
      }
      $self-> {keyMappings}->{$key} = $value;
      $w-> KeyDescription-> text( $optKeys-> {$okey}-> [1] );
   }
	], [ Label => 
      origin => [ $x+220, $y+10],
      size   => [ 150, 100],
      autoWidth  => 0,
      autoHeight => 0,
      text       => '',
      name       => 'KeyDescription',
      wordWrap   => 1,
   ], [ Button => 
      origin  => [ $x+10, $y+10],
      size    => [96, 36],
      text    => '~Clear',
      hint    => 'Clears the key',
      onClick => sub {
         $w-> KeySelector-> key( kb::NoKey);
      },
   ] , [ Button => 
      origin  => [ $x+114, $y+10],
      size    => [96, 36],
      text    => '~Default',
      hint    => 'Set default value for a key',
      onClick => sub {
         my $kl = $w-> KeyList;
         my ( $item, $lev) = $kl-> get_item( $kl-> focusedItem);
         return unless $item;
         $w-> KeySelector-> key( Prima::AbstractMenu-> translate_shortcut(
            $self->{default_keys}-> {$kl-> get_item_text( $item)}-> [0])); 
      },
   ] );
   $w-> KeyList-> focusedItem(0);
}

# removes reference to GUI windows parent
sub gui_remove
{
   $_[0]->{gui} = undef;
}

# updates gui list when key definitions are changed outside GUI
sub gui_update
{
   my $self = $_[0];
	return unless $self->{gui};
	my $w = $self->{gui};
   $w-> KeyList-> focusedItem(0);
}

# returns a boolean flag, whether keys were changed by GUI
sub gui_changed { $_[0]-> {keyMappings_change} }

# copies keyMappings into menus
sub update_menu
{
   my ( $self, $menu) = @_;
   for ( keys %{$self-> {keyMappings}}) {
      next unless m/^Key_(.*)$/;
      my ( $item, $value) = ( $1, $self-> {keyMappings}->{$_});
      $menu-> key( $item, $value);
      $menu-> accel( $item, ($value == kb::NoKey) ? '' : Prima::KeySelector::describe( $value));
   }
}

# copies keymappings to initfile
sub save
{
   my $self = $_[0];
   $self-> {ini_section}-> {$_} = Prima::KeySelector::shortcut( $self-> {keyMappings}->{$_})
      for keys %{$self->{keyMappings}};
}

# reset all keys to default values
sub defaults
{
   my $self = $_[0];
   my $keys = $self->{default_keys};
   $self->{keyMappings}->{"Key_$_"} = Prima::AbstractMenu-> translate_shortcut($keys->{$_}->[0])
	   for keys %$keys;
   $self-> gui_update;
}

package main;

sub default_keys
{
   return {
      'FileExit'        => [ '@X',                       "Save changes and exit the program"],
      'FileQuit'        => [ km::Alt|km::Shift|ord('X'), "Does not save changes and exit the program"],
		'EditApply'       => [ '^A',                       "Applies changes to menu"],
		'EditDefault'     => [ kb::NoKey,                  "Restores all keys to defaults"],
   }
}

my $k;
my $w = Prima::MainWindow-> create(
   size => [ 380, 290],
	borderStyle => bs::Dialog,
	text => 'Key selector',
	centered => 1,
	menuItems => [
	   [ File => [
			[	'FileExit' => "~Exit and save changes" => sub { $_[0]-> close } ],
			[	'FileQuit' => "Exit and ~discard changes" => sub { 
			   $_[0]-> {saveOnExit} = 0;
				$_[0]-> close;
		   }],
		]],
		[ Edit => [
		   [ 'EditApply'    => "~Apply changes" => sub {
			    $k-> update_menu( $_[0]-> menu);
			}],
		   [ 'EditDefault'  => "~Restore to defaults" => sub {
				$k-> defaults;
				$k-> update_menu( $_[0]-> menu);
			}],
		]],
	],
	onClose => sub { $k-> save if $_[0]-> {saveOnExit}},
);
$w-> {saveOnExit} = 1;

$w->{iniFile} = Prima::IniFile-> create(
   file => Prima::Utils::path('keyselector'),
);
$k = SerializedKeys-> new( default_keys(), $w-> {iniFile}-> section( 'Options'));
$k-> update_menu( $w-> menu);
$k-> gui_insert( $w,0,0);

run Prima;
