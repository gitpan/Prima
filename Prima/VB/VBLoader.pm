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
# $Id: VBLoader.pm,v 1.12 2000/09/07 09:52:39 dk Exp $
package Prima::VB::VBLoader;
use strict;
use vars qw($builderActive $fileVersion);

$builderActive = 0;
$fileVersion   = '1.1';

my %fileVerCompat = (
   '1'   => '1.0',
   '1.0' => '1.1',
);

sub check_version
{
   my $header = $_[0];
   return (0, 'unknown') unless $header =~ /file=(\d+\.*\d*)/;
   my $fv = $1;
   while( $fv ne $fileVersion) {
      $fv = $fileVerCompat{$fv}, next if exists $fileVerCompat{$fv};
      return (0, $1);
   }
   return (1, $fv);
}

sub GO_SUB
{
   return $_[0] if $builderActive;
   my $x = eval "sub { $_[0] }";
   if ( $@) { printf( STDERR "VBLoader: $@. Code: ---\n$_[0]\n---\n" ); return sub {}};
   return $x;
}

sub AUTOFORM_REALIZE
{
   my ( $seq, $parms) = @_;
   my %ret = ();
   my %modules = ();
   my $main;
   my $i;

   my %dep;
   for ( $i = 0; $i < scalar @$seq; $i+= 2) {
      $dep{$$seq[$i]} = $$seq[$i + 1];
   }

   for ( keys %dep) {
      $modules{$dep{$_}->{module}} = 1 if $dep{$_}->{module};
      $main = $_ if $dep{$_}->{parent};
   }
   for ( keys %modules) {
      my $c = $_;
      eval("use $c;");
      die "$@" if $@;
   }

   my %owners = ( $main => 0);
   for ( keys %dep) {
      next if $_ eq $main;
      $owners{$_} = exists $parms->{$_}->{owner} ? $parms->{$_}->{owner} :
         ( exists $dep{$_}->{profile}->{owner} ? $dep{$_}->{profile}->{owner} : $main);
      delete $dep{$_}->{profile}->{owner};
   }

   my @actNames  = qw( onBegin onFormCreate onCreate onChild onChildCreate onEnd);
   my %actions   = map { $_ => {}} @actNames;
   my %instances = ();
   for ( keys %dep) {
      my $key = $_;
      my $act = $dep{$_}->{actions};
      $instances{$_} = {};
      $instances{$_}-> {extras} = $dep{$_}->{extras} if $dep{$_}->{extras};

      for ( @actNames) {
         next unless exists $act->{$_};
         $actions{$_}->{$key} = $act->{$_};
      }
   }

   $actions{onBegin}->{$_}->($_, $instances{$_})
      for keys %{$actions{onBegin}};

   delete $dep{$main}->{profile}->{owner};
   $ret{$main} = $dep{$main}->{class}-> create(
      %{$dep{$main}->{profile}},
      %{$parms->{$main}},
   );
   $ret{$main}-> lock;
   $actions{onFormCreate}->{$_}->($_, $instances{$_}, $ret{$main})
      for keys %{$actions{onFormCreate}};
   $actions{onCreate}->{$main}->($main, $instances{$_}, $ret{$main})
      if $actions{onCreate}->{$main};

   my $do_layer;
   $do_layer = sub
   {
      my $id = $_[0];
      my $i;
      for ( $i = 0; $i < scalar @$seq; $i += 2) {
         $_ = $$seq[$i];
         next unless $owners{$_} eq $id;
         $owners{$_} = $main unless exists $ret{$owners{$_}}; # validating owner entry

         my $o = $owners{$_};
         $actions{onChild}->{$o}->($o, $instances{$o}, $ret{$o}, $_)
            if $actions{onChild}->{$o};

         $ret{$_} = $ret{$o}-> insert(
            $dep{$_}->{class},
            %{$dep{$_}->{profile}},
            %{$parms->{$_}},
         );

         $actions{onCreate}->{$_}->($_, $instances{$_}, $ret{$_})
            if $actions{onCreate}->{$_};
         $actions{onChildCreate}->{$o}->($o, $instances{$o}, $ret{$o}, $ret{$_})
            if $actions{onChildCreate}->{$o};

         $do_layer->( $_);
      }
   };
   $do_layer->( $main, \%owners);

   $actions{onEnd}->{$_}->($_, $instances{$_}, $ret{$_})
      for keys %{$actions{onEnd}};
   $ret{$main}-> unlock;
   return %ret;
}

sub AUTOFORM_CREATE
{
   my ( $filename, %parms) = @_;
   my $contents;
   my @preload_modules;
   {
      open F, $filename or die "Cannot open $filename:$!\n";
      my $first = <F>;
      die "Corrupted file $filename\n" unless $first =~ /^# VBForm/;
      my @fvc = check_version( $first);
      die "Incompatible version ($fvc[1]) of file $filename\n" unless $fvc[0];
      while (<F>) {
         $contents = $_, last unless /^#/;
         next unless /^#\s*\[([^\]]+)\](.*)$/;
         if ( $1 eq 'preload') { 
            push( @preload_modules, split( ' ', $2)); 
         }
      }
      local $/;
      $contents .= <F>;
      close F;
   }

   for ( @preload_modules) {
      eval "use $_;";
      die "$@\n" if $@;
   }

   my $sub = eval( $contents);
   die "$@\n" if $@;
   my @dep = $sub-> ();
   return AUTOFORM_REALIZE( \@dep, \%parms);
}

# onBegin       ( name, instance)
# onFormCreate  ( name, instance, formObject)
# onCreate      ( name, instance, object)
# onChild       ( name, instance, object, childName)
# onChildCreate ( name, instance, object, childObject)
# onEnd         ( name, instance, object)

1;
