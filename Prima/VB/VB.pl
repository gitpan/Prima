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
# $Id: VB.pl,v 1.47 2001/04/30 15:33:29 dk Exp $
use strict;
use Prima qw(StdDlg Notebooks MsgBox ComboBox ColorDialog IniFile);
use Prima::VB::VBLoader;
use Prima::VB::VBControls;
use Prima::VB::CfgMaint;

######### built-in setup variables  ###############

my $lite = 0;                          # set to 1 to use ::Lite packages. For debug only
$Prima::VB::CfgMaint::systemWide = 0;  # 0 - user config, 1 - root config to write
my $singleConfig                 = 0;  # set 1 to use only either user or root config
my $VBVersion                    = 0.1;

###################################################

$Prima::VB::VBLoader::builderActive = 1;
my $classes = 'Prima::VB::Classes';
if ( $lite) {
   $classes = 'Prima::VB::Lite::Classes';
   $Prima::VB::CfgMaint::systemWide = 1;
   $Prima::VB::CfgMaint::rootCfg = 'Prima/VB/Lite/Config.pm';
}

eval "use $classes;";
die "$@" if $@;
use Prima::Application name => 'Form template builder';

package VB;
use vars qw($inspector
            $main
            $form
            $fastLoad
            );

$fastLoad = 1;
my $openFileDlg;
my $saveFileDlg;
my $openImageDlg;
my $saveImageDlg;


sub open_dialog
{
   my %profile = @_;
   $openFileDlg = Prima::OpenDialog-> create( 
      icon => $VB::ico, 
      directory => $VB::main-> {ini}-> {OpenPath},
   ) unless $openFileDlg;
   $openFileDlg-> set( %profile);
   return $openFileDlg;
}

sub save_dialog
{
   my %profile = @_;
   $saveFileDlg = Prima::SaveDialog-> create( 
      icon => $VB::ico,
      directory => $VB::main-> {ini}-> {SavePath},
   ) unless $saveFileDlg;
   $saveFileDlg-> set( %profile);
   return $saveFileDlg;
}

sub image_open_dialog
{
   my %profile = @_;
   $openImageDlg = Prima::ImageOpenDialog-> create( 
      icon => $VB::ico, 
      directory => $VB::main-> {ini}-> {OpenPath},
   ) unless $openImageDlg;
   $openImageDlg-> set( %profile);
   return $openImageDlg;
}

sub image_save_dialog
{
   my %profile = @_;
   $saveImageDlg = Prima::ImageSaveDialog-> create( 
      icon => $VB::ico,
      directory => $VB::main-> {ini}-> {SavePath},
   ) unless $saveImageDlg;
   $saveImageDlg-> set( %profile);
   return $saveImageDlg;
}
sub accelItems
{
   return [
      ['openitem' => '~Open' => 'F3' => 'F3' => sub { $VB::main-> open;}],
      ['-saveitem1' => '~Save' => 'F2' => 'F2' => sub {$VB::main-> save;}],
      ['Exit' => 'Alt+X' => '@X' => sub{ $VB::main-> close;}],
      ['Object Inspector' => 'F11' => 'F11' => sub { $VB::main-> bring_inspector; }],
      ['-runitem' => '~Run' => 'Ctrl+F9' => '^F9' => sub { $VB::main-> form_run}, ],
   ];
}

package OPropListViewer;
use vars qw(@ISA);
@ISA = qw(PropListViewer);

sub on_click
{
   my $self = $_[0];
   my $index = $self-> focusedItem;
   my $current = $VB::inspector-> {current};
   return if $index < 0 or !$current;
   my $id = $self-> {'id'}->[$index];
   return if $id eq 'name' || $id eq 'owner';
   $self-> SUPER::on_click;
   if ( $self->{check}->[$index]) {
      $current->prf_set( $id => $current->{default}->{$id});
   } else {
      $current->prf_delete( $id);
   }
}

sub on_selectitem
{
   my ( $self, $lst, $state) = @_;
   return unless $state;
   $VB::inspector-> close_item;
   $VB::inspector-> open_item;
}


package ObjectInspector;
use vars qw(@ISA);
@ISA = qw(Prima::Window);

sub profile_default
{
   my $def = $_[ 0]-> SUPER::profile_default;
   my %prf = (
      text           => 'Object Inspector',
      width          => 280,
      height         => 350,
      left           => 6,
      sizeDontCare   => 0,
      originDontCare => 0,
      icon           => $VB::ico,
   );
   @$def{keys %prf} = values %prf;
   return $def;
}

sub init
{
   my $self = shift;
   my %profile = $self-> SUPER::init(@_);

   my @rx = split( ' ', $VB::main-> {ini}-> {ObjectInspectorRect});
   $self-> rect( @rx) if scalar grep { $_ != -1 } @rx;

   my @sz = $self-> size;

   my $fh = $self-> font-> height + 6;

   $self-> insert( ComboBox =>
      origin   => [ 0, $sz[1] - $fh],
      size     => [ $sz[0], $fh],
      growMode => gm::Ceiling,
      style    => cs::DropDown,
      name     => 'Selector',
      items    => [''],
      delegations => [qw(Change)],
   );

   $self-> {monger} = $self-> insert( Notebook =>
      origin  => [ 0, $fh],
      size    => [ 100,  $sz[1] - $fh * 2],
      growMode => gm::Client,
      pageCount => 2,
   );

   $self-> {mtabs} = $self-> insert( Button =>
      origin   => [ 0, 0],
      size     => [ 100, $fh],
      text     => '~Events',
      growMode => gm::Floor,
      name     => 'MTabs',
      delegations => [qw(Click)],
   );
   $self-> {mtabs}-> {mode} = 0;

   $self-> {plist} = $self-> {monger}-> insert_to_page( 0, OPropListViewer =>
      origin   => [ 0, 0],
      size     => [ 100, $sz[1] - $fh * 2],
      hScroll  => 1,
      name       => 'PList',
      growMode   => gm::Client,
   );

   $self-> {elist} = $self-> {monger}-> insert_to_page( 1, OPropListViewer =>
      origin   => [ 0, 0],
      size     => [ 100, $sz[1] - $fh * 2],
      hScroll  => 1,
      name       => 'EList',
      growMode   => gm::Client,
   );
   $self-> {currentList} = $self-> {'plist'};

   $self-> insert( Divider =>
      vertical => 1,
      origin => [ 100, 0],
      size   => [ 6, $sz[1] - $fh],
      min    => 50,
      max    => 50,
      name   => 'Div',
      delegations => [qw(Change)],
   );

   $self-> {panel} = $self-> insert( Notebook =>
      origin    => [ 106, 0],
      size      => [ $sz[0]-106, $sz[1] - $fh],
      growMode  => gm::Right,
      name      => 'Panel',
      pageCount => 1,
   );
   $self-> {panel}->{pages} = {};

   $self->{current} = undef;
   return %profile;
}

sub Div_Change
{
   my $self = $_[0];
   my $right = $self-> Div-> right;
   $self-> {monger}-> width( $self-> Div-> left);
   $self-> {mtabs}-> width( $self-> Div-> left);
   $self-> Panel-> set(
      width => $self-> width - $right,
      left  => $right,
   );
}

sub set_monger_index
{
   my ( $self, $ix) = @_;
   my $mtabs = $self->{mtabs};
   return if $ix == $mtabs-> {mode};
   $mtabs->{mode} = $ix;
   $mtabs-> text( $ix ? '~Properties' : '~Events');
   $self-> {monger}-> pageIndex( $ix);
   $self-> {currentList} = $self-> { $ix ? 'elist' : 'plist' };
   $self-> close_item;
   $self-> open_item;
}

sub MTabs_Click
{
   my ( $self, $mtabs) = @_;
   $self-> set_monger_index( $mtabs-> {mode} ? 0 : 1);
}

sub Selector_Change
{
   my $self = $_[0];
   return if $self->{selectorChanging};
   return unless $VB::form;
   my $t = $self-> Selector-> text;
   return unless length( $t);
   $self->{selectorRetrieving} = 1;
   my $enter;
   if ( $t eq $VB::form-> text) {
      $VB::form-> focus;
      $enter = $VB::form;
   } else {
      my @f = $VB::form-> widgets;
      for ( @f) {
         $enter = $_, $_-> show, $_->focus, last if $t eq $_->name;
      }
   }
   if ( $enter) {
      $enter-> marked(1,1);
      ObjectInspector::enter_widget( $enter);
   }
   $self->{selectorRetrieving} = 0;
}


sub item_changed
{
   my  $self = $VB::inspector;
   return unless $self;
   return unless $self-> {opened};
   return if $self-> {sync};
   if ( $self-> {opened}-> valid) {
      if ( $self-> {opened}-> can( 'get')) {
         $self-> {sync} = 1;
         my $data = $self-> {opened}-> get;
         $self->{opened}->{widget}->prf_set( $self->{opened}->{id} => $data);
         my $list = $self-> {currentList};
         my $ix = $list-> {index}->{$self->{opened}->{id}};
         unless ( $list-> {check}->[$ix]) {
            $list-> {check}->[$ix] = 1;
            $list-> redraw_items( $ix);
         }
         $self->{sync} = undef;
      }
   }
}

sub widget_changed
{
   my ( $how, $id) = @_;
   my $self = $VB::inspector;
   return unless $self;
   if ( $self-> {opened}) {
      if ( $id eq $self->{opened}->{id}) {
         return if $self-> {sync};
         $self-> {sync} = 1;
         my $data = $self-> {opened}-> {widget}-> prf( $id);
         $self-> {opened}-> set( $data);
         $self-> {sync} = undef;
      }   
   }
   my $list = $self-> {currentList};
   my $ix = $list->{index}->{$id};
   if ( $list-> {check}->[$ix] == $how) {
      $list-> {check}->[$ix] = $how ? 0 : 1;
      $list-> redraw_items( $ix);
   }
}


sub close_item
{
   my $self = $_[0];
   return unless defined $self->{opened};
   $self->{lastOpenedId} = $self->{opened}->{id};
   $self->{opened} = undef;
}

sub open_item
{
   my $self = $_[0];
   return if defined $self->{opened};
   my $list = $self->{currentList};
   my $f = $list-> focusedItem;

   if ( $f < 0) {
      $self->{panel}->pageIndex(0);
      return;
   }
   my $id   = $list->{id}->[$f];
   my $type = $VB::main-> get_typerec( $self->{current}-> {types}->{$id});
   my $p = $self->{panel};
   my $pageset;
   if ( exists $p->{pages}->{$type}) {
      $self-> {opened} = $self->{typeCache}->{$type};
      $pageset = $p->{pages}->{$type};
      $self-> {opened}-> renew( $id, $self-> {current});
   } else {
      $p-> pageCount( $p-> pageCount + 1);
      $p-> pageIndex( $p-> pageCount - 1);
      $p->{pages}->{$type} = $p-> pageIndex;
      $self-> {opened} = $type-> new( $p, $id, $self-> {current});
      $self-> {typeCache}->{$type} = $self-> {opened};
   }
   my $data = $self-> {current}-> prf( $id);
   $self-> {sync} = 1;
   $self-> {opened}-> set( $data);
   $self-> {sync} = undef;
   $p-> pageIndex( $pageset) if defined $pageset;
   $self-> {lastOpenedId} = undef;
}


sub enter_widget
{
   return unless $VB::inspector;
   my ( $self, $w) = ( $VB::inspector, $_[0]);
   if ( defined $w) {
      return if defined $self-> {current} and $self-> {current} == $w;
   } else {
      return unless defined $self-> {current};
   }
   my $oid = $self->{opened}->{id} if $self->{opened};
   $oid = $self-> {lastOpenedId} unless defined $oid;
   $self-> {current} = $w;

   if ( $self-> {current}) {
      my %df = %{$_[0]->{default}};
      my $pf = $_[0]->{profile};
      my @ef = sort keys %{$self->{current}-> {events}};
      my $ep = $self-> {elist};
      my $num = 0;
      my @check = ();
      my %ix = ();
      for ( @ef) {
         push( @check, exists $pf->{$_} ? 1 : 0);
         $ix{$_} = $num++;
         delete $df{$_};
      }
      $ep-> reset_items( [@ef], [@check], {%ix});
      $ep-> focusedItem( $ix{$oid}) if defined $oid and defined $ix{$oid};

      my $lp = $self-> {plist};
      @ef = sort keys %df;
      %ix = ();
      @check = ();
      $num = 0;
      for ( @ef) {
         push( @check, exists $pf->{$_} ? 1 : 0);
         $ix{$_} = $num++;
      }
      $lp-> reset_items( [@ef], [@check], {%ix});
      $lp-> focusedItem( $ix{$oid}) if defined $oid and defined $ix{$oid};

      $self-> Selector-> text( $self-> {current}-> name)
         unless $self->{selectorRetrieving};
      $self-> open_item;
   } else {
      $self-> {panel}-> pageIndex(0);
      for ( qw( plist elist)) {
         my $p = $self-> {$_};
         $p-> {check} = [];
         $p-> {index} = {};
         $p-> set_count(0);
      }
      $self-> Selector-> text( '');
   }
}

sub renew_widgets
{
   return unless $VB::inspector;
   return if $VB::inspector->{selectorChanging};
   $VB::inspector->{selectorChanging} = 1;
   $VB::inspector-> close_item;
   if ( $VB::form) {
      my @f = ( $VB::form, $VB::form-> widgets);
      $_ = $_->name for @f;
      $VB::inspector-> Selector-> items( \@f);
      my $fx = $VB::form-> focused ? $VB::form : $VB::form-> selectedWidget;
      $fx = $VB::form unless $fx;
      enter_widget( $fx);
   } else {
      $VB::inspector-> Selector-> items( ['']);
      $VB::inspector-> Selector-> text( '');
      enter_widget(undef);
   }
   $VB::inspector->{selectorChanging} = undef;
}

sub preload
{
   my $self = $VB::inspector;
   my $l = $self-> {plist};
   my $cnt = $l-> count;
   $self->{panel}->hide;
   $l->hide;
   $l->focusedItem( $cnt) while $cnt-- > 0;
   $l->show;
   $self->{panel}->show;
}

sub on_destroy
{
   $VB::inspector = undef;
   $VB::main-> {ini}-> {ObjectInspectorRect} = join( ' ', $_[0]-> rect);
}

package Form;
use vars qw(@ISA);
@ISA = qw( Prima::Window Prima::VB::Window);

{
my %RNT = (
   %{Prima::Window->notification_types()},
   Load => nt::Default,
);

sub notification_types { return \%RNT; }
}


sub profile_default
{
   my $def = $_[ 0]-> SUPER::profile_default;
   my %prf = (
      sizeDontCare   => 0,
      originDontCare => 0,
      width          => 300,
      height         => 200,
      centered       => 1,
      class          => 'Prima::Window',
      module         => 'Prima::Classes',
      selectable     => 1,
      mainEvent      => 'onMouseClick',
      popupItems     => $VB::main-> menu-> get_items( 'edit'),
      ownerIcon      => 0,
   );
   @$def{keys %prf} = values %prf;
   return $def;
}

sub init
{
   my $self = shift;
   my %profile = $self-> SUPER::init(@_);
   $profile{profile}->{name} = $self-> name;
   for ( qw( marked sizeable)) {
      $self->{$_}=0;
   };
   $self-> {dragMode} = 3;
   $self-> init_profiler( \%profile);
   $self-> {guidelineX} = $self-> width  / 2;
   $self-> {guidelineY} = $self-> height / 2;
   unless ( $self-> {syncRecting}) {
      $self-> {syncRecting} = $self;
      $self-> prf_set(
         origin => [$self-> origin],
         size   => [$self-> size],
         originDontCare => 0,
         sizeDontCare   => 0,
      );
      $self-> {syncRecting} = undef;
   }
   return %profile;
}

sub insert_new_control
{
   my ( $self, $x, $y, $where, %profile) = @_;
   my $class = exists($profile{class}) ? $profile{class} : $VB::main->{currentClass};
   my $xclass = $VB::main->{classes}->{$class}->{class};
   return unless defined $xclass;
   my $creatOrder = 0;
   my $wn = $where-> name;
   for ( $self-> widgets) {
      my $po = $_-> prf('owner');
      $po = $VB::form-> name unless length $po;
      next unless $po eq $wn;
      my $co = $_-> {creationOrder};
      $creatOrder++;
      next if $co < $creatOrder;
      $creatOrder = $co + 1;
   }
   my $j;
   my %prf = exists($profile{profile}) ? ( %{$profile{profile}}) : ();
   eval {
      eval "use $VB::main->{classes}->{$class}->{RTModule};";
      die "$@" if $@;
      $j = $self-> insert( $xclass,
         profile => {
            %prf,
            owner  => $wn,
            origin => [$x-4,$y-4],
         },
         class         => $class,
         module        => $VB::main->{classes}->{$class}->{RTModule},
         creationOrder => $creatOrder,
      );
      $j-> {realClass} = $profile{realClass} if exists $profile{realClass};
   };
   $VB::main->{currentClass} = undef unless exists $profile{class};
   if ( $@) {
      Prima::MsgBox::message( "Error:$@");
      return;
   }

   $self->{modified} = 1;

   unless ( $profile{manualSelect}) {
      $j-> select;
      $j-> marked(1,1);
      ObjectInspector::enter_widget( $j);
   }
   return $j;
}

sub on_paint
{
   my ( $self, $canvas) = @_;
   $canvas-> backColor( $self-> backColor);
   $canvas-> color( cl::Blue);
   $canvas-> fillPattern([0,0,0,0,4,0,0,0]);
   my @sz = $canvas-> size;
   $canvas-> bar(0,0,@sz);
   $canvas-> fillPattern( fp::Solid);
   $canvas-> linePattern( lp::Dash);
   $canvas-> line( $self-> {guidelineX}, 0, $self-> {guidelineX}, $sz[1]);
   $canvas-> line( 0, $self-> {guidelineY}, $sz[0], $self-> {guidelineY});
}

sub on_move
{
   my ( $self, $ox, $oy, $x, $y) = @_;
   return if $self-> {syncRecting};
   $self-> {syncRecting} = $self;
   $self-> prf_set(
      origin => [$x, $y],
      originDontCare => 0,
   );
   $self-> {syncRecting} = undef;
   $self-> {profile}->{left} = $x;
   $self-> {profile}->{bottom} = $y;
}

sub on_size
{
   my ( $self, $ox, $oy, $x, $y) = @_;
   return if $self-> {syncRecting};
   $self-> {syncRecting} = $self;
   $self-> prf_set(
      size => [$x, $y],
      sizeDontCare => 0,
   );
   $self-> {syncRecting} = undef;
   $self-> {profile}->{width} = $x;
   $self-> {profile}->{height} = $y;
}

sub on_close
{
   my $self = $_[0];
   if ( $self->{modified}) {
      my $name = defined ( $VB::main->{fmName}) ? $VB::main->{fmName} : 'Untitled';
      my $r = Prima::MsgBox::message( "Save changes to $name?", mb::YesNoCancel|mb::Warning);
      if ( $r == mb::Yes) {
         $self-> clear_event, return unless $VB::main-> save;
         $self->{modified} = undef;
      } elsif ( $r == mb::Cancel) {
         $self-> clear_event;
      } else {
         $self->{modified} = undef;
      }
   }
}

sub on_destroy
{
   if ( $VB::form && ( $VB::form == $_[0])) {
      $VB::form = undef;
      if ( defined $VB::main) {
         $VB::main->{fmName} = undef;
         $VB::main->update_menu();
         $VB::main->update_markings();
      }
      $VB::main-> {ini}-> {ObjectInspectorRect} = join( ' ', $_[0]-> rect);
   }
   ObjectInspector::renew_widgets;
}

sub veil
{
   my $self = $_[0];
   $::application-> begin_paint;
   my @r = ( @{$self->{anchor}}, @{$self->{dim}});
   ( $r[0], $r[2]) = ( $r[2], $r[0]) if $r[2] < $r[0];
   ( $r[1], $r[3]) = ( $r[3], $r[1]) if $r[3] < $r[1];
   @r = $self-> client_to_screen( @r);
   $::application-> clipRect( $self-> client_to_screen( 0,0,$self-> size));
   $::application-> rect_focus( @r, 1);
   $::application-> end_paint;
}


sub on_mousedown
{
   my ( $self, $btn, $mod, $x, $y) = @_;
   return if $self-> {transaction};
   if ( $btn == mb::Left) {
      unless ( $self-> {transaction}) {
         if ( abs( $self-> {guidelineX} - $x) < 3) {
            $self-> capture(1, $self);
            $self->{saveHdr} = $self-> text;
            $self-> {transaction} = ( abs( $self-> {guidelineY} - $y) < 3) ? 4 : 2;
            return;
         } elsif ( abs( $self-> {guidelineY} - $y) < 3) {
            $self-> {transaction} = 3;
            $self-> capture(1, $self);
            $self->{saveHdr} = $self-> text;
            return;
         }
      }

      if ( defined $VB::main->{currentClass}) {
         $self-> insert_new_control( $x, $y, $self);
      } else {
         $self-> focus;
         $self-> marked(0,1);
         $self-> update_view;
         $self-> {transaction} = 1;
         $self-> capture(1);
         $self-> {anchor} = [ $x, $y];
         $self-> {dim}    = [ $x, $y];
         $self-> veil;
         ObjectInspector::enter_widget( $self);
      }
   }
}

sub on_mousemove
{
   my ( $self, $mod, $x, $y) = @_;
   unless ( $self-> {transaction}) {
      if ( abs( $self-> {guidelineX} - $x) < 3) {
         $self-> pointer(( abs( $self-> {guidelineY} - $y) < 3) ? cr::Move : cr::SizeWE);
      } elsif ( abs( $self-> {guidelineY} - $y) < 3) {
         $self-> pointer( cr::SizeNS);
      } else {
         $self-> pointer( cr::Arrow);
      }
      return;
   }
   if ( $self-> {transaction} == 1) {
      return if $self-> {dim}->[0] == $x && $self-> {dim}->[1] == $y;
      $self-> veil;
      $self-> {dim} = [ $x, $y];
      $self-> veil;
      return;
   }

   if ( $self-> {transaction} == 2) {
      $self-> {guidelineX} = $x;
      $self-> text( $x);
      $self-> repaint;
      return;
   }

   if ( $self-> {transaction} == 3) {
      $self-> {guidelineY} = $y;
      $self-> text( $y);
      $self-> repaint;
      return;
   }

   if ( $self-> {transaction} == 4) {
      $self-> {guidelineY} = $y;
      $self-> {guidelineX} = $x;
      $self-> text( "$x:$y");
      $self-> repaint;
      return;
   }

}


sub on_mouseup
{
   my ( $self, $btn, $mod, $x, $y) = @_;
   return unless $self-> {transaction};
   return unless $btn == mb::Left;

   $self-> capture(0);
   if ( $self-> {transaction} == 1) {
      $self-> veil;
      my @r = ( @{$self->{anchor}}, @{$self->{dim}});
      ( $r[0], $r[2]) = ( $r[2], $r[0]) if $r[2] < $r[0];
      ( $r[1], $r[3]) = ( $r[3], $r[1]) if $r[3] < $r[1];
      $self-> {transaction} = $self->{anchor} = $self->{dim} = undef;

      for ( $self-> widgets) {
         my @x = $_-> rect;
         next if $x[0] < $r[0] || $x[1] < $r[1] || $x[2] > $r[2] || $x[3] > $r[3];
         $_-> marked(1);
      }
      return;
   }

   if ( $self-> {transaction} > 1 && $self-> {transaction} < 5) {
      $self-> {transaction} = undef;
      $self-> text( $self->{saveHdr});
      return;
   }
}

sub on_leave
{
   $_[0]-> notify(q(MouseUp), mb::Left, 0, 0, 0) if $_[0]-> {transaction};
}

sub dragMode
{
   if ( $#_) {
      my ( $self, $dm) = @_;
      return if $dm == $self->{dragMode};
      $dm = 1 if $dm > 3 || $dm < 1;
      $self->{dragMode} = $dm;
   } else {
      return $_[0]->{dragMode};
   }
}

sub dm_init
{
   my ( $self, $widget) = @_;
   my $cr;
   if ( $self-> {dragMode} == 1) {
      $cr = cr::SizeWE;
   } elsif ( $self-> {dragMode} == 2) {
      $cr = cr::SizeNS;
   } else {
      $cr = cr::Move;
   }
   $widget-> pointer( $cr);
}

sub dm_next
{
   my ( $self, $widget) = @_;
   $self-> dragMode( $self-> dragMode + 1);
   $self-> dm_init( $widget);
}

sub fm_resetguidelines
{
   my $self = $VB::form;
   return unless $self;
   $self-> {guidelineX} = $self-> width  / 2;
   $self-> {guidelineY} = $self-> height / 2;
   $self-> repaint;
}

sub fm_reclass
{
   my $self = $VB::form;
   return unless $self;
   my @wijs = $VB::form-> marked_widgets;
   return unless scalar @wijs;
   my $cx = $wijs[0];
   $self = $cx if $cx;
   my $lab_text = 'Class name';
   $lab_text =  "Temporary class for ".$self->{realClass} if defined $self->{realClass};
   my $dlg = Prima::Dialog-> create(
      icon => $VB::ico,
      size => [ 429, 55],
      centered => 1,
      text => 'Change class',
   );
   my ( $i, $b, $l) = $dlg-> insert([ InputLine =>
      origin => [ 5, 5],
      size => [ 317, 20],
      text => $self->{class},
   ], [ Button =>
       origin => [ 328, 4],
       size => [ 96, 36],
       text => '~Change',
       onClick => sub { $dlg-> ok },
       default => 1,
   ], [ Label =>
       origin => [ 5, 28],
       autoWidth => 0,
       size => [ 317, 20],
       text => $lab_text,
   ]);
   if ( $dlg-> execute == cm::OK) {
      $self-> {class} = $i-> text;
      delete $self-> {realClass};
   }
   $dlg->  destroy;
}

sub marked_widgets
{
   my $self = $_[0];
   my @ret = ();
   for ( $self-> widgets) {
      push ( @ret, $_) if $_-> marked;
   }
   return @ret;
}

sub fm_subalign
{
   my $self = $VB::form;
   return unless $self;
   my ( $id) = @_;
   my @wijs = $VB::form-> marked_widgets;
   return unless scalar @wijs;
   $id ?
      $wijs[0]-> bring_to_front :
      $wijs[0]-> send_to_back;
}

sub fm_stepalign
{
   my $self = $VB::form;
   return unless $self;
   my ($id) = @_;
   my @wijs = $VB::form-> marked_widgets;
   return unless scalar @wijs;
   my $cx = $wijs[0];
   if ( $id) {
      my $cz = $cx-> prev;
      if ( $cz) {
         $cz = $cz-> prev;
         $cz ? $cx-> insert_behind( $cz) : $cx-> bring_to_front;
      }
   } else {
      my $cz = $cx-> next;
      $cx-> insert_behind( $cz) if $cz;
   }
}

sub fm_duplicate
{
   my $self = $VB::form;
   return unless $self;
   my @r = ();
   my %wjs  = map { $_->prf('name') => $_} ( $self, $self-> widgets);
   my @marked = $self-> marked_widgets;
   $self-> marked(0,1);

   for ( @marked) {
      my %prf = (
         class        => $_->{class},
         manualSelect => 1,
         profile      => $_->{profile},
      );
      $prf{realClass} = $_->{realClass} if defined $_->{realClass};
      my $j = $self-> insert_new_control( $_-> left + 14, $_-> bottom + 14, $wjs{$_->prf('owner')}, %prf);
      next unless $j;
      $j-> focus unless scalar @r;
      push ( @r, $j);
      $j-> marked(1,0);
   }
}

sub fm_selectall
{
   return unless $VB::form;
   $_-> marked(1) for $VB::form-> widgets;
}

sub fm_delete
{
   return unless $VB::form;
   $_-> destroy for $VB::form-> marked_widgets;
   ObjectInspector::renew_widgets();
}

sub fm_copy
{
   return if !$VB::form || ! scalar $VB::form-> marked_widgets;
   my $c = $VB::main-> write_form(1);
   $::application-> Clipboard-> text( $c);
}

sub fm_paste
{
   return unless $VB::form; 
   my @seq = $VB::main-> inspect_load_data( $::application-> Clipboard-> text, 0);
   return unless @seq;

   $VB::main-> wait;
   my $i;
   my %names  = map { $_-> prf('name') => 1 } ( $VB::form, $VB::form-> widgets);
   my $main   = $VB::form-> prf('name');
   my %keymap;
   my $classes = $VB::main->{classes};

   for ( $i = 0; $i < scalar @seq; $i+= 2) {
      my ( $key, $hash) = ( $seq[$i], $seq[$i + 1]); 
      
      # handling name clashes
      my $j = 0;
      $key = $seq[$i] . "_$j", $j++ while exists $names{$key};
      $keymap{$seq[$i]} = $key;
      $hash-> {profile}->{name} = $key;

      unless ( $classes->{$hash->{class}}) {
         $hash->{realClass} = $hash->{class};
         $hash->{class}     = 'Prima::Widget';
      }

      my $wclass = $classes->{$hash->{class}}-> {class};
      my %handleTypes = map { $_ => 1} @{$wclass-> prf_types-> {Handle}};
      for ( keys %{$hash-> {profile}}) {
         next unless exists $handleTypes{ $_};
         my $mapv = $keymap{$hash->{profile}->{$_}};
         $mapv = $main unless defined $mapv;
         $hash->{profile}->{$_} = defined($mapv) ? $mapv : $main;
      }
      $seq[$i] = $key;
   }

   $VB::form-> marked(0,1);
   @seq = $VB::main-> push_widgets( @seq);
   ObjectInspector::renew_widgets;
   $_-> notify(q(Load)) for @seq;
   $_-> marked( 1, 0) for @seq;
}


sub fm_creationorder
{
   my $self = $VB::form;
   return unless $self;

   my %cos;
   my @names = ();
   $cos{$_->{creationOrder}} = $_->name for $self-> widgets;
   push( @names, $cos{$_}) for sort {$a <=> $b} keys %cos;

   return unless scalar @names;

   my $d = Prima::Dialog-> create(
      icon => $VB::ico,
      origin => [ 358, 396],
      size => [ 243, 325],
      text => 'Creation order',
   );
   $d-> insert( [ Button =>
      origin => [ 5, 5],
      size => [ 96, 36],
      text => '~OK',
      default => 1,
      modalResult => cm::OK,
   ], [ Button =>
      origin => [ 109, 5],
      size => [ 96, 36],
      text => 'Cancel',
      modalResult => cm::Cancel,
   ], [ ListBox =>
      origin => [ 5, 48],
      name => 'Items',
      size => [ 199, 269],
      items => \@names,
      focusedItem => 0,
   ], [ SpeedButton =>
      origin => [ 209, 188],
      image => Prima::Icon->create( width=>13, height=>13, type => im::bpp1,
palette => [ 0,0,0,0,0,0],
 data =>
"\xff\xf8\x00\x00\x7f\xf0\x00\x00\x7f\xf0\x00\x00\?\xe0\x00\x00\?\xe0\x00\x00".
"\x1f\xc0\x00\x00\x1f\xc0\x00\x00\x0f\x80\x00\x00\x0f\x80\x00\x00\x07\x00\x00\x00".
"\x07\x00\x00\x00\x02\x00\x00\x00\x02\x00\x00\x00".
''),
       size => [ 29, 130],
       onClick => sub {
          my $i  = $d-> Items;
          my $fi = $i-> focusedItem;
          return if $fi < 1;
          my @i = @{$i-> items};
          @i[ $fi - 1, $fi] = @i[ $fi, $fi - 1];
          $i-> items( \@i);
          $i-> focusedItem( $fi - 1);
       },
    ], [ SpeedButton =>
       origin => [ 209, 48],
       image => Prima::Icon->create( width=>13, height=>13, type => im::bpp1,
palette => [ 0,0,0,0,0,0],
 data =>
"\x02\x00\x00\x00\x02\x00\x00\x00\x07\x00\x00\x00\x07\x00\x00\x00\x0f\x80\x00\x00".
"\x0f\x80\x00\x00\x1f\xc0\x00\x00\x1f\xc0\x00\x00\?\xe0\x00\x00\?\xe0\x00\x00".
"\x7f\xf0\x00\x00\x7f\xf0\x00\x00\xff\xf8\x00\x00".
''),
       size => [ 29, 130],
       onClick => sub {
          my $i   = $d-> Items;
          my $fi  = $i-> focusedItem;
          my $c   = $i-> count;
          return if $fi >= $c - 1;
          my @i = @{$i-> items};
          @i[ $fi + 1, $fi] = @i[ $fi, $fi + 1];
          $i-> items( \@i);
          $i-> focusedItem( $fi + 1);
       },
    ]);
    if ( $d-> execute != cm::Cancel) {
       my $cord = 1;
       $self-> bring( $_)-> {creationOrder} = $cord++ for @{$d-> Items-> items};
    }
    $d-> destroy;
}

sub prf_icon
{
   $_[0]-> icon( $_[1]);
}


package MainPanel;
use vars qw(@ISA *do_layer);
@ISA = qw(Prima::Window);

sub profile_default
{
   my $def = $_[ 0]-> SUPER::profile_default;
   my %prf = (
      text           => $::application-> name,
      width          => $::application-> width - 12,
      left           => 6,
      bottom         => $::application-> height - 106 -
         $::application-> get_system_value(sv::YTitleBar) - $::application-> get_system_value(sv::YMenu),
      sizeDontCare   => 0,
      originDontCare => 0,
      height         => 100,
      icon           => $VB::ico,
      menuItems      => [
         ['~File' => [
            ['newitem' => '~New' => sub {$_[0]->new;}],
            ['openitem' => '~Open' => 'F3' => 'F3' => sub {$_[0]->open;}],
            ['-saveitem1' => '~Save' => 'F2' => 'F2' => sub {$_[0]->save;}],
            ['-saveitem2' =>'Save ~as...' =>           sub {$_[0]->saveas;}],
            ['closeitem' =>'~Close' =>           sub {$VB::form-> close if $VB::form}],
            [],
            ['E~xit' => 'Alt+X' => '@X' => sub{$_[0]->close;}],
         ]],
         ['edit' => '~Edit' => [
             ['Cop~y' => 'Ctrl+Ins' => km::Ctrl|kb::Insert => sub { Form::fm_copy(); }],
             ['~Paste' => 'Shift+Ins' => km::Shift|kb::Insert => sub { Form::fm_paste(); }],
             ['~Delete' => sub { Form::fm_delete(); } ], 
             ['~Select all' => sub { Form::fm_selectall(); }],
             ['D~uplicate'  => 'Ctrl+D' => '^D' => sub { Form::fm_duplicate(); }],
             [],
             ['~Align' => [
                ['~Bring to front' => 'Shift+PgUp' => km::Shift|kb::PgUp => sub { Form::fm_subalign(1);}],
                ['~Send to back'   => 'Shift+PgDn' => km::Shift|kb::PgDn => sub { Form::fm_subalign(0);}],
                ['Step ~forward'   => 'Ctrl+PgUp' => km::Ctrl|kb::PgUp => sub { Form::fm_stepalign(1);}],
                ['Step ~back'      => 'Ctrl+PgDn' => km::Ctrl|kb::PgDn => sub { Form::fm_stepalign(0);}],
             ]],
             ['~Change class...' => sub { Form::fm_reclass();}],
             ['Creation ~order' => sub { Form::fm_creationorder(); } ],
         ]],
         ['~View' => [
           ['~Object Inspector' => 'F11' => 'F11' => sub { $_[0]-> bring_inspector; }],
           ['~Add widgets...' => q(add_widgets)],
           [],
           ['Reset ~guidelines' => sub { Form::fm_resetguidelines(); } ],
           ['*gsnap' => 'Snap to guid~elines' => sub { $VB::main-> {ini}-> {SnapToGuidelines} = $VB::main-> menu-> toggle( 'gsnap') ? 1 : 0; } ],
           ['*dsnap' => 'Snap to gri~d'       => sub { $VB::main-> {ini}-> {SnapToGrid} = $VB::main-> menu-> toggle( 'dsnap') ? 1 : 0; } ],
           [],
           ['-runitem' => '~Run' => 'Ctrl+F9' => '^F9' => \&form_run ],
           ['-breakitem' => '~Break' => \&form_cancel ],
         ]],
      ],
   );
   @$def{keys %prf} = values %prf;
   return $def;
}

sub init
{
   my $self = shift;
   my %profile = $self-> SUPER::init(@_);

   my @r = ( $lite || $singleConfig) ?
      Prima::VB::CfgMaint::open_cfg :
      Prima::VB::CfgMaint::read_cfg;
   die "Error:$r[1]\n" unless $r[0];

   my %classes = %Prima::VB::CfgMaint::classes;
   my @pages   = @Prima::VB::CfgMaint::pages;

   $self-> set(
     sizeMin => [ 350, $self->height],
     sizeMax => [ 16384, $self->height],
   );

   $self->{newbutton} = $self-> insert( SpeedButton =>
      origin    => [ 4, $self-> height - 30],
      size      => [ 26, 26],
      hint      => 'New',
      imageFile => Prima::find_image( 'VB::VB.gif').':1',
      glyphs    => 2,
      onClick   => sub { $VB::main-> new; } ,
   );

   $self->{openbutton} = $self-> insert( SpeedButton =>
      origin    => [ 32, $self-> height - 30],
      size      => [ 26, 26],
      hint      => 'Open',
      imageFile => Prima::find_image( 'VB::VB.gif').':2',
      glyphs    => 2,
      onClick   => sub { $VB::main-> open; } ,
   );

   $self->{savebutton} = $self-> insert( SpeedButton =>
       origin    => [ 60, $self-> height - 30],
       size      => [ 26, 26],
       hint      => 'Save',
       imageFile => Prima::find_image( 'VB::VB.gif').':3',
       glyphs    => 2,
       onClick   => sub { $VB::main-> save; } ,
    );

   $self->{runbutton} = $self-> insert( SpeedButton =>
      origin    => [ 88, $self-> height - 30],
      size      => [ 26, 26],
      hint      => 'Run',
      imageFile => Prima::find_image( 'VB::VB.gif').':4',
      glyphs    => 2,
      onClick   => sub { $VB::main-> form_run} ,
   );


   $self-> {tabset} = $self-> insert( TabSet =>
      left   => 150,
      name   => 'TabSet',
      top    => $self-> height,
      width  => $self-> width - 150,
      growMode => gm::Ceiling,
      topMost  => 1,
      tabs     => [ @pages],
      buffered => 1,
      delegations => [qw(Change)],
   );

   $self-> {nb} = $self-> insert( Widget =>
      origin => [ 150, 0],
      size   => [$self-> width - 150, $self-> height - $self->{tabset}-> height],
      growMode => gm::Client,
      name    => 'TabbedNotebook',
      onPaint => sub {
         my ( $self, $canvas) = @_;
         my @sz = $self-> size;
         $canvas-> rect3d(0,0,$sz[0]-1,$sz[1],1,$self->light3DColor,$self->dark3DColor,$self->backColor);
      },
   );

   $self-> {nbpanel} = $self-> {nb}-> insert( Notebook =>
      origin     => [12,1],
      size       => [$self->{nb}->width-24,44],
      growMode   => gm::Floor,
      backColor  => cl::Gray,
      name       => 'NBPanel',
      onPaint    => sub {
         my ( $self, $canvas) = @_;
         my @sz = $self-> size;
         $canvas-> rect3d(0,0,$sz[0]-1,$sz[1]-1,1,cl::Black,cl::Black,$self->backColor);
         my $i = 0;
         $canvas-> rectangle($i-38,2,$i,40) while (($i+=40)<($sz[0]+36));
      },
   );

   $self-> {leftScroll} = $self-> {nb}-> insert( SpeedButton =>
      origin  => [1,5],
      size    => [11,36],
      name    => 'LeftScroll',
      autoRepeat => 1,
      onPaint => sub {
         $_[0]-> on_paint( $_[1]);
         $_[1]-> color( $_[0]-> enabled ? cl::Black : cl::Gray);
         $_[1]-> fillpoly([7,4,7,32,3,17]);
      },
      delegations => [ $self, qw(Click)],
   );

   $self-> {rightScroll} = $self-> {nb}-> insert( SpeedButton =>
      origin  => [$self-> {nb}-> width-11,5],
      size    => [11,36],
      name    => 'RightScroll',
      growMode => gm::Right,
      autoRepeat => 1,
      onPaint => sub {
         $_[0]-> on_paint( $_[1]);
         $_[1]-> color( $_[0]-> enabled ? cl::Black : cl::Gray);
         $_[1]-> fillpoly([3,4,3,32,7,17]);
      },
      delegations => [ $self, qw(Click)],
   );

   $self->{classes} = \%classes;
   $self->{pages}   = \@pages;
   $self->{gridAlert} = 5;
   
   my $home = ( defined $ENV{HOME}) ? $ENV{HOME} : '.';
   $self-> {iniFile} = Prima::IniFile-> create( 
      file    => $home . '/.vb',
      default => [
         'View' => [
            'SnapToGrid' => 1,
            'SnapToGuidelines' => 1,
            'ObjectInspectorVisible' => 1,
            'ObjectInspectorRect' => '-1 -1 -1 -1',
            'MainPanelRect' => '-1 -1 -1 -1',
            'OpenPath' => '.',
            'SavePath' => '.',
         ],
      ],
   );
   my $i = $self-> {ini} = $self-> {iniFile}-> section( 'View' );
   $self-> menu-> dsnap-> checked( $i-> {SnapToGrid});
   $self-> menu-> gsnap-> checked( $i-> {SnapToGuidelines});
   my @rx = split( ' ', $i->{MainPanelRect});
   $self-> rect( @rx) if scalar grep { $_ != -1 } @rx;
   return %profile;
}

sub on_create
{
   $_[0]-> reset_tabs;
}


sub on_close
{
   return unless $VB::form;
   $_[0]-> clear_event, return if !$VB::form->close;
}

sub on_destroy
{
   $_[0]-> {ini}-> {MainPanelRect} = join( ' ', $_[0]-> rect);
   my @rx = ( $_[0]-> {ini}-> {ObjectInspectorVisible} = ( $VB::inspector ? 1 : 0)) 
      ? $VB::inspector-> rect : ((-1)x4);
   $_[0]-> {ini}-> {ObjectInspectorRect} = join( ' ', @rx);
   $_[0]-> {ini}-> {OpenPath} = $openFileDlg-> directory if $openFileDlg;
   $_[0]-> {ini}-> {SavePath} = $saveFileDlg-> directory if $saveFileDlg;
   $VB::main = undef;
   $::application-> close;
}


sub reset_tabs
{
   my $self = $_[0];
   my $nb = $self->{nbpanel};
   $nb-> lock;
   $_-> destroy for $nb-> widgets;
   $self-> {tabset}-> tabs( $self->{pages});
   $self-> {tabset}-> tabIndex(0);
   $nb-> pageCount( scalar @{$self->{pages}});
   my %offsets = ();
   my %pagofs  = ();
   my %modules = ();
   my $i=0;
   $pagofs{$_} = $i++ for @{$self->{pages}};

   $modules{$self->{classes}->{$_}->{module}}=1 for keys %{$self->{classes}};

   for ( keys %modules) {
       my $c = $_;
       eval("use $c;");
       if ( $@) {
          Prima::MsgBox::message( "Error loading module $_:$@");
          $modules{$_} = 0;
       }
   }

   my %iconfails = ();
   my %icongtx   = ();
   for ( keys %{$self->{classes}}) {
      my ( $class, %info) = ( $_, %{$self->{classes}->{$_}});
      $offsets{$info{page}} = 4 unless exists $offsets{$info{page}};
      next unless $modules{$info{module}};
      my $i = undef;
      if ( $info{icon}) {
         $info{icon} =~ s/\:(\d+)$//;
         my @parms = ( Prima::find_image( $info{icon}));
         push( @parms, 'index', $1) if defined $1;
         $i = Prima::Icon-> create;
         unless ( defined $parms[0] && $i-> load( @parms)) {
            $iconfails{$info{icon}} = 1;
            $i = undef;
         }
      };
      my $j = $nb-> insert_to_page( $pagofs{$info{page}}, SpeedButton =>
         hint   => $class,
         name   => 'ClassSelector',
         image  => $i,
         origin => [ $offsets{$info{page}}, 4],
         size   => [ 36, 36],
         delegations => [$self, qw(Click)],
      );
      $j->{orgLeft}   = $offsets{$info{page}};
      $j->{className} = $class;
      $offsets{$info{page}} += 40;
   }
   $self->{nbIndex} = 0;
   $nb-> unlock;
   $self->{currentClass} = undef;

   if ( scalar keys %iconfails) {
      my @x = keys %iconfails;
      Prima::MsgBox::message( "Error loading images: @x");
   }
}

sub add_widgets
{
   my $self = $_[0];
   my $d = VB::open_dialog(
      filter => [['Packages' => '*.pm'], [ 'All files' => '*']],
   );
   return unless $d-> execute;
   my @r = Prima::VB::CfgMaint::add_package( $d-> fileName);
   Prima::MsgBox::message( "Error:$r[1]"), return unless $r[0];
   $self->{classes} = {%Prima::VB::CfgMaint::classes};
   $self->{pages}   = [@Prima::VB::CfgMaint::pages];
   $self-> reset_tabs;
   @r = Prima::VB::CfgMaint::write_cfg;
   Prima::MsgBox::message( "Error: $r[1]"), return unless $r[0];
}

sub get_nbpanel_count
{
   return $_[0]->{nbpanel}->widgets_from_page($_[0]->{nbpanel}->pageIndex);
}

sub set_nbpanel_index
{
   my ( $self, $idx) = @_;
   return if $idx < 0;
   my $nb  = $self->{nbpanel};
   my @wp  = $nb-> widgets_from_page( $nb-> pageIndex);
   return if $idx >= scalar @wp;
   for ( @wp) {
      $_->left( $_->{orgLeft} - $idx * 40);
   }
   $self->{nbIndex} = $idx;
}

sub LeftScroll_Click
{
   $_[0]-> set_nbpanel_index( $_[0]->{nbIndex} - 1);
}

sub RightScroll_Click
{
   $_[0]-> set_nbpanel_index( $_[0]->{nbIndex} + 1);
}

sub ClassSelector_Click
{
   $_[0]->{currentClass} = $_[1]-> {className};
}


sub TabSet_Change
{
   my $self = $_[0];
   my $nb = $self->{nbpanel};
   $nb-> pageIndex( $_[1]-> tabIndex);
   $self-> set_nbpanel_index(0);
}


sub get_typerec
{
   my ( $self, $type, $valPtr) = @_;
   unless ( defined $type) {
      my $rwx = 'generic';
      if ( defined $valPtr && defined $$valPtr) {
         if ( ref($$valPtr)) {
            if (( ref($$valPtr) eq 'ARRAY') || ( ref($$valPtr) eq 'HASH')) {
            } elsif ( $$valPtr->isa('Prima::Icon')) {
               $rwx = 'icon';
            } elsif ( $$valPtr->isa('Prima::Image')) {
               $rwx = 'image';
            }
         }
      }
      return "Prima::VB::Types::$rwx";
   }
   $self-> {typerecs} = () unless exists $self-> {typerecs};
   my $t = $self-> {typerecs};
   return $t->{$type} if exists $t->{type};
   my $ns = \%Prima::VB::Types::;
   my $rwx = exists $ns->{$type.'::'} ? $type : 'generic';
   $rwx = 'Prima::VB::Types::'.$rwx;
   $t->{$type} = $rwx;
   return $rwx;
}

sub new
{
   my $self = $_[0];
   return if $VB::form and !$VB::form-> close;
   $VB::form = Form-> create;
   $VB::main->{fmName} = undef;
   ObjectInspector::renew_widgets;
   update_menu();
}

sub inspect_load_data
{
   my ($self, $data, $asFile) = @_; 
   my @preload_modules;
   
   my $fn = ( $asFile ? $data : "input data");
   if ( $asFile) {
      unless (CORE::open( F, $data)) {
         Prima::MsgBox::message( "Error loading " . $data);
         return;
      }
      local $/;
      $data = <F>;
      close F;
   }

   my @d = split( "\n", $data);
   undef $data;
   
   
   if ( !defined($d[0]) || !($d[0] =~ /^# VBForm/ )) {
INV:   
      Prima::MsgBox::message("Invalid format of $fn");
      return;
   }

   my @fvc = Prima::VB::VBLoader::check_version( $d[0]);
   Prima::MsgBox::message("Incompatible file format version ($fvc[1]) of $fn.\nBugs possible!",
      mb::Warning|mb::OK) unless $fvc[0];

   shift @d;
   my $i;
   for ( $i = 0; $i < scalar @d; $i++) {
      last unless $d[$i] =~ /^#/;
      next unless $d[$i] =~ /^#\s*\[([^\]]+)\](.*)$/;
      if ( $1 eq 'preload') { 
         push( @preload_modules, split( ' ', $2)); 
      }
   }
   goto INV if $i >= scalar @d;

   for ( @preload_modules) {
      eval "use $_;";
      next unless $@;
      Prima::MsgBox::message( "Error loading module $_:$@");
      return;
   }
   my $sub = eval( join( "\n", @d[$i..$#d]));

   if ( $@ || ref($sub) ne 'CODE') {
      Prima::MsgBox::message("Error loading $fn:$@");
      return;
   }
   
   return $sub-> ();
}

sub preload_modules
{
   my $self = shift;
   

}

sub push_widgets
{
   my $self     = shift;
   my $classes = $self->{classes};
   my $callback = shift if $_[0] && ref($_[0]) eq 'CODE';
   
   my @seq = @_;
   my $main = $VB::form-> prf('name');
   my %owners  = ( $main => '');
   my %widgets = ( $main => $VB::form);
   my @return;
   my %dep;
   my $i;

   for ( $i = 0; $i < scalar @seq; $i+= 2) {
      $dep{$seq[$i]} = $seq[$i + 1];
   }

   for ( keys %dep) {
      $owners{$_} = exists $dep{$_}->{profile}->{owner} ? $dep{$_}->{profile}->{owner} : $main;
   }
   
   local *do_layer = sub
   {
      my $id = $_[0];
      my $i;
      for ( $i = 0; $i < scalar @seq; $i += 2) {
         $_ = $seq[$i];
         next unless $owners{$_} eq $id;
         eval "use $dep{$_}->{module};";
         Prima::message("Error loading $dep{$_}->{module}:$@"), next if "$@";
         my $c = $VB::form-> insert(
            $classes->{$dep{$_}->{class}}->{class},
            realClass     => $dep{$_}->{realClass},
            class         => $dep{$_}->{class},
            module        => $dep{$_}->{module},
            extras        => $dep{$_}->{extras},
            creationOrder => $i / 2,
         );
         push ( @return, $c);
         if ( exists $dep{$_}->{profile}->{origin}) {
            my @norg = @{$dep{$_}->{profile}->{origin}};
            unless ( exists $widgets{$owners{$_}}) {
               # validating owner entry
               $owners{$_} = $main;
               $dep{$_}->{profile}->{owner} = $main;
            }
            my @ndelta = $owners{$_} eq $main ? (0,0) : (
              $widgets{$owners{$_}}-> left,
              $widgets{$owners{$_}}-> bottom
            );
            $norg[$_] += $ndelta[$_] for 0..1;
            $dep{$_}->{profile}->{origin} = \@norg;
         }
         $c-> prf_set( %{$dep{$_}->{profile}});
         $widgets{$_} = $c;
         $callback-> ( $self) if $callback;
         &do_layer( $_);
      }
   };
   &do_layer( $main, \%owners);
   return @return;
}

sub load_file
{
   my ($self,$fileName) = @_;

   $VB::form-> destroy if $VB::form;
   $VB::form = undef;
   update_menu();

   my @seq = $self-> inspect_load_data( $fileName, 1);
   return unless @seq;
   
   $self->{fmName} = $fileName;

   $VB::main-> wait;
   my ( $i, $mf, $main, $fmindex);
   my $classes = $self->{classes};
   
   for ( $i = 0; $i < scalar @seq; $i+= 2) {
      my $hash = $seq[$i + 1];
      if ( $hash-> {parent}) {
         $main = $seq[$i];
         $mf   = $seq[$i+1];
         $fmindex = $i;
      }
      unless ( $classes->{$hash->{class}}) {
         $hash->{realClass} = $hash->{class};
         $hash->{class}     = $hash->{parent} ? 'Prima::Window' : 'Prima::Widget';
      }
   }

   defined($main) ? 
      splice( @seq, $fmindex, 2) :
      ( $main = 'Form1', $mf = {});

   my $oldtxt = $self-> text;
   my $maxwij = scalar(@seq) / 2;
   $self-> text( "Loading...");

   $VB::form = Form-> create(
      realClass   => $mf->{realClass},
      class       => $mf->{class},
      module      => $mf->{module},
      extras      => $mf->{extras},
      creationOrder => 0,
      visible     => 0,
   );
   $VB::form-> prf_set( %{$mf->{profile}});
   $VB::inspector->{selectorChanging} = 1 if $VB::inspector;
   my $loaded = 1;
   $self-> push_widgets( sub {
     $loaded++;
     $self-> text( sprintf( "Loaded %d%%", ($loaded / $maxwij) * 100)); 
   }, @seq);
   $VB::form-> show;
   $VB::inspector->{selectorChanging}-- if $VB::inspector;
   ObjectInspector::renew_widgets;
   update_menu();
   $self-> text( $oldtxt);
   $VB::form-> notify(q(Load));
   $_-> notify(q(Load)) for $VB::form-> widgets;
}

sub open
{
   my $self = $_[0];

   return if $VB::form and !$VB::form-> can_close;

   my $d = VB::open_dialog(
      filter => [['Form files' => '*.fm'], [ 'All files' => '*']],
   );
   return unless $d-> execute;
   $self-> load_file( $d-> fileName);
}

sub write_form
{
   my ( $self, $partialExport) = @_;

   my @cmp = $partialExport ? 
      $VB::form-> marked_widgets : $VB::form-> widgets;
   my %preload_modules;

   my $header = <<PREHEAD;
# VBForm version file=$Prima::VB::VBLoader::fileVersion builder=$VBVersion
PREHEAD

   my $c = <<STARTSUB;
sub
{
\treturn (
STARTSUB

   my $main = $VB::form-> prf( 'name');
   push( @cmp, $VB::form) unless $partialExport;
   @cmp = sort { $a->{creationOrder} <=> $b->{creationOrder}} @cmp;

   for ( @cmp) {
      my ( $class, $module) = @{$_}{'class','module'};
      $class = $_->{realClass} if defined $_->{realClass};
      my $types = $_->{types};
      my $name = $_-> prf( 'name');
      $c .= <<MEDI;
\t'$name' => {
\t\tclass   => '$class',
\t\tmodule  => '$module',
MEDI
      $c .= "\t\tparent => 1,\n" if $_ == $VB::form;
      my %extras    = $_-> ext_profile;
      if ( scalar keys %extras) {
          $c .= "\t\textras => {\n";
          for ( keys %extras) {
              my $val  = $extras{$_};
              my $type = $self-> get_typerec( $types->{$_}, \$val);
              $val = defined($val) ? $type-> write( $_, $val) : 'undef';
              $c .= "\t\t$_ => $val,\n";
          }
          $c .= "\t\t},\n";
      }
      %extras    = $_-> act_profile;
      if ( scalar keys %extras) {
          $c .= "\t\tactions => {\n";
          for ( keys %extras) {
              my $val  = $extras{$_};
              my $type = $self-> get_typerec( $types->{$_}, \$val);
              $val = defined($val) ? $type-> write( $_, $val) : 'undef';
              $c .= "\t\t$_ => $val,\n";
          }
          $c .= "\t\t},\n";
      }
      $c .= "\t\tprofile => {\n";
      my ( $x,$prf) = ($_, $_->{profile});
      my @o = $_-> get_o_delta;
      for( keys %{$prf}) {
         my $val = $prf->{$_};
         if ( $_ eq 'origin' && defined $val) {
            my @nval = (
               $$val[0] - $o[0],
               $$val[1] - $o[1],
            );
            $val = \@nval;
         }
         my $type = $self-> get_typerec( $types->{$_}, \$val);
         $val = defined($val) ? $type-> write( $_, $val) : 'undef';
         $preload_modules{$_} = 1 for $type-> preload_modules();
         $c .= "\t\t\t$_ => $val,\n";
      }
      $c .= "\t}},\n";
   }

$c .= <<POSTHEAD;
\t);
}
POSTHEAD
   $header .= '# [preload] ' . join( ' ', sort keys %preload_modules) . "\n";
   return $header . $c;
}

sub write_PL
{
   my $self = $_[0];
   my $main = $VB::form-> prf( 'name');
   my @cmp = $VB::form-> widgets;

   my $header = <<PREPREHEAD;
use Prima;
use Prima::Classes;
PREPREHEAD

   my %modules = map { $_->{module} => 1 } @cmp;
   
   my $c = <<PREHEAD;

package ${main}Window;
use vars qw(\@ISA);
\@ISA = qw(Prima::Window);

sub profile_default
{
   my \$def = \$_[ 0]-> SUPER::profile_default;
   my \%prf = (
PREHEAD
   my $prf   = $VB::form->{profile};
   my $types = $VB::form->{types};
   for ( keys %$prf) {
      my $val = $prf->{$_};
      my $type = $self-> get_typerec( $types->{$_}, \$val);
      $val = defined($val) ? $type-> write( $_, $val, 1) : 'undef';
      $c .= "       $_ => $val,\n";
   }
   my @ds = ( $::application-> font-> width, $::application-> font-> height);
   $c .= "       designScale => [ $ds[0], $ds[1]],\n";
   $c .= <<HEAD2;
   );
   \@\$def{keys \%prf} = values \%prf;
   return \$def;
}

HEAD2

   my @actNames  = qw( onBegin onFormCreate onCreate onChild onChildCreate onEnd);
   my %actions   = map { $_ => {}} @actNames;
   my @initInstances;
   for ( @cmp, $VB::form) {
      my $key = $_-> prf('name');
      my %act = $_-> act_profile;
      next unless scalar keys %act;
      push ( @initInstances, $key);
      for ( @actNames) {
         next unless exists $act{$_};
         my $aname = "${_}_$key";
         $actions{$_}->{$key} = $aname;
         my $asub = join( "\n   ", split( "\n", $act{$_}));
         $c .= "sub $aname {\n   $asub\n}\n\n";
      }
   }
   $c .= <<HEAD3;
sub init
{
   my \$self = shift;
   my \%instances = map {\$_ => {}} qw(@initInstances);
HEAD3
   for ( @initInstances) {
      my $obj = ( $_ eq $main) ? $VB::form : $VB::form-> bring($_);
      my %extras = $obj-> ext_profile;
      next unless scalar keys %extras;
      $c .= "   \$instances{$_}->{extras} = {\n";
      for ( keys %extras) {
          my $val  = $extras{$_};
          my $type = $self-> get_typerec( $types->{$_}, \$val);
          $val = defined($val) ? $type-> write( $_, $val) : 'undef';
          $c .= "      $_ => $val,\n";
      }
      $c .= "   };\n";
   }

   $c .= '   '.$actions{onBegin}->{$_}."(q($_), \$instances{$_});\n"
      for keys %{$actions{onBegin}};
   $c .= <<HEAD4;
   my \%profile = \$self-> SUPER::init(\@_);
   my \%names   = ( q($main) => \$self);
   \$self-> lock;
HEAD4
   @cmp = sort { $a->{creationOrder} <=> $b->{creationOrder}} @cmp;
   my %names = (
      $main => 1
   );
   my @re_cmp = ();

   $c .= '   '.$actions{onFormCreate}->{$_}."(q($_), \$instances{$_}, \$self);\n"
      for keys %{$actions{onFormCreate}};
   $c .= '   '.$actions{onCreate}->{$main}."(q($main), \$instances{$main}, \$self);\n"
      if $actions{onCreate}->{$main};
AGAIN:
   for ( @cmp) {
      my $owner = $_->prf('owner');
      unless ( $names{$owner}) {
         push @re_cmp, $_;
         next;
      }
      my ( $class, $module) = @{$_}{'class','module'};
      $class = $_->{realClass} if defined $_->{realClass};
      my $types = $_->{types};
      my $name = $_-> prf( 'name');
      $names{$name} = 1;

      $c .= '   '.$actions{onChild}->{$owner}."(q($owner), \$instances{$owner}, \$names{$owner}, q($name));\n"
         if $actions{onChild}->{$owner};

      $c .= "   \$names{$name} = \$names{$owner}-> insert( qq($class) => \n";
      my ( $x,$prf) = ($_, $_->{profile});
      my @o = $_-> get_o_delta;
      for ( keys %{$prf}) {
         my $val = $prf->{$_};
         if ( $_ eq 'origin' && defined $val) {
            my @nval = (
               $$val[0] - $o[0],
               $$val[1] - $o[1],
            );
            $val = \@nval;
         }
         next if $_ eq 'owner';
         my $type = $self-> get_typerec( $types->{$_}, \$val);
         $val = defined($val) ? $type-> write( $_, $val, 1) : 'undef';
         $modules{$_} = 1 for $type-> preload_modules();
         $c .= "       $_ => $val,\n";
      }
      $c .= "   );\n";

      $c .= '   '.$actions{onCreate}->{$name}."(q($name), \$instances{$name}, \$names{$name});\n"
         if $actions{onCreate}->{$name};
      $c .= '   '.$actions{onChildCreate}->{$owner}."(q($owner), \$instances{$owner}, \$names{$owner}, \$names{$name});\n"
         if $actions{onChildCreate}->{$owner};
   }
   if ( scalar @re_cmp) {
      @cmp = @re_cmp;
      @re_cmp = ();
      goto AGAIN;
   }

   $c .= '   '.$actions{onEnd}->{$_}."(q($_), \$instances{$_}, \$names{$_});\n"
      for keys %{$actions{onEnd}};
$c .= <<POSTHEAD;
   \$self-> unlock;
   return \%profile;
}

sub on_destroy
{
   \$::application-> close;
}

package ${main}Auto;

use Prima::Application;
${main}Window-> create;
run Prima;

POSTHEAD

   $header .= "use $_;\n" for sort keys %modules;
   return $header.$c;
}


sub save
{
   my ( $self, $asPL) = @_;

   return 0 unless $VB::form;

   return $self-> saveas unless defined $self->{fmName};

   if ( CORE::open( F, ">".$self->{fmName})) {
      local $/;
      $VB::main-> wait;
      my $c = $asPL ? $self-> write_PL : $self-> write_form;
      print F $c;
   } else {
      Prima::MsgBox::message("Error saving ".$self->{fmName});
      return 0;
   }
   close F;

   $VB::form->{modified} = undef unless $asPL;

   return 1;
}

sub saveas
{
   my $self = $_[0];
   return 0 unless $VB::form;
   my $d = VB::save_dialog(
      filter => [
        ['Form files' => '*.fm'],
        ['Program scratch' => '*.pl'],
        [ 'All files' => '*']
      ],
   );
   $self->{saveFileDlg} = $d;
   return 0 unless $d-> execute;
   my $fn = $d-> fileName;
   my $asPL = ($d-> filterIndex == 1);
   my $ofn = $self->{fmName};
   $self->{fmName} = $fn;
   $self-> save( $asPL);
   $self->{fmName} = $ofn if $asPL;
   return 1;
}

sub update_menu
{
   return unless $VB::main;
   my $m = $VB::main-> menu;
   my $a = $::application-> accelTable;
   my $f = (defined $VB::form) ? 1 : 0;
   my $r = (defined $VB::main->{running}) ? 1 : 0;
   $m-> enabled( 'runitem', $f && !$r);
   $a-> enabled( 'runitem', $f && !$r);
   $m-> enabled( 'newitem', !$r);
   $m-> enabled( 'openitem', !$r);
   $a-> enabled( 'openitem', !$r);
   $m-> enabled( 'saveitem1', $f);
   $a-> enabled( 'saveitem1', $f);
   $m-> enabled( 'saveitem2', $f);
   $m-> enabled( 'closeitem', $f);
   $m-> enabled( 'breakitem', $f && $r);
   $VB::main-> {runbutton}-> enabled( $f && !$r);
   $VB::main-> {openbutton}-> enabled( !$r);
   $VB::main-> {newbutton}-> enabled( !$r);
   $VB::main-> {savebutton}-> enabled( $f);
}

sub update_markings
{
}

sub form_cancel
{
   if ( $VB::main) {
      return unless $VB::main-> {running};
      $VB::main-> {running}-> destroy;
      $VB::main-> {running} = undef;
      update_menu();
   }
   $VB::form-> show if $VB::form;
   $VB::inspector-> show if $VB::inspector;
}


sub form_run
{
   my $self = $_[0];
   return unless $VB::form;
   if ( $VB::main->{running}) {
      $VB::main->{running}-> destroy;
      $VB::main->{running} = undef;
   }
   $VB::main-> wait;
   my $c = $self-> write_form;
   my $okCreate = 0;
   eval{
      my $sub = eval("$c");
      if ( $@) {
         print "Error loading module $@";
         Prima::MsgBox::message("$@");
         return;
      }
      $Prima::VB::VBLoader::builderActive = 0;
      my @d = $sub->();
      $Prima::VB::VBLoader::builderActive = 1;
      my %r = Prima::VB::VBLoader::AUTOFORM_REALIZE( \@d, {});
      my $f = $r{$VB::form->prf('name')};
      $okCreate = 1;
      if ( $f) {
         $f-> set( onClose => \&form_cancel );
         $VB::main-> {running} = $f;
         update_menu();
         $f-> select;
         $VB::form-> hide;
         $VB::inspector-> hide if $VB::inspector;
      };
   };
   $Prima::VB::VBLoader::builderActive = 1;
   Prima::MsgBox::message( "$@") if $@;
}

sub wait
{
   my $t = $_[0]-> insert( Timer => timeout => 10, onTick => sub {
      $::application-> pointer( $_[0]->{savePtr});
      $_[0]-> destroy;
   });
   $t-> {savePtr} = $::application-> pointer;
   $::application-> pointer( cr::Wait);
   $t-> start;
}

sub bring_inspector
{
   if ( $VB::inspector) {
      $VB::inspector-> restore if $VB::inspector-> windowState == ws::Minimized;
      $VB::inspector-> bring_to_front;
      $VB::inspector-> select;
   } else {
      $VB::inspector = ObjectInspector-> create;
      ObjectInspector::renew_widgets;
   }
}


package VisualBuilder;

$::application-> icon( Prima::Image-> load( Prima::find_image( 'VB::VB.gif'), index => 6));
$::application-> accelItems( VB::accelItems);
$VB::main = MainPanel-> create;
$VB::inspector = ObjectInspector-> create(
   top => $VB::main-> bottom - 12 - $::application-> get_system_value(sv::YTitleBar)
) if $VB::main-> {ini}-> {ObjectInspectorVisible};
$VB::form = Form-> create; 
ObjectInspector::renew_widgets;
ObjectInspector::preload() unless $VB::fastLoad;
$VB::main-> update_menu();

$VB::main-> load_file( $ARGV[0]) if @ARGV && -f $ARGV[0] && -r _;

while ($::application) {
   eval { run Prima };
   Prima::MsgBox::message( "$@") if $::application && $@;
}

1;
