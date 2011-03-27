# $Id: fmview.pl,v 1.1 2005/09/28 09:30:03 dk Exp $

die <<USAGE unless @ARGV;
Prima::VB form file viewer

format: $0 file.fm
USAGE

use Prima qw(Application VB::VBLoader);
my $ret = Prima::VBLoad( $ARGV[0] );
die "$@\n" unless $ret;
$ret-> execute;
