use strict;
use Prima qw(Application ScrollWidget);

# This is an example that demonstrates two things: 
# - How easy it is to make a widget a-la Tk::Canvas
# - And why something like Prima::Canvas does not exist
# The functionality of Tk::Canvas is although vast but
# hardly needed in full, so in order not to create
# unneeded entities, this example is designed to serve
# a kludge for anyone who needs parts of Tk::Canvas.
#
#   - <dmitry@karasik.eu.org>

package TkCanvas;
# A widget with two scrollbars. Contains set of objects, that know
# how to draw themselves. The graphic objects hierarchy starts
# from GraphicObject class

use vars qw(@ISA);
@ISA = qw(Prima::ScrollWidget);

sub on_create
{
   my $self = $_[0];
   $self-> {primitives} = [];
}

sub on_paint
{
   my ( $self, $canvas) = @_;
   $canvas-> clear;
   my @d = $self-> deltas;
   my @a = $self-> get_active_area(2);
   for ( @{$self->{primitives}}) {
      my $obj = $_;
      $canvas-> transform(
         -$d[0] + $obj-> left,
         $d[1] + $a[1] - $obj-> top,
      );
      $canvas-> set( map { $_ => $obj-> $_() } $obj-> uses);
      $obj-> on_paint( $canvas);
   }
}

sub on_mousedown
{
   my ( $self, $btn, $mod, $x, $y) = @_;
   return unless $btn == mb::Left && !$self-> {transaction};
   $y = $self-> height - $y;
   my @d = $self-> deltas;
   for ( @{$self->{primitives}}) {
      my $obj = $_;
      my @r = $obj-> rect;
      $r[0] -= $d[0];
      $r[1] -= $d[1];
      $r[2] -= $d[0];
      $r[3] -= $d[1];
      if ( $r[0] < $x && $r[1] < $y && $r[2] >= $x && $r[3] >= $y) {
         $self-> {transaction} = $obj;
         $self-> {selection}-> selected(0) if $self-> {selection};
         $self-> {anchor} = [ $x - $r[0], $y - $r[1]];
         $obj-> selected(1);
         $self-> {selection} = $obj;
         last;
      }
   }
}

sub on_mouseup
{
   my ( $self, $btn, $mod, $x, $y) = @_;
   return unless $btn == mb::Left && $self-> {transaction};
   $self-> {transaction} = undef;
}

sub on_mousemove
{
   my ( $self, $mod, $x, $y) = @_;
   return unless $self-> {transaction};
   $y = $self-> height - $y;
   $x -= $self-> {anchor}->[0];
   $y -= $self-> {anchor}->[1];
   $x += $self-> deltaX;
   $y += $self-> deltaY;
   $self-> {transaction}-> origin( $x, $y);
}

sub insert_object
{
   my ( $self, $class) = ( shift, shift);
   push @{$self->{primitives}}, $class-> new(
      @_,
      owner => $self,
   );
}

package GraphicObject;

sub new
{
   my ( $class, @whatever) = @_;
   my $self = bless {
      @whatever,
   }, $class;
   my %defaults = $self-> default;
   for ( keys %defaults) {
      next if exists $self-> {$_};
      $self-> {$_} = $defaults{$_};
   }
   die "No ``owner'' is specified" unless $self-> {owner};
   $self-> repaint;
   return $self;
}

sub default
{
   return (
      rop => rop::CopyPut,
      rect => [ 10, 10, 100, 100 ],
      color => cl::Black,
      backColor => cl::White,
      font => Prima::Widget-> get_default_font,
      lineWidth => 0,
      linePattern => lp::Solid,
      selected => 0,
   );
}

sub uses
{
   return ();
}

sub repaint
{
   my $self = $_[0];
   my @r = $self-> coord2owner( $self-> rect );
   $r[2]++;
   $r[3]++;
   $self-> owner-> invalidate_rect( @r);
}

sub coord2owner
{
   my $self = shift;
   my @delta = $self-> owner-> deltas;
   my $i;
   my @ret;
   for ( $i = 0; $i < @_; $i+=2) {
      push @ret, 
         $_[$i] + $delta[0],
         $_[$i+1] + $delta[1];
   }
   return @ret;
}

sub move
{
   $_[0]-> owner-> repaint;
}

sub owner
{
   return $_[0]-> {owner};
}

sub rop
{
   return $_[0]-> {rop} unless $#_;
   $_[0]-> {rop} = $_[1];
   $_[0]-> repaint;
}

sub left
{
   my $d = $_[0]-> {rect};
   return $$d[0] unless $#_;
   $$d[0] = $_[1];
   @$d[0,2] = @$d[2,0] if $$d[0] > $$d[2];
   $_[0]-> move;
}

sub bottom
{
   my $d = $_[0]-> {rect};
   return $$d[1] unless $#_;
   $$d[1] = $_[1];
   @$d[1,3] = @$d[3,1] if $$d[1] > $$d[3];
   $_[0]-> move;
}

sub right
{
   my $d = $_[0]-> {rect};
   return $$d[2] unless $#_;
   $$d[2] = $_[1];
   @$d[0,2] = @$d[2,0] if $$d[0] > $$d[2];
   $_[0]-> move;
}

sub top
{
   my $d = $_[0]-> {rect};
   return $$d[3] unless $#_;
   $$d[3] = $_[1];
   @$d[1,3] = @$d[3,1] if $$d[1] > $$d[3];
   $_[0]-> move;
}

sub width
{
   return $_[0]-> {rect}->[2] - $_[0]-> {rect}->[0] unless $#_;
   $_[0]-> {rect}->[2] = $_[0]-> {rect}->[0] + $_[1] if $_[1] >= 0;
   $_[0]-> move;
}

sub height
{
   return $_[0]-> {rect}->[3] - $_[0]-> {rect}->[1] unless $#_;
   $_[0]-> {rect}->[3] = $_[0]-> {rect}->[1] + $_[1] if $_[1] >= 0;
   $_[0]-> move;
}

sub rect
{
   my $d = $_[0]-> {rect};
   return $$d[0], $$d[1], $$d[2] + $$d[0], $$d[3] + $$d[1] unless $#_;
   my ( $self, $x, $y, $x2, $y2) = @_;
   $$d[0] = $x;
   $$d[1] = $y;
   $$d[2] = $x2;
   $$d[3] = $y2;
   @$d[0,2] = @$d[2,0] if $$d[0] > $$d[2];
   @$d[1,3] = @$d[3,1] if $$d[1] > $$d[3];
   $_[0]-> move;
}

sub origin
{
   my $d = $_[0]-> {rect};
   return $$d[0], $$d[1] unless $#_;
   my ( $self, $x, $y) = @_;
   $$d[0] = $x;
   $$d[1] = $y;
   $_[0]-> move;
}

sub size
{
   my $d = $_[0]-> {rect};
   return $$d[2], $$d[3] unless $#_;
   my ( $self, $w, $h) = @_;
   $$d[2] = $$d[0] + $w if $w >= 0;
   $$d[3] = $$d[1] + $h if $h >= 0;
   $_[0]-> move;
}

sub color
{
   return $_[0]-> {color} unless $#_;
   $_[0]-> {color} = $_[1];
   $_[0]-> repaint;
}

sub backColor
{
   return $_[0]-> {backColor} unless $#_;
   $_[0]-> {backColor} = $_[1];
   $_[0]-> repaint;
}

sub font
{
   return $_[0]-> {font} unless $#_;
   my ( $self, %font) = @_;
   for ( keys %font) {
      $self-> {font}->{$_} = $font{$_};
   }
   $_[0]-> repaint;
}

sub lineWidth
{
   return $_[0]-> {lineWidth} unless $#_;
   $_[0]-> {lineWidth} = $_[1];
   $_[0]-> repaint;
}

sub linePattern
{
   return $_[0]-> {linePattern} unless $#_;
   $_[0]-> {linePattern} = $_[1];
   $_[0]-> repaint;
}

sub selected
{ 
   return $_[0]-> {selected} unless $#_;
   my ( $self, $selected) = @_;
   $self-> {selected} = $selected;
   $self-> repaint;
}

sub paint_selection
{
   my ( $self, $canvas) = @_;
   $canvas-> rect_focus( @{$self-> {rect}});
}

package Rectangle;
use vars qw(@ISA);
@ISA = qw(GraphicObject);

sub uses { return qw( rop color lineWidth linePattern ); }

sub on_paint
{
   my ( $self, $canvas, $dx, $dy) = @_;
   my $d = $self-> {rect};
   $canvas-> rectangle( 0, 0, $$d[0] + $$d[2], $$d[1] + $$d[3]);
}

package main;

my $w = Prima::Window-> create(
  onDestroy => sub { $::application-> close },
  menuItems => [
     ['New ~object' => [
        ['Rectangle' => '~Rectangle' => \&insert],
        ['Bar' => '~Bar' => \&insert],
     ]],
  ],
);

my $c = $w-> insert( TkCanvas =>
   origin => [0,0],
   size   => [$w-> size],
   growMode => gm::Client,
   limitX   => 500,
   limitY   => 500,
   hScroll => 1,
   vScroll => 1,
);

sub insert
{
   my ( $self, $obj) = @_;
   $c-> insert_object( $obj);
}

$c-> insert_object( 'Rectangle');

run Prima;
