use strict;

package Prima::Markup;
use vars qw($VERSION %ESCAPES);

$VERSION = 0.02;

=head1 NAME

Prima::Markup - Allow markup in Prima Widgets

=head1 SYNOPSIS

    use Prima qw(Application Buttons Markup);
    my $markup_button = Prima::Markup::Button->create(...);

=head1 DESCRIPTION

C<Prima::Markup> adds the ability to recognize POD-like markup to Prima widgets.
Currently supported markup sequences are C<B> (bold text), C<I> (italic text),
C<U> (underlined text), C<E> (escape sequences), C<F> (change font), C<S>
(change font size), C<N> (change font encoding), and C<C> (change color).

The C<F> sequence is used as follows: C<FE<lt>n|textE<gt>>, where C<n> is a
0-based index into the C<fontPalette>.

The C<S> sequence is used as follows: C<SE<lt>n|textE<gt>>, where C<n> is the
font size.  The font size may optionally be preceded by C<+> or C<->, in which
case it is relative to the current font size.

The C<N> sequence is used as follows: C<NE<lt>n|textE<gt>>, where C<n> is a
0-based index into the C<encodings>.

The C<C> sequence is used as follows: C<CE<lt>c|textE<gt>>, where C<c> is a color
in any form accepted by Prima, including the C<cl> constants (C<Black> C<Blue>
C<Green> C<Cyan> C<Red> C<Magenta> C<Brown> C<LightGray> C<DarkGray> C<LightBlue>
C<LightGreen> C<LightCyan> C<LightRed> C<LightMagenta> C<Yellow> C<White> C<Gray>).

The methods C<text_out> and C<get_text_width> are affected by C<Prima::Markup>.
C<text_out> will write formatted text to the canvas, and C<get_text_width> will
return the width of the formatted text.  B<NOTE>: These methods do not save state
between calls, so your markup cannot span lines (since each line is drawn or
measured with a separate call).

=head1 AUTHORS

Teo Sankaro, E<lt>teo_sankaro@hotmail.comE<gt> 
minor fixes by Dmitry Karasik, E<lt>dmitry@karasik.eu.orgE<gt>.

=cut

sub text_out {
	my ($self, $text, $x, $y, $len) = @_;
	return unless $self-> get_paint_state;
	substr( $text, $len) = '' if defined $len && $len >= 0;
	my @font_stack = ($self->fontPalette->[0]);
	my @color_stack = ($self->color);
	my @size_stack = ($self->font->size);
	my @encoding_stack = ($self->encodings->[0]);
	my (@cmd_stack, @delim_stack, $iCounter, $bCounter, $uCounter, $escape);
	$iCounter = $bCounter = $uCounter = 0;
	my @tokens = split /([A-Z]<(?:<+\s+)?)/, $text;
	while ( @tokens ) {
		my $token = shift @tokens;
		## Look for the beginning of a sequence
		if ( $token=~/^([A-Z])(<(?:<+\s+)?)$/ ) {
			## Push a new sequence onto the stack of those "in-progress"
			my ($cmd, $ldelim) = ($1, $2);
			$ldelim =~ s/\s+$//, (my $rdelim = $ldelim) =~ tr/</>/;
			push @cmd_stack, $cmd;
			push @delim_stack, $rdelim;

			if ($cmd eq 'C') {
				(shift @tokens)=~/^([^|]+)\|(.*)$/;
				push @color_stack, eval "$1";
				$self->color($color_stack[$#color_stack]);
				unshift @tokens, $2;
			}
			elsif ($cmd eq 'F') {
				(shift @tokens)=~/^([^|]+)\|(.*)$/;
				push @font_stack,$self->fontPalette->[eval "$1"];
				$self->font($font_stack[$#font_stack]);
				unshift @tokens, $2;
			}
			elsif ($cmd eq 'S') {
				(shift @tokens)=~/^([^|]+)\|(.*)$/;
				unshift @tokens, $2;
				my $s = $1;
				if ($1=~/^[+-]/) {
					$s = eval "$size_stack[$#size_stack] $s";
				}
				else {
					$s = eval "$s";
				}
				push @size_stack, $s;
			}
			elsif ($cmd eq 'N') {
				(shift @tokens)=~/^([^|]+)\|(.*)$/;
				push @encoding_stack,$self->encodings->[eval "$1"];
				$self->font->encoding($encoding_stack[$#encoding_stack]);
				unshift @tokens, $2;
			}
			elsif ($cmd eq 'I') {
				$iCounter++;
			}
			elsif ($cmd eq 'B') {
				$bCounter++;
			}
			elsif ($cmd eq 'U') {
				$uCounter++;
			}
			elsif ($cmd eq 'E') {
				$escape = 1;
			}
			my $b = ($bCounter > 0) ? fs::Bold : 0;
			my $i = ($iCounter > 0) ? fs::Italic : 0;
			my $u = ($uCounter > 0) ? fs::Underlined : 0;
			$self->font->style($b | $i | $u);
			$self->font->size($size_stack[$#size_stack]);
		} # end of if block for open sequence
		## Look for sequence ending
		else {
			## Make sure we match the right kind of closing delimiter
			my ($seq_end, $post_seq) = ("", "");
			my $dlm;
			if ( $dlm = $delim_stack[$#delim_stack] and
			       (
			        ($dlm eq '>' and $token=~/\A(.*?)(\>)/s) or 
				  ($dlm ne '>' and $token=~/\A(.*?)(\s{1,}$dlm)/s)
			       )
                        )
				{
				my $t = $escape ? escape($self,$1) : $1;
				my $old_enc;
				if (ref($t) eq 'ARRAY') {
					$old_enc = $self->font->encoding;
					$self->font->encoding($self->encodings->[$t->[0]]);
					$t = chr($t->[1]);
				}

				Prima::Drawable::text_out($self, $t, $x, $y);
				$x += Prima::Drawable::get_text_width($self, $t);
				if ($old_enc) {
					$self->font->encoding($old_enc);
				}
				my $rest = substr($token, length($1) + length($2));
				length($rest) and unshift @tokens, $rest;

				my $cmd = pop @cmd_stack;
				if ($cmd eq 'C') {
					pop @color_stack;
					$self->color($color_stack[$#color_stack]);
				}
				elsif ($cmd eq 'F') {
					pop @font_stack;
					$self->font($font_stack[$#font_stack]);
				}
				elsif ($cmd eq 'S') {
					pop @size_stack;
				}
				elsif ($cmd eq 'N') {
					pop @encoding_stack;
					$self->font->encoding($encoding_stack[$#encoding_stack]);
				}
				elsif ($cmd eq 'I') {
					$iCounter--;
				}
				elsif ($cmd eq 'B') {
					$bCounter--;
				}
				elsif ($cmd eq 'U') {
					$uCounter--;
				}
				elsif ($cmd eq 'E') {
					$escape = 0;
				}
				my $b = ($bCounter > 0) ? fs::Bold : 0;
				my $i = ($iCounter > 0) ? fs::Italic : 0;
				my $u = ($uCounter > 0) ? fs::Underlined : 0;
				$self->font->style($b | $i | $u);
				$self->font->size($size_stack[$#size_stack]);

				next;
			} # end of if block for close sequence
			else { # if we get here, we're non-escaped text
				Prima::Drawable::text_out($self, $token, $x, $y);
				$x += Prima::Drawable::get_text_width($self, $token);
			}
		} # end of else block after if block for open sequence
	} # end of while loop
	return;
}

sub get_text_width {
	my ($self, $text, $len, $add_overhang) = @_;
	my $paint_state = $self->get_paint_state;
	$self->begin_paint_info unless $paint_state;
	substr( $text, $len) = '' if defined $len && $len >= 0;
	my @font_stack = ($self->fontPalette->[0]);
	my @size_stack = ($self->font->size);
	my @encoding_stack = ($self->encodings->[0]);
	my (@cmd_stack, @delim_stack, $iCounter, $bCounter, $uCounter, $escape);
	$iCounter = $bCounter = $uCounter = 0;
	my $w = 0;
	my @tokens = split /([A-Z]<(?:<+\s+)?)/, $text;
	while ( @tokens ) {
		my $token = shift @tokens;
		## Look for the beginning of a sequence
		if ( $token=~/^([A-Z])(<(?:<+\s+)?)$/ ) {
			## Push a new sequence onto the stack of those "in-progress"
			my ($cmd, $ldelim) = ($1, $2);
			$ldelim =~ s/\s+$//, (my $rdelim = $ldelim) =~ tr/</>/;
			push @cmd_stack, $cmd;
			push @delim_stack, $rdelim;

			if ($cmd eq 'C') {
				(shift @tokens)=~/^([^|]+)\|(.*)$/;
				unshift @tokens, $2;
			}
			elsif ($cmd eq 'F') {
				(shift @tokens)=~/^([^|]+)\|(.*)$/;
				push @font_stack,$self->fontPalette->[eval "$1"];
				$self->font($font_stack[$#font_stack]);
				unshift @tokens, $2;
			}
			elsif ($cmd eq 'S') {
				(shift @tokens)=~/^([^|]+)\|(.*)$/;
				unshift @tokens, $2;
				my $s = $1;
				if ($1=~/^[+-]/) {
					$s = eval "$size_stack[$#size_stack] $s";
				}
				else {
					$s = eval "$s";
				}
				push @size_stack, $s;
			}
			elsif ($cmd eq 'N') {
				(shift @tokens)=~/^([^|]+)\|(.*)$/;
				push @encoding_stack,$self->encodings->[eval "$1"];
				$self->font->encoding($encoding_stack[$#encoding_stack]);
				unshift @tokens, $2;
			}
			elsif ($cmd eq 'I') {
				$iCounter++;
			}
			elsif ($cmd eq 'B') {
				$bCounter++;
			}
			elsif ($cmd eq 'U') {
				$uCounter++;
			}
			elsif ($cmd eq 'E') {
				$escape = 1;
			}
			my $b = ($bCounter > 0) ? fs::Bold : 0;
			my $i = ($iCounter > 0) ? fs::Italic : 0;
			my $u = ($uCounter > 0) ? fs::Underlined : 0;
			$self->font->style($b | $i | $u);
			$self->font->size($size_stack[$#size_stack]);
		} # end of if block for open sequence
		## Look for sequence ending
		else {
			## Make sure we match the right kind of closing delimiter
			my ($seq_end, $post_seq) = ("", "");
			my $dlm;
			if ( $dlm = $delim_stack[$#delim_stack] and
			       (
			        ($dlm eq '>' and $token=~/\A(.*?)(\>)/s) or 
				  ($dlm ne '>' and $token=~/\A(.*?)(\s{1,}$dlm)/s)
			       )
                        )
				{
 				## Found end-of-sequence, capture the interior and the
				## closing the delimiter, and put the rest back on the
				## token-list
				my $t = $escape ? escape($self,$1) : $1;
				my $old_enc;
				if (ref($t) eq 'ARRAY') {
					$old_enc = $self->font->encoding;
					$self->font->encoding($self->encodings->[$t->[0]]);
					$t = chr($t->[1]);
				}
				$w += Prima::Drawable::get_text_width($self, $t);
				if ($old_enc) {
					$self->font->encoding($old_enc);
				}
				my $rest = substr($token, length($1) + length($2));
				length($rest) and unshift @tokens, $rest;

				my $cmd = pop @cmd_stack;
				if ($cmd eq 'F') {
					pop @font_stack;
					$self->font($font_stack[$#font_stack]);
				}
				elsif ($cmd eq 'S') {
					pop @size_stack;
				}
				elsif ($cmd eq 'N') {
					pop @encoding_stack;
					$self->font->encoding($encoding_stack[$#encoding_stack]);
				}
				elsif ($cmd eq 'I') {
					$iCounter--;
				}
				elsif ($cmd eq 'B') {
					$bCounter--;
				}
				elsif ($cmd eq 'U') {
					$uCounter--;
				}
				elsif ($cmd eq 'E') {
					$escape = 0;
				}
				my $b = ($bCounter > 0) ? fs::Bold : 0;
				my $i = ($iCounter > 0) ? fs::Italic : 0;
				my $u = ($uCounter > 0) ? fs::Underlined : 0;
				$self->font->style($b | $i | $u);
				$self->font->size($size_stack[$#size_stack]);

				next;
			} # end of if block for close sequence
			else { # if we get here, we're unescaped text
				$w += Prima::Drawable::get_text_width($self, $token);
			}
		} # end of else block after if block for open sequence
	} # end of while loop
	$self->end_paint_info unless $paint_state;
	return $w;
}

sub profile_default_markup
{
	return {
		fontPalette => [],
		escapes	    => {},
		encodings   => [],
	}
}

sub init_markup
{
	my ( $self, $profile) = @_;
        $profile->{font} = $profile->{fontPalette}->[0] if @{$profile->{fontPalette}};
	$self->fontPalette($profile->{fontPalette});
	$self->escapes($profile->{escapes});
	$self->encodings($profile->{encodings});
}

=head1 WIDGETS

The following widgets are defined:

    Markup::Button
    Markup::Radio
    Markup::CheckBox
    Markup::GroupBox

    Markup::ComboBox

    Markup::DetailedList

    Markup::CheckList

    Markup::Header

    Markup::Label

    Markup::ListBox

    Markup::TabSet
    Markup::TabbedNotebook

    Markup::StringOutline

You need only C<use Prima::Markup> (or C<use Prima qw(Markup)>) to make any
markup control available.  This is so you don't have to say

 use Prima qw(Application Buttons Label Markup::Button Markup::CheckBox Markup::Label);

but instead can say

 use Prima qw(Application Buttons Label Markup);

(In fact, you don't even have to specify C<Buttons> or C<Label> unless you plan
on using a non-markup version before you use a markup version, since the markup
version will make sure that the base version is loaded.)

=head1 BUGS

C<Prima::Markup> cannot be used when widget draws parts of text string.
In particular, C<Prima::Edit> is not convertable to markup scheme. 
C<Prima::PodView> or C<Prima::TextView> rich text widgets can be used
as a partical substitution here.

=head1 PROPERTIES

The following new properties are introduced:

=over 4

=item $widget->fontPalette([@fontPalette])

Gets or sets the font palette to be used for C<F> sequences within this widget.
Each element of the array should be a hashref suitable for setting a font.  This
method can also accept an arrayref instead of an array.  If called in list
context, returns an array; if called in scalar context, returns an arrayref.

=cut

sub fontPalette {
	my $self = shift;
	
	if (@_) {
		my @p = (ref($_[0]) eq 'ARRAY') ? @{ $_[0] } : @_;
		$self->{fontPalette} = \@p;
		$self->font($p[0]) if @p;	# set font to index 0
		return;
	}
	if ($self->{fontPalette} && @{$self->{fontPalette}}) {
		return @{ $self->{fontPalette} } if wantarray;
		return $self->{fontPalette};
	}
	return ( $self->get_font ) if wantarray;
	return [ $self->get_font ];
}

=item $widget->encodings([@encodings])

Gets or sets the encodings array to be used within C<N> (and possibly C<E>) sequences
within this widget.  See the L<Prima::Application> method C<fonts> for information on
valid values for encodings.  This method can also accept an arrayref instead of an array.
If called in list context, returns an array; if called in scalar context, returns an
arrayref.

=cut

sub encodings {
	my $self = shift;
	if (@_) {
		my @e = (ref($_[0]) eq 'ARRAY') ? @{$_[0]} : @_;
		$self->{encodings} = \@e;
		$self->font->encoding( @e ? $e[0] : '');	# set font to index 0
		return;
	}
	if ($self->{encodings}) {
		return @{ $self->{encodings} } if wantarray;
		return $self->{encodings};
	}
	return ( $self->font->encoding ) if wantarray;
	return [ $self->font->encoding ];
}

=item $widget->escapes([%escapes])

Gets or sets the custom escapes hash for a widget.  The keys in the hash should be the
escape sequences, and the values can be a scalar, a coderef, or an arrayref.  If a
scalar, the scalar will be inserted into the text.  If a coderef, the return value will
be inserted into the text (this is useful for inserting the current date and/or time,
for example).  If an arrayref, the first element is an index into C<encodings> and the
second is a position within that encoding (the current font must be valid for the encoding,
or the character will not display properly).  This method can also accept a hashref
instead of a hash.  If called in list context, returns a hash; if called in scalar context,
returns a hashref.

When an C<E> sequence is encountered, the code first checks the custom escapes hash, then
checks the default escapes hash (which was lifted directly from L<Pod::Text>).

Numeric escapes are automatically converted to the appropriate character; no checking of
either escapes hash is performed.  It accepts either decimal or hexadecimal numbers.

The default escapes are:

    'amp'       =>    '&',      # ampersand
    'lt'        =>    '<',      # left chevron, less-than
    'gt'        =>    '>',      # right chevron, greater-than
    'quot'      =>    '"',      # double quote
                                 
    "Aacute"    =>    "\xC1",   # capital A, acute accent
    "aacute"    =>    "\xE1",   # small a, acute accent
    "Acirc"     =>    "\xC2",   # capital A, circumflex accent
    "acirc"     =>    "\xE2",   # small a, circumflex accent
    "AElig"     =>    "\xC6",   # capital AE diphthong (ligature)
    "aelig"     =>    "\xE6",   # small ae diphthong (ligature)
    "Agrave"    =>    "\xC0",   # capital A, grave accent
    "agrave"    =>    "\xE0",   # small a, grave accent
    "Aring"     =>    "\xC5",   # capital A, ring
    "aring"     =>    "\xE5",   # small a, ring
    "Atilde"    =>    "\xC3",   # capital A, tilde
    "atilde"    =>    "\xE3",   # small a, tilde
    "Auml"      =>    "\xC4",   # capital A, dieresis or umlaut mark
    "auml"      =>    "\xE4",   # small a, dieresis or umlaut mark
    "Ccedil"    =>    "\xC7",   # capital C, cedilla
    "ccedil"    =>    "\xE7",   # small c, cedilla
    "Eacute"    =>    "\xC9",   # capital E, acute accent
    "eacute"    =>    "\xE9",   # small e, acute accent
    "Ecirc"     =>    "\xCA",   # capital E, circumflex accent
    "ecirc"     =>    "\xEA",   # small e, circumflex accent
    "Egrave"    =>    "\xC8",   # capital E, grave accent
    "egrave"    =>    "\xE8",   # small e, grave accent
    "ETH"       =>    "\xD0",   # capital Eth, Icelandic
    "eth"       =>    "\xF0",   # small eth, Icelandic
    "Euml"      =>    "\xCB",   # capital E, dieresis or umlaut mark
    "euml"      =>    "\xEB",   # small e, dieresis or umlaut mark
    "Iacute"    =>    "\xCD",   # capital I, acute accent
    "iacute"    =>    "\xED",   # small i, acute accent
    "Icirc"     =>    "\xCE",   # capital I, circumflex accent
    "icirc"     =>    "\xEE",   # small i, circumflex accent
    "Igrave"    =>    "\xCD",   # capital I, grave accent
    "igrave"    =>    "\xED",   # small i, grave accent
    "Iuml"      =>    "\xCF",   # capital I, dieresis or umlaut mark
    "iuml"      =>    "\xEF",   # small i, dieresis or umlaut mark
    "Ntilde"    =>    "\xD1",   # capital N, tilde
    "ntilde"    =>    "\xF1",   # small n, tilde
    "Oacute"    =>    "\xD3",   # capital O, acute accent
    "oacute"    =>    "\xF3",   # small o, acute accent
    "Ocirc"     =>    "\xD4",   # capital O, circumflex accent
    "ocirc"     =>    "\xF4",   # small o, circumflex accent
    "Ograve"    =>    "\xD2",   # capital O, grave accent
    "ograve"    =>    "\xF2",   # small o, grave accent
    "Oslash"    =>    "\xD8",   # capital O, slash
    "oslash"    =>    "\xF8",   # small o, slash
    "Otilde"    =>    "\xD5",   # capital O, tilde
    "otilde"    =>    "\xF5",   # small o, tilde
    "Ouml"      =>    "\xD6",   # capital O, dieresis or umlaut mark
    "ouml"      =>    "\xF6",   # small o, dieresis or umlaut mark
    "szlig"     =>    "\xDF",   # small sharp s, German (sz ligature)
    "THORN"     =>    "\xDE",   # capital THORN, Icelandic
    "thorn"     =>    "\xFE",   # small thorn, Icelandic
    "Uacute"    =>    "\xDA",   # capital U, acute accent
    "uacute"    =>    "\xFA",   # small u, acute accent
    "Ucirc"     =>    "\xDB",   # capital U, circumflex accent
    "ucirc"     =>    "\xFB",   # small u, circumflex accent
    "Ugrave"    =>    "\xD9",   # capital U, grave accent
    "ugrave"    =>    "\xF9",   # small u, grave accent
    "Uuml"      =>    "\xDC",   # capital U, dieresis or umlaut mark
    "uuml"      =>    "\xFC",   # small u, dieresis or umlaut mark
    "Yacute"    =>    "\xDD",   # capital Y, acute accent
    "yacute"    =>    "\xFD",   # small y, acute accent
    "yuml"      =>    "\xFF",   # small y, dieresis or umlaut mark
                                  
    "lchevron"  =>    "\xAB",   # left chevron (double less than) laquo
    "rchevron"  =>    "\xBB",   # right chevron (double greater than) raquo

    "iexcl"  =>   "\xA1",   # inverted exclamation mark
    "cent"   =>   "\xA2",   # cent sign
    "pound"  =>   "\xA3",   # (UK) pound sign
    "curren" =>   "\xA4",   # currency sign
    "yen"    =>   "\xA5",   # yen sign
    "brvbar" =>   "\xA6",   # broken vertical bar
    "sect"   =>   "\xA7",   # section sign
    "uml"    =>   "\xA8",   # diaresis
    "copy"   =>   "\xA9",   # Copyright symbol
    "ordf"   =>   "\xAA",   # feminine ordinal indicator
    "laquo"  =>   "\xAB",   # left pointing double angle quotation mark
    "not"    =>   "\xAC",   # not sign
    "shy"    =>   "\xAD",   # soft hyphen
    "reg"    =>   "\xAE",   # registered trademark
    "macr"   =>   "\xAF",   # macron, overline
    "deg"    =>   "\xB0",   # degree sign
    "plusmn" =>   "\xB1",   # plus-minus sign
    "sup2"   =>   "\xB2",   # superscript 2
    "sup3"   =>   "\xB3",   # superscript 3
    "acute"  =>   "\xB4",   # acute accent
    "micro"  =>   "\xB5",   # micro sign
    "para"   =>   "\xB6",   # pilcrow sign = paragraph sign
    "middot" =>   "\xB7",   # middle dot = Georgian comma
    "cedil"  =>   "\xB8",   # cedilla
    "sup1"   =>   "\xB9",   # superscript 1
    "ordm"   =>   "\xBA",   # masculine ordinal indicator
    "raquo"  =>   "\xBB",   # right pointing double angle quotation mark
    "frac14" =>   "\xBC",   # vulgar fraction one quarter
    "frac12" =>   "\xBD",   # vulgar fraction one half
    "frac34" =>   "\xBE",   # vulgar fraction three quarters
    "iquest" =>   "\xBF",   # inverted question mark
    "times"  =>   "\xD7",   # multiplication sign
    "divide" =>   "\xF7",   # division sign

=cut

sub escapes {
	my $self = shift;
	my %e = (ref($_[0]) eq 'HASH') ? %{$_[0]} : @_;
	$self->{escapes} = \%e;
	return wantarray ? %e : \%e;
}

sub escape {
	my ($self, $esc) = @_;
	my $result = $self->{'escapes'}{$esc};
	if (ref($result) eq 'ARRAY') {
		return $result;
	}
	if (ref($result) eq 'CODE') {
		return &$result;
	}
	return undef if ref($result);	# no other refs valid

	return chr($esc) if ($esc=~/^\d+$/);
	return chr(hex $esc) if ($esc=~s/^x([A-Fa-f0-9]+)$/$1/);
	return $result if (exists $self->{'escapes'}{$esc});
	return $ESCAPES{$esc};
}

# stolen from Pod::Text
%ESCAPES = (
    'amp'       =>    '&',      # ampersand
    'lt'        =>    '<',      # left chevron, less-than
    'gt'        =>    '>',      # right chevron, greater-than
    'quot'      =>    '"',      # double quote
                                 
    "Aacute"    =>    "\xC1",   # capital A, acute accent
    "aacute"    =>    "\xE1",   # small a, acute accent
    "Acirc"     =>    "\xC2",   # capital A, circumflex accent
    "acirc"     =>    "\xE2",   # small a, circumflex accent
    "AElig"     =>    "\xC6",   # capital AE diphthong (ligature)
    "aelig"     =>    "\xE6",   # small ae diphthong (ligature)
    "Agrave"    =>    "\xC0",   # capital A, grave accent
    "agrave"    =>    "\xE0",   # small a, grave accent
    "Aring"     =>    "\xC5",   # capital A, ring
    "aring"     =>    "\xE5",   # small a, ring
    "Atilde"    =>    "\xC3",   # capital A, tilde
    "atilde"    =>    "\xE3",   # small a, tilde
    "Auml"      =>    "\xC4",   # capital A, dieresis or umlaut mark
    "auml"      =>    "\xE4",   # small a, dieresis or umlaut mark
    "Ccedil"    =>    "\xC7",   # capital C, cedilla
    "ccedil"    =>    "\xE7",   # small c, cedilla
    "Eacute"    =>    "\xC9",   # capital E, acute accent
    "eacute"    =>    "\xE9",   # small e, acute accent
    "Ecirc"     =>    "\xCA",   # capital E, circumflex accent
    "ecirc"     =>    "\xEA",   # small e, circumflex accent
    "Egrave"    =>    "\xC8",   # capital E, grave accent
    "egrave"    =>    "\xE8",   # small e, grave accent
    "ETH"       =>    "\xD0",   # capital Eth, Icelandic
    "eth"       =>    "\xF0",   # small eth, Icelandic
    "Euml"      =>    "\xCB",   # capital E, dieresis or umlaut mark
    "euml"      =>    "\xEB",   # small e, dieresis or umlaut mark
    "Iacute"    =>    "\xCD",   # capital I, acute accent
    "iacute"    =>    "\xED",   # small i, acute accent
    "Icirc"     =>    "\xCE",   # capital I, circumflex accent
    "icirc"     =>    "\xEE",   # small i, circumflex accent
    "Igrave"    =>    "\xCD",   # capital I, grave accent
    "igrave"    =>    "\xED",   # small i, grave accent
    "Iuml"      =>    "\xCF",   # capital I, dieresis or umlaut mark
    "iuml"      =>    "\xEF",   # small i, dieresis or umlaut mark
    "Ntilde"    =>    "\xD1",   # capital N, tilde
    "ntilde"    =>    "\xF1",   # small n, tilde
    "Oacute"    =>    "\xD3",   # capital O, acute accent
    "oacute"    =>    "\xF3",   # small o, acute accent
    "Ocirc"     =>    "\xD4",   # capital O, circumflex accent
    "ocirc"     =>    "\xF4",   # small o, circumflex accent
    "Ograve"    =>    "\xD2",   # capital O, grave accent
    "ograve"    =>    "\xF2",   # small o, grave accent
    "Oslash"    =>    "\xD8",   # capital O, slash
    "oslash"    =>    "\xF8",   # small o, slash
    "Otilde"    =>    "\xD5",   # capital O, tilde
    "otilde"    =>    "\xF5",   # small o, tilde
    "Ouml"      =>    "\xD6",   # capital O, dieresis or umlaut mark
    "ouml"      =>    "\xF6",   # small o, dieresis or umlaut mark
    "szlig"     =>    "\xDF",   # small sharp s, German (sz ligature)
    "THORN"     =>    "\xDE",   # capital THORN, Icelandic
    "thorn"     =>    "\xFE",   # small thorn, Icelandic
    "Uacute"    =>    "\xDA",   # capital U, acute accent
    "uacute"    =>    "\xFA",   # small u, acute accent
    "Ucirc"     =>    "\xDB",   # capital U, circumflex accent
    "ucirc"     =>    "\xFB",   # small u, circumflex accent
    "Ugrave"    =>    "\xD9",   # capital U, grave accent
    "ugrave"    =>    "\xF9",   # small u, grave accent
    "Uuml"      =>    "\xDC",   # capital U, dieresis or umlaut mark
    "uuml"      =>    "\xFC",   # small u, dieresis or umlaut mark
    "Yacute"    =>    "\xDD",   # capital Y, acute accent
    "yacute"    =>    "\xFD",   # small y, acute accent
    "yuml"      =>    "\xFF",   # small y, dieresis or umlaut mark
                                  
    "lchevron"  =>    "\xAB",   # left chevron (double less than) laquo
    "rchevron"  =>    "\xBB",   # right chevron (double greater than) raquo

    "iexcl"  =>   "\xA1",   # inverted exclamation mark
    "cent"   =>   "\xA2",   # cent sign
    "pound"  =>   "\xA3",   # (UK) pound sign
    "curren" =>   "\xA4",   # currency sign
    "yen"    =>   "\xA5",   # yen sign
    "brvbar" =>   "\xA6",   # broken vertical bar
    "sect"   =>   "\xA7",   # section sign
    "uml"    =>   "\xA8",   # diaresis
    "copy"   =>   "\xA9",   # Copyright symbol
    "ordf"   =>   "\xAA",   # feminine ordinal indicator
    "laquo"  =>   "\xAB",   # left pointing double angle quotation mark
    "not"    =>   "\xAC",   # not sign
    "shy"    =>   "\xAD",   # soft hyphen
    "reg"    =>   "\xAE",   # registered trademark
    "macr"   =>   "\xAF",   # macron, overline
    "deg"    =>   "\xB0",   # degree sign
    "plusmn" =>   "\xB1",   # plus-minus sign
    "sup2"   =>   "\xB2",   # superscript 2
    "sup3"   =>   "\xB3",   # superscript 3
    "acute"  =>   "\xB4",   # acute accent
    "micro"  =>   "\xB5",   # micro sign
    "para"   =>   "\xB6",   # pilcrow sign = paragraph sign
    "middot" =>   "\xB7",   # middle dot = Georgian comma
    "cedil"  =>   "\xB8",   # cedilla
    "sup1"   =>   "\xB9",   # superscript 1
    "ordm"   =>   "\xBA",   # masculine ordinal indicator
    "raquo"  =>   "\xBB",   # right pointing double angle quotation mark
    "frac14" =>   "\xBC",   # vulgar fraction one quarter
    "frac12" =>   "\xBD",   # vulgar fraction one half
    "frac34" =>   "\xBE",   # vulgar fraction three quarters
    "iquest" =>   "\xBF",   # inverted question mark
    "times"  =>   "\xD7",   # multiplication sign
    "divide" =>   "\xF7",   # division sign
);

=head1 METHODS

=item subclass $new_class, $ancestor, %options

Creates $new_class package derived from $ancestor and C<Prima::Markup>,
defining C<profile_default> and C<init> methods so all intrinsic 
markup properies are correctly initialized and C<text_out>/C<get_text_width>
method overloaded. Recognized %options keys:

=over

=item module 

If present, $new_class overloads C<create> method so $module is loaded
prior $new_class creation. This is useful for letting Markup:: class
to decite which module it needs instead of pressing the programmer explicitly
load the underlying packages.

=item profile_default

Includes string of code, to be put in C<profile_default> class method. Useful
when minor properties adjustment are needed.

=item init

Includes string of code, to be put in C<profile_default> class method. Useful
when new properties are defined.


=back

=head1 COPYRIGHT

Copyright 2003 Teo Sankaro

Portions of this code were copied or adapted from L<Pod::Text> by Russ Allbery
and L<Pod::Parser> by Brad Appleton, both of which derive from the original
C<Pod::Text> by Tom Christianson.

You may redistribute and/or modify this module under the same terms as Perl itself.
(Although a credit would be nice.)

=head1 AUTHOR

Teo Sankaro, E<lt>teo_sankaro@hotmail.comE<gt>.

=cut

no strict 'refs';
sub export_base_methods {
	my ($pkg, $file, $line) = caller;
	# alter the symbol table
	for (qw(text_out get_text_width)) {
		*{$pkg ."::$_"} = \&{'Prima::Markup' . "::$_"};
	}
		
}
use strict 'refs';

sub subclass
{
	my ( $new_class, $ancestor, %options) = @_;

        $options{profile_default} = '' unless defined $options{profile_default}; 
        $options{init}            = '' unless defined $options{init}; 

	eval <<STD_SUBCLASS;
package $new_class;
use vars qw(\@ISA);
\@ISA = qw( $ancestor Prima::Markup);
Prima::Markup::export_base_methods;

sub profile_default
{
	return {
	      \%{\$_[ 0]-> SUPER::profile_default},
	      \%{\$_[ 0]-> SUPER::profile_default_markup},
              $options{profile_default}
	}
}

sub init {
	my (\$self,\%profile)=\@_;
	\$self->init_markup(\\\%profile);
	\%profile=\$self->SUPER::init(\%profile);
        $options{init}
        return \%profile;
}

STD_SUBCLASS
        die $@ if $@;
	eval <<AUTOLOAD_MODULE if defined $options{module};
package $new_class;
sub create {
	unless (\%::${ancestor}::) {
		eval "use $options{module}";
		die \$\@ if \$\@;
	}
	return shift->SUPER::create(\@_);
}
AUTOLOAD_MODULE
        die $@ if $@;

}

sub std_subclass 
{ 
   my ( $class, $module, %options) = @_;
   subclass "Prima::Markup::$class", "Prima::$class", module => "Prima::$module", %options
}

std_subclass( $_, 'Buttons') for qw(Button Radio CheckBox GroupBox);
std_subclass( 'ComboBox',     'ComboBox');
std_subclass( 'CheckList', 'ExtLists');
std_subclass( 'DetailedList', 'DetailedList', 
   profile_default => 'headerClass => q(Prima::Markup::Header),');
std_subclass( 'Header', 'Header');
std_subclass( 'Edit', 'Edit');
std_subclass( 'Label', 'Label');
std_subclass( 'ListBox', 'Lists');
std_subclass( 'TabSet', 'Notebooks');
std_subclass( 'TabbedNotebook', 'Notebooks', 
   profile_default => 'tabsetClass => q(Prima::Markup::TabSet),');
std_subclass( 'StringOutline', 'Outlines');

1;
