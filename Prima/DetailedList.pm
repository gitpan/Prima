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
#  Modifications by Anton Berezin <tobez@tobez.org>
#
#  $Id: DetailedList.pm,v 1.15 2002/07/22 09:21:46 dk Exp $


package Prima::DetailedList;

use strict;
use Prima::Classes;
use Prima::Lists;
use Prima::Header;

use vars qw(@ISA);
@ISA = qw(Prima::ListViewer);

{
my %RNT = (
   %{Prima::ListViewer->notification_types()},
   Sort => nt::Command,
);

sub notification_types { return \%RNT; }
}


my %hdrProps = (
   clickable   => 1,
   scalable    => 1,
   dragable    => 1,
   minTabWidth => 1,
);

for ( keys %hdrProps) {
   eval <<GENPROC;
   sub $_ { return shift-> {hdr}-> $_(\@_); }
   sub Prima::DetailList::DummyHeader::$_ {}
GENPROC
}

sub profile_default
{
   return {
      %{Prima::Header->profile_default},
      %{$_[ 0]-> SUPER::profile_default},
      headerClass       => 'Prima::Header',
      headerProfile     => {},
      headerDelegations => [qw(MoveItem SizeItem SizeItems Click)],
      multiColumn       => 0,
      autoWidth         => 0,
      columns           => 0,
      widths            => [],
      headers           => [],
      mainColumn        => 0,
   };
}


sub init
{
   my ( $self, %profile) = @_;
   $self->{noHeader} = 1;
   $self->{header} = bless [], q\Prima::DetailList::DummyHeader\;
   $self-> {$_} = 0 for qw( mainColumn);
   %profile = $self-> SUPER::init( %profile);

   my $hh = $self-> {headerInitHeight};
   delete $self-> {headerInitHeight};
   delete $self-> {noHeader};
   my $bw = $self-> borderWidth;
   my @sz = $self-> size;

   my $hasv = $self-> {vScroll};

   $self-> {header} = $self-> insert( $profile{headerClass} =>
      name     => 'Header',
      origin   => [ $bw, $sz[1] - $bw - $hh],
      size     => [ $sz[0] - $bw * 2 + 1 - ( $hasv ? $self->{vScrollBar}-> width : 0), $hh],
      vertical => 0,
      growMode => gm::Ceiling,
      items    => $profile{headers},
      widths   => $profile{widths},
      delegations => $profile{headerDelegations},
      (map { $_ => $profile{$_}} keys %hdrProps),
      %{$profile{headerProfile}},
   );
   my $x = $self-> {header}->items;
   $self-> {umap} = [ 0 .. $#$x];
   $self-> $_( $profile{$_}) for qw( columns mainColumn);
   $self-> autowidths unless scalar @{$profile{widths}};
   return %profile;
}

sub setup_indents
{
   $_[0]-> SUPER::setup_indents;
   $_[0]-> {headerInitHeight} = $_[0]-> font-> height + 8;
   $_[0]-> {indents}-> [ 3] += $_[0]-> {headerInitHeight};
}


sub set_v_scroll
{
   my ( $self, $s) = @_;
   $self-> SUPER::set_v_scroll( $s);
   return if $self->{noHeader};
   my @a = $self-> get_active_area(2);
   $self-> {header}-> width( $a[0]);
}

sub set_offset
{
   my ( $self, $o) = @_;
   $self-> SUPER::set_offset( $o);
   $self-> { header}-> offset( $self-> {offset}) unless $self-> {noHeader};
}

sub columns
{
   return $_[0]-> {numColumns} unless $#_;
   my ( $self, $c) = @_;
   $c = 0 if $c < 0;
   return if defined $self->{numColumns} && $self->{numColumns} == $c;
   my $h    = $self-> {header};
   my @iec  = @{$h-> items};
   my @umap = @{$self-> {umap}};
   if ( scalar(@iec) > $c) {
      splice( @iec, $c);
      splice( @umap, $c);
   } elsif ( scalar(@iec) < $c) {
      push( @umap, (( undef ) x ( $c - scalar @iec)));
      push( @iec, (( '' ) x ( $c - scalar @iec)));
      my $i = 0; for ( @umap) { $_ = $i unless defined $_; $i++; }
   }
   $self-> {umap} = \@umap;
   $h-> items( \@iec);
   $self-> {numColumns} = $c;
   $self-> repaint;
}

sub autowidths
{
   my $self = $_[0];
   my $i;
   my @w = @{$self-> widths};
   my @header_w = $self->{header}->calc_autowidths;
   for ( $i = 0; $i < $self-> {numColumns}; $i++) {
      $self-> mainColumn( $i);
      $self-> recalc_widths;
      $w[ $i] = $self-> {maxWidth} + 5 if $w[ $i] < $self-> {maxWidth} + 5;
      $w[$i] = $header_w[$i] if $w[$i] < $header_w[$i];
   }
   undef $self-> {widths};
   $self-> widths( \@w);
}

sub draw_items
{
   my ($self,$canvas) = (shift,shift);
   my @clrs = (
      $self-> color,
      $self-> backColor,
      $self-> colorIndex( ci::HiliteText),
      $self-> colorIndex( ci::Hilite)
   );
   my @clipRect = $canvas-> clipRect;
   my $cols   = $self-> {numColumns};

   my $xstart = $self-> {borderWidth} - 1;
   my ( $i, $ci, $xend);
   my @widths = @{ $self-> { header}-> widths };
   my $umap   = $self-> {umap}->[0];
   my $o = $self-> {offset} ;

   $xend = $xstart - $o + 2;
   $xend += $_ + 2 for @widths;
   $canvas-> clear( $xend, @clipRect[1..3]) if $xend <= $clipRect[2];

   return if $cols == 0;

   my $iref   = \@_;
   my $rref   = $self-> {items};
   my $icount = scalar @_;

   my $drawVeilFoc = -1;
   my $x0d    = $self->{header}->{maxWidth} - 2;

   my @normals;
   my @selected;
   my ( $lastNormal, $lastSelected) = (undef, undef);

   # sorting items by index
   $iref = [ sort { $$a[0]<=>$$b[0] } @$iref];

   # calculating conjoint bars for normals / selected
   @normals = ();
   $lastNormal = undef;

   for ( $i = 0; $i < $icount; $i++)
   {
      my ( $itemIndex, $x, $y, $x2, $y2, $selected, $focusedItem) = @{$$iref[$i]};
      $drawVeilFoc = $i if $focusedItem;
      if ( $selected)
      {
         if ( defined $lastSelected && ( $y2 + 1 == $lastSelected)) {
            ${$selected[-1]}[1] = $y;
         } else {
            push ( @selected, [ $x, $y, $x + $x0d, $y2]);
         }
         $lastSelected = $y;
      } else {
         if ( defined $lastNormal && ( $y2 + 1 == $lastNormal)) {
            ${$normals[-1]}[1] = $y;
         } else {
            push ( @normals, [ $x, $y, $x + $x0d, $y2]);
         }
         $lastNormal = $y;
      }
   }

   $canvas-> backColor( $clrs[1]);
   $canvas-> clear( @$_) for @normals;
   $canvas-> backColor( $clrs[3]);
   $canvas-> clear( @$_) for @selected;

   # draw veil
   if ( $drawVeilFoc >= 0) {
      my ( $itemIndex, $x, $y, $x2, $y2) = @{$$iref[$drawVeilFoc]};
      $canvas-> rect_focus( $x + $o, $y, $x + $o + $x0d, $y2);
   }

   # texts
   my $lc = $clrs[0];
   my $txw = 1;
   for ( $ci = 0; $ci < $cols; $ci++) {
      $umap = $self-> {umap}->[$ci];
      my $wx = $widths[ $ci] + 2;
      if ( $xstart + $wx - $o >= $clipRect[0]) {
         $canvas-> clipRect(
             (( $xstart - $o) < $clipRect[0]) ? $clipRect[0] : $xstart - $o,
             $clipRect[1],
             (( $xstart + $wx - $o) > $clipRect[2]) ? $clipRect[2] : $xstart + $wx - $o,
             $clipRect[3]);
         for ( $i = 0; $i < $icount; $i++) {
            my ( $itemIndex, $x, $y, $x2, $y2, $selected, $focusedItem) = @{$$iref[$i]};
            my $c = $clrs[ $selected ? 2 : 0];
            $canvas-> color( $c), $lc = $c if $c != $lc;
            $canvas-> text_out( $rref->[$itemIndex]-> [$umap], $x + $txw, $y);
         }
      }
      $xstart += $wx;
      $txw    += $wx;
      last if $xstart - $o >= $clipRect[2];
   }
}

sub item2rect
{
   my ( $self, $item, @size) = @_;
   my @a = $self-> get_active_area( 0, @size);
   my ($i,$ih) = ( $item - $self->{topItem}, $self->{itemHeight});
   return $a[0], $a[3] - $ih * ( $i + 1), $a[0] + $self->{header}->{maxWidth}, $a[3] - $ih * $i;
}

sub Header_SizeItem
{
   my ( $self, $header, $col, $oldw, $neww) = @_;
   my $xs = $self-> {borderWidth} - 1 - $self-> {offset};
   my $i = 0;
   for ( @{$self-> {header}-> widths}) {
      last if $col == $i++;
      $xs += $_ + 2;
   }
   $xs += 3 + $oldw;
   my @sz = $self-> size;
   my @a = $self-> get_active_area( 0, @sz);
   $self-> scroll(
      $neww - $oldw, 0,
      confineRect => [ $xs, $a[1], $a[2] + abs( $neww - $oldw), $a[3]],
      clipRect    => \@a,
   );
   $self-> {itemWidth} = $self-> {header}-> {maxWidth} - 1;
   if ( $self-> {hScroll}) {
      my $ov = $self-> {vScroll};
      $self-> {vScroll} = 0; # speedup a bit
      $self-> reset_scrolls;
      $self-> {vScroll} = $ov;
   }
}

sub widths {
   return shift-> { header}-> widths( @_) unless $#_;
   my $self = shift;
   $self-> {header}-> widths( @_);
}

sub headers {
   return shift-> { header}-> items( @_) unless $#_;
   my $self = shift;
   $self-> {header}-> items( @_);
   my $x = $self-> {header}-> items;
   $self-> {umap} = [ 0 .. $#$x];
   $self-> repaint;
}

sub mainColumn
{
   return $_[0]-> {mainColumn} unless $#_;
   my ( $self, $c) = @_;
   $c = 0 if $c < 0;
   $c = $self->{numColumns} - 1 if $c >= $self-> {numColumns};
   $self-> {mainColumn} = $c;
}

sub Header_SizeItems
{
   $_[0]-> {itemWidth} = $_[0]-> {header}-> {maxWidth} - 1;
   $_[0]-> reset_scrolls;
   $_[0]-> repaint;
}

sub Header_MoveItem  {
   my ( $self, $hdr, $o, $p) = @_;
   splice( @{$self-> {umap}}, $p, 0, splice( @{$self-> {umap}}, $o, 1));
   $self-> repaint;
}

sub Header_Click
{
   my ( $self, $hdr, $id) = @_;
   $self-> mainColumn( $self-> {umap}->[ $id]);
   $self-> sort( $self-> {mainColumn});
}

sub get_item_text
{
   my ( $self, $index, $sref) = @_;
   my $c = $self-> {mainColumn};
   $$sref = $self-> {items}->[$index]-> [ $c];
}

sub on_measureitem
{
   my ( $self, $index, $sref) = @_;
   my $c = $self-> {mainColumn};
   $$sref = $self-> get_text_width( $self-> {items}->[$index]-> [ $c]);
}

sub on_stringify
{
   my ( $self, $index, $sref) = @_;
   my $c = $self-> {mainColumn};
   $$sref = $self-> {items}->[$index]-> [ $c];
}

sub sort
{
   my ( $self, $c) = @_;
   my $dirSort;
   if ( defined $c) {
       return if $c < 0;
       if ( defined($self-> {lastSortCol}) && ( $self-> {lastSortCol} == $c)) {
	  $dirSort = $self-> {lastSortDir} = ( $self-> {lastSortDir} ? 0 : 1);
       } else {
	  $dirSort = 1;
	  $self-> {lastSortDir} = 1;
	  $self-> {lastSortCol} = $c;
       }
   }
   else {
       $self->{ lastSortCol} = 0 unless defined $self->{ lastSortCol};
       $c = $self->{ lastSortCol};
       $self->{ lastSortDir} = 0 unless defined $self->{ lastSortDir};
       $dirSort = $self->{ lastSortDir};
   }
   my $foci = undef;
   $foci = $self-> {items}->[$self-> {focusedItem}] if $self-> {focusedItem} >= 0;
   $self-> notify(q(Sort), $c, $dirSort);
   $self-> repaint;
   return unless defined $foci;
   my $i = 0;
   my $newfoc;
   for ( @{$self-> {items}}) {
      $newfoc = $i, last if $_ == $foci;
      $i++;
   }
   $self-> focusedItem( $newfoc) if defined $newfoc;
}

sub on_sort
{
   my ( $self, $col, $dir) = @_;
   if ( $dir) {
      $self-> {items} = [
         sort { $$a[$col] cmp $$b[$col]}
         @{$self->{items}}];
   } else {
      $self-> {items} = [
         sort { $$b[$col] cmp $$a[$col]}
         @{$self->{items}}];
   }
   $self-> clear_event;
}

sub itemWidth {$_[0]-> {itemWidth};}
sub autoWidth { 0;}

1;

__DATA__

=pod

=head1 NAME

Prima::DetailedList - a multi-column list viewer with controlling 
header widget.

=head1 DESCRIPTION

Prima::DetailedList is a descendant of Prima::ListViewer, and as such provides
a certain level of abstraction. It overloads format of L<items> in order to
support multi-column ( 2D ) cell span. It also inserts L<Prima::Header> widget
on top of the list, so the user can interactively move, resize and sort the content
of the list. The sorting mechanism is realized inside the package; it is
activated by the mouse click on a header tab.

Since the class inherits Prima::ListViewer, some functionality, like 'item search by
key', or C<get_item_text> method can not operate on 2D lists. Therefore, L<mainColumn>
property is introduced, that selects the column representing all the data.

=head1 SYNOPSIS

  use Prima::DetailedList;

  my $l = $w-> insert( 'Prima::DetailedList', 
        columns => 2,
        headers => [ 'Column 1', 'Column 2' ],
        items => [
             ['Row 1, Col 1', 'Row 1, Col 2'],
             ['Row 2, Col 1', 'Row 2, Col 2']
        ],
  );
  $l-> sort(1);

=head1 API

=head2 Events

=over

=item Sort COLUMN, DIRECTION

Called inside L<sort> method, to facilitate custom algorithms of sorting.
If the callback procedure is willing to sort by COLUMN index, then it must
call C<clear_event>, to signal the event flow stop. The DIRECTION is a boolean
flag, specifying whether the sorting must be performed is ascending ( 1 ) or
descending ( 0 ) order.

The callback procedure must operate on the internal storage of C<{items}>,
which is an array of arrays of scalars.

The default action is the literal sorting algorithm, where precedence is
arbitrated by C<cmp> operator ( see L<perlop/"Equality Operators"> ) .

=back

=head2 Properties

=over

=item columns INTEGER

Governs the number of columns in L<items>. If set-called, and the new number 
is different from the old number, both L<items> and L<headers> are restructured.

Default value: 0

=item headerClass

Assigns a header class.

Create-only property.

Default value: C<Prima::Header>

=item headerProfile HASH

Assigns hash of properties, passed to the header widget during the creation.

Create-only property.

=item headerDelegations ARRAY

Assigns a header widget list of delegated notifications.

Create-only property.

=item headers ARRAY

Array of strings, passed to the header widget as column titles.

=item items ARRAY

Array of arrays of scalars, of arbitrary kind. The default
behavior, however, assumes that the scalars are strings.
The data direction is from left to right and from top to bottom.

=item mainColumn INTEGER

Selects the column, responsible for representation of all the data.
As the user clicks the header tab, C<mainColumn> is automatically
changed to the corresponding column.

Default value: 0

=back

=head2 Methods

=over

=item sort [ COLUMN ]

Sorts items by the COLUMN index in ascending order. If COLUMN is not specified,
sorts by the last specified column, or by #0 if it is the first C<sort> invocation.

If COLUMN was specified, and the last specified column equals to COLUMN,
the sort direction is reversed.

The method does not perform sorting itself, but invokes L<Sort> notification,
so the sorting algorithms can be overloaded, or be applied differently to
the columns.

=back

=head1 AUTHOR

Dmitry Karasik, E<lt>dmitry@karasik.eu.orgE<gt>.

=head1 SEE ALSO

L<Prima>, L<Prima::Lists>, L<Prima::Header>, F<examples/sheet.pl>

=cut
