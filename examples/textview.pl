use strict;
use Prima;
use Prima::TextView;
use Prima::Application;


my $w = Prima::Window-> create;

my $t = $w-> insert( TextView => 
  origin => [0,0],
  size   => [ $w-> size],
  growMode => gm::Client,
  borderWidth => 3,
  hScroll  => 1,
);

if (1) {
#open F, 'editor.pl';
open F, 'C:/home/dict/dansk-engelsk.html';
local $/;
$t-> text(<F> . 'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW');
close F;
}
#$t-> text('1234567890');
#$t-> width( 400);

if(0){
  my $i;
  for ( $i = 0; $i < $t-> {superBlockLog}; $i++) {
     my $b = $t-> {superBlocks}->[$i];
     print "$i:@$b\n";
  }
}
#$t-> text(1);

=pod
sub bdump
{
   my $ix = 0;
   for(@{$_[0]}) {
      if ( $ix < Prima::TextView::BLK_PARAMS) {
         my $c = '';
         if ( $ix == Prima::TextView::BLK_LENGTH) {
            $c = 'LEN';
         } elsif ( $ix == Prima::TextView::BLK_OPS) {
            $c = "OPS";
            s/(.)/sprintf("%02x:", ord($1))/ge;
         } 
         print "$c:$ix:$_\n";
      } else {
         print "$ix:$_\n";
      }
      $ix++;
   }
}

my $blk = Prima::TextView::block_create;
Prima::TextView::block_p_add( $blk, Prima::TextView::OP_FONT);
Prima::TextView::block_p_add( $blk, Prima::TextView::OP_TEXT, 'Hello');
Prima::TextView::block_p_add( $blk, Prima::TextView::OP_COLOR, '#00ff00');
Prima::TextView::block_p_add( $blk, Prima::TextView::block_p_item( $blk, 0));
Prima::TextView::block_p_add( $blk, 1, 'Hello');
my @r =Prima::TextView::block_p_item( $blk, 2);
Prima::TextView::block_p_add( $blk, @r);
bdump( $blk);
#print "=@r\n";
=cut

run Prima;


