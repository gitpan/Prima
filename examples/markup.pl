BEGIN {
	if ($ARGV[0] eq 'test') {
		unshift @INC, '.';	# force to look in pwd first
	}
}

use Prima qw(Application Outlines Notebooks Buttons Edit Markup);

$fp = [
	{ name   => 'Times New Roman', size => 10 },
	{ name   => 'Courier New',     size => 10 },
	];

$enc = $::application->font_encodings;

$esc = {
	char_at_c0 => [1,0xC0],
	sub => sub { 'retval' },
	};

$Main = Prima::Window->create(
	name   => 'Main',
	text   => 'Markup test',
	origin => [100,100],
	size   => [500,500],
	onDestroy => sub { $::application->destroy },
	);

$tn = $Main->insert('Markup::TabbedNotebook',
	origin => [5,5],
	size   => [490,490],
	tabs   => ['B<Basic Controls>', 'I<Detailed List>', 'U<Outline>'],
	fontPalette => $fp,
	growMode => gm::Client,
	);


$tn->insert_to_page(0,'Markup::Label',
	text   => 'Some F<1|monospace text> in a label',
	origin => [5,375],
	size   => [200,20],
	fontPalette => $fp,
	);

$tn->insert_to_page(0,'Markup::Button',
	text   => 'Some C<cl::Red|red text> in a button',
	origin => [5,350],
	size   => [200,20],
	fontPalette => $fp,
	);

$tn->insert_to_page(0,'Markup::Radio',
	text   => 'Some S<+2|big text> in a radio button',
	origin => [5,325],
	size   => [200,20],
	fontPalette => $fp,
	);

$tn->insert_to_page(0,'Markup::CheckBox',
	text   => 'Some S<-2|small text> in a checkbox',
	origin => [5,300],
	size   => [200,20],
	fontPalette => $fp,
	);

$tn->insert_to_page(0,'Markup::GroupBox',
	text   => 'Some B<mixed> I<text> in a groupbox',
	origin => [5,200],
	size   => [200,95],
	fontPalette => $fp,
	);

$tn->insert_to_page(0,'Markup::ListBox',
	items  => [
		'Some B<bold text>',
		'Some I<italic text>',
		'Some U<underlined text>',
		'Some escapes: E<char_at_c0>, E<sub>',
		],
	origin => [5,100],
	size   => [200,95],
	fontPalette => $fp,
	encodings => $enc,
	escapes => $esc,
	);

$tn->insert_to_page(0,'Markup::Edit',
	name   => 'EditTest',
	text   => "Some different encodings in an Edit:
The character at 0xC0:
N<0|\xC0> ($enc->[0])
N<1|\xC0> ($enc->[1])
N<2|\xC0> ($enc->[2])
N<3|\xC0> ($enc->[3])",
	origin => [5,0],
	size   => [200,95],
	fontPalette => $fp,
	encodings => $enc,
	escapes => $esc,
	readOnly => 1,
	hScroll => 1,
	vScroll => 1,
	);

$tn->insert_to_page(1,'Markup::DetailedList',
	items  => [
		['Some B<bold text>', 'Some I<italic text>', 'Some U<underlined text>' ],
		['Some S<+2|big text>', 'Some S<-2|small text>', 'Some F<1|monospace text>' ],
		],
	columns => 3,
	headers => ['B<Works>', 'in I<headers>', 'U<too>'],
	origin => [5,5],
	size   => [454,394],
	fontPalette => $fp,
	);

$tn->insert_to_page(2,'Markup::Outline',
	items  => [
		['Some B<bold text>', [
			['Some I<italic text>'],
			['Some U<underlined text>'],
			]],
		 ['Some S<+2|big text>', [
			['Some S<-2|small text>', [
				['Some F<1|monospace text>' ],
				]],
			]],
		],
	origin => [5,5],
	size   => [454,394],
	fontPalette => $fp,
	) if 0;

run Prima;
