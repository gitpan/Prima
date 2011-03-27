use strict;
use Prima qw(Application Buttons ScrollWidget Notebooks);

my $w = Prima::MainWindow-> new;

my $d;
my $dt = 1;

if ( $dt) {
	$d = $w-> insert( 'Prima::TabbedScrollNotebook' => 
		tabs => [ 'A', 'B', 'C'],
		pack => { expand => 1, fill => 'both' },
	
		notebookProfile => {
			clientProfile => {
				backColor => cl::Green,
				sizeMax => [ 300, 300],
			}
		},
	);
} else {
	$d = $w-> insert( 'Prima::ScrollGroup' => 
		pack => { expand => 1, fill => 'both' },
	
		clientProfile => {
			backColor => cl::Green,
			sizeMax => [ 300, 300],
		},
	);
}

$d-> packPropagate(0);
#$d-> packPropagate(1);
$d-> insert( 'Button', pack => {padx => 204});
$d-> insert( 'Button', pack => {});
$d-> insert( 'Button', pack => {});
$d-> defaultInsertPage(1) if $dt;
$d-> insert( 'Button', pack => {});
$d-> insert( 'Button', pack => {});
$d-> insert( 'Button', pack => {});
$d-> packPropagate(1);
$d-> packPropagate(0);
#$d-> reset;

run Prima;
