# This file was automatically generated.
# Do not edit, you'll loose your changes anyway.
package Prima::Config;
use vars qw(%Config %Config_inst);

%Config_inst = (
  incpaths              => [ '/usr/local/lib/perl5/site_perl/5.6.1/mach/Prima/CORE','/usr/local/lib/perl5/site_perl/5.6.1/mach/Prima/CORE/generic','/usr/local/lib/perl5/5.6.1/mach/CORE','/usr/local/include','/usr/X11R6/include','/usr/local/include/freetype2' ],
  gencls                => '/usr/local/bin\\gencls',
  tmlink                => '/usr/local/bin\\tmlink',
  libname               => '/usr/local/lib/perl5/site_perl/5.6.1/mach/Prima.a',
  dlname                => '/usr/local/lib/perl5/site_perl/5.6.1/mach/auto/Prima/Prima.so',
  ldpaths               => ['/usr/lib','/usr/local/lib','/usr/local/lib','/usr/X11R6/lib'],
);

%Config = (
  ifs                   => '/',
  quote                 => '\'',
  platform              => 'unix',
  compiler              => 'gcc',
  incpaths              => [ '/usr/home/dk/download/Prima-1.15/include','/usr/home/dk/download/Prima-1.15/include/generic','/usr/local/lib/perl5/5.6.1/mach/CORE','/usr/local/include','/usr/X11R6/include','/usr/local/include/freetype2' ],
  platform_path         => '/usr/home/dk/download/Prima-1.15/unix',
  gencls                => '\'perl\' /usr/home/dk/download/Prima-1.15/utils/gencls.pl',
  tmlink                => '\'perl\' /usr/home/dk/download/Prima-1.15/utils/tmlink.pl',
  scriptext             => '',
  genclsoptions         => '--tml --h --inc',
  cc                    => 'cc',
  cflags                => '-c -DAPPLLIB_EXP="/usr/local/lib/perl5/5.6.1/BSDPAN" -fno-strict-aliasing -I/usr/local/include -Wall  -O -pipe -mcpu=pentiumpro  ',
  cdebugflags           => '-g -O',
  cincflag              => '-I',
  cobjflag              => '-o ',
  cdefflag              => '-D',
  cdefs                 => ['HAVE_CONFIG_H=1'],
  objext                => '.o',
  lib                   => '',
  liboutflag            => '',
  libext                => '.a',
  libname               => '/usr/home/dk/download/Prima-1.15/auto/Prima/Prima.a',
  dlname                => '/usr/home/dk/download/Prima-1.15/auto/Prima/Prima.so',
  dlext                 => '.so',
  ld                    => 'cc',
  ldflags               => ' -shared  -L/usr/local/lib  ',
  lddefflag             => '',
  lddebugflags          => '-g',
  ldoutflag             => '-o ',
  ldlibflag             => '-l',
  ldlibpathflag         => '-L',
  ldpaths               => ['/usr/lib','/usr/local/lib','/usr/local/lib','/usr/X11R6/lib'],
  ldlibs                => ['m','c','crypt','util','gcc','X11','Xext','freetype','fontconfig','Xrender','Xft','iconv','jpeg','png','tiff','ungif','Xpm'],
  ldlibext              =>'',
  inline                => 'inline',
  perl                  => 'perl',
  dl_load_flags         => 1,
);

1;
