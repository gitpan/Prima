# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
  incpaths              => [ '/usr/local/lib/perl5/site_perl/5.8.0/i386-freebsd/Prima/CORE','/usr/local/lib/perl5/site_perl/5.8.0/i386-freebsd/Prima/CORE/generic','/usr/local/lib/perl5/5.8.0/i386-freebsd/CORE','/usr/local/include','/usr/X11R6/include' ],
  gencls                => '/usr/local/bin\\gencls',
  tmlink                => '/usr/local/bin\\tmlink',
  libname               => '/usr/local/lib/perl5/site_perl/5.8.0/i386-freebsd/Prima.a',
  dlname                => '/usr/local/lib/perl5/site_perl/5.8.0/i386-freebsd/auto/Prima/Prima.so',
  ldpaths               => ['/usr/lib','/usr/local/lib','/usr/local/lib','/usr/X11R6/lib'],
);

%Config = (
  ifs                   => '/',
  quote                 => '\'',
  platform              => 'unix',
  compiler              => 'gcc',
  incpaths              => [ '/usr/home/dk/src/Prima/include','/usr/home/dk/src/Prima/include/generic','/usr/local/lib/perl5/5.8.0/i386-freebsd/CORE','/usr/local/include','/usr/X11R6/include' ],
  platform_path         => '/usr/home/dk/src/Prima/unix',
  gencls                => '\'/usr/local/bin/perl58\' /usr/home/dk/src/Prima/utils/gencls.pl',
  tmlink                => '\'/usr/local/bin/perl58\' /usr/home/dk/src/Prima/utils/tmlink.pl',
  scriptext             => '',
  genclsoptions         => '--tml --h --inc',
  cc                    => 'cc',
  cflags                => '-c -DHAS_FPSETMASK -DHAS_FLOATINGPOINT_H -fno-strict-aliasing -I/usr/local/include -Wall  -O  ',
  cdebugflags           => '-g -O',
  cincflag              => '-I',
  cobjflag              => '-o ',
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
  ldflags               => ' -shared  -L/usr/local/lib  ',
  lddefflag             => '',
  lddebugflags          => '-g',
  ldoutflag             => '-o ',
  ldlibflag             => '-l',
  ldlibpathflag         => '-L',
  ldpaths               => ['/usr/lib','/usr/local/lib','/usr/local/lib','/usr/X11R6/lib'],
  ldlibs                => ['m','c','crypt','util','gcc','X11','Xext','jpeg','png','ungif','Xpm'],
  ldlibext              =>'',
  inline                => 'inline',
  perl                  => '/usr/local/bin/perl58',
  dl_load_flags         => 1,
);

1;
