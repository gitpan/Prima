# $Id: Component.t,v 1.2 2000/10/18 11:58:21 tobez Exp $
print "1..6 create,onCreate,name,onPostMessage,onPostMessage,onDestroy\n";

{ # block for mys
  $dong = 0;
  my @xpm = (0,0);
  my $c = $w-> insert( Component =>
     onCreate  => \&__dong,
     onDestroy => \&__dong,
     onPostMessage => sub { $dong = 1; @xpm = ($_[1],$_[2])},
     name => 'gumbo jumbo',
  );
  ok($c);
  ok($dong);
  ok($c-> name eq 'gumbo jumbo');
  $c-> post_message("abcd", [1..200]);
  $c-> owner( $::application);
  $c-> owner( $w);
  ok(&__wait);
  ok($xpm[0] eq 'abcd' && @{$xpm[1]} == 200);
  $dong = 0;
  $c-> destroy;
  ok($dong);
  return 1;
}
1;

