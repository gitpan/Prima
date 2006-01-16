use strict;
use Prima qw(Application Buttons ScrollWidget);

package Prima::ScrollDocument;
use vars qw(@ISA);
@ISA = qw(Prima::ScrollWidget);

sub profile_default
{
	my $def = $_[0]-> SUPER::profile_default;
	my %prf = (
		rigid      		=> 1,
		slaveClass		=> 'Prima::Widget',
		slaveProfile		=> {},
		slaveDelegations	=> [],
		clientClass		=> 'Prima::Widget',
		clientProfile		=> {},
		clientDelegations	=> [],
	);
	@$def{keys %prf} = values %prf;
	return $def;
}

sub init
{
	my ($self, %profile) = @_;
	%profile = $self-> SUPER::init(%profile);

	$self-> {$_} = 0 for qw(rigid);
	$self-> $_( $profile{$_}) for qw(rigid);
   
	$self-> {slave} = $profile{slaveClass}-> new( 
		delegations => $profile{slaveDelegations},
		%{$profile{slaveProfile}},
		owner => $self,
		name => 'SlaveWindow',
		rect  => [ $self-> get_active_area(0) ],
		growMode => gm::Client,
	);

	$self-> {client_geomSize} = [0,0];
	$self-> {client} = $profile{clientClass}-> new( 
		delegations => [ $self, 'Size', $self, 'Move',
			@{$profile{clientDelegations}}],
		%{$profile{clientProfile}},
		owner => $self-> {slave},
		name  => 'ClientWindow',
	);

	$self-> reset(1);

	return %profile;
}

sub reset_indents
{
	$_[0]-> reset(1);
}

sub reset
{
	my ( $self, $update_slave) = @_;
	return unless $self-> {client};

	my @size = $self-> size;
	$self-> {slave}-> rect( $self-> get_active_area(0, @size))
		if $update_slave;

	$self-> ClientWindow_Move( $self-> {client}, 0, 0, $self-> {client}-> origin);
	$self-> ClientWindow_Size( $self-> {client}, 0, 0, $self-> {client}-> size);
}

sub on_paint
{
	my ( $self, $canvas) = @_;
	my @size = $self-> size;
	$canvas-> rect3d( 0, 0, $size[0]-1, $size[1]-1, 
		$self-> borderWidth, $self-> dark3DColor, $self-> light3DColor,
		$self-> backColor);
}

sub on_size
{
	$_[0]-> reset(1);
}

sub on_scroll
{
	my ( $self, $dx, $dy) = @_;
	return if $self-> {protect_scrolling};
	local $self-> {protect_scrolling} = 1;
	my @o = $self-> {client}-> origin;
	$self-> {client}-> origin(
		$o[0] + $dx,
		$o[1] + $dy,
	);
}

sub ClientWindow_Move
{
	my ( $self, $client, $ox, $oy, $x, $y) = @_;
	return if $self-> {protect_scrolling};
	local $self-> {protect_scrolling} = 1;
	$self-> deltas( -$x, $y - $self-> {slave}-> height + $self-> limitY);
}

sub ClientWindow_Size
{
	my ( $self, $client, $ox, $oy, $x, $y) = @_;
	
	my @l = $self-> limits;
	( $l[0] == $x and $l[1] == $y) ? 
		$self-> reset_scrolls : 
		$self-> limits( $x, $y);

	if ( $self-> {rigid} or $self-> packPropagate ) {
		my @g = $client-> geomSize;
		if ( $g[0] != $self-> {client_geomSize}-> [0] or
		     $g[1] != $self-> {client_geomSize}-> [1]) {
			@{$self-> {client_geomSize}} = @g;
		     	$client-> sizeMin( @g) if $self-> {rigid};
			if ( $self-> packPropagate) {
				my @i = $self-> indents;
				$self-> geomSize( 
					$g[0] + $i[0] + $i[2],
					$g[1] + $i[1] + $i[3]
				);
			}
		}
	}
}

sub slave { $_[0]-> {slave} } 
sub client { $_[0]-> {client} } 
sub insert_widget { shift-> {client}-> insert( @_ ) }

sub rigid
{
	return $_[0]-> {rigid} unless $#_;

	my ( $self, $rigid) = @_;
	$self-> {rigid} = $rigid;

	if ( $rigid) {
		if ( $self-> {client}) {
			my @g = $self-> {client}-> geomSize;
			@{$self-> {client_geomSize}} = @g;
			$self-> {client}-> sizeMin( @g);
		}
	}
}

package main;

my $w = Prima::MainWindow-> new;

my $d = $w-> insert( 'Prima::ScrollDocument' => 
	pack => { expand => 1, fill => 'both' },
	clientProfile => {
		backColor => cl::Green,
		pack => { expand => 0, xfill => 'both' },
#		onSize => sub { shift ; print "size @_\n"; },
#		onMove => sub { $_=shift ; print "move @_ / sz ="; print $_->size, "\n"; },
	},
);

# $d-> insert_widget( 'Button', growMode => gm::Center,);
$d-> packPropagate(0);
$d-> insert_widget( 'Button', pack => {padx => 204});
$d-> insert_widget( 'Button', pack => {});
$d-> insert_widget( 'Button', pack => {});
$d-> insert_widget( 'Button', pack => {});
$d-> insert_widget( 'Button', pack => {});
$d-> insert_widget( 'Button', pack => {});
$d-> packPropagate(1);


run Prima;
