# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config);

%Config = (
  ifs                   => '/',
  quote                 => '\'',
  platform              => 'unix',
  compiler              => 'gcc',
  incpaths              => [ '/usr/home/dk/src/Prima/include','/usr/home/dk/src/Prima/include/generic','/usr/libdata/perl/5.00503/mach/CORE','/usr/include','/usr/local/include','/usr/X11R6/include' ],
  platform_path         => '/usr/home/dk/src/Prima/unix',
  gencls                => '\'perl\' /usr/home/dk/src/Prima/utils/gencls.pl',
  tmlink                => '\'perl\' /usr/home/dk/src/Prima/utils/tmlink.pl',
  scriptext             => '',
  genclsoptions         => '--tml --h --inc',
  cc                    => 'cc',
  cflags                => '-c  -Wall  ',
  cdebugflags           => '-g -O',
  cincflag              => '-I',
  cobjflag              => '-o',
  cdefflag              => '-D',
  cdefs                 => ['HAVE_CONFIG_H=1'],
  objext                => '.o',
  lib                   => '',
  liboutflag            => '',
  libext                => '.a',
  libname               => '/usr/home/dk/src/Prima/auto/Prima/Prima.a',
  dlname                => '/usr/home/dk/src/Prima/auto/Prima/Prima.so',
  dlext                 => '.so',
  ld                    => 'cc',
  ldflags               => ' -Wl,-E -shared -lperl -lm  -lgcc ',
  lddefflag             => '',
  lddebugflags          => '-g',
  ldoutflag             => '-o',
  ldlibflag             => '-l',
  ldlibpathflag         => '-L',
  ldpaths               => ['/usr/lib','/usr/local/lib','/usr/X11R6/lib'],
  ldlibs                => ['m','c','crypt','X11','Xext','jpeg','ungif'],
  ldlibext              =>'',
  perl                  => 'perl',
);

1;
