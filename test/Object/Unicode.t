# $Id: Unicode.t,v 1.1 2002/10/31 12:56:35 dk Exp $

unless ( $::application-> get_system_value( sv::CanUTF8_Output)) {
   print "1..1 support\n";
   skip;
   return 1;
}

print "1..2 support, wrap utf8 text\n";
ok(1);

my @r = @{$::application-> text_wrap( "line\x{2028}line", 1000, tw::NewLineBreak)};
ok( 2 == @r && $r[0] eq $r[1]);

1;
